import {
  CanActivate,
  createParamDecorator,
  ExecutionContext,
  ForbiddenException,
  Inject,
  Injectable,
  SetMetadata,
  UnauthorizedException,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { JwtService } from '@nestjs/jwt';
import { Role } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import type { SystemConfigService } from '../system-config/system-config.module';

export interface AuthUser {
  id: string;
  email: string;
  name: string;
  role: Role;
}

const IS_PUBLIC = 'isPublic';
const ROLES = 'roles';
const FEATURE = 'feature';

export const Public = () => SetMetadata(IS_PUBLIC, true);
export const Roles = (...roles: Role[]) => SetMetadata(ROLES, roles);

/** Tính năng app bật/tắt được trong Cấu hình hệ thống. */
export type FeatureName = 'savingGoals' | 'recurring' | 'transfers' | 'csvExport' | 'quickTemplates';
/** Đánh dấu controller/route thuộc 1 tính năng: tắt => route ghi (khác GET) trả 403 FEATURE_DISABLED; `reads: true` => chặn cả GET. */
export const Feature = (name: FeatureName, opts: { reads?: boolean } = {}) => SetMetadata(FEATURE, { name, reads: !!opts.reads });
/** Token DI của SystemConfigService (tránh import vòng giữa common/auth và system-config). */
export const SYSTEM_CONFIG = 'SYSTEM_CONFIG';

export const CurrentUser = createParamDecorator(
  (_: unknown, ctx: ExecutionContext): AuthUser => ctx.switchToHttp().getRequest().user,
);

/**
 * Guard toàn cục: xác thực JWT, chặn user bị khóa, token cũ (tokenVersion lệch), kiểm tra @Roles,
 * chế độ bảo trì (user thường => 503 MAINTENANCE, admin không bị chặn) và tính năng bị tắt (@Feature => 403 FEATURE_DISABLED).
 */
@Injectable()
export class AuthGuard implements CanActivate {
  constructor(
    private readonly reflector: Reflector,
    private readonly jwt: JwtService,
    private readonly prisma: PrismaService,
    @Inject(SYSTEM_CONFIG) private readonly sys: SystemConfigService,
  ) {}

  async canActivate(ctx: ExecutionContext): Promise<boolean> {
    const targets = [ctx.getHandler(), ctx.getClass()];
    if (this.reflector.getAllAndOverride<boolean>(IS_PUBLIC, targets)) return true;

    const req = ctx.switchToHttp().getRequest();
    const [scheme, token] = (req.headers.authorization ?? '').split(' ');
    if (scheme !== 'Bearer' || !token) throw new UnauthorizedException();

    let payload: { sub: string; tv?: number };
    try {
      payload = await this.jwt.verifyAsync(token);
    } catch {
      throw new UnauthorizedException('Token không hợp lệ hoặc đã hết hạn');
    }

    const user = await this.prisma.user.findUnique({
      where: { id: payload.sub },
      select: { id: true, email: true, name: true, role: true, status: true, tokenVersion: true },
    });
    if (!user) throw new UnauthorizedException();
    if (user.status === 'LOCKED') throw new ForbiddenException('Tài khoản đã bị khóa');
    // Token cấp trước khi có tokenVersion không mang tv => coi như 0
    if ((payload.tv ?? 0) !== user.tokenVersion) throw new UnauthorizedException('Phiên đăng nhập đã hết hiệu lực, hãy đăng nhập lại');

    const roles = this.reflector.getAllAndOverride<Role[]>(ROLES, targets);
    if (roles?.length && !roles.includes(user.role)) throw new ForbiddenException();

    await this.sys.assertNotMaintenance(user.role);
    const feature = this.reflector.getAllAndOverride<{ name: FeatureName; reads: boolean } | undefined>(FEATURE, targets);
    if (feature && (feature.reads || req.method !== 'GET')) await this.sys.assertFeature(feature.name);

    req.user = { id: user.id, email: user.email, name: user.name, role: user.role } satisfies AuthUser;
    return true;
  }
}
