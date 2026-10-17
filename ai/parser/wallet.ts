import { fold } from '../lib/text.js';
import type { Span } from './money.js';

export interface WalletSpan extends Span { walletName: string }

// Biệt danh phổ biến cho ví/ngân hàng VN; ví nào user không có thì bỏ qua.
const ALIASES: Record<string, string[]> = {
  momo: ['momo', 'vi momo'],
  'mb bank': ['mb bank', 'mbbank', 'mb'],
  techcombank: ['techcombank', 'techcom', 'tcb'],
  'tien mat': ['tien mat', 'cash'],
  vietcombank: ['vietcombank', 'vcb'],
  zalopay: ['zalopay', 'zalo pay'],
};

export function findWallets(f: string, wallets: { name: string }[]): WalletSpan[] {
  const out: WalletSpan[] = [];
  for (const w of wallets) {
    const key = fold(w.name);
    const names = [...new Set([key, key.replace(/\s+/g, ''), ...(ALIASES[key] ?? [])])].sort((a, b) => b.length - a.length);
    const re = new RegExp(String.raw`(?:\b(?:tra|thanh toan|ck|chuyen khoan|quet the|quet|bang|qua|vao|tu|the)\s+)*\b(?:${names.join('|')})\b`, 'g');
    for (const m of f.matchAll(re)) out.push({ start: m.index!, end: m.index! + m[0].length, walletName: w.name });
  }
  return out.sort((a, b) => a.start - b.start);
}
