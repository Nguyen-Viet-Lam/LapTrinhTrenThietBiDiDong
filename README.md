# LifeQuest – Ứng dụng Quản lý Mục tiêu & Gamification

> **Học phần:** Lập trình trên thiết bị di động (ECMP177)  
> **Trường Đại học Công nghệ TP.HCM (HUTECH)**  
> **Giảng viên hướng dẫn:** ThS. Trần Đăng Khoa  
> **Lớp học phần:** 23DTHB6 – **Nhóm thực hiện:** Nhóm 10  
>
> **Thành viên nhóm:**
> 1. **Nguyễn Viết Lãm** (Trưởng nhóm) – MSSV: `2380601183`
> 2. **Nguyễn Đại Kỳ** – MSSV: `2380601178`
> 3. **Trần Ngọc Lợi** – MSSV: `2380601292`
> 4. **Châu Tuấn** – MSSV: `2380602434`

---

## 🌟 Giới thiệu sản phẩm

**LifeQuest** là ứng dụng di động gamification hóa quá trình rèn luyện mục tiêu đời thường của sinh viên, kết hợp Trợ lý Trí tuệ Nhân tạo (AI Vision & Planner), không gian CLB nhóm đồng bộ thời gian thực (Server-Sent Events) và Bảng điều khiển Quản trị viên (Admin Dashboard) theo kiến trúc Client-Server độc lập.

### Các phân hệ cốt lõi:
1. **Gamification V2:** Cấp độ, Điểm kinh nghiệm (XP), Chuỗi ngày kỷ luật (Streak), 5 Trụ cột đời sống, Cơ chế Idempotent Transaction chống gian lận điểm số.
2. **Quản lý Nhiệm vụ & Checklist:** Phân loại độ khó (Dễ 20 XP, Vừa 40 XP, Khó 70 XP), bộ lọc trạng thái (*Đang làm, Đã xong, Lưu trữ*), checklist nhiệm vụ con.
3. **Trợ lý AI Thông minh (Gemini API & Vision):** Nhận diện bối cảnh ảnh đời thực (sân cầu lông, gym, học tập), phân rã mục tiêu thành kế hoạch 3/5/7 bước với nguyên tắc *Review-before-save* và bộ lọc an toàn (Safety Moderation HTTP 422).
4. **CLB Nhóm & Giao tiếp Thời gian thực:** Mã mời bảo mật SHA-256, kênh thảo luận nhóm, tin nhắn mẫu rủ đi chơi 1-chạm, đồng bộ sự kiện qua Server-Sent Events (SSE < 50ms).
5. **Bảng điều khiển Quản trị viên (Admin Dashboard):** Thiết kế kính *Deep Ocean Glass*, phân quyền nghiêm ngặt RBAC qua JWT, giám sát tiến độ thành viên toàn hệ thống và xử lý khóa tài khoản vi phạm.

---

## 🚀 Hướng dẫn cài đặt & Khởi chạy nhanh (Quick Start)

### Cách 1: Khởi chạy 1-chạm tự động (Khuyên dùng trên Windows)
Chỉ cần nhấp đúp hoặc chạy file kịch bản tự động trong thư mục gốc:
```powershell
.\chay_local.bat
```
*Script sẽ tự động cài đặt `npm install`, khởi chạy máy chủ Backend REST API tại cổng `3000`, tải gói `flutter pub get` và mở app trên thiết bị đang kết nối.*

---

### Cách 2: Khởi chạy thủ công từng bước

#### Bước 1: Khởi động Backend REST API & CSDL SQLite
```bash
cd backend
npm install
npm start
```
*Máy chủ backend sẽ chạy tại: `http://localhost:3000` (hoặc `http://10.0.2.2:3000` đối với Android Emulator). CSDL SQLite 9 bảng tuân thủ ACID tự động khởi tạo dữ liệu mẫu.*

#### Bước 2: Khởi chạy Ứng dụng Di động Flutter
Mở một cửa sổ dòng lệnh mới tại thư mục gốc của dự án:
```bash
flutter pub get
flutter run
```

---

## 👥 Tài khoản kiểm thử nhanh (Demo Accounts)

