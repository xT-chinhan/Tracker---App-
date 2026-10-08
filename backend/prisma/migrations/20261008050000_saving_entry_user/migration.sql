-- DropForeignKey
ALTER TABLE "SavingEntry" DROP CONSTRAINT "SavingEntry_goalId_fkey";

-- AlterTable
ALTER TABLE "SavingEntry" ADD COLUMN     "userId" TEXT,
ALTER COLUMN "goalId" DROP NOT NULL;

-- Backfill: sổ tiết kiệm thuộc user của mục tiêu
UPDATE "SavingEntry" e SET "userId" = g."userId" FROM "SavingGoal" g WHERE g."id" = e."goalId";
ALTER TABLE "SavingEntry" ALTER COLUMN "userId" SET NOT NULL;

-- CreateIndex
CREATE INDEX "SavingEntry_userId_idx" ON "SavingEntry"("userId");

-- AddForeignKey
ALTER TABLE "SavingEntry" ADD CONSTRAINT "SavingEntry_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SavingEntry" ADD CONSTRAINT "SavingEntry_goalId_fkey" FOREIGN KEY ("goalId") REFERENCES "SavingGoal"("id") ON DELETE SET NULL ON UPDATE CASCADE;

