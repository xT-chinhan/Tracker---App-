-- CreateTable
CREATE TABLE "SystemSetting" (
    "key" TEXT NOT NULL,
    "value" JSONB NOT NULL,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "updatedById" TEXT,
    "updatedByName" TEXT,

    CONSTRAINT "SystemSetting_pkey" PRIMARY KEY ("key")
);

-- CreateTable
CREATE TABLE "SystemConfigChange" (
    "id" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "actorId" TEXT,
    "actorName" TEXT,
    "actorEmail" TEXT,
    "section" TEXT NOT NULL,
    "key" TEXT NOT NULL,
    "oldValue" JSONB,
    "newValue" JSONB,
    "secret" BOOLEAN NOT NULL DEFAULT false,

    CONSTRAINT "SystemConfigChange_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "SystemConfigChange_createdAt_idx" ON "SystemConfigChange"("createdAt");

-- CreateIndex
CREATE INDEX "SystemConfigChange_section_createdAt_idx" ON "SystemConfigChange"("section", "createdAt");
