import { useState, type FormEvent } from 'react'
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { KeyRound, Lock, ShieldCheck } from 'lucide-react'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { Card } from '@/components/ui/card'
import { Field, Input, PasswordInput } from '@/components/ui/input'
import { notify } from '@/components/ui/sonner'
import { Bubble } from '@/components/CategoryIcon'
import { PageHeader, UserBubble } from '@/components/common'
import { api, auth } from '@/lib/api'
import { formatDate } from '@/lib/format'

type PwErrors = { current?: string; next?: string; confirm?: string }

export default function AccountPage() {
  const qc = useQueryClient()
  const { data: me } = useQuery({ queryKey: ['me'], queryFn: api.me, initialData: auth.user() ?? undefined })
  const [name, setName] = useState(me?.name ?? '')
  const [pw, setPw] = useState({ current: '', next: '', confirm: '' })
  const [pwErr, setPwErr] = useState<PwErrors>({})

  const saveName = useMutation({
    mutationFn: () => api.updateMe(name.trim()),
    onSuccess: (u) => {
      auth.setUser(u)
      qc.setQueryData(['me'], u)
      qc.invalidateQueries({ queryKey: ['users'] })
      notify.success('Đã cập nhật tên hiển thị', { description: `Tên mới: ${u.name}` })
    },
    onError: (e) => notify.error('Không lưu được tên', e.message),
  })
  const changePw = useMutation({
    mutationFn: () => api.changePassword(pw.current, pw.next),
    onSuccess: ({ accessToken, user }) => {
      auth.save(accessToken, user) // token cũ đã bị vô hiệu
      setPw({ current: '', next: '', confirm: '' })
      notify.success('Đã đổi mật khẩu', { description: 'Các thiết bị khác đã bị đăng xuất.', icon: <KeyRound /> })
    },
    // Lỗi của backend (vd sai mật khẩu hiện tại) hiện ngay dưới ô tương ứng
    onError: (e) => setPwErr(/hiện tại/i.test(e.message) ? { current: e.message } : { next: e.message }),
  })

  const submitName = (e: FormEvent) => {
    e.preventDefault()
    if (name.trim()) saveName.mutate()
  }
  const submitPw = (e: FormEvent) => {
    e.preventDefault()
    const errs: PwErrors = {}
    if (!pw.current) errs.current = 'Nhập mật khẩu hiện tại'
    if (pw.next.length < 6) errs.next = 'Mật khẩu mới phải có ít nhất 6 ký tự'
    else if (pw.next !== pw.confirm) errs.confirm = 'Mật khẩu nhập lại chưa khớp'
    setPwErr(errs)
    if (!Object.keys(errs).length) changePw.mutate()
  }
  const setField = (k: keyof typeof pw, v: string) => {
    setPw({ ...pw, [k]: v })
    setPwErr({ ...pwErr, [k]: undefined })
  }

  return (
    <>
      <PageHeader title="Tài khoản" description="Thông tin đăng nhập của bạn" />
      <div className="grid grid-cols-12 items-start gap-5">
        <Card className="col-span-6">
          <div className="flex items-center gap-4">
            <UserBubble name={me?.name ?? '?'} size="xl" />
            <div className="min-w-0">
              <p className="truncate text-title-l" data-testid="account-name">{me?.name}</p>
              <div className="mt-1 flex items-center gap-2">
                <Badge variant="ink"><ShieldCheck />Quản trị</Badge>
                {me && <span className="text-body-s text-muted-foreground tabular-nums">từ {formatDate(me.createdAt)}</span>}
              </div>
            </div>
          </div>
          <form onSubmit={submitName} className="mt-8 flex flex-col gap-[18px]">
            <Field label="Họ và tên" htmlFor="name">
              <Input id="name" size="lg" value={name} maxLength={100} required onChange={(e) => setName(e.target.value)} />
            </Field>
            <Field label="Email đăng nhập" htmlFor="email" help="Email không đổi được trong bảng quản trị.">
              <Input id="email" size="lg" icon={<Lock />} value={me?.email ?? ''} disabled readOnly />
            </Field>
            <div className="mt-3.5 flex justify-end">
              <Button type="submit" disabled={saveName.isPending || !name.trim() || name.trim() === me?.name} data-testid="save-name">Lưu tên</Button>
            </div>
          </form>
        </Card>

        <Card className="col-span-6">
          <div className="flex items-center gap-3.5">
            <Bubble size="lg"><KeyRound /></Bubble>
            <div>
              <p className="text-title-l">Đổi mật khẩu</p>
              <p className="mt-0.5 text-body-s text-muted-foreground">Cần mật khẩu hiện tại để xác nhận</p>
            </div>
          </div>
          <form onSubmit={submitPw} className="mt-8 flex flex-col gap-[18px]" noValidate>
            <Field label="Mật khẩu hiện tại" htmlFor="pw-current" error={pwErr.current} errorTestId="pw-error">
              <PasswordInput id="pw-current" size="lg" autoComplete="current-password" aria-invalid={!!pwErr.current} value={pw.current} onChange={(e) => setField('current', e.target.value)} />
            </Field>
            <Field label="Mật khẩu mới" htmlFor="pw-new" help="Tối thiểu 6 ký tự" error={pwErr.next} errorTestId="pw-error">
              <PasswordInput id="pw-new" size="lg" autoComplete="new-password" aria-invalid={!!pwErr.next} value={pw.next} onChange={(e) => setField('next', e.target.value)} />
            </Field>
            <Field label="Nhập lại mật khẩu mới" htmlFor="pw-confirm" error={pwErr.confirm} errorTestId="pw-error">
              <PasswordInput id="pw-confirm" size="lg" autoComplete="new-password" aria-invalid={!!pwErr.confirm} value={pw.confirm} onChange={(e) => setField('confirm', e.target.value)} />
            </Field>
            <div className="mt-3.5 flex justify-end">
              <Button type="submit" disabled={changePw.isPending} data-testid="save-password">Đổi mật khẩu</Button>
            </div>
          </form>
        </Card>
      </div>
    </>
  )
}
