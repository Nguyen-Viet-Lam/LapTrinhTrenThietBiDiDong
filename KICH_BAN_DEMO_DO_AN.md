# KỊCH BẢN DEMO ĐỒ ÁN LIFEQUEST TRỰC CHIẾN (7 - 10 PHÚT)
**Học phần:** Lập trình trên thiết bị di động (ECMP177) – Trường ĐH Công nghệ TP.HCM (HUTECH)  
**Đề tài:** LifeQuest – Ứng dụng nhiệm vụ Gamification tích hợp AI, phân quyền hệ thống và đồng bộ nhóm thời gian thực trên thiết bị di động  
**Nhóm sinh viên thực hiện:** Nhóm 10  
1. **Nguyễn Viết Lãm** – MSSV: 2380601183 (Trưởng nhóm: Phụ trách mở đầu, phân quyền Admin, kết thúc & phản biện)  
2. **Trần Ngọc Lợi** – MSSV: 2380601292 (Phụ trách demo Gamification & Quest Idempotent)  
3. **Nguyễn Đại Kỳ** – MSSV: 2380601178 (Phụ trách demo Nhóm & Đồng bộ Realtime 2 thiết bị)  
4. **Châu Tuấn** – MSSV: 2380602434 (Phụ trách demo Trợ lý AI an toàn & Safety Center)  

---

## 1. CÔNG TÁC CHUẨN BỊ TRƯỚC KHI BẮT ĐẦU BUỔI BẢO VỆ

1. **Thiết bị trình diễn:**
   - **Máy tính xách tay (Laptop trình chiếu):** Đã khởi động sẵn Backend Server (`cd backend && node src/server.js`) hoặc bản ứng dụng trên trình duyệt web / giả lập Android Studio.
   - **Điện thoại di động 1 (Thiết bị chính):** Cài sẵn file `app-debug.apk` hoặc mở bản web, đăng nhập sẵn tài khoản `demo@lifequest.vn` / `123456`.
   - **Điện thoại di động 2 (Thiết bị phụ):** Đăng nhập sẵn tài khoản thành viên nhóm `ban@lifequest.vn` (hoặc `ky@lifequest.vn`) để trình diễn tính năng đồng bộ 2 thiết bị thời gian thực.
2. **Danh sách tài khoản kiểm thử đã cấu hình sẵn trong CSDL:**
   - **Tài khoản Quản trị viên (Admin):** `lam@lifequest.vn` / Mật khẩu: `123456` (hoặc `admin@lifequest.vn`).
   - **Tài khoản Người dùng 1 (User chính):** `demo@lifequest.vn` / Mật khẩu: `123456`.
   - **Tài khoản Người dùng 2 (Thành viên CLB):** `ban@lifequest.vn` / Mật khẩu: `123456`.
   - **Tài khoản dự phòng:** `ky@lifequest.vn`, `loi@lifequest.vn`, `tuan@lifequest.vn` / Mật khẩu: `123456`.
3. **Kế hoạch dự phòng (Fallback Plan):**
   - Nếu hội trường mất kết nối Internet, máy chủ Backend tự động kích hoạt chế độ **Mock AI** đã tích hợp sẵn, bảo đảm tạo được bản thảo nhiệm vụ mượt mà không bị treo lỗi mạng.

---

## 2. KỊCH BẢN CHI TIẾT TỪNG PHÚT

### ⏱️ PHÚT 00:00 – 01:30 | MỞ ĐẦU & PHÂN QUYỀN ADMIN CHUYÊN BIỆT
* **Người thực hiện:** **Nguyễn Viết Lãm** (Trưởng nhóm)
* **Thao tác trên màn hình:**
  1. Mở màn hình Đăng nhập ứng dụng LifeQuest.
  2. Đăng nhập bằng tài khoản Quản trị viên: `lam@lifequest.vn` / `123456`.
  3. Màn hình tự động chuyển về **Bảng điều khiển Quản trị (Admin Dashboard)**.
* **Lời thoại thuyết trình:**
  > *"Kính thưa Thầy và các bạn, hôm nay Nhóm 10 xin phép được bắt đầu phần demo ứng dụng LifeQuest. Đầu tiên, em xin trình diễn tính năng Phân quyền hệ thống nghiêm ngặt (Strict RBAC).  
  > Khi em đăng nhập bằng tài khoản của Quản trị viên, hệ thống sẽ mở ra giao diện Admin chuyên biệt. Tại đây, Quản trị viên có cái nhìn toàn cảnh: theo dõi tổng số lượng tài khoản đăng ký, số lượng nhiệm vụ đang hoạt động, tỷ lệ hoàn thành và trung tâm tiếp nhận báo cáo vi phạm.  
  > Đặc biệt, để đảm bảo tính khách quan và đúng nghiệp vụ, tài khoản Admin hoàn toàn không tham gia làm các nhiệm vụ cá nhân to-do của người dùng. Tiếp theo, em xin mời bạn Lợi trình diễn trải nghiệm của một người dùng thực tế."*

