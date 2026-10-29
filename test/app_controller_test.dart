import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifequest/api/api_client.dart';
import 'package:lifequest/api/api_exception.dart';
import 'package:lifequest/app_controller.dart';
import 'package:lifequest/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Fake ApiClient that simulates the LifeQuest REST API in-memory.
class FakeApiClient extends ApiClient {
  FakeApiClient({super.preferences, super.onUnauthorized});

  final Map<String, dynamic> demoUser = {
    'id': 'demo-user',
    'email': 'demo@lifequest.vn',
    'displayName': 'Minh Anh',
    'xp': 160,
    'level': 2,
    'streak': 3,
    'longestStreak': 5,
    'lastActiveDate': '2026-10-22',
    'onboardingCompleted': true,
    'interests': ['Sức khỏe', 'Học tập'],
    'notificationsEnabled': true,
    'darkMode': false,
    'badges': [
      {
        'id': 'first-quest',
        'name': 'Khởi đầu',
        'description': 'Hoàn thành quest đầu tiên',
      },
    ],
  };

  bool sampleCompleted = false;

  @override
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    if (token == null || token!.isEmpty) {
      onUnauthorized?.call();
      throw const ApiException(401, 'Phiên đăng nhập không hợp lệ.');
    }

    if (path == '/me') {
      return Response(
        requestOptions: RequestOptions(path: path),
        statusCode: 200,
        data: Map<String, dynamic>.from(demoUser) as T,
      );
    }
    if (path == '/stats') {
      return Response(
        requestOptions: RequestOptions(path: path),
        statusCode: 200,
        data: {
          'xp': demoUser['xp'],
          'level': demoUser['level'],
          'xpToNextLevel': 240,
          'streak': demoUser['streak'],
          'active': 1,
          'completed': sampleCompleted ? 1 : 0,
          'archived': 0,
          'badges': demoUser['badges'],
        } as T,
      );
    }
    if (path == '/quests') {
      return Response(
        requestOptions: RequestOptions(path: path),
        statusCode: 200,
        data: [
          {
            'id': 'sample-quest',
            'ownerId': 'demo-user',
            'title': 'Đi bộ 20 phút',
            'description': 'Vận động nhẹ sau giờ học',
            'category': 'Sức khỏe',
            'difficulty': 'easy',
            'status': sampleCompleted ? 'completed' : 'active',
            'xpReward': 20,
            'xpAwarded': sampleCompleted,
            'createdByAi': false,
            'dueAt': null,
            'createdAt': '2026-10-22T08:00:00.000Z',
            'steps': [
              {'id': 's1', 'title': 'Chuẩn bị giày', 'isDone': sampleCompleted},
              {'id': 's2', 'title': 'Đi bộ 20 phút', 'isDone': sampleCompleted},
            ],
            'progress': sampleCompleted ? 1.0 : 0.0,
          },
        ] as T,
      );
    }
    if (path == '/groups') {
      return Response(
        requestOptions: RequestOptions(path: path),
        statusCode: 200,
        data: [
          {
            'id': 'sample-group',
            'name': 'Nhóm sống khỏe',
            'description': 'Cùng nhau xây dựng thói quen tốt',
            'ownerId': 'demo-user',
            'createdAt': '2026-10-22T08:00:00.000Z',
            'inviteCode': 'LIFE2026',
            'members': [
              {
                'id': 'demo-user',
                'displayName': 'Minh Anh',
                'role': 'owner',
                'joinedAt': '2026-10-22T08:00:00.000Z',
              },
            ],
          },
        ] as T,
      );
    }
    if (path == '/notifications') {
      return Response(
        requestOptions: RequestOptions(path: path),
        statusCode: 200,
        data: [] as T,
      );
    }
    if (path == '/blocks') {
      return Response(
        requestOptions: RequestOptions(path: path),
        statusCode: 200,
        data: [] as T,
      );
    }

