import { useState, type FormEvent } from 'react'
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { toast } from 'sonner'
import { AlertCircle, Archive, ArchiveRestore, Loader2, Pencil, Plus, Trash2 } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Card, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle } from '@/components/ui/dialog'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table'
import { Tabs, TabsList, TabsTrigger } from '@/components/ui/tabs'
import { Tooltip, TooltipContent, TooltipTrigger } from '@/components/ui/tooltip'
import { EmptyState, ErrorState, PageHeader, TableSkeleton } from '@/components/common'
import { CATEGORY_ICONS, CategoryIcon } from '@/components/CategoryIcon'
import { ConfirmDialog, type ConfirmOptions } from '@/components/ConfirmDialog'
import { api, type SystemCategory, type TxType } from '@/lib/api'
import { formatNumber } from '@/lib/format'
import { cn } from '@/lib/utils'

const COLORS = ['#16A34A', '#0EA5E9', '#3B82F6', '#8B5CF6', '#A855F7', '#EC4899', '#F43F5E', '#EF4444', '#F97316', '#EAB308', '#14B8A6', '#64748B']
const HEX = /^#[0-9a-fA-F]{6}$/

type FormState = { id?: string; name: string; icon: string; color: string }

export default function CategoriesPage() {
  const qc = useQueryClient()
  const [type, setType] = useState<TxType>('EXPENSE')
  const [form, setForm] = useState<FormState | null>(null)
  const [confirm, setConfirm] = useState<ConfirmOptions | null>(null)
  const { data, isPending, error, refetch } = useQuery({ queryKey: ['categories'], queryFn: () => api.categories() })

  const invalidate = () => qc.invalidateQueries({ queryKey: ['categories'] })
  const remove = useMutation({
    mutationFn: (c: SystemCategory) => api.deleteCategory(c.id),
    onSuccess: (r, c) => {
      toast.success(r.archived ? `Đã lưu trữ "${c.name}" vì danh mục đang có giao dịch` : `Đã xóa vĩnh viễn "${c.name}"`)
      invalidate()
    },
    onError: (e) => toast.error(e.message),
  })
  const restore = useMutation({
    mutationFn: (c: SystemCategory) => api.restoreCategory(c.id),
    onSuccess: (_, c) => {
      toast.success(`Đã khôi phục "${c.name}"`)
      invalidate()
    },
    onError: (e) => toast.error(e.message),
  })

  const list = (data?.filter((c) => c.type === type) ?? []).sort((a, b) => a.name.localeCompare(b.name, 'vi'))
  const active = list.filter((c) => !c.isArchived)
  const archived = list.filter((c) => c.isArchived)
  const countOf = (t: TxType) => data?.filter((c) => c.type === t && !c.isArchived).length ?? 0

  const askDelete = (c: SystemCategory) =>
    setConfirm({
      title: `Xóa danh mục "${c.name}"?`,
      description:
        c._count.transactions > 0
          ? `Danh mục đang được dùng trong ${formatNumber(c._count.transactions)} giao dịch nên sẽ được LƯU TRỮ (ẩn với người dùng, giữ nguyên lịch sử). Bạn có thể khôi phục sau.`
          : 'Danh mục chưa có giao dịch nào nên sẽ bị xóa vĩnh viễn.',
      confirmText: c._count.transactions > 0 ? 'Lưu trữ' : 'Xóa vĩnh viễn',
      destructive: true,
      onConfirm: () => remove.mutate(c),
    })

  return (
    <>
      <PageHeader
        title="Danh mục hệ thống"
        description="Danh mục dùng chung cho mọi người dùng"
        actions={
          <Button onClick={() => setForm({ name: '', icon: 'ellipsis', color: COLORS[0] })} data-testid="cat-create">
            <Plus /> Thêm danh mục
          </Button>
        }
      />
      <Tabs value={type} onValueChange={(v) => setType(v as TxType)} className="mb-4">
        <TabsList>
          <TabsTrigger value="EXPENSE" className="px-4" data-testid="tab-expense">Chi <span className="text-muted-foreground">({countOf('EXPENSE')})</span></TabsTrigger>
          <TabsTrigger value="INCOME" className="px-4" data-testid="tab-income">Thu <span className="text-muted-foreground">({countOf('INCOME')})</span></TabsTrigger>
        </TabsList>
      </Tabs>

      <Card className="gap-0 py-0">
        {error ? (
          <ErrorState error={error} onRetry={refetch} />
        ) : isPending ? (
          <TableSkeleton cols={4} />
        ) : active.length === 0 ? (
          <EmptyState title="Chưa có danh mục" description="Bấm “Thêm danh mục” để tạo mới." />
        ) : (
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead className="pl-4">Danh mục</TableHead>
                <TableHead>Icon</TableHead>
                <TableHead>Màu</TableHead>
                <TableHead className="text-right">Đang dùng</TableHead>
                <TableHead className="w-24 pr-4" />
              </TableRow>
            </TableHeader>
            <TableBody>
              {active.map((c) => (
                <TableRow key={c.id} data-testid="cat-row" data-name={c.name}>
                  <TableCell className="pl-4">
                    <div className="flex items-center gap-3">
                      <CategoryIcon icon={c.icon} color={c.color} />
                      <span className="font-medium">{c.name}</span>
                    </div>
                  </TableCell>
                  <TableCell className="font-mono text-xs text-muted-foreground">{c.icon}</TableCell>
                  <TableCell>
                    <span className="inline-flex items-center gap-2 font-mono text-xs uppercase">
                      <span className="size-4 rounded border" style={{ backgroundColor: c.color }} />
                      {c.color}
                    </span>
                  </TableCell>
                  <TableCell className="text-right tabular-nums" data-testid="cat-usage">{formatNumber(c._count.transactions)} giao dịch</TableCell>
                  <TableCell className="pr-4">
                    <div className="flex justify-end gap-1">
                      <Tooltip>
                        <TooltipTrigger asChild>
                          <Button variant="ghost" size="icon-sm" aria-label="Sửa" data-testid="cat-edit" onClick={() => setForm({ id: c.id, name: c.name, icon: c.icon, color: c.color })}>
                            <Pencil />
                          </Button>
                        </TooltipTrigger>
                        <TooltipContent>Sửa</TooltipContent>
                      </Tooltip>
                      <Tooltip>
                        <TooltipTrigger asChild>
                          <Button variant="ghost" size="icon-sm" aria-label="Xóa" data-testid="cat-delete" className="text-destructive hover:bg-destructive/10 hover:text-destructive" onClick={() => askDelete(c)}>
                            <Trash2 />
                          </Button>
                        </TooltipTrigger>
                        <TooltipContent>{c._count.transactions > 0 ? 'Lưu trữ' : 'Xóa'}</TooltipContent>
                      </Tooltip>
                    </div>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        )}
      </Card>

      {archived.length > 0 && (
        <Card className="mt-6 gap-0 py-0" data-testid="archived-section">
          <CardHeader className="border-b py-4">
            <CardTitle className="flex items-center gap-2"><Archive className="size-4 text-muted-foreground" /> Đã lưu trữ</CardTitle>
            <CardDescription>Ẩn với người dùng nhưng vẫn giữ lịch sử giao dịch</CardDescription>
          </CardHeader>
          <Table>
            <TableBody>
              {archived.map((c) => (
                <TableRow key={c.id} data-testid="archived-row" data-name={c.name}>
                  <TableCell className="pl-4">
                    <div className="flex items-center gap-3 opacity-70">
                      <CategoryIcon icon={c.icon} color={c.color} />
                      <span className="font-medium">{c.name}</span>
                    </div>
                  </TableCell>
                  <TableCell className="text-right text-muted-foreground tabular-nums">{formatNumber(c._count.transactions)} giao dịch</TableCell>
                  <TableCell className="w-32 pr-4 text-right">
                    <Button variant="outline" size="sm" disabled={restore.isPending} onClick={() => restore.mutate(c)} data-testid="cat-restore">
                      <ArchiveRestore /> Khôi phục
                    </Button>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </Card>
      )}

      <CategoryForm type={type} value={form} onClose={() => setForm(null)} onSaved={invalidate} />
      <ConfirmDialog options={confirm} onClose={() => setConfirm(null)} />
    </>
  )
}

function CategoryForm({ type, value, onClose, onSaved }: { type: TxType; value: FormState | null; onClose: () => void; onSaved: () => void }) {
  return (
    <Dialog open={!!value} onOpenChange={(o) => !o && onClose()}>
      <DialogContent className="sm:max-w-lg">
        {value && <CategoryFormBody key={value.id ?? 'new'} type={type} initial={value} onClose={onClose} onSaved={onSaved} />}
      </DialogContent>
    </Dialog>
  )
}

function CategoryFormBody({ type, initial, onClose, onSaved }: { type: TxType; initial: FormState; onClose: () => void; onSaved: () => void }) {
  const [f, setF] = useState(initial)
  const [error, setError] = useState<string | null>(null)
  const editing = !!initial.id
  const save = useMutation({
    mutationFn: () => {
      const body = { name: f.name.trim(), icon: f.icon, color: f.color.toUpperCase() }
      return editing ? api.updateCategory(initial.id!, body) : api.createCategory({ ...body, type })
    },
    onSuccess: (c) => {
      toast.success(editing ? `Đã cập nhật "${c.name}"` : `Đã tạo danh mục "${c.name}"`)
      onSaved()
      onClose()
    },
    onError: (e) => setError(e.message),
  })
  const submit = (e: FormEvent) => {
    e.preventDefault()
    setError(null)
    if (!f.name.trim()) return setError('Vui lòng nhập tên danh mục')
    if (!HEX.test(f.color)) return setError('Màu phải có dạng #RRGGBB')
    save.mutate()
  }

  return (
    <form onSubmit={submit} className="grid gap-5">
      <DialogHeader>
        <DialogTitle>{editing ? 'Sửa danh mục' : `Thêm danh mục ${type === 'INCOME' ? 'thu' : 'chi'}`}</DialogTitle>
        <DialogDescription>Danh mục hệ thống hiển thị cho tất cả người dùng.</DialogDescription>
      </DialogHeader>

      {error && (
        <div role="alert" data-testid="cat-form-error" className="flex gap-2 rounded-lg border border-destructive/20 bg-destructive/5 p-3 text-sm text-destructive">
          <AlertCircle className="mt-0.5 size-4 shrink-0" /> {error}
        </div>
      )}

      <div className="flex items-end gap-3">
        <CategoryIcon icon={f.icon} color={HEX.test(f.color) ? f.color : '#64748B'} className="size-10" />
        <div className="grid flex-1 gap-2">
          <Label htmlFor="cat-name">Tên danh mục</Label>
          <Input id="cat-name" value={f.name} maxLength={50} autoFocus onChange={(e) => setF({ ...f, name: e.target.value })} placeholder="VD: Cà phê" />
        </div>
      </div>

      <div className="grid gap-2">
        <Label>Icon <span className="font-mono text-xs font-normal text-muted-foreground">({f.icon})</span></Label>
        <div className="grid max-h-40 grid-cols-9 gap-1.5 overflow-y-auto rounded-lg border p-2" data-testid="icon-grid">
          {Object.entries(CATEGORY_ICONS).map(([name, Icon]) => (
            <button
              key={name}
              type="button"
              title={name}
              aria-label={name}
              aria-pressed={f.icon === name}
              onClick={() => setF({ ...f, icon: name })}
              className={cn(
                'flex aspect-square items-center justify-center rounded-md text-muted-foreground transition-colors hover:bg-muted hover:text-foreground',
                f.icon === name && 'bg-primary/10 text-primary ring-2 ring-primary',
              )}
            >
              <Icon className="size-4" />
            </button>
          ))}
        </div>
      </div>

      <div className="grid gap-2">
        <Label htmlFor="cat-color">Màu</Label>
        <div className="flex flex-wrap items-center gap-2">
          {COLORS.map((c) => (
            <button
              key={c}
              type="button"
              aria-label={c}
              onClick={() => setF({ ...f, color: c })}
              className={cn('size-7 rounded-full ring-offset-2 transition', f.color.toUpperCase() === c && 'ring-2 ring-foreground/60')}
              style={{ backgroundColor: c }}
            />
          ))}
          <label className="relative size-7 cursor-pointer overflow-hidden rounded-full border bg-[conic-gradient(red,yellow,lime,aqua,blue,magenta,red)]" title="Chọn màu khác">
            <input type="color" className="absolute inset-0 cursor-pointer opacity-0" value={HEX.test(f.color) ? f.color : '#64748B'} onChange={(e) => setF({ ...f, color: e.target.value.toUpperCase() })} />
          </label>
          <Input id="cat-color" value={f.color} onChange={(e) => setF({ ...f, color: e.target.value })} className="ml-auto w-28 font-mono uppercase" maxLength={7} />
        </div>
      </div>

      <DialogFooter>
        <Button type="button" variant="outline" onClick={onClose}>Hủy</Button>
        <Button type="submit" disabled={save.isPending} data-testid="cat-save">
          {save.isPending && <Loader2 className="animate-spin" />} {editing ? 'Lưu thay đổi' : 'Tạo danh mục'}
        </Button>
      </DialogFooter>
    </form>
  )
}
