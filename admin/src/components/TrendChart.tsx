import { useState } from 'react'
import { Bar, BarChart, CartesianGrid, ResponsiveContainer, Tooltip, XAxis, YAxis } from 'recharts'
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table'
import type { MonthTotal } from '@/lib/api'
import { currentMonth, formatAxis, formatMonthLong, formatMonthShort, formatSigned, formatVND, todayDayMonth } from '@/lib/format'
import { cn } from '@/lib/utils'

const INCOME = 'var(--color-income)'
const EXPENSE = 'var(--color-expense)'

/** Chú thích Thu / Chi (ô vuông bo 3px). */
export function ChartLegend() {
  return (
    <div className="flex items-center gap-[18px] text-[13px] text-muted-foreground">
      <span className="flex items-center gap-[7px]"><i className="size-2.5 rounded-[3px] bg-income" />Thu</span>
      <span className="flex items-center gap-[7px]"><i className="size-2.5 rounded-[3px] bg-expense" />Chi</span>
    </div>
  )
}

function TipRow({ color, label, value, className }: { color?: string; label: string; value: string; className?: string }) {
  return (
    <div className={cn('flex justify-between gap-4 leading-[1.7] tabular-nums', className)}>
      <span className="flex items-center text-muted-foreground">
        {color && <i className="mr-1.5 size-2 rounded-[2px]" style={{ background: color }} />}
        {label}
      </span>
      <b className="font-semibold">{value}</b>
    </div>
  )
}

function ChartTip({ active, payload }: { active?: boolean; payload?: readonly { payload?: unknown }[] }) {
  const d = payload?.[0]?.payload as MonthTotal | undefined
  if (!active || !d) return null
  return (
    <div className="min-w-[196px] rounded-sm border border-border bg-card px-3 py-2.5 text-body-s whitespace-nowrap shadow-pop" data-testid="chart-tip">
      <p className="mb-1 text-[13px] font-semibold">{formatMonthLong(d.month)}</p>
      <TipRow color={INCOME} label="Thu" value={formatVND(d.income)} />
      <TipRow color={EXPENSE} label="Chi" value={formatSigned(d.expense, false)} />
      <div className="mt-1 border-t border-line pt-1">
        <TipRow label="Chênh lệch" value={formatSigned(d.net, d.net >= 0)} className={d.net >= 0 ? '[&_b]:text-income' : undefined} />
      </div>
    </div>
  )
}

/** Bước chia trục "đẹp" (1, 2, 2.5, 5 × 10^k) để nhãn tròn: 0 · 1 tỷ · 2 tỷ · 3 tỷ. */
function niceTicks(max: number, count = 3) {
  const raw = Math.max(max, 1) / count
  const p = 10 ** Math.floor(Math.log10(raw))
  const f = raw / p
  const step = (f <= 1 ? 1 : f <= 2 ? 2 : f <= 2.5 ? 2.5 : f <= 5 ? 5 : 10) * p
  return Array.from({ length: Math.ceil(Math.max(max, 1) / step) + 1 }, (_, i) => i * step)
}

/** Nền bo tròn sau nhóm cột đang hover (Recharts truyền x/y/width/height). */
function CursorBand({ x = 0, y = 0, width = 0, height = 0 }: { x?: number; y?: number; width?: number; height?: number }) {
  return <rect x={x + 6} y={y} width={Math.max(0, width - 12)} height={height} rx={10} fill="#F7F6F3" />
}

/**
 * Thu vs chi theo tháng: cột nhóm, một trục, cột tối đa `barSize`px bo 4 ở đầu, cách nhau 2px.
 * Hover tô nền cả nhóm + tooltip; tháng hiện tại có nhãn "đến dd/MM".
 */
