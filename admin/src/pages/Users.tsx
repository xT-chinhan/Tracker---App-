import { useEffect, useState } from 'react'
import { Link } from 'react-router'
import { keepPreviousData, useQuery } from '@tanstack/react-query'
import { Eye, Lock, MoreHorizontal, Search, ShieldCheck, ShieldOff, Unlock } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Card } from '@/components/ui/card'
import {
  DropdownMenu, DropdownMenuContent, DropdownMenuItem, DropdownMenuSeparator, DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu'
import { Input } from '@/components/ui/input'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table'
import { EmptyState, ErrorState, PageHeader, Pagination, RoleBadge, StatusBadge, TableSkeleton, UserAvatar } from '@/components/common'
import { useUserActions } from '@/components/useUserActions'
import { api, auth, type Role, type UserStatus } from '@/lib/api'
import { formatDate, formatNumber } from '@/lib/format'
import { useDebounced, useUrlFilters } from '@/lib/utils'

const LIMIT = 10

export default function UsersPage() {
  const { values, page, set } = useUrlFilters(['q', 'status', 'role'] as const)
  const [search, setSearch] = useState(values.q)
  const debounced = useDebounced(search)
  useEffect(() => {
    if (debounced.trim() !== values.q) set({ q: debounced.trim() })
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [debounced])

  const query = {
    page,
    limit: LIMIT,
    q: values.q || undefined,
    status: (values.status || undefined) as UserStatus | undefined,
    role: (values.role || undefined) as Role | undefined,
  }
  const { data, isPending, isFetching, error, refetch } = useQuery({
    queryKey: ['users', query],
    queryFn: () => api.users(query),
    placeholderData: keepPreviousData,
  })
  const { toggleLock, toggleRole, dialog } = useUserActions()
  const meId = auth.user()?.id

  return (
    <>
      <PageHeader
        title="Người dùng"
        description={data ? `${formatNumber(data.total)} tài khoản phù hợp` : 'Quản lý tài khoản, khóa/mở khóa và phân quyền'}
      />
      <Card className="gap-0 py-0">
        <div className="flex flex-wrap items-center gap-3 border-b p-4">
          <div className="relative min-w-56 flex-1">
            <Search className="pointer-events-none absolute top-1/2 left-3 size-4 -translate-y-1/2 text-muted-foreground" />
            <Input
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              placeholder="Tìm theo tên hoặc email…"
              className="h-9 pl-9"
              data-testid="users-search"
            />
          </div>
          <Select value={values.status || 'all'} onValueChange={(v) => set({ status: v })}>
            <SelectTrigger className="h-9! w-40" data-testid="filter-status"><SelectValue /></SelectTrigger>
            <SelectContent>
              <SelectItem value="all">Mọi trạng thái</SelectItem>
              <SelectItem value="ACTIVE">Hoạt động</SelectItem>
              <SelectItem value="LOCKED">Đã khóa</SelectItem>
            </SelectContent>
          </Select>
          <Select value={values.role || 'all'} onValueChange={(v) => set({ role: v })}>
            <SelectTrigger className="h-9! w-40" data-testid="filter-role"><SelectValue /></SelectTrigger>
            <SelectContent>
              <SelectItem value="all">Mọi vai trò</SelectItem>
              <SelectItem value="USER">Người dùng</SelectItem>
              <SelectItem value="ADMIN">Quản trị</SelectItem>
            </SelectContent>
          </Select>
        </div>

        {error ? (
          <ErrorState error={error} onRetry={refetch} />
        ) : isPending ? (
          <TableSkeleton />
        ) : data.items.length === 0 ? (
          <EmptyState title="Không tìm thấy người dùng" description="Thử đổi từ khóa hoặc bộ lọc." />
        ) : (
          <div className={isFetching ? 'opacity-60 transition-opacity' : 'transition-opacity'}>
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead className="pl-4">Người dùng</TableHead>
                  <TableHead>Vai trò</TableHead>
                  <TableHead>Trạng thái</TableHead>
                  <TableHead className="text-right">Giao dịch</TableHead>
                  <TableHead className="text-right">Mục tiêu</TableHead>
                  <TableHead className="pl-6">Ngày tạo</TableHead>
                  <TableHead className="w-12 pr-4" />
                </TableRow>
              </TableHeader>
              <TableBody>
                {data.items.map((u) => (
                  <TableRow key={u.id} data-testid="user-row" data-email={u.email}>
                    <TableCell className="max-w-72 pl-4">
                      <Link to={`/users/${u.id}`} className="group flex items-center gap-3">
                        <UserAvatar name={u.name} />
                        <div className="min-w-0">
                          <p className="truncate font-medium group-hover:text-primary group-hover:underline">
                            {u.name}
                            {u.id === meId && <span className="ml-1.5 text-xs font-normal text-muted-foreground">(bạn)</span>}
                          </p>
                          <p className="truncate text-xs text-muted-foreground">{u.email}</p>
                        </div>
                      </Link>
                    </TableCell>
                    <TableCell><RoleBadge role={u.role} /></TableCell>
                    <TableCell><StatusBadge status={u.status} /></TableCell>
                    <TableCell className="text-right tabular-nums">{formatNumber(u._count.transactions)}</TableCell>
                    <TableCell className="text-right tabular-nums">{formatNumber(u._count.savingGoals)}</TableCell>
                    <TableCell className="pl-6 text-muted-foreground tabular-nums">{formatDate(u.createdAt)}</TableCell>
                    <TableCell className="pr-4">
                      <DropdownMenu>
                        <DropdownMenuTrigger asChild>
                          <Button variant="ghost" size="icon-sm" aria-label="Thao tác" data-testid="user-actions"><MoreHorizontal /></Button>
                        </DropdownMenuTrigger>
                        <DropdownMenuContent align="end" className="w-52">
                          <DropdownMenuItem asChild>
                            <Link to={`/users/${u.id}`}><Eye /> Xem chi tiết</Link>
                          </DropdownMenuItem>
                          <DropdownMenuSeparator />
                          <DropdownMenuItem onClick={() => toggleRole(u)}>
                            {u.role === 'USER' ? <><ShieldCheck /> Cấp quyền quản trị</> : <><ShieldOff /> Hạ quyền quản trị</>}
                          </DropdownMenuItem>
                          <DropdownMenuItem variant={u.status === 'ACTIVE' ? 'destructive' : 'default'} onClick={() => toggleLock(u)}>
                            {u.status === 'ACTIVE' ? <><Lock /> Khóa tài khoản</> : <><Unlock /> Mở khóa</>}
                          </DropdownMenuItem>
                        </DropdownMenuContent>
                      </DropdownMenu>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </div>
        )}
        {data && data.total > 0 && <Pagination page={page} limit={LIMIT} total={data.total} onChange={(p) => set({ page: p })} />}
      </Card>
      {dialog}
    </>
  )
}
