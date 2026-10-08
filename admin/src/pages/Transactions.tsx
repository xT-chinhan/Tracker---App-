import { useEffect, useState } from 'react'
import { Link } from 'react-router'
import { keepPreviousData, useQuery } from '@tanstack/react-query'
import { Calendar, Download, Search, X } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Card } from '@/components/ui/card'
import { Input } from '@/components/ui/input'
import { Select, SelectContent, SelectItem, SelectTrigger } from '@/components/ui/select'
import { notify } from '@/components/ui/sonner'
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table'
import { Tabs, TabsList, TabsTrigger } from '@/components/ui/tabs'
import { CategoryChip } from '@/components/CategoryIcon'
import { EmptyState, ErrorState, PageHeader, Pagination, TableSkeleton, UserBubble } from '@/components/common'
import { api, type Transaction, type TxQuery, type TxType } from '@/lib/api'
import { formatDate, formatDayMonth, formatMonthLong, formatNumber, formatSigned, formatTime, formatVND, TYPE_LABEL } from '@/lib/format'
import { cn, useDebounced, useUrlFilters } from '@/lib/utils'

const LIMIT = 10
const CSV_MAX = 10_000

/** 24 tháng gần nhất theo giờ VN, mới nhất trước. */
const MONTHS = Array.from({ length: 24 }, (_, i) => {
  const now = new Date(Date.now() + 7 * 3600_000)
  return new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth() - i, 1)).toISOString().slice(0, 7)
})

/** Tải toàn bộ giao dịch khớp bộ lọc (tối đa CSV_MAX) và xuất CSV UTF-8 có BOM để Excel đọc đúng tiếng Việt. */
async function exportCsv(filter: Omit<TxQuery, 'page' | 'limit'>) {
  const rows: Transaction[] = []
  for (let page = 1; rows.length < CSV_MAX; page++) {
    const r = await api.transactions({ ...filter, page, limit: 200 })
    rows.push(...r.items)
    if (rows.length >= r.total || r.items.length === 0) break
  }
  const esc = (v: string | number) => `"${String(v).replace(/"/g, '""')}"`
  const lines = [
    ['Ngày', 'Giờ', 'Người dùng', 'Email', 'Nội dung', 'Ghi chú', 'Danh mục', 'Loại', 'Ví', 'Số tiền'],
    ...rows.map((t) => [
      formatDate(t.occurredAt), formatTime(t.occurredAt), t.user.name, t.user.email, t.title, t.note ?? '', t.category.name,
      TYPE_LABEL[t.type], t.wallet.name, t.type === 'INCOME' ? t.amount : -t.amount,
    ]),
  ]
  const blob = new Blob(['﻿' + lines.map((l) => l.map(esc).join(',')).join('\r\n')], { type: 'text/csv;charset=utf-8' })
  const a = document.createElement('a')
  a.href = URL.createObjectURL(blob)
  a.download = `giao-dich${filter.month ? `-${filter.month}` : ''}.csv`
  a.click()
  URL.revokeObjectURL(a.href)
  return rows.length
}

