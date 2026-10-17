import { useMemo, useState } from 'react'
import { useNavigate, useParams } from 'react-router'
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { Check, ChevronUp, CircleAlert, CircleCheck, Lock, ShieldX, Table2, X } from 'lucide-react'
import { CartesianGrid, Line, LineChart, ResponsiveContainer, Tooltip, XAxis, YAxis } from 'recharts'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { Card, CardHeader } from '@/components/ui/card'
import { notify } from '@/components/ui/sonner'
import { Skeleton } from '@/components/ui/skeleton'
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table'
import { Tabs, TabsList, TabsTrigger } from '@/components/ui/tabs'
import { ErrorState, PageHeader, TableSkeleton } from '@/components/common'
import { api, type AiEvalReport, type AiExample, type AiLearningRun, type AiRule, type AiStats } from '@/lib/api'
import { aiSkillLabel, formatDate, formatDayMonth, formatNumber, formatPercent, formatTime } from '@/lib/format'
import { cn } from '@/lib/utils'

/** viz-1..4 (design/tokens.md), gán cố định theo thứ tự series */
const VIZ = ['#2a78d6', '#eb6834', '#1baf7a', '#eda100']
const WEEKS = 8
const DAY = 86400_000
const rate = (c: number, e: number, x: number) => (c + e + x ? Math.round((c / (c + e + x)) * 1000) / 10 : null)
const seconds = (ms: number | null) => (ms == null ? '—' : `${new Intl.NumberFormat('vi-VN', { maximumFractionDigits: 2 }).format(ms / 1000)} giây`)
/** "YYYY-MM-DD" theo giờ VN của mốc thời gian */
const vnDay = (t: number) => new Date(t + 7 * 3600_000).toISOString().slice(0, 10)

export default function LearningPage() {
  const { tab = 'tong-quan' } = useParams()
  const navigate = useNavigate()
  const runs = useQuery({ queryKey: ['ai-runs'], queryFn: () => api.aiRuns(20) })
  const last = runs.data?.find((r) => r.finishedAt)
  return (
    <>
      <PageHeader
        title="Trung tâm học"
        description={
          <>
            Học từ việc người dùng xác nhận, sửa, hủy nháp
            {last && <> · chạy gần nhất {formatTime(last.startedAt)}–{formatTime(last.finishedAt!)} {formatDayMonth(last.startedAt)}</>}
          </>
        }
        actions={
          <Tabs value={tab} onValueChange={(v) => navigate(v === 'tong-quan' ? '/learning' : `/learning/${v}`)}>
            <TabsList>
              <TabsTrigger value="tong-quan" data-testid="tab-overview">Tổng quan</TabsTrigger>
              <TabsTrigger value="luot-chay" data-testid="tab-runs">Lượt chạy đêm</TabsTrigger>
            </TabsList>
          </Tabs>
        }
      />
      <div className="flex items-center gap-3 rounded-lg bg-muted/70 px-4 py-3 text-[13.5px] text-muted-foreground" data-testid="privacy-note">
        <Lock className="size-4 shrink-0" />
        Không hiển thị nội dung tin nhắn của người dùng. Ở đây chỉ có số tổng hợp và mẫu câu đã bỏ tên, số tài khoản, được ít nhất 5 người khác nhau xác nhận.
      </div>
      {tab === 'luot-chay' ? <RunsTab runs={runs} /> : <OverviewTab />}
    </>
  )
}

/* ============================== Tổng quan ============================== */

function Kpi({ label, value, sub, loading, testId }: { label: string; value: string; sub?: string; loading: boolean; testId: string }) {
  return (
    <Card className="flex flex-col gap-1.5" data-testid={testId}>
      <p className="text-[13.5px] font-medium text-muted-foreground">{label}</p>
      {loading ? <Skeleton className="mt-1.5 h-8 w-28" /> : <p className="text-[30px] leading-[1.2] font-bold tracking-[-0.02em] tabular-nums">{value}</p>}
      {sub && !loading && <p className="text-body-s text-muted-foreground tabular-nums">{sub}</p>}
    </Card>
  )
}

