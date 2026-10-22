# LifeQuest

LifeQuest là ứng dụng di động biến công việc đời thường thành nhiệm vụ (quest), có AI hỗ trợ chia nhỏ mục tiêu, cơ chế an toàn và đồng bộ nhóm theo thời gian thực.

## Phạm vi đồ án

- Flutter chạy Android (ưu tiên) và iOS.
- Đăng nhập, hồ sơ và thiết lập an toàn.
- Quest cá nhân/nhóm, checklist, XP, streak, huy hiệu.
- Nhóm có mã mời, phân quyền, bảng hoạt động và realtime sync.
- AI gợi ý/chia nhỏ quest; API key chỉ ở backend.
- Báo cáo, chặn người dùng, rời nhóm, quyền riêng tư.
- Thông báo nhắc hạn.
- Mock/Emulator mode để demo ổn định khi không có API AI.

## Stack thống nhất

- Flutter 3.x, Dart 3.x, Material 3.
- Riverpod, GoRouter, Freezed/json_serializable.
- Backend: Node.js + Express, SQLite (migration trong `backend/sql`), JWT + bcrypt, SSE realtime.
- AI: Gemini API (server) hoặc mock an toàn.
- Firebase chỉ dùng để host bản web demo. Kiểm thử: flutter_test, node:test.

## Chạy ứng dụng ngay

Web demo đã triển khai: **https://flutter-firebase-6b5af.web.app**

Hosting dùng domain Firebase miễn phí có HTTPS. Bản web hiện chạy Demo Local Mode: dữ liệu được lưu riêng trong trình duyệt của từng người dùng, chưa đồng bộ Firestore giữa các thiết bị.

```powershell
flutter pub get
flutter run
```

Tài khoản demo: `demo@lifequest.vn` / `123456`.

Ứng dụng mặc định chạy ở **Demo Local Mode** và lưu dữ liệu bằng SharedPreferences dưới dạng JSON. Chế độ này có đầy đủ luồng trình diễn, không cần tạo Firebase project hoặc Gemini key. Nút “Khôi phục dữ liệu demo” ở trang Cá nhân đưa dữ liệu về trạng thái ban đầu.

Kiểm tra và build APK:

```powershell
flutter analyze
flutter test
flutter build apk --debug
flutter build web --release
```

APK nằm tại `build/app/outputs/flutter-apk/app-debug.apk`.

Ảnh chạy thật trên Android Emulator: [Login](docs/screenshots/login.png) và [Home](docs/screenshots/home.png).

Deploy lại web:

```powershell
flutter build web --release
firebase deploy --only hosting --project flutter-firebase-6b5af
```

## Backend REST API

Backend nằm trong [backend/](backend/) (xem [backend/README.md](backend/README.md)): 12 test tích hợp, SQLite có migration, JWT, SSE. Bản Flutter hiện vẫn chạy Demo Local Mode; việc nối app với API xem [ANTIGRAVITY_TASKS.md](ANTIGRAVITY_TASKS.md).

## Chức năng đã triển khai

- Đăng ký, đăng nhập, onboarding và phiên đăng nhập bền vững.
- Dashboard XP, level, streak, huy hiệu và quest ưu tiên.
- Tạo quest, checklist, deadline, tìm kiếm, hoàn thành/lưu trữ.
- Cấp XP đúng một lần trong local mode; transaction idempotent trong Cloud Function.
- Tạo/tham gia nhóm bằng mã mời, danh sách thành viên và quest nhóm.
- AI mock tạo kế hoạch theo độ khó, review-before-save và từ chối từ khóa nguy hiểm.
- Gemini Cloud Function có input/output schema, rate limit, moderation và server secret.
- Notification center, report, block, Safety Center, privacy settings.
- Dark mode, xóa tài khoản và khôi phục seed demo.
- Firestore rules deny-by-default, indexes và Emulator config.
- Unit, controller và widget tests.

## Tài liệu

- [IMPLEMENTATION_PLAN.md](IMPLEMENTATION_PLAN.md): backlog, schema, kiến trúc, tiêu chí nghiệm thu.
- [ANTIGRAVITY_TASKS.md](ANTIGRAVITY_TASKS.md): danh sách việc chi tiết để nối Flutter với API.
- [ANTIGRAVITY_PROMPTS.md](ANTIGRAVITY_PROMPTS.md): prompt giao trực tiếp cho Antigravity từng chặng.
- [BAO_CAO_DO_AN.md](BAO_CAO_DO_AN.md): nội dung nền để viết báo cáo môn học.
- [ANTIGRAVITY_REPORT_PROMPT.md](ANTIGRAVITY_REPORT_PROMPT.md): prompt yêu cầu Antigravity đọc code và hoàn thiện báo cáo.

Không giao toàn bộ dự án trong một prompt. Làm lần lượt từng chặng và chỉ chuyển chặng sau khi test/acceptance criteria của chặng trước đạt.