---

### ⏱️ PHÚT 01:30 – 03:00 | TRẢI NGHIỆM GAMIFICATION & QUẢN LÝ NHIỆM VỤ
* **Người thực hiện:** **Trần Ngọc Lợi**
* **Thao tác trên màn hình:**
  1. Đăng xuất tài khoản Admin, đăng nhập tài khoản Người dùng: `demo@lifequest.vn` / `123456`.
  2. Màn hình mở ra Trang chủ (Home) rực rỡ với các chỉ số Gamification.
  3. Nhấn vào nút tạo nhiệm vụ mới (+), nhập:
     - Tiêu đề: *"Chạy bộ rèn luyện sức bền"*
     - Danh mục: *Sức khỏe* – Độ khó: *Vừa (40 XP)*
     - Checklist: Bước 1: Khởi động 5 phút; Bước 2: Chạy 3km; Bước 3: Thả lỏng cơ.
  4. Bấm Lưu, nhiệm vụ xuất hiện ngay ở đầu danh sách. Tích chọn Bước 1 và Bước 2, thanh tiến độ tăng lên 66%.
* **Lời thoại thuyết trình:**
  > *"Em xin chào Thầy. Đây là giao diện của người dùng thông thường, được thiết kế theo phong cách Minimalism tối giản, phẳng và dịu mắt. Trên trang chủ, người dùng thấy ngay điểm số kinh nghiệm XP, thanh tiến độ cấp độ được tính toán theo công thức toán học và chuỗi ngày rèn luyện liên tục (Streak).  
  > Vừa rồi em đã tạo một nhiệm vụ rèn luyện thể thao với 3 bước nhỏ. Khi em tích hoàn thành từng bước, thanh tiến độ lập tức cập nhật tương ứng, tạo cảm giác thôi thúc người dùng hoàn thành nốt công việc."*

---

### ⏱️ PHÚT 03:00 – 04:30 | ĐIỂM NHẤN KỸ THUẬT: CƠ CHẾ IDEMPOTENT CHỐNG HACK ĐIỂM
* **Người thực hiện:** **Trần Ngọc Lợi**
* **Thao tác trên màn hình:**
  1. Tích nốt bước thứ 3, sau đó nhấn nút **"Hoàn thành nhiệm vụ"**.
  2. Ứng dụng hiện hiệu ứng thông báo: *"Chúc mừng! Bạn nhận được +40 XP"*. Số XP trên trang chủ tăng từ 160 lên 200.
  3. Tiếp tục nhấn vào nút "Hoàn thành" lần thứ 2 (hoặc mở lại nhiệm vụ đó và bấm hoàn thành).
  4. Hệ thống hiển thị: *"Nhiệm vụ này đã nhận thưởng trước đó"*, số XP vẫn giữ nguyên 200, không bị tăng khống.
* **Lời thoại thuyết trình:**
  > *"Thưa Thầy, một trong những lỗi phổ biến nhất ở các ứng dụng Gamification là người dùng spam bấm nút hoàn thành nhiều lần để gian lận điểm số. Tại LifeQuest, nhóm em đã giải quyết triệt để vấn đề này bằng cơ chế Idempotent Transaction trong CSDL SQLite.  
  > Khi bấm hoàn thành lần đầu, CSDL lưu cờ đã nhận điểm và cộng 40 XP. Ở lần bấm thứ hai, API nhận diện trạng thái và trả về idempotent: true với 0 XP thưởng. Điều này bảo đảm tính toàn vẹn dữ liệu tuyệt đối dù mạng có bị chập chờn hay người dùng bấm liên tục."*

---

### ⏱️ PHÚT 04:30 – 06:00 | TRỢ LÝ AI PHÂN RÃ MỤC TIÊU & BỘ LỌC AN TOÀN
* **Người thực hiện:** **Châu Tuấn**
* **Thao tác trên màn hình:**
  1. Chuyển sang Tab **"Trợ lý AI"** trên thanh điều hướng.
  2. Tại ô nhập mục tiêu, nhập: *"Học lập trình Flutter trong 5 ngày"* $\rightarrow$ Chọn độ khó *Vừa* $\rightarrow$ Bấm nút **"Tạo kế hoạch"**.
  3. AI sinh ra bản thảo 5 bước chi tiết. Nhấp vào bước 3 để sửa đổi văn bản trực tiếp trên màn hình, sau đó nhấn *"Lưu vào nhiệm vụ của tôi"*.
  4. Tiếp tục nhập thử một từ khóa tiêu cực (ví dụ: *"Cách tự gây hại"*), bấm Tạo kế hoạch $\rightarrow$ Ứng dụng hiện cảnh báo đỏ từ chối an toàn ngay lập tức.
