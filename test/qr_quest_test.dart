import 'package:flutter_test/flutter_test.dart';
import 'package:lifequest/models.dart';

void main() {
  group('QR Code Sharing & Join Unit Tests', () {
    test('Tạo và giải mã mã QR nhiệm vụ (Quest QR payload)', () {
      final title = 'Kèo Cầu lông HUTECH rèn phản xạ';
      final desc = 'Đánh cầu lông đôi cùng bạn bè';
      final cat = 'Sức khỏe';
      final diff = QuestDifficulty.medium;
      final steps = [
        'Khởi động khớp cổ tay và gối',
        'Tập phát cầu chính xác',
        'Thi đấu set 21 điểm',
      ];
      final xp = 100;
      final img = 'https://images.unsplash.com/photo-1626224583764-f87db24ac4ea';

      final uriString = Uri(
        scheme: 'lifequest',
        host: 'quest',
        queryParameters: {
          'title': title,
          'desc': desc,
          'cat': cat,
          'diff': diff.name,
          'steps': steps.join('|||'),
          'xp': '$xp',
          'img': img,
        },
      ).toString();

      expect(uriString.startsWith('lifequest://quest'), isTrue);

      // Giải mã payload
      final decodedUri = Uri.parse(uriString);
      expect(decodedUri.scheme, equals('lifequest'));
      expect(decodedUri.host, equals('quest'));
      expect(decodedUri.queryParameters['title'], equals(title));
      expect(decodedUri.queryParameters['desc'], equals(desc));
      expect(decodedUri.queryParameters['cat'], equals(cat));
      expect(decodedUri.queryParameters['diff'], equals(diff.name));
      expect(
        decodedUri.queryParameters['steps']!.split('|||'),
        equals(steps),
      );
      expect(decodedUri.queryParameters['xp'], equals('100'));
      expect(decodedUri.queryParameters['img'], equals(img));
    });

    test('Tạo và giải mã mã QR gia nhập nhóm (Group QR payload)', () {
      const inviteCode = 'LIFE2026';
      final groupUriString = 'lifequest://group?invite=$inviteCode';

      final decoded = Uri.parse(groupUriString);
      expect(decoded.scheme, equals('lifequest'));
      expect(decoded.host, equals('group'));
      expect(decoded.queryParameters['invite'], equals('LIFE2026'));
    });
  });
}

