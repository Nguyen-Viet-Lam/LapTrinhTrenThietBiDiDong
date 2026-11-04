# Tính năng và công nghệ – LifeQuest

Mỗi mục ghi rõ: **là gì**, **dùng công nghệ gì**, **làm ở file nào**. Đường dẫn tính từ thư mục gốc dự án.

## 1. Tài khoản và đăng nhập
- **Là gì:** đăng ký, đăng nhập, quên mật khẩu, đổi mật khẩu, xóa tài khoản, onboarding chọn sở thích khi vào lần đầu, giữ phiên đăng nhập.
- **Công nghệ:** JWT (hết hạn 7 ngày), bcrypt băm mật khẩu, zod kiểm tra dữ liệu, `shared_preferences` lưu token, go_router chặn người chưa đăng nhập. Sai mật khẩu quá 5 lần bị khóa 15 phút (HTTP 429).
- **File:** `backend/src/app.js` (route `/auth/*`, `/me`), `lib/screens/auth_screens.dart`, `lib/app_controller.dart` (login/register/logout), `lib/app.dart` (router).

## 2. Nhiệm vụ và checklist
- **Là gì:** tạo/sửa/xóa/lưu trữ nhiệm vụ; mỗi nhiệm vụ có danh mục (Sức khỏe, Học tập, Công việc, Gia đình, Khác), độ khó (Dễ 20 XP, Vừa 40 XP, Khó 70 XP), hạn hoàn thành và các bước nhỏ (checklist). Lọc theo Đang làm / Đã xong / Lưu trữ, tìm theo tên.
- **Công nghệ:** REST API + SQLite (bảng `quests`, `quest_steps`).
- **File:** `backend/src/app.js` (route `/quests/*`), `lib/screens/quests_screen.dart`, `lib/screens/quest_widgets.dart`, `lib/app_controller.dart` (phần Quests).

## 3. Gamification: XP, cấp độ, chuỗi ngày, huy hiệu
- **Là gì:** hoàn thành nhiệm vụ nhận XP, lên cấp, giữ chuỗi ngày (streak), mở huy hiệu (Khởi đầu, Chăm chỉ, Chuỗi 3/7 ngày, Cấp 5). Trang chủ có 5 trụ cột đời sống, biểu đồ và đồng hồ Pomodoro 25 phút.
- **Công nghệ:** công thức cấp độ `floor(sqrt(xp/100)) + 1`; **hoàn thành idempotent** (bấm nhiều lần chỉ cộng XP một lần) bằng transaction SQLite và cờ `xp_awarded`.
- **File:** `backend/src/app.js` (`levelForXp`, `badges`, route `/quests/:id/complete`), `lib/screens/home_screen.dart`, `lib/screens/design_v2_widgets.dart`.

## 4. Trợ lý AI lập kế hoạch (văn bản)
- **Là gì:** nhập mục tiêu, AI chia thành kế hoạch 3/5/7 bước theo độ khó. Kết quả là **bản nháp**, người dùng xem và sửa rồi mới lưu (review-before-save).
- **Công nghệ:** Google Gemini API gọi từ backend. Có từ cấm → HTTP 422, giới hạn tần suất → HTTP 429, kiểm tra JSON trả về bằng zod, prompt dặn AI bỏ qua chỉ dẫn lạ.
- **File:** `backend/src/ai.js` (`generatePlan`), route `POST /api/ai/quest-plan` trong `backend/src/app.js`, `lib/screens/ai_screen.dart`, `lib/app_controller.dart` (`generateAiPlan`).

## 5. AI Thị giác (nhận diện ảnh)
- **Là gì:** chụp hoặc chọn ảnh thật; Gemini nhìn ảnh, nhận ra bối cảnh (sân cầu lông, bàn học, công viên...) rồi gợi ý nhiệm vụ phù hợp. Có ảnh mẫu để thử nhanh.
- **Công nghệ:** `image_picker` (camera/thư viện), ảnh nén ≤1200px rồi mã hóa base64, gửi `POST /api/ai/vision-plan`; Gemini Vision. Backend thử lần lượt nhiều model, tự chuyển khi model quá tải (503/429) hoặc quá thời gian. Thiếu key → HTTP 503.
- **File:** `backend/src/ai.js` (`callGemini`, `generateVisionPlan`), `backend/.env` (`GEMINI_API_KEY`, `GEMINI_MODEL`), `lib/screens/ai_screen.dart`, `lib/app_controller.dart` (`generateVisionQuest`).

## 6. CLB nhóm và mã mời
- **Là gì:** tạo nhóm, nhập **mã nhóm** để tham gia, xem thành viên, rời nhóm, chủ nhóm xóa nhóm / chuyển quyền / xóa thành viên. Hộp "Mời bạn bè" hiện mã nhóm và nút sao chép lời mời để gửi qua Zalo/Messenger. Nhiệm vụ nhóm có thể giao cho một thành viên.
- **Công nghệ:** mã mời lưu dạng hash **SHA-256** (có hạn dùng), bảng `groups_`, `group_members`; phân quyền theo vai trò chủ nhóm/thành viên, người ngoài nhóm nhận 404.
- **File:** `backend/src/app.js` (route `/groups/*`), `lib/screens/groups_screen.dart`, `lib/app_controller.dart` (phần Groups).
- **Mã nhóm dữ liệu mẫu:** `CAULONG26`, `BONGDA26`, `FLUTTER26`.

