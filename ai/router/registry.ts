/**
 * Danh bạ skill cho backend (Track C): tên → SkillDef. `ghi-giao-dich` do Track A giữ (skills/ghi-giao-dich/pipeline.ts,
 * hàm runGhi) nên không nằm ở đây; router vẫn route tới nó trong scope USER.
 */
import type { Scope, SkillDef } from '../lib/contracts.js';
import { skill as hoiSoDu } from '../skills/hoi-so-du/index.js';
import { skill as tongKetThang } from '../skills/tong-ket-thang/index.js';
import { skill as kiemTraNganSach } from '../skills/kiem-tra-ngan-sach/index.js';
import { skill as timGiaoDich } from '../skills/tim-giao-dich/index.js';
import { skill as tienDoTietKiem } from '../skills/tien-do-tiet-kiem/index.js';
import { skill as goiYNganSach } from '../skills/goi-y-ngan-sach/index.js';
import { skill as meoTietKiem } from '../skills/meo-tiet-kiem/index.js';
import { skill as huongDan } from '../skills/huong-dan/index.js';
import { skill as ngoaiPhamVi } from '../skills/ngoai-pham-vi/index.js';
import { skill as hoiLai } from '../skills/hoi-lai/index.js';
import { skill as tongQuan } from '../skills/tong-quan-he-thong/index.js';
import { skill as traCuu } from '../skills/tra-cuu-nguoi-dung/index.js';
import { skill as batThuong } from '../skills/phat-hien-bat-thuong/index.js';
import { skill as soanThongBao } from '../skills/soan-thong-bao/index.js';
import { skill as deXuatKhoa } from '../skills/de-xuat-khoa/index.js';
import { skill as tomTatCauHinh } from '../skills/tom-tat-cau-hinh/index.js';
import { skill as huongDanQuanTri } from '../skills/huong-dan-quan-tri/index.js';

export const SKILLS: Record<string, SkillDef> = Object.fromEntries([
  hoiSoDu, tongKetThang, kiemTraNganSach, timGiaoDich, tienDoTietKiem, goiYNganSach, meoTietKiem, huongDan, ngoaiPhamVi, hoiLai,
  tongQuan, traCuu, batThuong, soanThongBao, deXuatKhoa, tomTatCauHinh, huongDanQuanTri,
].map((s) => [s.name, s]));

/** Skill có chạy được trong scope này không (backend kiểm tra lại trước khi gọi run). */
export const allowed = (name: string, scope: Scope) => {
  if (name === 'ghi-giao-dich') return scope === 'USER';
  const s = SKILLS[name];
  return !!s && (s.scope === 'BOTH' || s.scope === scope);
};
