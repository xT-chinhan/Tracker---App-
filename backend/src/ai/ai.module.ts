/**
 * Trợ lý AI (API). Người dùng và admin dùng chung `/ai/*` (phạm vi hội thoại theo role); admin có thêm `/admin/ai/*` (trung tâm học).
 * Thiết kế cô lập, vòng học, cấu hình: xem backend/README.md mục "Trợ lý AI".
 */
import { Body, Controller, Delete, Get, HttpCode, HttpException, Module, NotFoundException, Param, ParseUUIDPipe, Patch, Post, Put, Query, Req, Res } from '@nestjs/common';
import { ApiBearerAuth, ApiProduces, ApiTags } from '@nestjs/swagger';
import { Transform, Type } from 'class-transformer';
import { IsBoolean, IsDateString, IsEnum, IsIn, IsInt, IsObject, IsOptional, IsString, Max, MaxLength, Min, MinLength } from 'class-validator';
import { AiKnowledgeStatus } from '@prisma/client';
import type { Request, Response } from 'express';
import { AuthUser, CurrentUser, Feature, Roles } from '../common/auth';
import { PageQuery, Trim } from '../common/dto';
import { TransactionsModule } from '../transactions/transactions.module';
import { BudgetsModule } from '../budgets/budgets.module';
import { AdminModule } from '../admin/admin.module';
import { CategoriesModule } from '../categories/categories.module';
import { WalletsModule } from '../wallets/wallets.module';
import { StatsModule } from '../stats/stats.module';
import { SavingGoalsModule } from '../saving-goals/saving-goals.module';
import { AiAdminService } from './ai.admin';
import { AiContextService } from './ai.context';
import { DraftKinds } from './ai.drafts';
import { AiLearningService } from './ai.learning';
import { AiRouter } from './ai.router';
import { AiLlmFactory, AiService, messageView } from './ai.service';
import { SkillRegistry } from './ai.skills';
import { AiStore } from './ai.store';

/* ============================== DTO ============================== */

class ConversationQuery extends PageQuery {
  /** true = danh sách đã lưu trữ */
  @IsOptional() @Transform(({ value }) => value === true || value === 'true') @IsBoolean() archived?: boolean;
}

class CreateConversationDto {
  @IsOptional() @Trim() @IsString() @MaxLength(120) title?: string;
}

class UpdateConversationDto {
  @IsOptional() @Trim() @IsString() @MinLength(1) @MaxLength(120) title?: string;
  @IsOptional() @IsBoolean() archived?: boolean;
  /** Ghim: không bị tự lưu trữ khi đạt giới hạn số hội thoại */
  @IsOptional() @IsBoolean() pinned?: boolean;
}

class AiSettingsDto {
  /** Đồng ý góp ví dụ đã ẩn danh vào kho chung (lưu thời điểm đồng ý; tắt bất cứ lúc nào) */
  @IsBoolean() shareExamples: boolean;
}

class RetentionQuery {
  /** Mốc "bây giờ" (dev/test) */
  @IsOptional() @IsDateString() now?: string;
}

class PostMessageDto {
  /** Câu của người dùng (1–2000 ký tự) */
  @Trim() @IsString() @MinLength(1) @MaxLength(2000) text: string;
}

class ConfirmDraftDto {
  /** Bản đã sửa (cùng dạng `payload` của nháp). Bỏ trống = xác nhận nguyên nháp */
  @IsOptional() @IsObject() payload?: Record<string, unknown>;
}

class FeedbackDto {
  /** 1 = thích, -1 = không thích */
  @Type(() => Number) @IsIn([1, -1]) rating: number;
  @IsOptional() @Trim() @IsString() @MaxLength(500) comment?: string;
}

class RerouteDto {
  /** Tên skill đúng ý người dùng (xem GET /ai/skills) */
  @Trim() @IsString() @MinLength(1) @MaxLength(60) skill: string;
}

class StatsQuery {
  @IsOptional() @Type(() => Number) @IsInt() @Min(1) @Max(365) days: number = 30;
}