* **Lời thoại thuyết trình:**
  > *"Em xin chào Thầy, em là Tuấn. Em xin trình diễn tính năng Trợ lý AI phân rã mục tiêu. Khi người dùng gặp một mục tiêu quá lớn và chưa biết bắt đầu từ đâu, AI sẽ đóng vai trò người cố vấn chia nhỏ công việc thành các bước hành động cụ thể.  
  > Chúng em áp dụng nguyên tắc an toàn Review-before-save: AI không bao giờ tự ý lưu vào máy chủ. Người dùng luôn được xem trước bản thảo, chỉnh sửa câu từ theo ý mình rồi mới quyết định lưu. Đồng thời, hệ thống tích hợp bộ lọc kiểm duyệt (Moderation Filter) từ chối ngay lập tức mọi mục tiêu độc hại hoặc vi phạm chuẩn mực."*

---

### ⏱️ PHÚT 06:00 – 07:30 | ĐỒNG BỘ THỜI GIAN THỰC NHÓM (SSE) TRÊN 2 THIẾT BỊ
* **Người thực hiện:** **Nguyễn Đại Kỳ**
* **Thao tác trên màn hình:**
  1. Cầm đồng thời 2 thiết bị (hoặc chia đôi 2 cửa sổ trên màn hình chiếu):
     - **Thiết bị A (Bên trái):** Đăng nhập User `demo@lifequest.vn`.
     - **Thiết bị B (Bên phải):** Đăng nhập User `ban@lifequest.vn`.
  2. Cả 2 thiết bị cùng mở trang chi tiết của nhóm *"CLB Thể Thao & Phát Triển Bản Thân"*.
  3. Trên Thiết bị A, bấm tạo một nhiệm vụ nhóm: *"Chạy bộ 5km chiều nay"* và giao cho cả nhóm.
  4. Ngay lập tức, trên màn hình Thiết bị B, nhiệm vụ mới tự động xuất hiện mà **không cần kéo vuốt làm mới hay bấm F5**.
  5. Trên Thiết bị B, tích chọn hoàn thành 1 bước $\rightarrow$ Trên Thiết bị A thanh tiến độ lập tức nhảy số đồng bộ.
* **Lời thoại thuyết trình:**
  > *"Em chào Thầy, em là Kỳ. Để giải quyết bài toán làm việc nhóm và sinh hoạt câu lạc bộ, nhóm em đã xây dựng tính năng đồng bộ thời gian thực qua Server-Sent Events (SSE).  
  > Như Thầy đang thấy trên màn hình: khi bạn A trên Thiết bị 1 tạo một nhiệm vụ mới hoặc đánh dấu công việc, máy chủ Backend lập tức đẩy sự kiện qua kênh SSE. Thiết bị 2 của bạn B lập tức cập nhật dữ liệu tức thời. Giải pháp này giúp các thành viên trong nhóm luôn nắm bắt được tiến độ của nhau mà không tiêu tốn nhiều tài nguyên mạng hay hao pin như cơ chế kéo liên tục (polling)."*

---

### ⏱️ PHÚT 07:30 – 08:30 | AN TOÀN BẢO MẬT: CHẶN NGƯỜI DÙNG & SAFETY CENTER
* **Người thực hiện:** **Châu Tuấn** & **Nguyễn Đại Kỳ**
* **Thao tác trên màn hình:**
  1. Trên Thiết bị B, vào mục **Safety Center (Trung tâm an toàn)**.
  2. Chọn tính năng **"Chặn người dùng (Block)"** đối với tài khoản bạn `demo-user`.
  3. Quay trở lại màn hình danh sách nhiệm vụ nhóm trên Thiết bị B: toàn bộ các nhiệm vụ do `demo-user` tạo ra lập tức biến mất khỏi tầm nhìn của Thiết bị B.
  4. Thao tác gỡ chặn (Unblock) $\rightarrow$ Danh sách nhiệm vụ lại hiển thị bình thường.