export default function TransactionsPage() {
  const { values, page, set } = useUrlFilters(['userId', 'walletId', 'type', 'month', 'q'] as const)
  const [search, setSearch] = useState(values.q)
  const [exporting, setExporting] = useState(false)
  const debounced = useDebounced(search)
  useEffect(() => {
    if (debounced.trim() !== values.q) set({ q: debounced.trim() })
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [debounced])

  const users = useQuery({ queryKey: ['users', 'all'], queryFn: () => api.users({ limit: 200 }) })
  const user = useQuery({ queryKey: ['user', values.userId], queryFn: () => api.user(values.userId), enabled: !!values.userId })
  const overview = useQuery({ queryKey: ['overview'], queryFn: api.overview })
  const filter = {
    userId: values.userId || undefined,
    walletId: (values.userId && values.walletId) || undefined,
    type: (values.type || undefined) as TxType | undefined,
    month: values.month || undefined,
    q: values.q || undefined,
  }
  const query = { ...filter, page, limit: LIMIT }
  const { data, isPending, isFetching, error, refetch } = useQuery({
    queryKey: ['transactions', query],
    queryFn: () => api.transactions(query),
    placeholderData: keepPreviousData,
  })

  const hasFilter = !!(filter.userId || filter.type || filter.month || filter.q)
  const userName = user.data?.name ?? users.data?.items.find((u) => u.id === values.userId)?.name
  const walletName = user.data?.wallets.find((w) => w.id === filter.walletId)?.name
  const clear = () => {
    setSearch('')
    set({ userId: '', walletId: '', type: '', month: '', q: '' })
  }

  // Thu/chi của tháng đang lọc lấy từ xu hướng 6 tháng (hệ thống hoặc của người dùng đang chọn)
  const trend = filter.userId ? user.data?.trend : overview.data?.trend
  const monthSum = filter.month && !filter.walletId && !filter.type && !filter.q ? trend?.find((t) => t.month === filter.month) : undefined
  const subtitle = data && (
    <>
      {formatNumber(data.total)} giao dịch {filter.month && !hasFilterExceptMonth(filter) ? `trong ${formatMonthLong(filter.month).toLowerCase()}` : hasFilter ? 'khớp bộ lọc' : 'trên toàn hệ thống'}
      {monthSum && (
        <> · thu <span className="font-semibold text-income">{formatVND(monthSum.income)}</span> · chi <span className="font-semibold text-foreground">{formatVND(monthSum.expense)}</span></>
      )}
    </>
  )

  const emptyText = () => {
    const parts = [
      filter.type && `loại ${TYPE_LABEL[filter.type].toLowerCase()}`,
      filter.walletId && walletName && `trong ví ${walletName}`,
      filter.q && `chứa “${filter.q}”`,
      filter.month && `trong ${formatMonthLong(filter.month).toLowerCase()}`,
    ].filter(Boolean)
    return `${userName ?? 'Hệ thống'} không có giao dịch nào ${parts.join(' ')}. Thử bỏ bớt bộ lọc hoặc chọn tháng khác.`
  }

  return (
    <>
      <PageHeader
        title="Giao dịch"
        description={subtitle}
        actions={
          <Button
            variant="secondary"
            disabled={exporting || !data?.total}
            data-testid="export-csv"
            onClick={async () => {
              setExporting(true)
              try {
                const n = await exportCsv(filter)
                notify.success(`Đã xuất ${formatNumber(n)} giao dịch`, { description: n >= CSV_MAX ? `Chỉ xuất ${formatNumber(CSV_MAX)} dòng đầu, hãy lọc hẹp hơn.` : 'File CSV đã được tải xuống.', icon: <Download /> })
              } catch (e) {
                notify.error('Không xuất được CSV', e instanceof Error ? e.message : undefined)
              } finally {
                setExporting(false)
              }
            }}
          >
            <Download /> Xuất CSV
          </Button>
        }
      />

      <div className="flex flex-wrap items-center gap-2.5 xl:flex-nowrap">
        <Input
          wrapperClassName="w-[200px] shrink-0 xl:w-[272px]"
          icon={<Search />}
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          placeholder="Tìm theo nội dung, ghi chú"
          aria-label="Tìm giao dịch"
          data-testid="tx-search"
        />
        <div className="relative w-[190px] shrink-0 xl:w-[222px]">
          <Select value={values.userId || 'all'} onValueChange={(v) => set({ userId: v, walletId: '' })}>
            <SelectTrigger
              label={values.userId ? undefined : 'Người dùng'}
              icon={values.userId && userName ? <UserBubble name={userName} size="xs" /> : undefined}
              className={cn('w-full', values.userId && 'pl-1.5 [&>svg:last-child]:invisible')}
              data-testid="filter-user"
            >
              {values.userId ? userName ?? '…' : 'Tất cả'}
            </SelectTrigger>
            <SelectContent className="max-h-80">
              <SelectItem value="all">Tất cả người dùng</SelectItem>
              {users.data?.items.map((u) => (
                <SelectItem key={u.id} value={u.id}>
                  <span className="flex min-w-0 flex-col">
                    <span className="truncate">{u.name}</span>
                    <span className="truncate text-xs font-normal text-muted-foreground">{u.email}</span>
                  </span>
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
          {values.userId && (
            <button
              type="button"
              aria-label="Bỏ lọc người dùng"
              onClick={() => set({ userId: '', walletId: '' })}
              className="absolute top-1/2 right-2 flex size-7 -translate-y-1/2 cursor-pointer items-center justify-center rounded-full text-muted-foreground hover:bg-muted hover:text-foreground"
            >
              <X className="size-4" />
            </button>
          )}
        </div>
        <Select value={filter.walletId || 'all'} onValueChange={(v) => set({ walletId: v })} disabled={!values.userId}>
          <SelectTrigger label="Ví" className="w-[130px] shrink-0 xl:w-[150px]" data-testid="filter-wallet" title={values.userId ? undefined : 'Chọn người dùng trước'}>
            {walletName ?? 'Tất cả'}
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="all">Tất cả ví</SelectItem>
            {user.data?.wallets.map((w) => (
              <SelectItem key={w.id} value={w.id}>{w.name}{w.isArchived && <span className="text-xs font-normal text-muted-foreground">Đã lưu trữ</span>}</SelectItem>
            ))}
          </SelectContent>
        </Select>
        <Select value={values.month || 'all'} onValueChange={(v) => set({ month: v })}>
          <SelectTrigger icon={<Calendar />} className="w-[160px] shrink-0 xl:w-[176px]" aria-label="Tháng" data-testid="filter-month">
            {values.month ? formatMonthLong(values.month) : 'Mọi thời gian'}
          </SelectTrigger>
          <SelectContent className="max-h-80">
            <SelectItem value="all">Mọi thời gian</SelectItem>
            {MONTHS.map((m) => <SelectItem key={m} value={m}>{formatMonthLong(m)}</SelectItem>)}
          </SelectContent>
        </Select>
        <Tabs value={values.type || 'all'} onValueChange={(v) => set({ type: v })} className="ml-auto">
          <TabsList aria-label="Loại giao dịch" data-testid="filter-type">
            <TabsTrigger value="all">Tất cả</TabsTrigger>
            <TabsTrigger value="EXPENSE">Chi</TabsTrigger>
            <TabsTrigger value="INCOME">Thu</TabsTrigger>
          </TabsList>
        </Tabs>
      </div>

      <Card flush className={cn(data?.items.length === 0 && 'flex flex-1 items-center justify-center')}>
        {error ? (
          <ErrorState error={error} onRetry={refetch} />
        ) : isPending ? (
          <TableSkeleton rows={10} />
        ) : data.items.length === 0 ? (
          hasFilter
            ? <EmptyState title="Không có giao dịch nào khớp bộ lọc" description={emptyText()} action={{ label: 'Xóa bộ lọc', onClick: clear }} />
            : <EmptyState title="Chưa có giao dịch nào" description="Giao dịch người dùng ghi trong app sẽ hiện ở đây." />
        ) : (
          <div className={isFetching ? 'opacity-60 transition-opacity' : 'transition-opacity'}>
            <Table>
              <colgroup>
                <col className="w-[76px] xl:w-[96px]" />
                <col className="w-[180px] xl:w-[270px]" />
                <col />
                <col className="w-[140px] xl:w-[178px]" />
                <col className="w-[104px] xl:w-[140px]" />
                <col className="w-[140px] xl:w-[150px]" />
              </colgroup>
              <TableHeader>
                <TableRow>
                  <TableHead>Thời gian</TableHead>
                  <TableHead>Người dùng</TableHead>
                  <TableHead>Nội dung</TableHead>
                  <TableHead>Danh mục</TableHead>
                  <TableHead>Ví</TableHead>
                  <TableHead className="text-right">Số tiền</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {data.items.map((t) => (
                  <TableRow key={t.id} data-testid="tx-row">
                    <TableCell className="tabular-nums">
                      <p>{formatDayMonth(t.occurredAt)}</p>
                      <p className="text-body-s text-muted-foreground">{formatTime(t.occurredAt)}</p>
                    </TableCell>
                    <TableCell>
                      <Link to={`/users/${t.user.id}`} className="group/u flex min-w-0 items-center gap-3">
                        <UserBubble name={t.user.name} size="sm" />
                        <div className="min-w-0">
                          <p className="truncate group-hover/u:underline" data-testid="tx-user">{t.user.name}</p>
                          <p className="truncate text-body-s text-muted-foreground">{t.user.email}</p>
                        </div>
                      </Link>
                    </TableCell>
                    <TableCell>
                      <p className="truncate font-medium" data-testid="tx-title">{t.title}</p>
                      {t.note && <p className="truncate text-body-s text-muted-foreground">{t.note}</p>}
                    </TableCell>
                    <TableCell><CategoryChip name={t.category.name} icon={t.category.icon} /></TableCell>
                    <TableCell className="text-muted-foreground" data-testid="tx-wallet">{t.wallet.name}</TableCell>
                    <TableCell className="pr-4 text-right">
                      <span className={cn('text-body-l font-semibold tabular-nums', t.type === 'INCOME' && 'text-income')} data-testid="tx-amount">
                        {formatSigned(t.amount, t.type === 'INCOME')}
                      </span>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </div>
        )}
        {data && data.total > 0 && <Pagination page={page} limit={LIMIT} total={data.total} onChange={(p) => set({ page: p })} />}
      </Card>
    </>
  )
}

function hasFilterExceptMonth(f: { userId?: string; type?: string; q?: string }) {
  return !!(f.userId || f.type || f.q)
}