export function TrendChart({ data, barSize = 22, className }: { data: MonthTotal[]; barSize?: number; className?: string }) {
  const [hover, setHover] = useState<number | null>(null)
  const thisMonth = currentMonth()
  const last = data.length - 1
  const ticks = niceTicks(Math.max(...data.flatMap((d) => [d.income, d.expense])))

  return (
    <div className={cn('min-h-0', className)} data-testid="trend-chart">
      <ResponsiveContainer width="100%" height="100%">
        <BarChart
          data={data}
          barGap={2}
          barCategoryGap={0}
          margin={{ top: 24, right: 8, left: 4, bottom: 0 }}
          onMouseMove={(s) => setHover(s.activeTooltipIndex != null ? Number(s.activeTooltipIndex) : null)}
          onMouseLeave={() => setHover(null)}
        >
          <CartesianGrid vertical={false} stroke="var(--color-line)" />
          <XAxis
            dataKey="month"
            tickLine={false}
            axisLine={{ stroke: '#E3E2DD' }}
            tickMargin={10}
            interval={0}
            tick={({ x, y, payload, index }) => (
              <text
                x={x}
                y={y}
                dy={10}
                textAnchor="middle"
                fontSize={12}
                fill={hover === index ? '#111' : '#787774'}
                fontWeight={hover === index ? 600 : 400}
                className="tabular-nums"
              >
                {formatMonthShort(String(payload.value))}
              </text>
            )}
          />
          <YAxis
            width={56}
            tickLine={false}
            axisLine={false}
            tickMargin={12}
            ticks={ticks}
            domain={[0, ticks[ticks.length - 1]]}
            tick={{ fontSize: 11.5, fill: '#A9A8A3' }}
            tickFormatter={(v: number) => formatAxis(v)}
          />
          <Tooltip
            content={(p) => <ChartTip active={p.active} payload={p.payload} />}
            cursor={<CursorBand />}
            isAnimationActive={false}
            offset={16}
            reverseDirection={{ x: true }}
            position={{ y: 24 }}
          />
          <Bar
            dataKey="income"
            name="Thu"
            fill={INCOME}
            radius={[4, 4, 0, 0]}
            maxBarSize={barSize}
            isAnimationActive={false}
            label={({ x, y, width, index }) =>
              index === last && data[last]?.month === thisMonth ? (
                <text x={Number(x) + Number(width) + 1} y={Number(y) - 10} textAnchor="middle" fontSize={12} fill="#787774" className="tabular-nums">
                  đến {todayDayMonth()}
                </text>
              ) : null
            }
          />
          <Bar dataKey="expense" name="Chi" fill={EXPENSE} radius={[4, 4, 0, 0]} maxBarSize={barSize} isAnimationActive={false} />
        </BarChart>
      </ResponsiveContainer>
    </div>
  )
}

/** Cùng số liệu dạng bảng (cho người dùng trình đọc màn hình / cần số chính xác). */
export function TrendTable({ data }: { data: MonthTotal[] }) {
  return (
    <Table compact className="mt-2" data-testid="trend-table">
      <TableHeader>
        <TableRow>
          <TableHead className="pl-0 first:pl-0">Tháng</TableHead>
          <TableHead className="text-right">Thu</TableHead>
          <TableHead className="text-right">Chi</TableHead>
          <TableHead className="pr-0 text-right">Chênh lệch</TableHead>
        </TableRow>
      </TableHeader>
      <TableBody>
        {data.map((d) => (
          <TableRow key={d.month} data-month={d.month}>
            <TableCell className="pl-0 font-medium first:pl-0">{formatMonthLong(d.month)}</TableCell>
            <TableCell className="text-right font-semibold text-income tabular-nums">{formatVND(d.income)}</TableCell>
            <TableCell className="text-right font-semibold tabular-nums">{formatSigned(d.expense, false)}</TableCell>
            <TableCell className={cn('pr-0 text-right font-semibold tabular-nums', d.net >= 0 && 'text-income')}>{formatSigned(d.net, d.net >= 0)}</TableCell>
          </TableRow>
        ))}
      </TableBody>
    </Table>
  )
}
