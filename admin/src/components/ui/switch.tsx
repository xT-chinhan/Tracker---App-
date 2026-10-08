import * as React from "react"
import { Switch as SwitchPrimitive } from "radix-ui"
import { cn } from "@/lib/utils"

/** Switch 40×24 như mobile: xám khi tắt, đen khi bật; `tone="warn"` = vàng khi bật (bảo trì). */
function Switch({ className, tone = "default", ...props }: React.ComponentProps<typeof SwitchPrimitive.Root> & { tone?: "default" | "warn" }) {
  return (
    <SwitchPrimitive.Root
      data-slot="switch"
      className={cn(
        "peer relative inline-flex h-6 w-10 shrink-0 cursor-pointer items-center rounded-full bg-[#DAD8D2] transition-colors duration-200 ease-out outline-none focus-visible:ring-2 focus-visible:ring-primary/20 disabled:cursor-not-allowed disabled:opacity-60",
        tone === "warn" ? "data-[state=checked]:bg-warning-bar" : "data-[state=checked]:bg-primary",
        className
      )}
      {...props}
    >
      <SwitchPrimitive.Thumb className="pointer-events-none block size-5 translate-x-0.5 rounded-full bg-white shadow-[0_1px_3px_rgb(0_0_0/.15)] transition-transform duration-200 ease-out data-[state=checked]:translate-x-[18px]" />
    </SwitchPrimitive.Root>
  )
}

export { Switch }
