import { useState } from 'react'
import { useMutation, useQueryClient } from '@tanstack/react-query'
import { Lock, LockOpen, ShieldCheck, ShieldOff, Undo2 } from 'lucide-react'
import { notify } from '@/components/ui/sonner'
import { ConfirmDialog, type ConfirmOptions } from '@/components/ConfirmDialog'
import { api, type User } from '@/lib/api'
import { formatNumber } from '@/lib/format'

type Target = Pick<User, 'id' | 'name' | 'email' | 'status' | 'role'> & { _count?: { transactions: number; savingGoals: number } }
type Change = { status?: User['status']; role?: User['role'] }

const firstName = (name: string) => name.trim().split(/\s+/).pop() ?? name

/** Khóa/mở khóa, cấp/hạ quyền admin: hộp xác nhận, toast có Hoàn tác. Dùng chung cho danh sách và trang chi tiết. */
export function useUserActions() {
  const qc = useQueryClient()
  const [confirm, setConfirm] = useState<ConfirmOptions | null>(null)

  const mutation = useMutation({
    mutationFn: (v: { id: string; body: Change; onOk: () => void; failTitle: string }) => api.updateUser(v.id, v.body),
    onSuccess: (_, v) => {
      v.onOk()
      qc.invalidateQueries({ queryKey: ['users'] })
      qc.invalidateQueries({ queryKey: ['user', v.id] })
      qc.invalidateQueries({ queryKey: ['overview'] })
    },
    onError: (e, v) => notify.error(v.failTitle, e.message),
  })

  /** Áp thay đổi; toast thành công có nút Hoàn tác trả lại giá trị cũ. */
  const apply = (u: Target, body: Change, undoBody: Change, done: { title: string; description: string; icon: React.ReactNode }, failTitle: string) =>
    mutation.mutate({
      id: u.id,
      body,
      failTitle,
      onOk: () =>
        notify.success(done.title, {
          description: done.description,
          icon: done.icon,
          undo: () =>
            mutation.mutate({
              id: u.id,
              body: undoBody,
              failTitle: 'Không hoàn tác được',
              onOk: () => notify.success(`Đã hoàn tác thay đổi cho ${u.name}`, { icon: <Undo2 /> }),
            }),
        }),
    })

  const toggleLock = (u: Target) => {
    const lock = u.status === 'ACTIVE'
    const first = firstName(u.name)
    setConfirm({
      title: lock ? `Khóa tài khoản ${u.name}?` : `Mở khóa tài khoản ${u.name}?`,
      description: lock
        ? `${first} sẽ bị đăng xuất và không đăng nhập được cho tới khi được mở khóa. Dữ liệu vẫn được giữ nguyên.`
        : `${first} sẽ đăng nhập và dùng ứng dụng lại được ngay.`,
      icon: lock ? <Lock /> : <LockOpen />,
      destructive: lock,
      confirmText: lock ? 'Khóa tài khoản' : 'Mở khóa',
      facts: [
        ['Email', u.email],
        ...(u._count
          ? [['Dữ liệu giữ lại', `${formatNumber(u._count.transactions)} giao dịch · ${formatNumber(u._count.savingGoals)} mục tiêu`] as [string, string]]
          : []),
      ],
      onConfirm: () =>
        apply(
          u,
          { status: lock ? 'LOCKED' : 'ACTIVE' },
          { status: u.status },
          lock
            ? { title: `Đã khóa ${u.name}`, description: `${first} không đăng nhập được cho tới khi được mở khóa.`, icon: <Lock /> }
            : { title: `Đã mở khóa ${u.name}`, description: `${first} có thể đăng nhập lại ngay.`, icon: <LockOpen /> },
          lock ? 'Không khóa được tài khoản' : 'Không mở khóa được tài khoản',
        ),
    })
  }

  const toggleRole = (u: Target) => {
    const promote = u.role === 'USER'
    setConfirm({
      title: promote ? `Cấp quyền quản trị cho ${u.name}?` : `Hạ quyền quản trị của ${u.name}?`,
      description: promote
        ? `${firstName(u.name)} sẽ vào được bảng quản trị và xem được dữ liệu của mọi người dùng.`
        : `${firstName(u.name)} trở thành người dùng thường và mất quyền vào bảng quản trị.`,
      icon: promote ? <ShieldCheck /> : <ShieldOff />,
      destructive: !promote,
      confirmText: promote ? 'Cấp quyền' : 'Hạ quyền',
      facts: [['Email', u.email]],
      onConfirm: () =>
        apply(
          u,
          { role: promote ? 'ADMIN' : 'USER' },
          { role: u.role },
          promote
            ? { title: `Đã cấp quyền quản trị cho ${u.name}`, description: 'Quyền có hiệu lực ở lần tải trang tiếp theo.', icon: <ShieldCheck /> }
            : { title: `Đã hạ quyền ${u.name}`, description: `${firstName(u.name)} không còn vào được bảng quản trị.`, icon: <ShieldOff /> },
          promote ? 'Không cấp quyền được' : 'Không thể hạ quyền',
        ),
    })
  }

  const dialog = <ConfirmDialog options={confirm} onClose={() => setConfirm(null)} />
  return { toggleLock, toggleRole, dialog, pending: mutation.isPending }
}
