# NỘI DUNG SLIDE THUYẾT TRÌNH CANVA (9 SLIDE CHUẨN ĐỒ ÁN)
**Học phần:** Lập trình trên thiết bị di động (ECMP177) – Trường ĐH Công nghệ TP.HCM (HUTECH)  
**Đề tài:** LifeQuest – Ứng dụng nhiệm vụ Gamification tích hợp AI, phân quyền hệ thống và đồng bộ nhóm thời gian thực trên thiết bị di động  
**Nhóm thực hiện:** Nhóm 10  
*(Phong cách thiết kế trên Canva: **Minimalism - Style 1**, nền sáng `#F8FAFC`, bề mặt thẻ trắng `#FFFFFF` viền 1px `#E2E8F0`, màu nhấn xanh Ocean Blue `#2563EB`, font chữ Sans-Serif hiện đại như Inter/Roboto/Plus Jakarta Sans)*

---

## SLIDE 1: TRANG TIÊU ĐỀ (TITLE SLIDE)
* **Bố cục Canva:** Nền sáng tối giản, Logo HUTECH góc trái trên, tên đề tài in hoa đậm giữa trang, bên dưới là thông tin nhóm.
* **Tiêu đề lớn:** `LIFEQUEST`
* **Tiêu đề phụ:** Ứng dụng nhiệm vụ Gamification tích hợp AI, phân quyền hệ thống & đồng bộ nhóm thời gian thực trên thiết bị di động
* **Thông tin học phần:**
  * Học phần: Lập trình trên thiết bị di động (ECMP177)
  * Giảng viên hướng dẫn: ThS. [Chèn tên Thầy]
  * Lớp: 23DTHB6 – Nhóm: 10
* **Danh sách thành viên:**
  1. Nguyễn Viết Lãm – MSSV: 2380601183 (Trưởng nhóm)
  2. Trần Ngọc Lợi – MSSV: 2380601292
  3. Nguyễn Đại Kỳ – MSSV: 2380601178
  4. Châu Tuấn – MSSV: 2380602434
* **Người trình bày mở đầu:** Nguyễn Viết Lãm
* **Lời thoại người nói (Speaker Notes):**
  > *"Kính chào Thầy và toàn thể các bạn sinh viên. Hôm nay Nhóm 10 xin phép được đại diện trình bày báo cáo đồ án kết thúc môn Lập trình trên thiết bị di động với sản phẩm ứng dụng LifeQuest. Đề tài hướng tới việc giải quyết bài toán duy trì động lực rèn luyện của sinh viên bằng phương pháp Gamification và Trí tuệ nhân tạo an toàn."*

---

## SLIDE 2: ĐẶT VẤN ĐỀ & MỤC TIÊU ĐỀ TÀI
* **Bố cục Canva:** Chia làm 2 cột đối xứng (Bên trái: Vấn đề thực tế; Bên phải: Giải pháp LifeQuest).
* **Cột trái - Thực trạng & Thách thức:**
  * Người trẻ và sinh viên dễ trì hoãn, nhanh mất động lực khi tự quản lý mục tiêu cá nhân hoặc bài tập nhóm.
  * Các ứng dụng To-Do truyền thống đơn điệu, dễ bị lãng quên sau 2 - 3 ngày.
  * Khó khăn trong việc phối hợp và theo dõi tiến độ công việc giữa các thành viên trong nhóm.
* **Cột phải - Giải pháp LifeQuest:**
  * **Gamification hóa đời sống:** Biến mục tiêu rèn luyện thành nhiệm vụ (Quest) có điểm thưởng XP, thăng cấp độ và chuỗi ngày Streak.
  * **Trợ lý AI đồng hành:** Phân rã mục tiêu lớn thành các bước hành động cụ thể, có kiểm duyệt an toàn.
  * **Không gian Nhóm thời gian thực (SSE):** Cộng tác minh bạch, giao việc và đồng bộ dữ liệu tức thời.
