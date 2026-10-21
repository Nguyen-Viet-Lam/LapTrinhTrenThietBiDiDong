---
title: "BÁO CÁO ĐỒ ÁN CUỐI KỲ"
---

**TRƯỜNG: [CHÈN TÊN TRƯỜNG] – KHOA/VIỆN: [CHÈN KHOA/VIỆN]**

**Học phần:** Lập trình trên thiết bị di động (ECMP177)

**Đề tài:** LifeQuest – Ứng dụng nhiệm vụ đời thường an toàn có tích hợp AI và đồng bộ nhóm trên thiết bị di động

**Thành viên:** [Họ tên – MSSV] ; [Họ tên – MSSV]

**Lớp/Nhóm:** [CHÈN LỚP / NHÓM]

**Giảng viên phụ trách:** [CHÈN TÊN GIẢNG VIÊN]

**Học kỳ – Năm học:** [CHÈN HỌC KỲ – NĂM HỌC]

\newpage

# 1. Kết quả thực nghiệm

## 1.1. Tổng hợp chức năng và công nghệ

**Link dự án (public):** <https://github.com/Nguyen-Viet-Lam/LapTrinhTrenThietBiDiDong>

### a. Công nghệ sử dụng

| Thành phần | Công nghệ/Thư viện | Mục đích sử dụng |
|---|---|---|
| Mobile App | Flutter / Dart (Material 3) | Xây dựng ứng dụng di động Android/iOS/Web |
| Backend/API | Node.js + Express (thư mục `backend/`) | REST API cho tài khoản, quest, nhóm, AI, thông báo, an toàn |
| Cơ sở dữ liệu | SQLite (`node:sqlite`), 9 bảng có khóa ngoại | Lưu trữ người dùng, quest, nhóm, thông báo, báo cáo |
| Authentication | JWT + bcrypt | Đăng ký, đăng nhập, băm mật khẩu, bảo vệ API |
| Realtime | Server-Sent Events (SSE) | Đẩy sự kiện đồng bộ quest/thành viên trong nhóm |
| AI | Gemini API (phía server) + chế độ mock an toàn | Gợi ý chia nhỏ mục tiêu thành quest |
| Validation | Zod | Kiểm tra dữ liệu đầu vào ở API |
| State Management | Riverpod, GoRouter | Quản lý trạng thái và điều hướng ứng dụng |
| Local Storage | SharedPreferences | Lưu dữ liệu cục bộ ở chế độ Demo Local |
| Triển khai web | Firebase Hosting | Bản demo web: https://flutter-firebase-6b5af.web.app |
| Kiểm thử | flutter_test, node:test | Unit/widget test và test tích hợp API |

### b. Tổng hợp chức năng

> Cột "Trạng thái" phản ánh đúng hiện trạng: **Backend** = đã có API + DB và có test tự động; **App** = giao diện Flutter hiện chạy ở Demo Local Mode (dữ liệu lưu trên thiết bị). Việc nối giao diện Flutter với API do thành viên phụ trách giao diện thực hiện sau.

| STT | Module | Chức năng | Backend/API | Giao diện App |
|---|---|---|---|---|
| 1 | Tài khoản | Đăng ký | Hoàn thành | Hoàn thành (local) |
| 2 | Tài khoản | Đăng nhập / phiên JWT 7 ngày | Hoàn thành | Hoàn thành (local) |
| 3 | Tài khoản | Onboarding, cập nhật hồ sơ, dark mode | Hoàn thành | Hoàn thành (local) |
| 4 | Tài khoản | Xóa tài khoản (xóa toàn bộ dữ liệu liên quan) | Hoàn thành | Hoàn thành (local) |
| 5 | Quest | Tạo quest + checklist + hạn chót | Hoàn thành | Hoàn thành (local) |
| 6 | Quest | Tìm kiếm, lọc theo trạng thái/nhóm | Hoàn thành | Hoàn thành (local) |
| 7 | Quest | Đánh dấu bước, sửa quest, lưu trữ, xóa | Hoàn thành | Sửa/xóa quest: chưa có trên giao diện |
| 8 | Gamification | Hoàn thành quest → XP, level, streak (cộng đúng 1 lần) | Hoàn thành | Hoàn thành (local) |
| 9 | Gamification | Huy hiệu, thống kê | Hoàn thành | Hiển thị cơ bản |
| 10 | Nhóm | Tạo nhóm, mã mời (lưu hash, hết hạn 7 ngày), tham gia | Hoàn thành | Hoàn thành (local) |
| 11 | Nhóm | Rời nhóm, xóa thành viên, chuyển quyền, xóa nhóm | Hoàn thành | Chỉ có rời nhóm |
| 12 | Nhóm | Quest nhóm, giao việc cho thành viên | Hoàn thành | Quest nhóm cơ bản |
| 13 | Nhóm | Đồng bộ thời gian thực giữa thiết bị (SSE) | Hoàn thành (chưa có test tự động) | **Chưa nối** |
| 14 | AI | Sinh bản nháp quest, người dùng duyệt trước khi lưu | Hoàn thành (mock; Gemini khi có API key) | Hoàn thành (mock local) |
| 15 | AI | Chặn nội dung nguy hiểm, giới hạn tần suất gọi | Hoàn thành | Chặn từ khóa ở local |
| 16 | Thông báo | Danh sách, đánh dấu đã đọc | Hoàn thành | Hoàn thành (local) |
| 17 | An toàn | Báo cáo vi phạm, chặn người dùng | Hoàn thành | Hoàn thành (local) |
| 18 | Thông báo | Push notification (FCM) / nhắc hạn trên hệ điều hành | Chưa xây dựng | Chưa xây dựng |
| 19 | Tài khoản | Đăng nhập Google, quên mật khẩu, xác minh email | Chưa xây dựng | Chưa xây dựng |
| 20 | Hệ thống | Kết nối app Flutter ↔ REST API | Sẵn sàng | **Chưa hoàn thiện** |

