-- AlterTable
ALTER TABLE "AiConversation" ADD COLUMN     "pinned" BOOLEAN NOT NULL DEFAULT false;

-- CreateTable
CREATE TABLE "LoginFailure" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "ip" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "LoginFailure_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "AiUserSetting" (
    "userId" TEXT NOT NULL,
    "shareExamples" BOOLEAN NOT NULL DEFAULT false,
    "consentedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "AiUserSetting_pkey" PRIMARY KEY ("userId")
);

-- CreateIndex
CREATE INDEX "LoginFailure_userId_createdAt_idx" ON "LoginFailure"("userId", "createdAt");

-- CreateIndex
CREATE INDEX "LoginFailure_createdAt_idx" ON "LoginFailure"("createdAt");

-- AddForeignKey
ALTER TABLE "LoginFailure" ADD CONSTRAINT "LoginFailure_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "AiUserSetting" ADD CONSTRAINT "AiUserSetting_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;
