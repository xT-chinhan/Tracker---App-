import { PrismaClient, TxType } from '@prisma/client';
import * as bcrypt from 'bcryptjs';

const prisma = new PrismaClient();

const SYSTEM_CATEGORIES: { name: string; type: TxType; icon: string; color: string }[] = [
  { name: 'Lương', type: 'INCOME', icon: 'wallet', color: '#16A34A' },
  { name: 'Thưởng', type: 'INCOME', icon: 'gift', color: '#22C55E' },
  { name: 'Đầu tư', type: 'INCOME', icon: 'chartLine', color: '#0EA5E9' },
  { name: 'Được tặng', type: 'INCOME', icon: 'handHoldingHeart', color: '#EC4899' },
  { name: 'Thu khác', type: 'INCOME', icon: 'ellipsis', color: '#64748B' },
  { name: 'Ăn uống', type: 'EXPENSE', icon: 'mugHot', color: '#F97316' },
  { name: 'Di chuyển', type: 'EXPENSE', icon: 'taxi', color: '#EAB308' },
  { name: 'Mua sắm', type: 'EXPENSE', icon: 'basketShopping', color: '#A855F7' },
  { name: 'Hóa đơn', type: 'EXPENSE', icon: 'bolt', color: '#EF4444' },
  { name: 'Nhà ở', type: 'EXPENSE', icon: 'house', color: '#8B5CF6' },
  { name: 'Sức khỏe', type: 'EXPENSE', icon: 'heartPulse', color: '#F43F5E' },
  { name: 'Giáo dục', type: 'EXPENSE', icon: 'graduationCap', color: '#3B82F6' },
  { name: 'Giải trí', type: 'EXPENSE', icon: 'gamepad', color: '#14B8A6' },
  { name: 'Chi khác', type: 'EXPENSE', icon: 'ellipsis', color: '#64748B' },
];

async function main() {
  for (const c of SYSTEM_CATEGORIES) {
    const exists = await prisma.category.findFirst({
      where: { userId: null, name: c.name, type: c.type },
    });
    if (!exists) await prisma.category.create({ data: c });
  }

  const email = process.env.ADMIN_EMAIL;
  const password = process.env.ADMIN_PASSWORD;
  if (email && password) {
    await prisma.user.upsert({
      where: { email },
      update: { role: 'ADMIN' },
      create: {
        email,
        name: 'Administrator',
        role: 'ADMIN',
        passwordHash: await bcrypt.hash(password, 10),
      },
    });
  }

  console.log(`Seeded ${SYSTEM_CATEGORIES.length} system categories, admin: ${email ?? '(skipped)'}`);
}

main().finally(() => prisma.$disconnect());
