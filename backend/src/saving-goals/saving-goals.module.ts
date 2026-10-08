import { BadRequestException, Body, ConflictException, Controller, Delete, Get, HttpCode, Injectable, Module, NotFoundException, Param, ParseUUIDPipe, Patch, Post, Query } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import { IsDateString, IsEnum, IsHexColor, IsInt, IsOptional, IsString, Max, MaxLength, Min, MinLength } from 'class-validator';
import { GoalStatus, SavingGoal } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { AuthUser, CurrentUser } from '../common/auth';
import { MAX_AMOUNT, Trim } from '../common/dto';
import { StatsModule, StatsService } from '../stats/stats.module';

class CreateGoalDto {
  @Trim() @IsString() @MinLength(1) @MaxLength(80) name: string;
  @Type(() => Number) @IsInt() @Min(1) @Max(MAX_AMOUNT) targetAmount: number;
  /** Mặc định hôm nay */
  @IsOptional() @IsDateString() startDate?: string;
  @IsDateString() targetDate: string;
  @IsOptional() @IsString() @MaxLength(50) icon?: string;
  @IsOptional() @IsHexColor() color?: string;
}

class UpdateGoalDto {
  @IsOptional() @Trim() @IsString() @MinLength(1) @MaxLength(80) name?: string;
  @IsOptional() @Type(() => Number) @IsInt() @Min(1) @Max(MAX_AMOUNT) targetAmount?: number;
  @IsOptional() @IsDateString() startDate?: string;
  @IsOptional() @IsDateString() targetDate?: string;
  @IsOptional() @IsString() @MaxLength(50) icon?: string;
  @IsOptional() @IsHexColor() color?: string;
}

class DepositDto {
  @Type(() => Number) @IsInt() @Min(1) @Max(MAX_AMOUNT) amount: number;
  /** Ngày nạp, mặc định hôm nay */
  @IsOptional() @IsDateString() date?: string;
}

class GoalQuery {
  @IsOptional() @IsEnum(GoalStatus) status?: GoalStatus;
}

const CLOSED: GoalStatus[] = ['WITHDRAWN', 'EARLY_WITHDRAWN'];
const DAY_MS = 24 * 60 * 60 * 1000;

/**
 * Luật nghiệp vụ (giữ theo app cũ):
 * - Nạp: trừ vào số dư, không vượt quá số còn thiếu (phần dư bị cắt), số dư phải đủ.
 * - Đủ mục tiêu => COMPLETED. Rút: trả toàn bộ về số dư, COMPLETED => WITHDRAWN, chưa đủ => EARLY_WITHDRAWN.
 * - Mục tiêu đã rút không nạp thêm được.
 */
@Injectable()
export class SavingGoalsService {
  constructor(private readonly prisma: PrismaService, private readonly stats: StatsService) {}

  async list(userId: string, status?: GoalStatus) {
    const goals = await this.prisma.savingGoal.findMany({
      where: { userId, status },
      orderBy: [{ status: 'asc' }, { targetDate: 'asc' }],
    });
    return goals.map(withProgress);
  }

  async get(userId: string, id: string) {
    const goal = await this.findOwned(userId, id);
    const entries = await this.prisma.savingEntry.findMany({
      where: { goalId: id },
      orderBy: [{ date: 'desc' }, { createdAt: 'desc' }],
    });
    return { ...withProgress(goal), entries };
  }

  async create(userId: string, dto: CreateGoalDto) {
    const startDate = dto.startDate ? new Date(dto.startDate) : new Date();
    const targetDate = new Date(dto.targetDate);
    if (targetDate <= startDate) throw new BadRequestException('Ngày mục tiêu phải sau ngày bắt đầu');
    const goal = await this.prisma.savingGoal.create({
      data: {
        userId,
        name: dto.name.trim(),
        targetAmount: BigInt(dto.targetAmount),
        startDate,
        targetDate,
        icon: dto.icon,
        color: dto.color,
      },
    });
    return withProgress(goal);
  }

  async update(userId: string, id: string, dto: UpdateGoalDto) {
    const goal = await this.findOwned(userId, id);
    const startDate = dto.startDate ? new Date(dto.startDate) : goal.startDate;
    const targetDate = dto.targetDate ? new Date(dto.targetDate) : goal.targetDate;
    if (targetDate <= startDate) throw new BadRequestException('Ngày mục tiêu phải sau ngày bắt đầu');

    let status = goal.status;
    if (dto.targetAmount !== undefined && !CLOSED.includes(goal.status)) {
      status = goal.savedAmount >= BigInt(dto.targetAmount) ? 'COMPLETED' : 'ACTIVE';
    }
    const updated = await this.prisma.savingGoal.update({
      where: { id },
      data: {
        name: dto.name?.trim(),
        targetAmount: dto.targetAmount !== undefined ? BigInt(dto.targetAmount) : undefined,
        startDate,
        targetDate,
        icon: dto.icon,
        color: dto.color,
        status,
      },
    });
    return withProgress(updated);
  }

