import { Fragment, type ReactNode } from 'react'
import { useNavigate } from 'react-router'
import { ChevronRight, Database } from 'lucide-react'
import type { AiReplyBlock } from '@/lib/api'
import { cn } from '@/lib/utils'

/** "**đậm**" → <strong>. */
export function RichText({ text }: { text: string }) {
  const parts = text.split(/(\*\*[^*]+\*\*)/g)
  return <>{parts.map((p, i) => (p.startsWith('**') && p.endsWith('**') ? <strong key={i} className="font-semibold">{p.slice(2, -2)}</strong> : <Fragment key={i}>{p}</Fragment>))}</>
}

function Stats({ items }: { items: { label: string; value: string; sub?: string }[] }) {
  return (
    <div className={cn('grid overflow-hidden rounded-[16px] border border-border bg-card', items.length >= 4 ? 'grid-cols-2 xl:grid-cols-4' : items.length === 3 ? 'grid-cols-3' : 'grid-cols-2')} data-testid="ai-block-stats">
      {items.map((it) => (
        <div key={it.label} className="flex min-w-0 flex-col gap-1 border-line px-4 py-3.5 not-first:border-l [&:nth-child(3)]:max-xl:border-l-0 [&:nth-child(n+3)]:max-xl:border-t">
          <p className="truncate text-[13px] text-muted-foreground">{it.label}</p>
          <p className="truncate text-[24px] leading-[1.2] font-bold tracking-[-0.02em] tabular-nums" title={it.value}>{it.value}</p>
          {it.sub && <p className="text-body-s text-muted-foreground tabular-nums">{it.sub}</p>}
        </div>
      ))}
    </div>
  )
}

function Cell({ text, first }: { text: string; first?: boolean }) {
  const [head, ...rest] = text.split('\n')
  return (
    <>
      <span className={cn('block leading-[1.45]', first && 'font-medium')}><RichText text={head} /></span>
      {rest.map((r, i) => <span key={i} className="block text-body-s leading-[1.45] text-muted-foreground"><RichText text={r} /></span>)}
    </>
  )
}

function Table({ b }: { b: Extract<AiReplyBlock, { type: 'table' }> }) {
  const navigate = useNavigate()
  const right = (i: number) => b.align?.[i] === 'right'
  return (
    <div className="overflow-hidden rounded-[16px] border border-border bg-card" data-testid="ai-block-table">
      <table className="w-full text-[14px]">
        <thead>
          <tr className="border-b border-line">
            {b.columns.map((c, i) => <th key={c} className={cn('px-4 py-2.5 text-left text-[13px] font-medium whitespace-nowrap text-muted-foreground', right(i) && 'text-right')}>{c}</th>)}
            {b.links && <th className="w-8" />}
          </tr>
        </thead>
        <tbody>
          {b.rows.map((r, ri) => {
            const to = b.links?.[ri]
            return (
              <tr
                key={ri}
                onClick={to ? () => navigate(to) : undefined}
                className={cn('border-line align-top not-last:border-b', to && 'cursor-pointer hover:bg-hover')}
                data-testid="ai-block-row"
              >
                {r.map((cell, ci) => <td key={ci} className={cn('px-4 py-2.5', right(ci) && 'text-right tabular-nums')}><Cell text={cell} first={ci === 0} /></td>)}
                {b.links && <td className="py-2.5 pr-3 text-faint">{to && <ChevronRight className="mt-0.5 size-4" />}</td>}
              </tr>
            )
          })}
        </tbody>
      </table>
      {b.more && <p className="border-t border-line px-4 py-2.5 text-body-s text-muted-foreground">{b.more}</p>}
    </div>
  )
}

/** Câu trả lời dạng chữ (không có khối): gạch đầu dòng thành danh sách, "Nhãn: …" in đậm nhãn. */
export function FormattedText({ text, className }: { text: string; className?: string }) {
  const out: ReactNode[] = []
  let list: string[] = []
  const flush = () => {
    if (list.length) out.push(<ul key={`l${out.length}`} className="flex list-disc flex-col gap-1 pl-5 marker:text-faint">{list.map((x, i) => <li key={i}><RichText text={x} /></li>)}</ul>)
    list = []
  }
  for (const line of text.split('\n')) {
    const bullet = /^\s*(?:[•\-*]|\d+\.)\s+(.*)$/.exec(line)
    if (bullet) { list.push(bullet[1]); continue }
    flush()
    if (!line.trim()) continue
    const lab = /^([^:\d]{2,40}):\s+(.+)$/.exec(line)
    out.push(<p key={`p${out.length}`}>{lab ? <><strong className="font-semibold">{lab[1]}</strong>: <RichText text={lab[2]} /></> : <RichText text={line} />}</p>)
  }
  flush()
  return <div className={cn('flex flex-col gap-2', className)}>{out}</div>
}

export function ReplyBlocks({ blocks, className }: { blocks: AiReplyBlock[]; className?: string }) {
  return (
    <div className={cn('flex flex-col gap-3', className)} data-testid="ai-blocks">
      {blocks.map((b, i) =>
        b.type === 'stats' ? <Stats key={i} items={b.items} />
          : b.type === 'table' ? <Table key={i} b={b} />
            : b.type === 'list' ? <ul key={i} className="flex list-disc flex-col gap-1 pl-5 marker:text-faint">{b.items.map((x, j) => <li key={j}><RichText text={x} /></li>)}</ul>
              : b.type === 'source' ? <p key={i} className="flex items-center gap-1.5 text-[13px] text-faint" data-testid="ai-block-source"><Database className="size-3.5 shrink-0" />{b.text}</p>
                : <p key={i}><RichText text={b.text} /></p>,
      )}
    </div>
  )
}
