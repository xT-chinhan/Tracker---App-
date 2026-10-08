import { useEffect, useState } from 'react'
import { keepPreviousData, useQuery } from '@tanstack/react-query'
import { Search, X } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Card } from '@/components/ui/card'
import { Input } from '@/components/ui/input'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { EmptyState, ErrorState, PageHeader, Pagination, TableSkeleton } from '@/components/common'
import { TransactionsTable } from '@/components/TransactionsTable'
import { api, type TxType } from '@/lib/api'
import { formatMonth, formatNumber } from '@/lib/format'
import { useDebounced, useUrlFilters } from '@/lib/utils'

const LIMIT = 15

/** 24 tháng gần nhất theo giờ VN, mới nhất trước. */
const MONTHS = Array.from({ length: 24 }, (_, i) => {
  const now = new Date(Date.now() + 7 * 3600_000)
  return new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth() - i, 1)).toISOString().slice(0, 7)
})

export default function TransactionsPage() {
  const { values, page, set } = useUrlFilters(['userId', 'type', 'month', 'q'] as const)
  const [search, setSearch] = useState(values.q)
  const debounced = useDebounced(search)
  useEffect(() => {
    if (debounced.trim() !== values.q) set({ q: debounced.trim() })
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [debounced])

  const users = useQuery({ queryKey: ['users', 'all'], queryFn: () => api.users({ limit: 200 }) })
  const query = {
    page,
    limit: LIMIT,
    userId: values.userId || undefined,
    type: (values.type || undefined) as TxType | undefined,
    month: values.month || undefined,
    q: values.q || undefined,
  }
  const { data, isPending, isFetching, error, refetch } = useQuery({
    queryKey: ['transactions', query],
    queryFn: () => api.transactions(query),
    placeholderData: keepPreviousData,
  })
  const hasFilter = !!(values.userId || values.type || values.month || values.q)

  return (
    <>
      <PageHeader
        title="Giao dịch"
        description={data ? `${formatNumber(data.total)} giao dịch phù hợp` : 'Toàn bộ giao dịch thu/chi của người dùng'}
      />
      <Card className="gap-0 py-0">
        <div className="flex flex-wrap items-center gap-3 border-b p-4">
          <div className="relative min-w-52 flex-1">
            <Search className="pointer-events-none absolute top-1/2 left-3 size-4 -translate-y-1/2 text-muted-foreground" />
            <Input
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              placeholder="Tìm theo tiêu đề, ghi chú…"
              className="h-9 pl-9"
              data-testid="tx-search"
            />
          </div>
          <Select value={values.userId || 'all'} onValueChange={(v) => set({ userId: v })}>
            <SelectTrigger className="h-9! w-52" data-testid="filter-user"><SelectValue placeholder="Người dùng" /></SelectTrigger>
            <SelectContent className="max-h-80">
              <SelectItem value="all">Mọi người dùng</SelectItem>
              {users.data?.items.map((u) => (
                <SelectItem key={u.id} value={u.id}>
                  <span className="truncate">{u.name}</span>
                  <span className="truncate text-xs text-muted-foreground">{u.email}</span>
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
          <Select value={values.type || 'all'} onValueChange={(v) => set({ type: v })}>
            <SelectTrigger className="h-9! w-32" data-testid="filter-type"><SelectValue /></SelectTrigger>
            <SelectContent>
              <SelectItem value="all">Thu & chi</SelectItem>
              <SelectItem value="INCOME">Thu</SelectItem>
              <SelectItem value="EXPENSE">Chi</SelectItem>
            </SelectContent>
          </Select>
          <Select value={values.month || 'all'} onValueChange={(v) => set({ month: v })}>
            <SelectTrigger className="h-9! w-40" aria-label="Tháng" data-testid="filter-month"><SelectValue /></SelectTrigger>
            <SelectContent className="max-h-80">
              <SelectItem value="all">Mọi thời gian</SelectItem>
              {MONTHS.map((m) => <SelectItem key={m} value={m}>Tháng {formatMonth(m).slice(1)}</SelectItem>)}
            </SelectContent>
          </Select>
          {hasFilter && (
            <Button
              variant="ghost"
              size="sm"
              className="h-9"
              onClick={() => {
                setSearch('')
                set({ userId: '', type: '', month: '', q: '' })
              }}
            >
              <X /> Xóa lọc
            </Button>
          )}
        </div>

        {error ? (
          <ErrorState error={error} onRetry={refetch} />
        ) : isPending ? (
          <TableSkeleton />
        ) : data.items.length === 0 ? (
          <EmptyState title="Không có giao dịch" description={hasFilter ? 'Không có giao dịch nào khớp bộ lọc.' : undefined} />
        ) : (
          <div className={isFetching ? 'opacity-60 transition-opacity' : 'transition-opacity'}>
            <TransactionsTable items={data.items} />
          </div>
        )}
        {data && data.total > 0 && <Pagination page={page} limit={LIMIT} total={data.total} onChange={(p) => set({ page: p })} />}
      </Card>
    </>
  )
}
