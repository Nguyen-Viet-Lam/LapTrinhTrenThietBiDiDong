# Khoảng cách từ bản demo đến Firebase production

## Đã chạy thật

- Flutter Android và Flutter Web.
- Local database bằng SharedPreferences/JSON.
- Đầy đủ luồng demo quest, XP, group, AI mock, report và settings.
- Firebase Hosting tại `https://flutter-firebase-6b5af.web.app`.
- Cloud Functions TypeScript build thành công.
- Firestore Rules được Firestore Emulator nạp thành công.

## Chưa kết nối/deploy production

1. Flutter client chưa cài và khởi tạo FlutterFire (`firebase_core`, Auth, Firestore, Functions, Messaging).
2. Đăng nhập hiện là tài khoản local; chưa dùng Firebase Auth, Google Sign-In, xác minh email hoặc reset password thật.
3. Group/quest hiện lưu theo thiết bị; chưa có realtime listener và offline queue từ Firestore.
4. AI trên giao diện đang dùng mock; `generateQuestPlan` chưa deploy và chưa có `GEMINI_API_KEY` server secret.
5. Notification hiện là inbox trong app; chưa có FCM token, push notification hoặc lịch nhắc ở hệ điều hành.
6. Firestore Rules chưa deploy lên project thật để tránh làm ảnh hưởng app Firebase cũ trong cùng project.
7. Chưa có automated Firestore Rules test bằng `@firebase/rules-unit-testing`.
8. Chưa có edit quest hoàn chỉnh, chuyển quyền/xóa thành viên nhóm, ảnh đại diện/Storage và admin moderation dashboard.
9. Chưa cấu hình App Check, Crashlytics, Analytics consent và release signing keystore.

## Khuyến nghị

Tạo Firebase project riêng cho LifeQuest thay vì dùng chung `flutter-firebase-6b5af`. Hosting demo có thể giữ nguyên, nhưng Auth/Firestore/Functions production nên ở project riêng để không ảnh hưởng dữ liệu hoặc rules của ứng dụng cũ.
