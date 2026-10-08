import * as React from "react"
import { cn } from "@/lib/utils"
import { Tabs as TabsPrimitive } from "radix-ui"

/** Segmented control (nền xám, "thumb" trắng) dùng Radix Tabs cho bàn phím/aria. */
function Tabs(props: React.ComponentProps<typeof TabsPrimitive.Root>) {
  return <TabsPrimitive.Root data-slot="tabs" {...props} />
}

function TabsList({ className, size = "default", ...props }: React.ComponentProps<typeof TabsPrimitive.List> & { size?: "default" | "sm" }) {
  return (
    <TabsPrimitive.List
      data-slot="tabs-list"
      data-size={size}
      className={cn(
        "group/seg inline-grid auto-cols-fr grid-flow-col rounded-full bg-muted p-[3px]",
        size === "sm" ? "h-[34px]" : "h-10",
        className
      )}
      {...props}
    />
  )
}

function TabsTrigger({ className, ...props }: React.ComponentProps<typeof TabsPrimitive.Trigger>) {
  return (
    <TabsPrimitive.Trigger
      data-slot="tabs-trigger"
      className={cn(
        "flex cursor-pointer items-center justify-center gap-1.5 rounded-full px-[18px] text-sm font-medium whitespace-nowrap text-muted-foreground outline-none transition-colors group-data-[size=sm]/seg:px-3 group-data-[size=sm]/seg:text-[13px] hover:text-foreground focus-visible:ring-2 focus-visible:ring-primary/20 data-active:bg-card data-active:font-semibold data-active:text-foreground data-active:shadow-thumb",
        className
      )}
      {...props}
    />
  )
}

export { Tabs, TabsList, TabsTrigger }
