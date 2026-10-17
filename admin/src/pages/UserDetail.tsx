import { Link, useParams } from 'react-router'
import { useQuery } from '@tanstack/react-query'
import { ChevronLeft, ChevronRight, Lock, LockOpen, ShieldCheck, ShieldOff, Sparkles, Tag } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Card, CardHeader } from '@/components/ui/card'
import { Skeleton } from '@/components/ui/skeleton'
import { Bubble, CATEGORY_ICONS, WALLET_ICONS } from '@/components/CategoryIcon'
import { ErrorState, StatusBadge, UserBubble } from '@/components/common'
import { ChartLegend, TrendChart } from '@/components/TrendChart'
import { useUserActions } from '@/components/useUserActions'
import { api, auth, type Transaction, type Wallet } from '@/lib/api'
import {
  formatDate, formatDayMonth, formatNumber, formatSigned, formatTime, formatVND, isToday, ROLE_LABEL, WALLET_TYPE_LABEL,
} from '@/lib/format'
import { cn } from '@/lib/utils'

const crumb = (
  <Link to="/users" className="mb-2 inline-flex items-center gap-1 text-[13.5px] font-medium text-muted-foreground hover:text-foreground">
    <ChevronLeft className="size-4" />Người dùng
  </Link>
)

function Figure({ label, value, testId, className }: { label: string; value: string; testId: string; className?: string }) {
  return (
    <div className="min-w-0 flex-1 border-l border-line pl-4">
      <p className="text-body-s font-medium text-muted-foreground">{label}</p>
      <p className={cn('mt-2 text-title-m whitespace-nowrap tabular-nums', className)} data-testid={testId}>{value}</p>
    </div>
  )
}

function WalletRow({ w }: { w: Wallet }) {
  const Icon = WALLET_ICONS[w.type]
  return (
    <div className={cn('flex min-h-[58px] items-center gap-3 border-line not-first:border-t', w.isArchived && 'opacity-55')} data-testid="wallet-row" data-name={w.name}>
      <Bubble><Icon /></Bubble>
      <div className="min-w-0 flex-1">
        <p className="truncate text-body-l font-medium">{w.name}</p>
        <p className="truncate text-body-s text-muted-foreground">{WALLET_TYPE_LABEL[w.type]}{w.isArchived && ' · Đã lưu trữ'}</p>
      </div>
      <span className={cn('text-body-l font-semibold tabular-nums', w.balance < 0 && 'text-destructive')} data-testid="wallet-balance">{formatVND(w.balance)}</span>
    </div>
  )
}

function TxRow({ t }: { t: Transaction }) {
  const Icon = CATEGORY_ICONS[t.category.icon] ?? Tag
  const income = t.type === 'INCOME'
  return (
    <div className="flex min-h-[58px] items-center gap-3 border-line not-first:border-t" data-testid="tx-row">
      <Bubble><Icon /></Bubble>
      <div className="min-w-0 flex-1">
        <p className="truncate text-body-l font-medium" data-testid="tx-title">{t.title}</p>
        <p className="truncate text-body-s text-muted-foreground">{t.category.name} · {t.wallet.name}</p>
      </div>
      <div className="shrink-0 text-right">
        <p className={cn('text-body-l font-semibold tabular-nums', income && 'text-income')} data-testid="tx-amount">{formatSigned(t.amount, income)}</p>
        <p className="text-body-s text-muted-foreground tabular-nums">{formatDayMonth(t.occurredAt)} · {formatTime(t.occurredAt)}</p>
      </div>
    </div>
  )
}

function DetailSkeleton() {
  return (
    <div className="grid grid-cols-12 items-start gap-5" data-testid="loading" aria-busy="true">
      <div className="col-span-8 flex flex-col gap-5">
        <Card><Skeleton className="h-3 w-24" /><Skeleton className="mt-3 h-8 w-56" /><Skeleton className="mt-10 h-[214px] w-full" /></Card>
        <Card className="h-72"><Skeleton className="h-4 w-36" /></Card>
      </div>
      <div className="col-span-4 flex flex-col gap-5">
        <Card className="h-64"><Skeleton className="h-4 w-16" /></Card>
        <Card className="h-64"><Skeleton className="h-4 w-20" /></Card>
      </div>
    </div>
  )
}

