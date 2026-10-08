import { BadRequestException, Body, ConflictException, Controller, ForbiddenException, Get, HttpCode, Injectable, Module, Patch, Post, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { IsEmail, IsString, MaxLength, MinLength } from 'class-validator';
import * as bcrypt from 'bcryptjs';
import { User } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { AuthUser, CurrentUser, Public } from '../common/auth';
import { Trim } from '../common/dto';

class RegisterDto {
  @IsEmail() email: string;
  @IsString() @MinLength(6) @MaxLength(72) password: string;
  @Trim() @IsString() @MinLength(1) @MaxLength(100) name: string;
}

class LoginDto {
  @IsEmail() email: string;
  @IsString() password: string;
}

class UpdateProfileDto {
  @Trim() @IsString() @MinLength(1) @MaxLength(100) name: string;
}

class ChangePasswordDto {
  @IsString() currentPassword: string;
  @IsString() @MinLength(6) @MaxLength(72) newPassword: string;
}

export function publicUser<T extends { passwordHash: string }>(u: T): Omit<T, 'passwordHash'> {
  const { passwordHash, ...rest } = u;
  return rest;
}

@Injectable()
export class AuthService {
  constructor(private readonly prisma: PrismaService, private readonly jwt: JwtService) {}

  async register(dto: RegisterDto) {
    const email = dto.email.toLowerCase().trim();
    if (await this.prisma.user.findUnique({ where: { email } })) {
      throw new ConflictException('Email đã được sử dụng');
    }
    const user = await this.prisma.user.create({
      data: { email, name: dto.name.trim(), passwordHash: await bcrypt.hash(dto.password, 10) },
    });
    return this.issue(user);
  }

  async login(dto: LoginDto) {
    const user = await this.prisma.user.findUnique({ where: { email: dto.email.toLowerCase().trim() } });
    if (!user || !(await bcrypt.compare(dto.password, user.passwordHash))) {
      throw new UnauthorizedException('Email hoặc mật khẩu không đúng');
    }
    if (user.status === 'LOCKED') throw new ForbiddenException('Tài khoản đã bị khóa');
    return this.issue(user);
  }

  async me(userId: string) {
    return publicUser(await this.prisma.user.findUniqueOrThrow({ where: { id: userId } }));
  }

  async updateProfile(userId: string, dto: UpdateProfileDto) {
    return publicUser(await this.prisma.user.update({ where: { id: userId }, data: { name: dto.name.trim() } }));
  }

  async changePassword(userId: string, dto: ChangePasswordDto) {
    const user = await this.prisma.user.findUniqueOrThrow({ where: { id: userId } });
    if (!(await bcrypt.compare(dto.currentPassword, user.passwordHash))) {
      throw new BadRequestException('Mật khẩu hiện tại không đúng');
    }
    await this.prisma.user.update({
      where: { id: userId },
      data: { passwordHash: await bcrypt.hash(dto.newPassword, 10) },
    });
  }

  private async issue(user: User) {
    return {
      accessToken: await this.jwt.signAsync({ sub: user.id, role: user.role }),
      user: publicUser(user),
    };
  }
}

@ApiTags('auth')
@Controller()
export class AuthController {
  constructor(private readonly auth: AuthService) {}

  @Public() @Post('auth/register')
  register(@Body() dto: RegisterDto) {
    return this.auth.register(dto);
  }

  @Public() @Post('auth/login') @HttpCode(200)
  login(@Body() dto: LoginDto) {
    return this.auth.login(dto);
  }

  @ApiBearerAuth() @Get('me')
  me(@CurrentUser() u: AuthUser) {
    return this.auth.me(u.id);
  }

  @ApiBearerAuth() @Patch('me')
  updateProfile(@CurrentUser() u: AuthUser, @Body() dto: UpdateProfileDto) {
    return this.auth.updateProfile(u.id, dto);
  }

  @ApiBearerAuth() @Post('me/password') @HttpCode(204)
  changePassword(@CurrentUser() u: AuthUser, @Body() dto: ChangePasswordDto) {
    return this.auth.changePassword(u.id, dto);
  }
}

@Module({ controllers: [AuthController], providers: [AuthService] })
export class AuthModule {}
