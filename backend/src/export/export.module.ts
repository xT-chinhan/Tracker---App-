import { Controller, Get, Injectable, Module, Query, StreamableFile } from '@nestjs/common';
import { ApiBearerAuth, ApiProduces, ApiTags } from '@nestjs/swagger';
import { IsOptional, IsUUID } from 'class-validator';
import { Readable } from 'stream';
import { PrismaService } from '../prisma/prisma.service';
import { AuthUser, CurrentUser, Feature } from '../common/auth';
import { RangeQuery } from '../common/dto';
import { resolveRange } from '../common/time';
import { WalletsModule, WalletsService } from '../wallets/wallets.module';

class ExportQuery extends RangeQuery {
  @IsOptional() @IsUUID() walletId?: string;
}

const OFFSET_MS = 7 * 60 * 60 * 1000;
const HEADER = ['Ngày', 'Loại', 'Danh mục', 'Ví', 'Tiêu đề', 'Ghi chú', 'Số tiền'];
/** Đọc DB theo lô (keyset) => khoảng thời gian lớn cũng không dồn hết vào RAM */
const BATCH = 1000;

/** RFC 4180: bọc ngoặc kép khi có dấu phẩy / ngoặc kép / xuống dòng, ngoặc kép bên trong nhân đôi. */
export function csvCell(v: string | number | null | undefined): string {
  const s = v === null || v === undefined ? '' : String(v);
  return /[",\r\n]/.test(s) ? `"${s.replace(/"/g, '""')}"` : s;
}

/** "YYYY-MM-DD HH:mm" theo giờ VN */
const vnTime = (d: Date) => new Date(d.getTime() + OFFSET_MS).toISOString().slice(0, 16).replace('T', ' ');

@Injectable()
export class ExportService {
  constructor(private readonly prisma: PrismaService, private readonly wallets: WalletsService) {}

  /** Kiểm tra quyền + query trước (lỗi => 4xx bình thường), sau đó mới trả stream các dòng CSV. */
  async transactionsCsv(userId: string, q: ExportQuery): Promise<Readable> {
    if (q.walletId) await this.wallets.findOwned(userId, q.walletId);
    const range = resolveRange(q);
    const where = { userId, walletId: q.walletId, occurredAt: range.gte || range.lt ? range : undefined };
    const prisma = this.prisma;
    async function* lines() {
      yield '\uFEFF' + HEADER.map(csvCell).join(',') + '\r\n';
      let cursor: string | undefined;
      for (;;) {
        const rows = await prisma.transaction.findMany({
          where,
          include: { category: { select: { name: true } }, wallet: { select: { name: true } } },
          orderBy: [{ occurredAt: 'asc' }, { createdAt: 'asc' }, { id: 'asc' }],
          take: BATCH,
          ...(cursor ? { cursor: { id: cursor }, skip: 1 } : {}),
        });
        if (!rows.length) return;
        yield rows
          .map((t) => [vnTime(t.occurredAt), t.type === 'INCOME' ? 'Thu' : 'Chi', t.category.name, t.wallet.name, t.title, t.note, Number(t.amount)]
            .map(csvCell).join(',') + '\r\n')
          .join('');
        if (rows.length < BATCH) return;
        cursor = rows[rows.length - 1].id;
      }
    }
    return Readable.from(lines());
  }
}

@ApiTags('export')
@ApiBearerAuth()
/** Tính năng có thể tắt trong Cấu hình hệ thống: tắt => mọi route 403 FEATURE_DISABLED */
@Feature('csvExport', { reads: true })
@Controller('export')
export class ExportController {
  constructor(private readonly exporter: ExportService) {}

  /** CSV UTF-8 (có BOM để Excel đọc đúng tiếng Việt), lọc month | from&to, walletId */
  @Get('transactions.csv')
  @ApiProduces('text/csv')
  async transactions(@CurrentUser() u: AuthUser, @Query() q: ExportQuery) {
    return new StreamableFile(await this.exporter.transactionsCsv(u.id, q), {
      type: 'text/csv; charset=utf-8',
      disposition: 'attachment; filename="transactions.csv"',
    });
  }
}

@Module({ imports: [WalletsModule], controllers: [ExportController], providers: [ExportService] })
export class ExportModule {}
