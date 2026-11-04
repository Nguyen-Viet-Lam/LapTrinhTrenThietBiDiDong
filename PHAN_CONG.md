# Phân công công việc – Nhóm 10 – LifeQuest

Tỉ trọng đóng góp (thang 100):

| Thành viên | Điểm | Mảng chính |
|---|---|---|
| Nguyễn Viết Lãm (nhóm trưởng) | **35** | Backend + Admin + Nhóm (CLB) + điều phối |
| Nguyễn Đại Kỳ | **30** | Gamification, Nhiệm vụ, Trang chủ |
| Trần Ngọc Lợi | **20** | Trợ lý AI, Thông báo, An toàn (báo cáo/chặn) |
| Châu Tuấn | **15** | Đăng nhập/Onboarding, UI chung, Kiểm thử, Tài liệu |

Đường dẫn bên dưới tính từ thư mục gốc dự án; số là dòng code (xấp xỉ, có thể lệch vài dòng sau khi sửa).

---

## 1. Nguyễn Viết Lãm – 35 điểm

**Backend (Node.js + SQLite)**
- `backend/src/app.js:1-394` – toàn bộ REST API: auth `128-170`, quests `179-258`, groups + SSE `260-337`, notifications/reports/blocks `357-394`, JWT/RBAC middleware `53-125`, công thức level `14`.
- `backend/src/db.js` (1-46), `backend/src/server.js`, `backend/src/seed.js` (dữ liệu mẫu), `backend/sql/001_init.sql`, `002_password_changed.sql` – schema 9 bảng, migration.

**Flutter**
- `lib/app_controller.dart:56-210` – khởi tạo, đăng nhập/đăng ký, đổi mật khẩu, settings (chỉ dùng REST API + SQLite).
- `lib/app_controller.dart:416-611` – logic CLB nhóm (tạo/tham gia/rời/chuyển quyền, chat nhóm, chat 1-1).
- `lib/api/api_client.dart`, `lib/api/api_exception.dart` – Dio, token, SSE.
- `lib/screens/groups_screen.dart` (1-1447) – màn CLB nhóm, chi tiết nhóm, chat trực tiếp.

- `lib/screens/admin_screen.dart` (1-757) – Admin Dashboard.
- `android/` (Gradle) – cấu hình build.

**Điều phối:** quản lý git/merge, `chay_local.bat`, demo chính.

## 2. Nguyễn Đại Kỳ – 30 điểm

- `lib/screens/home_screen.dart` (1-2392) – trang chủ: 5 trụ cột `2164-2268`, thống kê `2269-2320`, biểu đồ `2321+`, Pomodoro `1891-2042`, thẻ Deep Ocean `1780-1890`.
- `lib/screens/quests_screen.dart` (1-581) – danh sách nhiệm vụ, bộ lọc Đang làm/Đã xong/Lưu trữ.
- `lib/screens/quest_widgets.dart` (1-1212) – `QuestCard 11-165`, `QuestDetailSheet 166-586` (checklist), `CreateQuestSheet 587-938`, `EditQuestSheet 939+`.
- `lib/app_controller.dart:211-415` – stats, fetch/thêm/sửa/xóa nhiệm vụ, toggle bước, hoàn thành nhiệm vụ (XP, streak, idempotent), lưu trữ.
- `lib/models.dart` (1-679) – model Quest, User, Stats, Group...

- `lib/screens/profile_screen.dart:8-219` – trang Hồ sơ.
- `lib/screens/main_shell.dart` (1-646) – khung điều hướng chính.

## 3. Trần Ngọc Lợi – 20 điểm

- `lib/screens/ai_screen.dart` (1-987) – Trợ lý AI: preset ảnh `16-90`, màn chính `91+`, quy trình review-before-save.
- `lib/app_controller.dart:612-804` – `generateAiPlan`, `generateVisionQuest` (kế hoạch 3/5/7 bước).
- `backend/src/ai.js` (1-55) + route `POST /api/ai/quest-plan` (`backend/src/app.js:339-356`) – gọi Gemini, kiểm duyệt an toàn (HTTP 422).
- `lib/screens/notifications_sheet.dart` (1-99) + `app_controller.dart:805-828`.
- Phần An toàn: `lib/screens/profile_screen.dart:354-528` (`BlockedUsersSheet`, `SafetyCenterSheet`), `app_controller.dart:829-868` (report/block).

## 4. Châu Tuấn – 15 điểm

- `lib/screens/auth_screens.dart` (1-1169) – `LoginScreen 7-273`, `RegisterScreen 274-471`, `ForgotPasswordScreen 472-607`, `OnboardingScreen 608-743`.
- `lib/screens/design_v2_widgets.dart` (1-210) – `AnimatedCounter`, `ProgressRing`.
- `lib/app.dart`, `lib/main.dart` – theme, khởi động app.
- `lib/screens/profile_screen.dart:220-353` – `ChangePasswordSheet`.
- Kiểm thử: `test/*.dart` (9 file), `backend/test/api.test.js`, test plan IEEE 829.
- Tài liệu: `README.md`, báo cáo, slide.

---

## Quy ước chung
- Mỗi người làm trên nhánh `feat/<ten>`, tạo Pull Request vào `main`, Lãm review và merge.
- Trước khi nộp: `flutter analyze`, `flutter test`, `cd backend && npm test` phải pass.
- Cả 4 người chạy thử app trên điện thoại thật và nắm rõ phần của mình để trả lời vấn đáp.

> **Cơ sở dữ liệu duy nhất:** SQLite phía backend (`backend/data/lifequest.db`). Ứng dụng Flutter chỉ gọi REST API; không dùng Firebase.
