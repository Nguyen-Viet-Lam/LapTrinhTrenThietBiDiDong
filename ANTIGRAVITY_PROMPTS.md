# Prompt giao việc cho Antigravity

## Cách dùng

Gửi **Prompt nền** trước, sau đó gửi từng prompt chặng. Không giao tất cả cùng lúc. Sau mỗi chặng phải xem file đã đổi, lệnh đã chạy, kết quả test và phần còn thiếu trước khi chuyển chặng.

## Prompt nền

```text
Bạn là senior Flutter + Firebase engineer. Hãy xây LifeQuest trong workspace hiện tại. Trước khi sửa code, đọc toàn bộ README.md và IMPLEMENTATION_PLAN.md.

Quy tắc bắt buộc:
1. Stack: Flutter/Dart, Material 3, Riverpod, GoRouter, Freezed; Firebase Auth/Firestore/FCM/Functions TypeScript.
2. Kiến trúc feature-first; presentation không gọi Firebase trực tiếp, mọi truy cập qua repository/service.
3. Không đặt secret/Gemini API key trong Flutter. AI chỉ gọi qua Cloud Functions và phải có mock để demo.
4. XP, join group, owner permissions và dữ liệu nhạy cảm phải xác thực backend; không tin client.
5. Duy trì Firestore Rules deny-by-default và rules tests.
6. UI tiếng Việt, light/dark, đủ loading/empty/error/offline, accessibility và màn hình nhỏ.
7. Không xóa thay đổi không liên quan; không để TODO/placeholder cho phần thuộc chặng hiện tại.
8. Sau khi sửa: format, analyze, lint, test phù hợp. Nếu thiếu SDK/config, nói chính xác và hoàn thiện tối đa phần tĩnh.
9. Chỉ làm đúng chặng được giao. Cuối chặng báo cáo: tóm tắt, file thay đổi, lệnh + kết quả thật, cách test tay, việc còn lại/rủi ro.

Hãy khảo sát workspace, đối chiếu kế hoạch, nêu kế hoạch ngắn rồi thực hiện ngay. Không chỉ trả lời bằng hướng dẫn hoặc code snippet: phải tạo/sửa file thật.
```

## Prompt 0 — Bootstrap

```text
Thực hiện Chặng 0 trong IMPLEMENTATION_PLAN.md. Tạo Flutter project package com.lifequest.app, cấu trúc feature-first, dependencies đúng stack, Material 3 light/dark, GoRouter shell, Riverpod bootstrap, error handling và logger không ghi PII. Thêm dev/prod config, .env.example không secret, Firebase Emulator config và README setup. Tạo Login/Home placeholder có chủ đích để chứng minh router. Thêm smoke test.

Acceptance: format/analyze sạch, smoke test pass, app khởi động chưa cần Firebase production. Chưa làm Auth.
```

## Prompt 1 — Auth/onboarding

```text
Thực hiện Chặng 1. Xây register/login/forgot password/logout, AuthRepository, Firebase implementation và fake cho test/demo. GoRouter auth/onboarding guards không redirect loop. Tạo user document an toàn lần đăng nhập đầu. Onboarding nhiều bước: tên, interests, notification preference, profile visibility. Lỗi tiếng Việt, validation đầy đủ. Google Sign-In chỉ có graceful fallback nếu thiếu config.

Viết unit/widget tests cho validators, controller state, router guards; cập nhật user rules. Acceptance: user mới/cũ/logout/network error/email sai kiểm thử được; analyze/tests pass.
```

## Prompt 2 — Quest cá nhân

```text
Thực hiện Chặng 2. Tạo models/repository/controllers/UI cho quest/steps. Hoàn thiện list Hôm nay-Sắp tới-Hoàn thành, filter, detail, create/edit/archive, checklist progress, reminder và recurrence daily/weekly. Firestore queries có indexes; private rules đúng; không hard delete. Có fake repository.

UI timezone local, Firestore UTC. Đủ loading/empty/error/offline/pending writes. Tests model/converter/validation/controller/widget và rules owner-vs-outsider. Acceptance: CRUD/checklist đúng, outsider không đọc private quest, analyze/tests pass.
```

## Prompt 3 — Gamification

```text
Thực hiện Chặng 3. Callable completeQuest bằng TypeScript, Zod và Firestore transaction; idempotent. Client không tự sửa xp/level/completedAt/badge. Áp dụng level formula, streak theo timezone và 4 badge MVP. Client retry an toàn, celebration hỗ trợ reduce-motion.

Tests: gọi lặp, 10 concurrent calls, sai quyền, archived quest, biên ngày/timezone, level thresholds. Cập nhật rules. Acceptance: concurrency vẫn cấp XP đúng một lần; tests/analyze/lint pass.
```

