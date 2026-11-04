# Phân công công việc – Nhóm 10 – LifeQuest

> **Cơ sở dữ liệu duy nhất:** SQLite phía backend (`backend/data/lifequest.db`). Ứng dụng Flutter chỉ gọi REST API, không dùng Firebase.
> Đường dẫn tính từ thư mục gốc dự án; số là dòng code (xấp xỉ, có thể lệch vài dòng sau khi sửa).

## Tỉ trọng đóng góp (thang 100)

| Thành viên | Điểm | Mảng chính |
|---|---|---|
| Nguyễn Viết Lãm (nhóm trưởng) | **35** | Backend + Database + Admin + CLB nhóm + điều phối |
| Nguyễn Đại Kỳ | **30** | Gamification, Nhiệm vụ, Trang chủ |
| Trần Ngọc Lợi | **20** | Trợ lý AI, Thông báo, An toàn (báo cáo/chặn) |
| Châu Tuấn | **15** | Đăng nhập/Onboarding, UI chung, Kiểm thử, Tài liệu |

---

## 1. Nguyễn Viết Lãm – 35 điểm

**Database (SQLite) – làm ở đâu**
- `backend/sql/001_init.sql` – schema 9 bảng: users, groups_, group_members, quests, quest_steps, notifications, reports, blocks, ai_requests.
- `backend/sql/002_password_changed.sql` – cột `password_changed_at`.
- `backend/sql/003_messages.sql` – bảng `messages` (chat nhóm + chat 1-1).
- `backend/src/db.js` (1-46) – mở DB, migration tự động theo `PRAGMA user_version`, hàm transaction `tx`.
- `backend/src/seed.js` – dữ liệu mẫu: 6 tài khoản, 3 CLB (cầu lông, bóng đá, Flutter), nhiệm vụ cá nhân + nhiệm vụ nhóm, tin nhắn nhóm, tin nhắn 1-1 giữa Lãm/Kỳ/Lợi/Tuấn, thông báo.

**Backend API**
- `backend/src/app.js` – toàn bộ REST API: JWT/RBAC + middleware (53-125), auth, quests, groups, tin nhắn (`/api/groups/:id/messages`, `/api/messages/:peerId`), SSE realtime (`/api/groups/:id/events`), notifications/reports/blocks.
- `backend/src/server.js` – khởi động server cổng 3000.

**Flutter**
- `lib/app_controller.dart:56-210` – khởi tạo, đăng nhập/đăng ký, đổi mật khẩu, settings.
- `lib/app_controller.dart:416-646` – logic CLB nhóm, chat nhóm, chat 1-1 (`loadGroupMessages`, `loadDirectMessages`, `sendGroupMessage`, `sendDirectMessage`).
- `lib/api/api_client.dart`, `lib/api/api_exception.dart` – Dio, token, SSE.
- `lib/screens/groups_screen.dart` (1-1447) – màn CLB nhóm, chi tiết nhóm, chat trực tiếp.
- `lib/screens/admin_screen.dart` (1-757) – Admin Dashboard.
- `android/` (Gradle), `.run/LifeQuest Phone.run.xml` – cấu hình chạy từ Android Studio.

**Kiểm thử (backend)** – `backend/test/api.test.js`, chạy bằng `cd backend && npm test`:
- Lãm viết/chịu trách nhiệm: migration (`:136`), quest + XP idempotent (`:37-58`), nhóm + quyền chủ nhóm (`:59`), SSE realtime (`:120`), tin nhắn nhóm + 1-1 (`:141-170`).

**Điều phối:** quản lý git/merge, `chay_local.bat`, demo chính.

## 2. Nguyễn Đại Kỳ – 30 điểm

- `lib/screens/home_screen.dart` (1-2392) – trang chủ: 5 trụ cột, thống kê, biểu đồ, Pomodoro, thẻ Deep Ocean.
- `lib/screens/quests_screen.dart` (1-581) – danh sách nhiệm vụ, bộ lọc Đang làm/Đã xong/Lưu trữ.
- `lib/screens/quest_widgets.dart` (1-1212) – `QuestCard`, `QuestDetailSheet` (checklist), `CreateQuestSheet`, `EditQuestSheet`.
- `lib/app_controller.dart:211-415` – stats, fetch/thêm/sửa/xóa nhiệm vụ, toggle bước, hoàn thành (XP, streak, idempotent), lưu trữ.
- `lib/models.dart` (1-679) – model Quest, User, Stats, Group, Message...
- `lib/screens/profile_screen.dart:8-219` – trang Hồ sơ.
- `lib/screens/main_shell.dart` (1-646) – khung điều hướng chính.

**Kiểm thử Kỳ phụ trách (Flutter, `flutter test`):**
- `test/app_controller_test.dart` – tạo quest, hoàn thành quest idempotent, đăng nhập/401.
- `test/models_test.dart` – công thức level, tiến độ checklist.
- `test/database_volume_test.dart` – hiệu năng tìm kiếm/lọc 100 nhiệm vụ.

