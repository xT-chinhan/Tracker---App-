import { Navigate, NavLink, Outlet, useNavigate } from 'react-router'
import { useQuery } from '@tanstack/react-query'
import { ArrowLeftRight, LayoutDashboard, LogOut, Shapes, UserCog, Users, Wallet } from 'lucide-react'
import {
  DropdownMenu, DropdownMenuContent, DropdownMenuItem, DropdownMenuLabel, DropdownMenuSeparator, DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu'
import { UserAvatar } from '@/components/common'
import { api, auth, logout } from '@/lib/api'
import { cn } from '@/lib/utils'

const NAV = [
  { to: '/', label: 'Tổng quan', icon: LayoutDashboard, end: true },
  { to: '/users', label: 'Người dùng', icon: Users },
  { to: '/transactions', label: 'Giao dịch', icon: ArrowLeftRight },
  { to: '/categories', label: 'Danh mục hệ thống', icon: Shapes },
  { to: '/account', label: 'Tài khoản', icon: UserCog },
]

/** Khung trang sau đăng nhập: sidebar (thu gọn thành icon trên tablet) + nội dung. */
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

  // Token hết hạn: trang login sẽ dọn localStorage
  if (!authed) return <Navigate to={auth.token() ? '/login?reason=expired' : '/login'} replace />

  return (
    <div className="flex min-h-svh bg-muted/40">
      <aside className="sticky top-0 flex h-svh w-16 shrink-0 flex-col border-r bg-background lg:w-64">
        <div className="flex h-16 items-center gap-2.5 border-b px-4">
          <div className="flex size-8 shrink-0 items-center justify-center rounded-lg bg-primary text-primary-foreground">
            <Wallet className="size-4" />
          </div>
          <div className="hidden leading-tight lg:block">
            <p className="text-sm font-semibold">Thu Chi Admin</p>
            <p className="text-xs text-muted-foreground">Bảng quản trị</p>
          </div>
        </div>
        <nav className="flex flex-1 flex-col gap-1 p-2 lg:p-3">
          {NAV.map(({ to, label, icon: Icon, end }) => (
            <NavLink
              key={to}
              to={to}
              end={end}
              title={label}
              className={({ isActive }) =>
                cn(
                  'flex h-10 items-center justify-center gap-3 rounded-lg px-3 text-sm font-medium text-muted-foreground transition-colors hover:bg-muted hover:text-foreground lg:justify-start',
                  isActive && 'bg-primary/10 text-primary hover:bg-primary/10 hover:text-primary',
                )
              }
            >
              <Icon className="size-4.5 shrink-0" />
              <span className="hidden lg:inline">{label}</span>
            </NavLink>
          ))}
        </nav>
        <div className="border-t p-2 lg:p-3">
          <DropdownMenu>
            <DropdownMenuTrigger
              className="flex w-full items-center justify-center gap-3 rounded-lg p-1.5 text-left outline-none hover:bg-muted lg:justify-start"
              data-testid="user-menu"
            >
              <UserAvatar name={me?.name ?? '?'} />
              <div className="hidden min-w-0 lg:block">
                <p className="truncate text-sm font-medium" data-testid="me-name">{me?.name}</p>
                <p className="truncate text-xs text-muted-foreground">{me?.email}</p>
              </div>
            </DropdownMenuTrigger>
            <DropdownMenuContent side="top" align="start" className="w-56">
              <DropdownMenuLabel className="truncate">{me?.email}</DropdownMenuLabel>
              <DropdownMenuSeparator />
              <DropdownMenuItem onClick={() => navigate('/account')}>
                <UserCog /> Tài khoản
              </DropdownMenuItem>
              <DropdownMenuItem variant="destructive" onClick={() => logout()}>
                <LogOut /> Đăng xuất
              </DropdownMenuItem>
            </DropdownMenuContent>
          </DropdownMenu>
        </div>
      </aside>
      <main className="min-w-0 flex-1">
        <div className="mx-auto w-full max-w-7xl p-4 md:p-6 lg:p-8">
          <Outlet />
        </div>
      </main>
    </div>
  )
}