## 1.2. Minh họa chi tiết các chức năng

> Ảnh minh họa: chạy `flutter run` hoặc mở bản web, chụp màn hình và thay các dòng `[CHÈN ẢNH …]`. Hai ảnh đã có sẵn: `docs/screenshots/login.png`, `docs/screenshots/home.png`.

### Chức năng 1: Đăng ký / Đăng nhập

![Màn hình đăng nhập](docs/screenshots/login.png){width=40%}

**Mô tả:** Người dùng nhập email và mật khẩu (tối thiểu 6 ký tự) để đăng nhập, hoặc chuyển sang tab đăng ký để tạo tài khoản mới. Dữ liệu sai định dạng hoặc sai mật khẩu bị từ chối kèm thông báo. Ở phía API, mật khẩu được băm bằng bcrypt, email là duy nhất (trùng email trả 409), đăng nhập thành công trả về JWT hết hạn sau 7 ngày dùng cho mọi API còn lại. Tài khoản demo: `demo@lifequest.vn` / `123456`.

### Chức năng 2: Trang chủ – XP, level, streak

![Trang chủ](docs/screenshots/home.png){width=40%}

**Mô tả:** Trang chủ hiển thị tên người dùng, XP, cấp độ, chuỗi ngày liên tiếp (streak), huy hiệu và các quest ưu tiên. Cấp độ tính theo `level = floor(sqrt(xp/100)) + 1`. API `GET /api/stats` cung cấp cùng dữ liệu này cho app: XP còn thiếu để lên cấp, số quest đang làm/hoàn thành/lưu trữ.

### Chức năng 3: Tạo và quản lý quest

[CHÈN ẢNH: màn hình danh sách quest và form tạo quest]

**Mô tả:** Người dùng nhập tiêu đề, mô tả, danh mục, độ khó, hạn chót và danh sách các bước. Quest xuất hiện trong danh sách, có thể tìm kiếm theo từ khóa và lọc theo trạng thái. Độ khó quyết định XP thưởng: dễ 20, vừa 40, khó 70. Thanh tiến độ tăng khi đánh dấu từng bước. Người ngoài không thể xem hay sửa quest của người khác (API trả 404).

### Chức năng 4: Hoàn thành quest và nhận XP

[CHÈN ẢNH: hộp thoại/thông báo nhận XP sau khi hoàn thành quest]

**Mô tả:** Khi bấm hoàn thành, hệ thống đánh dấu toàn bộ bước xong, cộng XP, cập nhật cấp độ và streak (tăng tối đa một lần mỗi ngày, bỏ lỡ một ngày thì về 1). Việc cộng điểm nằm trong một transaction CSDL nên bấm nhiều lần hoặc gọi lặp API chỉ cộng XP **một lần** (lần sau trả `idempotent: true`, `xpAwarded: 0`). Test tự động kiểm chứng điều này.

### Chức năng 5: Gợi ý quest bằng AI

[CHÈN ẢNH: màn hình AI – nhập mục tiêu, bản nháp, nút lưu]

