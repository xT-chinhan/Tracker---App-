import { useEffect, useMemo, useRef, useState, type FormEvent, type KeyboardEvent } from 'react'
import { Link, useNavigate, useParams } from 'react-router'
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import {
  Archive, ArchiveRestore, ArrowLeft, ArrowUp, ChevronRight, CircleDashed, Copy, Ellipsis, Lock, Megaphone, MessageSquare, Pencil, Pin, PinOff,
  RotateCcw, Search, ShieldCheck, Sparkles, SquareArrowOutUpRight, SquarePen, ThumbsDown, ThumbsUp, Trash2, UserRound, Users,
} from 'lucide-react'
import {
  AlertDialog, AlertDialogAction, AlertDialogCancel, AlertDialogContent, AlertDialogDescription, AlertDialogTitle,
} from '@/components/ui/alert-dialog'
import { Badge } from '@/components/ui/badge'
import { Button, buttonVariants } from '@/components/ui/button'
import { Card } from '@/components/ui/card'
import {
  DropdownMenu, DropdownMenuContent, DropdownMenuItem, DropdownMenuSeparator, DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu'
import { Input, Textarea } from '@/components/ui/input'
import { notify } from '@/components/ui/sonner'
import { Skeleton } from '@/components/ui/skeleton'
import { Bubble } from '@/components/CategoryIcon'
import { ConfirmDialog, type ConfirmOptions } from '@/components/ConfirmDialog'
import { FormattedText, ReplyBlocks } from '@/components/ReplyBlocks'
import { ErrorState, PageHeader } from '@/components/common'
import { api, ApiError, type AiConversation, type AiDraft, type AiMessage } from '@/lib/api'
import { formatNumber, formatShortWhen, formatTime, isToday, ROLE_LABEL, STATUS_LABEL } from '@/lib/format'
import { cn } from '@/lib/utils'

const SUGGESTIONS = [
  'Tóm tắt tình hình hệ thống 7 ngày qua',
  'Có tài khoản nào bất thường không?',
  'Soạn thông báo giới thiệu trợ lý AI cho người dùng, ngắn gọn',
  'Cấu hình thay đổi gì gần đây?',
]
/** Thao tác của thẻ nháp đã có nút riêng, không lặp lại thành chip gợi ý. */
const ACTION_CHIPS = new Set(['Gửi', 'Hủy'])
const TEXT_MAX = 2000
const TITLE_MAX = 120
const BODY_MAX = 2000

const DAY = 86400_000
function groupOf(iso: string) {
  if (isToday(iso)) return 'Hôm nay'
  return Date.now() - Date.parse(iso) < 7 * DAY ? '7 ngày qua' : 'Cũ hơn'
}
const seconds = (ms: number) => `${new Intl.NumberFormat('vi-VN', { maximumFractionDigits: 1 }).format(ms / 1000)} giây`

/* ============================== Trang ============================== */

export default function AssistantPage() {
  const { id } = useParams()
  const navigate = useNavigate()
  const qc = useQueryClient()
  const [archived, setArchived] = useState(false)
  const [search, setSearch] = useState('')
  const [rename, setRename] = useState<AiConversation | null>(null)
  const [confirm, setConfirm] = useState<ConfirmOptions | null>(null)

  const list = useQuery({ queryKey: ['ai-convs', archived], queryFn: () => api.aiConversations({ archived, limit: 100 }) })
  const archivedCount = useQuery({ queryKey: ['ai-convs', true, 'count'], queryFn: () => api.aiConversations({ archived: true, limit: 1 }), select: (d) => d.total })
  const conv = useQuery({ queryKey: ['ai-conv', id], queryFn: () => api.aiConversation(id!), enabled: !!id })
  const cfg = useQuery({ queryKey: ['config'], queryFn: api.config })
  const disabled = cfg.data ? cfg.data.values.ai?.enabled === false || cfg.data.values.business.featureAi === false : false

  const refreshLists = () => qc.invalidateQueries({ queryKey: ['ai-convs'] })

  const update = useMutation({
    mutationFn: (v: { c: AiConversation; body: { title?: string; archived?: boolean; pinned?: boolean } }) => api.aiUpdateConversation(v.c.id, v.body),
    onSuccess: (c, v) => {
      refreshLists()
      qc.invalidateQueries({ queryKey: ['ai-conv', c.id] })
      if (v.body.archived === true) {
        notify.success('Đã lưu trữ cuộc trò chuyện', { description: c.title, icon: <Archive />, undo: () => update.mutate({ c, body: { archived: false } }) })
        if (c.id === id) navigate('/assistant')
      }
      if (v.body.archived === false) notify.success('Đã khôi phục cuộc trò chuyện', { description: c.title, icon: <ArchiveRestore /> })
    },
    onError: (e) => notify.error('Không cập nhật được cuộc trò chuyện', e.message),
  })

  const remove = useMutation({
    mutationFn: (c: AiConversation) => api.aiDeleteConversation(c.id),
    onSuccess: (_, c) => {
      refreshLists()
      qc.removeQueries({ queryKey: ['ai-conv', c.id] })
      notify.success('Đã xóa cuộc trò chuyện', { description: c.title, icon: <Trash2 /> })
      if (c.id === id) navigate('/assistant')
    },
    onError: (e) => notify.error('Không xóa được cuộc trò chuyện', e.message),
  })

  const askDelete = (c: AiConversation) =>
    setConfirm({
      title: 'Xóa cuộc trò chuyện?',
      description: 'Toàn bộ tin nhắn và nháp trong cuộc này bị xóa vĩnh viễn, không khôi phục được.',
      icon: <Trash2 />,
      destructive: true,
      confirmText: 'Xóa',
      facts: [['Cuộc trò chuyện', c.title], ...(c.messageCount != null ? [['Tin nhắn', formatNumber(c.messageCount)] as [string, string]] : [])],
      onConfirm: () => remove.mutate(c),
    })

  const menu = { pin: (c: AiConversation) => update.mutate({ c, body: { pinned: !c.pinned } }), archive: (c: AiConversation) => update.mutate({ c, body: { archived: !c.archived } }), rename: setRename, remove: askDelete }

  const items = (list.data?.items ?? []).filter((c) => !search.trim() || c.title.toLowerCase().includes(search.trim().toLowerCase()))
  const groups = useMemo(() => {
    const pinned = items.filter((c) => c.pinned && !archived)
    const rest = items.filter((c) => !c.pinned || archived)
    const out: [string, AiConversation[]][] = pinned.length ? [['Đã ghim', pinned]] : []
    for (const c of rest) {
      const g = archived ? 'Đã lưu trữ' : groupOf(c.updatedAt)
      const last = out[out.length - 1]
      if (last?.[0] === g) last[1].push(c)
      else out.push([g, [c]])
    }
    return out
  }, [items, archived])

  return (
    <>
      <PageHeader
        title="Trợ lý AI"
        description="Trợ lý quản trị · đọc số liệu toàn hệ thống như bảng quản trị · mọi thao tác cần bạn xác nhận"
        actions={<Button onClick={() => navigate('/assistant')} data-testid="ai-new"><SquarePen /> Cuộc trò chuyện mới</Button>}
      />
      <div className="grid h-[calc(100svh-150px)] min-h-[560px] grid-cols-[264px_minmax(0,1fr)] gap-5 xl:h-[calc(100svh-164px)] xl:grid-cols-[296px_minmax(0,1fr)]">
        {/* Danh sách cuộc trò chuyện */}
        <Card flush className="flex min-h-0 flex-col" data-testid="ai-conv-list">
          <div className="p-4 pb-2">
            {archived ? (
              <button type="button" className="flex h-10 cursor-pointer items-center gap-2 text-sm font-semibold" onClick={() => setArchived(false)} data-testid="ai-archived-back">
                <ArrowLeft className="size-4" /> Đã lưu trữ
              </button>
            ) : (
              <Input icon={<Search />} value={search} onChange={(e) => setSearch(e.target.value)} placeholder="Tìm cuộc trò chuyện" aria-label="Tìm cuộc trò chuyện" data-testid="ai-search" />
            )}
          </div>
          <div className="min-h-0 flex-1 overflow-y-auto px-2 pb-2">
            {list.error ? (
              <ErrorState error={list.error} onRetry={list.refetch} />
            ) : list.isPending ? (
              <div className="flex flex-col gap-3 px-2 pt-3" aria-busy="true">
                {Array.from({ length: 5 }, (_, i) => (
                  <div key={i} className="flex items-center gap-3"><Skeleton className="size-9 rounded-full" /><div className="flex-1"><Skeleton className="h-3 w-32" /><Skeleton className="mt-2 h-2.5 w-44" /></div></div>
                ))}
              </div>
            ) : groups.length === 0 ? (
              <p className="px-3 pt-4 text-body-s text-muted-foreground" data-testid="ai-conv-empty">
                {search ? 'Không có cuộc trò chuyện nào khớp.' : archived ? 'Chưa lưu trữ cuộc nào.' : 'Chưa có cuộc trò chuyện nào. Hỏi trợ lý ở khung bên phải để bắt đầu.'}
              </p>
            ) : (
              groups.map(([label, cs]) => (
                <div key={label}>
                  <p className="px-3 pt-3 pb-1.5 text-xs font-medium text-faint">{label}</p>
                  {cs.map((c) => <ConvItem key={c.id} c={c} active={c.id === id} menu={menu} />)}
                </div>
              ))
            )}
          </div>
          {!archived && (
            <button
              type="button"
              className="flex h-12 cursor-pointer items-center gap-2 border-t border-line px-5 text-[13.5px] font-medium text-muted-foreground hover:text-foreground"
              onClick={() => setArchived(true)}
              data-testid="ai-archived"
            >
              <Archive className="size-4" /> Đã lưu trữ{archivedCount.data != null && ` · ${formatNumber(archivedCount.data)}`}
              <ChevronRight className="ml-auto size-4" />
            </button>
          )}
        </Card>

        {/* Khung chat */}
        <Card flush className="flex min-h-0 flex-col" data-testid="ai-chat">
          {id && conv.error ? (
            <ErrorState error={conv.error} onRetry={conv.refetch} />
          ) : (
            <Chat key={id ?? 'new'} id={id} conv={conv.data} loading={!!id && conv.isPending} disabled={disabled} menu={menu} />
          )}
        </Card>
      </div>
      <RenameDialog key={rename?.id ?? 'none'} c={rename} onClose={() => setRename(null)} onSave={(c, title) => update.mutate({ c, body: { title } })} />
      <ConfirmDialog options={confirm} onClose={() => setConfirm(null)} />
    </>
  )
}

type Menu = {
  pin: (c: AiConversation) => void
  archive: (c: AiConversation) => void
  rename: (c: AiConversation) => void
  remove: (c: AiConversation) => void
}

function ConvMenu({ c, menu, trigger }: { c: AiConversation; menu: Menu; trigger: React.ReactNode }) {
  return (
    <DropdownMenu>
      <DropdownMenuTrigger asChild>{trigger}</DropdownMenuTrigger>
      <DropdownMenuContent align="end">
        {!c.archived && <DropdownMenuItem onClick={() => menu.pin(c)}>{c.pinned ? <><PinOff /> Bỏ ghim</> : <><Pin /> Ghim</>}</DropdownMenuItem>}
        <DropdownMenuItem onClick={() => menu.rename(c)}><Pencil /> Đổi tên</DropdownMenuItem>
        <DropdownMenuItem onClick={() => menu.archive(c)}>{c.archived ? <><ArchiveRestore /> Khôi phục</> : <><Archive /> Lưu trữ</>}</DropdownMenuItem>
        <DropdownMenuSeparator />
        <DropdownMenuItem variant="destructive" onClick={() => menu.remove(c)}><Trash2 /> Xóa</DropdownMenuItem>
      </DropdownMenuContent>
    </DropdownMenu>
  )
}

function ConvItem({ c, active, menu }: { c: AiConversation; active: boolean; menu: Menu }) {
  return (
    <div
      className={cn('group/conv relative flex items-center gap-3 rounded-sm px-3 py-2.5 transition-colors hover:bg-muted/60', active && 'bg-muted-high hover:bg-muted-high')}
      data-testid="ai-conv"
      data-title={c.title}
    >
      <Bubble size="sm" className={cn(active && 'bg-card')}>{c.pinned ? <Pin /> : <MessageSquare />}</Bubble>
      <Link to={`/assistant/${c.id}`} className="min-w-0 flex-1 after:absolute after:inset-0" aria-current={active ? 'page' : undefined}>
        <p className="truncate text-sm leading-[1.4] font-semibold">{c.title}</p>
        <p className="truncate text-body-s text-muted-foreground tabular-nums">{c.messageCount != null ? `${formatNumber(c.messageCount)} tin nhắn` : ''}</p>
      </Link>
      <span className="self-start pt-0.5 text-xs text-faint tabular-nums group-hover/conv:invisible group-has-[[aria-expanded=true]]/conv:invisible">{formatShortWhen(c.updatedAt)}</span>
      <div className="absolute top-2 right-2 z-10 hidden group-hover/conv:block group-has-[[aria-expanded=true]]/conv:block">
        <ConvMenu c={c} menu={menu} trigger={<Button variant="ghost" size="icon-sm" aria-label="Thao tác" data-testid="ai-conv-menu"><Ellipsis /></Button>} />
      </div>
    </div>
  )
}

function RenameDialog({ c, onClose, onSave }: { c: AiConversation | null; onClose: () => void; onSave: (c: AiConversation, title: string) => void }) {
  const [title, setTitle] = useState(c?.title ?? '')
  const ok = title.trim().length > 0 && title.trim().length <= 120
  return (
    <AlertDialog open={!!c} onOpenChange={(o) => !o && onClose()}>
      <AlertDialogContent>
        <Bubble size="lg"><Pencil /></Bubble>
        <AlertDialogTitle className="mt-[18px]">Đổi tên cuộc trò chuyện</AlertDialogTitle>
        <AlertDialogDescription>Tên chỉ hiện với bạn.</AlertDialogDescription>
        <Input className="mt-4" wrapperClassName="mt-4" value={title} maxLength={120} onChange={(e) => setTitle(e.target.value)} aria-label="Tên cuộc trò chuyện" data-testid="ai-rename-input" autoFocus />
        <div className="mt-6 flex gap-2.5">
          <AlertDialogCancel>Hủy</AlertDialogCancel>
          <AlertDialogAction disabled={!ok} onClick={() => c && onSave(c, title.trim())} data-testid="ai-rename-save">Lưu</AlertDialogAction>
        </div>
      </AlertDialogContent>
    </AlertDialog>
  )
}

/* ============================== Chat ============================== */

type Pending = { text: string; at: number }

function Chat({ id, conv, loading, disabled, menu }: {
  id?: string
  conv?: AiConversation & { messages: AiMessage[] }
  loading: boolean
  disabled: boolean
  menu: Menu
}) {
  const navigate = useNavigate()
  const qc = useQueryClient()
  const [text, setText] = useState('')
  const [pending, setPending] = useState<Pending | null>(null)
  const [ratings, setRatings] = useState<Record<string, 1 | -1>>({})
  const scroller = useRef<HTMLDivElement>(null)
  const input = useRef<HTMLTextAreaElement>(null)

  const messages = conv?.messages ?? []
  useEffect(() => {
    scroller.current?.scrollTo({ top: scroller.current.scrollHeight })
  }, [messages.length, pending])

  const send = useMutation({
    mutationFn: async (t: string) => {
      let cid = id
      if (!cid) {
        const c = await api.aiCreateConversation()
        if (c.autoArchived) notify.success('Đã tự lưu trữ cuộc cũ nhất', { description: `“${c.autoArchived.title ?? 'Không tên'}” vì đã đạt giới hạn số cuộc trò chuyện.`, icon: <Archive /> })
        cid = c.id
      }
      const out = await api.aiPost(cid, t)
      return { cid, out }
    },
    onMutate: (t) => setPending({ text: t, at: Date.now() }),
    onSuccess: async ({ cid }) => {
      await qc.invalidateQueries({ queryKey: ['ai-conv', cid] })
      qc.invalidateQueries({ queryKey: ['ai-convs'] })
      setPending(null)
      if (cid !== id) navigate(`/assistant/${cid}`, { replace: !id })
    },
    onError: (e, t) => {
      setPending(null)
      setText((cur) => cur || t)
      const code = e instanceof ApiError ? (e.data as { code?: string } | null)?.code : undefined
      notify.error(code === 'AI_DAILY_LIMIT' ? 'Hết lượt hỏi hôm nay' : code === 'FEATURE_DISABLED' ? 'Trợ lý đang tắt' : 'Trợ lý chưa trả lời được', e.message)
    },
  })

  const submit = (t = text) => {
    const v = t.trim()
    if (!v || send.isPending || disabled) return
    setText('')
    send.mutate(v.slice(0, TEXT_MAX))
  }
  const onKey = (e: KeyboardEvent<HTMLTextAreaElement>) => {
    if (e.key === 'Enter' && !e.shiftKey && !e.nativeEvent.isComposing) {
      e.preventDefault()
      submit()
    }
  }
  // Ô nhập tự giãn tới 6 dòng
  useEffect(() => {
    const el = input.current
    if (!el) return
    el.style.height = 'auto'
    el.style.height = `${Math.min(el.scrollHeight, 152)}px`
  }, [text])

  const feedback = useMutation({
    mutationFn: (v: { id: string; rating: 1 | -1 }) => api.aiFeedback(v.id, v.rating),
    onMutate: (v) => setRatings((r) => ({ ...r, [v.id]: v.rating })),
    onError: (e, v) => {
      setRatings(({ [v.id]: _drop, ...r }) => r)
      notify.error('Không gửi được đánh giá', e.message)
    },
  })

  const lastAssistant = [...messages].reverse().find((m) => m.role === 'ASSISTANT')

  return (
    <>
      <div className="flex h-[64px] shrink-0 items-center justify-between gap-3 border-b border-line px-6">
        <h2 className="truncate text-title-m" data-testid="ai-chat-title">{loading ? <Skeleton className="h-4 w-48" /> : conv?.title ?? 'Cuộc trò chuyện mới'}</h2>
        <div className="flex shrink-0 items-center gap-1">
          <Badge className="mr-2"><ShieldCheck /> Chỉ đề xuất, bạn xác nhận</Badge>
          {conv && (
            <>
              <Button variant="ghost" size="icon" aria-label="Đổi tên" title="Đổi tên" onClick={() => menu.rename(conv)}><Pencil /></Button>
              <ConvMenu c={conv} menu={menu} trigger={<Button variant="ghost" size="icon" aria-label="Thao tác cuộc trò chuyện" data-testid="ai-chat-menu"><Ellipsis /></Button>} />
            </>
          )}
        </div>
      </div>

      <div ref={scroller} className="min-h-0 flex-1 overflow-y-auto" data-testid="ai-messages">
        <div className="mx-auto flex min-h-full w-full max-w-[780px] flex-col justify-end gap-5 px-8 pt-8 pb-4">
          {loading ? (
            <div className="flex flex-col gap-4" aria-busy="true">
              <Skeleton className="ml-auto h-10 w-64 rounded-[18px]" />
              <Skeleton className="h-3 w-full" /><Skeleton className="h-3 w-4/5" /><Skeleton className="h-3 w-2/3" />
            </div>
          ) : messages.length === 0 && !pending ? (
            <Welcome disabled={disabled} onPick={(s) => submit(s)} />
          ) : (
            messages.map((m) =>
              m.role === 'USER' ? (
                <UserBubbleMsg key={m.id} text={m.content} />
              ) : (
                <AssistantMsg
                  key={m.id}
                  m={m}
                  conversationId={conv!.id}
                  isLast={m.id === lastAssistant?.id && !pending}
                  rating={ratings[m.id]}
                  onRate={(rating) => feedback.mutate({ id: m.id, rating })}
                  onAsk={(t) => submit(t)}
                  busy={send.isPending || disabled}
                />
              ),
            )
          )}
          {pending && (
            <>
              <UserBubbleMsg text={pending.text} />
              <div className="flex items-center gap-2.5 text-muted-foreground" data-testid="ai-thinking">
                <Sparkles className="size-4 animate-pulse" />
                <span className="text-sm">Đang trả lời…</span>
              </div>
            </>
          )}
        </div>
      </div>

      <form
        className="mx-auto w-full max-w-[780px] shrink-0 px-8 pb-4"
        onSubmit={(e: FormEvent) => {
          e.preventDefault()
          submit()
        }}
      >
        {disabled && (
          <p className="mb-2.5 rounded-md bg-warning-soft px-4 py-2.5 text-[13px] text-warning" data-testid="ai-disabled">
            Trợ lý đang tắt. Bật lại trong <Link className="font-semibold underline" to="/settings/tro-ly">Cấu hình › Trợ lý AI</Link>.
          </p>
        )}
        <div className="flex items-end gap-2 rounded-[26px] border border-input bg-card py-2 pr-2 pl-5 transition-[border-color,box-shadow] has-[textarea:focus-visible]:border-primary has-[textarea:focus-visible]:ring-3 has-[textarea:focus-visible]:ring-primary/6">
          <textarea
            ref={input}
            rows={1}
            value={text}
            maxLength={TEXT_MAX}
            disabled={disabled}
            onChange={(e) => setText(e.target.value)}
            onKeyDown={onKey}
            placeholder="Hỏi về người dùng, giao dịch, cấu hình, hoặc nhờ soạn thông báo…"
            aria-label="Tin nhắn cho trợ lý"
            className="max-h-[152px] min-h-9 flex-1 resize-none bg-transparent py-[7px] text-[15px] leading-[1.45] outline-none placeholder:text-faint disabled:cursor-not-allowed"
            data-testid="ai-input"
          />
          <Button type="submit" size="icon" className="size-9 rounded-full bg-primary text-primary-foreground hover:bg-primary/88 hover:text-primary-foreground disabled:bg-muted-high disabled:text-faint" disabled={!text.trim() || send.isPending || disabled} aria-label="Gửi" data-testid="ai-send">
            <ArrowUp />
          </Button>
        </div>
        <p className="mt-2 text-center text-xs text-faint">Không đọc được tin nhắn trợ lý của người dùng. Số liệu do hệ thống tính, trợ lý chỉ diễn giải.</p>
      </form>
    </>
  )
}

function Welcome({ onPick, disabled }: { onPick: (s: string) => void; disabled: boolean }) {
  return (
    <div className="flex flex-col items-center pb-6 text-center" data-testid="ai-welcome">
      <Bubble size="lg"><Sparkles /></Bubble>
      <p className="mt-5 text-title-l">Hỏi trợ lý quản trị</p>
      <p className="mt-2 max-w-[460px] text-muted-foreground">Trợ lý đọc số liệu như bảng quản trị. Thông báo, khóa tài khoản chỉ là nháp, bạn mở màn tương ứng để xác nhận.</p>
      <div className="mt-6 flex max-w-[620px] flex-wrap justify-center gap-2">
        {SUGGESTIONS.map((s) => (
          <button key={s} type="button" disabled={disabled} onClick={() => onPick(s)} className="h-[34px] cursor-pointer rounded-full border border-border bg-card px-3.5 text-[13.5px] font-medium hover:bg-hover disabled:cursor-default disabled:text-faint" data-testid="ai-suggestion">
            {s}
          </button>
        ))}
      </div>
    </div>
  )
}

function UserBubbleMsg({ text }: { text: string }) {
  return (
    <div className="ml-auto max-w-[80%] rounded-[18px] bg-muted-high px-4 py-2.5 text-[15px] leading-[1.5] break-words whitespace-pre-line" data-testid="ai-msg-user">
      {text}
    </div>
  )
}

function AssistantMsg({ m, conversationId, isLast, rating, onRate, onAsk, busy }: {
  m: AiMessage
  conversationId: string
  isLast: boolean
  rating?: 1 | -1
  onRate: (r: 1 | -1) => void
  onAsk: (t: string) => void
  busy: boolean
}) {
  const chips = (m.followUps ?? []).filter((f) => !ACTION_CHIPS.has(f))
  const failed = m.status === 'error'
  return (
    <div className="flex flex-col gap-3" data-testid="ai-msg-assistant" data-skill={m.skill ?? ''}>
      {m.blocks?.length && !failed
        ? <ReplyBlocks blocks={m.blocks} className="text-[15px] leading-[1.6] break-words" />
        : <FormattedText text={m.content} className={cn('text-[15px] leading-[1.6] break-words', failed && 'text-destructive')} />}
      {m.draft && <DraftCard d={m.draft} conversationId={conversationId} onAsk={onAsk} busy={busy} />}
      <div className="flex items-center gap-1 text-faint">
        <button type="button" aria-label="Hữu ích" aria-pressed={rating === 1} onClick={() => onRate(1)} className={cn('flex size-7 cursor-pointer items-center justify-center rounded-full hover:bg-muted hover:text-foreground [&_svg]:size-4', rating === 1 && 'text-foreground')} data-testid="ai-thumb-up"><ThumbsUp /></button>
        <button type="button" aria-label="Chưa đúng" aria-pressed={rating === -1} onClick={() => onRate(-1)} className={cn('flex size-7 cursor-pointer items-center justify-center rounded-full hover:bg-muted hover:text-foreground [&_svg]:size-4', rating === -1 && 'text-foreground')} data-testid="ai-thumb-down"><ThumbsDown /></button>
        <button
          type="button"
          aria-label="Chép"
          onClick={() => navigator.clipboard.writeText(m.content).then(() => notify.success('Đã chép câu trả lời', { icon: <Copy /> }))}
          className="flex size-7 cursor-pointer items-center justify-center rounded-full hover:bg-muted hover:text-foreground [&_svg]:size-4"
        >
          <Copy />
        </button>
        {m.latencyMs != null && <span className="ml-auto text-[13px] tabular-nums" data-testid="ai-latency">{seconds(m.latencyMs)}</span>}
      </div>
      {isLast && chips.length > 0 && (
        <div className="flex flex-wrap gap-2">
          {chips.map((f) => (
            <button key={f} type="button" disabled={busy} onClick={() => onAsk(f)} className="h-[34px] cursor-pointer rounded-full border border-border bg-card px-3.5 text-[13.5px] font-semibold hover:bg-hover disabled:cursor-default disabled:text-faint" data-testid="ai-followup">
              {f}
            </button>
          ))}
        </div>
      )}
    </div>
  )
}

/* ============================== Thẻ nháp (nét đứt = chưa có hiệu lực) ============================== */

function DraftShell({ label, icon, aside, children, resolved }: { label: string; icon: React.ReactNode; aside?: React.ReactNode; children: React.ReactNode; resolved?: boolean }) {
  return (
    <div className={cn('rounded-[18px] border border-dashed border-[#D5D4CF] p-5', resolved && 'border-solid border-border')} data-testid="ai-draft">
      <div className="mb-3.5 flex items-center justify-between gap-3">
        <Badge>{icon}{label}</Badge>
        {aside && <span className="flex items-center gap-1.5 text-[13px] text-muted-foreground [&_svg]:size-4">{aside}</span>}
      </div>
      {children}
    </div>
  )
}

const resolvedLabel = (d: AiDraft) => (d.status === 'CANCELLED' ? 'Đã bỏ nháp' : d.status === 'EDITED' ? 'Đã sửa và xác nhận' : 'Đã xác nhận')

function DraftCard({ d, conversationId, onAsk, busy }: { d: AiDraft; conversationId: string; onAsk: (t: string) => void; busy: boolean }) {
  const qc = useQueryClient()
  const navigate = useNavigate()
  const [lockOpen, setLockOpen] = useState(false)
  const overview = useQuery({ queryKey: ['overview'], queryFn: api.overview })
  const done = <T,>(out: T) => {
    qc.invalidateQueries({ queryKey: ['ai-conv', conversationId] })
    return out
  }
  const cancel = useMutation({
    mutationFn: () => api.aiCancelDraft(d.id).then(done),
    onError: (e) => notify.error('Không bỏ được nháp', e.message),
  })
  const confirm = useMutation({
    mutationFn: (payload?: unknown) => api.aiConfirmDraft(d.id, payload).then(done),
    onError: (e) => notify.error('Không thực hiện được', e.message),
  })
  const open = d.status === 'PROPOSED'

  if (d.kind === 'broadcast') {
    const p = d.payload as { title?: string; body?: string }
    const result = d.result as { recipients?: number } | null
    return (
      <DraftShell
        label={open ? 'Nháp thông báo' : resolvedLabel(d)}
        icon={open ? <CircleDashed /> : <Megaphone />}
        resolved={!open}
        aside={open ? <><Users />Gửi tới {overview.data ? `${formatNumber(overview.data.users.active)} người đang hoạt động` : 'mọi người dùng đang hoạt động'}</> : result?.recipients != null ? <>Đã gửi tới {formatNumber(result.recipients)} người</> : undefined}
      >
        <div className="rounded-md border border-border bg-background px-4 py-3">
          <p className="font-semibold break-words">{p.title}</p>
          <p className="mt-1 text-[14px] leading-normal break-words text-ink-soft">{p.body}</p>
        </div>
        <div className="mt-2.5 flex justify-between text-body-s text-muted-foreground tabular-nums">
          <span>Tiêu đề {(p.title ?? '').length}/{TITLE_MAX} · nội dung {(p.body ?? '').length}/{BODY_MAX} ký tự</span>
          <span>Viết lúc {formatTime(d.createdAt)}</span>
        </div>
        {open && (
          <div className="mt-4 flex items-center gap-2.5">
            <Button onClick={() => navigate('/broadcasts', { state: { aiDraft: { id: d.id, conversationId, title: p.title ?? '', body: p.body ?? '' } } })} data-testid="ai-draft-open">
              <SquareArrowOutUpRight /> Mở trong trình soạn
            </Button>
            <Button variant="secondary" disabled={busy} onClick={() => onAsk('Viết lại thông báo khác')} data-testid="ai-draft-rewrite"><RotateCcw /> Viết lại</Button>
            <Button variant="ghost" disabled={cancel.isPending} onClick={() => cancel.mutate()} data-testid="ai-draft-cancel">Bỏ nháp</Button>
          </div>
        )}
      </DraftShell>
    )
  }

  if (d.kind === 'lock_user') {
    const p = d.payload as { userId?: string; email?: string | null; name?: string | null; reasons?: string[] }
    return (
      <DraftShell label={open ? 'Đề xuất khóa' : resolvedLabel(d)} icon={open ? <CircleDashed /> : <Lock />} resolved={!open}>
        <div className="flex items-center gap-3">
          <Bubble size="sm"><UserRound /></Bubble>
          <div className="min-w-0">
            <p className="truncate font-semibold">{p.name ?? p.email}</p>
            {p.email && <p className="truncate text-body-s text-muted-foreground">{p.email}</p>}
          </div>
        </div>
        {!!p.reasons?.length && (
          <ul className="mt-3 flex flex-col">
            {p.reasons.map((r, i) => <li key={i} className="border-t border-line py-2.5 text-[14px] leading-normal">{r}</li>)}
          </ul>
        )}
        {open && (
          <div className="mt-3 flex items-center gap-2.5">
            <Button variant="danger-soft" onClick={() => setLockOpen(true)} data-testid="ai-draft-lock"><Lock /> Xem xét khóa</Button>
            {p.userId && <Button variant="secondary" asChild><Link to={`/users/${p.userId}`}><UserRound /> Mở hồ sơ</Link></Button>}
            <Button variant="ghost" disabled={cancel.isPending} onClick={() => cancel.mutate()} data-testid="ai-draft-cancel">Bỏ qua</Button>
          </div>
        )}
        <LockDialog
          key={String(lockOpen)}
          open={lockOpen}
          onClose={() => setLockOpen(false)}
          draft={d}
          onConfirm={(reason) =>
            confirm.mutate({ ...p, reasons: reason ? [reason] : [] }, {
              onSuccess: () => {
                qc.invalidateQueries({ queryKey: ['users'] })
                qc.invalidateQueries({ queryKey: ['overview'] })
                notify.success(`Đã khóa ${p.name ?? p.email}`, { description: 'Lý do đã ghi vào nhật ký.', icon: <Lock /> })
              },
            })
          }
        />
      </DraftShell>
    )
  }

  if (d.kind === 'search_filter' && d.payload?.target === 'users') {
    const p = d.payload as { q: string | null; status: 'ACTIVE' | 'LOCKED' | null; role: 'USER' | 'ADMIN' | null }
    const qs = new URLSearchParams(Object.entries({ q: p.q, status: p.status, role: p.role }).filter(([, v]) => v) as [string, string][]).toString()
    const facts = [p.q && `“${p.q}”`, p.status && STATUS_LABEL[p.status], p.role && ROLE_LABEL[p.role]].filter(Boolean)
    return (
      <DraftShell label="Bộ lọc người dùng" icon={<Users />} resolved={!open}>
        <p className="text-[14px]">{facts.length ? facts.join(' · ') : 'Tất cả người dùng'}</p>
        <div className="mt-3.5">
          <Button
            variant="secondary"
            onClick={() => {
              if (open) confirm.mutate(undefined)
              navigate(`/users${qs ? `?${qs}` : ''}`)
            }}
            data-testid="ai-draft-filter"
          >
            Mở trong Người dùng, đã lọc sẵn <ChevronRight />
          </Button>
        </div>
      </DraftShell>
    )
  }

  // Loại nháp khác (của trợ lý người dùng): xác nhận / bỏ nguyên nháp
  return (
    <DraftShell label={open ? 'Nháp' : resolvedLabel(d)} icon={<CircleDashed />} resolved={!open}>
      {open ? (
        <div className="flex items-center gap-2.5">
          <Button disabled={confirm.isPending} onClick={() => confirm.mutate(undefined)}>Xác nhận</Button>
          <Button variant="ghost" disabled={cancel.isPending} onClick={() => cancel.mutate()}>Bỏ nháp</Button>
        </div>
      ) : (
        <p className="text-body-s text-muted-foreground">{resolvedLabel(d)}{d.resolvedAt ? ` lúc ${formatTime(d.resolvedAt)}` : ''}</p>
      )}
    </DraftShell>
  )
}

/** Hộp xác nhận khóa giống A3, thêm "Đề xuất bởi Trợ lý AI" và lý do điền sẵn (sửa được, ghi nhật ký). */
function LockDialog({ open, onClose, draft, onConfirm }: { open: boolean; onClose: () => void; draft: AiDraft; onConfirm: (reason: string) => void }) {
  const p = draft.payload as { userId?: string; email?: string | null; name?: string | null; reasons?: string[] }
  const [reason, setReason] = useState((p.reasons ?? []).join('; '))
  const user = useQuery({ queryKey: ['user', p.userId], queryFn: () => api.user(p.userId!), enabled: open && !!p.userId })
  const name = p.name ?? p.email ?? 'người dùng'
  const first = name.trim().split(/\s+/).pop()
  return (
    <AlertDialog open={open} onOpenChange={(o) => !o && onClose()}>
      <AlertDialogContent data-testid="ai-lock-dialog">
        <Bubble size="lg" tone="danger"><Lock /></Bubble>
        <AlertDialogTitle className="mt-[18px]">Khóa tài khoản {name}?</AlertDialogTitle>
        <AlertDialogDescription>{first} sẽ bị đăng xuất và không đăng nhập được cho tới khi được mở khóa. Dữ liệu vẫn được giữ nguyên.</AlertDialogDescription>
        <dl className="mt-[18px] rounded-md bg-background px-4 py-1">
          {([
            ['Email', p.email ?? '—'],
            ...(user.data ? [['Dữ liệu giữ lại', `${formatNumber(user.data._count.transactions)} giao dịch · ${formatNumber(user.data._count.savingGoals)} mục tiêu`]] : []),
            ['Đề xuất bởi', <span key="by" className="inline-flex items-center gap-1.5"><Sparkles className="size-3.5" />Trợ lý AI · {formatTime(draft.createdAt)}</span>],
          ] as [string, React.ReactNode][]).map(([k, v]) => (
            <div key={k} className="flex h-[42px] items-center justify-between gap-4 text-[13.5px] not-first:border-t not-first:border-border">
              <dt className="text-muted-foreground">{k}</dt>
              <dd className="truncate tabular-nums">{v}</dd>
            </div>
          ))}
        </dl>
        <label className="mt-4 block text-[13px] font-medium text-muted-foreground" htmlFor="ai-lock-reason">Lý do, ghi vào nhật ký</label>
        <Textarea id="ai-lock-reason" wrapperClassName="mt-2" rows={2} maxLength={300} value={reason} onChange={(e) => setReason(e.target.value)} data-testid="ai-lock-reason" />
        <div className="mt-6 flex gap-2.5">
          <AlertDialogCancel>Hủy</AlertDialogCancel>
          <AlertDialogAction className={buttonVariants({ variant: 'danger-soft', size: 'dialog' })} onClick={() => onConfirm(reason.trim())} data-testid="ai-lock-confirm">
            <Lock /> Khóa tài khoản
          </AlertDialogAction>
        </div>
      </AlertDialogContent>
    </AlertDialog>
  )
}
