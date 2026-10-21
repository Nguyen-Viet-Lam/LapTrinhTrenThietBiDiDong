# LifeQuest

LifeQuest là ứng dụng di động biến công việc đời thường thành nhiệm vụ (quest), có AI hỗ trợ chia nhỏ mục tiêu, cơ chế an toàn và đồng bộ nhóm theo thời gian thực.

## Phạm vi đồ án

- Flutter chạy Android (ưu tiên) và iOS.
- Đăng nhập, hồ sơ và thiết lập an toàn.
- Quest cá nhân/nhóm, checklist, XP, streak, huy hiệu.
- Nhóm có mã mời, phân quyền, bảng hoạt động và realtime sync.
- AI gợi ý/chia nhỏ quest; API key chỉ ở Cloud Functions.
- Báo cáo, chặn người dùng, rời nhóm, quyền riêng tư.
- Thông báo nhắc hạn.
- Mock/Emulator mode để demo ổn định khi không có API AI.

## Stack thống nhất

- Flutter 3.x, Dart 3.x, Material 3.
- Riverpod, GoRouter, Freezed/json_serializable.
- Firebase Auth, Firestore, Storage, FCM, Crashlytics.
- Cloud Functions TypeScript và Gemini API.
- Firebase Emulator Suite, flutter_test, mocktail, integration_test.

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

## Firebase production backend

Repository có sẵn `firestore.rules`, `firestore.indexes.json`, `firebase.json` và Cloud Functions TypeScript trong `functions/`. Đây là backend production cho group membership, invite code hash, completeQuest transaction/idempotency và AI proxy an toàn.

```powershell
Copy-Item .firebaserc.example .firebaserc
# Sửa project id trong .firebaserc
Set-Location functions
npm install
npm run build
Set-Location ..
firebase emulators:start
```

Để triển khai AI production, cấu hình secret ở Firebase/Google Secret Manager với tên `GEMINI_API_KEY`. Không đặt key vào Flutter source hoặc `.env` của ứng dụng.

> Bản Flutter hiện dùng local repository để chạy độc lập. Khi đưa lên production, tạo adapter Firebase Auth/Firestore/Functions theo cùng model và chuyển provider trong bootstrap; backend và rules đã được chuẩn bị cho đường nâng cấp này.

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
- [ANTIGRAVITY_PROMPTS.md](ANTIGRAVITY_PROMPTS.md): prompt giao trực tiếp cho Antigravity từng chặng.
- [BAO_CAO_DO_AN.md](BAO_CAO_DO_AN.md): nội dung nền để viết báo cáo môn học.
- [ANTIGRAVITY_REPORT_PROMPT.md](ANTIGRAVITY_REPORT_PROMPT.md): prompt yêu cầu Antigravity đọc code và hoàn thiện báo cáo.

Không giao toàn bộ dự án trong một prompt. Làm lần lượt từng chặng và chỉ chuyển chặng sau khi test/acceptance criteria của chặng trước đạt.
