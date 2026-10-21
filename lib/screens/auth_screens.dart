import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final email = TextEditingController(text: 'demo@lifequest.vn');
  final password = TextEditingController(text: '123456');
  bool busy = false;
  String? error;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    setState(() {
      busy = true;
      error = null;
    });
    final message = await ref
        .read(appControllerProvider)
        .login(email.text, password.text);
    if (mounted) {
      setState(() {
        busy = false;
        error = message;
      });
    }
  }

  @override
  Widget build(BuildContext context) => AuthScaffold(
    title: 'Chào mừng trở lại',
    subtitle: 'Mỗi việc nhỏ hôm nay tạo nên một hành trình lớn.',
    children: [
      TextField(
        controller: email,
        keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(
          labelText: 'Email',
          prefixIcon: Icon(Icons.mail_outline),
        ),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: password,
        obscureText: true,
        onSubmitted: (_) => submit(),
        decoration: const InputDecoration(
          labelText: 'Mật khẩu',
          prefixIcon: Icon(Icons.lock_outline),
        ),
      ),
      if (error != null) ...[
        const SizedBox(height: 12),
        Text(
          error!,
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      ],
      const SizedBox(height: 20),
      FilledButton.icon(
        onPressed: busy ? null : submit,
        icon: busy
            ? const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.login),
        label: const Text('Đăng nhập'),
      ),
      TextButton(
        onPressed: () => context.go('/register'),
        child: const Text('Chưa có tài khoản? Đăng ký'),
      ),
      const Divider(),
      const Text(
        'Tài khoản demo: demo@lifequest.vn / 123456',
        textAlign: TextAlign.center,
      ),
    ],
  );
}

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});
  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  String? error;
  bool busy = false;

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (name.text.trim().length < 2) {
      setState(() => error = 'Vui lòng nhập tên ít nhất 2 ký tự.');
      return;
    }
    setState(() {
      busy = true;
      error = null;
    });
    final message = await ref
        .read(appControllerProvider)
        .register(name.text, email.text, password.text);
    if (mounted) {
      setState(() {
        busy = false;
        error = message;
      });
    }
  }

  @override
  Widget build(BuildContext context) => AuthScaffold(
    title: 'Tạo tài khoản',
    subtitle: 'Bắt đầu với một nhiệm vụ vừa sức.',
    children: [
      TextField(
        controller: name,
        decoration: const InputDecoration(
          labelText: 'Tên hiển thị',
          prefixIcon: Icon(Icons.person_outline),
        ),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: email,
        keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(
          labelText: 'Email',
          prefixIcon: Icon(Icons.mail_outline),
        ),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: password,
        obscureText: true,
        decoration: const InputDecoration(
          labelText: 'Mật khẩu (tối thiểu 6 ký tự)',
          prefixIcon: Icon(Icons.lock_outline),
        ),
      ),
      if (error != null) ...[
        const SizedBox(height: 12),
        Text(
          error!,
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      ],
      const SizedBox(height: 20),
      FilledButton(
        onPressed: busy ? null : submit,
        child: const Text('Tạo tài khoản'),
      ),
      TextButton(
        onPressed: () => context.go('/login'),
        child: const Text('Đã có tài khoản? Đăng nhập'),
      ),
    ],
  );
}

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});
  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final Set<String> selected = {'Sức khỏe'};
  static const interests = [
    'Sức khỏe',
    'Học tập',
    'Công việc',
    'Gia đình',
    'Tài chính',
    'Sáng tạo',
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Thiết lập LifeQuest')),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Icon(
            Icons.explore_rounded,
            size: 72,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Bạn muốn tập trung vào điều gì?',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Chọn ít nhất một chủ đề. Bạn có thể thay đổi sau.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: interests
                .map(
                  (item) => FilterChip(
                    label: Text(item),
                    selected: selected.contains(item),
                    onSelected: (value) => setState(
                      () => value ? selected.add(item) : selected.remove(item),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: selected.isEmpty
                ? null
                : () => ref
                      .read(appControllerProvider)
                      .completeOnboarding(selected.toList()),
            icon: const Icon(Icons.rocket_launch),
            label: const Text('Bắt đầu hành trình'),
          ),
          const SizedBox(height: 12),
          const Text(
            'LifeQuest khuyến khích tiến bộ vừa sức, không tạo áp lực hoặc thay thế tư vấn chuyên môn.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    required this.title,
    required this.subtitle,
    required this.children,
    super.key,
  });
  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CircleAvatar(
                  radius: 42,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                  child: Icon(
                    Icons.auto_awesome,
                    size: 42,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(subtitle, textAlign: TextAlign.center),
                const SizedBox(height: 28),
                ...children,
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
