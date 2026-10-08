import { BadRequestException, Body, ConflictException, Controller, Delete, Get, HttpCode, Injectable, Module, NotFoundException, Param, ParseUUIDPipe, Patch, Post, Query } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { IsEnum, IsHexColor, IsOptional, IsString, MaxLength, MinLength } from 'class-validator';
import { TxType } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { AuthUser, CurrentUser } from '../common/auth';
import { Trim } from '../common/dto';

export class CreateCategoryDto {
  @Trim() @IsString() @MinLength(1) @MaxLength(50) name: string;
  @IsEnum(TxType) type: TxType;
  @IsOptional() @IsString() @MaxLength(50) icon?: string;
  @IsOptional() @IsHexColor() color?: string;
}

export class UpdateCategoryDto {
  @IsOptional() @Trim() @IsString() @MinLength(1) @MaxLength(50) name?: string;
  @IsOptional() @IsString() @MaxLength(50) icon?: string;
  @IsOptional() @IsHexColor() color?: string;
}

class CategoryQuery {
  @IsOptional() @IsEnum(TxType) type?: TxType;
}

/** Collation mặc định của Postgres xếp "Ăn uống" sau "Sức khỏe" => sắp xếp tiếng Việt ở tầng ứng dụng. */
const viCollator = new Intl.Collator('vi', { sensitivity: 'base' });
const viCompare = (a: string, b: string) => viCollator.compare(a, b);

/**
 * Dùng chung cho user (ownerId = userId) và admin (ownerId = null => danh mục hệ thống).
 * Tên danh mục là duy nhất trong phạm vi (hệ thống + của user) theo từng loại thu/chi.
 */
@Injectable()
export class CategoriesService {
  constructor(private readonly prisma: PrismaService) {}

  /** Danh mục user được thấy: hệ thống + của riêng mình, chưa lưu trữ. */
  /** Hệ thống trước, của user sau; trong mỗi nhóm xếp theo tên tiếng Việt. */
  async listForUser(userId: string, type?: TxType) {
    const rows = await this.prisma.category.findMany({ where: { isArchived: false, type, OR: [{ userId: null }, { userId }] } });
    return rows.sort((a, b) => Number(a.userId !== null) - Number(b.userId !== null) || viCompare(a.name, b.name));
  }

  /** Đang dùng trước, đã lưu trữ sau; xếp theo tên tiếng Việt. */
  async listSystem(type?: TxType) {
    const rows = await this.prisma.category.findMany({
      where: { userId: null, type },
      include: { _count: { select: { transactions: true } } },
    });
    return rows.sort((a, b) => Number(a.isArchived) - Number(b.isArchived) || viCompare(a.name, b.name));
  }

  /** Danh mục dùng được để ghi giao dịch / ngân sách cho user. */
  async usableForUser(userId: string, categoryId: string) {
    const c = await this.prisma.category.findFirst({
      where: { id: categoryId, isArchived: false, OR: [{ userId: null }, { userId }] },
    });
    if (!c) throw new BadRequestException('Danh mục không tồn tại');
    return c;
  }

  async create(ownerId: string | null, dto: CreateCategoryDto) {
    const name = dto.name.trim();
    await this.assertNameFree(ownerId, name, dto.type);
    return this.prisma.category.create({
      data: { userId: ownerId, name, type: dto.type, icon: dto.icon, color: dto.color },
    });
  }

  async update(ownerId: string | null, id: string, dto: UpdateCategoryDto) {
    const c = await this.findOwned(ownerId, id);
    const name = dto.name?.trim();
    if (name && name !== c.name) await this.assertNameFree(ownerId, name, c.type, id);
    return this.prisma.category.update({
      where: { id },
      data: { name, icon: dto.icon, color: dto.color },
    });
  }

  /**
   * Đã có giao dịch / giao dịch định kỳ => lưu trữ (ẩn) để giữ lịch sử; chưa có => xóa hẳn (mẫu nhập nhanh, ngân sách xóa theo).
   * Danh mục hệ thống: ngân sách / mẫu nhập nhanh của user cũng tính là "đã dùng" => admin xóa không làm mất dữ liệu của user.
   */
  async remove(ownerId: string | null, id: string) {
    await this.findOwned(ownerId, id);
    const used = (await this.prisma.transaction.count({ where: { categoryId: id } }))
      + (await this.prisma.recurringRule.count({ where: { categoryId: id } }))
      + (ownerId === null
        ? (await this.prisma.budget.count({ where: { categoryId: id } })) + (await this.prisma.quickTemplate.count({ where: { categoryId: id } }))
        : 0);
    if (used > 0) {
      await this.prisma.category.update({ where: { id }, data: { isArchived: true } });
      return { archived: true };
    }
    await this.prisma.category.delete({ where: { id } });
    return { archived: false };
  }

  async restore(ownerId: string | null, id: string) {
    const c = await this.findOwned(ownerId, id);
    await this.assertNameFree(ownerId, c.name, c.type, id);
    return this.prisma.category.update({ where: { id }, data: { isArchived: false } });
  }

  private async findOwned(ownerId: string | null, id: string) {
    const c = await this.prisma.category.findFirst({ where: { id, userId: ownerId } });
    if (!c) throw new NotFoundException('Không tìm thấy danh mục');
    return c;
  }

  private async assertNameFree(ownerId: string | null, name: string, type: TxType, exceptId?: string) {
    const scope = ownerId ? [{ userId: null }, { userId: ownerId }] : [{ userId: null }];
    const dup = await this.prisma.category.findFirst({
      where: {
        id: exceptId ? { not: exceptId } : undefined,
        type,
        isArchived: false,
        name: { equals: name, mode: 'insensitive' },
        OR: scope,
      },
    });
    if (dup) throw new ConflictException(`Danh mục "${name}" đã tồn tại`);
  }
}

@ApiTags('categories')
@ApiBearerAuth()
@Controller('categories')
export class CategoriesController {
  constructor(private readonly categories: CategoriesService) {}

  @Get()
  list(@CurrentUser() u: AuthUser, @Query() q: CategoryQuery) {
    return this.categories.listForUser(u.id, q.type);
  }

  @Post()
  create(@CurrentUser() u: AuthUser, @Body() dto: CreateCategoryDto) {
    return this.categories.create(u.id, dto);
  }

  @Patch(':id')
  update(@CurrentUser() u: AuthUser, @Param('id', ParseUUIDPipe) id: string, @Body() dto: UpdateCategoryDto) {
    return this.categories.update(u.id, id, dto);
  }

  @Delete(':id') @HttpCode(200)
  remove(@CurrentUser() u: AuthUser, @Param('id', ParseUUIDPipe) id: string) {
    return this.categories.remove(u.id, id);
  }
}

@Module({ controllers: [CategoriesController], providers: [CategoriesService], exports: [CategoriesService] })
export class CategoriesModule {}
