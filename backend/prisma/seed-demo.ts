/**
 * Dữ liệu demo: ~40 người dùng Việt Nam với 12 tháng thu chi thật, ví, chuyển tiền, ngân sách, tiết kiệm,
 * định kỳ, mẫu nhập nhanh, thông báo + 3 broadcast. Chạy: npm run db:seed:demo (sau npm run db:seed).
 *
 * Idempotent: chỉ xóa user demo (email @demo.thuchi.vn + demo@thuchi.vn) và broadcast demo (id cố định), rồi tạo lại.
 * Không đụng tới user thật. admin@thuchi.vn được tạo nếu chưa có (không đổi mật khẩu nếu đã có).
 *
 * Mọi bất biến nghiệp vụ được giữ bằng cách MÔ PHỎNG theo thời gian: chuyển tiền / nạp tiết kiệm chỉ xảy ra khi ví đủ
 * tiền tại thời điểm đó, savedAmount = nạp − rút, trạng thái mục tiêu suy ra từ sổ, dấu warnedAt/exceededAt + thông báo
 * ngân sách sinh đúng như checkThresholds khi giao dịch được tạo, giao dịch định kỳ sinh theo occurrence() của backend.
 */
import 'reflect-metadata';
import { randomUUID } from 'node:crypto';
import { Frequency, GoalStatus, NotificationType, PrismaClient, TxType, WalletType } from '@prisma/client';
import * as bcrypt from 'bcryptjs';
import { monthOf, monthRange, shiftMonth } from '../src/common/time';
import { occurrence } from '../src/recurring/recurring.module';

const prisma = new PrismaClient();

export const DEMO_DOMAIN = 'demo.thuchi.vn';
const SHOWCASE_EMAIL = 'demo@thuchi.vn';
const DEMO_ADMIN_EMAIL = 'admin@thuchi.vn';
const DEMO_PASSWORD = 'demo123';
const DEMO_ADMIN_PASSWORD = 'admin123';
/** id cố định của broadcast demo => xóa đúng chúng khi chạy lại */
const BROADCAST_IDS = ['de300000-0000-4000-8000-00000000b001', 'de300000-0000-4000-8000-00000000b002', 'de300000-0000-4000-8000-00000000b003'];

const MIN = 60_000;
const HOUR = 60 * MIN;
const DAY = 24 * HOUR;
const NOW = new Date(Date.now() - 2 * MIN);
const fmt = (v: number) => v.toLocaleString('vi-VN');

