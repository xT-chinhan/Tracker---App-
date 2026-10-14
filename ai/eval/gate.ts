/**
 * Cổng kiểm định cho vòng học ban đêm: thử MỘT luật hoặc ví dụ đề xuất trên bộ đề hồi quy, so trước/sau.
 * Chỉ chạy model trên các câu mà đề xuất thực sự đổi được (luật khớp khác đi / tập kNN đổi), nên rẻ.
 * Điểm before/after tính trên tập câu bị ảnh hưởng (câu khác giữ nguyên kết quả nên không cần chạy).
 *
 *   import { evaluateRule } from 'ai/eval/gate';
 *   const r = await evaluateRule({ kind: 'rule', key: 'trà đá', categoryName: 'Ăn uống' }, { ctx, cases, bank, rules });
 *   if (r.pass) rules.pin('trà đá', 'Ăn uống');
 */
import type { GhiCase, UserContext } from '../lib/types.js';
import type { Example, ExampleBank, RuleBook } from '../learn/store.js';
import { analyze } from '../parser/index.js';
import { runGhi } from '../skills/ghi-giao-dich/pipeline.js';
import { scoreCase } from './score.js';

export type Proposal =
  | { kind: 'rule'; key: string; categoryName: string } // key: bigram CÒN DẤU như RuleBook (vd. "trà đá"), hoặc 1 âm tiết ("grab")
  | { kind: 'example'; example: Example }; // ví dụ mới cho kho kNN

export interface GateOptions {
  ctx: UserContext; // danh mục/ví của user (hoặc user mẫu khi kiểm luật chung)
  cases: GhiCase[]; // bộ đề hồi quy có nhãn (vd. ai/eval/data/ghi.dev.json + câu user đã xác nhận)
  bank: ExampleBank; // kho hiện tại (không bị sửa)
  rules: RuleBook; // sổ luật hiện tại (không bị sửa)
  maxRegressions?: number; // số khoản được phép từ đúng → sai (mặc định 0)
  minGain?: number; // số khoản tối thiểu phải từ sai → đúng (mặc định 0; đặt 1 nếu muốn đề xuất phải có ích)
}

export interface GateScore { cases: number; items: number; itemsExact: number; accepted: number }
export interface GateResult {
  pass: boolean;
  reason: string;
  affected: string[]; // id câu bị ảnh hưởng
  before: GateScore; // trên các câu bị ảnh hưởng
  after: GateScore;
  regressions: string[]; // "id: text" khoản đúng → sai
  fixes: string[]; // khoản sai → đúng
}

export async function evaluateRule(p: Proposal, o: GateOptions): Promise<GateResult> {
  const rulesAfter = o.rules.clone();
  const bankAfter = o.bank.clone();
  if (p.kind === 'rule') rulesAfter.pin(p.key, p.categoryName);
  else await bankAfter.add(p.example);

  // câu nào có thể đổi kết quả?
  const affected: GhiCase[] = [];
  for (const c of o.cases) {
    const { segs } = analyze(c.text, o.ctx);
    let hit = false;
    for (const s of segs) {
      if (p.kind === 'rule') {
        const a = o.rules.match(s), b = rulesAfter.match(s);
        if (a?.key !== b?.key || a?.categoryName !== b?.categoryName) hit = true;
      } else {
        const a = await o.bank.nearest(s.clean || s.text, 5), b = await bankAfter.nearest(s.clean || s.text, 5);
        if (a.length !== b.length || a.some((x, i) => x.e !== b[i].e)) hit = true;
      }
    }
    if (hit) affected.push(c);
  }

  const score = async (bank: ExampleBank, rules: RuleBook) => {
    const s: GateScore = { cases: affected.length, items: 0, itemsExact: 0, accepted: 0 };
    const flags: boolean[][] = [];
    for (const c of affected) {
      const sc = scoreCase(c, await runGhi(c.text, o.ctx, { variant: 'V4', bank, rules }));
      s.items += sc.items; s.itemsExact += sc.itemsExact; s.accepted += sc.accept ? 1 : 0;
      flags.push(sc.itemOk.length ? sc.itemOk : [sc.ok]);
    }
    return { s, flags };
  };
  const A = await score(o.bank, o.rules), B = await score(bankAfter, rulesAfter);
  const regressions: string[] = [], fixes: string[] = [];
  affected.forEach((c, i) => A.flags[i].forEach((ok, j) => {
    if (ok && !B.flags[i][j]) regressions.push(`${c.id}: ${c.text}`);
    if (!ok && B.flags[i][j]) fixes.push(`${c.id}: ${c.text}`);
  }));
  const maxReg = o.maxRegressions ?? 0, minGain = o.minGain ?? 0;
  const pass = regressions.length <= maxReg && fixes.length >= minGain && B.s.itemsExact >= A.s.itemsExact;
  const reason = !affected.length ? 'không câu nào bị ảnh hưởng'
    : pass ? `+${fixes.length} / -${regressions.length} khoản` : `tụt: ${regressions.length} khoản đúng → sai (cho phép ${maxReg}), sửa được ${fixes.length} (cần ${minGain})`;
  return { pass: affected.length ? pass : minGain === 0, reason, affected: affected.map((c) => c.id), before: A.s, after: B.s, regressions, fixes };
}
