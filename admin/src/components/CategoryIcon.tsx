import {
  Baby, Banknote, BookOpen, Briefcase, Building2, Car, CarTaxiFront, Coffee, Coins, Dumbbell, Ellipsis, Film, Fuel, Gamepad2,
  Gift, GraduationCap, HandHeart, HeartPulse, House, Landmark, type LucideIcon, Music, PawPrint, PiggyBank, Pill, Plane, Shirt,
  ShoppingBasket, ShoppingCart, Smartphone, Star, Tag, TrendingUp, Utensils, Wallet, Wifi, Zap,
} from 'lucide-react'
import type { WalletType } from '@/lib/api'
import { cn } from '@/lib/utils'

/** Tên icon dùng chung với app di động (kiểu FontAwesome camelCase) -> icon hiển thị. */
export const CATEGORY_ICONS: Record<string, LucideIcon> = {
  wallet: Wallet, gift: Gift, chartLine: TrendingUp, handHoldingHeart: HandHeart, moneyBill: Banknote, coins: Coins,
  piggyBank: PiggyBank, briefcase: Briefcase, mugHot: Coffee, utensils: Utensils, taxi: CarTaxiFront, car: Car,
  gasPump: Fuel, plane: Plane, basketShopping: ShoppingBasket, cartShopping: ShoppingCart, shirt: Shirt, bolt: Zap,
  wifi: Wifi, mobile: Smartphone, house: House, building: Building2, heartPulse: HeartPulse, pills: Pill,
  dumbbell: Dumbbell, graduationCap: GraduationCap, book: BookOpen, gamepad: Gamepad2, film: Film, music: Music,
  paw: PawPrint, baby: Baby, star: Star, ellipsis: Ellipsis,
}

export const WALLET_ICONS: Record<WalletType, LucideIcon> = { CASH: Banknote, BANK: Landmark, EWALLET: Smartphone }

const BUBBLE_SIZE = {
  xs: 'size-6 text-[10px] [&_svg]:size-[13px]',
  chip: 'size-[22px] bg-card [&_svg]:size-[13px]',
  sm: 'size-8 text-xs [&_svg]:size-4',
  md: 'size-10 text-[13px] [&_svg]:size-[19px]',
  lg: 'size-14 text-lg [&_svg]:size-6',
  xl: 'size-[72px] text-2xl [&_svg]:size-[30px]',
} as const

/** Bong bóng tròn xám chứa icon hoặc chữ viết tắt (màu chỉ dùng cho ý nghĩa, không tô theo danh mục). */
export function Bubble({ size = 'md', tone = 'default', className, children }: {
  size?: keyof typeof BUBBLE_SIZE
  tone?: 'default' | 'ink' | 'danger' | 'success'
  className?: string
  children?: React.ReactNode
}) {
  return (
    <span
      className={cn(
        'inline-flex shrink-0 items-center justify-center rounded-full font-semibold tracking-[-0.01em]',
        { default: 'bg-muted text-ink-soft', ink: 'bg-primary text-primary-foreground', danger: 'bg-destructive-soft text-destructive', success: 'bg-success-soft text-income' }[tone],
        BUBBLE_SIZE[size],
        className,
      )}
    >
      {children}
    </span>
  )
}

export function CategoryIcon({ icon, size = 'sm', className }: { icon: string; size?: keyof typeof BUBBLE_SIZE; className?: string }) {
  const Icon = CATEGORY_ICONS[icon] ?? Tag
  return <Bubble size={size} className={className}><Icon /></Bubble>
}

/** Chip danh mục trong bảng: nền xám, icon trong bong bóng trắng. */
export function CategoryChip({ name, icon }: { name: string; icon: string }) {
  const Icon = CATEGORY_ICONS[icon] ?? Tag
  return (
    <span
      className="inline-flex h-[30px] max-w-full items-center gap-2 rounded-full bg-muted pr-3 pl-1 text-[13px] font-medium whitespace-nowrap text-ink-soft"
      data-testid="category-chip"
    >
      <Bubble size="chip"><Icon /></Bubble>
      <span className="truncate">{name}</span>
    </span>
  )
}

/** Ô màu nhỏ: màu danh mục chỉ để tô biểu đồ. */
export function Swatch({ color, className }: { color: string; className?: string }) {
  return <span className={cn('size-3.5 shrink-0 rounded-[4px] shadow-[inset_0_0_0_1px_rgb(17_17_17/.06)]', className)} style={{ backgroundColor: color }} />
}