function OverviewTab() {
  const week = useQuery({ queryKey: ['ai-stats', 7], queryFn: () => api.aiStats(7) })
  const long = useQuery({ queryKey: ['ai-stats', WEEKS * 7], queryFn: () => api.aiStats(WEEKS * 7) })

  const k = useMemo(() => {
    const s = week.data?.skills ?? []
    const sum = (f: (x: (typeof s)[number]) => number) => s.reduce((a, x) => a + f(x), 0)
    const messages = sum((x) => x.messages)
    const c = sum((x) => x.drafts.confirmed), e = sum((x) => x.drafts.edited), x = sum((y) => y.drafts.cancelled)
    const asks = sum((y) => y.askBacks) + (s.find((y) => y.skill === 'ngoai-pham-vi')?.messages ?? 0)
    const avg = messages ? Math.round(sum((y) => (y.latencyMs.avg ?? 0) * y.messages) / messages) : null
    const slow = [...s].filter((y) => y.latencyMs.p95 != null).sort((a, b) => b.latencyMs.p95! - a.latencyMs.p95!)[0]
    const userMsgs = (week.data?.volume ?? []).reduce((a, v) => a + v.messages, 0)
    // 4 tuần trước: tuần thứ 4 tính lùi từ hôm nay
    const from = vnDay(Date.now() - 34 * DAY), to = vnDay(Date.now() - 28 * DAY)
    const old = (long.data?.daily ?? []).filter((d) => d.day >= from && d.day <= to)
    const oldRate = rate(old.reduce((a, d) => a + d.confirmed, 0), old.reduce((a, d) => a + d.edited, 0), old.reduce((a, d) => a + d.cancelled, 0))
    return { messages, userMsgs, resolved: c + e + x, accept: rate(c, e, x), oldRate, asks, avg, slow }
  }, [week.data, long.data])

  return (
    <>
      <div className="grid grid-cols-2 gap-5 xl:grid-cols-4">
        <Kpi testId="kpi-accept" loading={week.isPending} label="Nháp xác nhận không sửa" value={formatPercent(k.accept)}
          sub={`${k.oldRate != null ? `4 tuần trước ${formatPercent(k.oldRate)} · ` : ''}${formatNumber(k.resolved)} nháp đã xử lý 7 ngày`} />
        <Kpi testId="kpi-messages" loading={week.isPending} label="Tin nhắn 7 ngày" value={formatNumber(k.userMsgs)} sub={`${formatNumber(Math.round(k.userMsgs / 7))} tin mỗi ngày`} />
        <Kpi testId="kpi-latency" loading={week.isPending} label="Độ trễ trung bình" value={seconds(k.avg)}
          sub={k.slow ? `p95 chậm nhất ${seconds(k.slow.latencyMs.p95)} · ${aiSkillLabel(k.slow.skill)}` : 'hàng đợi 1 GPU'} />
        <Kpi testId="kpi-asks" loading={week.isPending} label="Hỏi lại hoặc ngoài phạm vi" value={formatPercent(k.messages ? (k.asks / k.messages) * 100 : null, 1)} sub={`${formatNumber(k.asks)} tin trong 7 ngày`} />
      </div>
      {week.error && <Card flush><ErrorState error={week.error} onRetry={week.refetch} /></Card>}
      <div className="grid flex-1 grid-cols-1 items-start gap-5 xl:grid-cols-[minmax(0,5fr)_minmax(0,7fr)]">
        <AcceptanceChart stats={long.data} loading={long.isPending} />
        <Proposals />
      </div>
    </>
  )
}