* **Người trình bày:** Trần Ngọc Lợi
* **Speaker Notes:**
  > *"Trong học tập và đời sống, rào cản lớn nhất của sinh viên không phải là không có mục tiêu, mà là thiếu động lực duy trì. LifeQuest ra đời để biến việc học và rèn luyện thói quen thành một trò chơi nhập vai thực tế, nơi mỗi hành động nhỏ hoàn thành đều đem lại điểm số và cấp độ cụ thể."*

---

## SLIDE 3: KIẾN TRÚC HỆ THỐNG & CÔNG NGHỆ SỬ DỤNG
* **Bố cục Canva:** Sơ đồ khối 3 tầng phẳng (Client $\leftrightarrow$ REST API $\leftrightarrow$ Database & AI Service).
* **Tầng 1 - Mobile App (Frontend):**
  * Flutter 3.x / Dart (Material 3).
  * State Management: Riverpod 2.x.
  * Declarative Routing: GoRouter.
  * Thiết kế Responsive: Thích ứng màn hình Mobile (Drawer + Bottom Bar) và Desktop/Web (Left Sidebar).
* **Tầng 2 - Backend & Server:**
  * Node.js + Express REST API.
  * Xác thực: JWT (7 ngày) + băm mật khẩu `bcrypt` (salt 10).
  * Realtime: Server-Sent Events (SSE) đẩy sự kiện nhóm hai chiều nhẹ nhàng, tiết kiệm pin.
* **Tầng 3 - Dữ liệu & AI:**
  * SQLite CSDL quan hệ chuẩn 9 bảng, migration `.sql` độc lập.
  * Trí tuệ nhân tạo: Gemini API với cơ chế Mock dự phòng khi offline.
* **Người trình bày:** Nguyễn Viết Lãm
* **Speaker Notes:**
  > *"Về mặt kiến trúc, nhóm áp dụng mô hình phân tầng Client - Server hoàn chỉnh. Ứng dụng di động viết bằng Flutter kết nối với Backend REST API Node.js và CSDL SQLite có quản lý phiên bản migration. Chúng em sử dụng Server-Sent Events thay vì WebSocket để tối ưu hóa thời lượng pin trên thiết bị di động."*

---

## SLIDE 4: GAMIFICATION & CƠ CHẾ IDEMPOTENT CHỐNG HACK ĐIỂM
* **Bố cục Canva:** Chèn ảnh chụp `docs/screenshots/home.png` và `docs/screenshots/quest-complete.png`, bên cạnh là công thức toán học và bảng độ khó.
* **Nội dung trọng tâm:**
  * **Công thức toán học cấp độ:** $\text{Level} = \left\lfloor\sqrt{\frac{\text{XP}}{100}}\right\rfloor + 1$ (tạo độ khó tăng dần theo hàm bình phương).
  * **Phân cấp nhiệm vụ:** Dễ (20 XP) - Vừa (40 XP) - Khó (70 XP).
  * **Chuỗi ngày rèn luyện (Streak):** Tự động tăng khi hoàn thành nhiệm vụ trong ngày, bảo vệ tính kỷ luật.
* **Điểm nhấn kỹ thuật - Cơ chế Idempotent Transaction:**
  * Bấm hoàn thành lần 1: Ghi nhận CSDL, cộng 40 XP, trả `{ idempotent: false, xpAwarded: 40 }`.
  * Bấm lặp lại hoặc cố tình spam API: Hệ thống kiểm tra cờ `xp_awarded = 1`, trả `{ idempotent: true, xpAwarded: 0 }`.
  * **Ý nghĩa:** Chống triệt để việc gian lận điểm số và lỗi lặp giao dịch mạng.
* **Người trình bày:** Trần Ngọc Lợi
* **Speaker Notes:**
  > *"Điểm nhấn kỹ thuật ăn điểm trong phân hệ Gamification là tính Idempotent. Trong CSDL, chúng em gói toàn bộ quy trình hoàn thành nhiệm vụ vào một Transaction nguyên tử. Dù người dùng có bấm nút 10 lần liên tục hoặc mạng chập chờn, điểm XP chỉ được cấp đúng một lần duy nhất."*

---