export default function UserDetailPage() {
  const { id = '' } = useParams()
  const user = useQuery({ queryKey: ['user', id], queryFn: () => api.user(id) })
  const recentQuery = { userId: id, limit: 4 }
  const recent = useQuery({ queryKey: ['transactions', recentQuery], queryFn: () => api.transactions(recentQuery) })
  const { toggleLock, toggleRole, dialog, pending } = useUserActions()

  if (user.error) return <>{crumb}<Card><ErrorState error={user.error} onRetry={user.refetch} /></Card></>
  if (user.isPending) {
    return (
      <>
        <div>{crumb}<div className="flex items-center gap-4"><Skeleton className="size-14 rounded-full" /><div><Skeleton className="h-7 w-64" /><Skeleton className="mt-3 h-3.5 w-80" /></div></div></div>
        <DetailSkeleton />
      </>
    )
  }

  const u = user.data
  const isMe = u.id === auth.user()?.id
  const f = u.finance
  const last = recent.data?.items[0]
  const target = { ...u, _count: { transactions: u._count.transactions, savingGoals: u._count.savingGoals } }
  const profile: [string, string, string][] = [
    ['Giao dịch', formatNumber(u._count.transactions), 'count-transactions'],
    ['Danh mục riêng', formatNumber(u._count.categories), 'count-categories'],
    ['Ngân sách', formatNumber(u._count.budgets), 'count-budgets'],
    ['Mục tiêu tiết kiệm', formatNumber(u._count.savingGoals), 'count-goals'],
    ['Giao dịch định kỳ', formatNumber(u._count.recurringRules), 'count-recurring'],
    ['Đăng nhập gần nhất', u.lastLoginAt ? (isToday(u.lastLoginAt) ? `${formatTime(u.lastLoginAt)} hôm nay` : formatDate(u.lastLoginAt)) : '—', 'last-login'],
    ['Giao dịch gần nhất', last ? (isToday(last.occurredAt) ? `${formatTime(last.occurredAt)} hôm nay` : formatDate(last.occurredAt)) : '—', 'last-activity'],
  ]

  return (
    <>
      <div className="flex items-end justify-between gap-6">
        <div className="min-w-0">
          {crumb}
          <div className="flex items-center gap-4">
            <UserBubble name={u.name} size="lg" />
            <div className="min-w-0">
              <div className="flex items-center gap-3">
                <h1 className="truncate text-headline" data-testid="detail-name">{u.name}</h1>
                {isMe && <span className="text-muted-foreground">(bạn)</span>}
                <StatusBadge status={u.status} solid />
              </div>
              <p className="mt-0.5 truncate text-muted-foreground">
                <span data-testid="detail-email">{u.email}</span> · {ROLE_LABEL[u.role]} · tham gia {formatDate(u.createdAt)}
              </p>
            </div>
          </div>
        </div>
        <div className="flex shrink-0 items-center gap-2.5">
          <Button variant="secondary" disabled={pending} onClick={() => toggleRole(target)} data-testid="detail-role-btn">
            {u.role === 'USER' ? <><ShieldCheck /> Cấp quyền quản trị</> : <><ShieldOff /> Hạ quyền quản trị</>}
          </Button>
          <Button variant={u.status === 'ACTIVE' ? 'danger' : 'secondary'} disabled={pending} onClick={() => toggleLock(target)} data-testid="detail-lock-btn">
            {u.status === 'ACTIVE' ? <><Lock /> Khóa tài khoản</> : <><LockOpen /> Mở khóa</>}
          </Button>
        </div>
      </div>

      <div className="grid grid-cols-12 items-start gap-5">
        <div className="col-span-12 flex flex-col gap-5 xl:col-span-8">
          <Card>
            <div className="flex items-stretch gap-4">
              <div className="shrink-0 pr-2">
                <p className="text-body-s font-medium text-muted-foreground">Số dư · {u.wallets.length} ví</p>
                <p className={cn('mt-1 text-display whitespace-nowrap tabular-nums', f.balance < 0 && 'text-destructive')} data-testid="fin-balance">{formatVND(f.balance)}</p>
              </div>
              <Figure label="Tổng thu" value={formatSigned(f.totalIncome, true)} testId="fin-income" className="text-income" />
              <Figure label="Tổng chi" value={formatSigned(f.totalExpense, false)} testId="fin-expense" />
              <Figure label="Đang tiết kiệm" value={formatVND(f.savings)} testId="fin-savings" />
            </div>
            <CardHeader className="mt-7" title="Thu chi 6 tháng" aside={<ChartLegend />} />
            <TrendChart data={u.trend} barSize={18} className="mt-3 h-[214px]" />
          </Card>

          <Card flush>
            <CardHeader
              className="px-6 pt-5"
              title="Giao dịch gần đây"
              aside={
                u._count.transactions > 0 && (
                  <Link to={`/transactions?userId=${u.id}`} className="inline-flex items-center gap-1 text-[13.5px] font-semibold hover:underline" data-testid="all-tx-link">
                    Xem cả {formatNumber(u._count.transactions)} giao dịch<ChevronRight className="size-4" />
                  </Link>
                )
              }
            />
            <div className="mt-3 px-6 pb-1.5" data-testid="recent-tx">
              {recent.isPending
                ? [0, 1, 2].map((i) => <div key={i} className="flex h-[58px] items-center gap-3"><Skeleton className="size-10 rounded-full" /><Skeleton className="h-3 w-40" /></div>)
                : recent.data?.items.length
                  ? recent.data.items.map((t) => <TxRow key={t.id} t={t} />)
                  : <p className="pt-2 pb-5 text-muted-foreground">Chưa có giao dịch nào.</p>}
            </div>
          </Card>
        </div>

        <div className="col-span-12 flex flex-col gap-5 xl:col-span-4">
          <Card flush data-testid="wallets">
            <CardHeader className="px-6 pt-5" title="Ví" aside={<span className="text-body-s font-medium text-muted-foreground">{u.wallets.length} ví</span>} />
            <div className="mt-3 px-6 pb-1.5">
              {u.wallets.map((w) => <WalletRow key={w.id} w={w} />)}
              <div className="flex h-[52px] items-center justify-between border-t border-border">
                <span className="text-muted-foreground">Tổng</span>
                <span className="text-body-l font-semibold tabular-nums" data-testid="wallets-total">{formatVND(u.wallets.reduce((s, w) => s + w.balance, 0))}</span>
              </div>
            </div>
          </Card>
          <Card>
            <h2 className="text-title-m">Hồ sơ</h2>
            <dl className="mt-3">
              {profile.map(([k, v, t]) => (
                <div key={k} className="flex h-10 items-center justify-between border-line not-first:border-t">
                  <dt className="text-muted-foreground">{k}</dt>
                  <dd className="font-semibold tabular-nums" data-testid={t}>{v}</dd>
                </div>
              ))}
            </dl>
          </Card>
          <AiUsageCard userId={u.id} email={u.email} />
        </div>
      </div>
      {dialog}
    </>
  )
}