function AcceptanceChart({ stats, loading }: { stats?: AiStats; loading: boolean }) {
  const [asTable, setAsTable] = useState(false)
  const { weeks, series } = useMemo(() => {
    const daily = stats?.daily ?? []
    // 4 skill có nhiều nháp nhất, thứ tự cố định theo số nháp
    const totals = new Map<string, number>()
    for (const d of daily) totals.set(d.skill, (totals.get(d.skill) ?? 0) + d.confirmed + d.edited + d.cancelled)
    const series = [...totals.entries()].filter(([, n]) => n > 0).sort((a, b) => b[1] - a[1]).slice(0, 4).map(([s]) => s)
    const now = Date.now()
    const weeks = Array.from({ length: WEEKS }, (_, i) => {
      const start = vnDay(now - (WEEKS - i) * 7 * DAY + DAY), end = vnDay(now - (WEEKS - 1 - i) * 7 * DAY)
      const row: Record<string, number | string | null> = { label: `${Number(start.slice(8))}/${Number(start.slice(5, 7))}` }
      for (const s of series) {
        const ds = daily.filter((d) => d.skill === s && d.day >= start && d.day <= end)
        row[s] = rate(ds.reduce((a, d) => a + d.confirmed, 0), ds.reduce((a, d) => a + d.edited, 0), ds.reduce((a, d) => a + d.cancelled, 0))
      }
      return row
    })
    return { weeks, series }
  }, [stats])
  const lastOf = (s: string) => [...weeks].reverse().find((w) => w[s] != null)?.[s] as number | undefined

  return (
    <Card className="flex flex-col" data-testid="acceptance-card">
      <CardHeader title="Chấp nhận không sửa theo skill" sub={`${WEEKS} tuần, tuần cuối tính đến hôm nay`} />
      {loading ? (
        <Skeleton className="mt-5 h-[300px] w-full" />
      ) : series.length === 0 ? (
        <p className="mt-5 rounded-md bg-background px-4 py-10 text-center text-body-s text-muted-foreground" data-testid="acceptance-empty">Chưa có nháp nào được xử lý trong {WEEKS} tuần qua.</p>
      ) : asTable ? (
        <Table className="mt-4" data-testid="acceptance-table">
          <TableHeader>
            <TableRow><TableHead>Tuần từ</TableHead>{series.map((s) => <TableHead key={s} className="text-right">{aiSkillLabel(s)}</TableHead>)}</TableRow>
          </TableHeader>
          <TableBody>
            {weeks.map((w) => (
              <TableRow key={String(w.label)}>
                <TableCell className="tabular-nums">{w.label}</TableCell>
                {series.map((s) => <TableCell key={s} className="text-right tabular-nums">{formatPercent(w[s] as number | null, 1)}</TableCell>)}
              </TableRow>
            ))}
          </TableBody>
        </Table>
      ) : (
        <>
          <div className="mt-4 flex flex-wrap gap-x-[18px] gap-y-1.5 text-[13px] text-muted-foreground">
            {series.map((s, i) => <span key={s} className="flex items-center gap-[7px]"><i className="size-2.5 rounded-[3px]" style={{ background: VIZ[i] }} />{aiSkillLabel(s)}</span>)}
          </div>
          <div className="mt-3 h-[280px]" data-testid="acceptance-chart">
            <ResponsiveContainer width="100%" height="100%">
              <LineChart data={weeks} margin={{ top: 12, right: 44, left: 0, bottom: 0 }}>
                <CartesianGrid vertical={false} stroke="var(--color-line)" />
                <XAxis dataKey="label" tickLine={false} axisLine={{ stroke: '#E3E2DD' }} tickMargin={10} tick={{ fontSize: 11.5, fill: '#787774' }} />
                <YAxis width={40} tickLine={false} axisLine={false} domain={[0, 100]} ticks={[0, 25, 50, 75, 100]} tick={{ fontSize: 11.5, fill: '#A9A8A3' }} tickFormatter={(v: number) => `${v}%`} />
                <Tooltip
                  isAnimationActive={false}
                  content={({ active, payload, label }) =>
                    active && payload?.length ? (
                      <div className="min-w-[180px] rounded-sm border border-border bg-card px-3 py-2.5 text-body-s shadow-pop">
                        <p className="mb-1 text-[13px] font-semibold">Tuần từ {label}</p>
                        {payload.map((p) => (
                          <div key={String(p.dataKey)} className="flex justify-between gap-4 leading-[1.7] tabular-nums">
                            <span className="flex items-center text-muted-foreground"><i className="mr-1.5 size-2 rounded-[2px]" style={{ background: p.color }} />{aiSkillLabel(String(p.dataKey))}</span>
                            <b className="font-semibold">{formatPercent(p.value as number | null, 1)}</b>
                          </div>
                        ))}
                      </div>
                    ) : null
                  }
                />
                {series.map((s, i) => (
                  <Line
                    key={s}
                    dataKey={s}
                    stroke={VIZ[i]}
                    strokeWidth={2}
                    dot={false}
                    connectNulls
                    isAnimationActive={false}
                    label={({ x, y, index, value }) =>
                      index === weeks.length - 1 && value != null ? (
                        <text x={Number(x) + 8} y={Number(y) + 4} fontSize={12} fontWeight={600} fill="#111" className="tabular-nums">{formatPercent(lastOf(s))}</text>
                      ) : null
                    }
                  />
                ))}
              </LineChart>
            </ResponsiveContainer>
          </div>
        </>
      )}
      {series.length > 0 && (
        <div className="mt-4 flex items-end justify-between gap-4">
          <p className="text-body-s text-muted-foreground">Tỉ lệ nháp được xác nhận mà không sửa, trên số nháp đã xác nhận, sửa hoặc hủy.</p>
          <Button variant="link" onClick={() => setAsTable((v) => !v)} data-testid="acceptance-toggle">
            {asTable ? <><ChevronUp /> Xem biểu đồ</> : <><Table2 /> Xem dạng bảng</>}
          </Button>
        </div>
      )}
    </Card>
  )
}

