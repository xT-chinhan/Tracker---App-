import type { ReactNode } from 'react'
import {
  AlertDialog, AlertDialogAction, AlertDialogCancel, AlertDialogContent, AlertDialogDescription, AlertDialogTitle,
} from '@/components/ui/alert-dialog'
import { buttonVariants } from '@/components/ui/button'
import { Bubble } from '@/components/CategoryIcon'

export interface ConfirmOptions {
  title: string
  description: ReactNode
  confirmText: string
  icon: ReactNode
  /** danger = bong bóng + nút đỏ nhạt */
  destructive?: boolean
  facts?: [string, ReactNode][]
  onConfirm: () => void
}

/** Hộp xác nhận điều khiển bằng state: truyền `options = null` để đóng. */
export function ConfirmDialog({ options, onClose }: { options: ConfirmOptions | null; onClose: () => void }) {
  return (
    <AlertDialog open={!!options} onOpenChange={(o) => !o && onClose()}>
      <AlertDialogContent>
        {options && (
          <>
            <Bubble size="lg" tone={options.destructive ? 'danger' : 'default'}>{options.icon}</Bubble>
            <AlertDialogTitle className="mt-[18px]">{options.title}</AlertDialogTitle>
            <AlertDialogDescription>{options.description}</AlertDialogDescription>
            {options.facts && (
              <dl className="mt-[18px] rounded-md bg-background px-4 py-1">
                {options.facts.map(([k, v]) => (
                  <div key={k} className="flex h-[42px] items-center justify-between gap-4 border-border text-[13.5px] not-first:border-t">
                    <dt className="text-muted-foreground">{k}</dt>
                    <dd className="truncate tabular-nums">{v}</dd>
                  </div>
                ))}
              </dl>
            )}
            <div className="mt-6 flex gap-2.5">
              <AlertDialogCancel>Hủy</AlertDialogCancel>
              <AlertDialogAction
                className={options.destructive ? buttonVariants({ variant: 'danger-soft', size: 'dialog' }) : undefined}
                onClick={() => {
                  options.onConfirm()
                  onClose()
                }}
              >
                {options.icon}
                {options.confirmText}
              </AlertDialogAction>
            </div>
          </>
        )}
      </AlertDialogContent>
    </AlertDialog>
  )
}
