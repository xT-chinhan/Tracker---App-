import { useEffect, useState } from 'react'
import { Link } from 'react-router'
import { keepPreviousData, useQuery } from '@tanstack/react-query'
import { Ellipsis, Lock, LockOpen, Search, ShieldCheck, ShieldOff, UserRound } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Card } from '@/components/ui/card'
import {
  DropdownMenu, DropdownMenuContent, DropdownMenuItem, DropdownMenuLabel, DropdownMenuSeparator, DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu'
import { Input } from '@/components/ui/input'
import { Select, SelectContent, SelectItem, SelectTrigger } from '@/components/ui/select'
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table'
import { Chip, EmptyState, ErrorState, PageHeader, Pagination, RoleBadge, StatusBadge, TableSkeleton, UserBubble } from '@/components/common'
import { useUserActions } from '@/components/useUserActions'
import { api, auth, type Role, type UserStatus } from '@/lib/api'
import { formatDate, formatDayMonth, formatNumber, ROLE_LABEL } from '@/lib/format'
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
  const overview = useQuery({ queryKey: ['overview'], queryFn: api.overview })
  const counts = overview.data?.users
  const { toggleLock, toggleRole, dialog } = useUserActions()
  const meId = auth.user()?.id
  const filtered = !!(values.q || values.status || values.role)

  return (
    <>
      <PageHeader
        title="Người dùng"
        description={
          filtered
            ? data && `${formatNumber(data.total)} tài khoản phù hợp`
            : counts && `${formatNumber(counts.total)} tài khoản · ${formatNumber(counts.active)} hoạt động · ${formatNumber(counts.locked)} đã khóa`
        }
      />
      <div className="flex items-center gap-2.5">
        <Input
          wrapperClassName="w-[260px] shrink-0 xl:w-[340px]"
          icon={<Search />}
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          placeholder="Tìm theo tên hoặc email"
          aria-label="Tìm người dùng"
          data-testid="users-search"
        />
        <Select value={values.role || 'all'} onValueChange={(v) => set({ role: v })}>
          <SelectTrigger label="Vai trò" className="w-[168px] xl:w-[184px]" data-testid="filter-role">
            {values.role ? ROLE_LABEL[values.role as Role] : 'Tất cả'}
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="all">Tất cả</SelectItem>
            <SelectItem value="USER">Người dùng</SelectItem>
            <SelectItem value="ADMIN">Quản trị</SelectItem>
          </SelectContent>
        </Select>
        <div className="flex gap-2 xl:ml-1.5" role="group" aria-label="Trạng thái" data-testid="filter-status">
          <Chip on={!values.status} onClick={() => set({ status: '' })}>Tất cả</Chip>
          <Chip on={values.status === 'ACTIVE'} onClick={() => set({ status: 'ACTIVE' })}>
            Hoạt động {counts && <span className="c text-faint tabular-nums">{formatNumber(counts.active)}</span>}
          </Chip>
          <Chip on={values.status === 'LOCKED'} onClick={() => set({ status: 'LOCKED' })}>
            Đã khóa {counts && <span className="c text-faint tabular-nums">{formatNumber(counts.locked)}</span>}
          </Chip>
        </div>
      </div>

      <Card flush>
        {error ? (
          <ErrorState error={error} onRetry={refetch} />
        ) : isPending ? (
          <TableSkeleton rows={10} />
        ) : data.items.length === 0 ? (
          <EmptyState
            title="Không tìm thấy người dùng"
            description="Không có tài khoản nào khớp từ khóa và bộ lọc hiện tại."
            action={{ label: 'Xóa bộ lọc', onClick: () => { setSearch(''); set({ q: '', status: '', role: '' }) } }}
          />
        ) : (
          <div className={isFetching ? 'opacity-60 transition-opacity' : 'transition-opacity'}>
            <Table>
              <colgroup>
                <col />
                <col className="w-[132px] xl:w-[150px]" />
                <col className="w-[134px] xl:w-[150px]" />
                <col className="w-[100px] xl:w-[120px]" />
                <col className="hidden w-[110px] xl:table-column" />
                <col className="hidden w-[150px] xl:table-column" />
                <col className="w-[76px] xl:w-[72px]" />
              </colgroup>
              <TableHeader>
                <TableRow>
                  <TableHead>Người dùng</TableHead>
                  <TableHead>Vai trò</TableHead>
                  <TableHead>Trạng thái</TableHead>
                  <TableHead className="text-right">Giao dịch</TableHead>
                  <TableHead className="hidden text-right xl:table-cell">Mục tiêu</TableHead>
                  <TableHead className="hidden xl:table-cell">Ngày tham gia</TableHead>
                  <TableHead><span className="sr-only">Thao tác</span></TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {data.items.map((u) => (
                  <TableRow key={u.id} data-testid="user-row" data-email={u.email}>
                    <TableCell>
                      <Link to={`/users/${u.id}`} className="flex min-w-0 items-center gap-3">
                        <UserBubble name={u.name} />
                        <div className="min-w-0">
                          <p className="truncate text-body-l font-medium">
                            {u.name}
                            {u.id === meId && <span className="ml-1.5 text-xs font-normal text-muted-foreground">(bạn)</span>}
                          </p>
                          <p className="truncate text-body-s text-muted-foreground">
                            {u.email}
                            <span className="tabular-nums xl:hidden"> · {formatDayMonth(u.createdAt)}</span>
                          </p>
                        </div>
                      </Link>
                    </TableCell>
                    <TableCell><RoleBadge role={u.role} /></TableCell>
                    <TableCell><StatusBadge status={u.status} /></TableCell>
                    <TableCell className="text-right tabular-nums">{formatNumber(u._count.transactions)}</TableCell>
                    <TableCell className="hidden text-right tabular-nums xl:table-cell">{formatNumber(u._count.savingGoals)}</TableCell>
                    <TableCell className="hidden text-muted-foreground tabular-nums xl:table-cell">{formatDate(u.createdAt)}</TableCell>
                    <TableCell className="pr-4 text-right">
                      <DropdownMenu>
                        <DropdownMenuTrigger asChild>
                          <Button variant="ghost" size="icon" aria-label="Thao tác" data-testid="user-actions"><Ellipsis /></Button>
                        </DropdownMenuTrigger>
                        <DropdownMenuContent align="end" sideOffset={4}>
                          <DropdownMenuLabel>{u.name}</DropdownMenuLabel>
                          <DropdownMenuItem asChild>
                            <Link to={`/users/${u.id}`}><UserRound /> Xem chi tiết</Link>
                          </DropdownMenuItem>
                          <DropdownMenuItem onClick={() => toggleRole(u)}>
                            {u.role === 'USER' ? <><ShieldCheck /> Cấp quyền quản trị</> : <><ShieldOff /> Hạ quyền quản trị</>}
                          </DropdownMenuItem>
                          <DropdownMenuSeparator />
                          <DropdownMenuItem variant={u.status === 'ACTIVE' ? 'destructive' : 'default'} onClick={() => toggleLock(u)}>
                            {u.status === 'ACTIVE' ? <><Lock /> Khóa tài khoản</> : <><LockOpen /> Mở khóa</>}
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
