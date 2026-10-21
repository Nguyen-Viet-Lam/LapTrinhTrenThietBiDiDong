# LifeQuest Backend (REST API + SQLite)

Node.js ≥ 22.5 · Express · SQLite (`node:sqlite`, có sẵn trong Node) · JWT · bcrypt · Zod.

```bash
cd backend
npm install
cp .env.example .env   # tuỳ chọn; đặt JWT_SECRET, GEMINI_API_KEY
npm start              # http://localhost:3000/api/health, tự tạo DB + dữ liệu demo
npm test               # 7 test tích hợp chạy trên SQLite in-memory
```

- Tài khoản demo: `demo@lifequest.vn` / `123456` (và `ban@lifequest.vn`), nhóm mã mời `LIFE2026`.
- DB: file `data/lifequest.db` (đổi bằng `DB_FILE`). Schema ở `src/db.js` (users, groups_, group_members, quests, quest_steps, notifications, reports, blocks, ai_requests), khoá ngoại + `ON DELETE CASCADE`.
- Android emulator gọi API qua `http://10.0.2.2:3000/api`.
- Không có `GEMINI_API_KEY` → `/api/ai/quest-plan` dùng mock an toàn (`source: "mock"`); có key → gọi Gemini (`source: "gemini"`).

## Quy ước
- Header `Authorization: Bearer <token>` cho mọi endpoint trừ `health`, `auth/*`.
- Lỗi: `{ "error": "thông báo tiếng Việt" }` với 400/401/403/404/409/410/422/429/502.
- Thời gian ISO-8601; `difficulty`: `easy|medium|hard` (XP 20/40/70); `status`: `active|completed|archived`.
- Level = `floor(sqrt(xp/100)) + 1`.

## Endpoint

| Method | Path | Mô tả |
|---|---|---|
| POST | `/api/auth/register` `{email,password,displayName}` | Đăng ký → `{token,user}` |
| POST | `/api/auth/login` `{email,password}` | Đăng nhập → `{token,user}` |
| GET/PATCH/DELETE | `/api/me` | Hồ sơ (`displayName, interests, onboardingCompleted, notificationsEnabled, darkMode`) / xoá tài khoản (cascade) |
| GET | `/api/stats` | XP, level, streak, số quest, huy hiệu |
| GET | `/api/quests?status=&groupId=&q=` | Danh sách quest (của tôi, được giao, quest nhóm) + tìm kiếm |
| POST | `/api/quests` `{title,description,category,difficulty,steps[],dueAt,groupId,assigneeId,createdByAi}` | Tạo quest |
| GET/PATCH/DELETE | `/api/quests/:id` | Xem / sửa / xoá (chỉ người tạo) |
| POST | `/api/quests/:id/steps/:stepId/toggle` | Đánh dấu bước |
| POST | `/api/quests/:id/complete` | Hoàn thành, cộng XP **một lần** (transaction, idempotent), cập nhật streak |
| POST | `/api/quests/:id/archive` | Lưu trữ |
| GET/POST | `/api/groups` `{name,description}` | Nhóm của tôi / tạo nhóm (chủ nhóm thấy `inviteCode`) |
| POST | `/api/groups/join` `{inviteCode}` | Tham gia bằng mã (lưu hash SHA-256, hết hạn 7 ngày) |
| GET/DELETE | `/api/groups/:id` | Chi tiết + thành viên / xoá nhóm (chủ nhóm) |
| POST | `/api/groups/:id/leave` | Rời nhóm |
| DELETE | `/api/groups/:id/members/:uid` | Chủ nhóm xoá thành viên |
| POST | `/api/groups/:id/transfer` `{userId}` | Chuyển quyền chủ nhóm |
| GET | `/api/groups/:id/events?token=` | **SSE** realtime: `quest.created/updated/completed/archived/deleted`, `step.toggled`, `member.joined/left/removed`, `owner.changed`, `group.deleted` |
| POST | `/api/ai/quest-plan` `{goal,difficulty,constraints}` | Bản nháp quest (không tự lưu). 422 nếu nội dung nguy hiểm, 429 nếu gọi quá nhanh |
| GET | `/api/notifications` · POST `/api/notifications/read-all` | Thông báo |
| POST | `/api/reports` `{targetType,targetId,reason}` | Báo cáo vi phạm |
| GET/POST/DELETE | `/api/blocks`, `/api/blocks/:uid` | Chặn người dùng |

## Gợi ý cho frontend (Antigravity)
Thay `SharedPreferences` repository trong `lib/app_controller.dart` bằng client HTTP (Dio/http) gọi các endpoint trên, lưu token bằng `shared_preferences`/`flutter_secure_storage`; dùng SSE (`/groups/:id/events`) để refresh quest nhóm. JSON trả về trùng tên field với `lib/models.dart` (`isDone`, `xpReward`, `xpAwarded`, `dueAt`, `createdByAi`...); khác biệt: `AppUser.streak` ↔ `streak`, nhóm trả `members[]` thay cho `memberIds`.
