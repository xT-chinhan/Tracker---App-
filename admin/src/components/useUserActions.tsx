import { useState } from 'react'
import { useMutation, useQueryClient } from '@tanstack/react-query'
import { toast } from 'sonner'
import { ConfirmDialog, type ConfirmOptions } from '@/components/ConfirmDialog'
import { api, type User } from '@/lib/api'

/** Khóa/mở khóa, cấp/hạ quyền admin kèm hộp xác nhận. Dùng chung cho danh sách và trang chi tiết. */
export function useUserActions() {
  const qc = useQueryClient()
  const [confirm, setConfirm] = useState<ConfirmOptions | null>(null)

  const mutation = useMutation({
    mutationFn: (v: { id: string; body: Parameters<typeof api.updateUser>[1]; success: string }) => api.updateUser(v.id, v.body),
    onSuccess: (_, v) => {
      toast.success(v.success)
      qc.invalidateQueries({ queryKey: ['users'] })
      qc.invalidateQueries({ queryKey: ['user', v.id] })
      qc.invalidateQueries({ queryKey: ['overview'] })
    },
    onError: (e) => toast.error(e.message),
  })

  const toggleLock = (u: Pick<User, 'id' | 'name' | 'status'>) => {
    const lock = u.status === 'ACTIVE'
    setConfirm({
      title: lock ? 'Khóa tài khoản?' : 'Mở khóa tài khoản?',
      description: lock
        ? `${u.name} sẽ bị đăng xuất khỏi mọi thiết bị và không thể đăng nhập cho tới khi được mở khóa.`
        : `${u.name} sẽ có thể đăng nhập và sử dụng ứng dụng trở lại.`,
      confirmText: lock ? 'Khóa tài khoản' : 'Mở khóa',
      destructive: lock,
      onConfirm: () =>
        mutation.mutate({ id: u.id, body: { status: lock ? 'LOCKED' : 'ACTIVE' }, success: lock ? `Đã khóa ${u.name}` : `Đã mở khóa ${u.name}` }),
    })
  }

  const toggleRole = (u: Pick<User, 'id' | 'name' | 'role'>) => {
    const promote = u.role === 'USER'
    setConfirm({
      title: promote ? 'Cấp quyền quản trị?' : 'Hạ quyền quản trị?',
      description: promote
        ? `${u.name} sẽ truy cập được trang quản trị và mọi dữ liệu người dùng.`
        : `${u.name} sẽ trở thành người dùng thường và mất quyền truy cập trang quản trị.`,
      confirmText: promote ? 'Cấp quyền' : 'Hạ quyền',
      destructive: !promote,
      onConfirm: () =>
        mutation.mutate({
          id: u.id,
          body: { role: promote ? 'ADMIN' : 'USER' },
          success: promote ? `Đã cấp quyền quản trị cho ${u.name}` : `Đã hạ quyền ${u.name}`,
        }),
    })
  }

  const dialog = <ConfirmDialog options={confirm} onClose={() => setConfirm(null)} />
  return { toggleLock, toggleRole, dialog, pending: mutation.isPending }
}
