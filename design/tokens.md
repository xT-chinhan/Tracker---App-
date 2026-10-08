# Thu Chi · Design tokens

Nguồn thật: `mockup/styles.css` (khối `:root`). Tên token map 1:1 sang Flutter:
`--color-*` → `ColorScheme` / `ThemeExtension<AppColors>`, cỡ chữ → `TextTheme`, còn lại → `ThemeExtension<AppSpacing/AppRadius/AppShadows/AppMotion>`.

## 1. Màu

### ColorScheme (light)
| CSS token | Flutter | Hex | Dùng cho |
|---|---|---|---|
| `--color-background` | `scaffoldBackgroundColor` | `#F7F6F3` | Nền app, màu ngà ấm |
| `--color-surface` | `colorScheme.surface` | `#FFFFFF` | Card, sheet, input, chip chưa chọn |
| `--color-surface-container` | `colorScheme.surfaceContainer` | `#F1F0EC` | Bong bóng icon, nền segmented, track progress |
| `--color-surface-container-high` | `colorScheme.surfaceContainerHigh` | `#E9E8E3` | Trạng thái nhấn, nút disabled |
| `--color-outline` | `colorScheme.outline` | `#EAEAEA` | Viền card 1px, viền chip/nút phụ |
| `--color-outline-variant` | `colorScheme.outlineVariant` | `#F0EFEC` | Đường chia trong list (thụt 52px) |
| `--color-on-surface` | `colorScheme.onSurface` | `#111111` | Chữ chính, số tiền khoản chi |
| `--color-on-surface-variant` | `colorScheme.onSurfaceVariant` | `#787774` | Nhãn phụ, subtitle |
| `--color-on-surface-faint` | `AppColors.faint` | `#A9A8A3` | Placeholder, giờ, tick biểu đồ |
| `--color-primary` | `colorScheme.primary` | `#111111` | Nút chính, chip đang chọn, nút ＋ |
| `--color-on-primary` | `colorScheme.onPrimary` | `#FFFFFF` | |
| `--color-scrim` | `colorScheme.scrim` (32%) | `rgba(17,17,17,.32)` | Lớp mờ sau bottom sheet |

### Ngữ nghĩa (`ThemeExtension<AppColors>`)
| Token | Hex | Dùng cho |
|---|---|---|
| `income` | `#1F8A4C` | Số tiền thu (+), cột Thu |
| `expense` | `#111111` | Số tiền chi (−), cột Chi |
| `warning` / `warningContainer` / `warningBar` | `#956400` / `#FBF3DB` / `#D99A1E` | Ngân sách ≥ 80% |
| `danger` / `dangerContainer` / `dangerBar` | `#B3261E` / `#FDEBEC` / `#D9483B` | Ngân sách ≥ 100%, hành động xóa |
| `successContainer` | `#EDF3EC` | Badge xu hướng tốt |

Quy tắc: màu chỉ mang ý nghĩa. Thu thì xanh, chi thì đen, cảnh báo vàng, vượt ngưỡng đỏ. Không có màu thương hiệu.

### Biểu đồ (`AppColors.viz1..viz5`)
`#2a78d6` `#eb6834` `#1baf7a` `#eda100` `#e87ba4`. Bộ này đã kiểm bằng `dataviz/validate_palette.js --mode light`: đạt hết, CVD ΔE nhỏ nhất 9.1. Thứ tự gán cố định theo danh mục, không xoay vòng. 3 màu sáng có tương phản dưới 3:1, nên legend luôn kèm nhãn và số (yêu cầu "relief"). Chữ không bao giờ dùng màu series.

## 2. Typography: Be Vietnam Pro (dự phòng: SF Pro Display, system-ui)
| Flutter `TextTheme` | CSS class | Size / weight / line-height | Tracking | Dùng cho |
|---|---|---|---|---|
| `displayLarge` | `.amount-big` | 46 / 700 / 1.2 | −0.03em | Số tiền đang nhập |
| `displayMedium` | `.display` | 40 / 700 / 1.2 | −0.03em | Tổng số dư, số tiền chi tiết |
| `displaySmall` | (inline 32) | 32 / 700 / 1.25 | −0.03em | Số chính trên card (chênh lệch, còn lại) |
| `headlineLarge` | `.headline` | 30 / 700 / 1.25 | −0.025em | Tiêu đề màn hình, ngày |
| `titleLarge` | `.title-l` | 20 / 700 / 1.3 | −0.015em | Tiêu đề sheet, empty state |
| `titleMedium` | `.title-m` | 16 / 600 / 1.35 | 0 | Tiêu đề card, giá trị phụ |
| `bodyLarge` | `.t` | 15 / 500 / 1.4 | 0 | Tiêu đề dòng list |
| `bodyMedium` | `.body-m` | 14 / 400 / 1.5 | 0 | Đoạn mô tả |
| `bodySmall` | `.body-s`, `.s` | 12.5 / 400 / 1.45 | 0 | Subtitle "Ăn uống · MB Bank" |
| `labelLarge` | `.btn` | 16 / 600 | 0 | Nút |
| `labelMedium` | `.chip` | 13.5 / 500 | 0 | Chip |
| `labelSmall` | `.label-s`, tab | 12 / 500 (tab 10.5) | 0 | Nhãn nhỏ, tab bar |

