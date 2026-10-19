import { useEffect, useMemo, useRef, useState, type ReactNode } from 'react'
import { Link, useBlocker, useParams } from 'react-router'
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import {
  AppWindow, ArrowLeftRight, BellRing, ArrowRight, Banknote, CalendarClock, CircleAlert, CircleCheck, Construction, Download, ExternalLink, History,
  KeyRound, Lock, LogIn, Mail, MailCheck, MailWarning, PencilLine, Phone, PiggyBank, Repeat, RotateCcw, Send, ShieldX, Signal,
  Smartphone, Sparkles, Timer, WalletCards, Wifi, X, Zap, Server, PlugZap, Cpu, Database,
} from 'lucide-react'
import {
  AlertDialog, AlertDialogAction, AlertDialogCancel, AlertDialogContent, AlertDialogDescription, AlertDialogTitle,
} from '@/components/ui/alert-dialog'
import { Badge } from '@/components/ui/badge'
import { Button, buttonVariants } from '@/components/ui/button'
import { Card } from '@/components/ui/card'
import { Input, PasswordInput, Textarea } from '@/components/ui/input'
import { notify } from '@/components/ui/sonner'
import { Switch } from '@/components/ui/switch'
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table'
import { Tabs, TabsList, TabsTrigger } from '@/components/ui/tabs'
import { Skeleton } from '@/components/ui/skeleton'
import { Bubble } from '@/components/CategoryIcon'
import { ConfirmDialog, type ConfirmOptions } from '@/components/ConfirmDialog'
import { Chip, ErrorState, PageHeader, Pagination, TableSkeleton, UserBubble } from '@/components/common'
import { api, ApiError, auth, type ConfigSection, type ConfigValue, type OllamaTestResult, type SmtpTestResult, type SystemConfig } from '@/lib/api'
import { formatDate, formatDayMonth, formatNumber, formatTime, isToday } from '@/lib/format'
import { cn } from '@/lib/utils'

/* ============================== Định nghĩa trường ============================== */

type Kind = 'text' | 'int' | 'bool' | 'datetime' | 'enum' | 'secret'
type Format = 'email' | 'https' | 'version' | 'phone' | 'from' | 'url'
interface Def {
  section: ConfigSection
  field: string
  label: string
  kind: Kind
  min?: number
  max?: number
  unit?: string
  maxLen?: number
  required?: boolean
  format?: Format
}

const D = (section: ConfigSection, field: string, label: string, kind: Kind, o: Partial<Def> = {}): Def => ({ section, field, label, kind, ...o })
const FEATURES = [
  { field: 'featureSavingGoals', label: 'Mục tiêu tiết kiệm', desc: 'Tạo mục tiêu, nạp và rút tiền tiết kiệm.', icon: PiggyBank },
  { field: 'featureRecurring', label: 'Giao dịch định kỳ', desc: 'Tự ghi lương, tiền nhà, hóa đơn theo lịch.', icon: Repeat },
  { field: 'featureTransfers', label: 'Chuyển tiền giữa ví', desc: 'Chuyển số dư từ ví này sang ví khác.', icon: ArrowLeftRight },
  { field: 'featureCsvExport', label: 'Xuất CSV', desc: 'Xuất giao dịch theo tháng ở màn Báo cáo.', icon: Download },
  { field: 'featureQuickTemplates', label: 'Mẫu nhập nhanh', desc: 'Lưu sẵn giao dịch hay dùng để ghi một chạm.', icon: Zap },
  { field: 'featureAi', label: 'Trợ lý AI', desc: 'Hỏi chi tiêu, ghi nhanh bằng một câu. Cùng công tắc với Cấu hình › Trợ lý AI.', icon: Sparkles },
  { field: 'featureBankNotifications', label: 'Ghi từ thông báo ngân hàng', desc: 'Chỉ Android. Đọc thông báo biến động số dư của ngân hàng, ví để gợi ý giao dịch; người dùng tự bật, cấp quyền và xác nhận từng khoản.', icon: BellRing },
] as const
/** `business.featureAi` và `ai.enabled` là cùng một công tắc (backend ghi cả hai) → cả hai nơi đều sửa `ai.enabled` */
const featureKey = (field: string) => (field === 'featureAi' ? 'ai.enabled' : `business.${field}`)
const PROVIDER_LABEL: Record<string, string> = { ollama: 'Ollama · nội bộ', fake: 'Giả lập (kiểm thử)' }

const DEFS: Def[] = [
  D('general', 'appName', 'Tên ứng dụng', 'text', { required: true, maxLen: 50 }),
  D('general', 'supportEmail', 'Email hỗ trợ', 'text', { format: 'email', maxLen: 120 }),
  D('general', 'hotline', 'Hotline', 'text', { format: 'phone', maxLen: 20 }),
  D('general', 'termsUrl', 'Điều khoản sử dụng', 'text', { format: 'https', maxLen: 300 }),
  D('general', 'privacyUrl', 'Chính sách bảo mật', 'text', { format: 'https', maxLen: 300 }),
  D('access', 'maintenanceEnabled', 'Chế độ bảo trì', 'bool'),
  D('access', 'maintenanceMessage', 'Thông báo bảo trì', 'text', { required: true, maxLen: 200 }),
  D('access', 'maintenanceEndsAt', 'Dự kiến xong lúc', 'datetime'),
  D('access', 'registrationEnabled', 'Cho phép đăng ký mới', 'bool'),
  D('access', 'sessionDays', 'Thời hạn phiên đăng nhập', 'int', { min: 1, max: 365, unit: 'ngày' }),
  D('access', 'loginMaxAttempts', 'Số lần đăng nhập sai', 'int', { min: 1, max: 1000, unit: 'lần' }),
  D('access', 'loginWindowMinutes', 'Khung thời gian đăng nhập sai', 'int', { min: 1, max: 60, unit: 'phút' }),
  D('smtp', 'host', 'Máy chủ', 'text', { maxLen: 200 }),
  D('smtp', 'port', 'Cổng', 'int', { min: 1, max: 65535 }),
  D('smtp', 'security', 'Bảo mật', 'enum'),
  D('smtp', 'user', 'Tên đăng nhập', 'text', { maxLen: 200 }),
  D('smtp', 'password', 'Mật khẩu SMTP', 'secret', { maxLen: 500 }),
  D('smtp', 'from', 'Địa chỉ gửi', 'text', { format: 'from', maxLen: 200 }),
  D('password', 'minLength', 'Độ dài mật khẩu tối thiểu', 'int', { min: 6, max: 64, unit: 'ký tự' }),
  D('password', 'otpExpiryMinutes', 'OTP hết hạn sau', 'int', { min: 1, max: 60, unit: 'phút' }),
  D('password', 'otpMaxAttempts', 'Số lần nhập sai OTP tối đa', 'int', { min: 1, max: 10, unit: 'lần' }),
  D('password', 'otpResendSeconds', 'Chờ trước khi gửi lại OTP', 'int', { min: 30, max: 600, unit: 'giây' }),
  D('business', 'budgetWarningPercent', 'Ngưỡng sắp hết ngân sách', 'int', { min: 10, max: 100, unit: '%' }),
  D('business', 'budgetExceededPercent', 'Ngưỡng vượt ngân sách', 'int', { min: 50, max: 200, unit: '%' }),
  D('business', 'defaultWalletName', 'Tên ví mặc định', 'text', { required: true, maxLen: 100 }),
  ...FEATURES.map((f) => D('business', f.field, f.label, 'bool')),
  D('mobile', 'androidLatestVersion', 'Phiên bản mới nhất · Android', 'text', { required: true, format: 'version' }),
  D('mobile', 'androidMinVersion', 'Bản tối thiểu · Android', 'text', { required: true, format: 'version' }),
  D('mobile', 'androidStoreUrl', 'Link CH Play', 'text', { format: 'https', maxLen: 300 }),
  D('mobile', 'iosLatestVersion', 'Phiên bản mới nhất · iOS', 'text', { required: true, format: 'version' }),
  D('mobile', 'iosMinVersion', 'Bản tối thiểu · iOS', 'text', { required: true, format: 'version' }),
  D('mobile', 'iosStoreUrl', 'Link App Store', 'text', { format: 'https', maxLen: 300 }),
  D('mobile', 'releaseNotes', 'Ghi chú cập nhật', 'text', { maxLen: 300 }),
  D('ai', 'enabled', 'Bật trợ lý', 'bool'),
  D('ai', 'provider', 'Nhà cung cấp', 'enum'),
  D('ai', 'ollamaUrl', 'Địa chỉ Ollama', 'text', { required: true, maxLen: 300, format: 'url' }),
  D('ai', 'chatModel', 'Model trả lời', 'text', { required: true, maxLen: 100 }),
  D('ai', 'embedModel', 'Model embedding', 'text', { required: true, maxLen: 100 }),
  D('ai', 'timeoutSeconds', 'Chờ tối đa mỗi câu trả lời', 'int', { min: 5, max: 600, unit: 'giây' }),
  D('ai', 'dailyMessageLimitPerUser', 'Tin nhắn mỗi người mỗi ngày', 'int', { min: 1, max: 100000, unit: 'tin' }),
  D('ai', 'maxConversationsPerUser', 'Cuộc trò chuyện tối đa mỗi người', 'int', { min: 1, max: 10000, unit: 'cuộc' }),
  D('ai', 'ocrEnabled', 'Bật đọc ảnh', 'bool'),
  D('ai', 'ocrDailyLimitPerUser', 'Ảnh mỗi người mỗi ngày', 'int', { min: 1, max: 100, unit: 'ảnh' }),
  D('ai', 'ocrMaxSide', 'Kích thước ảnh tối đa gửi lên', 'int', { min: 384, max: 1536, unit: 'px' }),
  D('ai', 'ocrTimeoutSeconds', 'Thời gian chờ đọc ảnh tối đa', 'int', { min: 10, max: 120, unit: 'giây' }),
  D('ai', 'autoApproveEnabled', 'Tự áp dụng luật chung', 'bool'),
  D('ai', 'autoApproveMinUsers', 'Tự áp dụng khi đủ số người', 'int', { min: 5, max: 100000, unit: 'người' }),
  D('ai', 'autoApproveMinSupport', 'Tự áp dụng khi đủ số lần', 'int', { min: 1, max: 100000, unit: 'lần' }),
  D('ai', 'autoApproveMinPrecision', 'Tự áp dụng khi đúng từ', 'int', { min: 50, max: 100, unit: '%' }),
]
const DEF = new Map(DEFS.map((d) => [`${d.section}.${d.field}`, d]))

const SECTIONS = [
  { slug: 'chung', api: 'general', label: 'Chung', short: 'Chung', icon: AppWindow },
  { slug: 'truy-cap', api: 'access', label: 'Đăng ký & truy cập', short: 'Đăng ký & truy cập', icon: LogIn },
  { slug: 'email', api: 'smtp', label: 'Email (SMTP)', short: 'Email', icon: Mail },
  { slug: 'mat-khau', api: 'password', label: 'Mật khẩu & OTP', short: 'Mật khẩu & OTP', icon: KeyRound },
  { slug: 'nghiep-vu', api: 'business', label: 'Nghiệp vụ', short: 'Nghiệp vụ', icon: WalletCards },
  { slug: 'ung-dung', api: 'mobile', label: 'Ứng dụng di động', short: 'Ứng dụng', icon: Smartphone },
  { slug: 'tro-ly', api: 'ai', label: 'Trợ lý AI', short: 'Trợ lý AI', icon: Sparkles },
] as const
const SECTION_SHORT = Object.fromEntries(SECTIONS.map((s) => [s.api, s.short])) as Record<ConfigSection, string>
const SECURITY_LABEL: Record<string, string> = { starttls: 'STARTTLS', ssl: 'SSL/TLS', none: 'Không mã hóa' }
/** Nhãn hiển thị mọi trường enum (Trước: …, lịch sử) */
const ENUM_LABEL: Record<string, string> = { ...SECURITY_LABEL, ...PROVIDER_LABEL }

