# 📘 HƯỚNG DẪN KIẾN TRÚC & PHẠM VI DỰ ÁN LIFEQUEST (DÀNH CHO CODEX)

> **Dự án:** LifeQuest – Ứng dụng Quản lý & Gamification Nhiệm vụ đời thường (Đồ án Lập trình Thiết bị Di động)  
> **Sinh viên thực hiện:** Nguyễn Viết Lãm  
> **Ngăn xếp công nghệ (Tech Stack):**  
> - **Frontend:** Flutter (Dart), Flutter Riverpod (`StateNotifier`/`ChangeNotifierProvider`), Dio, Shared Preferences.  
> - **Backend:** Node.js (Express) + SQLite (`node:sqlite`) chạy tại thư mục `backend/` (cổng 3000).  
> - **Realtime:** Server-Sent Events (SSE) tại `/api/groups/:id/events?token=<jwt>`.

---

## ⚠️ 1. NGUYÊN TẮC CỐT LÕI (BẮT BUỘC TUÂN THỦ 100%)

1. **TUYỆT ĐỐI KHÔNG CÀI ĐẶT HOẶC SỬ DỤNG SUPABASE, FIREBASE:**  
   Backend của dự án là một REST API Node.js tự xây dựng trong thư mục `backend/`. Không import bất kỳ package nào như `supabase_flutter`, `firebase_core`, `cloud_firestore`. Mọi dữ liệu đi qua `lib/api/api_client.dart`.
2. **KHÔNG TỰ Ý SỬA BACKEND (`backend/`):**  
   Backend đã hoàn chỉnh 12/12 test (`cd backend && npm test`). Mọi thay đổi chỉ được thực hiện trong `lib/`, `test/`, `pubspec.yaml`.
3. **GIỮ VỮNG CHUẨN KIỂM THỬ:**  
   Trước khi kết thúc bất kỳ lượt làm việc nào, PHẢI đảm bảo:
   - `flutter analyze`: Không có lỗi (0 issues).
   - `flutter test`: Toàn bộ 14 tests đều PASS.

---

## 🗺️ 2. BẢN ĐỒ MÃ NGUỒN (CODEBASE MAP)

### A. Tầng Dữ liệu & Mạng (Core & State)
- **`lib/api/api_client.dart`**: Lớp gọi HTTP bằng `Dio`, tự động gán Bearer Token, bắt lỗi `ApiException`, quản lý stream SSE `subscribeGroupEvents()`.
- **`lib/api/api_exception.dart`**: Mô hình hóa lỗi từ backend (400, 401, 403, 404, 422, 429).
- **`lib/models.dart`**: Khai báo các thực thể chính: `AppUser`, `UserStats`, `Quest`, `QuestStep`, `QuestGroup`, `GroupMember`, `AppNotification`, `AiQuestDraft`, `BlockedUser`.
- **`lib/app_controller.dart`**: Quản lý trạng thái toàn cục ứng dụng (Authentication, Quests CRUD, Gamification XP/Streak, Groups & Realtime SSE, AI Plans, Safety Reports, Blocked Users).

### B. Màn hình Giao diện (`lib/screens/`)
- **`auth_screens.dart`**: Màn hình đăng nhập, đăng ký, quên mật khẩu / tài khoản demo.
- **`home_screen.dart`**: Màn hình chính phong cách Novara Alpine (Hero Banner, 5 Trụ cột đời thường, Ma trận thói quen 7 ngày, Thanh tiến trình Level, Nhiệm vụ ưu tiên, Dashboard riêng cho Admin).
- **`quests_screen.dart` & `quest_widgets.dart`**: Danh sách nhiệm vụ (tìm kiếm, lọc Active/Completed/Archived), chi tiết nhiệm vụ (Checklist toggle bước, hoàn thành nhận XP một lần idempotent), tạo/sửa/xóa nhiệm vụ.
- **`groups_screen.dart`**: Danh sách nhóm, tham gia bằng mã mời (`inviteCode`), chi tiết nhóm, danh sách thành viên, nhiệm vụ nhóm, realtime SSE lắng nghe cập nhật.
- **`ai_screen.dart`**: Trợ lý AI đề xuất kế hoạch theo mục tiêu và độ khó (3, 5, 7 bước), bộ lọc an toàn 422 (chặn nội dung độc hại), review bản nháp trước khi lưu.
- **`profile_screen.dart`**: Hồ sơ người dùng, đổi mật khẩu, bật tắt dark mode, danh sách huy hiệu (Badges), danh sách tài khoản đã chặn.
- **`admin_screen.dart`**: Bảng điều khiển quản trị viên (giám sát báo cáo an toàn, kiểm duyệt nội dung).

---

## 🎯 3. TÌNH TRẠNG HIỆN TẠI & NHIỆM VỤ TIẾP THEO (NEXT TASKS)

### Việc đã hoàn thành (Ổn định 100%):
- Hệ thống Auth, đổi mật khẩu, tự động đăng nhập.
- Quản lý Quest & Checklist con, tính toán XP và Level.
- Kết nối SSE nhóm thời gian thực.
- Bộ lọc an toàn AI 422 & Mock Fallback.
- Toàn bộ 14/14 Unit & Widget Tests đạt chuẩn.

### Nhiệm vụ tiếp theo cần nâng cấp (Design System v2):
1. **`AnimatedCounter`**: Hiệu ứng chuyển số nhảy mượt mà (smooth easing animation) khi điểm XP tăng hoặc Streak tăng trong `home_screen.dart`.
2. **`ProgressRing`**: Thay thế thanh tiến trình Linear phẳng bằng vòng tròn tiến trình neon 3D hiển thị % hoàn thành nhiệm vụ và cấp độ.
3. **`Quest Discovery`**: Bổ sung bộ lọc nhanh theo 5 chủ đề trụ cột (Thể thao/Sức khỏe, Học tập, Kỷ luật, Đồng đội, Cân bằng) trong `quests_screen.dart`.
4. **Chia sẻ mã mời nhóm (Group Invite Code)**: Thêm nút copy nhanh 1-chạm hoặc dialog mã mời đẹp mắt cho chủ nhóm trong `groups_screen.dart`.

---

## 🧪 4. LỆNH KIỂM TRA MÔI TRƯỜNG

```bash
# Phân tích tĩnh code Dart (bắt buộc 0 lỗi):
flutter analyze

# Chạy toàn bộ 14 test cases:
flutter test

# Khởi chạy backend local khi cần:
cd backend && npm start
```