    throw ApiException(404, 'Không tìm thấy dữ liệu: $path');
  }

  @override
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    if (path == '/auth/login') {
      final email = data['email'] as String;
      final password = data['password'] as String;
      if (email == 'demo@lifequest.vn' && password == '123456') {
        return Response(
          requestOptions: RequestOptions(path: path),
          statusCode: 200,
          data: {
            'token': 'mock-jwt-token-123',
            'user': Map<String, dynamic>.from(demoUser),
          } as T,
        );
      }
      throw const ApiException(401, 'Email hoặc mật khẩu không đúng.');
    }

    if (path == '/auth/register') {
      final email = data['email'] as String;
      if (email == 'existing@lifequest.vn') {
        throw const ApiException(409, 'Email đã được đăng ký.');
      }
      final newUser = {
        'id': 'new-user-123',
        'email': email,
        'displayName': data['displayName'],
        'xp': 0,
        'level': 1,
        'streak': 0,
        'longestStreak': 0,
        'onboardingCompleted': false,
        'interests': [],
        'notificationsEnabled': true,
        'darkMode': false,
        'badges': [],
      };
      return Response(
        requestOptions: RequestOptions(path: path),
        statusCode: 201,
        data: {'token': 'mock-new-jwt-token', 'user': newUser} as T,
      );
    }

    // Authenticated endpoints below:
    if (token == null || token!.isEmpty) {
      onUnauthorized?.call();
      throw const ApiException(401, 'Phiên đăng nhập không hợp lệ.');
    }

    if (path == '/quests') {
      final created = {
        'id': 'new-quest-id',
        'ownerId': demoUser['id'],
        'title': data['title'],
        'description': data['description'] ?? '',
        'category': data['category'] ?? 'Khác',
        'difficulty': data['difficulty'] ?? 'easy',
        'status': 'active',
        'xpReward': data['difficulty'] == 'hard'
            ? 70
            : (data['difficulty'] == 'medium' ? 40 : 20),
        'xpAwarded': false,
        'createdByAi': data['createdByAi'] ?? false,
        'dueAt': data['dueAt'],
        'createdAt': DateTime.now().toIso8601String(),
        'steps': (data['steps'] as List<dynamic>? ?? [])
            .map((s) => {'id': 'step-${s.hashCode}', 'title': s, 'isDone': false})
            .toList(),
        'progress': 0.0,
      };
      return Response(
        requestOptions: RequestOptions(path: path),
        statusCode: 201,
        data: created as T,
      );
    }

    if (path == '/quests/sample-quest/complete') {
      if (sampleCompleted) {
        return Response(
          requestOptions: RequestOptions(path: path),
          statusCode: 200,
          data: {
            'xpAwarded': 0,
            'idempotent': true,
            'quest': {
              'id': 'sample-quest',
              'ownerId': 'demo-user',
              'title': 'Đi bộ 20 phút',
              'description': 'Vận động nhẹ sau giờ học',
              'category': 'Sức khỏe',
              'difficulty': 'easy',
              'status': 'completed',
              'xpReward': 20,
              'xpAwarded': true,
              'createdByAi': false,
              'createdAt': '2026-10-22T08:00:00.000Z',
              'steps': [
                {'id': 's1', 'title': 'Chuẩn bị giày', 'isDone': true},
                {'id': 's2', 'title': 'Đi bộ 20 phút', 'isDone': true},
              ],
              'progress': 1.0,
            },
            'user': Map<String, dynamic>.from(demoUser),
          } as T,
        );
      }

      sampleCompleted = true;
      demoUser['xp'] = (demoUser['xp'] as int) + 20;
      return Response(
        requestOptions: RequestOptions(path: path),
        statusCode: 200,
        data: {
          'xpAwarded': 20,
          'idempotent': false,
          'quest': {
            'id': 'sample-quest',
            'ownerId': 'demo-user',
            'title': 'Đi bộ 20 phút',
            'description': 'Vận động nhẹ sau giờ học',
            'category': 'Sức khỏe',
            'difficulty': 'easy',
            'status': 'completed',
            'xpReward': 20,
            'xpAwarded': true,
            'createdByAi': false,
            'createdAt': '2026-10-22T08:00:00.000Z',
            'steps': [
              {'id': 's1', 'title': 'Chuẩn bị giày', 'isDone': true},
              {'id': 's2', 'title': 'Đi bộ 20 phút', 'isDone': true},
            ],
            'progress': 1.0,
          },
          'user': Map<String, dynamic>.from(demoUser),
        } as T,
      );
    }

    if (path == '/ai/quest-plan') {
      final goal = data['goal'] as String;
      if (goal.contains('chế bom') || goal.contains('tự tử')) {
        throw const ApiException(
          422,
          'LifeQuest không biến nội dung nguy hiểm thành nhiệm vụ. Hãy tìm hỗ trợ từ người đáng tin cậy.',
        );
      }
      final difficulty = data['difficulty'] as String;
      final count = difficulty == 'hard' ? 7 : (difficulty == 'medium' ? 5 : 3);
      final steps = List.generate(count, (i) => 'Bước ${i + 1} cho mục tiêu');
      return Response(
        requestOptions: RequestOptions(path: path),
        statusCode: 200,
        data: {
          'title': goal,
          'description': 'Kế hoạch do AI gợi ý',
          'category': 'Khác',
          'difficulty': difficulty,
          'estimatedMinutes': count * 15,
          'steps': steps,
          'safetyNote': 'Gợi ý an toàn',
          'source': 'mock',
        } as T,
      );
    }

    if (path == '/groups/join') {
      final code = data['inviteCode'] as String;
      if (code == 'LIFE2026') {
        return Response(
          requestOptions: RequestOptions(path: path),
          statusCode: 200,
          data: {
            'id': 'sample-group',
            'name': 'Nhóm sống khỏe',
            'description': 'Cùng nhau xây dựng thói quen tốt',
            'ownerId': 'demo-user',
            'createdAt': '2026-10-22T08:00:00.000Z',
            'members': [
              {'id': 'demo-user', 'displayName': 'Minh Anh', 'role': 'owner'},
            ],
          } as T,
        );
      }
      throw const ApiException(404, 'Mã mời không tồn tại.');
    }

    if (path == '/auth/change-password') {
      final current = data['currentPassword'] as String;
      if (current != '123456') {
        throw const ApiException(401, 'Mật khẩu hiện tại không đúng.');
      }
      return Response(
        requestOptions: RequestOptions(path: path),
        statusCode: 200,
        data: {'ok': true} as T,
      );
    }

    throw ApiException(404, 'Endpoint không tồn tại: $path');
  }

  @override
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    if (path == '/me') {
      if (data['onboardingCompleted'] != null) {
        demoUser['onboardingCompleted'] = data['onboardingCompleted'];
      }
      if (data['interests'] != null) {
        demoUser['interests'] = data['interests'];
      }
      if (data['darkMode'] != null) {
        demoUser['darkMode'] = data['darkMode'];
      }
      return Response(
        requestOptions: RequestOptions(path: path),
        statusCode: 200,
        data: Map<String, dynamic>.from(demoUser) as T,
      );
    }
    throw ApiException(404, 'Endpoint không tồn tại: $path');
  }

  @override
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    if (path == '/me') {
      await clearToken();
      return Response(
        requestOptions: RequestOptions(path: path),
        statusCode: 204,
        data: null as T,
      );
    }
    return Response(
      requestOptions: RequestOptions(path: path),
      statusCode: 204,
      data: null as T,
    );
  }
}

