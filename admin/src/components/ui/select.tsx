import * as React from "react"
import { cn } from "@/lib/utils"
import { Select as SelectPrimitive } from "radix-ui"
import { CheckIcon, ChevronDownIcon } from "lucide-react"

function Select(props: React.ComponentProps<typeof SelectPrimitive.Root>) {
  return <SelectPrimitive.Root data-slot="select" {...props} />
}

function SelectValue(props: React.ComponentProps<typeof SelectPrimitive.Value>) {
  return <SelectPrimitive.Value data-slot="select-value" {...props} />
}

/** Select dạng viên thuốc: "Nhãn: Giá trị" + chevron. */
function SelectTrigger({
  className,
  label,
  icon,
  children,
  ...props
}: React.ComponentProps<typeof SelectPrimitive.Trigger> & { label?: string; icon?: React.ReactNode }) {
  return (
    <SelectPrimitive.Trigger
      data-slot="select-trigger"
      className={cn(
        "group/select flex h-10 min-w-0 cursor-pointer items-center justify-between gap-2 rounded-full border border-input bg-card pr-3 pl-3.5 text-sm whitespace-nowrap outline-none transition-[border-color,box-shadow] select-none focus-visible:border-primary focus-visible:ring-3 focus-visible:ring-primary/6 disabled:cursor-not-allowed disabled:bg-background disabled:text-faint data-[state=open]:border-primary [&_svg]:pointer-events-none [&_svg]:shrink-0",
        className
      )}
      {...props}
    >
      <span className="flex min-w-0 items-center gap-2 [&_svg:not([class*='size-'])]:size-[17px] [&_svg]:text-muted-foreground group-disabled/select:[&_svg]:text-faint">
        {icon}
        <span className="truncate">
          {label && <span className="text-muted-foreground group-disabled/select:text-faint">{label}: </span>}
          <span className="font-medium">{children}</span>
        </span>
      </span>
      <SelectPrimitive.Icon asChild>
        <ChevronDownIcon className="size-4 text-muted-foreground group-disabled/select:text-faint" />
      </SelectPrimitive.Icon>
    </SelectPrimitive.Trigger>
  )
}

function SelectContent({ className, children, ...props }: React.ComponentProps<typeof SelectPrimitive.Content>) {
  return (
    <SelectPrimitive.Portal>
      <SelectPrimitive.Content
        data-slot="select-content"
        position="popper"
        sideOffset={6}
        className={cn(
          "relative z-50 max-h-(--radix-select-content-available-height) min-w-(--radix-select-trigger-width) origin-(--radix-select-content-transform-origin) overflow-x-hidden overflow-y-auto rounded-md border border-border bg-popover p-1.5 text-popover-foreground shadow-pop data-open:animate-in data-open:fade-in-0 data-open:zoom-in-95 data-closed:animate-out data-closed:fade-out-0",
          className
        )}
        {...props}
      >
        <SelectPrimitive.Viewport>{children}</SelectPrimitive.Viewport>
      </SelectPrimitive.Content>
    </SelectPrimitive.Portal>
  )
}

function SelectItem({ className, children, ...props }: React.ComponentProps<typeof SelectPrimitive.Item>) {
  return (
    <SelectPrimitive.Item
      data-slot="select-item"
      className={cn(
        "relative flex min-h-10 w-full cursor-pointer items-center gap-2.5 rounded-[10px] py-1.5 pr-9 pl-2.5 text-sm font-medium outline-hidden select-none data-highlighted:bg-muted data-disabled:pointer-events-none data-disabled:opacity-50 [&_svg]:shrink-0",
        className
      )}
      {...props}
    >
      <span className="pointer-events-none absolute right-2.5 flex size-4 items-center justify-center">
        <SelectPrimitive.ItemIndicator>
          <CheckIcon className="size-4" />
        </SelectPrimitive.ItemIndicator>
      </span>
      <SelectPrimitive.ItemText>{children}</SelectPrimitive.ItemText>
    </SelectPrimitive.Item>
  )
}

export { Select, SelectContent, SelectItem, SelectTrigger, SelectValue }
