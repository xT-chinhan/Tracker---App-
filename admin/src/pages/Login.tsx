import { useEffect, useState, type FormEvent } from 'react'
import { Navigate, useNavigate, useSearchParams } from 'react-router'
import { AlertCircle, Loader2, Wallet } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { api, auth } from '@/lib/api'

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
    <div className="flex min-h-svh items-center justify-center bg-gradient-to-br from-teal-50 via-background to-slate-100 p-4">
      <div className="w-full max-w-sm">
        <div className="mb-6 flex flex-col items-center gap-3 text-center">
          <div className="flex size-12 items-center justify-center rounded-xl bg-primary text-primary-foreground shadow-lg shadow-primary/20">
            <Wallet className="size-6" />
          </div>
          <div>
            <h1 className="text-xl font-semibold">Thu Chi Admin</h1>
            <p className="text-sm text-muted-foreground">Quản trị nền tảng quản lý tài chính cá nhân</p>
          </div>
        </div>
        <Card className="shadow-xl shadow-slate-200/60">
          <CardHeader>
            <CardTitle>Đăng nhập</CardTitle>
            <CardDescription>Dùng tài khoản quản trị viên để tiếp tục</CardDescription>
          </CardHeader>
          <CardContent>
            <form onSubmit={submit} className="space-y-4">
              {error && (
                <div role="alert" data-testid="login-error" className="flex gap-2 rounded-lg border border-destructive/20 bg-destructive/5 p-3 text-sm text-destructive">
                  <AlertCircle className="mt-0.5 size-4 shrink-0" />
                  <span>{error}</span>
                </div>
              )}
              <div className="space-y-2">
                <Label htmlFor="email">Email</Label>
                <Input id="email" type="email" autoComplete="username" required value={email} onChange={(e) => setEmail(e.target.value)} placeholder="admin@example.com" className="h-10" />
              </div>
              <div className="space-y-2">
                <Label htmlFor="password">Mật khẩu</Label>
                <Input id="password" type="password" autoComplete="current-password" required value={password} onChange={(e) => setPassword(e.target.value)} className="h-10" />
              </div>
              <Button type="submit" className="h-10 w-full" disabled={loading}>
                {loading && <Loader2 className="animate-spin" />} Đăng nhập
              </Button>
            </form>
          </CardContent>
        </Card>
      </div>
    </div>
  )
}
