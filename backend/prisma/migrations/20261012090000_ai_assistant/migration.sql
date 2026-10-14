-- CreateEnum
CREATE TYPE "AiScope" AS ENUM ('USER', 'ADMIN');

-- CreateEnum
CREATE TYPE "AiMessageRole" AS ENUM ('USER', 'ASSISTANT');

-- CreateEnum
CREATE TYPE "AiDraftStatus" AS ENUM ('PROPOSED', 'EXECUTING', 'CONFIRMED', 'EDITED', 'CANCELLED');

-- CreateEnum
CREATE TYPE "AiKnowledgeScope" AS ENUM ('USER', 'GLOBAL');

-- CreateEnum
CREATE TYPE "AiKnowledgeStatus" AS ENUM ('PROPOSED', 'ACTIVE', 'REJECTED');

-- CreateTable
CREATE TABLE "AiConversation" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "scope" "AiScope" NOT NULL,
    "title" TEXT,
    "archived" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "AiConversation_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "AiMessage" (
    "id" TEXT NOT NULL,
    "conversationId" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "role" "AiMessageRole" NOT NULL,
    "content" TEXT NOT NULL,
    "skill" TEXT,
    "routeBy" TEXT,
    "status" TEXT NOT NULL DEFAULT 'ok',
    "latencyMs" INTEGER,
    "promptTokens" INTEGER,
    "evalTokens" INTEGER,
    "meta" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "AiMessage_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "AiDraft" (
    "id" TEXT NOT NULL,
    "messageId" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "skill" TEXT NOT NULL,
    "kind" TEXT NOT NULL,
    "payload" JSONB NOT NULL,
    "status" "AiDraftStatus" NOT NULL DEFAULT 'PROPOSED',
    "finalPayload" JSONB,
    "result" JSONB,
    "resolvedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "AiDraft_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "AiFeedback" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "messageId" TEXT NOT NULL,
    "kind" TEXT NOT NULL,
    "skill" TEXT,
    "outcome" TEXT,
    "fromSkill" TEXT,
    "toSkill" TEXT,
    "rating" INTEGER,
    "diff" JSONB,
    "comment" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "AiFeedback_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "AiMemory" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "key" TEXT NOT NULL,
    "value" TEXT NOT NULL,
    "helpful" INTEGER NOT NULL DEFAULT 0,
    "harmful" INTEGER NOT NULL DEFAULT 0,
    "source" TEXT NOT NULL,
    "lastUsedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "AiMemory_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "AiExample" (
    "id" TEXT NOT NULL,
    "scope" "AiKnowledgeScope" NOT NULL,
    "userId" TEXT,
    "ownerKey" TEXT NOT NULL,
    "skill" TEXT NOT NULL,
    "input" TEXT NOT NULL,
    "inputNorm" TEXT NOT NULL,
    "output" JSONB NOT NULL,
    "embedding" BYTEA,
    "embedModel" TEXT,
    "confirmations" INTEGER NOT NULL DEFAULT 1,
    "userCount" INTEGER NOT NULL DEFAULT 1,
    "status" "AiKnowledgeStatus" NOT NULL DEFAULT 'ACTIVE',
    "approvedById" TEXT,
    "approvedAt" TIMESTAMP(3),
    "evalReport" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "AiExample_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "AiRule" (
    "id" TEXT NOT NULL,
    "scope" "AiKnowledgeScope" NOT NULL,
    "userId" TEXT,
    "ownerKey" TEXT NOT NULL,
    "skill" TEXT NOT NULL,
    "kind" TEXT NOT NULL,
    "pattern" TEXT NOT NULL,
    "value" TEXT NOT NULL,
    "support" INTEGER NOT NULL DEFAULT 0,
    "helpful" INTEGER NOT NULL DEFAULT 0,
    "harmful" INTEGER NOT NULL DEFAULT 0,
    "userCount" INTEGER NOT NULL DEFAULT 1,
    "precision" DOUBLE PRECISION,
    "status" "AiKnowledgeStatus" NOT NULL DEFAULT 'PROPOSED',
    "approvedById" TEXT,
    "approvedAt" TIMESTAMP(3),
    "evalReport" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "AiRule_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "AiEvalCase" (
    "id" TEXT NOT NULL,
    "skill" TEXT NOT NULL,
    "input" TEXT NOT NULL,
    "inputNorm" TEXT NOT NULL,
    "expected" JSONB NOT NULL,
    "source" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "AiEvalCase_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "AiLearningRun" (
    "id" TEXT NOT NULL,
    "trigger" TEXT NOT NULL,
    "startedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "finishedAt" TIMESTAMP(3),
    "stats" JSONB,
    "error" TEXT,

    CONSTRAINT "AiLearningRun_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "AiConversation_userId_updatedAt_idx" ON "AiConversation"("userId", "updatedAt");

-- CreateIndex
CREATE INDEX "AiMessage_conversationId_createdAt_idx" ON "AiMessage"("conversationId", "createdAt");

-- CreateIndex
CREATE INDEX "AiMessage_userId_role_createdAt_idx" ON "AiMessage"("userId", "role", "createdAt");

-- CreateIndex
CREATE INDEX "AiMessage_skill_createdAt_idx" ON "AiMessage"("skill", "createdAt");

-- CreateIndex
CREATE UNIQUE INDEX "AiDraft_messageId_key" ON "AiDraft"("messageId");

-- CreateIndex
CREATE INDEX "AiDraft_userId_status_idx" ON "AiDraft"("userId", "status");

-- CreateIndex
CREATE INDEX "AiDraft_skill_status_createdAt_idx" ON "AiDraft"("skill", "status", "createdAt");

-- CreateIndex
CREATE INDEX "AiFeedback_userId_createdAt_idx" ON "AiFeedback"("userId", "createdAt");

-- CreateIndex
CREATE INDEX "AiFeedback_kind_createdAt_idx" ON "AiFeedback"("kind", "createdAt");

-- CreateIndex
CREATE UNIQUE INDEX "AiFeedback_messageId_kind_key" ON "AiFeedback"("messageId", "kind");

-- CreateIndex
CREATE UNIQUE INDEX "AiMemory_userId_key_key" ON "AiMemory"("userId", "key");

-- CreateIndex
CREATE INDEX "AiExample_scope_skill_status_idx" ON "AiExample"("scope", "skill", "status");

-- CreateIndex
CREATE UNIQUE INDEX "AiExample_ownerKey_skill_inputNorm_key" ON "AiExample"("ownerKey", "skill", "inputNorm");

-- CreateIndex
CREATE INDEX "AiRule_scope_kind_status_idx" ON "AiRule"("scope", "kind", "status");

-- CreateIndex
CREATE UNIQUE INDEX "AiRule_ownerKey_kind_pattern_value_key" ON "AiRule"("ownerKey", "kind", "pattern", "value");

-- CreateIndex
CREATE UNIQUE INDEX "AiEvalCase_skill_inputNorm_key" ON "AiEvalCase"("skill", "inputNorm");

-- AddForeignKey
ALTER TABLE "AiConversation" ADD CONSTRAINT "AiConversation_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "AiMessage" ADD CONSTRAINT "AiMessage_conversationId_fkey" FOREIGN KEY ("conversationId") REFERENCES "AiConversation"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "AiMessage" ADD CONSTRAINT "AiMessage_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "AiDraft" ADD CONSTRAINT "AiDraft_messageId_fkey" FOREIGN KEY ("messageId") REFERENCES "AiMessage"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "AiDraft" ADD CONSTRAINT "AiDraft_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "AiFeedback" ADD CONSTRAINT "AiFeedback_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "AiFeedback" ADD CONSTRAINT "AiFeedback_messageId_fkey" FOREIGN KEY ("messageId") REFERENCES "AiMessage"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "AiMemory" ADD CONSTRAINT "AiMemory_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "AiExample" ADD CONSTRAINT "AiExample_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "AiRule" ADD CONSTRAINT "AiRule_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;