/* ============================== Giá trị nháp ============================== */

type DraftValue = string | boolean
type Draft = Record<string, DraftValue>

const pad = (n: number) => String(n).padStart(2, '0')
/** ISO -> "YYYY-MM-DDTHH:mm" theo giờ trình duyệt (ô datetime-local). */
const isoToLocal = (iso: string | null) => {
  if (!iso) return ''
  const d = new Date(iso)
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}T${pad(d.getHours())}:${pad(d.getMinutes())}`
}

function toDraft(def: Def, v: ConfigValue): DraftValue {
  if (def.kind === 'bool') return v === true
  if (def.kind === 'int') return v === null || v === undefined ? '' : String(v)
  if (def.kind === 'datetime') return isoToLocal(v as string | null)
  return (v as string | null) ?? ''
}

/** Giá trị gửi lên API (đã chuẩn hóa) từ ô nhập. */
function fromDraft(def: Def, v: DraftValue): ConfigValue {
  if (def.kind === 'bool') return v === true
  if (def.kind === 'int') return /^\s*-?\d+\s*$/.test(String(v)) ? Number(v) : NaN
  if (def.kind === 'datetime') return v ? new Date(String(v)).toISOString() : null
  if (def.kind === 'secret') return String(v)
  return String(v).trim()
}

const EMAIL_RE = /^[^\s@<>]+@[^\s@<>]+\.[^\s@<>]+$/
const VERSION_RE = /^\d{1,4}\.\d{1,4}\.\d{1,4}$/
const PHONE_RE = /^\+?[0-9][0-9 .-]{4,18}[0-9]$/
const FROM_RE = /^(?:[^<>]{1,100}<[^\s@<>]+@[^\s@<>]+\.[^\s@<>]+>|[^\s@<>]+@[^\s@<>]+\.[^\s@<>]+)$/
const cmpVersion = (a: string, b: string) => {
  const pa = a.split('.').map(Number), pb = b.split('.').map(Number)
  for (let i = 0; i < 3; i++) if (pa[i] !== pb[i]) return pa[i] - pb[i]
  return 0
}

/** Kiểm tra giống backend (cùng câu chữ). */
function validateOne(def: Def, v: ConfigValue): string | undefined {
  if (def.kind === 'int') {
    if (typeof v !== 'number' || Number.isNaN(v)) return 'Nhập số nguyên'
    if (v < def.min! || v > def.max!) return `Phải từ ${formatNumber(def.min!)} đến ${formatNumber(def.max!)}`
  }
  if (def.kind === 'datetime' && v && Number.isNaN(Date.parse(String(v)))) return 'Thời gian không hợp lệ'
  if (def.kind === 'text' || def.kind === 'secret') {
    const s = String(v ?? '')
    if (def.required && !s) return 'Không được để trống'
    if (def.maxLen && s.length > def.maxLen) return `Tối đa ${def.maxLen} ký tự`
    if (s && def.format === 'email' && !EMAIL_RE.test(s)) return 'Email không hợp lệ'
    if (s && def.format === 'https' && !/^https:\/\/[^\s/]+\.[^\s]+$/.test(s)) return 'Link phải bắt đầu bằng https://'
    if (s && def.format === 'version' && !VERSION_RE.test(s)) return 'Phiên bản dạng x.y.z, vd 1.4.0'
    if (s && def.format === 'phone' && !PHONE_RE.test(s)) return 'Số điện thoại không hợp lệ'
    if (s && def.format === 'from' && !FROM_RE.test(s)) return 'Dạng "Tên <email@miền>" hoặc một email'
    if (s && def.format === 'url' && !/^https?:\/\/[^\s/]+(\/[^\s]*)?$/.test(s)) return 'Link phải bắt đầu bằng http:// hoặc https://'
  }
}

/** Hiển thị giá trị (Trước: …, lịch sử thay đổi). */
function display(key: string, v: ConfigValue, secret = false): string {
  const def = DEF.get(key)
  if (secret || def?.kind === 'secret') return '••••'
  if (v === null || v === undefined || v === '') return def?.kind === 'datetime' ? 'Không hẹn giờ' : '(trống)'
  if (typeof v === 'boolean') return v ? 'Bật' : 'Tắt'
  if (def?.kind === 'datetime') return `${formatTime(String(v))} · ${formatDate(String(v))}`
  if (def?.kind === 'enum') return ENUM_LABEL[String(v)] ?? String(v)
  if (typeof v === 'number') return def?.unit === '%' ? `${v}%` : def?.unit ? `${formatNumber(v)} ${def.unit}` : String(v)
  return String(v).replace(/^https:\/\//, '')
}

/* ============================== Khung một hàng ============================== */

function SettingRow({ label, desc, changed, inline, children, testId }: {
  label: ReactNode
  desc?: ReactNode
  changed?: boolean
  inline?: boolean
  children: ReactNode
  testId?: string
}) {
  return (
    <div
      data-testid={testId}
      data-changed={changed || undefined}
      className={cn('grid grid-cols-[minmax(0,1fr)_400px] gap-8 border-t border-line px-6 py-4 first:border-t-0 xl:grid-cols-[minmax(0,1fr)_420px] xl:gap-10', inline ? 'items-center' : 'items-start')}
    >
      <div className="min-w-0">
        <div className="flex items-center gap-2 text-sm leading-[1.4] font-semibold">
          {label}
          {changed && <span className="size-1.5 rounded-full bg-primary" data-testid="changed-dot" />}
        </div>
        {desc && <div className="mt-[3px] text-body-s text-pretty text-muted-foreground">{desc}</div>}
      </div>
      <div className={cn('flex min-w-0 flex-col gap-1.5', inline && 'items-end')}>{children}</div>
    </div>
  )
}

function SettingCard({ title, aside, children, className, testId }: { title?: ReactNode; aside?: ReactNode; children: ReactNode; className?: string; testId?: string }) {
  return (
    <Card flush className={className} data-testid={testId}>
      {title && (
        <div className="flex items-center justify-between gap-3 border-b border-line px-6 pt-[18px] pb-3.5">
          <h3 className="text-title-m">{title}</h3>
          {aside}
        </div>
      )}
      {children}
    </Card>
  )
}

function SectionHead({ title, desc, aside }: { title: string; desc: ReactNode; aside?: ReactNode }) {
  return (
    <div className="flex items-start justify-between gap-4">
      <div>
        <h2 className="text-title-l">{title}</h2>
        <p className="mt-1 text-muted-foreground">{desc}</p>
      </div>
      {aside}
    </div>
  )
}

const FieldError = ({ children, testId }: { children?: ReactNode; testId?: string }) =>
  children ? <p role="alert" data-testid={testId ?? 'field-error'} className="flex items-center gap-1.5 text-body-s text-destructive"><CircleAlert className="size-3.5" />{children}</p> : null
const Help = ({ children, className }: { children: ReactNode; className?: string }) => <p className={cn('text-body-s text-faint', className)}>{children}</p>
const Was = ({ children }: { children: ReactNode }) => (
  <p className="text-body-s text-faint" data-testid="was">Trước: <s className="text-muted-foreground">{children}</s></p>
)

function Banner({ icon, title, children, action, testId }: { icon: ReactNode; title: ReactNode; children: ReactNode; action?: ReactNode; testId?: string }) {
  return (
    <div className="flex items-center gap-3.5 rounded-lg border border-warning-line bg-warning-soft py-3.5 pr-4 pl-[18px] text-warning" data-testid={testId}>
      <span className="flex size-8 shrink-0 items-center justify-center rounded-full bg-[#F6E7B8] [&_svg]:size-4">{icon}</span>
      <div className="min-w-0 flex-1">
        <p className="text-sm leading-[1.4] font-semibold text-warning-ink">{title}</p>
        <p className="mt-px text-[13px] leading-normal">{children}</p>
      </div>
      {action}
    </div>
  )
}

/* ============================== Trang ============================== */

type Ctx = {
  cfg: SystemConfig
  value: (key: string) => DraftValue
  set: (key: string, v: DraftValue) => void
  reset: (key: string) => void
  isDirty: (key: string) => boolean
  error: (key: string) => string | undefined
  server: (key: string) => ConfigValue
}


export default function SettingsPage() {
  const { section = 'chung' } = useParams()
  const qc = useQueryClient()
  const cfgQ = useQuery({ queryKey: ['config'], queryFn: api.config })
  const [draft, setDraft] = useState<Draft>({})
  const [serverErrors, setServerErrors] = useState<Record<string, string>>({})
  const [maintenanceAsk, setMaintenanceAsk] = useState(false)
  const cfg = cfgQ.data

  const server = (key: string): ConfigValue => {
    const [s, f] = key.split('.') as [ConfigSection, string]
    if (key === 'access.maintenanceEnabled') return cfg?.maintenance.enabled ?? false
    return cfg?.values[s]?.[f] ?? null
  }
  const isDirty = (key: string) => {
    if (!(key in draft)) return false
    const def = DEF.get(key)!
    if (def.kind === 'secret') return String(draft[key]) !== ''
    const a = fromDraft(def, draft[key]), b = server(key)
    return !(a === b || (Number.isNaN(a) && Number.isNaN(b)))
  }
  const dirtyKeys = useMemo(() => Object.keys(draft).filter(isDirty), [draft, cfg]) // eslint-disable-line react-hooks/exhaustive-deps
  const merged = (key: string): ConfigValue => (dirtyKeys.includes(key) ? fromDraft(DEF.get(key)!, draft[key]) : server(key))

  const errors = useMemo(() => {
    const e: Record<string, string> = {}
    for (const k of dirtyKeys) {
      const msg = validateOne(DEF.get(k)!, fromDraft(DEF.get(k)!, draft[k]))
      if (msg) e[k] = msg
    }
    const cross = (keys: string[], target: string, ok: boolean, msg: string) => {
      if (!ok && keys.some((k) => dirtyKeys.includes(k)) && !keys.some((k) => e[k])) e[dirtyKeys.includes(target) ? target : keys.find((k) => dirtyKeys.includes(k))!] = msg
    }
    cross(['business.budgetWarningPercent', 'business.budgetExceededPercent'], 'business.budgetWarningPercent',
      (merged('business.budgetWarningPercent') as number) < (merged('business.budgetExceededPercent') as number), 'Ngưỡng cảnh báo phải nhỏ hơn ngưỡng vượt')
    cross(['password.otpResendSeconds', 'password.otpExpiryMinutes'], 'password.otpResendSeconds',
      (merged('password.otpResendSeconds') as number) < (merged('password.otpExpiryMinutes') as number) * 60, 'Thời gian chờ gửi lại phải ngắn hơn thời hạn mã')
    for (const p of ['android', 'ios']) {
      const l = `mobile.${p}LatestVersion`, m = `mobile.${p}MinVersion`
      cross([l, m], m, cmpVersion(String(merged(m)), String(merged(l))) <= 0, 'Bản tối thiểu không được mới hơn bản mới nhất')
    }
    const ends = merged('access.maintenanceEndsAt')
    if (dirtyKeys.includes('access.maintenanceEndsAt') && !e['access.maintenanceEndsAt'] && ends && Date.parse(String(ends)) <= Date.now()) {
      e['access.maintenanceEndsAt'] = 'Giờ dự kiến xong phải ở tương lai'
    }
    for (const [k, msg] of Object.entries(serverErrors)) if (dirtyKeys.includes(k) && !e[k]) e[k] = msg
    return e
  }, [dirtyKeys, draft, serverErrors]) // eslint-disable-line react-hooks/exhaustive-deps

  const ctx: Ctx | null = cfg
    ? {
        cfg,
        value: (key) => (key in draft ? draft[key] : toDraft(DEF.get(key)!, server(key))),
        set: (key, v) => {
          setDraft((d) => ({ ...d, [key]: v }))
          setServerErrors((s) => {
            if (!(key in s)) return s
            const { [key]: _drop, ...rest } = s
            return rest
          })
        },
        reset: (key) => setDraft(({ [key]: _drop, ...rest }) => rest),
        isDirty: (key) => dirtyKeys.includes(key),
        error: (key) => errors[key],
        server,
      }
    : null

  const save = useMutation({
    mutationFn: () => {
      const body: Partial<Record<ConfigSection, Record<string, ConfigValue>>> = {}
      for (const k of dirtyKeys) {
        const def = DEF.get(k)!
        ;(body[def.section] ??= {})[def.field] = fromDraft(def, draft[k])
      }
      return api.updateConfig(body)
    },
    onSuccess: (data) => {
      const n = dirtyKeys.length
      qc.setQueryData(['config'], data)
      qc.invalidateQueries({ queryKey: ['config-history'] })
      setDraft({})
      setServerErrors({})
      notify.success('Đã lưu cấu hình', { description: `${formatNumber(n)} thay đổi, áp dụng cho app trong vòng 1 phút.` })
    },
    onError: (e) => {
      const errs = e instanceof ApiError ? (e.data as { errors?: Record<string, string> } | null)?.errors : undefined
      if (errs) setServerErrors(errs)
      notify.error('Không lưu được cấu hình', errs ? Object.entries(errs).map(([k, m]) => `${DEF.get(k)?.label ?? k}: ${m}`).join(' · ') : e.message)
    },
  })

  const maintenance = useMutation({
    mutationFn: (enabled: boolean) =>
      enabled
        ? api.setMaintenance({ enabled, message: String(fromDraft(DEF.get('access.maintenanceMessage')!, ctx!.value('access.maintenanceMessage'))), endsAt: fromDraft(DEF.get('access.maintenanceEndsAt')!, ctx!.value('access.maintenanceEndsAt')) as string | null })
        : api.setMaintenance({ enabled }),
    onSuccess: async (m) => {
      await qc.invalidateQueries({ queryKey: ['config'] })
      qc.invalidateQueries({ queryKey: ['config-history'] })
      setDraft(({ 'access.maintenanceMessage': _a, 'access.maintenanceEndsAt': _b, ...rest }) => rest)
      if (m.enabled) notify.success('Đã bật chế độ bảo trì', { description: m.endsAt ? `Tự tắt lúc ${display('access.maintenanceEndsAt', m.endsAt)}.` : 'Nhớ tắt khi bảo trì xong.', icon: <Construction /> })
      else notify.success('Đã tắt chế độ bảo trì', { description: 'Người dùng dùng app bình thường trở lại.' })
    },
    onError: (e) => {
      const errs = e instanceof ApiError ? (e.data as { errors?: Record<string, string> } | null)?.errors : undefined
      if (errs) setServerErrors(errs)
      notify.error('Không đổi được chế độ bảo trì', errs ? Object.values(errs).join(' · ') : e.message)
    },
  })

  // Rời trang khi còn thay đổi chưa lưu
  const dirty = dirtyKeys.length > 0
  const blocker = useBlocker(({ currentLocation, nextLocation }) => dirty && !nextLocation.pathname.startsWith('/settings') && currentLocation.pathname !== nextLocation.pathname)
  const leaving = useRef(false)
  const leaveOptions: ConfirmOptions | null = blocker.state === 'blocked'
    ? {
        title: 'Rời trang khi chưa lưu?',
        description: `${formatNumber(dirtyKeys.length)} thay đổi chưa lưu sẽ bị bỏ.`,
        icon: <PencilLine />,
        confirmText: 'Rời trang',
        destructive: true,
        onConfirm: () => {
          leaving.current = true
          blocker.proceed?.()
        },
      }
    : null
  useEffect(() => {
    if (!dirty) return
    const h = (e: BeforeUnloadEvent) => e.preventDefault()
    window.addEventListener('beforeunload', h)
    return () => window.removeEventListener('beforeunload', h)
  }, [dirty])

  const sec = SECTIONS.find((s) => s.slug === section)
  const counts = Object.fromEntries(SECTIONS.map((s) => [s.slug, dirtyKeys.filter((k) => k.startsWith(`${s.api}.`)).length]))
  const errorKeys = Object.keys(errors)
  const lastSaved = cfg?.lastSaved
  const appName = String(cfg?.values.general.appName ?? 'Thu Chi')

  const tails: Record<string, ReactNode> = {}
  for (const s of SECTIONS) if (counts[s.slug]) tails[s.slug] = <span className="inline-flex h-5 min-w-5 items-center justify-center rounded-full bg-primary px-1.5 text-[11.5px] font-semibold text-primary-foreground tabular-nums" data-testid="nav-count">{counts[s.slug]}</span>
  if (cfg?.maintenance.enabled) tails['truy-cap'] = <>{tails['truy-cap']}<span className="size-[7px] rounded-full bg-warning-bar" title="Đang bảo trì" data-testid="nav-maintenance-dot" /></>
  if (cfg && !cfg.smtp.configured) tails.email = <>{tails.email}<span className="size-[7px] rounded-full bg-warning-bar" title="Chưa cấu hình" /></>

  return (
    <>
      <PageHeader
        title="Cấu hình hệ thống"
        description={
          <>
            <span>Áp dụng cho app {appName} trên mọi thiết bị</span>
            {lastSaved && (
              <span className="hidden xl:inline" data-testid="last-saved">
                {' '}· lưu gần nhất {isToday(lastSaved.at) ? `${formatTime(lastSaved.at)} hôm nay` : `${formatTime(lastSaved.at)}, ${formatDayMonth(lastSaved.at)}`}{lastSaved.by ? ` bởi ${lastSaved.by}` : ''}
              </span>
            )}
          </>
        }
      />
      <div className="grid flex-1 grid-cols-1 gap-4 xl:grid-cols-[216px_minmax(0,1fr)] xl:gap-8">
        <SubNav active={section} tails={tails} />
        <div className="flex min-w-0 flex-col gap-5" data-testid="settings-body">
          {cfgQ.error ? (
            <Card flush><ErrorState error={cfgQ.error} onRetry={cfgQ.refetch} /></Card>
          ) : !ctx ? (
            <SettingsSkeleton />
          ) : !sec && section !== 'lich-su' ? (
            <Card><p className="text-muted-foreground">Không có mục cấu hình này. <Link className="font-semibold text-foreground underline" to="/settings">Về mục Chung</Link></p></Card>
          ) : section === 'chung' ? (
            <GeneralSection c={ctx} />
          ) : section === 'truy-cap' ? (
            <AccessSection c={ctx} busy={maintenance.isPending} onMaintenance={(on) => (on ? setMaintenanceAsk(true) : maintenance.mutate(false))} />
          ) : section === 'email' ? (
            <EmailSection c={ctx} smtpDirty={dirtyKeys.some((k) => k.startsWith('smtp.'))} />
          ) : section === 'mat-khau' ? (
            <PasswordSection c={ctx} />
          ) : section === 'nghiep-vu' ? (
            <BusinessSection c={ctx} />
          ) : section === 'ung-dung' ? (
            <MobileSection c={ctx} />
          ) : section === 'tro-ly' ? (
            <AiSection c={ctx} />
          ) : (
            <HistorySection />
          )}

          {dirty && (
            <div className="sticky bottom-6 z-10 mt-auto flex items-center gap-3 rounded-[16px] border border-border bg-card py-3 pr-3 pl-4 shadow-pop" data-testid="savebar">
              <Bubble size="sm"><PencilLine /></Bubble>
              <div className="min-w-0 flex-1">
                <p className="text-sm leading-[1.4] font-semibold tabular-nums" data-testid="savebar-count">{formatNumber(dirtyKeys.length)} thay đổi chưa lưu</p>
                <p className="truncate text-[13px] leading-[1.45] text-muted-foreground" data-testid="savebar-detail">
                  {errorKeys.length ? (
                    <><span className="text-destructive">{formatNumber(errorKeys.length)} lỗi cần sửa trước khi lưu:</span> {errorKeys.map((k) => DEF.get(k)?.label ?? k).join(', ')}</>
                  ) : (
                    Object.entries(counts).filter(([, n]) => n).map(([slug, n]) => `${SECTIONS.find((s) => s.slug === slug)!.short} (${n})`).join(' · ')
                  )}
                </p>
              </div>
              <Button variant="secondary" onClick={() => { setDraft({}); setServerErrors({}) }} disabled={save.isPending} data-testid="savebar-cancel">Hủy</Button>
              <Button onClick={() => save.mutate()} disabled={errorKeys.length > 0 || save.isPending} data-testid="savebar-save">Lưu thay đổi</Button>
            </div>
          )}
        </div>
      </div>

      {ctx && (
        <MaintenanceDialog
          open={maintenanceAsk}
          onClose={() => setMaintenanceAsk(false)}
          activeUsers={ctx.cfg.stats.activeUsers}
          message={String(ctx.value('access.maintenanceMessage')).trim()}
          endsAt={fromDraft(DEF.get('access.maintenanceEndsAt')!, ctx.value('access.maintenanceEndsAt')) as string | null}
          error={errors['access.maintenanceMessage'] ?? errors['access.maintenanceEndsAt']}
          onConfirm={() => maintenance.mutate(true)}
        />
      )}
      <ConfirmDialog options={leaveOptions} onClose={() => { if (!leaving.current) blocker.reset?.(); leaving.current = false }} />
    </>
  )
}

function SubNav({ active, tails }: { active: string; tails: Record<string, ReactNode> }) {
  const item = (slug: string, label: string, Icon: typeof Mail) => (
    <Link
      key={slug}
      to={`/settings/${slug}`}
      aria-current={active === slug ? 'page' : undefined}
      data-testid={`snav-${slug}`}
      className={cn(
        'flex h-10 items-center gap-2.5 rounded-sm px-3 text-sm font-medium whitespace-nowrap text-nav transition-colors hover:bg-muted/60',
        active === slug && 'bg-muted-high font-semibold text-foreground hover:bg-muted-high [&_svg]:text-foreground [&_svg]:[stroke-width:2]',
      )}
    >
      <Icon className="size-[17px] text-nav-icon" />
      <span>{label}</span>
      {tails[slug] && <span className="ml-auto inline-flex items-center gap-1.5">{tails[slug]}</span>}
    </Link>
  )
  const all = [...SECTIONS, { slug: 'lich-su', label: 'Lịch sử thay đổi', icon: History }]
  return (
    <>
      <nav className="sticky top-9 hidden flex-col gap-0.5 self-start xl:flex" aria-label="Mục cấu hình" data-testid="settings-nav">
        {SECTIONS.map((s) => item(s.slug, s.label, s.icon))}
        <div className="mx-3 my-2.5 h-px bg-border" />
        {item('lich-su', 'Lịch sử thay đổi', History)}
        <p className="px-3 pt-2.5 text-xs leading-normal text-faint">Thay đổi áp dụng cho app trong vòng 1 phút sau khi lưu.</p>
      </nav>
      <nav className="flex gap-2 overflow-x-auto [mask-image:linear-gradient(90deg,#000_88%,transparent)] [scrollbar-width:none] xl:hidden" aria-label="Mục cấu hình">
        {all.map((s) => (
          <Link
            key={s.slug}
            to={`/settings/${s.slug}`}
            aria-current={active === s.slug ? 'page' : undefined}
            className={cn(
              'inline-flex h-[34px] shrink-0 items-center gap-1.5 rounded-full border px-3.5 text-[13.5px] font-medium whitespace-nowrap',
              active === s.slug ? 'border-primary bg-primary text-primary-foreground' : 'border-border bg-card hover:bg-hover',
            )}
          >
            {s.label}
            {tails[s.slug]}
          </Link>
        ))}
      </nav>
    </>
  )
}

function SettingsSkeleton() {
  return (
    <div className="flex flex-col gap-5" data-testid="loading" aria-busy="true">
      <div><Skeleton className="h-5 w-40" /><Skeleton className="mt-3 h-3 w-80" /></div>
      {[3, 2].map((rows, i) => (
        <Card flush key={i}>
          <div className="border-b border-line px-6 py-5"><Skeleton className="h-4 w-36" /></div>
          {Array.from({ length: rows }, (_, j) => (
            <div key={j} className="grid grid-cols-[1fr_420px] gap-10 border-t border-line px-6 py-5 first:border-0">
              <div><Skeleton className="h-3.5 w-32" /><Skeleton className="mt-2.5 h-3 w-64" /></div>
              <Skeleton className="h-10 w-full rounded-sm" />
            </div>
          ))}
        </Card>
      ))}
    </div>
  )
}

/* ============================== Ô nhập dùng chung ============================== */

function TextSetting({ c, k, icon, placeholder, link, testId, className, type }: {
  c: Ctx
  k: string
  icon?: ReactNode
  placeholder?: string
  link?: boolean
  testId?: string
  className?: string
  type?: string
}) {
  const v = String(c.value(k))
  const def = DEF.get(k)!
  const valid = link && /^https:\/\/[^\s/]+\.[^\s]+$/.test(v.trim())
  return (
    <Input
      value={v}
      type={type}
      onChange={(e) => c.set(k, e.target.value)}
      aria-label={def.label}
      aria-invalid={!!c.error(k)}
      maxLength={def.maxLen ? def.maxLen + 20 : undefined}
      placeholder={placeholder}
      icon={icon}
      data-testid={testId ?? `in-${k}`}
      wrapperClassName={className}
      end={link ? (
        <a href={valid ? v.trim() : undefined} target="_blank" rel="noreferrer" aria-label="Mở link" className={cn('flex text-muted-foreground [&_svg]:size-4', valid ? 'cursor-pointer hover:text-foreground' : 'pointer-events-none opacity-60')}>
          <ExternalLink />
        </a>
      ) : undefined}
    />
  )
}

/** Hàng nhập số có đơn vị + khoảng hợp lệ + "Trước" + lỗi. */
function NumberRow({ c, k, desc, range }: { c: Ctx; k: string; desc: ReactNode; range: string }) {
  const def = DEF.get(k)!
  return (
    <SettingRow label={labelOf(k, def.label)} desc={desc} changed={c.isDirty(k)} testId={`row-${k}`}>
      <div className="flex items-center gap-3">
        <NumberBox c={c} k={k} />
        <span className="text-body-s text-faint">{range}</span>
      </div>
      {c.isDirty(k) && <Was>{display(k, c.server(k))}</Was>}
      <FieldError>{c.error(k)}</FieldError>
    </SettingRow>
  )
}

/** Nhãn hiển thị theo mockup (một số khác nhãn dùng trong lịch sử). */
const ROW_LABEL: Record<string, string> = {
  'password.minLength': 'Độ dài tối thiểu',
  'password.otpExpiryMinutes': 'Hết hạn sau',
  'password.otpMaxAttempts': 'Số lần nhập sai tối đa',
  'password.otpResendSeconds': 'Chờ trước khi gửi lại',
}
const labelOf = (k: string, fallback: string) => ROW_LABEL[k] ?? fallback

function NumberBox({ c, k, width = 148 }: { c: Ctx; k: string; width?: number }) {
  const def = DEF.get(k)!
  return (
    <div style={{ width }} className="shrink-0">
      <Input
        value={String(c.value(k))}
        onChange={(e) => c.set(k, e.target.value.replace(/[^\d]/g, ''))}
        inputMode="numeric"
        aria-label={def.label}
        aria-invalid={!!c.error(k)}
        className="tabular-nums"
        data-testid={`in-${k}`}
        end={def.unit ? <span className="text-[13.5px] whitespace-nowrap text-muted-foreground">{def.unit}</span> : undefined}
      />
    </div>
  )
}

/** Hàng chữ (link, email, …) với "Trước" + lỗi. */
function TextRow({ c, k, desc, icon, link, placeholder }: { c: Ctx; k: string; desc?: ReactNode; icon?: ReactNode; link?: boolean; placeholder?: string }) {
  return (
    <SettingRow label={DEF.get(k)!.label} desc={desc} changed={c.isDirty(k)} testId={`row-${k}`}>
      <TextSetting c={c} k={k} icon={icon} link={link} placeholder={placeholder} />
      {c.isDirty(k) && !c.error(k) && <Was>{display(k, c.server(k))}</Was>}
      <FieldError>{c.error(k)}</FieldError>
    </SettingRow>
  )
}

/* ============================== Các mục ============================== */

function GeneralSection({ c }: { c: Ctx }) {
  return (
    <>
      <SectionHead title="Chung" desc="Thông tin hiện trong app, trong email gửi người dùng và ở màn đăng nhập." />
      <SettingCard title="Thông tin ứng dụng">
        <TextRow c={c} k="general.appName" desc="Hiện ở màn đăng nhập, tiêu đề email và thông báo." />
        <TextRow c={c} k="general.supportEmail" desc="Nút “Liên hệ hỗ trợ” trong Cài đặt của app gửi tới địa chỉ này." icon={<Mail />} placeholder="vd. hotro@thuchi.vn" />
        <TextRow c={c} k="general.hotline" desc="Để trống thì app ẩn nút Gọi hỗ trợ." icon={<Phone />} placeholder="vd. 1900 6868" />
      </SettingCard>
      <SettingCard title="Pháp lý" aside={<span className="text-body-s font-medium text-muted-foreground">Mở bằng trình duyệt trong app</span>}>
        <TextRow c={c} k="general.termsUrl" desc="Hiện ở màn đăng ký và trong Cài đặt." link placeholder="https://" />
        <TextRow c={c} k="general.privacyUrl" desc="Hiện ở màn đăng ký và trong Cài đặt." link placeholder="https://" />
      </SettingCard>
      <SettingCard>
        <SettingRow label="Tiền tệ hiển thị" desc="Cố định cho toàn hệ thống.">
          <Input value="VND · Việt Nam đồng" disabled icon={<Lock />} aria-label="Tiền tệ hiển thị" readOnly />
          <Help>Số tiền lưu là số nguyên đồng, không có phần lẻ. Ví dụ 1.250.000đ.</Help>
        </SettingRow>
      </SettingCard>
    </>
  )
}

function AccessSection({ c, onMaintenance, busy }: { c: Ctx; onMaintenance: (on: boolean) => void; busy: boolean }) {
  const m = c.cfg.maintenance
  const msg = String(c.value('access.maintenanceMessage'))
  const endsRef = useRef<HTMLInputElement>(null)
  const since = m.startedAt ? formatTime(m.startedAt) : ''
  return (
    <>
      {m.enabled && (
        <Banner
          testId="maintenance-banner"
          icon={<Construction />}
          title={`Ứng dụng đang bảo trì từ ${since}${m.endsAt ? `, tự tắt lúc ${display('access.maintenanceEndsAt', m.endsAt)}` : ''}`}
          action={<Button variant="secondary" size="sm" className="h-[34px] px-3.5 text-[13.5px]" onClick={() => onMaintenance(false)} disabled={busy} data-testid="maintenance-off">Tắt bảo trì</Button>}
        >
          Người dùng app thấy thông báo bảo trì và không đăng nhập, đồng bộ được. Bảng quản trị vẫn dùng bình thường.
        </Banner>
      )}
      <SectionHead title="Đăng ký & truy cập" desc="Ai được vào app, và vào trong bao lâu." />
      <SettingCard
        testId="maintenance-card"
        className={cn(m.enabled && 'border-[#EFD999] shadow-[0_0_0_3px_rgb(217_154_30/.10)]')}
        title="Chế độ bảo trì"
        aside={m.enabled
          ? <Badge variant="warning" data-testid="maintenance-badge"><Construction />Đang bật · {since}{m.startedBy ? ` bởi ${m.startedBy}` : ''}</Badge>
          : <Badge data-testid="maintenance-badge">Đang tắt</Badge>}
      >
        <SettingRow label="Bật bảo trì" desc="Có hiệu lực ngay, không cần bấm Lưu. Tài khoản quản trị không bị chặn." inline>
          <Switch tone="warn" checked={m.enabled} disabled={busy} onCheckedChange={onMaintenance} aria-label="Bật bảo trì" data-testid="maintenance-switch" />
        </SettingRow>
        <SettingRow label="Thông báo cho người dùng" desc="Hiện toàn màn hình trong app khi đang bảo trì." changed={c.isDirty('access.maintenanceMessage')} testId="row-access.maintenanceMessage">
          <Textarea
            rows={2}
            value={msg}
            onChange={(e) => c.set('access.maintenanceMessage', e.target.value)}
            aria-label="Thông báo cho người dùng"
            aria-invalid={!!c.error('access.maintenanceMessage')}
            data-testid="in-access.maintenanceMessage"
            className="min-h-11"
          />
          {c.error('access.maintenanceMessage')
            ? <FieldError>{c.error('access.maintenanceMessage')}</FieldError>
            : <Help className="flex justify-between"><span>Viết ngắn, nói rõ khi nào xong.</span><span className="tabular-nums">{msg.length}/200</span></Help>}
          {c.isDirty('access.maintenanceMessage') && <Was>{display('access.maintenanceMessage', c.server('access.maintenanceMessage'))}</Was>}
        </SettingRow>
        <SettingRow label="Dự kiến xong lúc" desc="Không bắt buộc. Tới giờ này bảo trì tự tắt, để trống thì chỉ tắt bằng tay." changed={c.isDirty('access.maintenanceEndsAt')} testId="row-access.maintenanceEndsAt">
          <div
            className={cn(
              'relative flex h-10 w-[240px] items-center gap-2.5 rounded-sm border border-input bg-card px-3.5 text-sm transition-[border-color,box-shadow] has-[input:focus-visible]:border-primary has-[input:focus-visible]:ring-3 has-[input:focus-visible]:ring-primary/6 [&_svg]:size-[17px] [&_svg]:shrink-0 [&_svg]:text-muted-foreground',
              c.error('access.maintenanceEndsAt') && 'border-destructive-bar ring-3 ring-destructive-bar/8',
            )}
          >
            <CalendarClock />
            <span className={cn('flex-1 truncate tabular-nums', !c.value('access.maintenanceEndsAt') && 'text-faint')} data-testid="endsAt-text">
              {c.value('access.maintenanceEndsAt') ? display('access.maintenanceEndsAt', fromDraft(DEF.get('access.maintenanceEndsAt')!, c.value('access.maintenanceEndsAt'))) : 'Chọn giờ (không bắt buộc)'}
            </span>
            {/* Ô datetime-local thật phủ lên (trong suốt) để mở bộ chọn ngày giờ của trình duyệt; chữ hiển thị theo định dạng "23:30 · 25/09/2026" */}
            <input
              ref={endsRef}
              type="datetime-local"
              value={String(c.value('access.maintenanceEndsAt'))}
              onChange={(e) => c.set('access.maintenanceEndsAt', e.target.value)}
              onClick={(e) => e.currentTarget.showPicker?.()}
              aria-label="Dự kiến xong lúc"
              aria-invalid={!!c.error('access.maintenanceEndsAt')}
              data-testid="in-access.maintenanceEndsAt"
              className="absolute inset-0 cursor-pointer opacity-0"
            />
            {c.value('access.maintenanceEndsAt') && (
              <button type="button" aria-label="Xóa giờ dự kiến" className="relative z-10 flex cursor-pointer text-muted-foreground hover:text-foreground [&_svg]:size-4!" onClick={() => c.set('access.maintenanceEndsAt', '')} data-testid="clear-endsAt"><X /></button>
            )}
          </div>
          {c.isDirty('access.maintenanceEndsAt') && !c.error('access.maintenanceEndsAt') && <Was>{display('access.maintenanceEndsAt', c.server('access.maintenanceEndsAt'))}</Was>}
          <FieldError>{c.error('access.maintenanceEndsAt')}</FieldError>
        </SettingRow>
      </SettingCard>
      <SettingCard title="Đăng ký">
        <SettingRow label="Cho phép đăng ký mới" desc="Tắt thì màn Đăng ký trong app báo “Tạm ngưng nhận đăng ký”. Tài khoản đã có vẫn đăng nhập bình thường." inline changed={c.isDirty('access.registrationEnabled')} testId="row-access.registrationEnabled">
          <Switch checked={c.value('access.registrationEnabled') === true} onCheckedChange={(v) => c.set('access.registrationEnabled', v)} aria-label="Cho phép đăng ký mới" data-testid="in-access.registrationEnabled" />
          {c.isDirty('access.registrationEnabled') && <Was>{display('access.registrationEnabled', c.server('access.registrationEnabled'))}</Was>}
        </SettingRow>
      </SettingCard>
      <SettingCard title="Đăng nhập">
        <NumberRow c={c} k="access.sessionDays" desc="Hết hạn thì app yêu cầu đăng nhập lại." range="1–365 ngày" />
        <SettingRow label="Giới hạn đăng nhập sai" desc="Quá giới hạn thì tạm chặn đăng nhập của email đó tới hết khung thời gian." changed={c.isDirty('access.loginMaxAttempts') || c.isDirty('access.loginWindowMinutes')} testId="row-access.loginLimit">
          <div className="flex items-center gap-2.5">
            <NumberBox c={c} k="access.loginMaxAttempts" width={120} />
            <span className="text-muted-foreground">trong</span>
            <NumberBox c={c} k="access.loginWindowMinutes" width={128} />
          </div>
          {(c.isDirty('access.loginMaxAttempts') || c.isDirty('access.loginWindowMinutes')) && (
            <Was>{display('access.loginMaxAttempts', c.server('access.loginMaxAttempts'))} trong {display('access.loginWindowMinutes', c.server('access.loginWindowMinutes'))}</Was>
          )}
          <FieldError>{c.error('access.loginMaxAttempts') ?? c.error('access.loginWindowMinutes')}</FieldError>
        </SettingRow>
      </SettingCard>
    </>
  )
}

function MaintenanceDialog({ open, onClose, activeUsers, message, endsAt, error, onConfirm }: {
  open: boolean
  onClose: () => void
  activeUsers: number
  message: string
  endsAt: string | null
  error?: string
  onConfirm: () => void
}) {
  return (
    <AlertDialog open={open} onOpenChange={(o) => !o && onClose()}>
      <AlertDialogContent className="w-[480px]" data-testid="maintenance-dialog">
        <span className="flex size-14 items-center justify-center rounded-full bg-warning-soft text-warning [&_svg]:size-6"><Construction /></span>
        <AlertDialogTitle className="mt-[18px]">Bật chế độ bảo trì?</AlertDialogTitle>
        <AlertDialogDescription>Người dùng app sẽ thấy màn hình bảo trì và không đăng nhập, ghi hay đồng bộ giao dịch được cho tới khi bạn tắt. Bảng quản trị vẫn dùng bình thường.</AlertDialogDescription>
        <dl className="mt-[18px] rounded-md bg-background px-4 py-1">
          {([
            ['Ảnh hưởng', `${formatNumber(activeUsers)} người dùng đang hoạt động`],
            ['Dự kiến xong', endsAt ? display('access.maintenanceEndsAt', endsAt) : 'Không hẹn giờ, tắt bằng tay'],
            ['Hiệu lực', endsAt ? 'Ngay khi bấm Bật, tự tắt khi tới giờ' : 'Ngay khi bấm Bật'],
          ] as const).map(([k, v]) => (
            <div key={k} className="flex h-[42px] items-center justify-between gap-4 text-[13.5px] not-first:border-t not-first:border-border">
              <dt className="text-muted-foreground">{k}</dt>
              <dd className="truncate tabular-nums">{v}</dd>
            </div>
          ))}
        </dl>
        <div className="mt-3 rounded-md border border-border px-4 py-3">
          <p className="text-xs font-medium text-muted-foreground">Người dùng sẽ thấy</p>
          <p className="mt-1 text-body-s break-words" data-testid="maintenance-dialog-message">{message || '(chưa có nội dung)'}</p>
        </div>
        {error && <div className="mt-3"><FieldError>{error}</FieldError></div>}
        <div className="mt-6 flex gap-2.5">
          <AlertDialogCancel>Hủy</AlertDialogCancel>
          <AlertDialogAction
            className={cn(buttonVariants({ size: 'dialog' }), 'bg-warning-soft text-warning hover:bg-warning-soft/70')}
            disabled={!!error}
            onClick={onConfirm}
            data-testid="maintenance-confirm"
          >
            <Construction />Bật bảo trì
          </AlertDialogAction>
        </div>
      </AlertDialogContent>
    </AlertDialog>
  )
}

function EmailSection({ c, smtpDirty }: { c: Ctx; smtpDirty: boolean }) {
  const s = c.cfg.smtp
  const me = auth.user()
  const [result, setResult] = useState<SmtpTestResult | null>(null)
  const [replacing, setReplacing] = useState(false)
  const test = useMutation({
    mutationFn: api.testSmtp,
    onSuccess: (r) => {
      setResult(r)
      if (r.ok) notify.success('Đã gửi email thử', { description: `Thư tới ${r.to}. Nếu 2 phút chưa thấy, xem thư mục Spam.`, icon: <MailCheck /> })
      else notify.error('Gửi email thử thất bại', r.error)
    },
    onError: (e) => notify.error('Không gửi được email thử', e.message),
  })
  const showSaved = s.hasPassword && !replacing
  const canTest = s.configured && !smtpDirty
  const secondsText = (ms: number) => (ms < 1000 ? `${ms} ms` : `${new Intl.NumberFormat('vi-VN', { maximumFractionDigits: 1 }).format(ms / 1000)} giây`)
  return (
    <>
      {!s.configured && (
        <Banner icon={<MailWarning />} title="Chưa cấu hình SMTP · OTP chỉ ghi log" testId="smtp-banner">
          Người dùng quên mật khẩu sẽ không nhận được mã. Mã OTP hiện chỉ được ghi vào log máy chủ.
        </Banner>
      )}
      <SectionHead
        title="Email (SMTP)"
        desc="Máy chủ gửi mã OTP quên mật khẩu và các email hệ thống."
        aside={s.configured
          ? <Badge variant="success" data-testid="smtp-status"><CircleCheck />Đã cấu hình</Badge>
          : <Badge variant="warning" data-testid="smtp-status"><CircleAlert />Chưa cấu hình</Badge>}
      />
      <Card className="py-4 pr-5 pl-6">
        <div className="flex items-center gap-3.5">
          <Bubble size="sm"><Send /></Bubble>
          <div className="min-w-0 flex-1">
            <p className="text-sm font-semibold">Gửi email thử</p>
            <p className="text-body-s text-muted-foreground">
              {!s.configured ? 'Lưu cấu hình trước khi gửi thử.' : smtpDirty ? 'Lưu thay đổi trước khi gửi thử, thư gửi bằng cấu hình đã lưu.' : `Tới ${me?.email ?? 'email của bạn'}, dùng cấu hình đã lưu.`}
            </p>
          </div>
          <Button variant={canTest ? 'secondary' : 'default'} disabled={!canTest || test.isPending} onClick={() => test.mutate()} data-testid="smtp-test">
            <Send />{test.isPending ? 'Đang gửi…' : 'Gửi email thử'}
          </Button>
        </div>
        {result && (
          <div
            data-testid="smtp-result"
            data-ok={result.ok}
            className={cn('mt-3 flex items-start gap-2.5 rounded-md px-3.5 py-3 text-[13px] leading-normal [&_b]:font-semibold [&_b]:text-foreground [&>svg]:mt-px [&>svg]:size-[17px] [&>svg]:shrink-0',
              result.ok ? 'bg-success-soft text-[#2E5A36] [&>svg]:text-income' : 'bg-destructive-soft text-destructive')}
          >
            {result.ok ? <CircleCheck /> : <CircleAlert />}
            {result.ok ? (
              <span>Gửi thành công lúc {formatTime(result.at)}. Máy chủ trả về <b>{(result.response ?? 'OK').slice(0, 60)}</b> sau {secondsText(result.durationMs)}.</span>
            ) : (
              <span className="min-w-0 break-words">Gửi thất bại lúc {formatTime(result.at)} sau {secondsText(result.durationMs)}. Máy chủ báo: <b>{result.error}</b></span>
            )}
          </div>
        )}
      </Card>
      <SettingCard title="Máy chủ gửi thư">
        <SettingRow label="Máy chủ và cổng" changed={c.isDirty('smtp.host') || c.isDirty('smtp.port')} testId="row-smtp.host">
          <div className="flex gap-2.5">
            <TextSetting c={c} k="smtp.host" placeholder="vd. smtp.gmail.com" className="flex-1" />
            <div className="w-[92px] shrink-0">
              <Input value={String(c.value('smtp.port'))} onChange={(e) => c.set('smtp.port', e.target.value.replace(/[^\d]/g, ''))} inputMode="numeric" placeholder="Cổng"
                aria-label="Cổng" aria-invalid={!!c.error('smtp.port')} className="tabular-nums" data-testid="in-smtp.port" />
            </div>
          </div>
          {(c.isDirty('smtp.host') || c.isDirty('smtp.port')) && <Was>{display('smtp.host', c.server('smtp.host'))} · cổng {String(c.server('smtp.port'))}</Was>}
          <FieldError>{c.error('smtp.host') ?? c.error('smtp.port')}</FieldError>
        </SettingRow>
        <SettingRow label="Bảo mật" desc="STARTTLS thường dùng cổng 587, SSL/TLS dùng cổng 465." changed={c.isDirty('smtp.security')} testId="row-smtp.security">
          <Tabs value={String(c.value('smtp.security'))} onValueChange={(v) => c.set('smtp.security', v)} className="self-start">
            <TabsList data-testid="in-smtp.security">
              {Object.entries(SECURITY_LABEL).map(([v, l]) => <TabsTrigger key={v} value={v}>{l}</TabsTrigger>)}
            </TabsList>
          </Tabs>
          {c.isDirty('smtp.security') && <Was>{display('smtp.security', c.server('smtp.security'))}</Was>}
        </SettingRow>
        <TextRow c={c} k="smtp.user" placeholder="Tài khoản SMTP" />
        <SettingRow label="Mật khẩu" desc="Không bao giờ hiển thị lại sau khi lưu." changed={c.isDirty('smtp.password')} testId="row-smtp.password">
          {showSaved ? (
            <>
              <div className="flex gap-2.5">
                <div className="flex h-10 min-w-0 flex-1 items-center gap-2.5 rounded-sm border border-input bg-background px-3.5" data-testid="smtp-password-saved">
                  <span className="flex-1 tracking-[2px] text-muted-foreground">••••••••••••</span>
                  <Badge variant="success" className="h-[22px]"><Lock />Đã lưu</Badge>
                </div>
                <Button variant="secondary" onClick={() => setReplacing(true)} data-testid="smtp-password-replace"><KeyRound />Thay mật khẩu</Button>
              </div>
              {s.passwordSavedAt
                ? <Help>Lưu lúc {formatTime(s.passwordSavedAt)} · {formatDayMonth(s.passwordSavedAt)}{s.passwordSavedBy ? ` bởi ${s.passwordSavedBy}` : ''}</Help>
                : <Help>Đang dùng mật khẩu trong cấu hình máy chủ (SMTP_PASS).</Help>}
            </>
          ) : (
            <>
              <div className="flex gap-2.5">
                <div className="min-w-0 flex-1">
                  <PasswordInput
                    value={String(c.value('smtp.password'))}
                    onChange={(e) => c.set('smtp.password', e.target.value)}
                    placeholder={s.hasPassword ? 'Mật khẩu mới' : 'Mật khẩu ứng dụng'}
                    aria-label="Mật khẩu SMTP"
                    autoComplete="new-password"
                    data-testid="in-smtp.password"
                  />
                </div>
                {s.hasPassword && <Button variant="ghost" onClick={() => { setReplacing(false); c.reset('smtp.password') }}>Giữ mật khẩu cũ</Button>}
              </div>
              {c.isDirty('smtp.password') && <Help>Mật khẩu được mã hóa khi lưu và không hiển thị lại.</Help>}
            </>
          )}
        </SettingRow>
        <TextRow c={c} k="smtp.from" desc="Người nhận thấy tên và địa chỉ này." placeholder="vd. Thu Chi <no-reply@thuchi.vn>" />
      </SettingCard>
    </>
  )
}

function PasswordSection({ c }: { c: Ctx }) {
  const v = (k: string) => String(c.value(k)) || '…'
  const steps = [
    { icon: Mail, text: 'Nhận mã 6 số qua email' },
    { icon: Timer, text: `Mã dùng được trong ${v('password.otpExpiryMinutes')} phút` },
    { icon: RotateCcw, text: `Gửi lại mã sau ${v('password.otpResendSeconds')} giây` },
    { icon: ShieldX, text: `Nhập sai ${v('password.otpMaxAttempts')} lần thì mã bị hủy` },
  ]
  return (
    <>
      <SectionHead title="Mật khẩu & OTP" desc="Quy tắc mật khẩu và mã xác thực khi người dùng quên mật khẩu." />
      <SettingCard title="Mật khẩu">
        <NumberRow c={c} k="password.minLength" desc="Áp dụng khi đăng ký, đổi và đặt lại mật khẩu. Mật khẩu cũ không bị bắt đổi." range="6–64 ký tự" />
      </SettingCard>
      <SettingCard title="Mã OTP quên mật khẩu" aside={<span className="text-body-s font-medium text-muted-foreground">Mã 6 chữ số, gửi qua email</span>}>
        <NumberRow c={c} k="password.otpExpiryMinutes" desc="Tính từ lúc gửi mã." range="1–60 phút" />
        <NumberRow c={c} k="password.otpMaxAttempts" desc="Quá số lần thì mã bị hủy, người dùng phải gửi mã mới." range="1–10 lần" />
        <NumberRow c={c} k="password.otpResendSeconds" desc="Nút “Gửi lại mã” trong app mờ đi trong khoảng này." range="30–600 giây, phải ngắn hơn thời hạn mã" />
      </SettingCard>
      <Card className="bg-background shadow-none" data-testid="otp-summary">
        <p className="text-body-s font-medium text-muted-foreground">Người dùng quên mật khẩu sẽ</p>
        <div className="mt-3.5 grid grid-cols-4 gap-4">
          {steps.map((s, i) => (
            <div key={i} className="flex items-start gap-3">
              <Bubble size="sm" className="bg-card"><s.icon /></Bubble>
              <div>
                <p className="text-xs text-faint tabular-nums">Bước {i + 1}</p>
                <p className="text-[13.5px] leading-[1.45] font-medium">{s.text}</p>
              </div>
            </div>
          ))}
        </div>
      </Card>
    </>
  )
}

function BusinessSection({ c }: { c: Ctx }) {
  const w = Number(c.value('business.budgetWarningPercent')) || 0
  const x = Number(c.value('business.budgetExceededPercent')) || 0
  const scale = Math.max(x + 20, w + 20, 120)
  const pctOf = (p: number) => `${Math.min(100, Math.max(0, (p / scale) * 100))}%`
  const counts: Record<string, string> = {
    featureSavingGoals: `${formatNumber(c.cfg.stats.savingGoals)} mục tiêu`,
    featureRecurring: `${formatNumber(c.cfg.stats.recurringRules)} lịch`,
  }
  const budgetErr = c.error('business.budgetWarningPercent') ?? c.error('business.budgetExceededPercent')
  const budgetBox = (k: string, label: string) => (
    <div className="flex flex-1 flex-col gap-2">
      <label className="flex items-center gap-2 text-[13px] font-medium text-muted-foreground">{label}{c.isDirty(k) && <span className="size-1.5 rounded-full bg-primary" />}</label>
      <Input value={String(c.value(k))} onChange={(e) => c.set(k, e.target.value.replace(/[^\d]/g, ''))} inputMode="numeric" aria-label={label}
        aria-invalid={!!c.error(k)} className="tabular-nums" data-testid={`in-${k}`} end={<span className="text-[13.5px] text-muted-foreground">%</span>} />
      {c.isDirty(k) && <Was>{display(k, c.server(k))}</Was>}
    </div>
  )
  return (
    <>
      <SectionHead title="Nghiệp vụ" desc="Giá trị mặc định và tính năng người dùng thấy trong app." />
      <div className="grid grid-cols-1 items-start gap-5 xl:grid-cols-2">
        <div className="flex flex-col gap-5">
          <Card data-testid="budget-card">
            <h3 className="text-title-m">Cảnh báo ngân sách</h3>
            <div className="mt-5 flex items-start gap-4">
              {budgetBox('business.budgetWarningPercent', 'Sắp hết khi chi tới')}
              {budgetBox('business.budgetExceededPercent', 'Vượt khi chi tới')}
            </div>
            {budgetErr && <div className="mt-2"><FieldError>{budgetErr}</FieldError></div>}
            <div className="mt-5" data-testid="budget-preview">
              <div className="flex h-2 overflow-hidden rounded-full bg-muted">
                <i className="block h-full bg-primary" style={{ width: pctOf(w) }} />
                <i className="block h-full bg-warning-bar" style={{ width: `calc(${pctOf(x)} - ${pctOf(w)})` }} />
                <i className="block h-full flex-1 bg-destructive-bar" />
              </div>
              <div className="relative mt-2 h-[18px] text-xs text-muted-foreground tabular-nums">
                <span className="absolute left-0">0%</span>
                <span className="absolute -translate-x-1/2" style={{ left: pctOf(w) }} data-testid="budget-preview-warning">{w}%</span>
                <span className="absolute -translate-x-1/2" style={{ left: pctOf(x) }} data-testid="budget-preview-exceeded">{x}%</span>
              </div>
            </div>
            <p className="mt-3 text-body-s text-muted-foreground">Thanh ngân sách trong app chuyển vàng ở {w}% kèm thông báo “Sắp hết ngân sách”, chuyển đỏ khi vượt {x}%. Ngưỡng cảnh báo phải nhỏ hơn ngưỡng vượt.</p>
          </Card>
          <Card>
            <h3 className="text-title-m">Ví mặc định</h3>
            <div className="mt-5 flex flex-col gap-2">
              <label className="flex items-center gap-2 text-[13px] font-medium text-muted-foreground">Tên ví tạo sẵn khi đăng ký{c.isDirty('business.defaultWalletName') && <span className="size-1.5 rounded-full bg-primary" />}</label>
              <TextSetting c={c} k="business.defaultWalletName" icon={<Banknote />} />
              {c.error('business.defaultWalletName')
                ? <FieldError>{c.error('business.defaultWalletName')}</FieldError>
                : <Help>Chỉ áp dụng cho tài khoản mới. Người dùng đổi tên được.</Help>}
              {c.isDirty('business.defaultWalletName') && <Was>{display('business.defaultWalletName', c.server('business.defaultWalletName'))}</Was>}
            </div>
          </Card>
        </div>
        <Card flush data-testid="features-card">
          <div className="px-6 pt-5 pb-3.5">
            <h3 className="text-title-m">Tính năng trong app</h3>
            <p className="mt-1 text-body-s font-medium text-muted-foreground">Tắt thì ẩn khỏi app, dữ liệu cũ vẫn được giữ.</p>
          </div>
          {FEATURES.map((f) => {
            const k = featureKey(f.field)
            const on = c.value(k) === true
            const offSince = !on && !c.isDirty(k) && c.cfg.updated[k] ? `Tắt từ ${formatDayMonth(c.cfg.updated[k].at)}` : ''
            const meta = offSince || (on ? counts[f.field] : '')
            return (
              <div key={f.field} className="flex items-center gap-3.5 border-t border-line px-6 py-3.5" data-testid={`feature-${f.field}`}>
                <Bubble className={cn(!on && 'text-faint')}><f.icon /></Bubble>
                <div className="min-w-0 flex-1">
                  <p className="flex items-center gap-2 text-sm font-semibold">{f.label}{c.isDirty(k) && <span className="size-1.5 rounded-full bg-primary" data-testid="changed-dot" />}</p>
                  <p className="mt-px text-body-s text-muted-foreground">{f.desc}{meta && <> · <span className="tabular-nums">{meta}</span></>}{c.isDirty(k) && <> · Trước: {display(k, c.server(k))}</>}</p>
                </div>
                <Switch checked={on} onCheckedChange={(v) => c.set(k, v)} aria-label={f.label} data-testid={`in-${k}`} />
              </div>
            )
          })}
        </Card>
      </div>
    </>
  )
}

/** Bản ngay dưới `v` để minh họa máy cũ (1.2.0 -> 1.1.9). */
function belowVersion(v: string) {
  if (!VERSION_RE.test(v)) return 'cũ'
  const [a, b, c] = v.split('.').map(Number)
  if (c > 0) return `${a}.${b}.${c - 1}`
  if (b > 0) return `${a}.${b - 1}.9`
  if (a > 0) return `${a - 1}.9.9`
  return 'cũ'
}

function MobileSection({ c }: { c: Ctx }) {
  const [mode, setMode] = useState<'force' | 'suggest'>('force')
  const notes = String(c.value('mobile.releaseNotes'))
  const latest = String(c.value('mobile.androidLatestVersion'))
  const min = String(c.value('mobile.androidMinVersion'))
  const appName = String(c.server('general.appName') ?? 'Thu Chi')
  const versionBox = (k: string, label: string) => (
    <div className="flex flex-col gap-2">
      <label className="flex items-center gap-2 text-[13px] font-medium text-muted-foreground">{label}{c.isDirty(k) && <span className="size-1.5 rounded-full bg-primary" />}</label>
      <TextSetting c={c} k={k} className="tabular-nums" />
      {c.isDirty(k) && !c.error(k) && <Was>{display(k, c.server(k))}</Was>}
      <FieldError>{c.error(k)}</FieldError>
    </div>
  )
  const platform = (p: 'android' | 'ios', name: string, store: string) => (
    <div className={cn(p === 'ios' && 'mt-5 border-t border-line pt-5')} data-testid={`platform-${p}`}>
      <h3 className="text-title-m">{name}</h3>
      <div className="mt-3 grid grid-cols-2 gap-3.5">
        {versionBox(`mobile.${p}LatestVersion`, 'Phiên bản mới nhất')}
        {versionBox(`mobile.${p}MinVersion`, 'Tối thiểu, bắt buộc cập nhật')}
      </div>
      <div className="mt-3 flex flex-col gap-2">
        <label className="flex items-center gap-2 text-[13px] font-medium text-muted-foreground">Link {store}{c.isDirty(`mobile.${p}StoreUrl`) && <span className="size-1.5 rounded-full bg-primary" />}</label>
        <TextSetting c={c} k={`mobile.${p}StoreUrl`} link placeholder="https://" />
        {c.isDirty(`mobile.${p}StoreUrl`) && !c.error(`mobile.${p}StoreUrl`) && <Was>{display(`mobile.${p}StoreUrl`, c.server(`mobile.${p}StoreUrl`))}</Was>}
        <FieldError>{c.error(`mobile.${p}StoreUrl`)}</FieldError>
      </div>
    </div>
  )
  const lines = notes.split('\n').map((l) => l.trim()).filter(Boolean)
  return (
    <>
      <SectionHead title="Ứng dụng di động" desc="Máy dưới bản tối thiểu phải cập nhật mới dùng tiếp. Máy dưới bản mới nhất chỉ được gợi ý, có nút Để sau." />
      <div className="grid grid-cols-1 items-start gap-5 xl:grid-cols-[minmax(0,1fr)_340px]">
        <div className="flex min-w-0 flex-col gap-5">
          <Card>
            {platform('android', 'Android', 'CH Play')}
            {platform('ios', 'iOS', 'App Store')}
          </Card>
          <Card>
            <div className="flex flex-col gap-2">
              <label htmlFor="release-notes" className="flex justify-between text-[13px] font-medium text-muted-foreground">
                <span className="flex items-center gap-2">Ghi chú cập nhật{c.isDirty('mobile.releaseNotes') && <span className="size-1.5 rounded-full bg-primary" />}</span>
                <span className="font-normal text-faint tabular-nums">{notes.length}/300</span>
              </label>
              <Textarea id="release-notes" rows={3} value={notes} onChange={(e) => c.set('mobile.releaseNotes', e.target.value)} aria-invalid={!!c.error('mobile.releaseNotes')} data-testid="in-mobile.releaseNotes" placeholder="• Mỗi dòng một ý" />
              {c.error('mobile.releaseNotes') ? <FieldError>{c.error('mobile.releaseNotes')}</FieldError> : <Help>Hiện trong hộp “Cần cập nhật”. Mỗi dòng một ý.</Help>}
            </div>
          </Card>
        </div>
        <Card className="flex flex-col items-center bg-background p-5 shadow-none" data-testid="update-preview">
          <div className="flex w-full items-center justify-between">
            <h3 className="text-title-m">Xem trước</h3>
            <Tabs value={mode} onValueChange={(v) => setMode(v as 'force' | 'suggest')}>
              <TabsList size="sm">
                <TabsTrigger value="force">Bắt buộc</TabsTrigger>
                <TabsTrigger value="suggest">Gợi ý</TabsTrigger>
              </TabsList>
            </Tabs>
          </div>
          <div className="relative mt-6 h-[480px] w-[300px] overflow-hidden rounded-[40px] bg-background text-[13px] shadow-[0_0_0_8px_#fff,0_0_0_9px_var(--color-border),var(--shadow-pop)]">
            <div className="flex h-10 items-center justify-between pt-1.5 pr-[26px] pl-[30px] text-[13px] font-semibold">
              <span className="tabular-nums">09:41</span>
              <span className="absolute top-[9px] left-1/2 h-[26px] w-[92px] -translate-x-1/2 rounded-[14px] bg-[#0b0b0b]" />
              <span className="flex items-center gap-1 [&_svg]:size-3.5"><Signal /><Wifi /></span>
            </div>
            <div className="px-4 pt-2">
              <p className="text-xs text-muted-foreground">Chào buổi sáng</p>
              <p className="text-xl font-bold tracking-[-0.02em]">Minh Anh</p>
              <div className="mt-3 rounded-[16px] border border-border bg-card px-3.5 py-3"><p className="text-xs text-muted-foreground">Tổng số dư</p><p className="text-[22px] font-bold tracking-[-0.02em] tabular-nums">26.022.000đ</p></div>
            </div>
            <div className="absolute inset-0 bg-scrim" />
            <div className="absolute inset-x-0 bottom-0 rounded-t-[24px] bg-card px-[18px] pt-2 pb-[22px] text-center">
              <div className="mx-auto mb-3.5 h-1 w-9 rounded-sm bg-[#DAD8D2]" />
              <Bubble size="lg"><Download /></Bubble>
              <p className="mt-2.5 text-base font-bold tracking-[-0.01em]" data-testid="preview-title">{mode === 'force' ? `Cần cập nhật ${appName}` : `Đã có ${appName} ${latest}`}</p>
              <p className="mt-1 text-xs leading-normal text-muted-foreground" data-testid="preview-text">
                {mode === 'force'
                  ? `Bản ${belowVersion(min)} trên máy không còn được hỗ trợ. Cập nhật lên ${latest} để tiếp tục dùng.`
                  : `Bản mới có nhiều cải tiến. Cập nhật lên ${latest} để dùng ngay.`}
              </p>
              {lines.length > 0 && (
                <div className="mt-3 rounded-sm bg-muted px-3 py-2.5 text-left text-[11.5px] leading-[1.55] text-ink-soft" data-testid="preview-notes">
                  <p className="mb-0.5 font-semibold text-foreground">Có gì mới</p>
                  {lines.map((l, i) => <p key={i}>{l.startsWith('•') ? l : `• ${l}`}</p>)}
                </div>
              )}
              <div className="mt-3.5 flex h-10 items-center justify-center rounded-full bg-primary text-[13px] font-semibold text-primary-foreground">Cập nhật trên CH Play</div>
              {mode === 'suggest' && <div className="mt-1.5 flex h-9 items-center justify-center text-[13px] font-semibold text-muted-foreground">Để sau</div>}
            </div>
          </div>
          <p className="mt-[18px] max-w-[290px] text-center text-body-s text-muted-foreground">
            {mode === 'force'
              ? `Hiện khi máy dưới ${min}. Bắt buộc thì không có nút Để sau và không vuốt tắt được.`
              : `Hiện khi máy từ ${min} tới dưới ${latest}. Có nút Để sau.`}
          </p>
        </Card>
      </div>
    </>
  )
}

const HISTORY_PAGE = 8

function HistorySection() {
  const [filter, setFilter] = useState<ConfigSection | undefined>()
  const [page, setPage] = useState(1)
  const q = useQuery({
    queryKey: ['config-history', filter, page],
    queryFn: () => api.configHistory({ section: filter, page, limit: HISTORY_PAGE }),
    placeholderData: (prev) => prev,
  })
  const all = useQuery({ queryKey: ['config-history', 'count'], queryFn: () => api.configHistory({ limit: 1 }) })
  const pick = (s?: ConfigSection) => { setFilter(s); setPage(1) }
  return (
    <>
      <SectionHead title="Lịch sử thay đổi" desc="Mọi lần lưu cấu hình, kể cả bật và tắt bảo trì. Giá trị bí mật luôn ẩn." />
      <div className="flex flex-wrap gap-2" data-testid="history-filter">
        <Chip on={!filter} onClick={() => pick()} testId="history-chip-all">Tất cả {all.data && <span className="c tabular-nums">{formatNumber(all.data.total)}</span>}</Chip>
        {SECTIONS.map((s) => <Chip key={s.api} on={filter === s.api} onClick={() => pick(s.api)} testId={`history-chip-${s.api}`}>{s.short}</Chip>)}
      </div>
      <Card flush>
        {q.error ? (
          <ErrorState error={q.error} onRetry={q.refetch} />
        ) : !q.data ? (
          <TableSkeleton rows={6} />
        ) : q.data.items.length === 0 ? (
          <p className="px-6 py-8 text-muted-foreground" data-testid="history-empty">Chưa có thay đổi nào{filter ? ` ở mục ${SECTION_SHORT[filter]}` : ''}.</p>
        ) : (
          <>
            <Table className="table-fixed">
              <colgroup><col className="w-[88px]" /><col className="w-[184px]" /><col className="w-[220px]" /><col /></colgroup>
              <TableHeader>
                <TableRow>
                  <TableHead>Thời gian</TableHead>
                  <TableHead>Người thay đổi</TableHead>
                  <TableHead>Mục</TableHead>
                  <TableHead>Cũ → mới</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {q.data.items.map((h) => {
                  const key = `${h.section}.${h.key}`
                  const label = DEF.get(key)?.label ?? h.key
                  const who = h.actor ? h.actor.name ?? h.actor.email ?? '?' : 'Hệ thống'
                  return (
                    <TableRow key={h.id} className="h-[52px]" data-testid="history-row" data-key={key}>
                      <TableCell><p className="tabular-nums">{formatDayMonth(h.createdAt)}</p><p className="text-body-s text-muted-foreground tabular-nums">{formatTime(h.createdAt)}</p></TableCell>
                      <TableCell>
                        <div className="flex min-w-0 items-center gap-2.5">
                          {h.actor ? <UserBubble name={who} size="sm" /> : <Bubble size="sm"><Timer /></Bubble>}
                          <span className="truncate" data-testid="history-actor">{who}</span>
                        </div>
                      </TableCell>
                      <TableCell><p className="truncate font-medium" title={label}>{label}</p><p className="text-body-s text-muted-foreground">{SECTION_SHORT[h.section]}</p></TableCell>
                      <TableCell>
                        <div className="flex min-w-0 items-center gap-2 text-[13.5px]" data-testid="history-diff">
                          {h.secret ? (
                            <>
                              <span className="tracking-[2px] text-faint">••••</span><ArrowRight className="size-3.5 shrink-0 text-faint" /><span className="font-semibold tracking-[2px]">••••</span>
                              <Badge className="ml-1 h-[22px]"><Lock />Bí mật, không hiển thị</Badge>
                            </>
                          ) : (
                            <>
                              <span className="truncate text-faint line-through decoration-[rgb(17_17_17/.25)]" title={display(key, h.oldValue)}>{display(key, h.oldValue)}</span>
                              <ArrowRight className="size-3.5 shrink-0 text-faint" />
                              <span className="truncate font-semibold" title={display(key, h.newValue)}>{display(key, h.newValue)}</span>
                            </>
                          )}
                        </div>
                      </TableCell>
                    </TableRow>
                  )
                })}
              </TableBody>
            </Table>
            <Pagination page={page} limit={HISTORY_PAGE} total={q.data.total} onChange={setPage} suffix="thay đổi" />
          </>
        )}
      </Card>
    </>
  )
}

/* ============================== Trợ lý AI ============================== */

function AiSection({ c }: { c: Ctx }) {
  const [test, setTest] = useState<OllamaTestResult | null>(null)
  const ollama = useMutation({
    mutationFn: () => api.aiOllamaTest({ url: String(c.value('ai.ollamaUrl')).trim(), chatModel: String(c.value('ai.chatModel')).trim(), embedModel: String(c.value('ai.embedModel')).trim() }),
    onSuccess: setTest,
    onError: (e) => notify.error('Không kiểm tra được kết nối', e.message),
  })
  const enabled = c.server('ai.enabled') === true
  const provider = String(c.value('ai.provider'))
  const fake = provider === 'fake'
  const models = test?.models ?? []
  const modelRow = (k: string, desc: string, icon: ReactNode) => (
    <SettingRow label={DEF.get(k)!.label} desc={desc} changed={c.isDirty(k)} testId={`row-${k}`}>
      <Input
        value={String(c.value(k))}
        onChange={(e) => c.set(k, e.target.value)}
        aria-label={DEF.get(k)!.label}
        aria-invalid={!!c.error(k)}
        icon={icon}
        list={models.length ? 'ollama-models' : undefined}
        data-testid={`in-${k}`}
      />
      {c.isDirty(k) && !c.error(k) && <Was>{display(k, c.server(k))}</Was>}
      <FieldError>{c.error(k)}</FieldError>
    </SettingRow>
  )
  return (
    <>
      <SectionHead
        title="Trợ lý AI"
        desc="Mô hình chạy nội bộ, giới hạn dùng và ngưỡng tự học. Áp dụng cho trợ lý của người dùng và của quản trị."
        aside={enabled ? <Badge variant="success" data-testid="ai-status"><CircleCheck />Đang chạy</Badge> : <Badge data-testid="ai-status">Đang tắt</Badge>}
      />
      <SettingCard title="Trạng thái">
        <SettingRow label="Bật trợ lý" desc="Tắt thì trợ lý ẩn khỏi app, cuộc trò chuyện cũ vẫn giữ. Cùng công tắc với Nghiệp vụ › Tính năng trong app." inline changed={c.isDirty('ai.enabled')} testId="row-ai.enabled">
          <Switch checked={c.value('ai.enabled') === true} onCheckedChange={(v) => c.set('ai.enabled', v)} aria-label="Bật trợ lý" data-testid="in-ai.enabled" />
          {c.isDirty('ai.enabled') && <Was>{display('ai.enabled', c.server('ai.enabled'))}</Was>}
        </SettingRow>
      </SettingCard>

      <SettingCard
        title="Mô hình"
        aside={<Button variant="secondary" size="sm" disabled={fake || ollama.isPending} onClick={() => ollama.mutate()} data-testid="ollama-test"><PlugZap /> Kiểm tra kết nối</Button>}
      >
        <SettingRow label="Nhà cung cấp" desc={fake ? 'Trả lời tất định, không gọi model. Chỉ dùng khi kiểm thử.' : 'Model chạy trên máy chủ của Thu Chi. Dữ liệu không gửi ra ngoài.'} changed={c.isDirty('ai.provider')} testId="row-ai.provider">
          <Tabs value={provider} onValueChange={(v) => c.set('ai.provider', v)}>
            <TabsList className="w-full">
              {Object.entries(PROVIDER_LABEL).map(([v, label]) => <TabsTrigger key={v} value={v} className="flex-1" data-testid={`provider-${v}`}>{label}</TabsTrigger>)}
            </TabsList>
          </Tabs>
          {c.isDirty('ai.provider') && <Was>{display('ai.provider', c.server('ai.provider'))}</Was>}
        </SettingRow>
        <SettingRow label="Địa chỉ Ollama" desc="Máy chủ Ollama trong mạng nội bộ." changed={c.isDirty('ai.ollamaUrl')} testId="row-ai.ollamaUrl">
          <TextSetting c={c} k="ai.ollamaUrl" icon={<Server />} placeholder="http://localhost:11434" />
          {c.isDirty('ai.ollamaUrl') && !c.error('ai.ollamaUrl') && <Was>{display('ai.ollamaUrl', c.server('ai.ollamaUrl'))}</Was>}
          <FieldError>{c.error('ai.ollamaUrl')}</FieldError>
          {test && (
            <div
              className={cn('flex items-start gap-2.5 rounded-md px-3.5 py-3 text-[13px] leading-normal', test.ok ? 'bg-success-soft text-income' : 'bg-destructive-soft text-destructive')}
              role="status"
              data-testid="ollama-result"
            >
              {test.ok ? <CircleCheck className="mt-px size-4 shrink-0" /> : <CircleAlert className="mt-px size-4 shrink-0" />}
              <p>
                {test.error ? (
                  <>{test.error} · {formatTime(test.at)}</>
                ) : (
                  <>
                    Kết nối được lúc {formatTime(test.at)} · {formatNumber(test.ms)} ms ·{' '}
                    {[test.chatModel, test.embedModel].map((m, i) => (
                      <span key={m.name}>{i > 0 && ', '}<b className="font-semibold">{m.name}</b> {m.loaded ? 'đã tải' : 'chưa tải'}</span>
                    ))}
                  </>
                )}
              </p>
            </div>
          )}
          {models.length > 0 && <datalist id="ollama-models">{models.map((m) => <option key={m} value={m} />)}</datalist>}
        </SettingRow>
        {modelRow('ai.chatModel', 'Model chỉ điền khuôn trả lời. Số tiền, ngày, ví luôn do code tính.', <Cpu />)}
        {modelRow('ai.embedModel', 'Dùng để định tuyến câu hỏi và tìm ví dụ giống nhau. Đổi model thì kho ví dụ cũ phải tính lại.', <Database />)}
      </SettingCard>

      <SettingCard title="Giới hạn">
        <NumberRow c={c} k="ai.dailyMessageLimitPerUser" desc="Hết lượt thì app báo giờ mở lại. Xác nhận nháp và đọc lại không tính lượt." range="1–100.000 tin" />
        <NumberRow c={c} k="ai.maxConversationsPerUser" desc="Đạt giới hạn thì cuộc cũ nhất không ghim tự lưu trữ." range="1–10.000 cuộc" />
        <NumberRow c={c} k="ai.timeoutSeconds" desc="Quá thời gian thì app báo “Trợ lý đang bận, thử lại sau”." range="5–600 giây" />
      </SettingCard>

      <SettingCard title="Đọc ảnh" aside={<span className="text-body-s font-medium text-muted-foreground">Quét hóa đơn và ảnh chuyển khoản trong app</span>}>
        <SettingRow label="Bật đọc ảnh" desc="Tắt thì dòng “Quét hóa đơn” ẩn khỏi app. Trợ lý trò chuyện không bị ảnh hưởng." inline changed={c.isDirty('ai.ocrEnabled')} testId="row-ai.ocrEnabled">
          <Switch checked={c.value('ai.ocrEnabled') === true} onCheckedChange={(v) => c.set('ai.ocrEnabled', v)} aria-label="Bật đọc ảnh" data-testid="in-ai.ocrEnabled" />
          {c.isDirty('ai.ocrEnabled') && <Was>{display('ai.ocrEnabled', c.server('ai.ocrEnabled'))}</Was>}
        </SettingRow>
        <SettingRow label="Model đọc ảnh" desc="Chạy trên máy chủ của Thu Chi, ảnh không gửi ra ngoài. Dùng chung model trả lời." testId="row-ai.ocrModel">
          <LockedValue testId="ocr-model">{String(c.server('ai.chatModel') ?? '')} · nội bộ</LockedValue>
        </SettingRow>
        <NumberRow c={c} k="ai.ocrDailyLimitPerUser" desc="Hết lượt thì app báo giờ mở lại, vẫn ghi tay được. Nháp đang chờ vẫn lưu được." range="1–100 ảnh" />
        <NumberRow c={c} k="ai.ocrMaxSide" desc="Máy chủ thu nhỏ ảnh theo cạnh dài trước khi đọc. Lớn hơn thì chậm hơn." range="384–1.536 px" />
        <NumberRow c={c} k="ai.ocrTimeoutSeconds" desc="Quá thời gian thì app báo không đọc được và mở nhập tay." range="10–120 giây" />
        <SettingRow label="Lưu ảnh" desc="Cố định, không đổi được. Quản trị viên không xem được ảnh hay nội dung đọc được." testId="row-ai.ocrStore">
          <LockedValue testId="ocr-store">Không lưu · xóa ngay sau khi đọc</LockedValue>
        </SettingRow>
      </SettingCard>

      <SettingCard title="Tự học" aside={<span className="text-body-s font-medium text-muted-foreground">Chạy lúc 02:30 mỗi đêm, tuần tự</span>}>
        <SettingRow label="Tự áp dụng luật chung" desc="Tắt thì mọi luật chung chờ duyệt ở Trung tâm học. Luật làm bộ đề tụt điểm luôn bị loại." inline changed={c.isDirty('ai.autoApproveEnabled')} testId="row-ai.autoApproveEnabled">
          <Switch checked={c.value('ai.autoApproveEnabled') === true} onCheckedChange={(v) => c.set('ai.autoApproveEnabled', v)} aria-label="Tự áp dụng luật chung" data-testid="in-ai.autoApproveEnabled" />
          {c.isDirty('ai.autoApproveEnabled') && <Was>{display('ai.autoApproveEnabled', c.server('ai.autoApproveEnabled'))}</Was>}
        </SettingRow>
        <SettingRow
          label="Tự áp dụng khi"
          desc="Không đủ thì chờ duyệt ở Trung tâm học."
          changed={['ai.autoApproveMinUsers', 'ai.autoApproveMinSupport', 'ai.autoApproveMinPrecision'].some(c.isDirty)}
          testId="row-ai.autoApprove"
        >
          <div className="flex flex-wrap items-center gap-2.5">
            <NumberBox c={c} k="ai.autoApproveMinUsers" width={128} />
            <NumberBox c={c} k="ai.autoApproveMinSupport" width={116} />
            <span className="text-muted-foreground">đúng ≥</span>
            <NumberBox c={c} k="ai.autoApproveMinPrecision" width={100} />
          </div>
          {['ai.autoApproveMinUsers', 'ai.autoApproveMinSupport', 'ai.autoApproveMinPrecision'].some(c.isDirty) && (
            <Was>{display('ai.autoApproveMinUsers', c.server('ai.autoApproveMinUsers'))} · {display('ai.autoApproveMinSupport', c.server('ai.autoApproveMinSupport'))} · đúng ≥ {display('ai.autoApproveMinPrecision', c.server('ai.autoApproveMinPrecision'))}</Was>
          )}
          <FieldError>{c.error('ai.autoApproveMinUsers') ?? c.error('ai.autoApproveMinSupport') ?? c.error('ai.autoApproveMinPrecision')}</FieldError>
        </SettingRow>
        {([
          ['Luật riêng của một người bật khi', 'Chỉ áp dụng cho chính người đó.', '3 lần khớp, đúng ≥ 85%'],
          ['Tắt luật khi', 'Số lần có hại đạt mức này và nhiều hơn số lần có ích.', '2 lần có hại'],
          ['Mẫu câu vào kho chung cần', 'Số người khác nhau đã xác nhận cùng mẫu. Người dùng tắt “Góp ví dụ ẩn danh” thì không được tính.', '5 người'],
        ] as const).map(([label, desc, value]) => (
          <SettingRow key={label} label={label} desc={desc} inline>
            <span className="inline-flex items-center gap-1.5 text-sm font-semibold tabular-nums">{value}<Lock className="size-3.5 text-faint" aria-label="Cố định" /></span>
          </SettingRow>
        ))}
      </SettingCard>
    </>
  )
}

function LockedValue({ children, testId }: { children: ReactNode; testId: string }) {
  return (
    <div className="flex h-10 items-center gap-2 rounded-md border bg-muted/60 px-3.5 text-sm text-muted-foreground" data-testid={testId}>
      <Lock className="size-4 shrink-0 text-faint" aria-label="Cố định" />
      {children}
    </div>
  )
}