// ---------------------------------------------------------------- ngẫu nhiên có hạt giống (tái lập được)
function mulberry32(seed: number) {
  return () => {
    seed |= 0; seed = (seed + 0x6d2b79f5) | 0;
    let t = Math.imul(seed ^ (seed >>> 15), 1 | seed);
    t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}
const hash = (s: string) => [...s].reduce((h, c) => (Math.imul(h, 31) + c.charCodeAt(0)) | 0, 7);
class Rng {
  private r: () => number;
  constructor(seed: string) { this.r = mulberry32(hash(seed)); }
  next() { return this.r(); }
  chance(p: number) { return this.r() < p; }
  int(a: number, b: number) { return a + Math.floor(this.r() * (b - a + 1)); }
  pick<T>(xs: readonly T[]): T { return xs[Math.floor(this.r() * xs.length)]; }
  /** Số tiền trong [a, b] làm tròn theo step (mặc định 1.000đ) */
  money(a: number, b: number, step = 1000) { return Math.max(step, Math.round((a + this.r() * (b - a)) / step) * step); }
}

// ---------------------------------------------------------------- giờ Việt Nam
const vnDay = (d: Date) => new Date(d.getTime() + 7 * HOUR).toISOString().slice(0, 10);
const dayStart = (day: string) => new Date(`${day}T00:00:00+07:00`);
const at = (day: string, h: number, m: number, s = 0) => new Date(dayStart(day).getTime() + ((h * 60 + m) * 60 + s) * 1000);
const addDays = (day: string, n: number) => new Date(Date.parse(`${day}T00:00:00Z`) + n * DAY).toISOString().slice(0, 10);
const weekday = (day: string) => new Date(`${day}T00:00:00Z`).getUTCDay(); // 0 = CN
const dom = (day: string) => Number(day.slice(8, 10));
const daysIn = (month: string) => { const [y, m] = month.split('-').map(Number); return new Date(Date.UTC(y, m, 0)).getUTCDate(); };
const dayOfMonth = (month: string, d: number) => `${month}-${String(Math.min(d, daysIn(month))).padStart(2, '0')}`;
const endOfVnDay = (day: string) => new Date(dayStart(addDays(day, 1)).getTime() - 1);
const TODAY = vnDay(NOW);
const CUR_MONTH = monthOf(NOW);
const HISTORY_START = addDays(TODAY, -364);

// ---------------------------------------------------------------- danh mục
type CatDef = { name: string; type: TxType; icon: string; color: string };
const CUSTOM_CATS: Record<string, CatDef> = {
  family: { name: 'Gia đình', type: 'EXPENSE', icon: 'handHoldingHeart', color: '#DB2777' },
  pet: { name: 'Thú cưng', type: 'EXPENSE', icon: 'paw', color: '#F59E0B' },
  kids: { name: 'Con cái', type: 'EXPENSE', icon: 'baby', color: '#EC4899' },
  sport: { name: 'Thể thao', type: 'EXPENSE', icon: 'dumbbell', color: '#10B981' },
  wedding: { name: 'Hiếu hỉ', type: 'EXPENSE', icon: 'gift', color: '#E11D48' },
  travel: { name: 'Du lịch', type: 'EXPENSE', icon: 'plane', color: '#0EA5E9' },
  stock: { name: 'Nhập hàng', type: 'EXPENSE', icon: 'cartShopping', color: '#7C3AED' },
  freelance: { name: 'Freelance', type: 'INCOME', icon: 'briefcase', color: '#0D9488' },
  shop: { name: 'Bán hàng online', type: 'INCOME', icon: 'coins', color: '#16A34A' },
  interest: { name: 'Lãi tiết kiệm', type: 'INCOME', icon: 'piggyBank', color: '#0891B2' },
};

// ---------------------------------------------------------------- ví
type WKey = 'cash' | 'bank' | 'bank2' | 'ew';
type WalletDef = { key: WKey; name: string; type: WalletType; icon: string; color: string; initial: number; archiveDay?: string };
const BANKS: [string, string][] = [
  ['MB Bank', '#1E3A8A'], ['Techcombank', '#DC2626'], ['Vietcombank', '#15803D'], ['VPBank', '#16A34A'],
  ['ACB', '#1D4ED8'], ['TPBank', '#7C3AED'], ['BIDV', '#0E7490'], ['Sacombank', '#2563EB'],
];
const EWALLETS: [string, string][] = [['MoMo', '#A50064'], ['ZaloPay', '#0068FF'], ['ShopeePay', '#EE4D2D']];

// ---------------------------------------------------------------- kế hoạch người dùng
type Persona = 'office' | 'senior' | 'student' | 'freelancer' | 'family' | 'seller';
interface Profile {
  persona: Persona;
  income: number; // thu nhập chính / tháng
  salaryDay: number;
  rent: number;
  rentDay: number;
  motorbike: boolean;
  coffeeP: number;
  lunchP: number;
  grabP: number;
  dinnerP: number;
  shopeeP: number;
  groceryPerWeek: number;
  entP: number;
  scale: number; // hệ số chi tiêu biến đổi
  sendParents: number; // gửi bố mẹ / tháng
  gym: boolean;
  pet: boolean;
  kids: boolean;
}

type TxEv = {
  k: 'tx'; at: Date; type: TxType; cat: string; amount: number; title: string; note?: string;
  pref: WKey[]; fixed?: boolean; rule?: { id: string; scheduledFor: Date };
};
type TrEv = { k: 'tr'; at: Date; from: WKey; to: WKey; amount: number; note: string };
type DepEv = { k: 'dep'; at: Date; goal: GoalPlan; amount: number; from: WKey[] };
type WdEv = { k: 'wd'; at: Date; goal: GoalPlan; to: WKey };
type ArchEv = { k: 'arch'; at: Date; wallet: WKey };
type Ev = TxEv | TrEv | DepEv | WdEv | ArchEv;

interface GoalPlan {
  id: string; name: string; target: number; icon: string; color: string; startDate: Date; targetDate: Date;
  saved: number; status: GoalStatus;
}
interface RulePlan {
  id: string; title: string; cat: string; type: TxType; amount: number; wallet: WKey; frequency: Frequency; interval: number;
  startDate: Date; endDate: Date | null; anchorDay: number; note?: string; pausedAt?: Date;
  // kết quả
  nextRunAt?: Date; lastRunAt?: Date | null; isActive?: boolean; skipped?: Date; createdAt?: Date;
}
interface UserPlan {
  id: string; email: string; name: string; role: 'USER' | 'ADMIN'; status: 'ACTIVE' | 'LOCKED'; createdAt: Date;
  rng: Rng; profile: Profile; wallets: WalletDef[]; customCats: string[]; goals: GoalPlan[]; rules: RulePlan[];
  events: Ev[]; showcase?: boolean;
  templates: { label: string; title: string; amount: number; cat: string; wallet: WKey; note?: string }[];
  budgetMonths: number; // số tháng gần nhất có ngân sách (0 = không)
}

// ---------------------------------------------------------------- danh sách người dùng
const PEOPLE: [string, string, Persona][] = [
  ['Trần Quốc Bảo', 'bao.tran', 'senior'],
  ['Lê Thu Hà', 'thuha.le', 'office'],
  ['Phạm Đức Anh', 'ducanh.pham', 'senior'],
  ['Hoàng Ngọc Anh', 'ngocanh.hoang', 'office'],
  ['Vũ Hoàng Long', 'long.vu', 'freelancer'],
  ['Đặng Thảo Vy', 'thaovy.dang', 'student'],
  ['Bùi Thanh Tùng', 'tung.bui', 'family'],
  ['Đỗ Phương Linh', 'phuonglinh.do', 'office'],
  ['Ngô Gia Huy', 'giahuy.ngo', 'student'],
  ['Dương Mai Anh', 'maianh.duong', 'seller'],
  ['Huỳnh Tuấn Kiệt', 'kiet.huynh', 'office'],
  ['Phan Khánh Linh', 'khanhlinh.phan', 'office'],
  ['Võ Hữu Phước', 'phuoc.vo', 'family'],
  ['Hồ Thanh Hương', 'huong.ho', 'senior'],
  ['Lý Đình Khoa', 'khoa.ly', 'student'],
  ['Nguyễn Bích Ngọc', 'bichngoc.nguyen', 'office'],
  ['Trần Nhật Nam', 'nam.tran', 'freelancer'],
  ['Lê Hồng Nhung', 'nhung.le', 'family'],
  ['Phạm Trọng Nghĩa', 'nghia.pham', 'office'],
  ['Hoàng Diệu Linh', 'dieulinh.hoang', 'seller'],
  ['Vũ Công Danh', 'danh.vu', 'senior'],
  ['Đặng Quỳnh Như', 'quynhnhu.dang', 'student'],
  ['Bùi Anh Khoa', 'anhkhoa.bui', 'office'],
  ['Đỗ Minh Thư', 'minhthu.do', 'office'],
  ['Ngô Thành Đạt', 'dat.ngo', 'family'],
  ['Dương Kim Ngân', 'kimngan.duong', 'office'],
  ['Huỳnh Bảo Long', 'baolong.huynh', 'freelancer'],
  ['Phan Hải Yến', 'haiyen.phan', 'office'],
  ['Võ Hải Đăng', 'haidang.vo', 'student'],
  ['Hồ Thùy Dương', 'thuyduong.ho', 'senior'],
  ['Lý Quang Vinh', 'vinh.ly', 'office'],
  ['Nguyễn Lan Chi', 'lanchi.nguyen', 'office'],
  ['Trần Minh Triết', 'triet.tran', 'student'],
  ['Lê Bảo Trân', 'baotran.le', 'seller'],
  ['Phạm Ngọc Hân', 'ngochan.pham', 'office'],
  ['Hoàng Tú Anh', 'tuanh.hoang', 'family'],
  ['Vũ Văn Hùng', 'hung.vu', 'office'],
  ['Đặng Minh Quân', 'quan.dang', 'senior'],
  ['Nguyễn Thị Hoa', 'hoa.nguyen', 'office'],
];

function makeProfile(r: Rng, persona: Persona): Profile {
  const base: Profile = {
    persona, income: 15_000_000, salaryDay: r.pick([1, 5, 5, 10, 10, 15, 25, 28]), rent: 0, rentDay: r.int(1, 5),
    motorbike: r.chance(0.6), coffeeP: r.next() * 0.6 + 0.2, lunchP: 0.85, grabP: r.next() * 0.35 + 0.05, dinnerP: 0.15 + r.next() * 0.2,
    shopeeP: 0.05 + r.next() * 0.1, groceryPerWeek: r.int(1, 2), entP: 0.25 + r.next() * 0.3, scale: 1, sendParents: 0,
    gym: r.chance(0.3), pet: r.chance(0.15), kids: false,
  };
  switch (persona) {
    case 'office': Object.assign(base, { income: r.money(11_000_000, 25_000_000, 500_000), rent: r.chance(0.6) ? r.money(2_500_000, 5_500_000, 500_000) : 0, sendParents: r.chance(0.4) ? r.money(1_000_000, 3_000_000, 500_000) : 0 }); break;
    case 'senior': Object.assign(base, { income: r.money(30_000_000, 55_000_000, 1_000_000), rent: r.chance(0.5) ? r.money(6_000_000, 12_000_000, 500_000) : 0, dinnerP: 0.3, sendParents: r.chance(0.6) ? r.money(3_000_000, 6_000_000, 500_000) : 0 }); break;
    case 'student': Object.assign(base, { income: r.money(4_500_000, 6_500_000, 500_000), salaryDay: r.int(1, 3), rent: r.money(1_500_000, 2_500_000, 100_000), coffeeP: 0.25, lunchP: 0.7, dinnerP: 0.08, grabP: 0.1, gym: false, groceryPerWeek: 1 }); break;
    case 'freelancer': Object.assign(base, { income: r.money(15_000_000, 30_000_000, 1_000_000), rent: r.chance(0.5) ? r.money(3_000_000, 6_000_000, 500_000) : 0, lunchP: 0.6, coffeeP: 0.7 }); break;
    case 'family': Object.assign(base, { income: r.money(28_000_000, 45_000_000, 1_000_000), kids: true, rent: r.chance(0.4) ? r.money(5_000_000, 8_000_000, 500_000) : 0, groceryPerWeek: 3, dinnerP: 0.1, grabP: 0.08, motorbike: true }); break;
    case 'seller': Object.assign(base, { income: r.money(11_000_000, 15_000_000, 1_000_000), rent: r.chance(0.5) ? r.money(3_000_000, 5_000_000, 500_000) : 0, shopeeP: 0.2, lunchP: 0.6 }); break;
  }
  // Chi biến đổi ~55% phần còn lại sau tiền nhà/hóa đơn => đa số user để dành được 15–35%
  const free = base.income * (persona === 'senior' ? 0.7 : 0.62) - base.rent - base.sendParents - 1_500_000;
  base.scale = Math.min(3.5, Math.max(0.3, free / 8_500_000));
  return base;
}

function makeWallets(r: Rng, p: Profile, n: number): WalletDef[] {
  const [bankName, bankColor] = r.pick(BANKS);
  const ws: WalletDef[] = [{ key: 'cash', name: 'Tiền mặt', type: 'CASH', icon: 'moneyBill', color: '#16A34A', initial: r.money(300_000, 2_500_000, 50_000) }];
  if (n >= 2) ws.push({ key: 'bank', name: bankName, type: 'BANK', icon: 'building', color: bankColor, initial: r.money(p.income * 0.3, p.income * 1.5, 100_000) });
  if (n >= 3) {
    const [ewName, ewColor] = r.pick(EWALLETS);
    ws.push({ key: 'ew', name: ewName, type: 'EWALLET', icon: 'mobile', color: ewColor, initial: r.money(0, 500_000, 10_000) });
  }
  if (n >= 4) {
    const [b2, c2] = r.pick(BANKS.filter(([b]) => b !== bankName));
    ws.push({ key: 'bank2', name: b2, type: 'BANK', icon: 'building', color: c2, initial: r.money(1_000_000, 10_000_000, 100_000) });
  }
  return ws;
}

// ---------------------------------------------------------------- sinh sự kiện
const COFFEE: [string, number, number][] = [
  ['Cà phê sáng', 25_000, 45_000], ['Highlands Coffee', 49_000, 69_000], ['Phúc Long', 45_000, 65_000], ['Cộng Cà Phê', 45_000, 59_000],
  ['Cà phê muối', 25_000, 35_000], ['The Coffee House', 45_000, 65_000], ['Katinat', 49_000, 65_000],
];
const BREAKFAST: [string, number, number][] = [['Bánh mì', 20_000, 35_000], ['Phở bò', 45_000, 65_000], ['Bún bò Huế', 40_000, 55_000], ['Xôi gà', 25_000, 35_000], ['Hủ tiếu', 35_000, 50_000]];
const LUNCH: [string, number, number][] = [
  ['Cơm trưa văn phòng', 40_000, 60_000], ['Cơm tấm sườn', 40_000, 60_000], ['Bún chả', 45_000, 65_000], ['Cơm gà Hải Nam', 50_000, 70_000],
  ['Mì Quảng', 40_000, 55_000], ['Bún riêu', 35_000, 50_000], ['Cơm văn phòng (đặt GrabFood)', 55_000, 85_000],
];
const DINNER: [string, number, number][] = [
  ['Lẩu Thái với bạn', 250_000, 600_000], ['Nướng Gogi', 300_000, 700_000], ['Ăn tối gia đình', 200_000, 500_000], ['Bún đậu mắm tôm', 120_000, 250_000],
  ["Pizza 4P's", 350_000, 900_000], ['Ốc với đồng nghiệp', 180_000, 400_000], ['Sushi Hokkaido', 400_000, 950_000],
];
const GROCERY = ['Siêu thị WinMart', 'Đi chợ', 'Bách Hóa Xanh', 'Co.opmart', 'Đi chợ cuối tuần', 'Lotte Mart', 'Mua rau củ, thịt cá'];
const SHOPEE: [string, number, number][] = [
  ['Shopee: áo thun', 129_000, 299_000], ['Shopee: ốp lưng điện thoại', 59_000, 149_000], ['Lazada: tai nghe Bluetooth', 290_000, 890_000],
  ['Tiki: sách', 89_000, 320_000], ['Shopee: đồ gia dụng', 99_000, 450_000], ['TikTok Shop: mỹ phẩm', 150_000, 560_000],
  ['Shopee: giày sneaker', 350_000, 890_000], ['Shopee: đồ ăn vặt', 80_000, 220_000], ['Uniqlo: quần jean', 499_000, 799_000],
];
const ENT: [string, number, number][] = [
  ['Xem phim CGV', 90_000, 240_000], ['Karaoke với bạn', 200_000, 500_000], ['Bida', 60_000, 150_000], ['Cà phê cuối tuần', 60_000, 150_000],
  ['Bowling', 150_000, 300_000], ['Vé xem bóng đá', 150_000, 400_000], ['Board game café', 80_000, 160_000],
];
const NOTES_FOOD = ['Với đồng nghiệp', 'Trả bằng QR', 'Khuyến mãi 20%', 'Đi cùng Lan', 'Mời khách', 'Có voucher'];

function addEvent(u: UserPlan, e: Ev) {
  if (e.at > NOW) return;
  u.events.push(e);
}

/** Sinh các khoản thu chi hằng ngày / hằng tháng theo persona. */
function generateDaily(u: UserPlan, skipFixed: Set<string>) {
  const { rng: r, profile: p } = u;
  const has = (k: WKey) => u.wallets.some((w) => w.key === k);
  const tx = (day: string, h: number, m: number, type: TxType, cat: string, amount: number, title: string, pref: WKey[], note?: string) =>
    addEvent(u, { k: 'tx', at: at(day, h, m, r.int(0, 59)), type, cat, amount, title, pref, note });
  const s = (v: number, step = 1000) => Math.max(step, Math.round((v * p.scale) / step) * step);
  const bigDays = new Set<string>();
  const nBig = u.showcase ? 0 : r.int(1, 3);
  for (let i = 0; i < nBig; i++) bigDays.add(addDays(HISTORY_START, r.int(20, 340)));
  const tripMonth = shiftMonth(CUR_MONTH, -r.int(1, 10));

  for (let day = HISTORY_START; day <= TODAY; day = addDays(day, 1)) {
    const wd = weekday(day);
    const weekend = wd === 0 || wd === 6;
    const d = dom(day);
    const month = day.slice(0, 7);

    // ---------- hằng tháng
    if (d === p.salaryDay && !skipFixed.has('salary')) {
      if (p.persona === 'student') {
        tx(day, 10, r.int(0, 50), 'INCOME', 'Được tặng', p.income, 'Bố mẹ gửi tiền tháng', ['bank', 'cash']);
      } else if (p.persona === 'freelancer') {
        // freelancer: thu nhập không đều, vài dự án / tháng
      } else if (p.persona === 'seller') {
        // seller: thu theo đơn hàng
      } else {
        tx(day, 9, r.int(0, 40), 'INCOME', 'Lương', p.income, `Lương tháng ${Number(month.slice(5))}`, ['bank']);
      }
    }
    if (p.persona === 'student' && d === 12) tx(day, 18, r.int(0, 59), 'INCOME', 'Lương', r.money(2_500_000, 4_000_000, 100_000), 'Lương làm thêm quán cà phê', ['bank', 'cash']);
    if (p.persona === 'freelancer' && r.chance(4 / 30)) {
      const [title, a, b] = r.pick([['Dự án thiết kế logo', 3_000_000, 8_000_000], ['Viết content website', 2_000_000, 5_000_000], ['Dựng video quảng cáo', 5_000_000, 15_000_000], ['Thiết kế landing page', 6_000_000, 12_000_000], ['Chụp ảnh sản phẩm', 2_500_000, 6_000_000]] as const);
      tx(day, r.int(10, 17), r.int(0, 59), 'INCOME', 'Freelance', r.money(a, b, 100_000), title, ['bank2', 'bank'], r.chance(0.3) ? 'Khách thanh toán đợt 1' : undefined);
    }
    if (p.persona === 'seller') {
      if (r.chance(0.7)) tx(day, r.int(9, 21), r.int(0, 59), 'INCOME', 'Bán hàng online', r.money(150_000, 2_200_000, 1000), r.pick(['Đơn hàng Shopee', 'Đơn TikTok Shop', 'Khách chuyển khoản', 'Đơn hàng Facebook']), ['bank', 'ew']);
      if (wd === 2) tx(day, 14, r.int(0, 59), 'EXPENSE', 'Nhập hàng', r.money(1_500_000, 3_800_000, 100_000), r.pick(['Nhập hàng chợ Tân Bình', 'Nhập hàng Quảng Châu', 'Nhập bao bì, hộp']), ['bank']);
    }
    if (d === p.rentDay && p.rent && !skipFixed.has('rent')) tx(day, 8, r.int(0, 30), 'EXPENSE', 'Nhà ở', p.rent, 'Tiền thuê nhà', ['bank'], 'Chuyển khoản cho chủ nhà');
    if (d === 9) {
      const summer = ['05', '06', '07', '08'].includes(month.slice(5));
      tx(day, 20, r.int(0, 59), 'EXPENSE', 'Hóa đơn', r.money(summer ? 550_000 : 300_000, summer ? 1_200_000 : 650_000, 1000), 'Tiền điện EVN', ['bank', 'ew']);
      tx(day, 20, r.int(0, 59), 'EXPENSE', 'Hóa đơn', r.money(70_000, 180_000, 1000), 'Tiền nước', ['bank', 'ew']);
    }
    if (d === 15 && !skipFixed.has('internet')) tx(day, 19, r.int(0, 59), 'EXPENSE', 'Hóa đơn', r.pick([180_000, 220_000, 245_000, 280_000]), r.pick(['Internet FPT', 'Internet Viettel', 'Internet VNPT']), ['bank', 'ew']);
    if (d === 20) tx(day, 21, r.int(0, 59), 'EXPENSE', 'Hóa đơn', r.pick([90_000, 120_000, 150_000, 200_000]), r.pick(['Cước Viettel', 'Nạp tiền điện thoại', 'Cước Vinaphone']), ['ew', 'bank']);
    if (p.sendParents && d === Math.min(p.salaryDay + 1, 28)) tx(day, 19, r.int(0, 59), 'EXPENSE', 'Gia đình', p.sendParents, 'Gửi tiền bố mẹ', ['bank'], 'Chuyển khoản về quê');
    if (p.gym && d === 3 && !skipFixed.has('gym')) tx(day, 18, r.int(0, 59), 'EXPENSE', 'Thể thao', r.pick([450_000, 500_000, 600_000]), 'Phí tập gym tháng', ['bank', 'ew']);
    if (p.kids) {
      if (d === 5) tx(day, 8, r.int(0, 59), 'EXPENSE', 'Con cái', r.pick([3_500_000, 4_000_000, 4_500_000]), 'Học phí mầm non', ['bank']);
      if (wd === 6) tx(day, 10, r.int(0, 59), 'EXPENSE', 'Con cái', r.money(350_000, 750_000, 1000), r.pick(['Sữa cho bé', 'Bỉm + sữa', 'Đồ chơi cho bé', 'Quần áo cho bé']), ['bank', 'cash']);
    }
    if (p.pet && wd === 0 && r.chance(0.5)) tx(day, 16, r.int(0, 59), 'EXPENSE', 'Thú cưng', r.money(150_000, 450_000, 1000), r.pick(['Pate cho mèo', 'Hạt cho chó', 'Cát vệ sinh', 'Tắm spa cho bé cún']), ['ew', 'cash']);
    if (d === 27 && r.chance(0.35)) tx(day, 10, r.int(0, 59), 'INCOME', 'Lãi tiết kiệm', r.money(150_000, 900_000, 1000), 'Lãi tiền gửi', ['bank']);
    if (d === 14 && r.chance(0.5)) tx(day, 18, r.int(0, 59), 'EXPENSE', 'Chi khác', r.pick([60_000, 80_000, 100_000, 120_000, 150_000]), 'Cắt tóc', ['cash']);

    // ---------- Tết (2026: mùng 1 = 17/02)
    if (day === '2026-02-10' && ['office', 'senior', 'family'].includes(p.persona)) tx(day, 15, r.int(0, 59), 'INCOME', 'Thưởng', Math.round(p.income * (0.8 + r.next() * 0.8) / 100_000) * 100_000, 'Thưởng Tết', ['bank'], 'Thưởng tháng 13');
    if (day === '2026-02-13') tx(day, 9, r.int(0, 59), 'EXPENSE', 'Di chuyển', r.money(350_000, 1_400_000, 10_000), 'Vé xe về quê ăn Tết', ['bank', 'ew']);
    if (day === '2026-02-14') tx(day, 16, r.int(0, 59), 'EXPENSE', 'Mua sắm', s(r.money(1_000_000, 3_000_000, 50_000), 50_000), 'Mua sắm Tết', ['bank', 'cash']);
    if (day === '2026-02-17') tx(day, 8, r.int(0, 59), 'EXPENSE', 'Chi khác', s(r.money(1_000_000, 4_000_000, 100_000), 100_000), 'Lì xì Tết', ['cash'], 'Mùng 1');
    if (day === '2026-02-18' && p.persona === 'student') tx(day, 9, r.int(0, 59), 'INCOME', 'Được tặng', r.money(1_000_000, 3_000_000, 100_000), 'Tiền lì xì', ['cash']);

    // ---------- mua lớn, du lịch, hiếu hỉ
    if (bigDays.has(day)) {
      const [title, cat, a, b] = r.pick([
        ['iPhone 16', 'Mua sắm', 18_000_000, 24_000_000], ['Laptop mới', 'Mua sắm', 15_000_000, 28_000_000], ['Tủ lạnh Samsung', 'Mua sắm', 8_000_000, 14_000_000],
        ['Sửa xe máy', 'Di chuyển', 800_000, 2_500_000], ['Máy lọc không khí', 'Mua sắm', 3_000_000, 6_000_000], ['Khám sức khỏe tổng quát', 'Sức khỏe', 1_500_000, 3_500_000],
        ['Khóa học tiếng Anh', 'Giáo dục', 4_000_000, 9_000_000], ['Đồng hồ Casio', 'Mua sắm', 2_000_000, 4_500_000],
      ] as const);
      const amount = r.money(a * Math.min(1, p.scale + 0.3), b * Math.min(1, p.scale + 0.3), 100_000);
      tx(day, r.int(10, 20), r.int(0, 59), 'EXPENSE', cat, amount, title, ['bank', 'bank2'], r.chance(0.5) ? 'Trả 1 lần, không trả góp' : undefined);
    }
    if (month === tripMonth && d === 12 && p.persona !== 'student') {
      const place = r.pick(['Đà Nẵng', 'Phú Quốc', 'Đà Lạt', 'Nha Trang', 'Sa Pa', 'Hạ Long']);
      tx(day, 21, r.int(0, 59), 'EXPENSE', 'Du lịch', s(r.money(1_800_000, 4_500_000, 10_000), 10_000), `Vé máy bay ${place}`, ['bank', 'bank2']);
      tx(addDays(day, 8), 14, r.int(0, 59), 'EXPENSE', 'Du lịch', s(r.money(1_500_000, 5_000_000, 50_000), 50_000), `Khách sạn ${place}`, ['bank', 'bank2']);
      tx(addDays(day, 9), 19, r.int(0, 59), 'EXPENSE', 'Ăn uống', s(r.money(500_000, 1_500_000, 10_000), 10_000), `Hải sản ${place}`, ['bank', 'cash']);
    }
    if (r.chance(1 / 75) && p.persona !== 'student' && p.persona !== 'seller') tx(day, 11, r.int(0, 59), 'EXPENSE', 'Hiếu hỉ', r.pick([500_000, 1_000_000, 1_000_000, 2_000_000]), r.pick(['Đám cưới bạn thân', 'Mừng cưới đồng nghiệp', 'Viếng đám tang', 'Mừng thôi nôi cháu']), ['cash', 'bank']);
    if (r.chance(1 / 45)) tx(day, r.int(9, 20), r.int(0, 59), 'EXPENSE', 'Sức khỏe', r.money(80_000, 900_000, 1000), r.pick(['Nhà thuốc Long Châu', 'Khám răng', 'Thuốc cảm', 'Vitamin tổng hợp', 'Khám mắt']), ['cash', 'ew']);
    if (p.persona !== 'student' && r.chance(1 / 90)) tx(day, 15, r.int(0, 59), 'INCOME', 'Thưởng', r.money(1_000_000, 6_000_000, 500_000), r.pick(['Thưởng KPI quý', 'Thưởng dự án', 'Thưởng doanh số']), ['bank']);
    if (r.chance(1 / 120)) tx(day, 12, r.int(0, 59), 'INCOME', 'Được tặng', r.money(500_000, 2_000_000, 100_000), r.pick(['Quà sinh nhật', 'Mẹ cho', 'Bạn trả tiền mượn']), ['cash', 'ew']);
    if (r.chance(1 / 60)) tx(day, r.int(10, 18), r.int(0, 59), 'INCOME', 'Thu khác', r.money(200_000, 1_500_000, 10_000), r.pick(['Bán đồ cũ', 'Hoàn tiền Shopee', 'Hoàn tiền bảo hiểm', 'Cashback thẻ']), ['bank', 'ew']);

    // ---------- hằng ngày
    const coffeeP = weekend ? p.coffeeP * 0.5 : p.coffeeP;
    if (r.chance(coffeeP)) { const [t, a, b] = r.pick(COFFEE); tx(day, r.int(7, 9), r.int(0, 59), 'EXPENSE', 'Ăn uống', r.money(a, b), t, ['ew', 'cash']); }
    if (r.chance(0.3)) { const [t, a, b] = r.pick(BREAKFAST); tx(day, r.int(6, 7), r.int(15, 59), 'EXPENSE', 'Ăn uống', r.money(a, b), t, ['cash']); }
    if (!weekend && r.chance(p.lunchP)) { const [t, a, b] = r.pick(LUNCH); tx(day, r.int(11, 12), r.int(15, 50), 'EXPENSE', 'Ăn uống', r.money(a, b), t, ['cash', 'ew'], r.chance(0.08) ? r.pick(NOTES_FOOD) : undefined); }
    if (r.chance(0.1)) tx(day, r.int(14, 16), r.int(0, 59), 'EXPENSE', 'Ăn uống', r.money(35_000, 65_000), r.pick(['Trà sữa Gong Cha', 'Trà sữa TocoToco', 'Trà chanh', 'Sinh tố']), ['ew', 'cash']);
    if (!weekend && r.chance(p.grabP)) tx(day, r.int(7, 8), r.int(0, 59), 'EXPENSE', 'Di chuyển', r.money(25_000, 75_000), r.pick(['Grab đi làm', 'Be đi làm', 'Xanh SM đi làm']), ['ew']);
    if (!weekend && r.chance(p.grabP * 0.8)) tx(day, r.int(17, 19), r.int(0, 59), 'EXPENSE', 'Di chuyển', r.money(28_000, 90_000), r.pick(['Grab về nhà', 'Be về nhà', 'Xanh SM về nhà']), ['ew']);
    if (p.motorbike && wd === r.int(0, 6) && r.chance(0.9)) tx(day, r.int(7, 18), r.int(0, 59), 'EXPENSE', 'Di chuyển', r.money(60_000, 110_000), 'Đổ xăng', ['cash', 'ew']);
    if (p.motorbike && d === 2) tx(day, 7, r.int(30, 59), 'EXPENSE', 'Di chuyển', r.pick([100_000, 120_000, 150_000]), 'Gửi xe tháng', ['cash']);
    if (r.chance((weekend ? 2.2 : 1) * p.dinnerP)) { const [t, a, b] = r.pick(DINNER); tx(day, r.int(18, 20), r.int(0, 59), 'EXPENSE', 'Ăn uống', s(r.money(a, b), 10_000), t, ['bank', 'ew', 'cash'], r.chance(0.2) ? r.pick(NOTES_FOOD) : undefined); }
    if (r.chance(p.groceryPerWeek / 7)) tx(day, r.int(17, 19), r.int(0, 59), 'EXPENSE', 'Ăn uống', s(r.money(180_000, 750_000), 1000), r.pick(GROCERY), ['cash', 'bank']);
    if (r.chance(p.shopeeP)) { const [t, a, b] = r.pick(SHOPEE); tx(day, r.int(20, 23), r.int(0, 59), 'EXPENSE', 'Mua sắm', r.money(a, b), t, ['ew', 'bank']); }
    if (weekend && r.chance(p.entP)) { const [t, a, b] = r.pick(ENT); tx(day, r.int(15, 21), r.int(0, 59), 'EXPENSE', 'Giải trí', s(r.money(a, b), 1000), t, ['ew', 'cash', 'bank']); }

    // ---------- chuyển tiền định kỳ
    if (d === Math.min(p.salaryDay + 1, 28) && has('bank')) {
      addEvent(u, { k: 'tr', at: at(day, 12, r.int(0, 59)), from: 'bank', to: 'cash', amount: r.money(1_000_000, 3_000_000, 500_000), note: 'Rút tiền mặt ATM' });
      if (has('ew')) addEvent(u, { k: 'tr', at: at(day, 21, r.int(0, 59)), from: 'bank', to: 'ew', amount: r.money(300_000, 1_500_000, 100_000), note: `Nạp ví ${u.wallets.find((w) => w.key === 'ew')!.name}` });
    }
    if (has('bank2') && d === 20 && r.chance(0.5)) addEvent(u, { k: 'tr', at: at(day, 10, r.int(0, 59)), from: 'bank', to: 'bank2', amount: r.money(2_000_000, 8_000_000, 1_000_000), note: 'Chuyển sang tài khoản phụ' });
  }
}

// ---------------------------------------------------------------- mục tiêu + định kỳ
const GOAL_POOL: { name: string; icon: string; color: string; target: [number, number] }[] = [
  { name: 'Quỹ khẩn cấp', icon: 'piggyBank', color: '#0EA5E9', target: [20_000_000, 60_000_000] },
  { name: 'Du lịch Nhật Bản', icon: 'plane', color: '#F43F5E', target: [30_000_000, 50_000_000] },
  { name: 'Mua xe máy', icon: 'car', color: '#F97316', target: [25_000_000, 45_000_000] },
  { name: 'Laptop mới', icon: 'mobile', color: '#6366F1', target: [15_000_000, 30_000_000] },
  { name: 'Đám cưới', icon: 'gift', color: '#EC4899', target: [50_000_000, 120_000_000] },
  { name: 'Học thạc sĩ', icon: 'graduationCap', color: '#3B82F6', target: [40_000_000, 80_000_000] },
  { name: 'Du lịch Đà Lạt', icon: 'plane', color: '#22C55E', target: [5_000_000, 9_000_000] },
  { name: 'Mua iPad', icon: 'mobile', color: '#A855F7', target: [10_000_000, 18_000_000] },
  { name: 'Quà sinh nhật mẹ', icon: 'gift', color: '#DB2777', target: [3_000_000, 6_000_000] },
];

function planGoals(u: UserPlan) {
  const { rng: r, profile: p } = u;
  if (!u.wallets.some((w) => w.key === 'bank')) return;
  const n = p.persona === 'student' ? r.int(0, 1) : r.int(1, 3);
  const pool = [...GOAL_POOL].sort(() => r.next() - 0.5);
  for (let i = 0; i < n; i++) {
    const g = pool[i];
    // ý định: đủ 4 trạng thái trên toàn bộ dữ liệu
    const intent = r.pick(['ACTIVE', 'ACTIVE', 'ACTIVE', 'COMPLETED', 'WITHDRAWN', 'EARLY_WITHDRAWN'] as const);
    const startDay = addDays(HISTORY_START, r.int(5, intent === 'ACTIVE' ? 250 : 150));
    const target = Math.round(r.money(g.target[0], g.target[1], 1_000_000) * Math.min(1.2, Math.max(0.3, p.income / 25_000_000)) / 500_000) * 500_000;
    const monthsToFill = intent === 'ACTIVE' ? r.int(10, 20) : r.int(3, 6);
    const monthly = Math.max(500_000, Math.ceil(target / monthsToFill / 100_000) * 100_000);
    const goal: GoalPlan = {
      id: randomUUID(), name: g.name, target, icon: g.icon, color: g.color, startDate: at(startDay, 9, 0),
      targetDate: intent === 'ACTIVE' ? at(addDays(TODAY, r.int(60, 400)), 0, 0) : at(addDays(startDay, monthsToFill * 31 + 10), 0, 0),
      saved: 0, status: 'ACTIVE',
    };
    u.goals.push(goal);
    const depDay = Math.min(p.salaryDay + 2, 28);
    let lastDep = startDay;
    for (let m = startDay.slice(0, 7); m <= CUR_MONTH; m = shiftMonth(m, 1)) {
      const day = dayOfMonth(m, depDay);
      if (day < startDay) continue;
      addEvent(u, { k: 'dep', at: at(day, 20, r.int(0, 59)), goal, amount: monthly, from: ['bank', 'bank2'] });
      lastDep = day;
    }
    if (intent === 'WITHDRAWN' || intent === 'EARLY_WITHDRAWN') {
      const wdDay = intent === 'WITHDRAWN' ? addDays(startDay, monthsToFill * 31 + r.int(20, 60)) : addDays(startDay, r.int(50, 80));
      if (wdDay < TODAY) addEvent(u, { k: 'wd', at: at(wdDay, 19, r.int(0, 59)), goal, to: 'bank' });
    }
    void lastDep;
  }
}

const SUBS: { title: string; amount: number; cat: string }[] = [
  { title: 'Netflix Premium', amount: 260_000, cat: 'Giải trí' }, { title: 'Spotify Premium', amount: 59_000, cat: 'Giải trí' },
  { title: 'YouTube Premium', amount: 79_000, cat: 'Giải trí' }, { title: 'iCloud 200GB', amount: 45_000, cat: 'Hóa đơn' },
  { title: 'Google One 100GB', amount: 45_000, cat: 'Hóa đơn' },
];

function rule(u: UserPlan, def: Omit<RulePlan, 'id' | 'anchorDay'>): RulePlan {
  const r: RulePlan = { ...def, id: randomUUID(), anchorDay: Number(vnDay(def.startDate).slice(8, 10)) };
  u.rules.push(r);
  return r;
}

function planRules(u: UserPlan, skip: Set<string>) {
  const { rng: r, profile: p } = u;
  const has = (k: WKey) => u.wallets.some((w) => w.key === k);
  const bankish: WKey = has('bank') ? 'bank' : 'cash';
  const startIn = (minDays: number, maxDays: number) => addDays(HISTORY_START, r.int(minDays, maxDays));
  if (['office', 'senior', 'family'].includes(p.persona) && has('bank') && r.chance(0.5)) {
    skip.add('salary');
    rule(u, { title: 'Lương công ty', cat: 'Lương', type: 'INCOME', amount: p.income, wallet: 'bank', frequency: 'MONTHLY', interval: 1, startDate: at(dayOfMonth(HISTORY_START.slice(0, 7), p.salaryDay) < HISTORY_START ? dayOfMonth(shiftMonth(HISTORY_START.slice(0, 7), 1), p.salaryDay) : dayOfMonth(HISTORY_START.slice(0, 7), p.salaryDay), 9, 0), endDate: null });
  }
  if (p.rent && r.chance(0.6)) {
    skip.add('rent');
    const m = shiftMonth(HISTORY_START.slice(0, 7), r.int(1, 4));
    rule(u, { title: 'Tiền nhà', cat: 'Nhà ở', type: 'EXPENSE', amount: p.rent, wallet: bankish, frequency: 'MONTHLY', interval: 1, startDate: at(dayOfMonth(m, p.rentDay), 8, 0), endDate: null, note: 'Chuyển khoản cho chủ nhà' });
  }
  if (r.chance(0.5)) {
    skip.add('internet');
    const m = shiftMonth(HISTORY_START.slice(0, 7), r.int(1, 6));
    rule(u, { title: r.pick(['Internet FPT', 'Internet Viettel']), cat: 'Hóa đơn', type: 'EXPENSE', amount: r.pick([220_000, 245_000, 280_000]), wallet: bankish, frequency: 'MONTHLY', interval: 1, startDate: at(dayOfMonth(m, 15), 20, 0), endDate: null });
  }
  const subs = [...SUBS].sort(() => r.next() - 0.5).slice(0, r.int(0, 2));
  for (const sub of subs) {
    const wallet: WKey = has('ew') ? 'ew' : bankish;
    const ruleDef = rule(u, { title: sub.title, cat: sub.cat, type: 'EXPENSE', amount: sub.amount, wallet, frequency: 'MONTHLY', interval: 1, startDate: at(startIn(10, 200), 7, 0), endDate: null });
    if (r.chance(0.25)) ruleDef.pausedAt = at(addDays(TODAY, -r.int(10, 60)), 21, 0); // user tự tạm dừng
  }
  if (p.gym && r.chance(0.6)) {
    skip.add('gym');
    rule(u, { title: 'Phí tập gym', cat: 'Thể thao', type: 'EXPENSE', amount: 500_000, wallet: bankish, frequency: 'MONTHLY', interval: 1, startDate: at(dayOfMonth(shiftMonth(HISTORY_START.slice(0, 7), r.int(1, 5)), 3), 18, 0), endDate: null });
  }
  if (p.persona === 'student' && r.chance(0.6)) {
    // khóa học đã kết thúc => quy tắc hết hạn
    const start = startIn(30, 120);
    rule(u, { title: 'Học phí khóa IELTS', cat: 'Giáo dục', type: 'EXPENSE', amount: 1_500_000, wallet: has('bank') ? 'bank' : 'cash', frequency: 'MONTHLY', interval: 1, startDate: at(start, 18, 0), endDate: endOfVnDay(addDays(start, 120)) });
  }
  if (p.persona === 'family' && r.chance(0.7)) {
    rule(u, { title: 'Đi chợ cuối tuần', cat: 'Ăn uống', type: 'EXPENSE', amount: 600_000, wallet: 'cash', frequency: 'WEEKLY', interval: 1, startDate: at(nextWeekday(startIn(20, 100), 0), 8, 0), endDate: null });
    rule(u, { title: 'Bảo hiểm nhân thọ', cat: 'Sức khỏe', type: 'EXPENSE', amount: 12_000_000, wallet: bankish, frequency: 'YEARLY', interval: 1, startDate: at(startIn(15, 200), 10, 0), endDate: null });
  }
}
const nextWeekday = (day: string, wd: number) => { let d = day; while (weekday(d) !== wd) d = addDays(d, 1); return d; };

/** Sinh giao dịch của quy tắc định kỳ theo occurrence() của backend; tính nextRunAt / isActive / kỳ bị bỏ qua. */
function expandRules(u: UserPlan) {
  for (const rl of u.rules) {
    const wallet = u.wallets.find((w) => w.key === rl.wallet)!;
    const archivedAt = wallet.archiveDay ? at(wallet.archiveDay, 12, 0) : undefined;
    let k = 0;
    let occ = occurrence(rl, 0);
    rl.isActive = true;
    for (; ; k++) {
      occ = occurrence(rl, k);
      if (occ > NOW) break;
      if (rl.endDate && occ > rl.endDate) { rl.isActive = false; break; }
      if (rl.pausedAt && occ > rl.pausedAt) { rl.isActive = false; break; }
      if (archivedAt && occ > archivedAt) { rl.isActive = false; rl.skipped = occ; occ = occurrence(rl, k + 1); break; }
      addEvent(u, { k: 'tx', at: occ, type: rl.type, cat: rl.cat, amount: rl.amount, title: rl.title, note: rl.note, pref: [rl.wallet], fixed: true, rule: { id: rl.id, scheduledFor: occ } });
    }
    if (rl.endDate && occ > rl.endDate) rl.isActive = false;
    rl.nextRunAt = occ; // lastRunAt gán trong simulate() theo createdAt của giao dịch sinh cuối cùng
  }
}

// ---------------------------------------------------------------- mô phỏng theo thời gian
interface Rows {
  tx: { id: string; userId: string; categoryId: string; walletId: string; type: TxType; amount: bigint; title: string; note: string | null; occurredAt: Date; recurringRuleId: string | null; scheduledFor: Date | null; createdAt: Date; updatedAt: Date }[];
  tr: { id: string; userId: string; fromWalletId: string; toWalletId: string; amount: bigint; note: string; occurredAt: Date; createdAt: Date; updatedAt: Date }[];
  se: { id: string; userId: string; goalId: string; walletId: string; type: 'DEPOSIT' | 'WITHDRAW'; amount: bigint; date: Date; createdAt: Date }[];
}

function simulate(u: UserPlan, walletIds: Map<WKey, string>, catIds: Map<string, string>) {
  const r = new Rng(`${u.email}#sim`);
  const bal = new Map<WKey, number>(u.wallets.map((w) => [w.key, w.initial]));
  const archived = new Set<WKey>();
  const exists = (k: WKey) => bal.has(k) && !archived.has(k);
  const rows: Rows = { tx: [], tr: [], se: [] };
  const created = (occurredAt: Date) => {
    // nhập liệu muộn vài phút; giao dịch trước ngày đăng ký = nhập lại sổ cũ lúc đăng ký
    const c = occurredAt < u.createdAt ? new Date(u.createdAt.getTime() + 60_000 + rows.tx.length * 1000) : new Date(occurredAt.getTime() + r.int(0, 25) * MIN);
    return c > NOW ? NOW : c;
  };
  const ruleCreatedAt = new Map(u.rules.map((rl) => [rl.id, new Date(Math.max(u.createdAt.getTime() + 10 * MIN, rl.startDate.getTime() - DAY))]));
  for (const rl of u.rules) rl.createdAt = ruleCreatedAt.get(rl.id);
  for (const g of u.goals) { g.saved = 0; g.status = 'ACTIVE'; }
  let negatives = 0;
  let last = new Date(0);
  const reserve = u.showcase ? 0 : u.profile.rent + u.rules.filter((x) => x.type === 'EXPENSE').reduce((a, x) => a + x.amount, 0) + 800_000;

  const fallback: Record<WKey, WKey[]> = { ew: ['ew', 'cash', 'bank', 'bank2'], cash: ['cash', 'ew', 'bank', 'bank2'], bank: ['bank', 'bank2', 'ew', 'cash'], bank2: ['bank2', 'bank', 'ew', 'cash'] };
  const resolve = (pref: WKey[]) => [...new Set(pref.flatMap((k) => fallback[k]))].filter(exists);

  const transfer = (when: Date, from: WKey, to: WKey, amount: number, note: string) => {
    if (when > last) last = when;
    bal.set(from, bal.get(from)! - amount);
    bal.set(to, bal.get(to)! + amount);
    rows.tr.push({ id: randomUUID(), userId: u.id, fromWalletId: walletIds.get(from)!, toWalletId: walletIds.get(to)!, amount: BigInt(amount), note, occurredAt: when, createdAt: created(when), updatedAt: created(when) });
  };
  /** Ví w thiếu tiền => nạp từ ngân hàng (đủ số dư) ngay trước đó */
  const topUp = (w: WKey, need: number, when: Date, after = false) => {
    // ưu tiên ngân hàng; ví ngân hàng thiếu thì nộp tiền mặt / rút ví điện tử vào
    const order = (k: WKey) => (k === 'bank' || k === 'bank2' ? 1e15 : 0) + bal.get(k)!;
    const sources = (['bank', 'bank2', 'cash', 'ew'] as WKey[]).filter((k) => k !== w && exists(k) && bal.get(k)! > 0).sort((a, b) => order(b) - order(a));
    const src = sources.find((k) => bal.get(k)! >= Math.ceil(need / 50_000) * 50_000);
    if (!src) return false;
    const typical = w === 'cash' ? r.money(1_000_000, 2_000_000, 500_000) : w === 'ew' ? r.money(300_000, 1_000_000, 100_000) : r.money(2_000_000, 5_000_000, 1_000_000);
    let amount = Math.ceil(Math.max(need, typical) / 100_000) * 100_000;
    if (bal.get(src)! < amount) amount = Math.ceil(need / 50_000) * 50_000;
    if (bal.get(src)! < amount) return false;
    // ngay sau khoản chi (1 giây) hoặc ngay trước nó, không bao giờ lệch thứ tự so với các sự kiện đã mô phỏng
    const t = after ? new Date(Math.min(NOW.getTime(), when.getTime() + 1000)) : new Date(Math.min(when.getTime(), Math.max(last.getTime() + 1000, when.getTime() - r.int(2, 20) * MIN)));
    const name = u.wallets.find((x) => x.key === w)!.name;
    transfer(t, src, w, amount, w === 'cash' ? 'Rút tiền mặt ATM' : w === 'ew' ? `Nạp ví ${name}` : src === 'cash' ? 'Nộp tiền mặt vào tài khoản' : `Chuyển sang ${name}`);
    return true;
  };

  const events = [...u.events].sort((a, b) => a.at.getTime() - b.at.getTime());
  for (const e of events) {
    switch (e.k) {
      case 'tx': {
        let w: WKey | undefined;
        if (e.type === 'INCOME') w = resolve(e.pref)[0];
        else if (e.fixed) {
          w = e.pref[0];
          if (bal.get(w)! < e.amount && !topUp(w, e.amount - bal.get(w)!, e.at)) {
            negatives++;
            if (process.env.DEMO_DEBUG) console.warn(`    ${vnDay(e.at)} ${e.title} ${e.amount} ví ${w}=${bal.get(w)} | ${[...bal].map(([k, v]) => `${k}:${v}`).join(' ')}`);
          }
        } else {
          // sắp cạn tiền => giữ lại khoản cho tiền nhà / định kỳ, bớt chi tiêu tùy ý
          const liquid = [...bal].filter(([k]) => exists(k)).reduce((a, [, v]) => a + v, 0);
          if (liquid - e.amount < reserve && !e.title.startsWith('Tiền điện') && r.chance(0.9)) break;
          const cands = resolve(e.pref);
          w = cands.find((k) => bal.get(k)! >= e.amount);
          if (!w && cands[0] && topUp(cands[0], e.amount - bal.get(cands[0])!, e.at)) w = cands[0];
        }
        if (!w) break; // không đủ tiền => bỏ khoản chi này (người dùng không tiêu)
        bal.set(w, bal.get(w)! + (e.type === 'INCOME' ? e.amount : -e.amount));
        // ví tiền mặt / ví điện tử sắp cạn => thường được nạp lại ngay sau đó
        const low = w === 'cash' ? 200_000 : w === 'ew' ? 100_000 : -1;
        if (e.type === 'EXPENSE' && bal.get(w)! < low && r.chance(0.9)) topUp(w, 0, e.at, true);
        const c = e.rule ? new Date(Math.min(NOW.getTime(), Math.max(e.at.getTime() + r.int(0, 14) * MIN, ruleCreatedAt.get(e.rule.id)!.getTime() + rows.tx.length))) : created(e.at);
        rows.tx.push({
          id: randomUUID(), userId: u.id, categoryId: catIds.get(e.cat)!, walletId: walletIds.get(w)!, type: e.type, amount: BigInt(e.amount),
          title: e.title, note: e.note ?? null, occurredAt: e.at, recurringRuleId: e.rule?.id ?? null, scheduledFor: e.rule?.scheduledFor ?? null, createdAt: c, updatedAt: c,
        });
        break;
      }
      case 'tr': {
        if (!exists(e.from) || !exists(e.to)) break;
        let amount = e.amount;
        if (bal.get(e.from)! < amount) amount = Math.floor(bal.get(e.from)! / 100_000) * 100_000;
        if (amount < 100_000) break;
        transfer(e.at, e.from, e.to, amount, e.note);
        break;
      }
      case 'dep': {
        const g = e.goal;
        if (g.status !== 'ACTIVE') break;
        const amount = Math.min(e.amount, g.target - g.saved);
        const w = resolve(e.from).filter((k) => k === 'bank' || k === 'bank2').find((k) => bal.get(k)! >= amount + (u.showcase ? 0 : Math.max(2_000_000, u.profile.income * 0.5)));
        if (!w) break;
        bal.set(w, bal.get(w)! - amount);
        g.saved += amount;
        if (g.saved >= g.target) g.status = 'COMPLETED';
        rows.se.push({ id: randomUUID(), userId: u.id, goalId: g.id, walletId: walletIds.get(w)!, type: 'DEPOSIT', amount: BigInt(amount), date: e.at, createdAt: created(e.at) });
        break;
      }
      case 'wd': {
        const g = e.goal;
        if (g.saved <= 0 || g.status === 'WITHDRAWN' || g.status === 'EARLY_WITHDRAWN') break;
        const w = resolve([e.to])[0];
        bal.set(w, bal.get(w)! + g.saved);
        rows.se.push({ id: randomUUID(), userId: u.id, goalId: g.id, walletId: walletIds.get(w)!, type: 'WITHDRAW', amount: BigInt(g.saved), date: e.at, createdAt: created(e.at) });
        g.status = g.status === 'COMPLETED' ? 'WITHDRAWN' : 'EARLY_WITHDRAWN';
        g.saved = 0;
        break;
      }
      case 'arch': {
        const left = bal.get(e.wallet)!;
        const to = resolve(['bank'])[0] ?? resolve(['cash']).find((k) => k !== e.wallet)!;
        if (left > 0) transfer(e.at, e.wallet, to, left, 'Chuyển hết về ngân hàng trước khi đóng ví');
        archived.add(e.wallet);
        break;
      }
    }
    if (e.at > last) last = e.at;
  }
  // lastRunAt = lúc sinh kỳ cuối cùng
  for (const rl of u.rules) {
    const gen = rows.tx.filter((t) => t.recurringRuleId === rl.id);
    rl.lastRunAt = gen.length ? gen[gen.length - 1].createdAt : null;
  }
  return { rows, bal, negatives, archived };
}

// ---------------------------------------------------------------- ngân sách + thông báo
type NotiRow = { id: string; userId: string; type: NotificationType; title: string; body: string; data: object; readAt: Date | null; broadcastId: string | null; createdAt: Date };
type BudgetRow = { id: string; userId: string; categoryId: string | null; month: string; limitAmount: bigint; warnedAt: Date | null; exceededAt: Date | null; createdAt: Date; updatedAt: Date };

function readAtFor(r: Rng, createdAt: Date, unreadBias = 0) {
  const ageDays = (NOW.getTime() - createdAt.getTime()) / DAY;
  const pRead = ageDays > 7 ? 0.9 - unreadBias : ageDays > 2 ? 0.6 - unreadBias : 0.25 - unreadBias;
  if (!r.chance(pRead)) return null;
  const t = new Date(createdAt.getTime() + r.int(5, 60 * 30) * MIN);
  return t > NOW ? new Date(createdAt.getTime() + Math.max(1, Math.floor((NOW.getTime() - createdAt.getTime()) / 2))) : t;
}

/**
 * Ngân sách cho `months` tháng gần nhất + dấu/ thông báo đúng như BudgetsService.checkThresholds:
 * mỗi giao dịch chi tạo sau ngân sách => kiểm tra ngân sách danh mục của nó + ngân sách tổng.
 */
function planBudgets(u: UserPlan, rows: Rows, catIds: Map<string, string>, catNames: Map<string, string>, overrides?: Map<string, number>) {
  const r = new Rng(`${u.email}#budget`);
  const budgets: BudgetRow[] = [];
  const notis: NotiRow[] = [];
  const expenses = rows.tx.filter((t) => t.type === 'EXPENSE');
  for (let i = u.budgetMonths - 1; i >= 0; i--) {
    const month = shiftMonth(CUR_MONTH, -i);
    const { start, end } = monthRange(month);
    const createdAt = new Date(Math.max(start.getTime() + 8 * HOUR + r.int(0, 120) * MIN, u.createdAt.getTime() + 30 * MIN));
    if (createdAt > NOW) continue;
    const inMonth = expenses.filter((t) => t.occurredAt >= start && t.occurredAt < end);
    const byCat = new Map<string, number>();
    for (const t of inMonth) byCat.set(t.categoryId, (byCat.get(t.categoryId) ?? 0) + Number(t.amount));
    const total = [...byCat.values()].reduce((a, b) => a + b, 0);
    const isCur = month === CUR_MONTH;
    // tháng hiện tại: hạn mức dựa trên chi tháng trước (dự phóng từ vài ngày đầu tháng không đáng tin)
    const prevSpent = new Map<string, number>();
    if (isCur) {
      const p = monthRange(shiftMonth(month, -1));
      for (const t of expenses.filter((x) => x.occurredAt >= p.start && x.occurredAt < p.end)) {
        const k = `${month}:${catNames.get(t.categoryId)}`;
        prevSpent.set(k, (prevSpent.get(k) ?? 0) + Number(t.amount));
        prevSpent.set(`${month}:overall`, (prevSpent.get(`${month}:overall`) ?? 0) + Number(t.amount));
      }
    }
    const elapsed = isCur ? Math.max(0.15, (NOW.getTime() - start.getTime()) / (end.getTime() - start.getTime())) : 1;
    // tỷ lệ mục tiêu: đa số ok, một số cảnh báo / vượt
    const ratio = () => r.pick([0.6, 0.7, 0.75, 0.85, 0.92, 1.08, 0.65, 0.78]);
    const limitFor = (spent: number, step: number, key: string) => {
      if (overrides?.has(key)) return overrides.get(key)!;
      const projected = isCur ? Math.max(spent / Math.max(elapsed, 0.5), prevSpent.get(key) ?? 0) : spent;
      const rt = isCur ? r.pick([0.75, 0.85, 0.95, 1.0]) : ratio();
      return Math.max(step, Math.round(projected / rt / step) * step);
    };
    if (total > 0) {
      budgets.push({ id: randomUUID(), userId: u.id, categoryId: null, month, limitAmount: BigInt(limitFor(total, 500_000, `${month}:overall`)), warnedAt: null, exceededAt: null, createdAt, updatedAt: createdAt });
    }
    const candidates = ['Ăn uống', 'Di chuyển', 'Mua sắm', 'Giải trí', 'Hóa đơn'].map((n) => catIds.get(n)!).filter((id) => (byCat.get(id) ?? 0) > 0);
    const chosen = overrides ? candidates.filter((id) => overrides.has(`${month}:${catNames.get(id)}`)) : candidates.sort(() => r.next() - 0.5).slice(0, r.int(2, 4));
    for (const id of chosen) {
      let limit = limitFor(byCat.get(id)!, 100_000, `${month}:${catNames.get(id)}`);
      // tháng hiện tại: thêm vài ngân sách đã chạm ngưỡng cho sinh động
      if (isCur && !overrides && r.chance(0.3)) limit = Math.max(100_000, Math.round(byCat.get(id)! / r.pick([0.85, 1.1]) / 100_000) * 100_000);
      budgets.push({ id: randomUUID(), userId: u.id, categoryId: id, month, limitAmount: BigInt(limit), warnedAt: null, exceededAt: null, createdAt: new Date(createdAt.getTime() + 1000 * budgets.length), updatedAt: createdAt });
    }
    // phát lại theo thứ tự tạo giao dịch
    const monthBudgets = budgets.filter((b) => b.month === month);
    const ordered = [...inMonth].sort((a, b) => a.createdAt.getTime() - b.createdAt.getTime());
    const spent = new Map<string | null, number>();
    // giao dịch tạo trước ngân sách vẫn được tính vào spent
    for (const t of ordered) {
      spent.set(t.categoryId, (spent.get(t.categoryId) ?? 0) + Number(t.amount));
      spent.set(null, (spent.get(null) ?? 0) + Number(t.amount));
      for (const b of monthBudgets) {
        if (b.createdAt > t.createdAt) continue;
        if (b.categoryId !== null && b.categoryId !== t.categoryId) continue;
        const used = spent.get(b.categoryId) ?? 0;
        const limit = Number(b.limitAmount);
        const pct = (used / limit) * 100;
        const level = pct >= 100 ? 'exceeded' : pct >= 80 ? 'warning' : null;
        if (!level) continue;
        if (level === 'exceeded' ? b.exceededAt : b.warnedAt) continue;
        const now = new Date(t.createdAt.getTime() + 300);
        if (level === 'exceeded') { b.exceededAt = now; b.warnedAt = b.warnedAt ?? now; } else b.warnedAt = now;
        b.updatedAt = now;
        const name = b.categoryId ? `"${catNames.get(b.categoryId)}"` : 'tổng';
        const pctR = Math.round(pct * 10) / 10;
        notis.push({
          id: randomUUID(), userId: u.id, type: level === 'exceeded' ? 'BUDGET_EXCEEDED' : 'BUDGET_WARNING',
          title: level === 'exceeded' ? `Vượt ngân sách ${name}` : `Sắp hết ngân sách ${name}`,
          body: `Tháng ${month}: đã chi ${fmt(used)}đ / ${fmt(limit)}đ (${pctR}%)`,
          data: { budgetId: b.id, month, categoryId: b.categoryId, spent: used, limit, percentage: pctR },
          readAt: null, broadcastId: null, createdAt: now,
        });
      }
    }
  }
  return { budgets, notis };
}

// ---------------------------------------------------------------- người dùng
function makeUser(email: string, name: string, persona: Persona, daysAgo: number, opts: Partial<UserPlan> = {}): UserPlan {
  const rng = new Rng(email);
  const profile = makeProfile(rng, persona);
  const createdDay = addDays(TODAY, -daysAgo);
  const createdAt = at(createdDay, rng.int(8, 22), rng.int(0, 59), rng.int(0, 59));
  const nWallets = persona === 'student' ? rng.int(2, 3) : rng.pick([2, 3, 3, 3, 4, 4]);
  const u: UserPlan = {
    id: randomUUID(), email, name, role: 'USER', status: 'ACTIVE', createdAt: createdAt > NOW ? new Date(NOW.getTime() - HOUR) : createdAt,
    rng, profile, wallets: makeWallets(rng, profile, nWallets), customCats: [], goals: [], rules: [], events: [], templates: [],
    budgetMonths: rng.pick([0, 1, 3, 3, 3]), ...opts,
  };
  const cats = new Set<string>(['family', 'wedding', 'travel']);
  if (persona === 'freelancer') cats.add('freelance');
  if (persona === 'seller') { cats.add('shop'); cats.add('stock'); }
  if (profile.kids) cats.add('kids');
  if (profile.pet) cats.add('pet');
  if (profile.gym) cats.add('sport');
  cats.add('interest');
  u.customCats = [...cats];
  return u;
}

function finishPlan(u: UserPlan) {
  const r = u.rng;
  const skip = new Set<string>();
  // ~1/6 user từng có ví điện tử thứ 2 rồi đóng => ví lưu trữ (số dư 0) + có thể kéo theo định kỳ bị tạm dừng
  if (u.wallets.some((w) => w.key === 'ew') && r.chance(0.18) && !u.showcase) {
    const ew = u.wallets.find((w) => w.key === 'ew')!;
    ew.archiveDay = addDays(TODAY, -r.int(20, 90));
  }
  planRules(u, skip);
  expandRules(u);
  generateDaily(u, skip);
  planGoals(u);
  for (const w of u.wallets) if (w.archiveDay) addEvent(u, { k: 'arch', at: at(w.archiveDay, 12, 0), wallet: w.key });
  const has = (k: WKey) => u.wallets.some((w) => w.key === k && !w.archiveDay);
  const pool = [
    { label: 'Cà phê', title: 'Cà phê sáng', amount: r.pick([29_000, 35_000, 45_000, 55_000]), cat: 'Ăn uống', wallet: has('ew') ? 'ew' : 'cash' },
    { label: 'Cơm trưa', title: 'Cơm trưa văn phòng', amount: r.pick([45_000, 50_000, 55_000]), cat: 'Ăn uống', wallet: 'cash' },
    { label: 'Grab', title: 'Grab đi làm', amount: r.pick([32_000, 38_000, 45_000]), cat: 'Di chuyển', wallet: has('ew') ? 'ew' : 'cash' },
    { label: 'Gửi xe', title: 'Gửi xe', amount: 5_000, cat: 'Di chuyển', wallet: 'cash' },
    { label: 'Bánh mì', title: 'Bánh mì sáng', amount: r.pick([20_000, 25_000]), cat: 'Ăn uống', wallet: 'cash' },
    { label: 'Trà sữa', title: 'Trà sữa', amount: r.pick([45_000, 55_000]), cat: 'Ăn uống', wallet: has('ew') ? 'ew' : 'cash' },
    { label: 'Đổ xăng', title: 'Đổ xăng', amount: r.pick([80_000, 100_000]), cat: 'Di chuyển', wallet: 'cash' },
  ] as const;
  const n = r.int(0, 4);
  u.templates = [...pool].sort(() => r.next() - 0.5).slice(0, n).map((t) => ({ ...t, wallet: t.wallet as WKey }));
}

/** Tài khoản trưng bày demo@thuchi.vn — bám sát mockup mobile. */
function makeShowcase(): UserPlan {
  const u = makeUser(SHOWCASE_EMAIL, 'Nguyễn Minh Anh', 'office', 340, { showcase: true, budgetMonths: 4 });
  Object.assign(u.profile, {
    income: 22_000_000, salaryDay: 5, rent: 2_500_000, rentDay: 1, motorbike: true, coffeeP: 0.55, lunchP: 0.9, grabP: 0.2,
    dinnerP: 0.12, shopeeP: 0.05, groceryPerWeek: 1, entP: 0.3, scale: 0.75, sendParents: 0, gym: false, pet: false, kids: false,
  } satisfies Partial<Profile>);
  u.wallets = [
    { key: 'bank', name: 'MB Bank', type: 'BANK', icon: 'building', color: '#1E3A8A', initial: 15_000_000 },
    { key: 'bank2', name: 'Techcombank', type: 'BANK', icon: 'building', color: '#DC2626', initial: 2_000_000 },
    { key: 'cash', name: 'Tiền mặt', type: 'CASH', icon: 'moneyBill', color: '#16A34A', initial: 1_200_000 },
    { key: 'ew', name: 'MoMo', type: 'EWALLET', icon: 'mobile', color: '#A50064', initial: 300_000 },
  ];
  u.customCats = ['wedding', 'travel', 'family'];
  const skip = new Set(['salary', 'rent', 'internet']);
  const first = (d: number) => at(dayOfMonth(shiftMonth(HISTORY_START.slice(0, 7), 1), d), 0, 0);
  const t = (d: Date, h: number, m: number) => new Date(d.getTime() + (h * 60 + m) * MIN);
  rule(u, { title: 'Lương công ty', cat: 'Lương', type: 'INCOME', amount: 22_000_000, wallet: 'bank', frequency: 'MONTHLY', interval: 1, startDate: t(first(5), 9, 0), endDate: null, note: 'Công ty TNHH Sao Việt' });
  rule(u, { title: 'Tiền nhà', cat: 'Nhà ở', type: 'EXPENSE', amount: 2_500_000, wallet: 'bank', frequency: 'MONTHLY', interval: 1, startDate: t(first(1), 8, 0), endDate: null, note: 'Chuyển khoản cho chủ nhà' });
  rule(u, { title: 'Đi chợ cuối tuần', cat: 'Ăn uống', type: 'EXPENSE', amount: 500_000, wallet: 'cash', frequency: 'WEEKLY', interval: 1, startDate: at(nextWeekday(addDays(TODAY, -120), 0), 8, 30), endDate: null });
  rule(u, { title: 'Internet FPT', cat: 'Hóa đơn', type: 'EXPENSE', amount: 245_000, wallet: 'bank2', frequency: 'MONTHLY', interval: 1, startDate: t(first(10), 20, 0), endDate: null });
  const spotify = rule(u, { title: 'Spotify Premium', cat: 'Giải trí', type: 'EXPENSE', amount: 59_000, wallet: 'ew', frequency: 'MONTHLY', interval: 1, startDate: t(first(15), 7, 0), endDate: null });
  spotify.pausedAt = at(addDays(TODAY, -18), 21, 10);
  expandRules(u);
  generateDaily(u, skip);
  // Freelance thiết kế qua Techcombank, chi giải trí từ Techcombank (như mockup)
  for (let m = shiftMonth(CUR_MONTH, -10); m < CUR_MONTH; m = shiftMonth(m, 1)) {
    addEvent(u, { k: 'tx', at: at(dayOfMonth(m, u.rng.int(16, 24)), 16, 20), type: 'INCOME', cat: 'Thu khác', amount: u.rng.pick([1_000_000, 1_500_000, 2_000_000, 2_500_000]), title: 'Freelance thiết kế', pref: ['bank2'] });
    addEvent(u, { k: 'tx', at: at(dayOfMonth(m, 6), 19, 30), type: 'EXPENSE', cat: 'Gia đình', amount: 2_000_000, title: 'Gửi tiền bố mẹ', pref: ['bank'], note: 'Chuyển khoản về Nam Định' });
  }
  // mua lớn trong năm
  addEvent(u, { k: 'tx', at: at(addDays(TODAY, -230), 19, 10), type: 'EXPENSE', cat: 'Mua sắm', amount: 22_990_000, title: 'iPhone 16 Pro', pref: ['bank'], note: 'Mua tại CellphoneS' });
  addEvent(u, { k: 'tx', at: at(addDays(TODAY, -130), 10, 5), type: 'EXPENSE', cat: 'Du lịch', amount: 6_850_000, title: 'Tour Phú Quốc 3N2Đ', pref: ['bank'] });
  addEvent(u, { k: 'tx', at: at(addDays(TODAY, -75), 21, 0), type: 'EXPENSE', cat: 'Giáo dục', amount: 8_900_000, title: 'Khóa học UX/UI Design', pref: ['bank'], note: 'Học online 3 tháng' });
  addEvent(u, { k: 'tx', at: at(addDays(TODAY, -100), 10, 30), type: 'EXPENSE', cat: 'Di chuyển', amount: 34_500_000, title: 'Mua xe Honda Vision', pref: ['bank'], note: 'Head Honda Phát Tiến, đã gồm biển số' });
  // tiết kiệm: 3 mục tiêu đang chạy như mockup (4,2tr / 18tr / 30tr)
  const goal = (name: string, target: number, icon: string, color: string, startDaysAgo: number, targetDate: Date, deposits: [number, number][]) => {
    const g: GoalPlan = { id: randomUUID(), name, target, icon, color, startDate: at(addDays(TODAY, -startDaysAgo), 9, 0), targetDate, saved: 0, status: 'ACTIVE' };
    u.goals.push(g);
    for (const [daysAgo, amount] of deposits) addEvent(u, { k: 'dep', at: at(addDays(TODAY, -daysAgo), 20, 15), goal: g, amount, from: ['bank'] });
  };
  // nạp ngày 6 hằng tháng (sau lương ngày 5), n tháng gần nhất trước tháng này
  const daysAgo = (day: string) => Math.round((dayStart(TODAY).getTime() - dayStart(day).getTime()) / DAY);
  const monthlyDeps = (n: number, _n: number, amount: number) => Array.from({ length: n }, (_, i) => [daysAgo(dayOfMonth(shiftMonth(CUR_MONTH, -1 - i), 6)), amount] as [number, number]);
  goal('Du lịch Đà Lạt', 6_000_000, 'plane', '#22C55E', 100, at('2026-12-15', 0, 0), [[98, 1_200_000], [68, 1_000_000], [37, 1_000_000], [7, 1_000_000]]);
  goal('MacBook Air M4', 35_000_000, 'mobile', '#6366F1', 190, at('2027-03-31', 0, 0), monthlyDeps(6, 6, 3_000_000));
  goal('Quỹ khẩn cấp', 50_000_000, 'piggyBank', '#0EA5E9', 320, at('2028-12-31', 0, 0), monthlyDeps(10, 10, 3_000_000));
  u.templates = [
    { label: 'Cà phê', title: 'Cà phê sáng', amount: 45_000, cat: 'Ăn uống', wallet: 'ew' },
    { label: 'Cơm trưa', title: 'Cơm trưa văn phòng', amount: 55_000, cat: 'Ăn uống', wallet: 'cash' },
    { label: 'Grab', title: 'Grab đi làm', amount: 38_000, cat: 'Di chuyển', wallet: 'ew' },
    { label: 'Gửi xe', title: 'Gửi xe', amount: 5_000, cat: 'Di chuyển', wallet: 'cash' },
  ];
  return u;
}

// ---------------------------------------------------------------- main
async function main() {
  const t0 = Date.now();
  const sys = await prisma.category.findMany({ where: { userId: null } });
  if (sys.length < 14) throw new Error('Chưa có danh mục hệ thống — chạy `npm run db:seed` trước');

  // ---- xóa dữ liệu demo cũ
  const old = await prisma.user.findMany({ where: { OR: [{ email: { endsWith: `@${DEMO_DOMAIN}` } }, { email: SHOWCASE_EMAIL }] }, select: { id: true } });
  await prisma.broadcast.deleteMany({ where: { OR: [{ id: { in: BROADCAST_IDS } }, { createdById: { in: old.map((o) => o.id) } }] } });
  for (let i = 0; i < old.length; i += 10) await prisma.user.deleteMany({ where: { id: { in: old.slice(i, i + 10).map((o) => o.id) } } });

  // ---- admin demo
  let admin = await prisma.user.findUnique({ where: { email: DEMO_ADMIN_EMAIL } });
  if (!admin) {
    admin = await prisma.user.create({
      data: { email: DEMO_ADMIN_EMAIL, name: 'Quản trị viên', role: 'ADMIN', passwordHash: await bcrypt.hash(DEMO_ADMIN_PASSWORD, 10), createdAt: at(addDays(TODAY, -364), 8, 30), lastLoginAt: new Date(NOW.getTime() - 3 * HOUR) },
    });
    await prisma.wallet.create({ data: { userId: admin.id, name: 'Tiền mặt', type: 'CASH', createdAt: admin.createdAt } });
  } else if (admin.role !== 'ADMIN' || admin.status !== 'ACTIVE') {
    admin = await prisma.user.update({ where: { id: admin.id }, data: { role: 'ADMIN', status: 'ACTIVE' } });
  }

  // ---- kế hoạch
  const users: UserPlan[] = [makeShowcase()];
  const pr = new Rng('demo-users');
  PEOPLE.forEach(([name, slug, persona], i) => {
    const daysAgo = i === 0 ? 362 : Math.max(2, Math.round(360 * Math.pow(pr.next(), 1.7)));
    const email = `${slug}${pr.chance(0.35) ? pr.int(88, 99) : ''}@${DEMO_DOMAIN}`;
    users.push(makeUser(email, name, persona, daysAgo));
  });
  users[1].role = 'ADMIN';
  for (const i of [7, 19, 30]) users[i].status = 'LOCKED';
  for (const u of users.slice(1)) finishPlan(u);

  const passwordHash = await bcrypt.hash(DEMO_PASSWORD, 10);
  const sysIds = new Map(sys.map((c) => [c.name, c.id]));
  const out = {
    users: [] as object[], wallets: [] as object[], cats: [] as object[], goals: [] as object[], rules: [] as object[], tx: [] as Rows['tx'], tr: [] as Rows['tr'],
    se: [] as Rows['se'], budgets: [] as BudgetRow[], templates: [] as object[], notis: [] as NotiRow[],
  };
  let negatives = 0;
  const activeIds: { id: string; createdAt: Date; showcase: boolean }[] = [];

  for (const u of users) {
    const catIds = new Map(sysIds);
    const catNames = new Map(sys.map((c) => [c.id, c.name]));
    for (const key of u.customCats) {
      const c = CUSTOM_CATS[key];
      const id = randomUUID();
      catIds.set(c.name, id);
      catNames.set(id, c.name);
      out.cats.push({ id, userId: u.id, ...c, createdAt: u.createdAt, updatedAt: u.createdAt });
    }
    // danh mục chưa tạo cho user này (vd không có thú cưng) mà sự kiện dùng tới => về danh mục hệ thống gần nhất
    const alias: Record<string, string> = { 'Gia đình': 'Chi khác', 'Thú cưng': 'Chi khác', 'Con cái': 'Chi khác', 'Thể thao': 'Sức khỏe', 'Hiếu hỉ': 'Chi khác', 'Du lịch': 'Giải trí', 'Nhập hàng': 'Mua sắm', Freelance: 'Thu khác', 'Bán hàng online': 'Thu khác', 'Lãi tiết kiệm': 'Đầu tư' };
    for (const [from, to] of Object.entries(alias)) if (!catIds.has(from)) catIds.set(from, sysIds.get(to)!);

    const walletIds = new Map(u.wallets.map((w) => [w.key, randomUUID()]));
    let sim = simulate(u, walletIds, catIds);

    let overrides: Map<string, number> | undefined;
    if (u.showcase) {
      // hiệu chỉnh: chi tháng này ~60% ngân sách 14tr, tổng số dư ~26tr phân bổ như mockup
      const { start } = monthRange(CUR_MONTH);
      const spentCur = () => sim.rows.tx.filter((t) => t.type === 'EXPENSE' && t.occurredAt >= start).reduce((s, t) => s + Number(t.amount), 0);
      const shoeDay = addDays(TODAY, -Math.min(2, dom(TODAY) - 1));
      const need = Math.round((8_400_000 - spentCur()) / 10_000) * 10_000;
      // luôn có 1 khoản mua sắm làm ngân sách "Mua sắm" vượt (như mockup)
      addEvent(u, { k: 'tx', at: at(shoeDay, 20, 40), type: 'EXPENSE', cat: 'Mua sắm', amount: 1_690_000, title: 'Giày chạy bộ Nike Pegasus', pref: ['bank'], note: 'Sale cuối mùa' });
      if (need - 1_690_000 >= 300_000) addEvent(u, { k: 'tx', at: at(addDays(shoeDay, -1), 17, 30), type: 'EXPENSE', cat: 'Sức khỏe', amount: Math.min(need - 1_690_000, 3_000_000), title: 'Khám răng, cạo vôi', pref: ['bank'], note: 'Nha khoa Kim' });
      sim = simulate(u, walletIds, catIds);
      const totalOf = () => [...sim.bal.values()].reduce((a, b) => a + b, 0);
      const bank = u.wallets.find((w) => w.key === 'bank')!;
      // khoản mua lớn hấp thụ phần dư để tổng số dư ~26tr (lặp vài lần vì mô phỏng có thể đổi chút ít)
      // đặt muộn (ví đã tích lũy đủ) để không ví nào cạn giữa năm
      const big: TxEv = { k: 'tx', at: at(addDays(TODAY, -45), 18, 45), type: 'EXPENSE', cat: 'Mua sắm', amount: 0, title: 'Máy giặt LG + tủ lạnh Panasonic', pref: ['bank'], note: 'Điện Máy Xanh, chuyển nhà mới' };
      u.events.push(big);
      for (let i = 0; i < 6; i++) {
        const excess = totalOf() - 26_022_000;
        if (excess === 0) break;
        if (big.amount + excess >= 0) big.amount += excess;
        else { bank.initial += -(big.amount + excess); big.amount = 0; }
        sim = simulate(u, walletIds, catIds);
      }
      if (!big.amount) u.events.splice(u.events.indexOf(big), 1);
      // cân lại phân bổ: Techcombank 4tr, Tiền mặt 1,85tr, MoMo 1,5tr, còn lại MB Bank
      const target: [WKey, number, string][] = [['bank2', 4_000_000, 'Chuyển sang Techcombank'], ['cash', 1_850_000, 'Rút tiền mặt ATM'], ['ew', 1_500_000, 'Nạp ví MoMo']];
      const when = at(addDays(TODAY, -2), 18, 5);
      for (const [k, want, note] of target) {
        const diff = Math.round((want - sim.bal.get(k)!) / 1000) * 1000;
        if (diff > 0) addEvent(u, { k: 'tr', at: new Date(when.getTime() + target.findIndex((x) => x[0] === k) * 7 * MIN), from: 'bank', to: k, amount: diff, note });
        else if (diff < 0) addEvent(u, { k: 'tr', at: new Date(when.getTime() + target.findIndex((x) => x[0] === k) * 7 * MIN), from: k, to: 'bank', amount: -diff, note: 'Chuyển về MB Bank' });
      }
      sim = simulate(u, walletIds, catIds);
      const mo = (d: number) => shiftMonth(CUR_MONTH, d);
      overrides = new Map<string, number>();
      for (const d of [-3, -2, -1, 0]) {
        overrides.set(`${mo(d)}:overall`, 14_000_000);
        overrides.set(`${mo(d)}:Ăn uống`, 3_500_000);
        overrides.set(`${mo(d)}:Mua sắm`, d === 0 ? 1_500_000 : 2_000_000);
        overrides.set(`${mo(d)}:Di chuyển`, 1_200_000);
        overrides.set(`${mo(d)}:Giải trí`, 800_000);
      }
    }
    negatives += sim.negatives;
    if (process.env.DEMO_DEBUG && sim.negatives) console.warn(`  ${u.email}: ${sim.negatives} khoản chi làm ví âm`);

    out.users.push({
      id: u.id, email: u.email, name: u.name, passwordHash, role: u.role, status: u.status, tokenVersion: u.status === 'LOCKED' ? 1 : 0,
      createdAt: u.createdAt, updatedAt: u.createdAt,
      lastLoginAt: new Date(Math.max(
        u.createdAt.getTime() + HOUR,
        u.showcase ? NOW.getTime() - 25 * MIN : u.status === 'LOCKED' ? NOW.getTime() - u.rng.int(15, 60) * DAY : NOW.getTime() - u.rng.int(1, 240) * HOUR,
      )),
    });
    if (u.status === 'ACTIVE') activeIds.push({ id: u.id, createdAt: u.createdAt, showcase: !!u.showcase });
    for (const w of u.wallets) out.wallets.push({ id: walletIds.get(w.key), userId: u.id, name: w.name, type: w.type, initialBalance: BigInt(w.initial), icon: w.icon, color: w.color, isArchived: sim.archived.has(w.key), createdAt: u.createdAt, updatedAt: w.archiveDay ? at(w.archiveDay, 12, 1) : u.createdAt });
    for (const g of u.goals) {
      out.goals.push({ id: g.id, userId: u.id, name: g.name, targetAmount: BigInt(g.target), savedAmount: BigInt(g.saved), startDate: g.startDate, targetDate: g.targetDate, icon: g.icon, color: g.color, status: g.status, createdAt: new Date(Math.max(u.createdAt.getTime() + MIN, g.startDate.getTime() - HOUR)), updatedAt: g.startDate });
    }
    for (const rl of u.rules) {
      out.rules.push({
        id: rl.id, userId: u.id, walletId: walletIds.get(rl.wallet), categoryId: catIds.get(rl.cat), amount: BigInt(rl.amount), title: rl.title, note: rl.note ?? null,
        frequency: rl.frequency, interval: rl.interval, startDate: rl.startDate, endDate: rl.endDate, anchorDay: rl.anchorDay, nextRunAt: rl.nextRunAt, lastRunAt: rl.lastRunAt,
        isActive: rl.isActive, createdAt: rl.createdAt, updatedAt: rl.lastRunAt ?? rl.createdAt,
      });
      if (rl.skipped) {
        const w = u.wallets.find((x) => x.key === rl.wallet)!;
        const c = new Date(rl.skipped.getTime() + u.rng.int(1, 14) * MIN);
        out.notis.push({
          id: randomUUID(), userId: u.id, type: 'RECURRING_PAUSED', title: `Đã tạm dừng giao dịch định kỳ "${rl.title}"`,
          body: `Bỏ qua kỳ ${vnDay(rl.skipped)} vì ví "${w.name}" đã lưu trữ. Hãy kiểm tra rồi bật lại.`,
          data: { ruleId: rl.id, scheduledFor: rl.skipped.toISOString(), reason: `ví "${w.name}" đã lưu trữ` }, readAt: readAtFor(u.rng, c), broadcastId: null, createdAt: c,
        });
      }
    }
    out.tx.push(...sim.rows.tx);
    out.tr.push(...sim.rows.tr);
    out.se.push(...sim.rows.se);
    const { budgets, notis } = planBudgets(u, sim.rows, catIds, catNames, overrides);
    out.budgets.push(...budgets);
    for (const n of notis) {
      n.readAt = u.showcase ? (n.createdAt.getTime() > NOW.getTime() - 5 * DAY ? null : new Date(n.createdAt.getTime() + 2 * HOUR)) : readAtFor(u.rng, n.createdAt);
      if (n.readAt && n.readAt > NOW) n.readAt = NOW;
    }
    out.notis.push(...notis);
    for (const t of u.templates) {
      if (!walletIds.has(t.wallet) || sim.archived.has(t.wallet)) continue;
      out.templates.push({ id: randomUUID(), userId: u.id, label: t.label, title: t.title, amount: BigInt(t.amount), categoryId: catIds.get(t.cat), walletId: walletIds.get(t.wallet), createdAt: new Date(u.createdAt.getTime() + 5 * MIN), updatedAt: new Date(u.createdAt.getTime() + 5 * MIN) });
    }
  }

  // ---- broadcast
  const maintenance = new Date(NOW.getTime() + 4 * DAY);
  const dd = (d: Date) => vnDay(d).slice(8, 10) + '/' + vnDay(d).slice(5, 7);
  const BROADCASTS = [
    { id: BROADCAST_IDS[0], daysAgo: 152, title: 'Ra mắt Ví & Chuyển tiền giữa ví', body: 'Giờ bạn có thể quản lý nhiều ví (tiền mặt, ngân hàng, ví điện tử) và chuyển tiền giữa các ví. Số dư luôn được tính tự động từ giao dịch của bạn.' },
    { id: BROADCAST_IDS[1], daysAgo: 46, title: 'Mẹo: đặt ngân sách cho tháng mới', body: 'Đặt ngân sách tổng và theo từng danh mục để nhận cảnh báo khi chi tiêu chạm 80% và 100% hạn mức. Vào Cài đặt → Ngân sách để bắt đầu.' },
    { id: BROADCAST_IDS[2], daysAgo: 3, title: `Bảo trì hệ thống đêm ${dd(maintenance)}`, body: `Hệ thống sẽ bảo trì từ 23:00 đến 23:30 ngày ${dd(maintenance)} để nâng cấp. Dữ liệu của bạn không bị ảnh hưởng, ứng dụng có thể gián đoạn vài phút.` },
  ];
  const broadcasts: object[] = [];
  for (const b of BROADCASTS) {
    const createdAt = at(addDays(TODAY, -b.daysAgo), 9, 30);
    const recipients = activeIds.filter((a) => a.createdAt < createdAt);
    broadcasts.push({ id: b.id, title: b.title, body: b.body, createdById: admin.id, recipients: recipients.length, createdAt });
    const r = new Rng(b.id);
    for (const a of recipients) {
      out.notis.push({
        id: randomUUID(), userId: a.id, type: 'BROADCAST', title: b.title, body: b.body, data: { broadcastId: b.id }, broadcastId: b.id, createdAt,
        readAt: a.showcase ? (b.daysAgo > 5 ? new Date(createdAt.getTime() + 3 * HOUR) : null) : readAtFor(r, createdAt),
      });
    }
  }

  // ---- ghi DB (createMany theo lô)
  const batch = async <T>(rows: T[], fn: (data: T[]) => Promise<unknown>, size = 5000) => {
    for (let i = 0; i < rows.length; i += size) await fn(rows.slice(i, i + size));
  };
  await prisma.$transaction(async (db) => {
    await db.user.createMany({ data: out.users as never });
    await db.wallet.createMany({ data: out.wallets as never });
    await db.category.createMany({ data: out.cats as never });
    await db.savingGoal.createMany({ data: out.goals as never });
    await db.recurringRule.createMany({ data: out.rules as never });
    await batch(out.tx, (d) => db.transaction.createMany({ data: d }));
    await batch(out.tr, (d) => db.transfer.createMany({ data: d }));
    await batch(out.se, (d) => db.savingEntry.createMany({ data: d }));
    await db.budget.createMany({ data: out.budgets });
    await db.quickTemplate.createMany({ data: out.templates as never });
    await db.broadcast.createMany({ data: broadcasts as never });
    await batch(out.notis, (d) => db.notification.createMany({ data: d as never }));
  }, { timeout: 120_000 });

  const statuses = (out.goals as { status: string }[]).reduce<Record<string, number>>((m, g) => ({ ...m, [g.status]: (m[g.status] ?? 0) + 1 }), {});
  console.log(
    `Demo: ${users.length} user (${users.filter((u) => u.status === 'LOCKED').length} khóa, ${users.filter((u) => u.role === 'ADMIN').length} admin demo), ` +
      `${out.wallets.length} ví, ${out.tx.length} giao dịch, ${out.tr.length} chuyển tiền, ${out.goals.length} mục tiêu ${JSON.stringify(statuses)}, ` +
      `${out.se.length} nạp/rút, ${out.rules.length} định kỳ, ${out.budgets.length} ngân sách, ${out.templates.length} mẫu nhanh, ${out.notis.length} thông báo, ` +
      `${broadcasts.length} broadcast. Khoản chi làm ví âm: ${negatives}. ${((Date.now() - t0) / 1000).toFixed(1)}s`,
  );
  console.log(`Đăng nhập: ${SHOWCASE_EMAIL} / ${DEMO_PASSWORD} · ${DEMO_ADMIN_EMAIL} / ${DEMO_ADMIN_PASSWORD} · user khác: <email>@${DEMO_DOMAIN} / ${DEMO_PASSWORD}`);
}

main()
  .catch((e) => {
    console.error(e);
    process.exitCode = 1;
  })
  .finally(() => prisma.$disconnect());