## 7. Trò chuyện (chat nhóm và chat 1-1)
- **Là gì:** nhắn tin trong nhóm và nhắn riêng giữa hai thành viên; có tin nhắn nhanh rủ đi chơi. Tin nhắn **lưu trong SQLite** nên điện thoại và máy khác (máy ảo Android Studio, trình duyệt) thấy cùng nội dung. Người nhận 1-1 được báo bằng thông báo.
- **Công nghệ:** bảng `messages` (cột `group_id` hoặc `receiver_id`, ràng buộc `CHECK`), REST API. Chat nhóm cập nhật tức thời qua **Server-Sent Events**; chat 1-1 tải lại định kỳ mỗi 4 giây.
- **File:** `backend/sql/003_messages.sql`, `backend/src/app.js` (route `/groups/:id/messages`, `/messages/:peerId`), `lib/screens/groups_screen.dart` (`GroupDetailSheet`, `DirectChatSheet`), `lib/app_controller.dart` (`loadGroupMessages`, `loadDirectMessages`, `send*Message`).

## 8. Cập nhật gần thời gian thực (SSE)
- **Là gì:** khi có thành viên mới, nhiệm vụ nhóm đổi trạng thái, có tin nhắn mới hoặc nhóm bị giải tán, màn hình nhóm đang mở tự cập nhật không cần kéo tải lại.
- **Công nghệ:** Server-Sent Events (một chiều server → app, nhẹ hơn WebSocket). Backend giữ danh sách kết nối theo nhóm (`hub`) và gọi `emit` khi có sự kiện.
- **File:** `backend/src/app.js` (`/groups/:id/events`, `emit`), `lib/api/api_client.dart` (`subscribeGroupEvents`).

## 9. Thông báo
- **Là gì:** thông báo khi có thành viên mới vào nhóm, hoàn thành nhiệm vụ, có tin nhắn 1-1; chuông ở thanh trên hiện số chưa đọc, có nút đánh dấu đã đọc.
- **File:** `backend/src/app.js` (hàm `notify`, route `/notifications`), `lib/screens/notifications_sheet.dart`.

## 10. An toàn cộng đồng
- **Là gì:** báo cáo vi phạm (người dùng, nhiệm vụ, nhóm), chặn người dùng (ẩn nhiệm vụ nhóm của người bị chặn), Trung tâm an toàn, lọc từ khóa nguy hiểm khi dùng AI.
- **File:** `backend/src/app.js` (`/reports`, `/blocks`, `UNSAFE_TERMS` trong `backend/src/ai.js`), `lib/screens/profile_screen.dart` (`BlockedUsersSheet`, `SafetyCenterSheet`).

## 11. Quản trị viên (Admin)
- **Là gì:** giao diện quản trị riêng (tối, kính mờ Deep Ocean), tab giám sát thành viên, nhiệm vụ và kiểm duyệt nội dung.
- **Lưu ý trung thực:** danh sách thành viên/nhiệm vụ trong màn Admin hiện là **dữ liệu ghi cứng trong code**, chưa đọc từ DB. Vai trò admin được xác định bằng email (`lam@lifequest.vn`).
- **File:** `lib/screens/admin_screen.dart`, phần Admin trong `lib/screens/home_screen.dart`.

## 12. Giao diện
- **Là gì:** Material 3, chế độ sáng/tối, giao diện admin riêng, thanh điều hướng dưới, màn hình thích ứng cỡ máy.
- **Công nghệ:** Flutter, Riverpod, go_router.
- **File:** `lib/app.dart`, `lib/screens/main_shell.dart`, `lib/screens/design_v2_widgets.dart`.

## 13. Cơ sở dữ liệu và hạ tầng
- **SQLite** một file `backend/data/lifequest.db`, 10 bảng: `users`, `groups_`, `group_members`, `quests`, `quest_steps`, `notifications`, `reports`, `blocks`, `ai_requests`, `messages`.
- **Migration tự động** theo `PRAGMA user_version` (`backend/sql/001_init.sql`, `002_password_changed.sql`, `003_messages.sql`), **dữ liệu mẫu** tự nạp (`backend/src/seed.js`: 6 tài khoản, 3 nhóm, nhiệm vụ cá nhân và nhóm, tin nhắn).
- Điện thoại và máy ảo Android Studio đều gọi **cùng một backend** nên dùng chung một CSDL.

## 14. Kiểm thử
- Flutter: 33 test (`test/*.dart`), chạy `flutter test`.
- Backend: 15 test (`backend/test/api.test.js`), chạy `cd backend && npm test`.
- Phân tích tĩnh: `flutter analyze`.

## Tổng hợp công nghệ

| Lớp | Công nghệ |
|---|---|
| Di động | Flutter 3.35, Dart 3.9, Material 3 |
| Trạng thái / điều hướng | Riverpod, go_router |
| Mạng / lưu cục bộ | Dio, shared_preferences |
| Camera/ảnh | image_picker |
| Backend | Node.js 24, Express 4 |
| CSDL | SQLite (`node:sqlite`) |
| Bảo mật | JWT, bcrypt, SHA-256, zod |
| Thời gian thực | Server-Sent Events |
| AI | Google Gemini API (văn bản và ảnh) |
