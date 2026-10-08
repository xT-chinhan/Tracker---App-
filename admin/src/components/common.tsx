import type { ReactNode } from 'react'
import { ChevronLeft, ChevronRight, CircleAlert, Lock, RotateCcw, SearchX, ShieldCheck } from 'lucide-react'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { Skeleton } from '@/components/ui/skeleton'
import { Bubble } from '@/components/CategoryIcon'
import type { Role, UserStatus } from '@/lib/api'
import { formatNumber, initials, ROLE_LABEL, STATUS_LABEL } from '@/lib/format'
import { cn } from '@/lib/utils'

/** Tiêu đề trang 30/700 + mô tả, hành động bên phải. Không có top bar. */
export function PageHeader({ title, description, actions, before }: { title: ReactNode; description?: ReactNode; actions?: ReactNode; before?: ReactNode }) {
  return (
    <div className="flex items-end justify-between gap-6">
      <div className="min-w-0">
        {before}
        <h1 className="text-headline">{title}</h1>
        {description && <div className="mt-1 text-muted-foreground tabular-nums" data-testid="page-sub">{description}</div>}
      </div>
      {actions && <div className="flex shrink-0 items-center gap-2.5">{actions}</div>}
    </div>
  )
}

export function UserBubble({ name, size = 'md' }: { name: string; size?: 'xs' | 'sm' | 'md' | 'lg' | 'xl' }) {
  return <Bubble size={size}>{initials(name)}</Bubble>
}

/** Hoạt động = chấm xanh không nền; đã khóa = badge đỏ có ổ khóa. */
export function StatusBadge({ status, solid }: { status: UserStatus; solid?: boolean }) {
  return status === 'ACTIVE' ? (
    <Badge variant={solid ? 'default' : 'plain'} data-testid="status-badge"><span className="size-[7px] rounded-full bg-income" />{STATUS_LABEL.ACTIVE}</Badge>
  ) : (
    <Badge variant="danger" data-testid="status-badge"><Lock />{STATUS_LABEL.LOCKED}</Badge>
  )
}

export function RoleBadge({ role }: { role: Role }) {
  return role === 'ADMIN'
    ? <Badge variant="ink" data-testid="role-badge"><ShieldCheck />{ROLE_LABEL.ADMIN}</Badge>
    : <span className="text-muted-foreground" data-testid="role-badge">{ROLE_LABEL.USER}</span>
}

function pageList(page: number, pages: number): (number | 'gap')[] {
  const want = new Set([1, pages, page - 1, page, page + 1])
  if (page <= 3) [2, 3].forEach((p) => want.add(p))
  if (page >= pages - 2) [pages - 2, pages - 1].forEach((p) => want.add(p))
  const sorted = [...want].filter((p) => p >= 1 && p <= pages).sort((a, b) => a - b)
  const out: (number | 'gap')[] = []
  sorted.forEach((p, i) => {
    if (i && p - sorted[i - 1] > 1) out.push('gap')
    out.push(p)
  })
  return out
}

/** "1–10 trong 1.284" + số trang (trang hiện tại nền đen). */
export function Pagination({ page, limit, total, onChange, suffix }: { page: number; limit: number; total: number; onChange: (p: number) => void; suffix?: string }) {
  const pages = Math.max(1, Math.ceil(total / limit))
  const from = total === 0 ? 0 : (page - 1) * limit + 1
  const to = Math.min(page * limit, total)
  const pg = 'inline-flex h-[34px] min-w-[34px] cursor-pointer items-center justify-center rounded-full px-1.5 font-medium tabular-nums text-foreground hover:bg-muted disabled:cursor-default disabled:text-faint disabled:hover:bg-transparent [&_svg]:size-4'
  return (
    <div className="flex items-center justify-between border-t border-border py-2.5 pr-4 pl-6 text-[13.5px] text-muted-foreground">
      <span className="tabular-nums" data-testid="pagination-info">
        {formatNumber(from)}–{formatNumber(to)} trong {formatNumber(total)}{suffix ? ` ${suffix}` : ''}
      </span>
      <nav className="flex items-center gap-1" aria-label="Phân trang">
        <button type="button" className={pg} disabled={page <= 1} onClick={() => onChange(page - 1)} aria-label="Trang trước"><ChevronLeft /></button>
        {pageList(page, pages).map((p, i) =>
          p === 'gap' ? (
            <span key={`g${i}`} className={cn(pg, 'cursor-default text-faint hover:bg-transparent')}>…</span>
          ) : (
            <button
              key={p}
              type="button"
              className={cn(pg, p === page && 'bg-primary text-primary-foreground hover:bg-primary')}
              aria-current={p === page ? 'page' : undefined}
              aria-label={`Trang ${p}`}
              onClick={() => onChange(p)}
            >
              {formatNumber(p)}
            </button>
          ),
        )}
        <button type="button" className={pg} disabled={page >= pages} onClick={() => onChange(page + 1)} aria-label="Trang sau"><ChevronRight /></button>
      </nav>
    </div>
  )
}