**Mô tả:** Người dùng nhập mục tiêu (ví dụ "Ôn thi Flutter trong 7 ngày") và chọn độ khó; AI trả về bản nháp gồm tiêu đề, mô tả, các bước (3/5/7 bước theo độ khó ở chế độ mock) và lưu ý an toàn. AI **không tự lưu** – người dùng xem, chỉnh rồi mới lưu thành quest. Mục tiêu chứa nội dung nguy hiểm (tự hại, bạo lực…) bị từ chối (422), gọi quá nhanh bị giới hạn (429). Khóa Gemini chỉ nằm ở server; khi chưa có khóa, backend dùng kế hoạch mock nên demo vẫn ổn định.

### Chức năng 6: Nhóm và quest nhóm

[CHÈN ẢNH: danh sách nhóm, chi tiết nhóm với mã mời và thành viên]

**Mô tả:** Người dùng tạo nhóm và nhận mã mời; bạn bè nhập mã để tham gia (mã sai trả 404, hết hạn trả 410). Thành viên tạo và xem quest chung, có thể giao quest cho một thành viên. Trưởng nhóm được xóa thành viên, chuyển quyền hoặc xóa nhóm; trưởng nhóm không thể rời nhóm khi chưa chuyển quyền; người ngoài nhóm không tạo được quest nhóm (403). Mã mời trong CSDL được lưu dưới dạng hash SHA-256.

### Chức năng 7: Đồng bộ nhóm thời gian thực

[CHÈN ẢNH: hai thiết bị cùng thấy quest nhóm cập nhật – cần hoàn tất bước nối app với API]

**Mô tả:** API `GET /api/groups/:id/events` mở kết nối SSE; mỗi khi có thành viên tạo, cập nhật, hoàn thành quest hoặc vào/ra nhóm, server đẩy sự kiện cho mọi thiết bị đang mở nhóm để app tải lại dữ liệu. **Trạng thái:** phần server đã viết, nhưng giao diện Flutter chưa kết nối nên chưa có minh họa trên thiết bị.

### Chức năng 8: Thông báo, báo cáo và chặn người dùng

[CHÈN ẢNH: Notification center, Safety Center, hộp thoại báo cáo]

**Mô tả:** Thông báo được tạo khi đăng ký, hoàn thành quest, được giao quest hoặc có thành viên mới vào nhóm; người dùng xem danh sách và bấm "đọc tất cả". Ở Safety Center, người dùng báo cáo nội dung/thành viên kèm lý do (tối đa 500 ký tự) và chặn người dùng khác; danh sách chặn có thể gỡ.

### Chức năng 9: Cài đặt, chế độ tối và xóa tài khoản

[CHÈN ẢNH: màn hình Cá nhân ở chế độ sáng và tối]

**Mô tả:** Người dùng đổi tên hiển thị, sở thích, bật/tắt thông báo và chế độ tối (lưu trong hồ sơ). Xóa tài khoản xóa toàn bộ quest, nhóm, thông báo của người đó nhờ ràng buộc `ON DELETE CASCADE`; token cũ lập tức không còn dùng được (401).

### Kết quả kiểm thử thực tế

| Hạng mục | Lệnh | Kết quả |
|---|---|---|
| API + CSDL | `cd backend && npm test` | **7/7 test đạt** (công thức level, xác thực, quest + XP idempotent, phân quyền, nhóm, AI, thông báo/báo cáo/chặn/xóa tài khoản) |
| Flutter | `flutter analyze`, `flutter test` | `flutter analyze`: không có lỗi; `flutter test`: **7/7 test đạt** |

# 2. Kết luận

**Đã hoàn thành:** Backend REST API đầy đủ nghiệp vụ (tài khoản JWT, quest, XP/streak idempotent, nhóm có phân quyền, AI an toàn, thông báo, báo cáo/chặn) với CSDL SQLite có khóa ngoại và bộ test tự động; ứng dụng Flutter chạy đủ luồng ở Demo Local Mode và đã triển khai bản web.

**Còn hạn chế:** Giao diện Flutter chưa gọi REST API nên dữ liệu chưa đồng bộ giữa các thiết bị; SSE chưa có test tự động và chưa dùng trên app; AI mặc định là mock nếu chưa cấu hình `GEMINI_API_KEY`; chưa có push notification, đăng nhập Google, quên mật khẩu, sửa quest/quản trị nhóm trên giao diện; backend chưa được triển khai lên máy chủ công cộng.

**Hướng phát triển:** nối app với API (Dio + lưu JWT, dùng SSE cho nhóm), triển khai backend lên dịch vụ cloud với PostgreSQL/MySQL, thêm FCM và nhắc hạn, đăng nhập Google, chat nhóm, trang quản trị xử lý báo cáo.
