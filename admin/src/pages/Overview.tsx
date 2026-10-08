import { useQuery } from '@tanstack/react-query'
import { ArrowDownLeft, ArrowLeftRight, ArrowUpRight, Lock, UserCheck, UserPlus, Users, Zap } from 'lucide-react'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Skeleton } from '@/components/ui/skeleton'
import { ErrorState, PageHeader, StatCard } from '@/components/common'
import { TrendChart } from '@/components/TrendChart'
import { api, type GoalStatus } from '@/lib/api'
import { formatNumber, formatVND, GOAL_COLORS, GOAL_STATUS_LABEL } from '@/lib/format'

const GOAL_ORDER: GoalStatus[] = ['ACTIVE', 'COMPLETED', 'WITHDRAWN', 'EARLY_WITHDRAWN']

export default function OverviewPage() {
  const { data, isPending, error, refetch } = useQuery({ queryKey: ['overview'], queryFn: api.overview })

  if (error) return <><PageHeader title="Tổng quan" /><Card><ErrorState error={error} onRetry={refetch} /></Card></>

  const goalsTotal = data ? GOAL_ORDER.reduce((s, k) => s + (data.savingGoals[k] ?? 0), 0) : 0
  const net = data ? data.transactions.totalIncome - data.transactions.totalExpense : 0

  return (
    <>
      <PageHeader title="Tổng quan" description="Số liệu toàn hệ thống, cập nhật theo thời gian thực" />
      {isPending ? (
        <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4" data-testid="loading">
          {Array.from({ length: 8 }, (_, i) => <Skeleton key={i} className="h-26 rounded-xl" />)}
        </div>
      ) : (
        <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
          <StatCard label="Tổng người dùng" value={formatNumber(data.users.total)} icon={<Users />} testId="stat-users-total" />
          <StatCard label="Đang hoạt động" value={formatNumber(data.users.active)} icon={<UserCheck />} tone="income" testId="stat-users-active" />
          <StatCard label="Bị khóa" value={formatNumber(data.users.locked)} icon={<Lock />} tone="expense" testId="stat-users-locked" />
          <StatCard label="Người dùng mới" value={formatNumber(data.users.new30d)} hint="Trong 30 ngày qua" icon={<UserPlus />} tone="warning" testId="stat-users-new" />
          <StatCard label="Tổng giao dịch" value={formatNumber(data.transactions.total)} icon={<ArrowLeftRight />} testId="stat-tx-total" />
          <StatCard label="Giao dịch mới" value={formatNumber(data.transactions.new30d)} hint="Được ghi trong 30 ngày qua" icon={<Zap />} tone="warning" testId="stat-tx-new" />
          <StatCard label="Tổng thu" value={formatVND(data.transactions.totalIncome)} icon={<ArrowDownLeft />} tone="income" testId="stat-income" />
          <StatCard
            label="Tổng chi"
            value={formatVND(data.transactions.totalExpense)}
            hint={<>Chênh lệch thu − chi: <span className="font-medium text-foreground" data-testid="stat-net">{formatVND(net)}</span></>}
            icon={<ArrowUpRight />}
            tone="expense"
            testId="stat-expense"
          />
        </div>
      )}

      <div className="mt-6 grid gap-6 xl:grid-cols-3">
        <Card className="xl:col-span-2">
          <CardHeader>
            <CardTitle>Thu và chi 6 tháng gần nhất</CardTitle>
            <CardDescription>Tổng của tất cả người dùng theo tháng (giờ Việt Nam)</CardDescription>
          </CardHeader>
          <CardContent>{isPending ? <Skeleton className="h-70" /> : <TrendChart data={data.trend} />}</CardContent>
        </Card>
        <Card>
          <CardHeader>
            <CardTitle>Mục tiêu tiết kiệm</CardTitle>
            <CardDescription>
              {isPending ? 'Đang tải…' : <>Tổng cộng <span data-testid="goals-total">{formatNumber(goalsTotal)}</span> mục tiêu</>}
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            {isPending
              ? Array.from({ length: 4 }, (_, i) => <Skeleton key={i} className="h-9" />)
              : GOAL_ORDER.map((s) => {
                  const count = data.savingGoals[s] ?? 0
                  const pct = goalsTotal ? (count / goalsTotal) * 100 : 0
                  return (
                    <div key={s} data-testid={`goal-${s}`}>
                      <div className="mb-1.5 flex items-center justify-between text-sm">
                        <span className="flex items-center gap-2">
                          <span className="size-2.5 rounded-full" style={{ backgroundColor: GOAL_COLORS[s] }} />
                          {GOAL_STATUS_LABEL[s]}
                        </span>
                        <span className="tabular-nums">
                          <span className="font-semibold" data-testid="goal-count">{formatNumber(count)}</span>
                          <span className="ml-1.5 text-muted-foreground">({Math.round(pct)}%)</span>
                        </span>
                      </div>
                      <div className="h-2 overflow-hidden rounded-full bg-muted">
                        <div className="h-full rounded-full transition-all" style={{ width: `${pct}%`, backgroundColor: GOAL_COLORS[s] }} />
                      </div>
                    </div>
                  )
                })}
          </CardContent>
        </Card>
      </div>
    </>
  )
}
