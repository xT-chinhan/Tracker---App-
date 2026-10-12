import type { SkillDef } from '../../lib/contracts.js';
import { answerFaq, type FaqEntry } from '../../lib/faq.js';
import { userGuard } from '../../lib/skillkit.js';
import FAQ from './faq.json' with { type: 'json' };

const faq = FAQ as FaqEntry[];
export const skill: SkillDef = {
  name: 'huong-dan', scope: 'USER', output: 'text', providers: [],
  plan: () => [],
  async run({ input, context, llm }) {
    const g = userGuard(input, context.principal); if (g) return g;
    return answerFaq(input, faq, llm, 'Mình chưa có hướng dẫn cho việc này. Bạn có thể hỏi về: ghi giao dịch, ví, chuyển tiền, ngân sách, tiết kiệm, định kỳ, báo cáo, xuất CSV, mật khẩu.', faq.map((e) => e.title));
  },
};
export const run = skill.run;