/* ---------- Đề xuất chờ duyệt ---------- */

type Row =
  | { type: 'rule'; item: AiRule }
  | { type: 'example'; item: AiExample }

function EvalCell({ r }: { r: AiEvalReport | null }) {
  if (!r || r.verdict === 'no-coverage') return <span className="text-body-s text-faint">Chưa có đề</span>
  if (r.verdict === 'fail') return <Badge variant="danger" data-testid="eval-blocked"><ShieldX />Bộ đề chặn · {r.correct}/{r.matched}</Badge>
  return <span className="text-[13.5px] font-semibold text-income tabular-nums">Đạt {r.correct}/{r.matched}</span>
}

function Proposals() {
  const qc = useQueryClient()
  const rules = useQuery({ queryKey: ['ai-rules', 'PROPOSED'], queryFn: () => api.aiRules({ status: 'PROPOSED', limit: 100 }) })
  const examples = useQuery({ queryKey: ['ai-examples', 'PROPOSED'], queryFn: () => api.aiExamples({ status: 'PROPOSED', limit: 100 }) })
  // Bị bộ đề chặn: chu trình đêm loại ngay (REJECTED, không ai duyệt) → chỉ còn trạng thái
  const rejected = useQuery({ queryKey: ['ai-rules', 'REJECTED'], queryFn: () => api.aiRules({ status: 'REJECTED', limit: 20 }) })
  const activeRules = useQuery({ queryKey: ['ai-rules', 'ACTIVE', 'count'], queryFn: () => api.aiRules({ status: 'ACTIVE', limit: 1 }), select: (d) => d.total })
  const activeExamples = useQuery({ queryKey: ['ai-examples', 'ACTIVE', 'count'], queryFn: () => api.aiExamples({ status: 'ACTIVE', limit: 1 }), select: (d) => d.total })

  const decide = useMutation({
    mutationFn: async (v: { row: Row; approve: boolean }): Promise<unknown> => (v.row.type === 'rule' ? api.aiDecideRule(v.row.item.id, v.approve) : api.aiDecideExample(v.row.item.id, v.approve)),
    onSuccess: (_, v) => {
      qc.invalidateQueries({ queryKey: ['ai-rules'] })
      qc.invalidateQueries({ queryKey: ['ai-examples'] })
      qc.invalidateQueries({ queryKey: ['ai-pending'] })
      notify.success(v.approve ? 'Đã duyệt, áp dụng cho mọi người dùng' : 'Đã từ chối đề xuất', { icon: v.approve ? <Check /> : <X /> })
    },
    onError: (e) => notify.error('Không cập nhật được đề xuất', e.message),
  })

  const rows: Row[] = [
    ...(rules.data?.items ?? []).map((item) => ({ type: 'rule' as const, item })),
    ...(examples.data?.items ?? []).map((item) => ({ type: 'example' as const, item })),
  ]
  const blocked = (rejected.data?.items ?? []).filter((r) => r.evalReport?.verdict === 'fail' && !r.approvedById)
  const loading = rules.isPending || examples.isPending
  const error = rules.error ?? examples.error

  return (
    <Card flush data-testid="proposals-card">
      <div className="px-6 pt-5 pb-3">
        <CardHeader
          title={<>Đề xuất chờ duyệt {rows.length > 0 && <span className="inline-flex h-5 min-w-5 items-center justify-center rounded-full bg-primary px-1.5 text-[11.5px] font-semibold text-primary-foreground tabular-nums" data-testid="proposals-count">{rows.length}</span>}</>}
          sub={`Áp dụng cho mọi người dùng.${activeRules.data != null && activeExamples.data != null ? ` Đang bật ${formatNumber(activeRules.data)} luật, ${formatNumber(activeExamples.data)} ví dụ chung.` : ''}`}
        />
      </div>
      {error ? (
        <ErrorState error={error} onRetry={() => { rules.refetch(); examples.refetch() }} />
      ) : loading ? (
        <TableSkeleton rows={4} />
      ) : rows.length === 0 && blocked.length === 0 ? (
        <p className="px-6 pt-2 pb-8 text-body-s text-muted-foreground" data-testid="proposals-empty">
          Không có đề xuất nào chờ duyệt. Chu trình học chạy lúc 02:30 mỗi đêm, đề xuất đủ ngưỡng được tự áp dụng.
        </p>
      ) : (
        <Table>
          <colgroup><col className="w-[72px]" /><col /><col className="w-[150px]" /><col className="w-[120px]" /><col className="w-[132px]" /></colgroup>
          <TableHeader>
            <TableRow>
              <TableHead />
              <TableHead>Đề xuất</TableHead>
              <TableHead>Bằng chứng</TableHead>
              <TableHead>Bộ đề</TableHead>
              <TableHead><span className="sr-only">Thao tác</span></TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {rows.map((row) => (
              <TableRow key={row.item.id} data-testid="proposal-row" data-type={row.type}>
                <TableCell className="align-top"><Badge>{row.type === 'rule' ? 'Luật' : 'Ví dụ'}</Badge></TableCell>
                <TableCell className="py-3">
                  {row.type === 'rule' ? (
                    <p className="font-semibold break-words">“{row.item.pattern}” → {row.item.value}</p>
                  ) : (
                    <>
                      <p className="font-semibold break-words">“{row.item.input}” → {row.item.output?.categoryName}</p>
                      {row.item.output?.title && <p className="text-body-s text-muted-foreground">Tên khoản: {row.item.output.title}</p>}
                    </>
                  )}
                  <p className="text-body-s text-faint">{aiSkillLabel(row.item.skill)}</p>
                </TableCell>
                <TableCell className="text-body-s text-muted-foreground tabular-nums">
                  {row.type === 'rule'
                    ? <>{formatNumber(row.item.support)} lần · {formatNumber(row.item.userCount)} người<br />đúng {formatPercent(row.item.precision * 100)}</>
                    : <>{formatNumber(row.item.userCount)} người xác nhận<br />{formatNumber(row.item.confirmations)} lần</>}
                </TableCell>
                <TableCell><EvalCell r={row.item.evalReport} /></TableCell>
                <TableCell className="pr-4 text-right">
                  <div className="flex items-center justify-end gap-1">
                    <Button variant="secondary" size="sm" disabled={decide.isPending} onClick={() => decide.mutate({ row, approve: true })} data-testid="proposal-approve"><Check /> Duyệt</Button>
                    <Button variant="ghost" size="icon-sm" aria-label="Từ chối" title="Từ chối" disabled={decide.isPending} onClick={() => decide.mutate({ row, approve: false })} data-testid="proposal-reject"><X /></Button>
                  </div>
                </TableCell>
              </TableRow>
            ))}
            {blocked.map((r) => (
              <TableRow key={r.id} className="text-muted-foreground" data-testid="proposal-blocked">
                <TableCell className="align-top"><Badge>Luật</Badge></TableCell>
                <TableCell className="py-3"><p className="break-words">“{r.pattern}” → {r.value}</p><p className="text-body-s text-faint">{aiSkillLabel(r.skill)}</p></TableCell>
                <TableCell className="text-body-s tabular-nums">{formatNumber(r.support)} lần · {formatNumber(r.userCount)} người<br />đúng {formatPercent(r.precision * 100)}</TableCell>
                <TableCell colSpan={2}><EvalCell r={r.evalReport} /></TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      )}
    </Card>
  )
}

/* ============================== Lượt chạy đêm ============================== */

const TRIGGER_LABEL: Record<string, string> = { cron: 'Hằng đêm', manual: 'Chạy tay' }
const STAT_LABEL: [string, string][] = [['candidates', 'ứng viên'], ['active', 'tự áp dụng'], ['proposed', 'chờ duyệt'], ['rejected', 'bị loại'], ['skippedAnonymity', 'thiếu người xác nhận'], ['skippedPrivate', 'có tên / số tài khoản']]

function duration(r: AiLearningRun) {
  if (!r.finishedAt) return 'Đang chạy'
  const s = Math.round((Date.parse(r.finishedAt) - Date.parse(r.startedAt)) / 1000)
  return s < 60 ? `${s} giây` : `${Math.floor(s / 60)} phút ${s % 60} giây`
}

function RunStatus({ r }: { r: AiLearningRun }) {
  if (r.error) return <Badge variant="danger"><CircleAlert />Lỗi</Badge>
  if (!r.finishedAt) return <Badge variant="warning">Đang chạy</Badge>
  return <Badge variant="success"><CircleCheck />Thành công</Badge>
}

function RunsTab({ runs }: { runs: ReturnType<typeof useQuery<AiLearningRun[]>> }) {
  const [sel, setSel] = useState<string | null>(null)
  const current = runs.data?.find((r) => r.id === sel) ?? runs.data?.[0]
  return (
    <div className="grid flex-1 grid-cols-1 items-start gap-5 xl:grid-cols-[minmax(0,7fr)_minmax(0,5fr)]">
      <Card flush data-testid="runs-card">
        <div className="px-6 pt-5 pb-3"><CardHeader title="Các lượt chạy" sub="Chạy lúc 02:30 mỗi đêm, tuần tự trên 1 GPU. Luật chung chỉ được áp dụng khi bộ đề không tụt." /></div>
        {runs.error ? (
          <ErrorState error={runs.error} onRetry={runs.refetch} />
        ) : runs.isPending ? (
          <TableSkeleton rows={5} />
        ) : runs.data.length === 0 ? (
          <p className="px-6 pt-2 pb-8 text-body-s text-muted-foreground" data-testid="runs-empty">Chưa có lượt chạy nào. Lượt đầu tiên chạy lúc 02:30 đêm nay.</p>
        ) : (
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Bắt đầu</TableHead>
                <TableHead>Kích hoạt</TableHead>
                <TableHead>Thời gian</TableHead>
                <TableHead className="text-right">Luật mới</TableHead>
                <TableHead className="text-right">Ví dụ mới</TableHead>
                <TableHead>Kết quả</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {runs.data.map((r) => (
                <TableRow key={r.id} onClick={() => setSel(r.id)} className={cn('cursor-pointer', current?.id === r.id && 'bg-hover')} data-testid="run-row">
                  <TableCell className="tabular-nums">{formatTime(r.startedAt)} <span className="text-muted-foreground">· {formatDate(r.startedAt)}</span></TableCell>
                  <TableCell className="text-muted-foreground">{TRIGGER_LABEL[r.trigger] ?? r.trigger}</TableCell>
                  <TableCell className="text-muted-foreground tabular-nums">{duration(r)}</TableCell>
                  <TableCell className="text-right tabular-nums">{formatNumber(r.stats?.rules?.candidates ?? 0)}</TableCell>
                  <TableCell className="text-right tabular-nums">{formatNumber(r.stats?.examples?.candidates ?? 0)}</TableCell>
                  <TableCell><RunStatus r={r} /></TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        )}
      </Card>
      {current && (
        <Card data-testid="run-detail">
          <CardHeader title={`Lượt ${formatTime(current.startedAt)} · ${formatDayMonth(current.startedAt)}`} aside={<RunStatus r={current} />} />
          <dl className="mt-4">
            {[['Kích hoạt', TRIGGER_LABEL[current.trigger] ?? current.trigger], ['Bắt đầu', `${formatTime(current.startedAt)} · ${formatDate(current.startedAt)}`], ['Thời gian', duration(current)]].map(([k, v]) => (
              <div key={k} className="flex h-10 items-center justify-between border-t border-line text-[13.5px] first:border-0">
                <dt className="text-muted-foreground">{k}</dt><dd className="tabular-nums">{v}</dd>
              </div>
            ))}
          </dl>
          {current.error && <p className="mt-3 rounded-md bg-destructive-soft px-4 py-3 text-body-s break-words text-destructive" data-testid="run-error">{current.error}</p>}
          {(['rules', 'examples'] as const).map((key) => {
            const st = current.stats?.[key]
            if (!st) return null
            return (
              <div key={key} className="mt-5">
                <p className="text-sm font-semibold">{key === 'rules' ? 'Luật chung' : 'Ví dụ chung'}</p>
                <dl className="mt-1.5">
                  {STAT_LABEL.map(([f, label]) => (
                    <div key={f} className="flex h-9 items-center justify-between border-t border-line text-[13.5px] first:border-0">
                      <dt className="text-muted-foreground">{label[0].toUpperCase() + label.slice(1)}</dt>
                      <dd className="font-semibold tabular-nums">{formatNumber(st[f] ?? 0)}</dd>
                    </div>
                  ))}
                </dl>
              </div>
            )
          })}
        </Card>
      )}
    </div>
  )
}
