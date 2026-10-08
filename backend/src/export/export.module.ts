import { Controller, Get, Injectable, Module, Query, StreamableFile } from '@nestjs/common';
import { ApiBearerAuth, ApiProduces, ApiTags } from '@nestjs/swagger';
import { IsOptional, IsUUID } from 'class-validator';
import { PrismaService } from '../prisma/prisma.service';
import { AuthUser, CurrentUser } from '../common/auth';
import { RangeQuery } from '../common/dto';
import { resolveRange } from '../common/time';
import { WalletsModule, WalletsService } from '../wallets/wallets.module';

class ExportQuery extends RangeQuery {
  @IsOptional() @IsUUID() walletId?: string;
}

const OFFSET_MS = 7 * 60 * 60 * 1000;
const HEADER = ['Ngày', 'Loại', 'Danh mục', 'Ví', 'Tiêu đề', 'Ghi chú', 'Số tiền'];

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

  async transactionsCsv(userId: string, q: ExportQuery) {
    if (q.walletId) await this.wallets.findOwned(userId, q.walletId);
    const range = resolveRange(q);
    const rows = await this.prisma.transaction.findMany({
      where: { userId, walletId: q.walletId, occurredAt: range.gte || range.lt ? range : undefined },
      include: { category: { select: { name: true } }, wallet: { select: { name: true } } },
      orderBy: [{ occurredAt: 'asc' }, { createdAt: 'asc' }],
    });
    const lines = [HEADER, ...rows.map((t) => [
      vnTime(t.occurredAt),
      t.type === 'INCOME' ? 'Thu' : 'Chi',
      t.category.name,
      t.wallet.name,
      t.title,
      t.note,
      Number(t.amount),
    ])].map((cols) => cols.map(csvCell).join(','));
    return '\uFEFF' + lines.join('\r\n') + '\r\n';
  }
}

@ApiTags('export')
@ApiBearerAuth()
@Controller('export')
export class ExportController {
  constructor(private readonly exporter: ExportService) {}

  /** CSV UTF-8 (có BOM để Excel đọc đúng tiếng Việt), lọc month | from&to, walletId */
  @Get('transactions.csv')
  @ApiProduces('text/csv')
  async transactions(@CurrentUser() u: AuthUser, @Query() q: ExportQuery) {
    return new StreamableFile(Buffer.from(await this.exporter.transactionsCsv(u.id, q), 'utf8'), {
      type: 'text/csv; charset=utf-8',
      disposition: 'attachment; filename="transactions.csv"',
    });
  }
}

@Module({ imports: [WalletsModule], controllers: [ExportController], providers: [ExportService] })
export class ExportModule {}
