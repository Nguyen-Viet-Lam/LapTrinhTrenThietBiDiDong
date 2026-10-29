# LifeQuest: Kế hoạch di trú sang Flutter + Firebase

## Mục tiêu

Di trú LifeQuest từ kiến trúc hiện tại:
- Flutter/Dart client
- Node.js + Express REST API
- SQLite
- JWT authentication
- SSE realtime

sang kiến trúc:
- Flutter/Dart client
- Firebase Authentication
- Cloud Firestore
- Firestore realtime streams
- Cloud Functions cho tác vụ cần giữ bí mật hoặc cần logic tin cậy phía server

Sau di trú, các màn hình ứng dụng không gọi Node.js API cho các chức năng đã chuyển sang Firebase. Backend cũ được giữ nguyên làm bản dự phòng cho tới khi migration hoàn tất và được nghiệm thu.

## Nguyên tắc bắt buộc

1. Không dùng đồng thời Firebase và API/SQLite cũ cho cùng một chức năng sau khi chức năng đó đã được chuyển.
2. Không xóa `backend/`, cơ sở dữ liệu cũ hoặc API client trước khi migration được nghiệm thu.
3. Không đặt API key riêng tư, service-account key, JWT secret hoặc AI provider key trong Flutter.
4. Không sử dụng Firestore Rules mở công khai như `allow read, write: if true`.
5. Không ghi trực tiếp từ widget vào Firestore. Dùng repository/service layer.
6. Dùng Firebase Emulator Suite cho kiểm thử logic Firestore và Security Rules.
7. Mỗi giai đoạn phải chạy `flutter analyze` và `flutter test`; không tiếp tục khi lỗi mới chưa được xử lý hoặc ghi nhận.
8. Không xóa dữ liệu SQLite cũ. Việc import dữ liệu chỉ làm sau khi có quyết định về dữ liệu cần giữ và có bản backup kiểm chứng được.
9. Trước khi sửa, kiểm tra Git status và không ghi đè thay đổi chưa commit của người dùng.
10. Không ghi thông tin đăng nhập Firebase hoặc secret thật vào tài liệu, mã nguồn hoặc Git.

## Kiến trúc đích

```text
Flutter app
├── Firebase Authentication
├── Cloud Firestore
├── Firebase Storage (chỉ khi cần ảnh/tệp)
└── Cloud Functions (AI, tác vụ đặc quyền hoặc logic cần tin cậy)

Firebase
├── Auth
├── Firestore
├── Storage (tùy nhu cầu)
└── Functions (tùy nhu cầu)

Legacy, chỉ giữ trong giai đoạn chuyển đổi
└── Node.js + Express + SQLite + JWT + SSE
```

Firebase Auth chịu trách nhiệm danh tính. Firestore lưu profile và dữ liệu ứng dụng. Firestore snapshots thay SSE. Nếu có AI provider hoặc thao tác quản trị đặc quyền, chúng phải chạy ở Cloud Functions hoặc một dịch vụ server-side tương đương, không chạy với secret nhúng trong APK.

## Giai đoạn 0: Khảo sát và tạo điểm khôi phục

### Việc cần làm
1. Kiểm tra git status, branch hiện tại và các thay đổi chưa commit.
2. Ghi nhận phiên bản Flutter, Dart, Android Gradle Plugin và Gradle wrapper.
3. Đọc pubspec.yaml, lib/main.dart, lib/api/, lib/app_controller.dart, lib/models.dart, toàn bộ màn hình, test và cấu hình android/.
4. Tìm mọi nơi gọi API, lưu JWT, đọc Shared Preferences, kết nối SSE và phụ thuộc vào cấu trúc response backend.
5. Chạy baseline:
   - flutter pub get
   - flutter analyze
   - flutter test
   - cd backend && npm test
6. Ghi lại số test thực tế, không dựa vào số lượng trong tài liệu cũ.
7. Tạo branch migration riêng, ví dụ `migration/firebase`.
8. Nếu có dữ liệu người dùng cần giữ, tạo và xác minh bản backup SQLite trước mọi thay đổi liên quan dữ liệu.