void main() {
  late AppController controller;
  late FakeApiClient fakeApi;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    fakeApi = FakeApiClient(preferences: prefs);
    controller = AppController(fakeApi);
    fakeApi.onUnauthorized = controller.handleUnauthorized;
    await controller.init();
    final loginError = await controller.login('demo@lifequest.vn', '123456');
    expect(loginError, isNull);
  });

  group('Auth tests', () {
    test('đăng nhập thành công', () {
      expect(controller.currentUser, isNotNull);
      expect(controller.currentUser!.email, 'demo@lifequest.vn');
      expect(fakeApi.token, isNotNull);
    });

    test('đăng nhập sai trả về thông báo lỗi', () async {
      final error = await controller.login('demo@lifequest.vn', 'sai-mat-khau');
      expect(error, contains('Email hoặc mật khẩu không đúng'));
    });

    test('lỗi 401 quay về màn hình đăng nhập (xóa token và reset user)', () async {
      await fakeApi.clearToken();
      expect(fakeApi.token, isNull);
      fakeApi.onUnauthorized?.call();
      expect(controller.currentUser, isNull);
    });
  });

  group('Quest tests', () {
    test('tạo quest thành công và cập nhật danh sách', () async {
      final quest = await controller.addQuest(
        title: 'Học Flutter REST API',
        description: 'Làm quen với Dio và API SQLite',
        category: 'Học tập',
        difficulty: QuestDifficulty.hard,
        steps: ['Cài đặt Dio', 'Tạo ApiClient', 'Viết test'],
      );

      expect(quest.title, 'Học Flutter REST API');
      expect(quest.xpReward, 70);
      expect(controller.myQuests.first.title, 'Học Flutter REST API');
    });

    test('hoàn thành quest idempotent (lần đầu nhận XP, lần 2 không nhận)', () async {
      final beforeXp = controller.currentUser!.xp;
      final first = await controller.completeQuest('sample-quest');
      expect(first.xpAwarded, 20);
      expect(first.idempotent, false);
      expect(controller.currentUser!.xp, beforeXp + 20);

      final second = await controller.completeQuest('sample-quest');
      expect(second.xpAwarded, 0);
      expect(second.idempotent, true);
      expect(controller.currentUser!.xp, beforeXp + 20);
    });
  });

  group('AI tests', () {
    test('AI tạo bản nháp theo độ khó', () async {
      final easyDraft = await controller.generateAiPlan(
        'Học Flutter cơ bản',
        QuestDifficulty.easy,
      );
      expect(easyDraft.steps.length, 3);

      final hardDraft = await controller.generateAiPlan(
        'Ôn thi cuối kỳ',
        QuestDifficulty.hard,
      );
      expect(hardDraft.steps.length, 7);
    });

    test('AI từ chối nội dung nguy hiểm (422)', () async {
      expect(
        () => controller.generateAiPlan(
          'Hướng dẫn chế bom nổ',
          QuestDifficulty.easy,
        ),
        throwsA(
          isA<ApiException>().having(
            (e) => e.statusCode,
            'statusCode',
            422,
          ),
        ),
      );
    });
  });

  group('Group tests', () {
    test('tham gia nhóm bằng mã sai trả về lỗi', () async {
      final result = await controller.joinGroup('INVALID_CODE');
      expect(result, isNotNull);
      expect(result, contains('Mã mời không tồn tại'));
    });

    test('tham gia nhóm bằng mã đúng thành công', () async {
      final result = await controller.joinGroup('LIFE2026');
      expect(result, isNull);
    });
  });

  group('Security & Profile tests', () {
    test('đổi mật khẩu thành công với mật khẩu đúng', () async {
      await expectLater(
        controller.changePassword('123456', 'newPassword678'),
        completes,
      );
    });

    test('đổi mật khẩu thất bại khi mật khẩu hiện tại sai', () async {
      await expectLater(
        controller.changePassword('wrongPass', 'newPassword678'),
        throwsA(isA<ApiException>()),
      );
    });
  });
}
