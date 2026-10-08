import { Link } from 'react-router'
import { Button } from '@/components/ui/button'

export default function NotFoundPage() {
  return (
    <div className="flex flex-col items-center gap-3 py-24 text-center">
      <p className="text-5xl font-semibold text-muted-foreground/40">404</p>
      <p className="font-medium">Không tìm thấy trang</p>
      <Button asChild variant="outline"><Link to="/">Về tổng quan</Link></Button>
    </div>
  )
}
