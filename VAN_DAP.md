# Tài liệu vấn đáp – LifeQuest (Nhóm 10)

## 1. Ý tưởng đồ án
LifeQuest biến việc rèn luyện mục tiêu đời thường của sinh viên thành trò chơi (gamification):
- Mỗi **nhiệm vụ** có độ khó (Dễ 20 XP, Vừa 40 XP, Khó 70 XP) và **checklist** các bước nhỏ.
- Hoàn thành nhiệm vụ nhận **XP** → lên **cấp** (level), duy trì **chuỗi ngày** (streak), mở **huy hiệu**.
- **Trợ lý AI** chia mục tiêu thành kế hoạch từng bước; **AI Thị giác** nhìn ảnh chụp thật (sân cầu lông, bàn học...) rồi gợi ý nhiệm vụ phù hợp.
- **CLB nhóm**: tạo/tham gia nhóm bằng mã mời, giao nhiệm vụ nhóm, chat nhóm và chat 1-1, cập nhật gần thời gian thực.
- **Admin**: giao diện quản trị riêng, kiểm duyệt nội dung, khóa tài khoản vi phạm.

## 2. Công nghệ sử dụng và lý do chọn

| Lớp | Công nghệ | Dùng để làm gì / vì sao chọn |
|---|---|---|
| Ứng dụng di động | **Flutter 3.35 / Dart 3.9**, Material 3 | Một codebase chạy Android (và web), giao diện tự vẽ, hot reload |
| Quản lý trạng thái | **Riverpod** + `ChangeNotifier` (`AppController`) | Một controller trung tâm, widget tự cập nhật khi dữ liệu đổi |
| Điều hướng | **go_router** | Điều hướng khai báo, `redirect` chặn người chưa đăng nhập/chưa onboarding |
| Gọi API | **Dio** | HTTP client, gắn JWT, timeout, bắt lỗi 401 để đăng xuất |
| Lưu cục bộ | **shared_preferences** | Lưu JWT token |
| Camera/thư viện ảnh | **image_picker** | Chụp hoặc chọn ảnh cho AI Thị giác |
| Backend | **Node.js 24 + Express 4** | REST API gọn, dễ trình bày |
| Cơ sở dữ liệu | **SQLite** (`node:sqlite` có sẵn trong Node) | Một file `backend/data/lifequest.db`, quan hệ 10 bảng, khóa ngoại + `ON DELETE CASCADE`, ACID |
| Migration | File `backend/sql/NNN_*.sql` + `PRAGMA user_version` | Mỗi file chạy đúng một lần, thêm cột = thêm file mới |
| Xác thực | **JWT** (hết hạn 7 ngày) + **bcrypt** | Token ký bằng secret; mật khẩu băm một chiều |
| Kiểm tra dữ liệu vào | **zod** | Validate mọi body request, trả 400 rõ lý do |
| Realtime | **Server-Sent Events (SSE)** | Backend đẩy sự kiện nhóm (thành viên mới, quest hoàn thành, tin nhắn) xuống app; nhẹ hơn WebSocket vì chỉ cần một chiều |
| AI | **Google Gemini API** (văn bản + ảnh) | Chia kế hoạch, nhận diện bối cảnh ảnh |
| Mã mời nhóm | **SHA-256** | DB chỉ so khớp bằng hash của mã mời |
| Kiểm thử | `flutter_test` (33 test), `node --test` (15 test) | Unit + widget + tích hợp API |

## 3. Kiến trúc tổng thể
```
Điện thoại (Flutter) ──HTTP/JSON + SSE──► Backend Express ──► SQLite (lifequest.db)
                                              └──► Gemini API (AI văn bản + ảnh)
```
- App **không giữ CSDL riêng**: mọi dữ liệu nằm ở SQLite trên máy chạy backend. Điện thoại và máy tính cùng gọi API nên thấy cùng dữ liệu.
- Điện thoại gọi backend qua Wi-Fi (`API_BASE_URL=http://<IP máy tính>:3000/api`); máy ảo Android dùng `10.0.2.2`.

## 4. Các ý tưởng kỹ thuật nên nắm

