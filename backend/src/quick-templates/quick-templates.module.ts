import { Body, ConflictException, Controller, Delete, Get, HttpCode, Injectable, Module, NotFoundException, Param, ParseUUIDPipe, Patch, Post } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import { IsDateString, IsInt, IsOptional, IsString, IsUUID, Max, MaxLength, Min, MinLength } from 'class-validator';
import { QuickTemplate } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { AuthUser, CurrentUser, Feature } from '../common/auth';
import { MAX_AMOUNT, Trim } from '../common/dto';
import { CategoriesModule, CategoriesService } from '../categories/categories.module';
import { WalletsModule, WalletsService } from '../wallets/wallets.module';
import { TransactionsModule, TransactionsService } from '../transactions/transactions.module';

class CreateTemplateDto {
  /** Nhãn hiển thị trên nút, vd "Cà phê sáng" */
  @Trim() @IsString() @MinLength(1) @MaxLength(50) label: string;
  @Trim() @IsString() @MinLength(1) @MaxLength(120) title: string;
  @Type(() => Number) @IsInt() @Min(1) @Max(MAX_AMOUNT) amount: number;
  @IsUUID() categoryId: string;
  @IsUUID() walletId: string;
  @IsOptional() @IsString() @MaxLength(500) note?: string;
}

class UpdateTemplateDto {
  @IsOptional() @Trim() @IsString() @MinLength(1) @MaxLength(50) label?: string;
  @IsOptional() @Trim() @IsString() @MinLength(1) @MaxLength(120) title?: string;
  @IsOptional() @Type(() => Number) @IsInt() @Min(1) @Max(MAX_AMOUNT) amount?: number;
  @IsOptional() @IsUUID() categoryId?: string;
  @IsOptional() @IsUUID() walletId?: string;
  @IsOptional() @IsString() @MaxLength(500) note?: string;
}

class UseTemplateDto {
  /** Mặc định hiện tại */
  @IsOptional() @IsDateString() occurredAt?: string;
  /** Ghi đè số tiền của mẫu */
  @IsOptional() @Type(() => Number) @IsInt() @Min(1) @Max(MAX_AMOUNT) amount?: number;
}

const INCLUDE = {
  category: { select: { id: true, name: true, icon: true, color: true, type: true, isArchived: true } },
  wallet: { select: { id: true, name: true, type: true, isArchived: true } },
} as const;

const view = <T extends QuickTemplate>(t: T) => ({ ...t, amount: Number(t.amount) });

/** Mẫu nhập nhanh. Danh mục/ví của mẫu bị xóa hẳn => mẫu bị xóa theo; bị lưu trữ => mẫu còn nhưng `use` trả 409. */
@Injectable()
export class QuickTemplatesService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly categories: CategoriesService,
    private readonly wallets: WalletsService,
    private readonly txs: TransactionsService,
  ) {}

  async list(userId: string) {
    const items = await this.prisma.quickTemplate.findMany({ where: { userId }, include: INCLUDE, orderBy: { createdAt: 'asc' } });
    return items.map(view);
  }

  async create(userId: string, dto: CreateTemplateDto) {
    await this.categories.usableForUser(userId, dto.categoryId);
    await this.wallets.usable(userId, dto.walletId);
    const t = await this.prisma.quickTemplate.create({
      data: { userId, ...dto, amount: BigInt(dto.amount), note: dto.note?.trim() || null },
      include: INCLUDE,
    });
    return view(t);
  }

  async update(userId: string, id: string, dto: UpdateTemplateDto) {
    await this.findOwned(userId, id);
    if (dto.categoryId) await this.categories.usableForUser(userId, dto.categoryId);
    if (dto.walletId) await this.wallets.usable(userId, dto.walletId);
    const t = await this.prisma.quickTemplate.update({
      where: { id },
      data: {
        ...dto,
        amount: dto.amount !== undefined ? BigInt(dto.amount) : undefined,
        note: dto.note !== undefined ? dto.note.trim() || null : undefined,
      },
      include: INCLUDE,
    });
    return view(t);
  }

  async remove(userId: string, id: string) {
    await this.findOwned(userId, id);
    await this.prisma.quickTemplate.delete({ where: { id } });
  }

  /** Tạo giao dịch thật qua cùng logic với POST /transactions (kể cả cảnh báo ngân sách). */
  async use(userId: string, id: string, dto: UseTemplateDto) {
    const t = await this.prisma.quickTemplate.findFirst({ where: { id, userId }, include: INCLUDE });
    if (!t) throw new NotFoundException('Không tìm thấy mẫu nhập nhanh');
    if (t.category.isArchived) throw new ConflictException(`Danh mục "${t.category.name}" của mẫu đã bị lưu trữ, hãy sửa mẫu`);
    if (t.wallet.isArchived) throw new ConflictException(`Ví "${t.wallet.name}" của mẫu đã bị lưu trữ, hãy sửa mẫu`);
    return this.txs.create(userId, {
      categoryId: t.categoryId,
      walletId: t.walletId,
      amount: dto.amount ?? Number(t.amount),
      title: t.title,
      note: t.note ?? undefined,
      occurredAt: dto.occurredAt,
    });
  }

  private async findOwned(userId: string, id: string) {
    const t = await this.prisma.quickTemplate.findFirst({ where: { id, userId } });
    if (!t) throw new NotFoundException('Không tìm thấy mẫu nhập nhanh');
    return t;
  }
}

@ApiTags('quick-templates')
@ApiBearerAuth()
/** Tính năng có thể tắt trong Cấu hình hệ thống: tắt => route ghi 403 FEATURE_DISABLED, đọc vẫn được */
@Feature('quickTemplates')
@Controller('quick-templates')
export class QuickTemplatesController {
  constructor(private readonly templates: QuickTemplatesService) {}

  @Get()
  list(@CurrentUser() u: AuthUser) {
    return this.templates.list(u.id);
  }

  @Post()
  create(@CurrentUser() u: AuthUser, @Body() dto: CreateTemplateDto) {
    return this.templates.create(u.id, dto);
  }

  @Patch(':id')
  update(@CurrentUser() u: AuthUser, @Param('id', ParseUUIDPipe) id: string, @Body() dto: UpdateTemplateDto) {
    return this.templates.update(u.id, id, dto);
  }

  @Delete(':id') @HttpCode(204)
  remove(@CurrentUser() u: AuthUser, @Param('id', ParseUUIDPipe) id: string) {
    return this.templates.remove(u.id, id);
  }

  /** Tạo giao dịch từ mẫu (tùy chọn ghi đè ngày, số tiền) */
  @Post(':id/use')
  use(@CurrentUser() u: AuthUser, @Param('id', ParseUUIDPipe) id: string, @Body() dto: UseTemplateDto) {
    return this.templates.use(u.id, id, dto);
  }
}

@Module({
  imports: [CategoriesModule, WalletsModule, TransactionsModule],
  controllers: [QuickTemplatesController],
  providers: [QuickTemplatesService],
})
export class QuickTemplatesModule {}