## SLIDE 5: TRỢ LÝ AI CHIA NHỎ MỤC TIÊU & BỘ LỌC AN TOÀN
* **Bố cục Canva:** Chèn ảnh chụp `docs/screenshots/ai-draft.png`, minh họa luồng Review-before-save và Moderation.
* **Tính năng thông minh:**
  * Nhập mục tiêu lớn (ví dụ: *"Ôn thi môn Lập trình di động trong 7 ngày"*).
  * AI tự động phân tích và sinh ra kế hoạch hành động 3, 5 hoặc 7 bước thực tế.
* **Nguyên tắc an toàn (Safety Guidelines):**
  * **Luồng Review-before-save:** AI không bao giờ tự ý lưu thẳng vào database. Người dùng có toàn quyền đọc, biên tập câu chữ, thêm bớt bước trước khi quyết định lưu.
  * **Bộ lọc kiểm duyệt (Moderation):** Tự động phát hiện và từ chối các mục tiêu chứa nội dung nguy hiểm, tiêu cực (trả mã lỗi HTTP 422).
  * **Bảo mật:** API Key của Gemini chỉ lưu ở máy chủ backend, tuyệt đối không để lộ ở client app.
* **Người trình bày:** Châu Tuấn
* **Speaker Notes:**
  > *"Đối với tính năng Trợ lý AI, nhóm đặt yếu tố an toàn lên hàng đầu với quy trình Review-before-save. AI chỉ đóng vai trò gợi ý bản thảo (draft). Người dùng xem trước, chỉnh sửa câu chữ rồi mới xác nhận lưu. Đồng thời, hệ thống có bộ lọc từ chối mọi nội dung tiêu cực trước khi gửi tới API."*

---

## SLIDE 6: KHÔNG GIAN NHÓM & ĐỒNG BỘ THỜI GIAN THỰC (SSE)
* **Bố cục Canva:** Chèn ảnh chụp `docs/screenshots/group-detail.png` và `docs/screenshots/group-realtime.png`, vẽ luồng kết nối 2 thiết bị.
* **Cộng tác nhóm an toàn:**
  * Khởi tạo nhóm học tập / rèn luyện thể thao.
  * Cơ chế mã mời bảo mật: Mã mời được băm bằng thuật toán **SHA-256** lưu trong CSDL và có thời hạn tự hủy sau 7 ngày.
* **Đồng bộ thời gian thực qua Server-Sent Events (SSE):**
  * Thiết lập kết nối kênh đẩy sự kiện `GET /api/groups/:id/events`.
  * Khi thành viên A tạo nhiệm vụ, tích checklist hoặc hoàn thành bài tập $\rightarrow$ Server lập tức phát sự kiện `quest.created` / `step.toggled`.
  * Toàn bộ thiết bị của các thành viên khác tự động cập nhật ngay lập tức mà không cần bấm F5 hay kéo reload.
* **Người trình bày:** Nguyễn Đại Kỳ
* **Speaker Notes:**
  > *"Trong phần làm việc nhóm, chúng em giải quyết bài toán đồng bộ dữ liệu bằng Server-Sent Events. Khi thành viên A tích chọn một bước công việc trên điện thoại của mình, điện thoại của bạn B lập tức hiển thị bước đó đã hoàn thành theo thời gian thực mà không cần thao tác tải lại trang."*

---

## SLIDE 7: BẢO MẬT ĐA LỚP & PHÂN QUYỀN ADMIN CHUYÊN BIỆT
* **Bố cục Canva:** Bảng so sánh 2 phân quyền (Admin vs User) và ảnh chụp `docs/screenshots/admin_ocean_desktop.png`.
* **Phân quyền hệ thống nghiêm ngặt (Strict RBAC):**
  * **Quản trị viên (Admin):** Giám sát biểu đồ hoạt động toàn hệ thống, quản lý danh sách người dùng, xử lý báo cáo vi phạm, khóa tài khoản vi phạm. Admin **không** làm nhiệm vụ to-do cá nhân.
  * **Người dùng (User):** Trải nghiệm rèn luyện nhiệm vụ, thăng cấp, tạo nhóm và tương tác an toàn.