/** A13: chỉ số đếm trợ lý AI của người dùng, không có nội dung tin nhắn hay điều trợ lý đã học. */
function AiUsageCard({ userId, email }: { userId: string; email: string }) {
  const q = useQuery({ queryKey: ['ai-usage', userId], queryFn: () => api.aiUserUsage({ q: email, limit: 20 }), select: (d) => d.items.find((x) => x.user?.id === userId) ?? null })
  const a = q.data
  const resolved = a ? a.drafts.confirmed + a.drafts.edited + a.drafts.cancelled : 0
  const rows: [string, string][] = a
    ? [
        ['Tin nhắn', formatNumber(a.messages)],
        ['Trong 24 giờ qua', formatNumber(a.messages24h)],
        ['Cuộc trò chuyện', formatNumber(a.conversations)],
        ['Nháp đề xuất', formatNumber(resolved + a.drafts.proposed)],
        ['Xác nhận không sửa', `${formatNumber(a.drafts.confirmed)}${resolved ? ` · ${Math.round((a.drafts.confirmed / resolved) * 100)}%` : ''}`],
        ['Sửa rồi lưu', formatNumber(a.drafts.edited)],
        ['Hủy nháp', formatNumber(a.drafts.cancelled)],
        ['Hỏi gần nhất', a.lastActiveAt ? (isToday(a.lastActiveAt) ? `${formatTime(a.lastActiveAt)} hôm nay` : formatDate(a.lastActiveAt)) : '—'],
      ]
    : []
  return (
    <Card data-testid="ai-usage-card">
      <h2 className="flex items-center gap-2 text-title-m"><Sparkles className="size-[18px]" />Trợ lý AI</h2>
      {q.isPending ? (
        <div className="mt-4 flex flex-col gap-3"><Skeleton className="h-3 w-full" /><Skeleton className="h-3 w-4/5" /><Skeleton className="h-3 w-3/5" /></div>
      ) : q.error ? (
        <p className="mt-3 text-body-s text-destructive">{q.error.message}</p>
      ) : !a ? (
        <p className="mt-3 text-body-s text-muted-foreground" data-testid="ai-usage-empty">Chưa dùng trợ lý.</p>
      ) : (
        <dl className="mt-3">
          {rows.map(([k, v]) => (
            <div key={k} className="flex h-10 items-center justify-between border-line not-first:border-t">
              <dt className="text-muted-foreground">{k}</dt>
              <dd className="font-semibold tabular-nums">{v}</dd>
            </div>
          ))}
        </dl>
      )}
      <p className="mt-4 flex items-start gap-2.5 rounded-md bg-background px-3.5 py-3 text-body-s text-muted-foreground">
        <Lock className="mt-0.5 size-3.5 shrink-0" />Chỉ số đếm. Không hiển thị nội dung tin nhắn hay điều trợ lý đã học về người này.
      </p>
    </Card>
  )
}