class KnowledgeQuery extends PageQuery {
  @IsOptional() @IsEnum(AiKnowledgeStatus) status?: AiKnowledgeStatus;
  @IsOptional() @IsString() @MaxLength(60) skill?: string;
  /** Lọc theo pattern (luật) / input (ví dụ) */
  @IsOptional() @Trim() @IsString() @MaxLength(100) q?: string;
}

class UsageQuery extends PageQuery {
  /** Lọc theo email / tên */
  @IsOptional() @Trim() @IsString() @MaxLength(100) q?: string;
}

class OllamaTestDto {
  /** Bỏ trống = dùng cấu hình đã lưu (cho phép thử địa chỉ / model đang sửa trước khi lưu) */
  @IsOptional() @Trim() @IsString() @MaxLength(300) url?: string;
  @IsOptional() @Trim() @IsString() @MaxLength(100) chatModel?: string;
  @IsOptional() @Trim() @IsString() @MaxLength(100) embedModel?: string;
}

class RunsQuery {
  @IsOptional() @Type(() => Number) @IsInt() @Min(1) @Max(100) limit: number = 20;
}

/** Chế độ debug (trả context + prompt đã dùng) chỉ khi không phải production và có header `x-ai-debug: 1`. */
const debugOf = (req: Request) => process.env.NODE_ENV !== 'production' && req.headers['x-ai-debug'] === '1';

/** 429 hạn mức ngày → thêm header Retry-After như các 429 khác của API. */
async function retryAfter<T>(res: Response, fn: () => Promise<T>): Promise<T> {
  try {
    return await fn();
  } catch (e) {
    if (e instanceof HttpException && e.getStatus() === 429) {
      const s = (e.getResponse() as { retryAfterSeconds?: number }).retryAfterSeconds;
      if (s) res.setHeader('Retry-After', String(s));
    }
    throw e;
  }
}

/* ============================== Controller người dùng + admin ============================== */

@ApiTags('ai')
@ApiBearerAuth()
/** Tắt (ai.enabled = false hoặc business.featureAi = false) => route ghi 403 FEATURE_DISABLED, đọc vẫn được */
@Feature('ai')
@Controller('ai')
export class AiController {
  constructor(private readonly ai: AiService) {}

  /** Hội thoại của chính mình (mới cập nhật trước) */
  @Get('conversations')
  list(@CurrentUser() u: AuthUser, @Query() q: ConversationQuery) {
    return this.ai.list(u, q);
  }

  /** Tạo hội thoại; phạm vi USER/ADMIN theo role. Đạt `ai.maxConversationsPerUser` → tự lưu trữ cuộc cũ nhất chưa ghim (`autoArchived`); mọi cuộc đều ghim → 409 AI_CONVERSATION_LIMIT */
  @Post('conversations')
  create(@CurrentUser() u: AuthUser, @Body() dto: CreateConversationDto) {
    return this.ai.create(u, dto.title);
  }

  /** Chi tiết + toàn bộ tin nhắn (kèm nháp) */
  @Get('conversations/:id')
  get(@CurrentUser() u: AuthUser, @Param('id', ParseUUIDPipe) id: string) {
    return this.ai.get(u, id);
  }

  /** Đổi tên / lưu trữ / khôi phục / ghim */
  @Patch('conversations/:id')
  update(@CurrentUser() u: AuthUser, @Param('id', ParseUUIDPipe) id: string, @Body() dto: UpdateConversationDto) {
    return this.ai.update(u, id, dto);
  }

  @Delete('conversations/:id') @HttpCode(204)
  remove(@CurrentUser() u: AuthUser, @Param('id', ParseUUIDPipe) id: string) {
    return this.ai.remove(u, id);
  }

  /** Gửi tin → `{userMessage, message, draft}`. Quá hạn mức ngày => 429 AI_DAILY_LIMIT (+ Retry-After) */
  @Post('conversations/:id/messages')
  async post(@CurrentUser() u: AuthUser, @Param('id', ParseUUIDPipe) id: string, @Body() dto: PostMessageDto, @Req() req: Request, @Res({ passthrough: true }) res: Response) {
    return retryAfter(res, () => this.ai.post(u, id, dto.text, { debug: debugOf(req) }));
  }

