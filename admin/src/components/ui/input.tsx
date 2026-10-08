import * as React from "react"
import { CircleAlert, Eye, EyeOff } from "lucide-react"
import { cn } from "@/lib/utils"

const fieldClass =
  "flex w-full min-w-0 items-center gap-2.5 rounded-sm border border-input bg-card text-sm transition-[border-color,box-shadow] has-[input:focus-visible,textarea:focus-visible]:border-primary has-[input:focus-visible,textarea:focus-visible]:ring-3 has-[input:focus-visible,textarea:focus-visible]:ring-primary/6 has-aria-invalid:border-destructive-bar has-aria-invalid:ring-3 has-aria-invalid:ring-destructive-bar/8 has-disabled:bg-background has-disabled:text-faint [&_svg]:shrink-0 [&_svg]:text-muted-foreground has-disabled:[&_svg]:text-faint"

/**
 * Ô nhập theo mockup: 40px (mặc định) hoặc 52px (`size="lg"`, form đăng nhập / tài khoản).
 * `icon` hiển thị bên trái, `end` bên phải (vd nút hiện mật khẩu).
 */
function Input({
  className,
  wrapperClassName,
  size = "default",
  icon,
  end,
  ...props
}: Omit<React.ComponentProps<"input">, "size"> & {
  size?: "default" | "lg"
  icon?: React.ReactNode
  end?: React.ReactNode
  wrapperClassName?: string
}) {
  return (
    <div
      data-slot="input-wrapper"
      className={cn(
        fieldClass,
        size === "lg" ? "h-[52px] rounded-md px-4 text-[15px]" : "h-10 px-3.5",
        "[&_svg:not([class*='size-'])]:size-[17px]",
        wrapperClassName
      )}
    >
      {icon}
      <input
        data-slot="input"
        className={cn("h-full w-full min-w-0 flex-1 bg-transparent outline-none placeholder:text-faint disabled:cursor-not-allowed", className)}
        {...props}
      />
      {end}
    </div>
  )
}

function Textarea({ className, wrapperClassName, ...props }: React.ComponentProps<"textarea"> & { wrapperClassName?: string }) {
  return (
    <div data-slot="textarea-wrapper" className={cn(fieldClass, "items-start px-3.5 py-3", wrapperClassName)}>
      <textarea
        data-slot="textarea"
        className={cn("min-h-[52px] w-full resize-none bg-transparent leading-[1.55] outline-none placeholder:text-faint", className)}
        {...props}
      />
    </div>
  )
}

/** Nhãn + ô + dòng trợ giúp/lỗi. */
function Field({
  label,
  htmlFor,
  aside,
  help,
  error,
  errorTestId,
  className,
  children,
}: {
  label: React.ReactNode
  htmlFor?: string
  aside?: React.ReactNode
  help?: React.ReactNode
  error?: React.ReactNode
  errorTestId?: string
  className?: string
  children: React.ReactNode
}) {
  return (
    <div className={cn("flex flex-col gap-2", className)}>
      <label htmlFor={htmlFor} className="flex justify-between text-[13px] font-medium text-muted-foreground">
        {label}
        {aside && <span className="font-normal text-faint tabular-nums">{aside}</span>}
      </label>
      {children}
      {error ? (
        <p role="alert" data-testid={errorTestId} className="flex items-center gap-1.5 text-body-s text-destructive">
          <CircleAlert className="size-3.5" />
          {error}
        </p>
      ) : (
        help && <p className="text-body-s text-faint">{help}</p>
      )}
    </div>
  )
}

/** Ô mật khẩu có nút hiện/ẩn. */
function PasswordInput(props: Omit<React.ComponentProps<typeof Input>, "type" | "end">) {
  const [show, setShow] = React.useState(false)
  return (
    <Input
      {...props}
      type={show ? "text" : "password"}
      className={cn(!show && "tracking-[2px] placeholder:tracking-normal", props.className)}
      end={
        <button
          type="button"
          tabIndex={-1}
          aria-label={show ? "Ẩn mật khẩu" : "Hiện mật khẩu"}
          onClick={() => setShow((v) => !v)}
          className="-mr-1 flex size-8 shrink-0 cursor-pointer items-center justify-center rounded-full hover:bg-muted [&_svg]:size-[17px]"
        >
          {show ? <EyeOff /> : <Eye />}
        </button>
      }
    />
  )
}

export { Input, PasswordInput, Textarea, Field }
