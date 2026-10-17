import { useEffect, useState, type FormEvent } from 'react'
import { Link, useLocation, useNavigate } from 'react-router'
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { ArrowLeft, ChevronLeft, ChevronRight, Megaphone, Send, Signal, Sparkles, Users, Wifi } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Card, CardHeader } from '@/components/ui/card'
import { Field, Input, Textarea } from '@/components/ui/input'
import { notify } from '@/components/ui/sonner'
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table'
import { Tabs, TabsList, TabsTrigger } from '@/components/ui/tabs'
import { Bubble } from '@/components/CategoryIcon'
import { ErrorState, PageHeader, TableSkeleton } from '@/components/common'
import { ConfirmDialog, type ConfirmOptions } from '@/components/ConfirmDialog'
import { api, type Broadcast } from '@/lib/api'
import { formatDayMonth, formatNumber, formatTime } from '@/lib/format'
import { cn } from '@/lib/utils'

/** Giới hạn của backend (BroadcastDto) */
const TITLE_MAX = 120
const BODY_MAX = 2000
const DRAFT_KEY = 'admin.broadcastDraft'
const PAGE = 5

type Draft = { title: string; body: string; savedAt?: number }
const loadDraft = (): Draft => {
  try {
    return JSON.parse(localStorage.getItem(DRAFT_KEY) ?? '') as Draft
  } catch {
    return { title: '', body: '' }
  }
}

/** Một thông báo trong danh sách "Thông báo" của app (dùng cho xem trước). */
function NoticeCard({ title, body, meta, highlight, dim }: { title: string; body: string; meta: string; highlight?: boolean; dim?: boolean }) {
  return (
    <div className={cn('rounded-[16px] border border-border bg-card px-3.5 py-3', highlight && 'shadow-[0_0_0_2px_var(--color-primary)]', dim && 'opacity-55')}>
      <div className="flex gap-2.5">
        <Bubble size="sm"><Megaphone /></Bubble>
        <div className="min-w-0 flex-1">
          <p className={cn('text-[13px] leading-[1.4] font-semibold break-words', !title && 'text-faint')}>{title || 'Tiêu đề thông báo'}</p>
          <p className={cn('mt-0.5 line-clamp-6 text-xs leading-normal break-words text-muted-foreground', !body && 'text-faint')}>{body || 'Nội dung thông báo hiển thị ở đây.'}</p>
          <p className="mt-1 text-[11px] text-faint">{meta}</p>
        </div>
      </div>
    </div>
  )
}

/** Điện thoại thu nhỏ: màn "Thông báo" trong app hoặc banner đẩy trên màn khóa. */
function PhonePreview({ mode, title, body, previous }: { mode: 'app' | 'push'; title: string; body: string; previous?: Broadcast }) {
  const now = new Date()
  return (
    <div
      className="relative h-[480px] w-[300px] overflow-hidden rounded-[40px] bg-background text-[13px] shadow-[0_0_0_8px_#fff,0_0_0_9px_var(--color-border),var(--shadow-pop)]"
      data-testid="phone-preview"
    >
      <div className="flex h-10 items-center justify-between pt-1.5 pr-[26px] pl-[30px] text-[13px] font-semibold">
        <span className="tabular-nums">{formatTime(now)}</span>
        <span className="absolute top-[9px] left-1/2 h-[26px] w-[92px] -translate-x-1/2 rounded-[14px] bg-[#0b0b0b]" />
        <span className="flex items-center gap-1 [&_svg]:size-3.5"><Signal /><Wifi /></span>
      </div>
      {mode === 'app' ? (
        <div className="px-4 pt-1.5">
          <div className="flex h-9 items-center justify-between"><ChevronLeft className="size-[18px]" /><span className="text-[12.5px] font-semibold">Đọc hết</span></div>
          <p className="mt-1 text-2xl leading-[1.25] font-bold tracking-[-0.025em]">Thông báo</p>
          <p className="mx-1 mt-3.5 mb-2 text-xs font-semibold text-muted-foreground">Hôm nay</p>
          <NoticeCard title={title} body={body} meta="Vừa xong · Từ đội ngũ Thu Chi" highlight />
          {previous && (
            <>
              <p className="mx-1 mt-3.5 mb-2 text-xs font-semibold text-muted-foreground">Trước đó</p>
              <NoticeCard title={previous.title} body={previous.body} meta={`${formatDayMonth(previous.createdAt)} · Từ đội ngũ Thu Chi`} dim />
            </>
          )}
        </div>
      ) : (
        <div className="px-3 pt-10 text-center">
          <p className="text-[56px] leading-none font-semibold tracking-[-0.03em] tabular-nums">{formatTime(now)}</p>
          <div className="mt-8 rounded-[18px] border border-border bg-card/90 p-3 text-left shadow-card">
            <div className="flex items-center gap-2 text-[11px] text-muted-foreground">
              <span className="flex size-5 items-center justify-center rounded-[6px] bg-primary text-[11px] font-bold text-primary-foreground underline decoration-1 underline-offset-2">đ</span>
              THU CHI<span className="ml-auto">bây giờ</span>
            </div>
            <p className={cn('mt-2 text-[13px] font-semibold break-words', !title && 'text-faint')}>{title || 'Tiêu đề thông báo'}</p>
            <p className={cn('mt-0.5 line-clamp-4 text-xs leading-normal break-words text-muted-foreground', !body && 'text-faint')}>{body || 'Nội dung thông báo hiển thị ở đây.'}</p>
          </div>
        </div>
      )}
    </div>
  )
}