Mọi số tiền dùng `FontFeature.tabularFigures()`. Dấu trừ là U+2212 "−", kéo sát số (−0.14em). Định dạng `26.022.000đ` (dấu chấm hàng nghìn, "đ" liền sau số). Line-height không dưới 1.2 để dấu tiếng Việt (Ễ, Ỗ) không bị cắt.

## 3. Spacing (lưới 4pt), `AppSpacing`
`s1 4` · `s2 8` · `s3 12` · `s4 16` · `s5 20` · `s6 24` · `s8 32` · `s10 40`. Lề màn hình `screenPadding = 20`. Khoảng giữa các card là 12, giữa các khối là 20–24.

## 4. Radius, `AppRadius`
`xs 8` (skeleton) · `sm 12` · `md 14` (input, tile, OTP) · `lg 18` (card) · `xl 28` (bottom sheet, góc trên) · `pill 999` (nút, chip, badge, progress, segmented).

## 5. Shadows, `AppShadows` (alpha < 0.05, rất loãng)
- `card`: `0 1 2 rgba(17,17,17,.03)` + `0 6 20 rgba(17,17,17,.035)` + viền 1px `outline`
- `sheet`: `0 −8 32 rgba(17,17,17,.08)`
- `raised` (nút ＋ giữa tab bar): `0 6 16 rgba(17,17,17,.18)` + vòng 5px màu `background`

## 6. Motion, `AppMotion`
`press 160ms easeOut` (scale 0.97) · `fast 200ms` · `sheet 360ms Cubic(0.32,0.72,0,1)` · `easeOut = Cubic(0.23,1,0.32,1)`. Không dùng ease-in. Skeleton shimmer 1.4s, tắt khi bật reduce-motion.

## 7. Component specs
| Component | Spec |
|---|---|
| **Card** | nền `surface`, viền 1px `outline`, radius 18, shadow `card`, padding 18 (dạng list: 4×16) |
| **List row** | cao tối thiểu 64. Bubble 40 + gap 12. Title `bodyLarge`, subtitle `bodySmall` màu muted, cắt "…" nếu dài. Bên phải: số tiền 15/600 + giờ 12 màu faint. Divider 1px `outlineVariant`, thụt 52px từ trái |
| **Icon bubble** | tròn 40 (sm 32, lg 56, xl 72), nền `surfaceContainer`, icon Lucide 19px, nét 1.75, màu `#3A3935`. Khi chọn: nền `primary`, icon trắng |
| **Chip (lọc)** | cao 34, padding ngang 14, pill, nền `surface` + viền `outline`. Khi chọn: nền `primary`, chữ trắng |
| **Segmented** | cao 40, nền `surfaceContainer`, padding 3. Mục đang chọn: nền trắng + shadow 0 1 3 / .08. Dùng cho Chi/Thu, tần suất |
| **Primary button** | cao 52, pill, nền `primary`, chữ 16/600 trắng, icon 18. Disabled: nền `surfaceContainerHigh`, chữ faint |
| **Secondary button** | cao 52 (sm 40), pill, nền `surface` + viền `outline`, chữ `onSurface`. Bản nguy hiểm: chữ `danger` |
| **Danger soft** | pill 52, nền `dangerContainer`, chữ `danger`. Chỉ dùng trong sheet xác nhận |
| **Keypad** | lưới 3 cột, phím cao 54, giãn dòng 4, số 26/500, không nền. Hàng cuối: `000` · `0` · xóa (icon delete 24). Nằm ở đáy (vùng ngón cái), nút lưu ngay dưới |
| **Amount display** | 46/700, căn giữa, caret 2.5px, có dòng đọc số bằng chữ bên dưới |
| **Bottom sheet** | nền trắng, radius trên 28, padding 10/20/42, grabber 36×5 `#DAD8D2`, scrim 32% |
| **Tab bar** | cao 86 (gồm 34 safe area), nền trắng 95% + blur 20, viền trên 1px. 5 ô; icon 23, nhãn 10.5. Tab đang chọn: ink 600, nét 2.1. Tab còn lại: `#9C9A94`. Nút ＋ giữa: tròn 56 màu `primary`, nhô lên 18px, vòng 5px màu nền |
| **Progress bar** | cao 6 (thick 8), pill, track `surfaceContainer`. Fill: bình thường `primary`, ≥ 80% `warningBar`, ≥ 100% `dangerBar` (kẹp ở 100%). Luôn có badge % + icon, không chỉ dựa vào màu |
| **Badge** | cao 26, pill, 12/600, icon 13. Biến thể neutral / warn / danger / ok |
| **Input** | cao 52, radius 14, viền `outline`. Focus: viền `primary` + vòng 3px rgba(17,17,17,.06). Nhãn nằm trên ô (13/500 muted) |
| **OTP** | 6 ô, cao 58, radius 14, số 24/600. Ô đang nhập: viền ink + caret |
| **Month switcher** | pill cao 36, viền `outline`, hai chevron 30px |
| **Skeleton** | `#ECEBE7`→`#F4F3F0` shimmer, giữ đúng kích thước bố cục thật. Không dùng spinner |
| **Touch target** | tối thiểu 44×44 (icon button 44, chip 34 nhưng vùng chạm 44 nhờ padding) |
