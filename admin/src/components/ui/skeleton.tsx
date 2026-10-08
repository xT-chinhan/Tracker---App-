import { cn } from "@/lib/utils"

/** Khối skeleton có ánh lướt (không dùng spinner). */
function Skeleton({ className, ...props }: React.ComponentProps<"div">) {
  return (
    <div
      data-slot="skeleton"
      className={cn(
        "animate-shimmer rounded-xs bg-[linear-gradient(90deg,var(--color-skeleton-a)_0%,var(--color-skeleton-b)_50%,var(--color-skeleton-a)_100%)] bg-size-[200%_100%] motion-reduce:animate-none",
        className
      )}
      {...props}
    />
  )
}

export { Skeleton }
