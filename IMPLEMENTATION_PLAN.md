# Kế hoạch triển khai LifeQuest

## 1. Mục tiêu và luồng demo

LifeQuest biến mục tiêu đời thường thành quest tích cực, an toàn. Người dùng làm cá nhân hoặc cùng nhóm; AI chỉ tạo gợi ý để người dùng duyệt, không tự thực hiện hành động và không đưa ra tư vấn y tế/pháp lý nguy hiểm.

Luồng demo bắt buộc:

1. Đăng ký, đăng nhập và onboarding.
2. Tạo quest thủ công hoặc nhờ AI chia nhỏ mục tiêu.
3. Hoàn thành checklist, nhận XP, level, streak và badge.
4. Tạo nhóm/mã mời; tài khoản thứ hai tham gia.
5. Giao quest nhóm; thiết bị thứ hai nhận thay đổi realtime.
6. Nhận nhắc hạn, mở đúng quest từ notification.
7. Báo cáo/chặn nội dung hoặc thành viên.
8. Mất mạng, thao tác hợp lệ và đồng bộ lại.

## 2. Phạm vi

MVP: Auth, onboarding, profile; CRUD quest/checklist; XP/level/streak/badge; nhóm/mã mời/vai trò; realtime group quest; AI tạo draft có moderation; notification; report/block/leave/delete account; Security Rules; unit/widget/integration tests.

Sau MVP: chat/reaction, ảnh minh chứng, leaderboard opt-in, recurrence nâng cao, admin dashboard, widget màn hình chính.

## 3. Kiến trúc

```text
lib/
  app/                 # bootstrap, theme, router
  core/                # errors, utils, shared widgets
  services/            # firebase, notifications, connectivity
  features/
    auth/ onboarding/ home/ quests/ groups/
    ai_assistant/ gamification/ notifications/ safety/ profile/
  l10n/
functions/src/         # Cloud Functions TypeScript
test/
integration_test/
firestore.rules
firestore.indexes.json
firebase.json
```

Mỗi feature có `data/domain/presentation`. UI không gọi Firebase trực tiếp; dùng repository. Riverpod `AsyncNotifier`/`StreamProvider`, GoRouter, immutable models với Freezed. Thời gian lưu UTC bằng server timestamp; UI đổi sang timezone local.

## 4. Schema Firestore

### `users/{uid}`

`displayName`, `email`, `avatarUrl`, `bio`, `interests[]`, `xp`, `level`, `currentStreak`, `longestStreak`, `lastActiveDate`, `timezone`, `onboardingCompleted`, `notificationEnabled`, `profileVisibility`, `createdAt`, `updatedAt`.

Subcollections: `devices/{tokenId}`, `badges/{badgeId}`, `blockedUsers/{blockedUid}`.

### `quests/{questId}`

`ownerId`, `groupId|null`, `assigneeIds[]`, `title`, `description`, `category`, `difficulty`, `status`, `visibility`, `dueAt`, `reminderAt`, `recurrence`, `progress`, `xpReward`, `createdByAi`, `completedAt`, `createdAt`, `updatedAt`.

Subcollection `steps/{stepId}`: `title`, `isCompleted`, `order`, `completedBy`, `completedAt`.

Status: `draft|active|completed|archived|cancelled`. Difficulty `easy|medium|hard`, XP `20|40|70`; backend chỉ cấp đúng một lần.

### `groups/{groupId}`

`name`, `description`, `avatarUrl`, `ownerId`, `memberCount`, `inviteCodeHash`, `inviteCodeExpiresAt`, `createdAt`, `updatedAt`.

- `members/{uid}`: `role` (`owner|member`), `displayNameSnapshot`, `joinedAt`, `status`.
- `activities/{id}`: `actorId`, `type`, `questId`, `message`, `createdAt`; không chứa email/PII.

### An toàn/vận hành

- `reports/{id}`: reporterId, targetType, targetId, groupId, reason, details, status, createdAt.
- `aiRequests/{id}`: uid, inputHash, category, outcome, safetyFlags, createdAt; không lưu prompt nhạy cảm.
- `idempotency/{eventId}`: chống cộng XP hai lần.

## 5. Màn hình

1. Splash/bootstrap; Login/Register/Forgot Password.
2. Onboarding: tên, sở thích, notification, privacy.
3. Home: XP/level/streak, quest hôm nay, quick actions.
4. Quest list: Hôm nay/Sắp tới/Hoàn thành, filter.
5. Quest detail và Create/Edit quest.
6. AI Assistant: nhập mục tiêu, review/edit draft rồi lưu.
7. Group list/detail, create/join, members, activity.
8. Notifications center.
9. Profile/Settings, blocked users, logout/delete account.
10. Safety Center và report form.

Mọi màn hình dữ liệu có loading, empty, error, offline, retry.

## 6. Backlog theo chặng

### Chặng 0 — Bootstrap

- Tạo Flutter project `com.lifequest.app`, Android/iOS.
- Cài Riverpod, GoRouter, Freezed, Firebase, intl, connectivity, notifications.
- Material 3 light/dark; font tiếng Việt; lint nghiêm ngặt.
- Config dev/prod, `.env.example`, Firebase Emulator; không commit secret.
- App shell, error boundary, logger loại PII, smoke test.

Nghiệm thu: app mở không cần Firebase production; format/analyze/test sạch.