  async deposit(userId: string, id: string, dto: DepositDto) {
    return this.prisma.$transaction(async (tx) => {
      // Khóa theo user để 2 lần nạp đồng thời không cùng vượt qua kiểm tra số dư
      await tx.$queryRaw`SELECT 1 FROM "User" WHERE id = ${userId} FOR UPDATE`;
      const goal = await tx.savingGoal.findFirst({ where: { id, userId } });
      if (!goal) throw new NotFoundException('Không tìm thấy mục tiêu');
      if (CLOSED.includes(goal.status)) throw new ConflictException('Mục tiêu đã rút, không thể nạp thêm');

      const stillNeeded = Number(goal.targetAmount - goal.savedAmount);
      if (stillNeeded <= 0) throw new ConflictException('Mục tiêu đã hoàn thành');
      const amount = Math.min(dto.amount, stillNeeded);

      const { balance } = await this.stats.balance(userId);
      if (balance < amount) throw new BadRequestException('Số dư không đủ để nạp');

      await tx.savingEntry.create({
        data: { goalId: id, type: 'DEPOSIT', amount: BigInt(amount), date: dto.date ? new Date(dto.date) : new Date() },
      });
      const savedAmount = goal.savedAmount + BigInt(amount);
      const updated = await tx.savingGoal.update({
        where: { id },
        data: { savedAmount, status: savedAmount >= goal.targetAmount ? 'COMPLETED' : 'ACTIVE' },
      });
      return { goal: withProgress(updated), deposited: amount, capped: amount < dto.amount };
    });
  }

  async withdraw(userId: string, id: string) {
    return this.prisma.$transaction(async (tx) => {
      await tx.$queryRaw`SELECT 1 FROM "User" WHERE id = ${userId} FOR UPDATE`;
      const goal = await tx.savingGoal.findFirst({ where: { id, userId } });
      if (!goal) throw new NotFoundException('Không tìm thấy mục tiêu');
      if (CLOSED.includes(goal.status)) throw new ConflictException('Mục tiêu đã được rút');
      if (goal.savedAmount <= 0n) throw new BadRequestException('Mục tiêu chưa có tiền để rút');

      await tx.savingEntry.create({
        data: { goalId: id, type: 'WITHDRAW', amount: goal.savedAmount, date: new Date() },
      });
      const updated = await tx.savingGoal.update({
        where: { id },
        data: { savedAmount: 0n, status: goal.status === 'COMPLETED' ? 'WITHDRAWN' : 'EARLY_WITHDRAWN' },
      });
      return { goal: withProgress(updated), withdrawn: Number(goal.savedAmount) };
    });
  }

  async remove(userId: string, id: string) {
    const goal = await this.findOwned(userId, id);
    if (goal.savedAmount > 0n) throw new ConflictException('Hãy rút tiền khỏi mục tiêu trước khi xóa');
    await this.prisma.savingGoal.delete({ where: { id } });
  }

  private async findOwned(userId: string, id: string) {
    const goal = await this.prisma.savingGoal.findFirst({ where: { id, userId } });
    if (!goal) throw new NotFoundException('Không tìm thấy mục tiêu');
    return goal;
  }
}

function withProgress(g: SavingGoal) {
  const target = Number(g.targetAmount);
  const saved = Number(g.savedAmount);
  const remaining = Math.max(target - saved, 0);
  const daysLeft = Math.max(Math.ceil((g.targetDate.getTime() - Date.now()) / DAY_MS), 0);
  return {
    ...g,
    targetAmount: target,
    savedAmount: saved,
    remaining,
    progress: target ? Math.min(Math.round((saved / target) * 1000) / 10, 100) : 0,
    daysLeft,
    dailyRequired: CLOSED.includes(g.status) ? 0 : daysLeft > 0 ? Math.ceil(remaining / daysLeft) : remaining,
  };
}

@ApiTags('saving-goals')
@ApiBearerAuth()
@Controller('saving-goals')
export class SavingGoalsController {
  constructor(private readonly goals: SavingGoalsService) {}

  @Get()
  list(@CurrentUser() u: AuthUser, @Query() q: GoalQuery) {
    return this.goals.list(u.id, q.status);
  }

  /** Chi tiết kèm lịch sử nạp/rút */
  @Get(':id')
  get(@CurrentUser() u: AuthUser, @Param('id', ParseUUIDPipe) id: string) {
    return this.goals.get(u.id, id);
  }

  @Post()
  create(@CurrentUser() u: AuthUser, @Body() dto: CreateGoalDto) {
    return this.goals.create(u.id, dto);
  }

  @Patch(':id')
  update(@CurrentUser() u: AuthUser, @Param('id', ParseUUIDPipe) id: string, @Body() dto: UpdateGoalDto) {
    return this.goals.update(u.id, id, dto);
  }

  @Post(':id/deposit') @HttpCode(200)
  deposit(@CurrentUser() u: AuthUser, @Param('id', ParseUUIDPipe) id: string, @Body() dto: DepositDto) {
    return this.goals.deposit(u.id, id, dto);
  }

  @Post(':id/withdraw') @HttpCode(200)
  withdraw(@CurrentUser() u: AuthUser, @Param('id', ParseUUIDPipe) id: string) {
    return this.goals.withdraw(u.id, id);
  }

  @Delete(':id') @HttpCode(204)
  remove(@CurrentUser() u: AuthUser, @Param('id', ParseUUIDPipe) id: string) {
    return this.goals.remove(u.id, id);
  }
}

@Module({ imports: [StatsModule], controllers: [SavingGoalsController], providers: [SavingGoalsService] })
export class SavingGoalsModule {}
