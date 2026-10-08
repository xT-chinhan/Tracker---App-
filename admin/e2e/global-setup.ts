/**
 * Seed dữ liệu thật qua public API (mỗi lần chạy dùng hậu tố riêng => chạy lại được trên cùng DB).
 * Ghi kỳ vọng (đã tính tay từ dữ liệu seed + số liệu nền trước khi seed) vào e2e/.state.json.
 */
import fs from 'node:fs'
import { adminToken, apiOk, STATE_FILE, type MonthSum, type Overview, type SeedUser, type State } from './helpers'

const monthOf = (d: Date) => new Date(d.getTime() + 7 * 3600_000).toISOString().slice(0, 7)
const shift = (m: string, delta: number) => {
  const [y, mo] = m.split('-').map(Number)
  return new Date(Date.UTC(y, mo - 1 + delta, 1)).toISOString().slice(0, 7)
}
const at = (month: string, day: number) => `${month}-${String(day).padStart(2, '0')}T12:00:00+07:00`

interface Tx { cat: string; amount: number; title: string; note?: string; month: string; day: number }

export default async function globalSetup() {
  const suffix = Date.now().toString(36)
  const cur = monthOf(new Date())
  const admin = await adminToken()
  const baseline = await apiOk<Overview>('GET', '/admin/overview', admin)

  const register = async (key: string, name: string): Promise<SeedUser> => {
    const email = `${key}.${suffix}@e2e.test`
    const password = 'secret123'
    const r = await apiOk<{ accessToken: string; user: { id: string } }>('POST', '/auth/register', undefined, { email, password, name })
    return { id: r.user.id, email, name, password, token: r.accessToken }
  }
  const users = {
    an: await register('an', 'Nguyễn Văn An'),
    binh: await register('binh', 'Trần Thị Bình'),
    chi: await register('chi', 'Lê Minh Chi'),
    dung: await register('dung', 'Phạm Quốc Dũng'),
    admin2: await register('admin2', 'Quản Trị Phụ'),
  }
  const fillers = 11
  for (let i = 1; i <= fillers; i++) await register(`filler${String(i).padStart(2, '0')}`, `Người dùng thử ${i}`)
  await apiOk('PATCH', `/admin/users/${users.admin2.id}`, admin, { role: 'ADMIN' })

  // Danh mục hệ thống riêng cho lần chạy, sẽ có 1 giao dịch => xóa sẽ thành lưu trữ.
  const used = await apiOk<{ id: string; name: string }>('POST', '/admin/categories', admin, {
    name: `Quà E2E ${suffix}`, type: 'EXPENSE', icon: 'gift', color: '#DB2777',
  })
  const cats = await apiOk<{ id: string; name: string; type: string }[]>('GET', '/categories', users.an.token)
  const catId = (name: string) => cats.find((c) => c.name === name)?.id ?? (name === used.name ? used.id : undefined)
  const catType = (name: string) => (name === used.name ? 'EXPENSE' : cats.find((c) => c.name === name)!.type)

  const plan: Record<'an' | 'binh' | 'chi', Tx[]> = { an: [], binh: [], chi: [] }
  for (let i = 5; i >= 0; i--) {
    const m = shift(cur, -i)
    plan.an.push(
      { cat: 'Lương', amount: 15_000_000, title: 'Lương tháng', month: m, day: 1 },
      { cat: 'Ăn uống', amount: 2_500_000 + i * 100_000, title: 'Ăn uống trong tháng', note: 'Chợ + quán', month: m, day: 2 },
      { cat: 'Di chuyển', amount: 800_000, title: 'Grab, xăng xe', month: m, day: 3 },
      { cat: 'Hóa đơn', amount: 1_200_000, title: 'Điện nước internet', month: m, day: 4 },
    )
  }
  plan.an.push(
    { cat: 'Thưởng', amount: 3_000_000, title: 'Thưởng dự án', month: cur, day: 5 },
    { cat: 'Mua sắm', amount: 1_750_000, title: 'Mua áo khoác', note: `Uniqlo ${suffix}`, month: cur, day: 5 },
    { cat: 'Lương', amount: 14_000_000, title: 'Lương cũ', month: shift(cur, -8), day: 1 },
  )
  for (let i = 2; i >= 0; i--) {
    const m = shift(cur, -i)
    plan.binh.push(
      { cat: 'Lương', amount: 22_000_000, title: 'Lương công ty', month: m, day: 1 },
      { cat: 'Nhà ở', amount: 6_000_000, title: 'Tiền thuê nhà', month: m, day: 2 },
      { cat: 'Giải trí', amount: 900_000, title: 'Xem phim, cafe', month: m, day: 3 },
    )
  }
  plan.binh.push({ cat: 'Đầu tư', amount: 5_000_000, title: 'Lãi chứng khoán', month: cur, day: 4 })
  for (const m of [shift(cur, -1), cur]) {
    plan.chi.push(
      { cat: 'Được tặng', amount: 2_500_000, title: 'Mẹ cho', month: m, day: 1 },
      { cat: 'Giáo dục', amount: 1_500_000, title: 'Học phí IELTS', month: m, day: 2 },
    )
  }
  plan.chi.push({ cat: used.name, amount: 300_000, title: 'Quà sinh nhật bạn', month: cur, day: 3 })

  for (const key of ['an', 'binh', 'chi'] as const) {
    const items = plan[key].map((t) => ({ categoryId: catId(t.cat)!, amount: t.amount, title: t.title, note: t.note, occurredAt: at(t.month, t.day) }))
    await apiOk('POST', '/transactions/bulk', users[key].token, { items })
  }

  // Ngân sách
  await apiOk('POST', '/budgets', users.an.token, { categoryId: catId('Ăn uống'), month: cur, limitAmount: 3_000_000 })
  await apiOk('POST', '/budgets', users.an.token, { categoryId: catId('Di chuyển'), month: cur, limitAmount: 1_000_000 })
  await apiOk('POST', '/budgets', users.binh.token, { categoryId: catId('Giải trí'), month: cur, limitAmount: 1_500_000 })

  // Mục tiêu tiết kiệm: an ACTIVE, binh COMPLETED + WITHDRAWN, chi EARLY_WITHDRAWN
  const target = new Date(Date.now() + 180 * 86400_000).toISOString()
  const goal = (u: SeedUser, name: string, targetAmount: number) =>
    apiOk<{ id: string }>('POST', '/saving-goals', u.token, { name, targetAmount, targetDate: target })
  const g1 = await goal(users.an, 'Mua laptop', 30_000_000)
  await apiOk('POST', `/saving-goals/${g1.id}/deposit`, users.an.token, { amount: 5_000_000 })
  const g2 = await goal(users.binh, 'Du lịch Đà Lạt', 4_000_000)
  await apiOk('POST', `/saving-goals/${g2.id}/deposit`, users.binh.token, { amount: 4_000_000 })
  const g3 = await goal(users.binh, 'Quỹ khẩn cấp', 10_000_000)
  await apiOk('POST', `/saving-goals/${g3.id}/deposit`, users.binh.token, { amount: 10_000_000 })
  await apiOk('POST', `/saving-goals/${g3.id}/withdraw`, users.binh.token)
  const g4 = await goal(users.chi, 'Học tiếng Anh', 5_000_000)
  await apiOk('POST', `/saving-goals/${g4.id}/deposit`, users.chi.token, { amount: 1_000_000 })
  await apiOk('POST', `/saving-goals/${g4.id}/withdraw`, users.chi.token)
  const goalsAdded: Record<string, number> = { ACTIVE: 1, COMPLETED: 1, WITHDRAWN: 1, EARLY_WITHDRAWN: 1 }

  // ===== Kỳ vọng tính tay =====
  const all = [...plan.an, ...plan.binh, ...plan.chi]
  const isIncome = (t: Tx) => catType(t.cat) === 'INCOME'
  const sum = (xs: Tx[]) => xs.reduce((s, t) => s + t.amount, 0)
  const monthSums = (xs: Tx[]): MonthSum[] =>
    Array.from({ length: 6 }, (_, i) => {
      const m = shift(cur, i - 5)
      return { month: m, income: sum(xs.filter((t) => t.month === m && isIncome(t))), expense: sum(xs.filter((t) => t.month === m && !isIncome(t))) }
    })
  const seededUsers = 5 + fillers
  const allSums = monthSums(all)
  const expected: Overview = {
    users: {
      total: baseline.users.total + seededUsers,
      active: baseline.users.active + seededUsers,
      locked: baseline.users.locked,
      new30d: baseline.users.new30d + seededUsers,
    },
    transactions: {
      total: baseline.transactions.total + all.length,
      new30d: baseline.transactions.new30d + all.length,
      totalIncome: baseline.transactions.totalIncome + sum(all.filter(isIncome)),
      totalExpense: baseline.transactions.totalExpense + sum(all.filter((t) => !isIncome(t))),
    },
    savingGoals: Object.fromEntries(
      Object.keys(goalsAdded).map((k) => [k, (baseline.savingGoals[k] ?? 0) + goalsAdded[k]]),
    ),
    trend: baseline.trend.map((b, i) => {
      const income = b.income + allSums[i].income
      const expense = b.expense + allSums[i].expense
      return { month: b.month, income, expense, net: income - expense }
    }),
  }
  const anIncome = sum(plan.an.filter(isIncome))
  const anExpense = sum(plan.an.filter((t) => !isIncome(t)))
  const st: State = {
    suffix,
    users,
    fillers,
    usedCategory: used,
    currentMonth: cur,
    baseline,
    expected,
    an: {
      income: anIncome,
      expense: anExpense,
      savings: 5_000_000,
      balance: anIncome - anExpense - 5_000_000,
      txCount: plan.an.length,
      incomeCount: plan.an.filter(isIncome).length,
      currentMonthCount: plan.an.filter((t) => t.month === cur).length,
      budgets: 2,
      goals: 1,
      trend: monthSums(plan.an),
    },
  }
  fs.writeFileSync(STATE_FILE, JSON.stringify(st, null, 2))
}
