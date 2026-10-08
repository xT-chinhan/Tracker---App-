import { ArgumentsHost, Catch, ConflictException, ExceptionFilter, NotFoundException } from '@nestjs/common';
import { BaseExceptionFilter } from '@nestjs/core';
import { Prisma } from '@prisma/client';

@Catch(Prisma.PrismaClientKnownRequestError)
export class PrismaExceptionFilter extends BaseExceptionFilter implements ExceptionFilter {
  catch(e: Prisma.PrismaClientKnownRequestError, host: ArgumentsHost) {
    if (e.code === 'P2002') return super.catch(new ConflictException('Dữ liệu đã tồn tại'), host);
    if (e.code === 'P2025') return super.catch(new NotFoundException(), host);
    if (e.code === 'P2003') return super.catch(new ConflictException('Dữ liệu đang được tham chiếu'), host);
    return super.catch(e, host);
  }
}
