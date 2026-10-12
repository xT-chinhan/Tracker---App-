/** Luật phát hiện bất thường — thuần code, dùng chung cho phat-hien-bat-thuong và de-xuat-khoa. */
import type { UserActivity } from '../../lib/contracts.js';
import { daysInMonth, monthOf, vnDay } from '../../lib/period.js';
import { int, money } from '../../lib/skillkit.js';

export interface Flag { userId: string; email: string; name: string; kind: 'spend-spike' | 'big-expense' | 'tx-burst' | 'failed-logins'; severity: number; reason: string; numbers: number[] }

export const TH = { spikeRatio: 2, spikeMinAvg: 1_000_000, bigMin: 5_000_000, bigShare: 0.5, burstVsMedian: 3, burstMin: 150, failed: 10 };

export function detect(users: UserActivity[], now: string): { flags: Flag[]; median: number; day: number; dim: number } {
  const month = monthOf(now);
  const day = Number(new Date(vnDay(now)).toISOString().slice(8, 10));
  const dim = daysInMonth(month);
  const counts = users.filter((u) => u.role === 'USER').map((u) => u.txCount30d).sort((a, b) => a - b);
  const median = counts.length ? counts[Math.floor(counts.length / 2)] : 0;
  const flags: Flag[] = [];
  for (const u of users) {
    if (u.role !== 'USER') continue;
    const base = { userId: u.id, email: u.email, name: u.name };
    const projected = Math.round((u.expenseThisMonth / day) * dim);
    if (u.expenseAvgPrev3 >= TH.spikeMinAvg && projected >= TH.spikeRatio * u.expenseAvgPrev3) {
      const ratio = Math.round((projected / u.expenseAvgPrev3) * 10) / 10;
      flags.push({ ...base, kind: 'spend-spike', severity: ratio, numbers: [projected, ratio, day],
        reason: `chi ${day} ngày đầu tháng ${money(u.expenseThisMonth)}, nếu giữ nhịp sẽ thành ~${money(projected)} (gấp ${ratio.toLocaleString('vi-VN')} lần TB 3 tháng ${money(u.expenseAvgPrev3)})` });
    }
    if (u.largestExpense30d >= TH.bigMin && u.largestExpense30d >= TH.bigShare * Math.max(u.expenseAvgPrev3, 1)) {
      flags.push({ ...base, kind: 'big-expense', severity: u.largestExpense30d / Math.max(u.expenseAvgPrev3, 1) * 2, numbers: [],
        reason: `một khoản chi ${money(u.largestExpense30d)} trong 30 ngày, lớn so với mức chi TB ${money(u.expenseAvgPrev3)}/tháng` });
    }
    if (median > 0 && u.txCount30d >= TH.burstMin && u.txCount30d >= TH.burstVsMedian * median) {
      const ratio = Math.round((u.txCount30d / median) * 10) / 10;
      flags.push({ ...base, kind: 'tx-burst', severity: ratio, numbers: [median, ratio],
        reason: `${int(u.txCount30d)} giao dịch trong 30 ngày, gấp ${ratio.toLocaleString('vi-VN')} lần trung vị (${int(median)})` });
    }
    if ((u.failedLogins24h ?? 0) >= TH.failed) {
      flags.push({ ...base, kind: 'failed-logins', severity: 10, numbers: [], reason: `${int(u.failedLogins24h!)} lần đăng nhập sai trong 24 giờ` });
    }
  }
  flags.sort((a, b) => b.severity - a.severity);
  return { flags, median, day, dim };
}