## Prompt 4 — Group/realtime

```text
Thực hiện Chặng 4. Xây create group, invite code có hạn chỉ lưu hash, refresh invite, join rate-limited, leave, remove member, luật owner, group detail, members, group quests, activity feed. Nghiệp vụ quan trọng dùng callable + transaction. Streams realtime, offline/pending indicator; assignee phải active member.

Rules tests cho owner/member/outsider/removed. Seed/dev helper tạo 2 users + 1 group trên Emulator, không vào production build. Acceptance: 2 client sync; outsider/removed mất quyền; invite sai/hết hạn có lỗi đúng; tests pass.
```

## Prompt 5 — AI an toàn

```text
Thực hiện Chặng 5. AI flow phải là draft-review-save. Client gọi generateQuestPlan; Gemini key ở server secret. Backend Zod input/output, JSON schema cố định, timeout, rate limit, moderation trước/sau, không log prompt. System instruction chống prompt injection; model không có tool/action permissions.

Tạo MockAiQuestService fixture để demo không mạng/key. Xử lý malformed output, quota, timeout và unsafe content bằng UI tiếng Việt. Tự hại/khủng hoảng không gamify; trả hỗ trợ tổng quát và link Safety Center, không hard-code hotline.

Tests parser/schema, injection, unsafe input, giới hạn 8 steps, retry/mock. Quét APK/source client tìm key. Acceptance: chỉ tạo draft; lỗi model không crash; mock độc lập; tests pass.
```

## Prompt 6 — Notifications

```text
Thực hiện Chặng 6. Notification permission theo ngữ cảnh, FCM token lifecycle, local quest reminders, in-app notification center, deep link kiểm tra quyền. Scheduled backend reminders cho group theo bucket/query hiệu quả. Hủy reminder khi complete/archive/leave.

Tạo abstraction/fake. Tests scheduling mapping, token refresh, deep-link authorization. Acceptance: tạo/sửa/hủy đúng; tap mở resource còn quyền hoặc màn hình an toàn; tests pass.
```

## Prompt 7 — Safety/privacy/accessibility

```text
Thực hiện Chặng 7. Report user/quest/group, block/unblock, community guidelines, Safety Center, privacy settings, delete account có re-auth + cleanup/anonymization. Target không được đọc report. Áp dụng block khi dựng feed và ở backend.

Audit semantics, contrast, text scale 1.3+, 48dp targets, reader labels, reduce motion. Audit logs/analytics không chứa quest text, email hoặc AI prompt. Bổ sung rules/widget tests. Acceptance: report/block/delete đúng quyền; accessibility màn hình chính đạt; tests pass.
```

## Prompt 8 — QA/release

```text
Thực hiện Chặng 8; không thêm feature. Audit repository, sửa compile/analyze/lint/test, hoàn thiện unit/widget/rules/functions/integration tests cho luồng demo. Tối ưu listeners/query/pagination/indexes. Hoàn thiện seed, Emulator workflow, README máy mới, .env.example, APK release workflow và demo script 5-7 phút.

Quét secret/PII logs. Chỉ báo pass nếu đã chạy thật. Tạo RELEASE_CHECKLIST.md liệt kê config Firebase/Gemini người dùng phải cung cấp. Acceptance: validations pass, APK build nếu SDK/config đủ, không secret, tài liệu tái tạo được.
```

## Prompt review cuối

```text
Đóng vai security reviewer độc lập, không thêm tính năng. Đọc IMPLEMENTATION_PLAN.md và lập bảng PASS/FAIL/PARTIAL có bằng chứng file/test. Tìm: Firestore Rules hở, client tự cộng XP, join trái phép, lộ Gemini key, IDOR deep link, double-award concurrency, PII logs, AI prompt injection/unsafe và offline sync conflict. Sửa mọi Critical/High tái hiện được, thêm regression tests rồi chạy lại toàn bộ validation. Báo chính xác phần chưa thể xác minh.
```

## Prompt xử lý khi Antigravity báo xong quá sớm

```text
Không chấp nhận mô tả chung. Hãy chứng minh chặng vừa làm bằng: (1) git diff/file list, (2) từng acceptance criterion gắn với file/test cụ thể, (3) output thật của format/analyze/lint/tests, (4) ít nhất một negative test về quyền hoặc lỗi mạng, (5) danh sách TODO còn tồn tại bằng lệnh tìm kiếm. Nếu có FAIL/PARTIAL, tiếp tục sửa trước khi kết luận.
```
