# Nội dung nền báo cáo đồ án LifeQuest

## 1. Thông tin đề tài

Tên đề tài: **LifeQuest – Ứng dụng nhiệm vụ đời thường an toàn có tích hợp AI và đồng bộ nhóm trên thiết bị di động**.

Mục tiêu là giúp người dùng chia các mục tiêu đời thường thành nhiệm vụ nhỏ, theo dõi tiến độ, duy trì động lực bằng gamification và phối hợp trong nhóm. AI chỉ đóng vai trò tạo bản nháp; người dùng luôn duyệt trước khi lưu.

## 2. Công nghệ

- Flutter/Dart và Material 3 cho Android/iOS.
- Riverpod quản lý trạng thái; GoRouter điều hướng và auth guard.
- SharedPreferences + JSON cho cơ sở dữ liệu demo cục bộ.
- Firebase Auth/Firestore/Cloud Functions/Emulator là kiến trúc production được chuẩn bị.
- Cloud Functions TypeScript, Zod validation, Gemini API phía server.
- Flutter Test cho unit/controller/widget tests.

## 3. Kiến trúc

Các lớp chính:

1. Presentation: `lib/screens/`, chỉ xử lý giao diện và sự kiện.
2. State/application: `lib/app_controller.dart`, quản lý use cases và trạng thái ứng dụng.
3. Domain/data: `lib/models.dart` và bộ lưu SharedPreferences.
4. Backend production: `functions/src/index.ts`, Firestore Rules và indexes.

Demo Local Mode giúp ứng dụng chạy độc lập khi không có mạng/API key. Production mode dùng Firebase backend để kiểm tra quyền và đồng bộ đa thiết bị.

## 4. Các use case chính

- UC01 đăng ký/đăng nhập/đăng xuất.
- UC02 chọn sở thích trong onboarding.
- UC03 tạo, tìm, xem, cập nhật checklist và lưu trữ quest.
- UC04 hoàn thành quest, nhận XP, cập nhật level/streak/badge.
- UC05 tạo nhóm, chia sẻ mã mời, tham gia/rời nhóm.
- UC06 tạo quest nhóm và theo dõi thành viên.
- UC07 nhập mục tiêu, AI sinh bản nháp, người dùng duyệt và lưu.
- UC08 xem và đánh dấu thông báo.
- UC09 báo cáo/chặn nội dung hoặc thành viên.
- UC10 cập nhật cài đặt, dark mode và xóa tài khoản.

## 5. Thiết kế dữ liệu

Các collection production: `users`, `quests` + `steps`, `groups` + `members` + `activities`, `notifications`, `reports`, `aiRequests`, `idempotency`. Chi tiết trường nằm trong `IMPLEMENTATION_PLAN.md` và rules.

Local Mode tuần tự hóa `AppUser`, `Quest`, `QuestStep`, `QuestGroup`, `AppNotification`, `SafetyReport` thành JSON và lưu dưới khóa `lifequest_database_v1`.

## 6. Thuật toán/nghiệp vụ đáng chú ý

- Level: `floor(sqrt(xp / 100)) + 1`.
- XP theo độ khó: dễ 20, vừa 40, khó 70.
- Streak chỉ tăng tối đa một lần/ngày; bỏ một ngày thì về 1.
- Hoàn thành quest idempotent: `xpAwarded` ngăn cộng điểm lần hai; production dùng Firestore transaction.
- Invite code production dùng chuỗi ngẫu nhiên; Firestore chỉ lưu SHA-256 hash và thời hạn.
- AI production validate input/output bằng Zod, tối đa 8 bước và không log prompt nguyên văn.

## 7. An toàn và bảo mật

- Firestore Rules deny-by-default và phân biệt owner/member/outsider.
- Client không được tự cập nhật XP, level, completedAt hoặc invite hash.
- API key Gemini chỉ ở server secret.
- AI có kiểm tra từ khóa nguy hiểm và không gamify nội dung khủng hoảng.
- Report chỉ reporter/backend đọc; target không đọc được nội dung báo cáo.
- Ứng dụng có block, delete account, Safety Center và khuyến cáo giới hạn AI.

## 8. Kiểm thử

- Unit test công thức level và checklist progress/serialization.
- Controller test đăng nhập, idempotent XP, AI plan theo độ khó, AI unsafe rejection và mã mời sai.
- Widget test màn hình đăng nhập và dữ liệu demo.
- `flutter analyze` kiểm tra tĩnh; `npm run build` kiểm tra TypeScript.

## 9. Kịch bản demo 5–7 phút

1. Đăng nhập `demo@lifequest.vn / 123456`.
2. Giới thiệu Home, XP, level, streak.
3. Tạo quest có checklist/deadline; đánh dấu bước; hoàn thành và quan sát XP.
4. Vào AI, nhập “Ôn thi Flutter trong 7 ngày”, tạo plan, duyệt và lưu.
5. Vào Nhóm, mở “Nhóm sống khỏe”, sao chép mã `LIFE2026`, tạo group quest.
6. Mở report/block và Safety Center.
7. Bật dark mode, xem notifications và trình bày backend Firebase/rules.

## 10. Hạn chế và hướng phát triển

- Bản demo Flutter đang dùng local repository; adapter Firebase client cần cấu hình project thật trước khi phát hành.
- Notification hiện là notification center trong app; FCM/OS scheduling là hướng production.
- Đồng bộ realtime thật cần kết nối FlutterFire với Firebase project; Cloud Functions/rules đã có sẵn.
- Có thể bổ sung ảnh minh chứng, chat nhóm, admin moderation dashboard và integration tests trên hai emulator.
