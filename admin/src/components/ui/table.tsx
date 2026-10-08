import * as React from "react"
import { cn } from "@/lib/utils"

/** Bảng không có nền header, chỉ hairline; dòng 56px (2 dòng chữ) hoặc 52px (`compact`). */
function Table({ className, compact, ...props }: React.ComponentProps<"table"> & { compact?: boolean }) {
  return (
    <table
      data-slot="table"
      data-compact={compact || undefined}
      className={cn("group/table w-full table-fixed border-collapse text-sm", className)}
      {...props}
    />
  )
}

function TableHeader(props: React.ComponentProps<"thead">) {
  return <thead data-slot="table-header" {...props} />
}

function TableBody({ className, ...props }: React.ComponentProps<"tbody">) {
  return <tbody data-slot="table-body" className={cn("[&>tr:last-child>td]:border-b-0", className)} {...props} />
}

function TableRow({ className, ...props }: React.ComponentProps<"tr">) {
  return (
    <tr
      data-slot="table-row"
      className={cn("hover:[&>td]:bg-hover has-aria-expanded:[&>td]:bg-hover", className)}
      {...props}
    />
  )
}

function TableHead({ className, ...props }: React.ComponentProps<"th">) {
  return (
    <th
      data-slot="table-head"
      className={cn(
        "h-11 border-b border-border px-4 text-left align-middle text-body-s font-medium whitespace-nowrap text-muted-foreground first:pl-6",
        className
      )}
      {...props}
    />
  )
}

function TableCell({ className, ...props }: React.ComponentProps<"td">) {
  return (
    <td
      data-slot="table-cell"
      className={cn(
        "h-14 truncate border-b border-line px-4 align-middle whitespace-nowrap first:pl-6 group-data-compact/table:h-[52px]",
        className
      )}
      {...props}
    />
  )
}

export { Table, TableHeader, TableBody, TableHead, TableRow, TableCell }