1. **Hoàn thành nhiệm vụ idempotent** (`backend/src/app.js`, route `/quests/:id/complete`): bấm hoàn thành nhiều lần chỉ cộng XP một lần. Làm bằng transaction `tx(db, ...)` + cờ `xp_awarded`; lần gọi sau trả `idempotent: true`, `xpAwarded: 0`. Chống gian lận và lỗi double-click/mạng chập chờn.
2. **Công thức cấp độ:** `level = floor(sqrt(xp / 100)) + 1` – lên cấp càng về sau càng cần nhiều XP.
3. **Streak:** hoạt động hôm qua → +1; cách ngày → về 1; cùng ngày → giữ nguyên.
4. **Phân quyền (RBAC):** middleware `auth` xác thực JWT; chỉ chủ nhóm mới xóa nhóm/chuyển quyền; người ngoài không đọc được quest hay chat của nhóm (trả 404 để không lộ sự tồn tại).
5. **Chống brute-force:** sai mật khẩu quá 5 lần bị khóa 15 phút (HTTP 429). AI có thời gian chờ giữa các lần gọi (cooldown).
6. **An toàn nội dung AI:** danh sách từ cấm → HTTP 422 trước khi gọi AI; prompt dặn AI bỏ qua chỉ dẫn nằm trong ảnh/ghi chú (chống prompt injection); kết quả AI được validate bằng zod.
7. **Review-before-save:** AI chỉ tạo **bản nháp**, người dùng xem và sửa rồi mới lưu thành nhiệm vụ.
8. **AI Thị giác:** app nén ảnh (≤1200px), mã hóa base64 gửi `/api/ai/vision-plan`; backend gửi ảnh + prompt cho Gemini, nhận JSON gồm bối cảnh nhận diện và các bước. Có **chuỗi model dự phòng** (`callGemini` trong `backend/src/ai.js`): model quá tải (503/429) hoặc quá thời gian thì tự thử model kế tiếp.
9. **SSE realtime:** app mở `/api/groups/:id/events`; backend giữ danh sách kết nối theo nhóm (`hub`) và `emit` khi có sự kiện; app nhận `message.created` thì tải lại tin nhắn.
10. **Chat lưu DB:** bảng `messages` dùng chung cho chat nhóm (`group_id`) và 1-1 (`receiver_id`), ràng buộc `CHECK` đảm bảo đúng một trong hai.
11. **Migration tự động:** khởi động backend → so `user_version` với số file `sql/`, chạy file còn thiếu trong transaction.
12. **Seed dữ liệu mẫu:** `backend/src/seed.js` chạy idempotent (có sẵn thì bỏ qua), tạo 6 tài khoản, 3 CLB, nhiệm vụ, tin nhắn.
13. **Xử lý 401 toàn cục:** Dio nhận 401 → `handleUnauthorized()` xóa token, router redirect về đăng nhập.

## 5. Cơ sở dữ liệu (10 bảng)
`users`, `groups_`, `group_members`, `quests`, `quest_steps`, `notifications`, `reports`, `blocks`, `ai_requests`, `messages`.
Quan hệ chính: `users 1-n quests`, `groups_ n-n users` qua `group_members`, `quests 1-n quest_steps`, `messages` thuộc nhóm hoặc giữa hai user.
Schema ở `backend/sql/001_init.sql`, `002_password_changed.sql`, `003_messages.sql`.

## 6. Những điểm hạn chế (nên nói thật nếu được hỏi)
- Backend chạy trên máy tính, **chưa triển khai lên cloud**; app chỉ dùng được khi cùng mạng với máy chạy backend.
- **Chưa có chế độ offline**: mất mạng thì app không tải/lưu được dữ liệu.
- **Admin Dashboard** hiện hiển thị danh sách thành viên/nhiệm vụ bằng **dữ liệu cứng trong code** (`admin_screen.dart`, `home_screen.dart`), chưa đọc từ DB; các số như "4.9/5 Đánh giá AI Plan" ở trang chủ cũng là chữ ghi cứng.
- Vai trò admin hiện được xác định bằng email (`lam@lifequest.vn` hoặc email chứa `admin`) trong `userDto`, chưa có cột `role` trong DB.
- API key Gemini nằm trong `backend/.env` trên máy chủ (không nằm trong app); nếu lộ thì phải tạo lại.
- Tin nhắn 1-1 cập nhật bằng truy vấn định kỳ mỗi 4 giây (chưa dùng SSE cho 1-1).

## 7. Câu hỏi vấn đáp thường gặp

| Câu hỏi | Gợi ý trả lời | Người trả lời |
|---|---|---|
| Vì sao dùng SQLite thay vì Firebase/MySQL? | Gọn, một file, đủ ACID/khóa ngoại cho đồ án, không cần cài server; cú pháp gần chuẩn nên dễ chuyển MySQL/PostgreSQL. Đồng bộ nhờ cả hai thiết bị cùng gọi một API. | Lãm |
| Vì sao SSE mà không WebSocket? | Chỉ cần server đẩy xuống, SSE nhẹ, tự kết nối lại, chạy trên HTTP thường. | Lãm |
| JWT hoạt động thế nào? | Đăng nhập đúng → server ký token chứa `sub` = id user, hạn 7 ngày; app lưu và gắn vào header `Authorization`. | Lãm / Tuấn |
| Idempotent là gì, áp dụng ở đâu? | Gọi nhiều lần cho cùng kết quả; áp dụng ở hoàn thành nhiệm vụ để không cộng XP trùng. | Kỳ |
| XP, level, streak tính thế nào? | Xem mục 4 (công thức level, streak). | Kỳ |
| AI Thị giác hoạt động ra sao? | Mục 4, ý 8. | Lợi |
| Làm sao tránh AI trả nội dung nguy hiểm? | Từ cấm → 422; prompt giới hạn; validate JSON; người dùng duyệt trước khi lưu. | Lợi |
| Nếu Gemini quá tải thì sao? | Tự thử model dự phòng; vẫn lỗi thì báo 502, app hiển thị thông báo, không lưu gì. | Lợi |
| Quản lý trạng thái trong app? | `AppController` (ChangeNotifier) + Riverpod; màn hình `watch` để tự vẽ lại. | Kỳ |
| Kiểm thử gồm những gì? | 33 test Flutter (unit/widget) + 15 test backend (API, quyền, SSE, migration, tin nhắn). | Tuấn |
| Mật khẩu lưu thế nào? | Băm bcrypt, không lưu bản rõ. | Tuấn |
