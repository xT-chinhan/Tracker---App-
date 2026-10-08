import { Navigate, NavLink, Outlet, useNavigate } from 'react-router'
import { useQuery } from '@tanstack/react-query'
import { ArrowLeftRight, LayoutDashboard, LogOut, Megaphone, Shapes, UserRoundCog, Users } from 'lucide-react'
import {
  DropdownMenu, DropdownMenuContent, DropdownMenuItem, DropdownMenuLabel, DropdownMenuSeparator, DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu'
import { Button } from '@/components/ui/button'
import { UserBubble } from '@/components/common'
import { api, auth, logout } from '@/lib/api'
import { formatNumber } from '@/lib/format'
import { cn } from '@/lib/utils'

const MANAGE = [
  { to: '/', label: 'Tổng quan', icon: LayoutDashboard, end: true },
  { to: '/users', label: 'Người dùng', icon: Users, count: true },
  { to: '/transactions', label: 'Giao dịch', icon: ArrowLeftRight },
  { to: '/categories', label: 'Danh mục', icon: Shapes },
  { to: '/broadcasts', label: 'Thông báo', icon: Megaphone },
]

/** Logo chữ "đ" gạch chân trên nền đen. */
export function Logo({ size = 'md' }: { size?: 'md' | 'lg' }) {
  return (
    <div
      className={cn(
        'flex shrink-0 items-center justify-center bg-primary font-bold text-primary-foreground underline decoration-2 underline-offset-3',
        size === 'lg' ? 'size-14 rounded-[16px] text-[26px]' : 'size-9 rounded-[11px] text-lg',
      )}
      aria-hidden="true"
    >
      đ
    </div>
  )
}

function NavItem({ to, label, icon: Icon, end, count }: { to: string; label: string; icon: typeof Users; end?: boolean; count?: number }) {
  return (
    <NavLink
      to={to}
      end={end}
      aria-label={label}
      title={label}
      className={({ isActive }) =>
        cn(
          'group/nav flex size-11 items-center justify-center gap-3 rounded-sm border border-transparent text-[14.5px] font-medium text-nav transition-colors hover:bg-card/60 hover:text-foreground xl:h-[42px] xl:w-auto xl:justify-start xl:px-3',
          isActive && 'border-border bg-card font-semibold text-foreground shadow-[0_1px_3px_rgb(17_17_17/.05)] hover:bg-card',
        )
      }
    >
      <Icon className="size-[18px] text-nav-icon group-aria-[current=page]/nav:text-foreground group-aria-[current=page]/nav:[stroke-width:2]" />
      <span className="hidden xl:inline">{label}</span>
      {count !== undefined && <span className="ml-auto hidden text-xs font-medium text-faint tabular-nums xl:inline">{formatNumber(count)}</span>}
    </NavLink>
  )
}

const groupLabel = 'mx-auto my-3.5 h-px w-7 overflow-hidden bg-border text-transparent xl:mx-0 xl:mt-1 xl:mb-2 xl:h-auto xl:w-auto xl:bg-transparent xl:px-3 xl:text-xs xl:leading-normal xl:font-medium xl:text-faint'

/** Khung trang sau đăng nhập: sidebar 248px (rail 72px dưới 1280px) cùng nền trang, không có top bar. */
export function Layout() {
  const navigate = useNavigate()
  const authed = auth.isValid()
  const { data: me } = useQuery({
    queryKey: ['me'],
    queryFn: async () => {
      const u = await api.me()
      if (u.role !== 'ADMIN') logout('forbidden')
      auth.setUser(u)
      return u
    },
    initialData: auth.user() ?? undefined,
    enabled: authed,
  })
  const overview = useQuery({ queryKey: ['overview'], queryFn: api.overview, enabled: authed })

  // Token hết hạn: trang login sẽ dọn localStorage
  if (!authed) return <Navigate to={auth.token() ? '/login?reason=expired' : '/login'} replace />

  return (
    <div className="flex min-h-svh">
      <aside className="sticky top-0 flex h-svh w-[72px] shrink-0 flex-col items-center border-r border-border px-3 pt-5 pb-5 xl:w-[248px] xl:items-stretch xl:px-4 xl:pt-7" data-testid="sidebar">
        <div className="flex items-center gap-3 pb-6 xl:px-2 xl:pb-7">
          <Logo />
          <div className="hidden xl:block">
            <p className="text-base leading-[1.3] font-bold tracking-[-0.01em]">Thu Chi</p>
            <p className="text-xs leading-[1.3] text-muted-foreground">Bảng quản trị</p>
          </div>
        </div>
        <p className={cn(groupLabel, 'hidden xl:block')}>Quản lý</p>
        <nav className="flex flex-col gap-0.5">
          {MANAGE.map((n) => <NavItem key={n.to} {...n} count={n.count ? overview.data?.users.total : undefined} />)}
        </nav>
        <p className={cn(groupLabel, 'xl:mt-6')} aria-hidden="true">Cá nhân</p>
        <nav className="flex flex-col gap-0.5">
          <NavItem to="/account" label="Tài khoản" icon={UserRoundCog} />
        </nav>

        <div className="mt-auto flex items-center gap-2.5 pt-3 xl:border-t xl:border-border xl:px-2">
          {/* Desktop: tên + email + nút đăng xuất */}
          <div className="hidden min-w-0 flex-1 items-center gap-2.5 xl:flex">
            <UserBubble name={me?.name ?? '?'} size="sm" />
            <div className="min-w-0 flex-1">
              <p className="truncate text-[13.5px] leading-[1.35] font-semibold" data-testid="me-name">{me?.name}</p>
              <p className="truncate text-xs leading-[1.4] text-muted-foreground">{me?.email}</p>
            </div>
            <Button variant="ghost" size="icon" aria-label="Đăng xuất" title="Đăng xuất" onClick={() => logout()} data-testid="logout">
              <LogOut />
            </Button>
          </div>
          {/* Rail: bong bóng mở menu */}
          <DropdownMenu>
            <DropdownMenuTrigger className="cursor-pointer rounded-full outline-none focus-visible:ring-2 focus-visible:ring-primary/20 xl:hidden" aria-label="Tài khoản của bạn" data-testid="user-menu">
              <UserBubble name={me?.name ?? '?'} size="sm" />
            </DropdownMenuTrigger>
            <DropdownMenuContent side="right" align="end">
              <DropdownMenuLabel>{me?.email}</DropdownMenuLabel>
              <DropdownMenuItem onClick={() => navigate('/account')}><UserRoundCog /> Tài khoản</DropdownMenuItem>
              <DropdownMenuSeparator />
              <DropdownMenuItem variant="destructive" onClick={() => logout()}><LogOut /> Đăng xuất</DropdownMenuItem>
            </DropdownMenuContent>
          </DropdownMenu>
        </div>
      </aside>
      <main className="flex min-w-0 flex-1 flex-col gap-5 px-8 pt-7 pb-8 xl:gap-6 xl:px-10 xl:pt-9">
        <Outlet />
      </main>
    </div>
  )
}
