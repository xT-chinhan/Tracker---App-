import { useState, type FormEvent } from 'react'
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { Archive, ArchiveRestore, Check, Pencil, Plus, Search, Shapes, Trash2, X } from 'lucide-react'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { Card } from '@/components/ui/card'
import { Field, Input } from '@/components/ui/input'
import { notify } from '@/components/ui/sonner'
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table'
import { Tabs, TabsList, TabsTrigger } from '@/components/ui/tabs'
import { Bubble, CATEGORY_ICONS, CategoryIcon, Swatch } from '@/components/CategoryIcon'
import { ErrorState, PageHeader, TableSkeleton } from '@/components/common'
import { ConfirmDialog, type ConfirmOptions } from '@/components/ConfirmDialog'
import { api, type SystemCategory, type TxType } from '@/lib/api'
import { formatNumber, TYPE_LABEL } from '@/lib/format'
import { cn } from '@/lib/utils'

const COLORS = ['#16A34A', '#0EA5E9', '#3B82F6', '#8B5CF6', '#A855F7', '#EC4899', '#F43F5E', '#EF4444', '#F97316', '#EAB308', '#14B8A6', '#64748B']

type FormState = { id?: string; name: string; icon: string; color: string; type: TxType; usage: number }

function Usage({ n }: { n: number }) {
  return <><span data-testid="cat-usage-n">{formatNumber(n)}</span> <span className="text-body-s text-faint">giao dịch</span></>
}