/** Nháp do Trợ lý AI soạn (A10 → A7): gửi bằng xác nhận nháp để trợ lý ghi nhận chấp nhận / sửa. */
type AiDraftState = { id: string; conversationId: string; title: string; body: string }

export default function BroadcastsPage() {
  const qc = useQueryClient()
  const location = useLocation()
  const navigate = useNavigate()
  const [aiDraft, setAiDraft] = useState<AiDraftState | null>(() => (location.state as { aiDraft?: AiDraftState } | null)?.aiDraft ?? null)
  const [draft, setDraft] = useState<Draft>(() => (aiDraft ? { title: aiDraft.title.slice(0, TITLE_MAX), body: aiDraft.body.slice(0, BODY_MAX) } : loadDraft()))
  // Bỏ state khỏi lịch sử để tải lại trang không điền lại nháp đã gửi
  useEffect(() => {
    if ((location.state as { aiDraft?: unknown } | null)?.aiDraft) navigate(location.pathname, { replace: true, state: null })
  }, []) // eslint-disable-line react-hooks/exhaustive-deps
  const [errors, setErrors] = useState<{ title?: string; body?: string }>({})
  const [mode, setMode] = useState<'app' | 'push'>('app')
  const [confirm, setConfirm] = useState<ConfirmOptions | null>(null)
  const [expanded, setExpanded] = useState(false)

  const overview = useQuery({ queryKey: ['overview'], queryFn: api.overview })
  const history = useQuery({ queryKey: ['broadcasts', expanded], queryFn: () => api.broadcasts({ limit: expanded ? 100 : PAGE }) })

  // Bản nháp tự lưu (debounce 600ms)
  useEffect(() => {
    const t = setTimeout(() => {
      if (!draft.title && !draft.body) {
        localStorage.removeItem(DRAFT_KEY)
        if (draft.savedAt) setDraft((d) => ({ ...d, savedAt: undefined }))
        return
      }
      const saved = loadDraft()
      if (saved.title === draft.title && saved.body === draft.body) return
      const next = { ...draft, savedAt: Date.now() }
      localStorage.setItem(DRAFT_KEY, JSON.stringify(next))
      setDraft(next)
    }, 600)
    return () => clearTimeout(t)
  }, [draft])

  const send = useMutation({
    mutationFn: async () => {
      const body = { title: draft.title.trim(), body: draft.body.trim() }
      if (!aiDraft) return api.broadcast(body)
      const out = await api.aiConfirmDraft(aiDraft.id, body)
      return { ...body, recipients: (out.result as { recipients: number }).recipients }
    },
    onSuccess: (b) => {
      localStorage.removeItem(DRAFT_KEY)
      setDraft({ title: '', body: '' })
      notify.success(`Đã gửi thông báo tới ${formatNumber(b.recipients)} người`, { description: b.title, icon: <Send /> })
      qc.invalidateQueries({ queryKey: ['broadcasts'] })
      if (aiDraft) {
        qc.invalidateQueries({ queryKey: ['ai-conv', aiDraft.conversationId] })
        setAiDraft(null)
      }
    },
    onError: (e) => notify.error('Không gửi được thông báo', e.message),
  })

  const active = overview.data?.users.active
  const locked = overview.data?.users.locked ?? 0
  const submit = (e: FormEvent) => {
    e.preventDefault()
    const errs = {
      title: draft.title.trim() ? undefined : 'Nhập tiêu đề thông báo',
      body: draft.body.trim() ? undefined : 'Nhập nội dung thông báo',
    }
    setErrors(errs)
    if (errs.title || errs.body) return
    setConfirm({
      title: `Gửi thông báo tới ${active !== undefined ? formatNumber(active) : 'mọi'} người?`,
      description: 'Thông báo xuất hiện ngay trong mục “Thông báo” của app. Thông báo đã gửi không thu hồi được.',
      icon: <Send />,
      confirmText: 'Gửi thông báo',
      facts: [
        ['Tiêu đề', draft.title.trim()],
        ['Người nhận', active !== undefined ? `${formatNumber(active)} người dùng đang hoạt động` : 'Mọi người dùng đang hoạt động'],
      ],
      onConfirm: () => send.mutate(),
    })
  }

  return (
    <>
      <PageHeader title="Thông báo hệ thống" description="Gửi thông báo trong ứng dụng tới mọi người dùng" />
      <div className="grid flex-1 grid-cols-12 gap-5">
        <div className="col-span-12 flex flex-col gap-5 xl:col-span-8">
          <Card>
            <form onSubmit={submit} className="flex flex-col gap-4">
              {aiDraft && (
                <div className="-mt-1 flex items-center gap-2.5 rounded-md bg-background px-3.5 py-2.5 text-[13px] text-muted-foreground" data-testid="bc-ai-note">
                  <Sparkles className="size-4 shrink-0 text-foreground" />
                  <span className="min-w-0 flex-1">Do Trợ lý AI soạn. Sửa thoải mái trước khi gửi, trợ lý không tự gửi.</span>
                  <Link to={`/assistant/${aiDraft.conversationId}`} className="inline-flex shrink-0 items-center gap-1 font-semibold text-foreground hover:underline"><ArrowLeft className="size-3.5" />Về cuộc trò chuyện</Link>
                </div>
              )}
              <CardHeader
                title="Soạn thông báo"
                aside={draft.savedAt && <span className="text-body-s font-medium text-muted-foreground tabular-nums" data-testid="draft-saved">Bản nháp tự lưu lúc {formatTime(draft.savedAt)}</span>}
              />
              <Field label="Tiêu đề" htmlFor="bc-title" aside={`${draft.title.length}/${TITLE_MAX}`} error={errors.title}>
                <Input id="bc-title" value={draft.title} maxLength={TITLE_MAX} aria-invalid={!!errors.title} placeholder="VD: Bảo trì hệ thống tối 25/09"
                  onChange={(e) => { setDraft({ ...draft, title: e.target.value }); setErrors({ ...errors, title: undefined }) }} />
              </Field>
              <Field label="Nội dung" htmlFor="bc-body" aside={`${draft.body.length}/${BODY_MAX}`} error={errors.body}>
                <Textarea id="bc-body" rows={2} value={draft.body} maxLength={BODY_MAX} aria-invalid={!!errors.body} placeholder="Nội dung ngắn gọn, người dùng đọc trong app"
                  onChange={(e) => { setDraft({ ...draft, body: e.target.value }); setErrors({ ...errors, body: undefined }) }} />
              </Field>
              <div className="flex items-center justify-between gap-4 border-t border-line pt-4">
                <div className="flex min-w-0 items-center gap-3">
                  <Bubble size="sm"><Users /></Bubble>
                  <div className="min-w-0">
                    <p className="text-sm font-semibold tabular-nums" data-testid="bc-audience">
                      Tất cả người dùng đang hoạt động{active !== undefined && ` · ${formatNumber(active)} người`}
                    </p>
                    <p className="text-body-s text-muted-foreground tabular-nums">{formatNumber(locked)} tài khoản đã khóa sẽ không nhận</p>
                  </div>
                </div>
                <Button type="submit" disabled={send.isPending} data-testid="bc-send"><Send /> Gửi thông báo</Button>
              </div>
            </form>
          </Card>

          <Card flush className="flex-1">
            <CardHeader
              className="px-6 pt-5"
              title="Đã gửi"
              aside={
                history.data && history.data.total > PAGE && (
                  <Button variant="link" onClick={() => setExpanded((v) => !v)} data-testid="bc-toggle-all">
                    {expanded ? 'Thu gọn' : <>Xem cả {formatNumber(history.data.total)}<ChevronRight /></>}
                  </Button>
                )
              }
            />
            {history.error ? (
              <ErrorState error={history.error} onRetry={history.refetch} />
            ) : history.isPending ? (
              <TableSkeleton rows={4} />
            ) : history.data.items.length === 0 ? (
              <p className="px-6 pt-4 pb-8 text-muted-foreground" data-testid="bc-empty">Chưa gửi thông báo nào.</p>
            ) : (
              <Table className="mt-2">
                <colgroup><col /><col className="w-[150px] xl:w-[176px]" /><col className="w-[140px] xl:w-[150px]" /><col className="w-[120px] xl:w-[130px]" /></colgroup>
                <TableHeader>
                  <TableRow>
                    <TableHead>Thông báo</TableHead>
                    <TableHead>Gửi lúc</TableHead>
                    <TableHead>Người gửi</TableHead>
                    <TableHead className="text-right">Người nhận</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {history.data.items.map((b) => (
                    <TableRow key={b.id} data-testid="bc-row" data-title={b.title}>
                      <TableCell>
                        <p className="truncate font-medium">{b.title}</p>
                        <p className="truncate text-body-s text-muted-foreground">{b.body}</p>
                      </TableCell>
                      <TableCell className="text-[13.5px] tabular-nums">{formatDayMonth(b.createdAt)} <span className="text-muted-foreground">· {formatTime(b.createdAt)}</span></TableCell>
                      <TableCell className="text-muted-foreground">{b.createdBy?.name ?? 'Quản trị viên'}</TableCell>
                      <TableCell className="pr-4 text-right" title={`${formatNumber(b.readCount)} người đã đọc`}>
                        <span className="font-semibold tabular-nums" data-testid="bc-recipients">{formatNumber(b.recipients)}</span> <span className="text-body-s text-faint">người</span>
                      </TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            )}
          </Card>
        </div>

        <Card className="col-span-12 flex flex-col items-center bg-background shadow-none xl:col-span-4">
          <div className="flex w-full items-center justify-between">
            <h2 className="text-title-m">Xem trước</h2>
            <Tabs value={mode} onValueChange={(v) => setMode(v as 'app' | 'push')}>
              <TabsList size="sm">
                <TabsTrigger value="app">Trong app</TabsTrigger>
                <TabsTrigger value="push">Đẩy</TabsTrigger>
              </TabsList>
            </Tabs>
          </div>
          <div className="mt-7">
            <PhonePreview mode={mode} title={draft.title.trim()} body={draft.body.trim()} previous={history.data?.items[0]} />
          </div>
          <p className="mt-5 max-w-[320px] text-center text-body-s text-muted-foreground">Hiển thị giống mục “Thông báo” trong app. Thông báo đã gửi không thu hồi được.</p>
        </Card>
      </div>
      <ConfirmDialog options={confirm} onClose={() => setConfirm(null)} />
    </>
  )
}