  /**
   * Như trên nhưng trả Server-Sent Events: `user` (tin đã lưu) → `route` ({skill, by}) → `delta` ({text}, nhiều lần) → `done` ({message, draft}) | `error`.
   * Lỗi kiểm tra trước (404 / 409 / 429) vẫn trả JSON + mã HTTP như bản thường.
   */
  @Post('conversations/:id/messages/stream') @ApiProduces('text/event-stream')
  async stream(@CurrentUser() u: AuthUser, @Param('id', ParseUUIDPipe) id: string, @Body() dto: PostMessageDto, @Req() req: Request, @Res() res: Response) {
    const { repo, conv, userMessage } = await retryAfter(res, () => this.ai.accept(u, id, dto.text));
    res.status(200).set({ 'content-type': 'text/event-stream; charset=utf-8', 'cache-control': 'no-cache', connection: 'keep-alive', 'x-accel-buffering': 'no' });
    res.flushHeaders();
    const send = (event: string, data: unknown) => res.write(`event: ${event}\ndata: ${JSON.stringify(data)}\n\n`);
    send('user', messageView(userMessage));
    try {
      const out = await this.ai.answer(repo, conv, dto.text, { debug: debugOf(req), onEvent: send });
      for (const chunk of out.message.content.match(/\S+\s*/g) ?? []) send('delta', { text: chunk });
      send('done', out);
    } catch (e) {
      send('error', { message: (e as Error).message });
    }
    res.end();
  }

  /** Xác nhận nháp (tùy chọn kèm bản sửa) → thực thi qua API nghiệp vụ thường. Xác nhận lặp => trả lại kết quả cũ (`idempotent: true`) */
  @Post('drafts/:id/confirm') @HttpCode(200)
  confirm(@CurrentUser() u: AuthUser, @Param('id', ParseUUIDPipe) id: string, @Body() dto: ConfirmDraftDto) {
    return this.ai.confirm(u, id, dto.payload);
  }

  @Post('drafts/:id/cancel') @HttpCode(200)
  cancel(@CurrentUser() u: AuthUser, @Param('id', ParseUUIDPipe) id: string) {
    return this.ai.cancel(u, id);
  }

  /** Thích / không thích một câu trả lời (ghi đè lần trước) */
  @Post('messages/:id/feedback') @HttpCode(200)
  feedback(@CurrentUser() u: AuthUser, @Param('id', ParseUUIDPipe) id: string, @Body() dto: FeedbackDto) {
    return this.ai.feedback(u, id, dto);
  }

  /** "Ý tôi là…": trả lời lại câu trước bằng skill được chọn + học định tuyến cho chính user. Skill admin với user thường => 403 */
  @Post('messages/:id/reroute')
  reroute(@CurrentUser() u: AuthUser, @Param('id', ParseUUIDPipe) id: string, @Body() dto: RerouteDto, @Req() req: Request) {
    return this.ai.reroute(u, id, dto.skill, { debug: debugOf(req) });
  }

  /** Skill dùng được (cho menu "Ý tôi là…") */
  @Get('skills')
  skills(@CurrentUser() u: AuthUser) {
    return this.ai.skillsFor(u);
  }

  /** Trí nhớ AI về chính mình (ví hay dùng…) */
  @Get('memory')
  memory(@CurrentUser() u: AuthUser) {
    return this.ai.memory(u);
  }

  @Delete('memory/:id') @HttpCode(204)
  deleteMemory(@CurrentUser() u: AuthUser, @Param('id', ParseUUIDPipe) id: string) {
    return this.ai.deleteMemory(u, id);
  }

  /** Cài đặt AI của mình: `{shareExamples, consentedAt, asked}` (asked = đã từng trả lời câu hỏi đồng ý) */
  @Get('settings')
  settings(@CurrentUser() u: AuthUser) {
    return this.ai.settings(u);
  }

  /** Bật / tắt góp ví dụ ẩn danh vào kho chung. Chưa đồng ý → dữ liệu của mình không dùng cho học chung */
  @Put('settings')
  setSettings(@CurrentUser() u: AuthUser, @Body() dto: AiSettingsDto) {
    return this.ai.setSettings(u, dto.shareExamples);
  }

