import { useState, type FormEvent } from 'react'
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { toast } from 'sonner'
import { Loader2 } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { PageHeader, RoleBadge } from '@/components/common'
import { api, auth } from '@/lib/api'

export default function AccountPage() {
  const qc = useQueryClient()
  const { data: me } = useQuery({ queryKey: ['me'], queryFn: api.me, initialData: auth.user() ?? undefined })
  const [name, setName] = useState(me?.name ?? '')
  const [pw, setPw] = useState({ current: '', next: '', confirm: '' })
  const [pwError, setPwError] = useState<string | null>(null)

  const saveName = useMutation({
    mutationFn: () => api.updateMe(name.trim()),
    onSuccess: (u) => {
      auth.setUser(u)
      qc.setQueryData(['me'], u)
      qc.invalidateQueries({ queryKey: ['users'] })
      toast.success('Đã cập nhật tên hiển thị')
    },
    onError: (e) => toast.error(e.message),
  })
  const changePw = useMutation({
    mutationFn: () => api.changePassword(pw.current, pw.next),
    onSuccess: () => {
      setPw({ current: '', next: '', confirm: '' })
      toast.success('Đã đổi mật khẩu')
    },
    onError: (e) => setPwError(e.message),
  })

  const submitName = (e: FormEvent) => {
    e.preventDefault()
    if (name.trim()) saveName.mutate()
  }
  const submitPw = (e: FormEvent) => {
    e.preventDefault()
    setPwError(null)
    if (pw.next.length < 6) return setPwError('Mật khẩu mới phải có ít nhất 6 ký tự')
    if (pw.next !== pw.confirm) return setPwError('Xác nhận mật khẩu không khớp')
    changePw.mutate()
  }

  return (
    <>
      <PageHeader title="Tài khoản" description="Thông tin đăng nhập quản trị viên" />
      <div className="grid max-w-3xl gap-6">
        <Card>
          <CardHeader>
            <CardTitle>Thông tin cá nhân</CardTitle>
            <CardDescription className="flex items-center gap-2">{me?.email} {me && <RoleBadge role={me.role} />}</CardDescription>
          </CardHeader>
          <CardContent>
            <form onSubmit={submitName} className="flex flex-wrap items-end gap-3 sm:max-w-md">
              <div className="grid min-w-52 flex-1 gap-2">
                <Label htmlFor="name">Tên hiển thị</Label>
                <Input id="name" value={name} maxLength={100} required onChange={(e) => setName(e.target.value)} />
              </div>
              <Button type="submit" disabled={saveName.isPending || !name.trim() || name.trim() === me?.name} data-testid="save-name">
                {saveName.isPending && <Loader2 className="animate-spin" />} Lưu
              </Button>
            </form>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Đổi mật khẩu</CardTitle>
            <CardDescription>Mật khẩu mới tối thiểu 6 ký tự</CardDescription>
          </CardHeader>
          <CardContent>
            <form onSubmit={submitPw} className="grid gap-4 sm:max-w-sm">
              {pwError && <p role="alert" className="rounded-lg border border-destructive/20 bg-destructive/5 p-3 text-sm text-destructive" data-testid="pw-error">{pwError}</p>}
              <div className="grid gap-2">
                <Label htmlFor="pw-current">Mật khẩu hiện tại</Label>
                <Input id="pw-current" type="password" autoComplete="current-password" required value={pw.current} onChange={(e) => setPw({ ...pw, current: e.target.value })} />
              </div>
              <div className="grid gap-2">
                <Label htmlFor="pw-new">Mật khẩu mới</Label>
                <Input id="pw-new" type="password" autoComplete="new-password" required value={pw.next} onChange={(e) => setPw({ ...pw, next: e.target.value })} />
              </div>
              <div className="grid gap-2">
                <Label htmlFor="pw-confirm">Nhập lại mật khẩu mới</Label>
                <Input id="pw-confirm" type="password" autoComplete="new-password" required value={pw.confirm} onChange={(e) => setPw({ ...pw, confirm: e.target.value })} />
              </div>
              <Button type="submit" className="w-fit" disabled={changePw.isPending} data-testid="save-password">
                {changePw.isPending && <Loader2 className="animate-spin" />} Đổi mật khẩu
              </Button>
            </form>
          </CardContent>
        </Card>
      </div>
    </>
  )
}