## 3. Trần Ngọc Lợi – 20 điểm

- `lib/screens/ai_screen.dart` (1-987) – Trợ lý AI: tab kế hoạch văn bản, tab AI Thị giác (chụp/chọn ảnh), preset bối cảnh, review-before-save.
- `lib/app_controller.dart:647-839` – `generateAiPlan`, `generateVisionQuest` (ảnh thật gửi `/ai/vision-plan`; ảnh mẫu dùng kế hoạch 3/5/7 bước).
- `backend/src/ai.js` – `callGemini` (thử lần lượt nhiều model, tự chuyển khi 503/429/timeout), `generatePlan` (văn bản), `generateVisionPlan` (ảnh, Gemini Vision), danh sách từ cấm `UNSAFE_TERMS`.
- Route `POST /api/ai/quest-plan` và `POST /api/ai/vision-plan` trong `backend/src/app.js` – kiểm duyệt an toàn (HTTP 422), giới hạn tần suất (HTTP 429), thiếu key trả 503.
- `lib/screens/notifications_sheet.dart` (1-99) + phần thông báo trong `app_controller.dart`.
- Phần An toàn: `lib/screens/profile_screen.dart:354-528` (`BlockedUsersSheet`, `SafetyCenterSheet`), phần report/block trong `app_controller.dart`.
- Cấu hình key: `backend/.env` (`GEMINI_API_KEY`, `GEMINI_MODEL`) – file này không đưa lên Git.

**Kiểm thử Lợi phụ trách:**
- `test/ai_vision_test.dart` – AI cầu lông 3 bước, học tập 7 bước, chặn từ khóa nguy hiểm 422, quest có ảnh.
- `backend/test/api.test.js` – AI văn bản (`:74`), AI ảnh (cuối file: 503 khi thiếu key, 400 sai định dạng, 422 nội dung nguy hiểm, 401 chưa đăng nhập), thông báo/báo cáo/chặn (`:82`, `:108`).

## 4. Châu Tuấn – 15 điểm

- `lib/screens/auth_screens.dart` (1-1169) – `LoginScreen`, `RegisterScreen`, `ForgotPasswordScreen`, `OnboardingScreen`.
- `lib/screens/design_v2_widgets.dart` (1-210) – `AnimatedCounter`, `ProgressRing`.
- `lib/app.dart`, `lib/main.dart` – theme, khởi động app.
- `lib/screens/profile_screen.dart:220-353` – `ChangePasswordSheet`.
- Tài liệu: `README.md`, báo cáo, slide, test plan IEEE 829.

**Kiểm thử Tuấn phụ trách:**
- `test/widget_test.dart` – màn hình đăng nhập.
- `test/design_v2_test.dart` – widget thiết kế.
- `test/group_chat_test.dart` – giao diện chat nhóm/chat 1-1.
- `backend/test/api.test.js` – auth (`:28`), rate limit đăng nhập (`:94`), đổi mật khẩu (`:100`).

---

## Tài khoản dữ liệu mẫu (mật khẩu chung `123456`)

| Email | Vai trò | Thuộc nhóm |
|---|---|---|
| `lam@lifequest.vn` | Admin | chủ nhóm Flutter; thành viên 2 CLB còn lại |
| `ky@lifequest.vn` | User | chủ CLB Cầu Lông; thành viên Bóng Đá, Flutter |
| `loi@lifequest.vn` | User | chủ Hội Bóng Đá; thành viên Cầu Lông, Flutter |
| `tuan@lifequest.vn` | User | thành viên cả 3 nhóm |
| `maianh@lifequest.vn` | User | thành viên CLB Cầu Lông |

Mã mời: `CAULONG26`, `BONGDA26`, `FLUTTER26`.

## Cách chạy
1. Backend: `cd backend && npm install`, copy `.env.example` thành `.env` và dán `GEMINI_API_KEY` (lấy ở https://aistudio.google.com/apikey), rồi `npm start` (cổng 3000, DB tự tạo và nạp dữ liệu mẫu). Không có key thì AI ảnh báo lỗi 503, phần còn lại vẫn chạy.
2. Điện thoại thật (cùng Wi-Fi với máy tính): `flutter run --dart-define=API_BASE_URL=http://<IP-máy-tính>:3000/api`; hoặc trong Android Studio chọn cấu hình **LifeQuest Phone** (sửa IP trong `.run/LifeQuest Phone.run.xml` nếu đổi mạng).
3. Máy ảo Android: `flutter run` (mặc định dùng `10.0.2.2:3000`).

## Quy ước chung
- Mỗi người làm trên nhánh `feat/<ten>`, tạo Pull Request vào `main`, Lãm review và merge.
- Trước khi nộp: `flutter analyze`, `flutter test`, `cd backend && npm test` phải pass.
- Cả 4 người chạy thử app trên điện thoại thật và nắm rõ phần của mình để trả lời vấn đáp.
- Tài liệu vấn đáp (công nghệ, ý tưởng, câu hỏi thường gặp): `VAN_DAP.md`.