### Đầu ra
- Báo cáo file/phần chức năng đang phụ thuộc backend.
- Kết quả baseline test.
- Branch migration và hướng quay lại.
- Danh sách dữ liệu có cần migrate hay không.

### Không được làm ở giai đoạn này
- Không xóa backend.
- Không đổi schema dữ liệu.
- Không thay toàn bộ controller hoặc màn hình trước khi biết các phụ thuộc hiện có.

---

## Giai đoạn 1: Cấu hình Firebase project và Android

### Người cần thực hiện
Antigravity hoặc chủ dự án cần thao tác bằng tài khoản Firebase/Google và Android Studio trên máy.

### Các bước
1. Tạo hoặc chọn Firebase project dành cho LifeQuest (`flutter-firebase-6b5af`).
2. Thêm Android app với application ID lấy từ cấu hình Android thực tế của repository.
3. Xác nhận application ID trên Firebase Console khớp chính xác với Android project.
4. Bật Email/Password trong Firebase Authentication.
5. Tạo Cloud Firestore database ở region đã thống nhất.
6. Chọn chế độ bảo mật; không bật quyền truy cập công khai.
7. Đặt google-services.json vào android/app/.
8. Cấu hình FlutterFire bằng CLI theo phiên bản tương thích với Flutter đang cài.
9. Sinh firebase_options.dart; kiểm tra file này không chứa private service-account key.
10. Cài plugin Flutter và Dart trong Android Studio nếu còn thiếu.
11. Mở đúng thư mục gốc Flutter, chọn lib/main.dart và khởi động emulator.
12. Chạy flutter doctor -v, ghi lại cảnh báo/error chưa xử lý.

### Cần bàn giao về repository
- Firebase project ID: `flutter-firebase-6b5af`.
- Android application ID đã đăng ký.
- Region Firestore.
- Các dịch vụ Firebase đã bật.
- Kết quả flutter doctor -v.
- Xác nhận emulator nhìn thấy bằng flutter devices.

---

## Giai đoạn 2: Thiết kế schema Firestore

Không chuyển máy móc schema SQLite sang Firestore. Thiết kế theo các query thực tế của màn hình và kiểm tra chi phí đọc/ghi.

### Schema khởi đầu đề xuất
```text
users/{uid}
  displayName
  email
  avatarUrl
  role
  xp
  level
  streak
  createdAt
  updatedAt

quests/{questId}
  ownerId
  title
  description
  category
  difficulty
  status
  xpReward
  dueDate
  groupId
  createdAt
  updatedAt
  completedAt

quests/{questId}/steps/{stepId}
  title
  isCompleted
  order

groups/{groupId}
  name
  description
  ownerId
  inviteCode
  createdAt
  updatedAt

groups/{groupId}/members/{uid}
  userId
  displayName
  role
  joinedAt

groups/{groupId}/quests/{questId}
  title
  description
  createdBy
  status
  xpReward
  createdAt
  updatedAt

groups/{groupId}/messages/{messageId}
  senderId
  senderName
  content
  createdAt

users/{uid}/notifications/{notificationId}
  type
  title
  body
  isRead
  createdAt

users/{uid}/blockedUsers/{blockedUid}
  blockedAt
  reason

safetyReports/{reportId}
  reporterId
  targetId
  type
  reason
  status
  createdAt

aiPlans/{planId}
  ownerId
  goal
  difficulty
  steps
  status
  createdAt
```

---

## Giai đoạn 3: Firebase bootstrap và lớp dữ liệu

### Công việc
1. Thêm `firebase_core`, `firebase_auth`, `cloud_firestore` với phiên bản tương thích. Chỉ thêm Storage/Functions khi đã có chức năng cụ thể.
2. Khởi tạo Firebase trước `runApp`.
3. Tạo cấu hình môi trường dev/test/prod; không hard-code endpoint cũ hoặc secret.
4. Tạo các lớp repository:
   - `AuthRepository`
   - `UserRepository`
   - `QuestRepository`
   - `GroupRepository`
   - `ProfileRepository`
   - `NotificationRepository`
   - `SafetyRepository`
