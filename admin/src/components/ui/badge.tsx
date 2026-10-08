import * as React from "react"
import { cva, type VariantProps } from "class-variance-authority"
import { cn } from "@/lib/utils"

const badgeVariants = cva(
  "inline-flex h-[26px] w-fit shrink-0 items-center gap-1.5 rounded-full px-2.5 text-xs leading-none font-semibold whitespace-nowrap [&>svg]:size-[13px] [&>svg]:[stroke-width:2]",
  {
    variants: {
      variant: {
        default: "bg-muted text-[#4A4945]",
        ink: "bg-primary text-primary-foreground",
        danger: "bg-destructive-soft text-destructive",
        success: "bg-success-soft text-income",
        warning: "bg-warning-soft text-warning",
        plain: "bg-transparent px-0 text-[13.5px] font-medium text-muted-foreground",
      },
    },
    defaultVariants: { variant: "default" },
  }
)

function Badge({ className, variant, ...props }: React.ComponentProps<"span"> & VariantProps<typeof badgeVariants>) {
  return <span data-slot="badge" className={cn(badgeVariants({ variant }), className)} {...props} />
}

export { Badge }
