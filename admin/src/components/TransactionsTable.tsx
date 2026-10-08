import { Link } from 'react-router'
import { ArrowDownLeft, ArrowUpRight } from 'lucide-react'
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table'
import { CategoryChip } from '@/components/CategoryIcon'
import type { Transaction } from '@/lib/api'
import { formatDateTime, formatVND } from '@/lib/format'
import { cn } from '@/lib/utils'

export function TransactionsTable({ items, showUser = true }: { items: Transaction[]; showUser?: boolean }) {
  return (
    <Table>
      <TableHeader>
        <TableRow>
          <TableHead className="w-36 pl-4">Thời gian</TableHead>
          <TableHead>Giao dịch</TableHead>
          {showUser && <TableHead>Người dùng</TableHead>}
          <TableHead>Danh mục</TableHead>
          <TableHead className="pr-4 text-right">Số tiền</TableHead>
        </TableRow>
      </TableHeader>
      <TableBody>
        {items.map((t) => (
          <TableRow key={t.id} data-testid="tx-row">
            <TableCell className="pl-4 text-muted-foreground tabular-nums">{formatDateTime(t.occurredAt)}</TableCell>
            <TableCell className="max-w-72">
              <div className="flex items-center gap-2.5">
                <span
                  className={cn(
                    'flex size-7 shrink-0 items-center justify-center rounded-full',
                    t.type === 'INCOME' ? 'bg-teal-500/10 text-teal-700' : 'bg-rose-500/10 text-rose-700',
                  )}
                  title={t.type === 'INCOME' ? 'Thu' : 'Chi'}
                >
                  {t.type === 'INCOME' ? <ArrowDownLeft className="size-3.5" /> : <ArrowUpRight className="size-3.5" />}
                </span>
                <div className="min-w-0">
                  <p className="truncate font-medium" data-testid="tx-title">{t.title}</p>
                  {t.note && <p className="truncate text-xs text-muted-foreground">{t.note}</p>}
                </div>
              </div>
            </TableCell>
            {showUser && (
              <TableCell className="max-w-56">
                <Link to={`/users/${t.user.id}`} className="block truncate hover:text-primary hover:underline" data-testid="tx-user">
                  {t.user.name}
                </Link>
                <p className="truncate text-xs text-muted-foreground">{t.user.email}</p>
              </TableCell>
            )}
            <TableCell className="max-w-44"><CategoryChip {...t.category} /></TableCell>
            <TableCell
              className={cn('pr-4 text-right font-semibold tabular-nums', t.type === 'INCOME' ? 'text-teal-700' : 'text-rose-700')}
              data-testid="tx-amount"
            >
              {t.type === 'INCOME' ? '+' : '−'}{formatVND(t.amount)}
            </TableCell>
          </TableRow>
        ))}
      </TableBody>
    </Table>
  )
}
