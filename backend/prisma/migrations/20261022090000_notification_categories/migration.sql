-- AlterEnum
-- This migration adds more than one value to an enum.
-- With PostgreSQL versions 11 and earlier, this is not possible
-- in a single migration. This can be worked around by creating
-- multiple migrations, each migration adding only one value to
-- the enum.


ALTER TYPE "NotificationType" ADD VALUE 'BALANCE_CHANGE';
ALTER TYPE "NotificationType" ADD VALUE 'SECURITY';

-- AlterTable
ALTER TABLE "Transaction" ADD COLUMN     "externalRef" TEXT,
ADD COLUMN     "source" TEXT;

-- CreateIndex
CREATE UNIQUE INDEX "Transaction_userId_externalRef_key" ON "Transaction"("userId", "externalRef");

