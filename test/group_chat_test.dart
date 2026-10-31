import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifequest/api/api_client.dart';
import 'package:lifequest/app_controller.dart';
import 'package:lifequest/screens/groups_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_controller_test.dart';

class FakeChatApiClient extends FakeApiClient {
  FakeChatApiClient({super.preferences, super.onUnauthorized});

  final _streamController = StreamController<GroupEvent>.broadcast();

  @override
  Stream<GroupEvent> subscribeGroupEvents(String groupId) =>
      _streamController.stream;

  void dispose() {
    _streamController.close();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeChatApiClient fakeApi;
  late AppController controller;

  setUp(() async {
    SharedPreferences.setMockInitialValues({'token': 'mock-valid-jwt-token'});
    final prefs = await SharedPreferences.getInstance();
    fakeApi = FakeChatApiClient(preferences: prefs);
    controller = AppController(fakeApi);
    fakeApi.onUnauthorized = controller.handleUnauthorized;
    await controller.init();
    await controller.login('demo@lifequest.vn', '123456');
    await controller.fetchGroups();
  });

  tearDown(() {
    fakeApi.dispose();
  });

  group('Group Chat & Invite Tests', () {
    test('getGroupMessages trả về tin nhắn chào mừng ban đầu', () {
      final messages = controller.getGroupMessages('sample-group');
      expect(messages.isNotEmpty, isTrue);
      expect(messages.first.senderId, 'system');
      expect(messages.first.content, contains('Chào mừng'));
    });

    test('sendGroupMessage gửi tin nhắn thành công vào nhóm', () {
      controller.sendGroupMessage(
        'sample-group',
        'Chiều nay có ai đi đá bóng không?',
      );
      final messages = controller.getGroupMessages('sample-group');
      expect(messages.length, 2);
      expect(messages.last.content, 'Chiều nay có ai đi đá bóng không?');
      expect(messages.last.isSelf, isTrue);
    });

    testWidgets(
      'hiển thị giao diện thảo luận nhóm và gửi tin nhắn qua quick chip',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appControllerProvider.overrideWith((ref) => controller),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: GroupDetailSheet(groupId: 'sample-group'),
              ),
            ),
          ),
        );

        // Chuyển sang tab Thảo luận nhóm
        expect(find.text('💬 Thảo luận nhóm'), findsOneWidget);
        await tester.tap(find.text('💬 Thảo luận nhóm'));
        await tester.pumpAndSettle();

        // Kiểm tra các chip tin nhắn nhanh xuất hiện
        expect(find.text('🏸 Cầu lông chiều nay?'), findsOneWidget);
        expect(find.text('🏃 Sáng mai chạy bộ nhé!'), findsOneWidget);

        // Nhấn vào quick chip cầu lông
        await tester.tap(find.text('🏸 Cầu lông chiều nay?'));
        await tester.pumpAndSettle();

        // Kiểm tra tin nhắn mới xuất hiện trên màn hình chat
        expect(
          find.textContaining('Chiều nay ai rảnh đi đánh cầu lông đôi không'),
          findsOneWidget,
        );
      },
    );

    test('getDirectMessages trả về tin nhắn chào mừng kết nối 1-1', () {
      final messages = controller.getDirectMessages('peer-123');
      expect(messages.isNotEmpty, isTrue);
      expect(messages.first.content, contains('Chào bạn'));
    });

    test('sendDirectMessage gửi tin nhắn 1-1 thành công', () {
      controller.sendDirectMessage('peer-123', 'Bạn Tuấn', 'Hẹn 5h chiều nay ở sân cầu lông nhé!');
      final messages = controller.getDirectMessages('peer-123');
      expect(messages.length, 2);
      expect(messages.last.content, 'Hẹn 5h chiều nay ở sân cầu lông nhé!');
      expect(messages.last.isSelf, isTrue);
    });

    testWidgets('hiển thị DirectChatSheet và gửi tin nhắn 1-1', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appControllerProvider.overrideWith((ref) => controller),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: DirectChatSheet(
                peerId: 'peer-test',
                peerName: 'Nguyễn Văn A',
              ),
            ),
          ),
        ),
      );

      expect(find.text('Nguyễn Văn A'), findsOneWidget);
      expect(find.text('Nhắn tin 1-1 riêng tư & an toàn'), findsOneWidget);
      expect(find.text('🏸 Chiều nay đi đánh cầu không?'), findsOneWidget);

      await tester.tap(find.text('🏸 Chiều nay đi đánh cầu không?'));
      await tester.pumpAndSettle();

      expect(find.text('🏸 Chiều nay đi đánh cầu không?'), findsAtLeastNWidgets(1));
    });
  });
}
