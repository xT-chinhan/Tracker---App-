import { Bar, BarChart, CartesianGrid, Legend, ResponsiveContainer, Tooltip, XAxis, YAxis } from 'recharts'
import type { MonthTotal } from '@/lib/api'
import { CHART, formatCompact, formatMonth, formatVND } from '@/lib/format'

/** Thu vs chi theo tháng (cột đôi, một trục). */
export function TrendChart({ data, height = 280 }: { data: MonthTotal[]; height?: number }) {
  const rows = data.map((d) => ({ ...d, label: formatMonth(d.month) }))
  return (
    <div style={{ height }} data-testid="trend-chart">
      <ResponsiveContainer width="100%" height="100%">
        <BarChart data={rows} barGap={2} barCategoryGap="28%" margin={{ top: 8, right: 8, left: 0, bottom: 0 }}>
          <CartesianGrid vertical={false} stroke="var(--border)" />
          <XAxis dataKey="label" tickLine={false} axisLine={false} tick={{ fontSize: 12, fill: 'var(--muted-foreground)' }} />
          <YAxis
            width={56}
            tickLine={false}
            axisLine={false}
            tick={{ fontSize: 12, fill: 'var(--muted-foreground)' }}
            tickFormatter={(v: number) => formatCompact(v)}
          />
          <Tooltip
            cursor={{ fill: 'var(--muted)', opacity: 0.6 }}
            contentStyle={{ borderRadius: 10, border: '1px solid var(--border)', fontSize: 13 }}
            formatter={(v) => formatVND(Number(v))}
            labelFormatter={(l, p) => {
              const net = p?.[0]?.payload?.net as number | undefined
              return net === undefined ? String(l) : `${l} · Chênh lệch ${formatVND(net)}`
            }}
          />
          <Legend itemSorter={null} iconType="circle" iconSize={8} wrapperStyle={{ fontSize: 13, paddingTop: 8 }} />
          <Bar dataKey="income" name="Thu" fill={CHART.income} radius={[4, 4, 0, 0]} maxBarSize={28} isAnimationActive={false} />
          <Bar dataKey="expense" name="Chi" fill={CHART.expense} radius={[4, 4, 0, 0]} maxBarSize={28} isAnimationActive={false} />
        </BarChart>
      </ResponsiveContainer>
    </div>
  )
}
