# Prompt giao Antigravity làm báo cáo môn học

```text
Bạn là trợ lý viết báo cáo kỹ thuật cho đồ án môn Lập trình thiết bị di động. Hãy đọc TOÀN BỘ source LifeQuest trong workspace, đặc biệt README.md, BAO_CAO_DO_AN.md, IMPLEMENTATION_PLAN.md, lib/, test/, functions/src/index.ts, firestore.rules và firestore.indexes.json.

Nhiệm vụ:
1. Kiểm chứng nội dung bằng code thật; không tự bịa chức năng chưa có.
2. Viết báo cáo tiếng Việt theo văn phong sinh viên, rõ ràng, có chiều sâu kỹ thuật.
3. Cấu trúc: trang bìa placeholder; lời cảm ơn; mục lục; chương 1 tổng quan; chương 2 cơ sở lý thuyết/công nghệ; chương 3 phân tích yêu cầu; chương 4 thiết kế hệ thống; chương 5 cài đặt; chương 6 kiểm thử; chương 7 kết luận/hướng phát triển; tài liệu tham khảo; phụ lục hướng dẫn chạy.
4. Chương phân tích phải có actor, functional/non-functional requirements, use-case table và business rules.
5. Chương thiết kế phải mô tả kiến trúc, component, navigation flow, class/domain model, Firestore schema, Security Rules và Cloud Functions. Tạo Mermaid source cho use-case, activity, sequence, class và deployment diagrams; không tuyên bố hình đã render nếu chưa render.
6. Chương cài đặt trích dẫn file và đoạn code ngắn tiêu biểu: AppController, completeQuest idempotency, AI safety, invite hash và Firestore Rules. Không chép nguyên file dài.
7. Chương kiểm thử dùng kết quả thực tế; chạy lại flutter analyze, flutter test và npm run build trong functions. Ghi PASS/FAIL đúng output, không bịa số liệu.
8. Nêu rõ hai chế độ: Demo Local Mode chạy độc lập; Firebase Production Backend đã chuẩn bị nhưng cần project/config thật để Flutter client sync đa thiết bị. Không được mô tả local demo là realtime production.
9. Chừa placeholder có nhãn [CHÈN ẢNH ...] cho các màn hình: Login, Home, Quest, AI Draft, Group, Safety Center, Dark Mode.
10. Tạo file BAO_CAO_LIFEQUEST.md và SLIDE_OUTLINE.md. Cuối cùng báo file đã tạo, lệnh test đã chạy và các placeholder người dùng cần điền (trường, khoa, GVHD, nhóm, MSSV, ảnh chụp).

Yêu cầu chất lượng: 35–50 trang khi đưa sang Word, thuật ngữ nhất quán, bảng biểu có số/thứ tự, không đạo văn, không tuyên bố triển khai cloud nếu chưa có bằng chứng deploy.
```
