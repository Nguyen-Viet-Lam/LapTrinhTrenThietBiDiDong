# Việc giao cho Antigravity: nối Flutter với REST API

Backend đã xong và có test (`cd backend && npm test`, 12/12). **Chỉ sửa trong `lib/`, `test/`, `pubspec.yaml`, `docs/screenshots/`. Không sửa `backend/`.** Đọc trước: `backend/README.md` (danh sách endpoint, quy ước lỗi), `lib/models.dart`, `lib/app_controller.dart`.

Làm lần lượt từng bước; mỗi bước phải `flutter analyze` sạch và `flutter test` đạt rồi mới sang bước sau. Nếu thấy API thiếu gì, ghi lại chứ không tự sửa backend.

## Chuẩn bị
Chạy backend: `cd backend && npm install && npm start` (http://localhost:3000). Android emulator gọi `http://10.0.2.2:3000/api`; Chrome/Windows gọi `http://localhost:3000/api`. Tài khoản: `demo@lifequest.vn` / `123456`, nhóm mã `LIFE2026`.

## Bước 1 – Lớp gọi API
1. Thêm `dio` và `flutter_secure_storage` (hoặc `shared_preferences`) vào `pubspec.yaml`.
2. Tạo `lib/api/api_client.dart`: base URL đọc từ `--dart-define=API_BASE_URL` (mặc định theo nền tảng như trên), tự gắn `Authorization: Bearer <token>`, timeout 15 giây.
3. Chuyển lỗi `{error: "..."}` của API thành `ApiException(status, message)`; 401 → xóa token và đưa về màn hình đăng nhập.
4. Lưu JWT, tự đăng nhập lại khi mở app (gọi `GET /api/me` để kiểm tra token).

## Bước 2 – Thay dữ liệu local bằng API
Giữ nguyên giao diện, chỉ đổi nguồn dữ liệu trong `AppController` (hoặc tách `ApiRepository`):
1. `login` → `POST /auth/login`; `register` → `POST /auth/register` (trả `{token,user}`); `logout` xóa token.
2. Hồ sơ: `GET/PATCH /me` (onboarding, sở thích, dark mode, bật/tắt thông báo); `DELETE /me` xóa tài khoản; nút đổi mật khẩu → `POST /auth/change-password {currentPassword,newPassword}`.
3. Home: `GET /stats` cho XP, level, `xpToNextLevel`, streak, huy hiệu.
4. Quest: `GET /quests?status=&q=&groupId=`, `POST /quests`, `POST /quests/:id/steps/:stepId/toggle`, `POST /quests/:id/complete` (hiển thị `xpAwarded`; nếu `idempotent: true` thì không báo "nhận XP"), `POST /quests/:id/archive`.
5. AI: `POST /ai/quest-plan {goal,difficulty,constraints}` → hiện bản nháp, người dùng sửa/duyệt rồi mới `POST /quests` với `createdByAi: true`. Xử lý 422 (nội dung nguy hiểm: hiện thông báo an toàn) và 429 (chờ vài giây).
6. Nhóm: `GET/POST /groups`, `POST /groups/join {inviteCode}`, `GET /groups/:id`, `POST /groups/:id/leave`. Mã mời chỉ có trong `inviteCode` khi người xem là trưởng nhóm.
7. Thông báo: `GET /notifications`, `POST /notifications/read-all`.
8. Báo cáo/chặn: `POST /reports {targetType: user|quest|group, targetId, reason}`, `POST /blocks {userId}`.
9. Đổi tên field cho khớp JSON API: nhóm có `members[{id,displayName,role}]` thay `memberIds`; user có `streak`, `badges[]`; quest có `progress`, `steps[].isDone`. Bỏ trường `password` khỏi model.
10. Xóa `SharedPreferences` seed demo và nút "Khôi phục dữ liệu demo" (hoặc giữ sau cờ `USE_LOCAL_DEMO=true` nếu muốn còn chế độ demo).

## Bước 3 – Loading, lỗi, offline
1. Mỗi màn hình có trạng thái loading, rỗng và lỗi + nút "Thử lại".
2. Mất mạng/timeout → thông báo tiếng Việt rõ ràng, không crash.
3. Nút gửi bị khóa khi đang gọi API (tránh bấm đúp khi hoàn thành quest).
4. Validate form trước khi gọi: email hợp lệ, mật khẩu ≥ 6 ký tự, tiêu đề quest ≤ 80, mô tả ≤ 500, mỗi bước ≤ 160.

## Bước 4 – Realtime nhóm (SSE)
1. Khi mở chi tiết nhóm, kết nối `GET /groups/:id/events?token=<jwt>` (dùng Dio stream hoặc package `eventsource`/`flutter_client_sse`).
2. Nhận các sự kiện `quest.created|updated|completed|archived|deleted`, `step.toggled`, `member.joined|left|removed`, `owner.changed`, `group.deleted` → tải lại danh sách quest/thành viên của nhóm; `group.deleted` → quay về danh sách nhóm.
3. Đóng kết nối khi rời màn hình; tự kết nối lại khi mất mạng.
4. Kiểm tra bằng hai thiết bị/hai tài khoản (demo và `ban@lifequest.vn`) cùng mở nhóm `LIFE2026`.

## Bước 5 – Màn hình còn thiếu
1. Sửa quest: tiêu đề, mô tả, danh mục, độ khó, hạn chót → `PATCH /quests/:id` (chỉ quest `active`).
2. Xóa quest (chỉ người tạo) → `DELETE /quests/:id`, có hộp thoại xác nhận.
3. Quản lý nhóm cho trưởng nhóm: xóa thành viên `DELETE /groups/:id/members/:uid`, chuyển quyền `POST /groups/:id/transfer {userId}`, giải tán `DELETE /groups/:id`.
4. Tạo quest nhóm có chọn người được giao (`assigneeId`, phải là thành viên).
5. Danh sách người đã chặn + gỡ chặn: `GET /blocks`, `DELETE /blocks/:uid`.
6. Màn hình đổi mật khẩu.

## Bước 6 – Test
1. Cập nhật `test/` cho code mới (mock Dio hoặc fake repository): đăng nhập thành công/sai, tạo quest, hoàn thành quest idempotent, lỗi 401 quay về đăng nhập.
2. `flutter analyze` không lỗi, `flutter test` đạt.

## Bước 7 – Ảnh cho báo cáo
Chạy bản đã nối API với backend đang chạy (không dùng Demo Local Mode), chụp vào `docs/screenshots/` với tên cố định:
`login.png`, `register.png`, `home.png`, `quests.png`, `quest-create.png`, `quest-complete.png`, `ai-draft.png`, `groups.png`, `group-detail.png`, `notifications.png`, `safety-center.png`, `profile-light.png`, `profile-dark.png`.
Chụp thêm ảnh hai thiết bị cùng thấy quest nhóm cập nhật (`group-realtime.png`).

## Ngoài phạm vi (đừng làm)
Đăng nhập Google, push notification/FCM, nhắc hạn hệ điều hành, ảnh đại diện, quên mật khẩu qua email, Firebase.