### Chặng 1 — Auth và onboarding

- Email/password register/login/forgot/logout; Google adapter có fallback khi chưa config.
- Tạo user document lần đầu; GoRouter guards không redirect loop.
- Onboarding nhiều bước, validation, lỗi tiếng Việt.
- Auth fake cho test/demo; rules tối thiểu cho user profile.

Nghiệm thu: user mới/cũ/logout/error network đúng luồng; tests validators/guards pass.

### Chặng 2 — Quest cá nhân

- Models, converters, repository + Firebase/fake implementation.
- Create/edit/archive; query theo status/dueAt; indexes.
- Checklist transaction cập nhật progress; recurrence daily/weekly.
- List/detail/form; offline cache và pending writes.

Nghiệm thu: CRUD/checklist đúng; user A không đọc quest private user B; tests pass.

### Chặng 3 — Gamification

- Callable `completeQuest(questId)` dùng transaction và idempotency.
- Level: `floor(sqrt(xp / 100)) + 1`; streak theo timezone, tối đa một lần/ngày.
- Badges: first_quest, streak_3, streak_7, team_player.
- Completion animation có reduce motion.

Nghiệm thu: gọi đồng thời/lặp chỉ cấp XP một lần; test biên ngày/level pass.

### Chặng 4 — Nhóm và realtime

- `createGroup`, mã mời ngẫu nhiên có hạn (Firestore chỉ lưu hash).
- `joinGroup` rate-limited; leave/remove member; luật chuyển owner.
- Streams members/quests/activities; group quest chỉ giao active member.
- Offline/pending indicator; seed 2 users + 1 group trong emulator.

Nghiệm thu: hai client đồng bộ; outsider/removed member mất quyền; tests rules/functions pass.

### Chặng 5 — AI an toàn

- Callable `generateQuestPlan`; Gemini key chỉ ở server secret.
- Input/output Zod; JSON schema cố định; tối đa 8 steps, title 80, description 500.
- Moderation trước/sau; timeout/rate limit; không log prompt nguyên văn.
- Chặn tự hại, phạm pháp, CSAM và hướng dẫn nguy hiểm. Khủng hoảng không được gamify.
- `AiQuestService` Firebase + Mock; AI chỉ tạo draft để người dùng duyệt.

Nghiệm thu: malformed output/prompt injection/unsafe input không crash; APK không có key; mock chạy offline.

### Chặng 6 — Notification

- Xin quyền đúng ngữ cảnh; quản lý FCM token theo device.
- Local reminder; scheduled group reminders; notification center.
- Deep link kiểm tra lại quyền; hủy reminder khi complete/archive/leave.

Nghiệm thu: tạo/sửa/hủy đúng; tap mở đúng resource hoặc màn hình an toàn.

### Chặng 7 — Safety, privacy, accessibility

- Report user/quest/group; block/unblock; guidelines/Safety Center.
- Delete account có re-auth và cleanup/anonymize.
- Semantics, contrast, dynamic text, target >=48dp, reduce motion.
- Không PII/quest text/AI prompt trong analytics/log.

Nghiệm thu: target không đọc report; block/delete đúng quyền; accessibility audit đạt.

### Chặng 8 — QA và release

- Unit: models, validators, XP/level/streak, AI parser.
- Rules tests: owner/member/outsider/removed; function concurrency tests.
- Widget tests: auth/form/loading/empty/error/offline.
- Integration tests toàn luồng demo; pagination/index/query audit.
- Seed script, Emulator workflow, secret scan, APK release, demo script.

Nghiệm thu: analyze/lint/tests pass; APK cài được; README tái tạo môi trường mới.

## 7. Security Rules và backend bắt buộc

- User chỉ sửa hồ sơ mình; người cùng nhóm chỉ thấy snapshot công khai, không email/settings.
- Private quest chỉ owner/assignee; group quest chỉ active members.
- Client không sửa `xp`, `level`, `completedAt`, badges, counters, invite hash.
- Reports: reporter create; target không đọc; status chỉ backend/admin.
- `aiRequests`, `idempotency`: client không đọc/ghi.
- Validate type, length, enum, allowed fields; deny by default.

Cloud Functions: `createGroup`, `refreshInviteCode`, `joinGroup`, `leaveGroup`, `removeMember`, `completeQuest`, `generateQuestPlan`; triggers cho activity/notification/counters. Mỗi function kiểm tra auth, Zod input, rate/size limits, App Check production, error codes ổn định và logs không PII.

## 8. Definition of Done

- Có code và đủ loading/error/empty/offline state.
- Test phù hợp pass; Flutter analyze và TypeScript lint sạch.
- Không secret, UID, URL môi trường hoặc demo data trong production path.
- Rules/indexes cập nhật khi data access đổi.
- Tiếng Việt không tràn ở text scale 1.3/màn hình nhỏ.
- README/comment cập nhật cho quyết định khó hiểu.
- Không phá regression chặng trước.

## 9. Chia việc 4 người

- Người 1: shell, auth, onboarding, profile/settings.
- Người 2: quest, checklist, gamification, notifications.
- Người 3: groups, realtime, Functions, Security Rules.
- Người 4: AI, safety/moderation, QA, seed/demo.

Feature branch ngắn; mỗi PR một phạm vi nhỏ, kèm ảnh/video và kết quả test.