  /** Số tin hôm nay / hạn mức, số hội thoại / tối đa */
  @Get('usage')
  usage(@CurrentUser() u: AuthUser) {
    return this.ai.usage(u);
  }
}

@ApiTags('admin ai')
@ApiBearerAuth()
@Roles('ADMIN')
@Controller('admin/ai')
export class AiAdminController {
  constructor(private readonly admin: AiAdminService) {}

  /** Theo skill: số tin, độ trễ, lỗi, tỉ lệ chấp nhận nháp không sửa; theo ngày; lượng dùng */
  @Get('stats')
  stats(@Query() q: StatsQuery) {
    return this.admin.stats(q.days);
  }

  /** Luật CHUNG (đề xuất / đang bật / bị loại) kèm kết quả kiểm định */
  @Get('rules')
  rules(@Query() q: KnowledgeQuery) {
    return this.admin.rules(q);
  }

  @Post('rules/:id/approve') @HttpCode(200)
  approveRule(@CurrentUser() u: AuthUser, @Param('id', ParseUUIDPipe) id: string) {
    return this.admin.decideRule(u, id, true);
  }

  @Post('rules/:id/reject') @HttpCode(200)
  rejectRule(@CurrentUser() u: AuthUser, @Param('id', ParseUUIDPipe) id: string) {
    return this.admin.decideRule(u, id, false);
  }

  /** Ví dụ CHUNG (đã ẩn danh) */
  @Get('examples')
  examples(@Query() q: KnowledgeQuery) {
    return this.admin.examples(q);
  }

  @Post('examples/:id/approve') @HttpCode(200)
  approveExample(@CurrentUser() u: AuthUser, @Param('id', ParseUUIDPipe) id: string) {
    return this.admin.decideExample(u, id, true);
  }

  @Post('examples/:id/reject') @HttpCode(200)
  rejectExample(@CurrentUser() u: AuthUser, @Param('id', ParseUUIDPipe) id: string) {
    return this.admin.decideExample(u, id, false);
  }

  /** Chỉ dev/test (production => 404): chạy ngay chu trình học ban đêm */
  @Post('learning/run') @HttpCode(200)
  run() {
    if (process.env.NODE_ENV === 'production') throw new NotFoundException();
    return this.admin.runLearning('manual');
  }

  /** Chỉ dev/test (production => 404): chạy ngay dọn lịch sử chat > 12 tháng (cron hằng ngày 03:20 giờ VN) */
  @Post('retention/run') @HttpCode(200)
  retention(@Query() q: RetentionQuery) {
    if (process.env.NODE_ENV === 'production') throw new NotFoundException();
    return this.admin.retention(q.now ? new Date(q.now) : new Date());
  }

  /** Kiểm tra kết nối Ollama: gọi `/api/tags`, báo độ trễ + model trả lời / embedding đã tải chưa */
  @Post('ollama/test') @HttpCode(200)
  ollamaTest(@Body() dto: OllamaTestDto) {
    return this.admin.ollamaTest(dto);
  }

  @Get('learning/runs')
  runs(@Query() q: RunsQuery) {
    return this.admin.runs(q.limit);
  }

  /** Mức dùng AI theo user — chỉ số đếm, không bao giờ có nội dung tin nhắn */
  @Get('usage')
  usage(@Query() q: UsageQuery) {
    return this.admin.usage(q);
  }

  /** Số dòng dữ liệu AI theo userId (cả khi user đã xóa: kiểm chứng xóa dây chuyền) */
  @Get('usage/:userId')
  usageOf(@Param('userId', ParseUUIDPipe) userId: string) {
    return this.admin.usageOf(userId);
  }

  /** Bất biến ẩn danh: dữ liệu chung không gắn userId nào */
  @Get('integrity')
  integrity() {
    return this.admin.globalIntegrity();
  }
}

@Module({
  imports: [TransactionsModule, BudgetsModule, AdminModule, CategoriesModule, WalletsModule, StatsModule, SavingGoalsModule],
  controllers: [AiController, AiAdminController],
  providers: [AiStore, AiContextService, DraftKinds, AiLearningService, AiRouter, SkillRegistry, AiLlmFactory, AiService, AiAdminService],
})
export class AiModule {}