export default function CategoriesPage() {
  const qc = useQueryClient()
  const [type, setType] = useState<TxType>('EXPENSE')
  const [search, setSearch] = useState('')
  const [form, setForm] = useState<FormState | null>(null)
  const [confirm, setConfirm] = useState<ConfirmOptions | null>(null)
  const { data, isPending, error, refetch } = useQuery({ queryKey: ['categories'], queryFn: () => api.categories() })

  const invalidate = () => qc.invalidateQueries({ queryKey: ['categories'] })
  const restore = useMutation({
    mutationFn: (c: SystemCategory) => api.restoreCategory(c.id),
    onSuccess: (_, c) => {
      notify.success(`Đã khôi phục "${c.name}"`, { description: 'Người dùng lại thấy danh mục này trong app.', icon: <ArchiveRestore /> })
      invalidate()
    },
    onError: (e) => notify.error('Không khôi phục được danh mục', e.message),
  })
  const remove = useMutation({
    mutationFn: (c: SystemCategory) => api.deleteCategory(c.id),
    onSuccess: (r, c) => {
      if (form?.id === c.id) setForm(null)
      if (r.archived) {
        notify.success(`Đã lưu trữ "${c.name}" vì danh mục đang có giao dịch`, {
          description: 'Ẩn với người dùng, giao dịch cũ vẫn giữ danh mục.',
          icon: <Archive />,
          undo: () => restore.mutate(c),
        })
      } else {
        notify.success(`Đã xóa vĩnh viễn "${c.name}"`, { icon: <Trash2 /> })
      }
      invalidate()
    },
    onError: (e) => notify.error('Không xóa được danh mục', e.message),
  })

  // Backend đã xếp theo tên tiếng Việt (Ă sau A, Đ sau D…), giữ nguyên thứ tự.
  const active = data?.filter((c) => c.type === type && !c.isArchived && c.name.toLowerCase().includes(search.trim().toLowerCase())) ?? []
  const archived = data?.filter((c) => c.isArchived) ?? []
  const countOf = (t: TxType) => data?.filter((c) => c.type === t && !c.isArchived).length ?? 0

  const askDelete = (c: SystemCategory) => {
    const used = c._count.transactions > 0
    setConfirm({
      title: used ? `Lưu trữ "${c.name}"?` : `Xóa danh mục "${c.name}"?`,
      description: used
        ? `Danh mục đang được dùng trong ${formatNumber(c._count.transactions)} giao dịch nên sẽ được lưu trữ: ẩn với người dùng, giao dịch cũ vẫn giữ danh mục. Bạn khôi phục được bất cứ lúc nào.`
        : 'Danh mục chưa có giao dịch nào nên sẽ bị xóa vĩnh viễn.',
      icon: used ? <Archive /> : <Trash2 />,
      destructive: true,
      confirmText: used ? 'Lưu trữ' : 'Xóa vĩnh viễn',
      facts: [['Loại', TYPE_LABEL[c.type]], ['Đang dùng', `${formatNumber(c._count.transactions)} giao dịch`]],
      onConfirm: () => remove.mutate(c),
    })
  }
  const edit = (c: SystemCategory) => setForm({ id: c.id, name: c.name, icon: c.icon, color: c.color, type: c.type, usage: c._count.transactions })

  return (
    <>
      <PageHeader
        title="Danh mục hệ thống"
        description="Dùng chung cho mọi người dùng. Người dùng vẫn tạo được danh mục riêng trong app."
        actions={
          <Button onClick={() => setForm({ name: '', icon: 'ellipsis', color: COLORS[0], type, usage: 0 })} data-testid="cat-create">
            <Plus /> Thêm danh mục
          </Button>
        }
      />
      <div className="grid grid-cols-[1fr_340px] items-start gap-5 xl:grid-cols-[1fr_400px]">
        <div className="flex min-w-0 flex-col gap-5">
          <Card flush>
            <div className="flex items-center justify-between gap-3 pt-4 pr-4 pl-6">
              <Tabs value={type} onValueChange={(v) => setType(v as TxType)}>
                <TabsList>
                  <TabsTrigger value="EXPENSE" data-testid="tab-expense">Chi <span className="font-medium text-faint tabular-nums">{countOf('EXPENSE')}</span></TabsTrigger>
                  <TabsTrigger value="INCOME" data-testid="tab-income">Thu <span className="font-medium text-faint tabular-nums">{countOf('INCOME')}</span></TabsTrigger>
                </TabsList>
              </Tabs>
              <Input wrapperClassName="w-[200px] xl:w-[240px]" icon={<Search />} placeholder="Tìm danh mục" aria-label="Tìm danh mục" value={search} onChange={(e) => setSearch(e.target.value)} />
            </div>
            {error ? (
              <ErrorState error={error} onRetry={refetch} />
            ) : isPending ? (
              <TableSkeleton rows={9} />
            ) : active.length === 0 ? (
              <p className="px-6 py-10 text-center text-muted-foreground" data-testid="empty">
                {search ? `Không có danh mục nào tên chứa “${search.trim()}”.` : 'Chưa có danh mục. Bấm “Thêm danh mục” để tạo mới.'}
              </p>
            ) : (
              <Table compact className="mt-2">
                <CatCols />
                <TableHeader>
                  <TableRow>
                    <TableHead>Danh mục</TableHead>
                    <TableHead>Màu biểu đồ</TableHead>
                    <TableHead className="text-right">Đang dùng</TableHead>
                    <TableHead><span className="sr-only">Thao tác</span></TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {active.map((c) => {
                    const on = form?.id === c.id
                    return (
                      <TableRow key={c.id} data-testid="cat-row" data-name={c.name} data-icon={c.icon} className={cn(on && '[&>td]:bg-hover')}>
                        <TableCell>
                          <div className="flex min-w-0 items-center gap-3">
                            <CategoryIcon icon={c.icon} />
                            <span className="truncate font-medium">{c.name}</span>
                          </div>
                        </TableCell>
                        <TableCell>
                          <span className="flex items-center gap-2"><Swatch color={c.color} /><span className="hidden text-[13px] text-muted-foreground tabular-nums xl:inline" data-testid="cat-color">{c.color.toUpperCase()}</span></span>
                        </TableCell>
                        <TableCell className="text-right tabular-nums" data-testid="cat-usage"><Usage n={c._count.transactions} /></TableCell>
                        <TableCell className="pr-4 text-right">
                          <Button variant="ghost" size="icon" aria-label="Sửa" title="Sửa" aria-expanded={on} data-testid="cat-edit" onClick={() => edit(c)}><Pencil className="size-4" /></Button>
                          <Button
                            variant="ghost"
                            size="icon"
                            aria-label={c._count.transactions > 0 ? 'Lưu trữ' : 'Xóa'}
                            title={c._count.transactions > 0 ? 'Lưu trữ' : 'Xóa'}
                            data-testid="cat-delete"
                            onClick={() => askDelete(c)}
                          >
                            {c._count.transactions > 0 ? <Archive className="size-4" /> : <Trash2 className="size-4" />}
                          </Button>
                        </TableCell>
                      </TableRow>
                    )
                  })}
                </TableBody>
              </Table>
            )}
          </Card>

          {archived.length > 0 && (
            <Card flush data-testid="archived-section">
              <div className="flex items-center justify-between gap-3 px-6 pt-4">
                <h2 className="flex items-center gap-2 text-title-m"><Archive className="size-[18px] text-muted-foreground" />Đã lưu trữ <span className="font-medium text-muted-foreground">{archived.length}</span></h2>
                <span className="hidden text-body-s font-medium text-muted-foreground xl:inline">Ẩn với người dùng, giao dịch cũ vẫn giữ danh mục</span>
              </div>
              <Table compact className="mt-1">
                <CatCols />
                <TableBody>
                  {archived.map((c) => (
                    <TableRow key={c.id} data-testid="archived-row" data-name={c.name}>
                      <TableCell>
                        <div className="flex min-w-0 items-center gap-3">
                          <CategoryIcon icon={c.icon} />
                          <span className="truncate font-medium">{c.name}</span>
                          <Badge className="h-[22px]">{TYPE_LABEL[c.type]}</Badge>
                        </div>
                      </TableCell>
                      <TableCell><span className="flex items-center gap-2"><Swatch color={c.color} /><span className="hidden text-[13px] text-muted-foreground tabular-nums xl:inline">{c.color.toUpperCase()}</span></span></TableCell>
                      <TableCell className="text-right tabular-nums"><Usage n={c._count.transactions} /></TableCell>
                      <TableCell className="pr-4 text-right">
                        <Button variant="secondary" size="sm" disabled={restore.isPending} onClick={() => restore.mutate(c)} data-testid="cat-restore">
                          <ArchiveRestore /> Khôi phục
                        </Button>
                      </TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            </Card>
          )}
        </div>

        {form ? (
          <CategoryPanel key={form.id ?? `new-${form.type}`} initial={form} onClose={() => setForm(null)} onSaved={invalidate} onArchive={() => {
            const c = data?.find((x) => x.id === form.id)
            if (c) askDelete(c)
          }} />
        ) : (
          <Card className="flex flex-col items-center py-12 text-center" data-testid="cat-panel-empty">
            <Bubble size="lg"><Shapes /></Bubble>
            <p className="mt-5 text-title-m">Chọn một danh mục để sửa</p>
            <p className="mt-1.5 max-w-[260px] text-muted-foreground">Đổi tên, biểu tượng hoặc màu biểu đồ. Thay đổi áp dụng cho mọi người dùng.</p>
          </Card>
        )}
      </div>
      <ConfirmDialog options={confirm} onClose={() => setConfirm(null)} />
    </>
  )
}

function CatCols() {
  return (
    <colgroup>
      <col />
      <col className="w-[64px] xl:w-[126px]" />
      <col className="w-[132px] xl:w-[156px]" />
      <col className="w-[96px] xl:w-[160px]" />
    </colgroup>
  )
}

/** Panel bên phải: tên, loại (không đổi), biểu tượng, màu biểu đồ. */
function CategoryPanel({ initial, onClose, onSaved, onArchive }: { initial: FormState; onClose: () => void; onSaved: () => void; onArchive: () => void }) {
  const [f, setF] = useState(initial)
  const [error, setError] = useState<string | null>(null)
  const editing = !!initial.id
  const Icon = CATEGORY_ICONS[f.icon] ?? Shapes
  const palette = COLORS.includes(initial.color.toUpperCase()) ? COLORS : [initial.color.toUpperCase(), ...COLORS]
  const save = useMutation({
    mutationFn: () => {
      const body = { name: f.name.trim(), icon: f.icon, color: f.color.toUpperCase() }
      return editing ? api.updateCategory(initial.id!, body) : api.createCategory({ ...body, type: f.type })
    },
    onSuccess: (c) => {
      notify.success(editing ? `Đã cập nhật "${c.name}"` : `Đã tạo danh mục "${c.name}"`, { icon: <Check /> })
      onSaved()
      onClose()
    },
    onError: (e) => setError(e.message),
  })
  const submit = (e: FormEvent) => {
    e.preventDefault()
    setError(null)
    if (!f.name.trim()) return setError('Vui lòng nhập tên danh mục')
    save.mutate()
  }

  return (
    <Card flush className="sticky top-6 flex flex-col" role="region" aria-label={editing ? 'Sửa danh mục' : 'Thêm danh mục'} data-testid="cat-panel">
      <form onSubmit={submit} className="flex flex-1 flex-col">
        <div className="flex items-center justify-between pt-5 pr-5 pl-6">
          <h2 className="text-title-l">{editing ? 'Sửa danh mục' : `Thêm danh mục ${TYPE_LABEL[f.type].toLowerCase()}`}</h2>
          <Button type="button" variant="ghost" size="icon" aria-label="Đóng" onClick={onClose}><X /></Button>
        </div>
        <div className="flex flex-col gap-5 px-6 pt-5">
          <div className="flex items-center gap-3.5 rounded-md bg-background p-3.5">
            <Bubble size="lg"><Icon /></Bubble>
            <div className="min-w-0 flex-1">
              <p className={cn('truncate text-title-m', !f.name.trim() && 'text-faint')}>{f.name.trim() || 'Tên danh mục'}</p>
              <p className="truncate text-body-s text-muted-foreground">
                {TYPE_LABEL[f.type]} · {editing ? `${formatNumber(initial.usage)} giao dịch đang dùng` : 'danh mục mới'}
              </p>
            </div>
            <Swatch color={f.color} className="size-5 rounded-[6px]" />
          </div>
          <Field label="Tên danh mục" htmlFor="cat-name" error={error} errorTestId="cat-form-error">
            <Input id="cat-name" value={f.name} maxLength={50} autoFocus aria-invalid={!!error} onChange={(e) => setF({ ...f, name: e.target.value })} placeholder="VD: Cà phê" />
          </Field>
          <Field label="Loại">
            <div className="flex items-center gap-2.5"><Badge>{TYPE_LABEL[f.type]}</Badge><span className="text-body-s text-muted-foreground">{editing ? 'Không đổi được sau khi tạo' : 'Theo tab đang chọn, không đổi được sau khi tạo'}</span></div>
          </Field>
          <Field label="Biểu tượng">
            <div className="grid grid-cols-9 gap-1 rounded-md border border-border p-2" data-testid="icon-grid">
              {Object.entries(CATEGORY_ICONS).map(([name, I]) => (
                <button
                  key={name}
                  type="button"
                  title={name}
                  aria-label={name}
                  aria-pressed={f.icon === name}
                  onClick={() => setF({ ...f, icon: name })}
                  className={cn(
                    'mx-auto flex size-[34px] cursor-pointer items-center justify-center rounded-full text-ink-soft transition-colors hover:bg-muted',
                    f.icon === name && 'bg-primary text-primary-foreground hover:bg-primary',
                  )}
                >
                  <I className="size-[17px]" />
                </button>
              ))}
            </div>
          </Field>
          <Field label="Màu trên biểu đồ" help="Chỉ dùng để tô biểu đồ báo cáo trên app.">
            <div className="flex flex-wrap gap-[5px] px-0.5 py-1" role="radiogroup" aria-label="Màu trên biểu đồ">
              {palette.map((c) => (
                <button
                  key={c}
                  type="button"
                  role="radio"
                  aria-label={c}
                  aria-checked={f.color.toUpperCase() === c}
                  onClick={() => setF({ ...f, color: c })}
                  className={cn('size-6 cursor-pointer rounded-full', f.color.toUpperCase() === c && 'shadow-[0_0_0_2px_#fff,0_0_0_4px_#111]')}
                  style={{ backgroundColor: c }}
                />
              ))}
            </div>
          </Field>
        </div>
        <div className="mt-6 flex items-center justify-between border-t border-border px-6 pt-[18px] pb-[22px]">
          {editing ? (
            <Button type="button" variant="ghost" className="px-1.5 text-destructive hover:bg-destructive-soft hover:text-destructive" onClick={onArchive} data-testid="cat-archive">
              {initial.usage > 0 ? <><Archive /> Lưu trữ</> : <><Trash2 /> Xóa</>}
            </Button>
          ) : <span />}
          <div className="flex gap-2">
            <Button type="button" variant="secondary" onClick={onClose}>Hủy</Button>
            <Button type="submit" disabled={save.isPending} data-testid="cat-save">{editing ? 'Lưu thay đổi' : 'Tạo danh mục'}</Button>
          </div>
        </div>
      </form>
    </Card>
  )
}
