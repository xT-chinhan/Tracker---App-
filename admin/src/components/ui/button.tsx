import * as React from "react"
import { cva, type VariantProps } from "class-variance-authority"
import { cn } from "@/lib/utils"
import { Slot } from "radix-ui"

/** Nút dạng viên thuốc: đen = hành động chính, trắng viền mảnh = phụ, đỏ nhạt = nguy hiểm. */
const buttonVariants = cva(
  "inline-flex shrink-0 cursor-pointer items-center justify-center gap-2 rounded-full border border-transparent font-semibold whitespace-nowrap transition-[transform,background-color,color] duration-150 ease-out outline-none select-none focus-visible:ring-2 focus-visible:ring-primary/10 active:not-disabled:scale-[0.97] disabled:pointer-events-none [&_svg]:pointer-events-none [&_svg]:shrink-0 [&_svg:not([class*='size-'])]:size-[17px]",
  {
    variants: {
      variant: {
        default: "bg-primary text-primary-foreground hover:bg-primary/88 disabled:bg-muted-high disabled:text-faint",
        secondary: "border-border bg-card text-foreground hover:bg-hover disabled:text-faint",
        danger: "border-border bg-card text-destructive hover:bg-destructive-soft/50 disabled:text-faint",
        "danger-soft": "bg-destructive-soft text-destructive hover:bg-destructive-soft/70 disabled:opacity-60",
        ghost: "text-muted-foreground hover:bg-muted hover:text-foreground disabled:text-faint",
        link: "h-auto! rounded-none px-0! text-[13.5px] text-foreground hover:underline [&_svg:not([class*='size-'])]:size-4",
      },
      size: {
        default: "h-10 px-[18px] text-sm",
        sm: "h-8 gap-1.5 px-3 text-[13px] [&_svg:not([class*='size-'])]:size-[15px]",
        lg: "h-[52px] px-6 text-base",
        dialog: "h-[46px] flex-1 px-[18px] text-[15px]",
        icon: "size-9 font-medium text-muted-foreground hover:bg-muted hover:text-foreground aria-expanded:bg-muted aria-expanded:text-foreground [&_svg:not([class*='size-'])]:size-[18px]",
        "icon-sm": "size-8 font-medium text-muted-foreground hover:bg-muted hover:text-foreground [&_svg:not([class*='size-'])]:size-4",
      },
    },
    compoundVariants: [
      { variant: ["default", "secondary", "danger", "danger-soft", "ghost", "link"], size: ["icon", "icon-sm"], className: "border-transparent bg-transparent" },
    ],
    defaultVariants: { variant: "default", size: "default" },
  }
)

function Button({
  className,
  variant = "default",
  size = "default",
  asChild = false,
  ...props
}: React.ComponentProps<"button"> & VariantProps<typeof buttonVariants> & { asChild?: boolean }) {
  const Comp = asChild ? Slot.Root : "button"
  return (
    <Comp
      data-slot="button"
      data-variant={variant}
      data-size={size}
      className={cn(buttonVariants({ variant, size, className }))}
      {...props}
    />
  )
}

export { Button, buttonVariants }
