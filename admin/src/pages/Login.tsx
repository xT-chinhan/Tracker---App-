import { useEffect, useState, type FormEvent } from 'react'
import { Navigate, useNavigate, useSearchParams } from 'react-router'
import { CircleAlert, KeyRound, Mail } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Card } from '@/components/ui/card'
import { Field, Input, PasswordInput } from '@/components/ui/input'
import { Logo } from '@/components/Layout'
import { api, auth } from '@/lib/api'

const YEAR = new Date().getFullYear()

const REASONS: Record<string, string> = {
  expired: 'Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại.',
  locked: 'Tài khoản đã bị khóa.',
  forbidden: 'Tài khoản không có quyền truy cập trang quản trị.',
}

export default function LoginPage() {
  const navigate = useNavigate()
  const [params] = useSearchParams()
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState<string | null>(REASONS[params.get('reason') ?? ''] ?? null)
  const [loading, setLoading] = useState(false)

  useEffect(() => {
    if (!auth.isValid()) auth.clear()
  }, [])

  if (auth.isValid()) return <Navigate to="/" replace />

  const submit = async (e: FormEvent) => {
    e.preventDefault()
    setError(null)
    setLoading(true)
    try {
      const { accessToken, user } = await api.login(email, password)
      if (user.role !== 'ADMIN') {
        setError('Tài khoản này không có quyền quản trị. Chỉ quản trị viên mới được đăng nhập.')
        return
      }
      auth.save(accessToken, user)
      navigate('/', { replace: true })
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Đăng nhập thất bại')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="relative flex min-h-svh flex-col items-center justify-center px-4 pb-10">
      <Card className="w-full max-w-[448px] rounded-2xl p-10">
        <Logo size="lg" />
        <h1 className="mt-6 text-headline">Đăng nhập quản trị</h1>
        <p className="mt-2 text-muted-foreground">Trang dành cho quản trị viên Thu Chi.</p>
        <form onSubmit={submit} className="mt-8">
          {error && (
            <div role="alert" data-testid="login-error" className="mb-5 flex gap-2.5 rounded-md bg-destructive-soft px-3.5 py-3 text-[13.5px] text-destructive">
              <CircleAlert className="mt-px size-4 shrink-0" />
              <span>{error}</span>
            </div>
          )}
          <Field label="Email" htmlFor="email">
            <Input id="email" size="lg" icon={<Mail />} type="email" autoComplete="username" required value={email} onChange={(e) => setEmail(e.target.value)} placeholder="ban@thuchi.vn" />
          </Field>
          <Field label="Mật khẩu" htmlFor="password" className="mt-4">
            <PasswordInput id="password" size="lg" icon={<KeyRound />} autoComplete="current-password" required value={password} onChange={(e) => setPassword(e.target.value)} />
          </Field>
          <Button type="submit" size="lg" className="mt-8 w-full" disabled={loading}>
            {loading ? 'Đang đăng nhập…' : 'Đăng nhập'}
          </Button>
        </form>
        <p className="mt-5 text-center text-body-s text-faint">Tài khoản người dùng thường không đăng nhập được ở đây.</p>
      </Card>
      <p className="absolute bottom-7 text-body-s text-faint">© {YEAR} Thu Chi · Bảng quản trị v1.0</p>
    </div>
  )
}
