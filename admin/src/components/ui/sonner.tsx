import type { ReactNode } from "react"
import { Toaster as Sonner, toast } from "sonner"
import { Check, CircleAlert, X } from "lucide-react"
import { cn } from "@/lib/utils"

/** Toast góc dưới phải, rộng 420px. Nội dung do `notify` dựng (toast.custom) để khớp mockup. */
function Toaster() {
  return (
    <Sonner
      position="bottom-right"
      offset={{ bottom: 32, right: 40 }}
      gap={10}
      expand
      visibleToasts={4}
      style={{ "--width": "420px" } as React.CSSProperties}
      toastOptions={{ unstyled: true, className: "w-full" }}
    />
  )
}

type Tone = "success" | "error"

function ToastCard({ id, tone, title, description, icon, undo }: {
  id: string | number
  tone: Tone
  title: ReactNode
  description?: ReactNode
  icon?: ReactNode
  undo?: () => void
}) {
  return (
    <div
      role={tone === "error" ? "alert" : "status"}
      data-testid={`toast-${tone}`}
      className="flex w-full items-start gap-3 rounded-[16px] border border-border bg-card py-3.5 pr-3.5 pl-4 font-sans shadow-pop"
    >
      <span
        className={cn(
          "mt-px flex size-8 shrink-0 items-center justify-center rounded-full [&_svg]:size-4",
          tone === "success" ? "bg-success-soft text-income" : "bg-destructive-soft text-destructive"
        )}
      >
        {icon ?? (tone === "success" ? <Check /> : <CircleAlert />)}
      </span>
      <div className="min-w-0 flex-1">
        <p className="text-sm leading-[1.4] font-semibold">{title}</p>
        {description && <p className="mt-0.5 text-[13px] leading-normal text-pretty text-muted-foreground">{description}</p>}
      </div>
      {undo ? (
        <button
          type="button"
          className="mt-0.5 cursor-pointer text-[13.5px] font-semibold whitespace-nowrap hover:underline"
          onClick={() => {
            toast.dismiss(id)
            undo()
          }}
        >
          Hoàn tác
        </button>
      ) : (
        <button
          type="button"
          aria-label="Đóng"
          className="-mt-0.5 -mr-0.5 flex size-7 cursor-pointer items-center justify-center rounded-full text-muted-foreground hover:bg-muted"
          onClick={() => toast.dismiss(id)}
        >
          <X className="size-[15px]" />
        </button>
      )}
    </div>
  )
}

const notify = {
  success: (title: ReactNode, opts: { description?: ReactNode; icon?: ReactNode; undo?: () => void } = {}) =>
    toast.custom((id) => <ToastCard id={id} tone="success" title={title} {...opts} />, { duration: opts.undo ? 10_000 : 5000 }),
  error: (title: ReactNode, description?: ReactNode) =>
    toast.custom((id) => <ToastCard id={id} tone="error" title={title} description={description} />, { duration: 10_000 }),
}

export { Toaster, notify }
