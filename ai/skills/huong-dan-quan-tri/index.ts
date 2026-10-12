import type { Skill } from '../../lib/contracts.js';
import { answerFaq, type FaqEntry } from '../../lib/faq.js';
import { adminGuard } from '../../lib/skillkit.js';
import FAQ from './faq.json' with { type: 'json' };

const faq = FAQ as FaqEntry[];
export const skill: Skill = {
  name: 'huong-dan-quan-tri', scope: 'ADMIN', description: 'Cách dùng trang quản trị (FAQ tĩnh)', context: [],
  async run({ input, context, llm }) {
    const g = adminGuard(input, context.principal); if (g) return g;
    return answerFaq(input, faq, llm, 'Chưa có hướng dẫn cho việc này. Có thể hỏi về: bảo trì, SMTP, khóa người dùng, phân quyền, thông báo, danh mục hệ thống, cấu hình đăng ký/bảo mật/nghiệp vụ/mobile.', faq.map((e) => e.title));
  },
};
export const run = skill.run;