* **Lời thoại thuyết trình:**
  > *"Bên cạnh tính năng cộng tác, LifeQuest cũng bảo vệ người dùng bằng Trung tâm An toàn. Khi một người dùng gặp phải đối tượng gây phiền toái hoặc quấy rối trong nhóm chung, họ có thể sử dụng nút Chặn (Block). Thuật toán truy vấn CSDL tại máy chủ sẽ tự động lọc bỏ toàn bộ nội dung của đối tượng bị chặn, trả lại không gian rèn luyện lành mạnh cho người dùng."*

---

### ⏱️ PHÚT 08:30 – 09:30 | KẾT THÚC DEMO, MINH CHỨNG TEST & SẴN SÀNG PHẢN BIỆN
* **Người thực hiện:** **Nguyễn Viết Lãm** (Trưởng nhóm)
* **Thao tác trên màn hình:**
  1. Thao tác chuyển đổi nhanh giao diện sang **Chế độ tối (Dark Mode)** trên điện thoại.
  2. Mở cửa sổ terminal, chạy nhanh 2 lệnh kiểm thử tự động:
     - `flutter test` $\rightarrow$ Màn hình hiện dòng chữ xanh: **`All 14 tests passed!`**
     - `cd backend && npm test` $\rightarrow$ Màn hình hiện dòng chữ xanh: **`tests 12, pass 12, fail 0`**.
* **Lời thoại thuyết trình:**
  > *"Thưa Thầy, để khép lại phần trình diễn, nhóm em xin minh chứng tính tin cậy của mã nguồn bằng kết quả kiểm thử tự động: 100% các bài test logic và kiểm thử tích hợp API đều vượt qua tuyệt đối.  
  > Ứng dụng LifeQuest đã hoàn thiện toàn diện từ tầng giao diện di động đến máy chủ và cơ sở dữ liệu. Nhóm 10 chúng em xin chân thành cảm ơn Thầy đã lắng nghe và chúng em rất mong nhận được những câu hỏi góp ý phản biện từ Thầy!"*

---

## 3. CÂU HỎI PHẢN BIỆN THƯỜNG GẶP CỦA GIẢNG VIÊN & CÁCH TRẢ LỜI ĂN ĐIỂM CAO

#### ❓ Câu hỏi 1: "Tại sao nhóm chọn Server-Sent Events (SSE) thay vì WebSocket để làm tính năng Realtime?"
* **Câu trả lời chuẩn:**  
  > *"Dạ thưa Thầy, đối với bài toán đồng bộ nhóm trong LifeQuest, luồng dữ liệu chủ yếu là một chiều từ Server đẩy xuống các thiết bị khi có sự kiện (tạo quest, hoàn thành quest, thành viên vào nhóm). SSE chạy trực tiếp trên giao thức HTTP tiêu chuẩn, không cần nâng cấp kết nối như WebSocket, tự động có cơ chế reconnect khi rớt mạng và đặc biệt là cực kỳ nhẹ nhàng, tiết kiệm pin cho thiết bị di động hơn rất nhiều so với việc duy trì kết nối WebSocket liên tục ạ."*

#### ❓ Câu hỏi 2: "Cơ chế Idempotent nhận XP hoạt động cụ thể dưới tầng Cơ sở dữ liệu như thế nào?"
* **Câu trả lời chuẩn:**  
  > *"Dạ thưa Thầy, trong bảng `quests`, chúng em thiết kế trường `xp_awarded` kiểu boolean mặc định là 0. Khi người dùng gọi API hoàn thành, chúng em đặt toàn bộ xử lý trong một Database Transaction: câu lệnh đầu tiên kiểm tra nếu `xp_awarded == 1` thì lập tức rollback và trả về `idempotent: true`, điểm thưởng là 0. Chỉ khi nào `xp_awarded == 0`, hệ thống mới đánh dấu thành 1 và cộng dồn XP vào bảng `users`. Nhờ vậy, dù client gửi trùng lặp request bao nhiêu lần thì điểm chỉ được cộng duy nhất một lần ạ."*

#### ❓ Câu hỏi 3: "Mật khẩu và dữ liệu nhạy cảm được bảo mật ra sao?"
* **Câu trả lời chuẩn:**  
  > *"Dạ thưa Thầy, toàn bộ mật khẩu người dùng đều được băm bằng thuật toán bcrypt với salt rounds bằng 10 trước khi lưu vào SQLite, không bao giờ lưu văn bản thô. Mã mời tham gia nhóm cũng được băm SHA-256 có thời hạn 7 ngày. Phía API có middleware xác thực JWT và cơ chế Rate Limiting: nếu nhập sai mật khẩu quá 5 lần liên tiếp trong 15 phút, hệ thống sẽ tạm khóa và trả về lỗi 429 để chống tấn công dò mật khẩu brute-force ạ."*
