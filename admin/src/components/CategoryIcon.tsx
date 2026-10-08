import {
  Baby, Banknote, BookOpen, Briefcase, Building2, Car, CarTaxiFront, Coffee, Coins, Dumbbell, Ellipsis, Film, Fuel, Gamepad2,
  Gift, GraduationCap, HandHeart, HeartPulse, House, type LucideIcon, Music, PawPrint, PiggyBank, Pill, Plane, Shirt,
  ShoppingBasket, ShoppingCart, Smartphone, Star, Tag, TrendingUp, Utensils, Wallet, Wifi, Zap,
} from 'lucide-react'
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

export function CategoryIcon({ icon, color, className }: { icon: string; color: string; className?: string }) {
  const Icon = CATEGORY_ICONS[icon] ?? Tag
  return (
    <span
      className={cn('inline-flex size-8 shrink-0 items-center justify-center rounded-lg', className)}
      style={{ backgroundColor: `${color}1f`, color }}
    >
      <Icon className="size-4" />
    </span>
  )
}

export function CategoryChip({ name, icon, color }: { name: string; icon: string; color: string }) {
  const Icon = CATEGORY_ICONS[icon] ?? Tag
  return (
    <span
      className="inline-flex max-w-full items-center gap-1.5 rounded-full px-2.5 py-0.5 text-xs font-medium"
      style={{ backgroundColor: `${color}1a`, color }}
      data-testid="category-chip"
    >
      <Icon className="size-3.5 shrink-0" />
      <span className="truncate text-foreground/80">{name}</span>
    </span>
  )
}