* **Bảo mật & Kiểm soát rủi ro:**
  * Mật khẩu băm bằng **bcrypt** (salt 10), mã mời băm **SHA-256**.
  * Chống tấn công brute-force: Rate limiting khóa đăng nhập 15 phút khi nhập sai 5 lần.
  * **Safety Center:** Cho phép người dùng gửi báo cáo vi phạm và Chặn (Block) tài khoản xấu; tự động ẩn quest của người bị chặn trong nhóm.
* **Người trình bày:** Nguyễn Viết Lãm
* **Speaker Notes:**
  > *"Hệ thống phân tách quyền hạn rạch ròi: tài khoản Admin chỉ phục vụ công tác quản trị, xử lý báo cáo và khóa tài khoản vi phạm. Toàn bộ mật khẩu và mã mời đều được băm bằng thuật toán mật mã tiêu chuẩn quốc tế, bảo đảm an toàn dữ liệu người dùng."*

---

## SLIDE 8: KẾT QUẢ KIỂM THỬ THỰC TẾ (TESTING & VERIFICATION)
* **Bố cục Canva:** 3 thẻ chỉ số lớn nổi bật màu xanh lá: `flutter analyze: 0 lỗi`, `flutter test: 14/14 PASS`, `backend test: 12/12 PASS`.
* **Minh chứng chất lượng mã nguồn:**
  * **Kiểm tra tĩnh:** `flutter analyze` $\rightarrow$ Không có bất kỳ cảnh báo cú pháp hay lỗi lặp (No issues found).
  * **Kiểm thử Unit & Widget Flutter:** 14/14 test cases ĐẠT 100% (kiểm tra Auth, Token 401, Gamification, Idempotency, AI moderation, Groups).
  * **Kiểm thử tích hợp Backend REST API:** 12/12 test suites ĐẠT 100% (kiểm tra bảo mật brute-force 429, Transaction CSDL, Phân quyền, Lọc chặn, Realtime SSE).
  * Đã build thành công file cài đặt Android APK: `app-debug.apk`.
* **Người trình bày:** Châu Tuấn & Nguyễn Viết Lãm
* **Speaker Notes:**
  > *"Để đảm bảo sản phẩm hoạt động hoàn toàn ổn định trước khi báo cáo, nhóm đã viết các bộ kiểm thử tự động toàn diện. Cả 14 bài test trên ứng dụng di động và 12 bài test tích hợp tại máy chủ backend đều vượt qua 100%, không xảy ra bất kỳ lỗi hồi quy nào."*

---

## SLIDE 9: TỔNG KẾT, HƯỚNG PHÁT TRIỂN & Q&A
* **Bố cục Canva:** Bên trái tóm tắt kết quả; Bên phải là Mã QR mở ứng dụng Web Demo + Link GitHub công khai.
* **Kết quả đạt được:**
  * Hoàn thành 100% các yêu cầu kỹ thuật của đồ án môn học Lập trình di động.
  * Giao diện đạt chuẩn Tối giản (Minimalism), trải nghiệm mượt mà trên điện thoại.
  * Kiến trúc mở, khả năng mở rộng cao.
* **Hướng phát triển tiếp theo:**
  * Triển khai Backend lên máy chủ đám mây (Render / Railway) với CSDL PostgreSQL.
  * Tích hợp Firebase Cloud Messaging (FCM) gửi thông báo nhắc hạn ra ngoài màn hình khóa.
* **Thông tin dự án:**
  * GitHub Public: `https://github.com/Nguyen-Viet-Lam/LapTrinhTrenThietBiDiDong.git`
  * Web Demo: `https://flutter-firebase-6b5af.web.app`
* **Lời cảm ơn Thầy & Mời Hội đồng chấm thi đặt câu hỏi.**
* **Người trình bày:** Nguyễn Viết Lãm
* **Speaker Notes:**
  > *"Nhóm 10 xin chân thành cảm ơn Thầy đã luôn tận tình hướng dẫn và định hướng cho nhóm trong suốt học phần. Kính mời Thầy cùng các bạn theo dõi phần Demo trực tiếp sản phẩm và đóng góp ý kiến phản biện cho nhóm."*
