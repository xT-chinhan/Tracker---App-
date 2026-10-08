import { useState, type ReactNode } from 'react'
import { Link } from 'react-router'
import { useQuery, useQueryClient } from '@tanstack/react-query'
import { ArrowLeftRight, BarChart3, ChevronRight, RefreshCw, Table2, Users } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Card, CardHeader } from '@/components/ui/card'
import { Skeleton } from '@/components/ui/skeleton'
import { ErrorState, PageHeader, UserBubble } from '@/components/common'
import { ChartLegend, TrendChart, TrendTable } from '@/components/TrendChart'
import { api, type GoalStatus } from '@/lib/api'
import {
  currentMonth, formatMonthLong, formatNumber, formatShortWhen, formatSigned, formatTime, formatVND, formatWeekdayDate, GOAL_STATUS_LABEL,
  todayDayMonth,
} from '@/lib/format'

const GOAL_ORDER: GoalStatus[] = ['ACTIVE', 'COMPLETED', 'WITHDRAWN', 'EARLY_WITHDRAWN']

function Kpi({ label, icon, value, testId, meta, className }: {
  label: ReactNode
  icon: ReactNode
  value: string
  testId: string
  meta: { label: string; value: ReactNode; testId: string; className?: string }[]
  className?: string
}) {
  return (
    <Card className={className}>
      <p className="flex items-center gap-2 text-body-s font-medium text-muted-foreground [&_svg]:size-4">{icon}{label}</p>
      <p className="mt-2.5 truncate text-display tabular-nums" data-testid={testId}>{value}</p>
      <div className="mt-[18px] flex gap-5 border-t border-line pt-4">
        {meta.map((m) => (
          <div key={m.label} className="not-first:border-l not-first:border-line not-first:pl-5">
            <p className="text-body-s font-medium text-muted-foreground">{m.label}</p>
            <p className={`mt-0.5 text-title-m leading-[1.35] whitespace-nowrap tabular-nums ${m.className ?? ''}`} data-testid={m.testId}>{m.value}</p>
          </div>
        ))}
      </div>
    </Card>
  )
}

/** Skeleton đúng bố cục Tổng quan (mockup 11), không spinner. */
function OverviewSkeleton() {
  const kpi = (w: number[], cls: string) => (
    <Card className={cls}>
      <Skeleton className="h-3" style={{ width: w[0] }} />
      <Skeleton className="mt-3.5 h-8" style={{ width: w[1] }} />
      <div className="mt-[22px] flex gap-5 border-t border-line pt-4">{w.slice(2).map((x, i) => <Skeleton key={i} className="h-[30px]" style={{ width: x }} />)}</div>
    </Card>
  )
  return (
    <div className="contents" data-testid="loading" aria-busy="true">
      <div className="grid grid-cols-12 gap-5">
        {kpi([90, 130, 70, 70, 70], 'col-span-6 xl:col-span-4')}
        {kpi([80, 150, 80, 80], 'col-span-6 xl:col-span-3')}
        {kpi([160, 280, 150, 150], 'col-span-12 xl:col-span-5')}
      </div>
      <div className="grid min-h-[540px] flex-1 grid-cols-12 gap-5">
        <Card className="col-span-8 flex flex-col">
          <Skeleton className="h-4 w-[130px]" />
          <Skeleton className="mt-2.5 h-3 w-[260px]" />
          <div className="flex flex-1 items-end border-b border-line px-2 pt-6 pb-0 pl-12">
            {[62, 48, 66, 52, 70, 58, 74, 56, 78, 60, 56, 40].map((h, i) => (
              <div key={i} className={`flex flex-1 px-px ${i % 2 ? 'justify-start' : 'justify-end'}`}>
                <Skeleton className="w-[26px] rounded-t-[4px] rounded-b-none" style={{ height: h * 3.4 }} />
              </div>
            ))}
          </div>
        </Card>
        <div className="col-span-4 flex flex-col gap-5">
          <Card>
            <Skeleton className="h-4 w-[140px]" />
            {[80, 60, 45, 30].map((w, i) => (
              <div key={i} className={i ? 'border-t border-line py-3' : 'mt-1.5 py-3'}>
                <div className="flex justify-between"><Skeleton className="h-3" style={{ width: w + 40 }} /><Skeleton className="h-3 w-11" /></div>
                <Skeleton className="mt-2.5 h-1.5 w-full rounded-full" />
              </div>
            ))}
          </Card>
          <Card className="flex-1">
            <Skeleton className="h-4 w-[130px]" />
            {[0, 1, 2].map((i) => (
              <div key={i} className="flex min-h-[58px] items-center gap-3 not-first:border-t not-first:border-line">
                <Skeleton className="size-8 rounded-full" />
                <div className="flex-1"><Skeleton className="h-3" style={{ width: 120 - i * 14 }} /><Skeleton className="mt-2 h-2.5" style={{ width: 170 - i * 20 }} /></div>
                <Skeleton className="h-2.5 w-14" />
              </div>
            ))}
          </Card>
        </div>
      </div>
    </div>
  )
}