5. Tạo model Firestore riêng hoặc thêm serializer có kiểm thử:
   - `fromFirestore`
   - `toFirestore`
6. Chuẩn hóa chuyển đổi Timestamp, nullable field, enum và document ID.
7. Tạo mapper lỗi Firebase sang lỗi/hiển thị phù hợp trong UI.
8. Tạo fake repository để widget test không cần kết nối Firebase thật.

### Tiêu chí hoàn tất
- Không widget nào gọi trực tiếp `FirebaseFirestore.instance`.
- Repository có test cơ bản.
- `flutter analyze` không có lỗi mới.
- Test cũ vẫn chạy hoặc các test bị ảnh hưởng đã được thay có chủ đích.

---

## Giai đoạn 4: Chuyển authentication

### Chức năng phải hỗ trợ
- Đăng ký email/password.
- Đăng nhập.
- Đăng xuất.
- Duy trì trạng thái đăng nhập khi mở lại app.
- Quên mật khẩu.
- Đổi mật khẩu với yêu cầu re-authentication khi Firebase yêu cầu.
- Tạo profile `users/{uid}` khi đăng ký.
- Xử lý user bị xóa, email chưa xác minh hoặc token hết hạn.

---

## Giai đoạn 5: Chuyển quest và gamification

### Chuyển các thao tác
- Danh sách, tìm kiếm và lọc quest.
- Tạo, sửa, archive và xóa quest.
- Checklist step.
- Hoàn thành quest.
- XP, level và streak.
- Bộ lọc category.
- Đồng bộ trạng thái khi thay đổi từ thiết bị khác.

### XP và hoàn thành idempotent
Dùng Firestore Transaction hoặc Cloud Function:
1. Đọc quest và user.
2. Kiểm tra quest chưa hoàn thành.
3. Đánh dấu quest hoàn thành.
4. Cộng XP đúng một lần.
5. Cập nhật level/streak theo quy tắc nghiệp vụ.
6. Ghi timestamp server.

---

## Giai đoạn 6: Chuyển groups, invite code, group chat và realtime

### Chức năng
- Tạo nhóm.
- Xem danh sách nhóm.
- Tham gia bằng invite code.
- Xem thành viên.
- Quest nhóm.
- Rời nhóm và xử lý chủ nhóm rời nhóm.
- Copy invite code và gửi lời mời.
- Kênh chat thảo luận nhóm (Group Chat).
- Realtime cập nhật thành viên/quest/chat qua Firestore snapshots stream.

---

## Giai đoạn 7: AI, safety, blocked users và admin

- AI: Nếu giữ tính năng AI thật, gọi qua backend/Cloud Function an toàn hoặc Smart Template an toàn đã xây dựng; không để lộ secret.
- Safety và blocked users: Lưu report/blocked user trong collection có rules riêng.
- Admin: Dùng Custom Claims hoặc trường `role: 'admin'` được xác thực an toàn qua Security Rules.

---

## Giai đoạn 8: Firestore Security Rules và indexes

1. Viết rules theo từng collection và từng hành động.
2. Mặc định từ chối truy cập chưa được khai báo.
3. Ràng buộc owner ID bằng `request.auth.uid`.
4. User A không thể đọc/sửa dữ liệu riêng của User B.
5. Non-member không thể đọc dữ liệu nhóm riêng.
6. Commit `firestore.rules` và `firestore.indexes.json` vào repository.

---

## Giai đoạn 9: Chuyển notification, profile và phần còn lại
- Chuyển profile và avatar.
- Chuyển notifications, blocked users, safety reports.
- Chuyển admin dashboard.

---

## Giai đoạn 10: Kiểm thử, dữ liệu và nghiệm thu
- `flutter analyze` 0 lỗi.
- `flutter test` PASS 100%.
- Firebase Emulator tests cho Auth, Firestore và Security Rules.
- Kiểm thử tích hợp trên Android Emulator / Web.
- Backend legacy: `cd backend && npm test` 12/12 PASS.

---

## Giai đoạn 11: Gỡ legacy sau nghiệm thu
Chỉ làm sau khi Firebase app chạy ổn và người phụ trách chấp thuận.
