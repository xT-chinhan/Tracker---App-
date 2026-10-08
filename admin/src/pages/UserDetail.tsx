import { Link, useParams } from 'react-router'
import { keepPreviousData, useQuery } from '@tanstack/react-query'
import { ArrowLeft, Lock, ShieldCheck, ShieldOff, Unlock } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Skeleton } from '@/components/ui/skeleton'
import { EmptyState, ErrorState, Pagination, RoleBadge, StatusBadge, TableSkeleton, UserAvatar } from '@/components/common'
import { TransactionsTable } from '@/components/TransactionsTable'
import { TrendChart } from '@/components/TrendChart'
import { useUserActions } from '@/components/useUserActions'
import { api, auth } from '@/lib/api'
import { formatDateTime, formatNumber, formatVND } from '@/lib/format'
import { cn, useUrlFilters } from '@/lib/utils'

const LIMIT = 10

export default function UserDetailPage() {
  const { id = '' } = useParams()
  const { page, set } = useUrlFilters([] as const)
  const user = useQuery({ queryKey: ['user', id], queryFn: () => api.user(id) })
  const txQuery = { userId: id, page, limit: LIMIT }
  const txs = useQuery({
    queryKey: ['transactions', txQuery],
    queryFn: () => api.transactions(txQuery),
    placeholderData: keepPreviousData,
  })
  const { toggleLock, toggleRole, dialog, pending } = useUserActions()

  const back = (
    <Button variant="ghost" size="sm" asChild className="mb-4 -ml-2 text-muted-foreground">
      <Link to="/users"><ArrowLeft /> Danh sách người dùng</Link>
    </Button>
  )

  if (user.error) return <>{back}<Card><ErrorState error={user.error} onRetry={user.refetch} /></Card></>
  if (user.isPending) {
    return (
      <>
        {back}
        <div className="space-y-4" data-testid="loading">
          <Skeleton className="h-28 rounded-xl" />
          <div className="grid gap-4 md:grid-cols-4">{Array.from({ length: 4 }, (_, i) => <Skeleton key={i} className="h-24 rounded-xl" />)}</div>
          <Skeleton className="h-80 rounded-xl" />
        </div>
      </>
    )
  }

  const u = user.data
  const isMe = u.id === auth.user()?.id
  const f = u.finance
  const money = [
    { label: 'Số dư hiện tại', value: f.balance, testId: 'fin-balance', className: f.balance < 0 ? 'text-rose-700' : '' },
    { label: 'Tổng thu', value: f.totalIncome, testId: 'fin-income', className: 'text-teal-700' },
    { label: 'Tổng chi', value: f.totalExpense, testId: 'fin-expense', className: 'text-rose-700' },
    { label: 'Đang tiết kiệm', value: f.savings, testId: 'fin-savings', className: 'text-blue-700' },
  ]
  const counts = [
    { label: 'Giao dịch', value: u._count.transactions, testId: 'count-transactions' },
    { label: 'Danh mục riêng', value: u._count.categories, testId: 'count-categories' },
    { label: 'Ngân sách', value: u._count.budgets, testId: 'count-budgets' },
    { label: 'Mục tiêu tiết kiệm', value: u._count.savingGoals, testId: 'count-goals' },
  ]

  return (
    <>
      {back}
      <Card className="mb-6">
        <CardContent className="flex flex-wrap items-center gap-4">
          <UserAvatar name={u.name} className="size-14 text-lg" />
          <div className="min-w-0 flex-1">
            <div className="flex flex-wrap items-center gap-2">
              <h1 className="truncate text-xl font-semibold" data-testid="detail-name">{u.name}</h1>
              {isMe && <span className="text-sm text-muted-foreground">(bạn)</span>}
              <RoleBadge role={u.role} />
              <StatusBadge status={u.status} />
            </div>
            <p className="truncate text-sm text-muted-foreground" data-testid="detail-email">{u.email}</p>
            <p className="mt-1 text-xs text-muted-foreground">
              Tham gia {formatDateTime(u.createdAt)} · Cập nhật {formatDateTime(u.updatedAt)}
            </p>
          </div>
          <div className="flex flex-wrap gap-2">
            <Button variant="outline" disabled={pending} onClick={() => toggleRole(u)} data-testid="detail-role-btn">
              {u.role === 'USER' ? <><ShieldCheck /> Cấp quyền quản trị</> : <><ShieldOff /> Hạ quyền</>}
            </Button>
            <Button
              variant={u.status === 'ACTIVE' ? 'destructive' : 'outline'}
              disabled={pending}
              onClick={() => toggleLock(u)}
              data-testid="detail-lock-btn"
            >
              {u.status === 'ACTIVE' ? <><Lock /> Khóa tài khoản</> : <><Unlock /> Mở khóa</>}
            </Button>
          </div>
        </CardContent>
      </Card>

      <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
        {money.map((m) => (
          <Card key={m.label} className="gap-1 px-5 py-4">
            <p className="text-sm text-muted-foreground">{m.label}</p>
            <p className={cn('truncate text-xl font-semibold tabular-nums', m.className)} data-testid={m.testId}>{formatVND(m.value)}</p>
          </Card>
        ))}
      </div>

      <div className="mt-6 grid gap-6 xl:grid-cols-3">
        <Card className="xl:col-span-2">
          <CardHeader>
            <CardTitle>Thu và chi 6 tháng gần nhất</CardTitle>
          </CardHeader>
          <CardContent><TrendChart data={u.trend} height={260} /></CardContent>
        </Card>
        <Card>
          <CardHeader>
            <CardTitle>Dữ liệu của người dùng</CardTitle>
            <CardDescription>Số bản ghi đang lưu</CardDescription>
          </CardHeader>
          <CardContent className="divide-y">
            {counts.map((c) => (
              <div key={c.label} className="flex items-center justify-between py-3 text-sm first:pt-0 last:pb-0">
                <span className="text-muted-foreground">{c.label}</span>
                <span className="font-semibold tabular-nums" data-testid={c.testId}>{formatNumber(c.value)}</span>
              </div>
            ))}
          </CardContent>
        </Card>
      </div>

      <Card className="mt-6 gap-0 py-0">
        <CardHeader className="border-b py-4">
          <CardTitle>Giao dịch của {u.name}</CardTitle>
        </CardHeader>
        {txs.error ? (
          <ErrorState error={txs.error} onRetry={txs.refetch} />
        ) : txs.isPending ? (
          <TableSkeleton />
        ) : txs.data.items.length === 0 ? (
          <EmptyState title="Chưa có giao dịch" />
        ) : (
          <>
            <TransactionsTable items={txs.data.items} showUser={false} />
            <Pagination page={page} limit={LIMIT} total={txs.data.total} onChange={(p) => set({ page: p })} />
          </>
        )}
      </Card>
      {dialog}
    </>
  )
}