export default function OverviewPage() {
  const qc = useQueryClient()
  const month = currentMonth()
  const [asTable, setAsTable] = useState(false)
  const overview = useQuery({ queryKey: ['overview'], queryFn: api.overview })
  const monthTx = useQuery({ queryKey: ['transactions', { month, limit: 1 }], queryFn: () => api.transactions({ month, limit: 1 }) })
  const recent = useQuery({ queryKey: ['users', { limit: 3 }], queryFn: () => api.users({ limit: 3 }) })
  const { data, error, refetch, isFetching, dataUpdatedAt } = overview

  const refresh = () => {
    qc.invalidateQueries({ queryKey: ['overview'] })
    qc.invalidateQueries({ queryKey: ['transactions'] })
    qc.invalidateQueries({ queryKey: ['users'] })
  }
  const header = (
    <PageHeader
      title="Tổng quan"
      description={data ? `Toàn hệ thống · cập nhật ${formatTime(dataUpdatedAt)}, ${formatWeekdayDate(dataUpdatedAt)}` : <Skeleton className="mt-2.5 h-3.5 w-[300px]" />}
      actions={<Button variant="secondary" onClick={refresh} disabled={isFetching} data-testid="refresh"><RefreshCw /> Làm mới</Button>}
    />
  )

  if (error) return <>{header}<Card><ErrorState error={error} onRetry={refetch} /></Card></>
  if (!data) return <>{header}<OverviewSkeleton /></>

  const goalsTotal = GOAL_ORDER.reduce((s, k) => s + (data.savingGoals[k] ?? 0), 0)
  const goalsMax = Math.max(1, ...GOAL_ORDER.map((k) => data.savingGoals[k] ?? 0))
  const net = data.transactions.totalIncome - data.transactions.totalExpense
  const monthNo = Number(month.slice(5))

  return (
    <>
      {header}
      <div className="grid grid-cols-12 gap-5">
        <Kpi
          className="col-span-6 xl:col-span-4"
          icon={<Users />}
          label="Người dùng"
          value={formatNumber(data.users.total)}
          testId="stat-users-total"
          meta={[
            { label: 'Hoạt động', value: formatNumber(data.users.active), testId: 'stat-users-active' },
            { label: 'Đã khóa', value: formatNumber(data.users.locked), testId: 'stat-users-locked' },
            { label: 'Mới 30 ngày', value: `+${formatNumber(data.users.new30d)}`, testId: 'stat-users-new' },
          ]}
        />
        <Kpi
          className="col-span-6 xl:col-span-3"
          icon={<ArrowLeftRight />}
          label="Giao dịch"
          value={formatNumber(data.transactions.total)}
          testId="stat-tx-total"
          meta={[
            { label: 'Mới 30 ngày', value: formatNumber(data.transactions.new30d), testId: 'stat-tx-new' },
            { label: `Tháng ${monthNo}`, value: monthTx.data ? formatNumber(monthTx.data.total) : '…', testId: 'stat-tx-month' },
          ]}
        />
        <Kpi
          className="col-span-12 xl:col-span-5"
          icon={<span className="size-[7px] rounded-full bg-income" />}
          label="Tổng thu · toàn thời gian"
          value={formatVND(data.transactions.totalIncome)}
          testId="stat-income"
          meta={[
            { label: 'Tổng chi', value: formatSigned(data.transactions.totalExpense, false), testId: 'stat-expense' },
            { label: 'Chênh lệch', value: formatSigned(net, net >= 0), testId: 'stat-net', className: net >= 0 ? 'text-income' : '' },
          ]}
        />
      </div>

      <div className="grid min-h-[540px] flex-1 grid-cols-12 gap-5">
        <Card className="col-span-8 flex flex-col">
          <CardHeader
            title="Thu chi 6 tháng"
            sub={`Tổng của mọi người dùng. ${formatMonthLong(month)} tính đến ${todayDayMonth()}.`}
            aside={
              <div className="flex items-center gap-4">
                {!asTable && <ChartLegend />}
                <Button variant="link" className="font-medium text-muted-foreground" onClick={() => setAsTable((v) => !v)} data-testid="toggle-table">
                  {asTable ? <><BarChart3 /> Xem biểu đồ</> : <><Table2 /> Xem dạng bảng</>}
                </Button>
              </div>
            }
          />
          {asTable ? <TrendTable data={data.trend} /> : <TrendChart data={data.trend} className="mt-[18px] min-h-[340px] flex-1" />}
        </Card>

        <div className="col-span-4 flex flex-col gap-5">
          <Card>
            <CardHeader title="Mục tiêu tiết kiệm" aside={<span className="text-body-s font-medium text-muted-foreground tabular-nums"><span data-testid="goals-total">{formatNumber(goalsTotal)}</span> mục tiêu</span>} />
            <div className="mt-1.5">
              {GOAL_ORDER.map((s) => {
                const count = data.savingGoals[s] ?? 0
                return (
                  <div key={s} className="grid grid-cols-[1fr_auto] gap-y-1.5 py-[9px] not-first:border-t not-first:border-line" data-testid={`goal-${s}`}>
                    <span className="font-medium">{GOAL_STATUS_LABEL[s]}</span>
                    <span className="text-right font-semibold tabular-nums">
                      <span data-testid="goal-count">{formatNumber(count)}</span>
                      <span className="ml-1.5 font-medium text-faint">{goalsTotal ? Math.round((count / goalsTotal) * 100) : 0}%</span>
                    </span>
                    <div className="col-span-2 h-1.5 overflow-hidden rounded-full bg-muted">
                      <div className="h-full rounded-full bg-primary" style={{ width: `${(count / goalsMax) * 100}%` }} />
                    </div>
                  </div>
                )
              })}
            </div>
          </Card>
          <Card className="flex-1 pb-2">
            <CardHeader title="Đăng ký gần đây" aside={<Link to="/users" className="inline-flex items-center gap-1 text-[13.5px] font-semibold hover:underline">Tất cả<ChevronRight className="size-4" /></Link>} />
            <div className="mt-1.5" data-testid="recent-signups">
              {recent.data?.items.map((u) => (
                <Link key={u.id} to={`/users/${u.id}`} className="flex min-h-[58px] items-center gap-3 not-first:border-t not-first:border-line">
                  <UserBubble name={u.name} size="sm" />
                  <div className="min-w-0 flex-1">
                    <p className="truncate text-body-l font-medium">{u.name}</p>
                    <p className="truncate text-body-s text-muted-foreground">{u.email}</p>
                  </div>
                  <span className="text-body-s text-muted-foreground tabular-nums">{formatShortWhen(u.createdAt)}</span>
                </Link>
              ))}
            </div>
          </Card>
        </div>
      </div>
    </>
  )
}
