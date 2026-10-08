import { Transform, Type } from 'class-transformer';
import { IsDateString, IsInt, IsOptional, Matches, Max, Min } from 'class-validator';
import { MONTH_REGEX } from './time';

export class PageQuery {
  @IsOptional() @Type(() => Number) @IsInt() @Min(1)
  page: number = 1;

  @IsOptional() @Type(() => Number) @IsInt() @Min(1) @Max(200)
  limit: number = 20;
}

export class RangeQuery {
  /** Tháng dạng YYYY-MM (ưu tiên hơn from/to) */
  @IsOptional() @Matches(MONTH_REGEX)
  month?: string;

  @IsOptional() @IsDateString()
  from?: string;

  @IsOptional() @IsDateString()
  to?: string;
}

/** Cắt khoảng trắng 2 đầu trước khi validate (chặn tên toàn dấu cách). */
export const Trim = () => Transform(({ value }) => (typeof value === 'string' ? value.trim() : value));

export function paged<T>(items: T[], total: number, q: PageQuery) {
  return { items, total, page: q.page, limit: q.limit };
}

/** Giới hạn số tiền (VND): 1 đến 10 nghìn tỷ. */
export const MAX_AMOUNT = 10_000_000_000_000;