/** Skeleton đúng bố cục bảng: bong bóng + 2 dòng chữ + số bên phải. */
export function TableSkeleton({ rows = 8 }: { rows?: number }) {
  return (
    <div className="px-6 py-2" data-testid="loading" aria-busy="true">
      {Array.from({ length: rows }, (_, i) => (
        <div key={i} className="flex h-14 items-center gap-3 border-b border-line last:border-0">
          <Skeleton className="size-8 rounded-full" />
          <div className="flex-1">
            <Skeleton className="h-3" style={{ width: 140 - (i % 3) * 18 }} />
            <Skeleton className="mt-2 h-2.5" style={{ width: 190 - (i % 4) * 16 }} />
          </div>
          <Skeleton className="h-3 w-24" />
          <Skeleton className="ml-10 h-3 w-16" />
        </div>
      ))}
    </div>
  )
}

function GhostStack({ icon }: { icon: ReactNode }) {
  const card = 'absolute left-1/2 -ml-[110px] flex h-14 w-[220px] items-center gap-2.5 rounded-md border border-border bg-card px-3.5 shadow-card'
  return (
    <div className="relative h-[132px] w-[260px]" aria-hidden="true">
      <div className={card} style={{ top: 0, transform: 'scale(.86)', opacity: 0.5 }}><Bubble size="sm" className="size-[30px]" /><div className="h-2 w-[60%] rounded bg-muted-high" /></div>
      <div className={card} style={{ top: 24, transform: 'scale(.93)', opacity: 0.75 }}><Bubble size="sm" className="size-[30px]" /><div className="h-2 w-[70%] rounded bg-muted-high" /></div>
      <div className={card} style={{ top: 52 }}>
        <Bubble size="sm" className="size-[30px] [&_svg]:size-4">{icon}</Bubble>
        <div className="flex-1"><div className="h-2 w-[72%] rounded bg-muted-high" /><div className="mt-[7px] h-2 w-[44%] rounded bg-muted" /></div>
      </div>
    </div>
  )
}

/** Trạng thái trống có minh họa "chồng thẻ" + nút hành động. */
export function EmptyState({ title, description, action, icon = <SearchX />, className }: {
  title: string
  description?: ReactNode
  action?: { label: string; onClick: () => void }
  icon?: ReactNode
  className?: string
}) {
  return (
    <div className={cn('flex flex-col items-center px-6 pt-14 pb-16 text-center', className)} data-testid="empty">
      <GhostStack icon={icon} />
      <p className="mt-6 text-title-l">{title}</p>
      {description && <p className="mt-2 max-w-[440px] text-muted-foreground">{description}</p>}
      {action && (
        <Button variant="secondary" className="mt-6" onClick={action.onClick}>
          <RotateCcw /> {action.label}
        </Button>
      )}
    </div>
  )
}

export function ErrorState({ error, onRetry }: { error: unknown; onRetry?: () => void }) {
  return (
    <div className="flex flex-col items-center px-6 py-14 text-center" data-testid="error">
      <Bubble size="lg" tone="danger"><CircleAlert /></Bubble>
      <p className="mt-5 text-title-l">Không tải được dữ liệu</p>
      <p className="mt-2 max-w-[440px] text-muted-foreground">{error instanceof Error ? error.message : 'Có lỗi xảy ra'}</p>
      {onRetry && <Button variant="secondary" className="mt-6" onClick={onRetry}><RotateCcw /> Thử lại</Button>}
    </div>
  )
}

/** Chip lọc: trắng viền mảnh, đen khi chọn. */
export function Chip({ on, onClick, children, testId }: { on: boolean; onClick: () => void; children: ReactNode; testId?: string }) {
  return (
    <button
      type="button"
      aria-pressed={on}
      onClick={onClick}
      data-testid={testId}
      className={cn(
        'inline-flex h-[34px] shrink-0 cursor-pointer items-center gap-1.5 rounded-full border px-3.5 text-[13.5px] font-medium whitespace-nowrap transition-colors',
        on ? 'border-primary bg-primary text-primary-foreground [&_.c]:text-white/60' : 'border-border bg-card hover:bg-hover',
      )}
    >
      {children}
    </button>
  )
}
