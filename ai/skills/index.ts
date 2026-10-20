/**
 * Gom mọi skill Track B cho backend (ai.external.ts nạp file này bằng tsx: export `skills` = Skill[]).
 * Skill cùng tên với built-in của backend sẽ đè built-in.
 * `ghi-giao-dich` do Track A giữ (skills/ghi-giao-dich) nên không nằm ở đây.
 *
 * Bí danh: router hiện tại của backend route câu admin tới tên built-in `admin-*`. Để skill Track B được dùng ngay mà
 * không phải sửa backend, mỗi skill admin được export thêm một bản trùng tên built-in (cùng run). Khi backend chuyển sang
 * tên Track B (routeRulesScoped) thì bỏ ADMIN_ALIASES.
 */
import type { Skill } from '../lib/contracts.js';
import { skill as hoiSoDu } from './hoi-so-du/index.js';
import { skill as tongKetThang } from './tong-ket-thang/index.js';
import { skill as kiemTraNganSach } from './kiem-tra-ngan-sach/index.js';
import { skill as timGiaoDich } from './tim-giao-dich/index.js';
import { skill as tienDoTietKiem } from './tien-do-tiet-kiem/index.js';
import { skill as goiYNganSach } from './goi-y-ngan-sach/index.js';
import { skill as meoTietKiem } from './meo-tiet-kiem/index.js';
import { skill as huongDan } from './huong-dan/index.js';
import { skill as ngoaiPhamVi } from './ngoai-pham-vi/index.js';
import { skill as hoiLai } from './hoi-lai/index.js';
import { skill as tongQuan } from './tong-quan-he-thong/index.js';
import { skill as traCuu } from './tra-cuu-nguoi-dung/index.js';
import { skill as batThuong } from './phat-hien-bat-thuong/index.js';
import { skill as soanThongBao } from './soan-thong-bao/index.js';
import { skill as deXuatKhoa } from './de-xuat-khoa/index.js';
import { skill as tomTatCauHinh } from './tom-tat-cau-hinh/index.js';
import { skill as huongDanQuanTri } from './huong-dan-quan-tri/index.js';
import { skill as nguoiDungMoi } from './nguoi-dung-moi/index.js';

export const TRACK_B_SKILLS: Skill[] = [
  hoiSoDu, tongKetThang, kiemTraNganSach, timGiaoDich, tienDoTietKiem, goiYNganSach, meoTietKiem, huongDan, ngoaiPhamVi, hoiLai,
  tongQuan, traCuu, batThuong, soanThongBao, deXuatKhoa, tomTatCauHinh, huongDanQuanTri, nguoiDungMoi,
];

/** tên built-in backend → skill Track B */
export const ADMIN_ALIASES: Record<string, Skill> = {
  'admin-tong-quan': tongQuan,
  'admin-tim-user': traCuu,
  'admin-bat-thuong': batThuong,
  'admin-gui-thong-bao': soanThongBao,
  'admin-khoa-user': deXuatKhoa,
  'admin-lich-su-cau-hinh': tomTatCauHinh,
};

export const skills: Skill[] = [
  ...TRACK_B_SKILLS,
  ...Object.entries(ADMIN_ALIASES).map(([name, s]) => ({ ...s, name, description: `${s.description} (Track B: ${s.name})` })),
];
export default skills;
