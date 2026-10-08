import type { ReactNode } from 'react'
import { AlertCircle, ChevronLeft, ChevronRight, Inbox } from 'lucide-react'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { Card } from '@/components/ui/card'
import { Skeleton } from '@/components/ui/skeleton'
import type { Role, UserStatus } from '@/lib/api'
import { formatNumber, ROLE_LABEL, STATUS_LABEL } from '@/lib/format'
import { cn } from '@/lib/utils'

export function PageHeader({ title, description, actions }: { title: ReactNode; description?: ReactNode; actions?: ReactNode }) {
  return (
    <div className="mb-6 flex flex-wrap items-end justify-between gap-4">
      <div className="min-w-0">
        <h1 className="text-2xl font-semibold tracking-tight">{title}</h1>
        {description && <p className="mt-1 text-sm text-muted-foreground">{description}</p>}
      </div>
      {actions && <div className="flex items-center gap-2">{actions}</div>}
    </div>
  )
}

export function StatCard({
  label, value, hint, icon, tone = 'default', testId,
}: { label: string; value: ReactNode; hint?: ReactNode; icon: ReactNode; tone?: 'default' | 'income' | 'expense' | 'warning'; testId?: string }) {
  const toneClass = {
    default: 'bg-primary/10 text-primary',
    income: 'bg-teal-500/10 text-teal-700',
    expense: 'bg-rose-500/10 text-rose-700',
    warning: 'bg-amber-500/10 text-amber-700',
  }[tone]
  return (
    <Card className="gap-0 px-5 py-4">
      <div className="flex items-start justify-between gap-3">
        <div className="min-w-0">
          <p className="text-sm text-muted-foreground">{label}</p>
          <p className="mt-1.5 truncate text-2xl font-semibold tabular-nums tracking-tight" data-testid={testId}>{value}</p>
        </div>
        <div className={cn('flex size-10 shrink-0 items-center justify-center rounded-lg [&_svg]:size-5', toneClass)}>{icon}</div>
      </div>
      {hint && <p className="mt-2 text-xs text-muted-foreground">{hint}</p>}
    </Card>
  )
}

export function Pagination({ page, limit, total, onChange }: { page: number; limit: number; total: number; onChange: (p: number) => void }) {
  const pages = Math.max(1, Math.ceil(total / limit))
  const from = total === 0 ? 0 : (page - 1) * limit + 1
  const to = Math.min(page * limit, total)
  return (
    <div className="flex flex-wrap items-center justify-between gap-3 border-t px-4 py-3 text-sm text-muted-foreground">
      <span data-testid="pagination-info">
        {formatNumber(from)}–{formatNumber(to)} / {formatNumber(total)}
      </span>
      <div className="flex items-center gap-2">
        <Button variant="outline" size="sm" disabled={page <= 1} onClick={() => onChange(page - 1)} aria-label="Trang trước">
          <ChevronLeft /> Trước
        </Button>
        <span className="px-1 tabular-nums" data-testid="pagination-page">Trang {page}/{pages}</span>
        <Button variant="outline" size="sm" disabled={page >= pages} onClick={() => onChange(page + 1)} aria-label="Trang sau">
          Sau <ChevronRight />
        </Button>
      </div>
    </div>
  )
}

export function TableSkeleton({ rows = 6, cols = 5 }: { rows?: number; cols?: number }) {
  return (
    <div className="space-y-3 p-4" data-testid="loading">
      {Array.from({ length: rows }, (_, i) => (
        <div key={i} className="flex gap-4">
          {Array.from({ length: cols }, (_, j) => <Skeleton key={j} className="h-6 flex-1" />)}
        </div>
      ))}
    </div>
  )
}

export function EmptyState({ title = 'Không có dữ liệu', description }: { title?: string; description?: string }) {
  return (
    <div className="flex flex-col items-center justify-center gap-2 px-4 py-14 text-center" data-testid="empty">
      <div className="flex size-12 items-center justify-center rounded-full bg-muted text-muted-foreground"><Inbox className="size-6" /></div>
      <p className="font-medium">{title}</p>
      {description && <p className="max-w-sm text-sm text-muted-foreground">{description}</p>}
    </div>
  )
}

export function ErrorState({ error, onRetry }: { error: unknown; onRetry?: () => void }) {
  return (
    <div className="flex flex-col items-center justify-center gap-3 px-4 py-14 text-center" data-testid="error">
      <div className="flex size-12 items-center justify-center rounded-full bg-destructive/10 text-destructive"><AlertCircle className="size-6" /></div>
      <div>
        <p className="font-medium">Không tải được dữ liệu</p>
        <p className="text-sm text-muted-foreground">{error instanceof Error ? error.message : 'Có lỗi xảy ra'}</p>
      </div>
      {onRetry && <Button variant="outline" size="sm" onClick={onRetry}>Thử lại</Button>}
    </div>
  )
}

export function RoleBadge({ role }: { role: Role }) {
  return role === 'ADMIN'
    ? <Badge className="bg-violet-100 text-violet-700">{ROLE_LABEL.ADMIN}</Badge>
    : <Badge variant="secondary">{ROLE_LABEL.USER}</Badge>
}

export function StatusBadge({ status }: { status: UserStatus }) {
  return (
    <Badge className={status === 'ACTIVE' ? 'bg-emerald-100 text-emerald-700' : 'bg-red-100 text-red-700'}>
      <span className={cn('size-1.5 rounded-full', status === 'ACTIVE' ? 'bg-emerald-500' : 'bg-red-500')} />
      {STATUS_LABEL[status]}
    </Badge>
  )
}

export function UserAvatar({ name, className }: { name: string; className?: string }) {
  const initials = name.trim().split(/\s+/).slice(-2).map((w) => w[0]?.toUpperCase()).join('') || '?'
  return (
    <div className={cn('flex size-9 shrink-0 items-center justify-center rounded-full bg-primary/10 text-xs font-semibold text-primary', className)}>
      {initials}
    </div>
  )
}