Trên màn hình Đăng nhập của ứng dụng, hệ thống đã tích hợp sẵn **2 nút bấm 1-chạm** để Thầy và người chấm thi có thể vào ngay mà không cần gõ bàn phím:

* **Tài khoản Người dùng (User Kỳ):**
  * Email: `ky@lifequest.vn` | Mật khẩu: `123456`
  * Nút bấm nhanh: Bấm vào chip **`[ 👤 User: Kỳ ]`** $\rightarrow$ Bấm **Đăng nhập**.
  * Quyền hạn: Trải nghiệm toàn bộ Gamification, Làm nhiệm vụ, Tích checklist nhận XP, Dùng trợ lý AI, Tham gia nhóm.

* **Tài khoản Quản trị viên (Admin Lãm):**
  * Email: `lam@lifequest.vn` | Mật khẩu: `123456`
  * Nút bấm nhanh: Bấm vào chip **`[ 🛡️ Admin: Lãm ]`** $\rightarrow$ Bấm **Đăng nhập**.
  * Quyền hạn: Bảng điều khiển Deep Ocean Glass, giám sát tiến độ 4 thành viên, theo dõi 4 nhiệm vụ đang chạy, Trung tâm kiểm duyệt nội dung.

---

## 🧪 Kết quả Kiểm thử Tự động (Testing & Quality Assurance)

Dự án tuân thủ nghiêm ngặt quy trình kiểm thử tự động với tỷ lệ hoàn thành 100%:

```bash
# 1. Kiểm tra tĩnh mã nguồn Dart/Flutter
flutter analyze
# Kết quả: No issues found! (0 cảnh báo, 0 lỗi)

# 2. Kiểm thử Unit & Widget Frontend Flutter (38 test cases)
flutter test
# Kết quả: All tests passed! (38/38 PASS 100%)

# 3. Kiểm thử tích hợp Backend REST API & Database (12 test suites)
cd backend && npm test
# Kết quả: 12 pass, 0 fail (12/12 PASS 100%)
```

---

## 🛠️ Kiến trúc Công nghệ sử dụng (Technology Stack)

| Thành phần | Công nghệ / Thư viện | Mục đích sử dụng |
| :--- | :--- | :--- |
| **Mobile App (Frontend)** | Flutter 3.x / Dart (Material 3) | Ứng dụng di động đa nền tảng, thiết kế Modern Glassmorphism |
| **Quản lý Trạng thái** | Riverpod 2.x | Quản lý state phản ứng, tối ưu rebuild và vòng đời widget |
| **Điều hướng (Routing)** | GoRouter | Quản lý điều hướng khai báo và bảo vệ luồng phân quyền |
| **Backend & API** | Node.js + Express | Xây dựng RESTful API chuẩn mực, xử lý logic nghiệp vụ |
| **Cơ sở dữ liệu** | SQLite (Embedded RDBMS) | Lưu trữ quan hệ 9 bảng, quản lý phiên bản migration tự động, tuân thủ ACID |
| **Thời gian thực (Realtime)** | Server-Sent Events (SSE) | Đẩy sự kiện nhóm và tin nhắn thảo luận tức thời (< 50ms, tiết kiệm pin) |
| **Trí tuệ Nhân tạo (AI)** | Google Gemini API | Phân rã mục tiêu thông minh & phân tích ảnh bối cảnh thị giác |
| **Bảo mật & Phân quyền** | JWT, bcrypt, SHA-256 | Xác thực phân quyền RBAC (User / Admin), băm mật khẩu và mã mời |
| **Lưu trữ Cục bộ** | SharedPreferences | Lưu trữ JWT token và cài đặt giao diện Dark Mode |

---

## 🎬 Video Demo & Tài liệu Báo cáo

* **Video Demo thực tế:** Video quay liền mạch từ Đăng ký, Đăng nhập, Gamification, AI đến Quản trị Admin được ghi hình trực tiếp trên Pixel 9 Android Studio Emulator.
* **Mã nguồn GitHub:** `https://github.com/Nguyen-Viet-Lam/LapTrinhTrenThietBiDiDong.git`
