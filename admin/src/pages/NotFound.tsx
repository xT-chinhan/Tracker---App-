import { useNavigate } from 'react-router'
import { MapPinOff } from 'lucide-react'
import { Card } from '@/components/ui/card'
import { EmptyState } from '@/components/common'

export default function NotFoundPage() {
  const navigate = useNavigate()
  return (
    <Card className="flex flex-1 items-center justify-center">
      <EmptyState icon={<MapPinOff />} title="Không tìm thấy trang" description="Đường dẫn không tồn tại hoặc đã bị đổi." action={{ label: 'Về tổng quan', onClick: () => navigate('/') }} />
    </Card>
  )
}
