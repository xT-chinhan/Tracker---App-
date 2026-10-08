import * as React from "react"
import { cn } from "@/lib/utils"

/** Card trắng, viền hairline, bo 18. `flush` = không padding (chứa bảng / danh sách sát mép). */
function Card({ className, flush, ...props }: React.ComponentProps<"div"> & { flush?: boolean }) {
  return (
    <div
      data-slot="card"
      className={cn("min-w-0 rounded-lg border border-border bg-card shadow-card", !flush && "p-6", className)}
      {...props}
    />
  )
}

/** Tiêu đề card (16/600) + mô tả phụ + phần bên phải. */
function CardHeader({ title, sub, aside, className }: { title: React.ReactNode; sub?: React.ReactNode; aside?: React.ReactNode; className?: string }) {
  return (
    <div data-slot="card-header" className={cn("flex items-center justify-between gap-3", className)}>
      <div className="min-w-0">
        <h2 className="flex items-center gap-2 text-title-m">{title}</h2>
        {sub && <p className="mt-1 text-body-s font-medium text-muted-foreground">{sub}</p>}
      </div>
      {aside}
    </div>
  )
}

export { Card, CardHeader }
