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
  final email = TextEditingController(text: 'lam@lifequest.vn');
  final password = TextEditingController(text: '123456');
  bool busy = false;
  bool obscurePassword = true;
  bool rememberMe = true;
  String? error;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    final emailText = email.text.trim();
    final passwordText = password.text;

    if (emailText.isEmpty || !emailText.contains('@')) {
      setState(() => error = 'Vui lòng nhập địa chỉ email hợp lệ.');
      return;
    }
    if (passwordText.isEmpty) {
      setState(() => error = 'Vui lòng nhập mật khẩu.');
      return;
    }

    setState(() {
      busy = true;
      error = null;
    });

    final message = await ref
        .read(appControllerProvider)
        .login(emailText, passwordText);

    if (mounted) {
      setState(() {
        busy = false;
        error = message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthShellLayout(
      title: 'Chào mừng trở lại',
      subtitle: 'Đăng nhập vào tài khoản LifeQuest để tiếp tục hành trình.',
      formContent: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Tên đăng nhập hoặc Email',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'Nhập email của bạn...',
              prefixIcon: Icon(Icons.mail_outline, color: Color(0xFF2563EB)),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Mật khẩu',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: password,
            obscureText: obscurePassword,
            onSubmitted: (_) => busy ? null : submit(),
            decoration: InputDecoration(
              hintText: 'Nhập mật khẩu...',
              prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF2563EB)),
              suffixIcon: IconButton(
                tooltip: obscurePassword ? 'Hiện mật khẩu' : 'Ẩn mật khẩu',
                icon: Icon(
                  obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 20,
                  color: const Color(0xFF64748B),
                ),
                onPressed: () => setState(() => obscurePassword = !obscurePassword),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              SizedBox(
                height: 24,
                width: 24,
                child: Checkbox(
                  value: rememberMe,
                  activeColor: const Color(0xFF2563EB),
                  onChanged: (val) => setState(() => rememberMe = val ?? true),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text('Duy trì đăng nhập', style: TextStyle(fontSize: 13, color: Color(0xFF475569))),
              const Spacer(),
              TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () => context.go('/forgot-password'),
                child: const Text(
                  'Quên mật khẩu?',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ),
            ],
          ),
          if (error != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Color(0xFFDC2626),
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      error!,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFB91C1C),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: const LinearGradient(
                colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.35),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: busy ? null : submit,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (busy)
                    const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  else ...[
                    const Text(
                      'Đăng nhập',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 0.3),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded, size: 18),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF2563EB),
              side: const BorderSide(color: Color(0xFFBFDBFE)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: busy ? null : () => context.go('/register'),
            child: const Text(
              'Chưa có tài khoản? Đăng ký ngay',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 18),
          // Demo Account Selector for quick testing
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F9FF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFBAE6FD)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.flash_on, size: 16, color: Color(0xFF0284C7)),
                    SizedBox(width: 6),
                    Text(
                      'Tài khoản kiểm thử nhanh (1 chạm điền):',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0369A1),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    ActionChip(
                      backgroundColor: email.text == 'lam@lifequest.vn'
                          ? const Color(0xFF0284C7)
                          : Colors.white,
                      label: Text(
                        '🛡️ Admin (Lãm)',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: email.text == 'lam@lifequest.vn' ? Colors.white : const Color(0xFF0C1E3C),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          email.text = 'lam@lifequest.vn';
                          password.text = '123456';
                        });
                      },
                    ),
                    ActionChip(
                      backgroundColor: email.text == 'demo@lifequest.vn'
                          ? const Color(0xFF0284C7)
                          : Colors.white,
                      label: Text(
                        '👤 User (Demo)',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: email.text == 'demo@lifequest.vn' ? Colors.white : const Color(0xFF0C1E3C),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          email.text = 'demo@lifequest.vn';
                          password.text = '123456';
                        });
                      },
                    ),
                    ActionChip(
                      backgroundColor: email.text == 'ky@lifequest.vn'
                          ? const Color(0xFF0284C7)
                          : Colors.white,
                      label: Text(
                        '⚡ User (Kỳ)',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: email.text == 'ky@lifequest.vn' ? Colors.white : const Color(0xFF0C1E3C),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          email.text = 'ky@lifequest.vn';
                          password.text = '123456';
                        });
                      },
                    ),
                    ActionChip(
                      backgroundColor: email.text == 'tuan@lifequest.vn'
                          ? const Color(0xFF0284C7)
                          : Colors.white,
                      label: Text(
                        '📘 User (Tuấn)',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: email.text == 'tuan@lifequest.vn' ? Colors.white : const Color(0xFF0C1E3C),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          email.text = 'tuan@lifequest.vn';
                          password.text = '123456';
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
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
  bool obscurePassword = true;

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    final nameText = name.text.trim();
    final emailText = email.text.trim();
    final passwordText = password.text;

    if (nameText.length < 2) {
      setState(() => error = 'Vui lòng nhập tên ít nhất 2 ký tự.');
      return;
    }
    if (emailText.isEmpty || !emailText.contains('@')) {
      setState(() => error = 'Vui lòng nhập địa chỉ email hợp lệ.');
      return;
    }
    if (passwordText.length < 6) {
      setState(() => error = 'Mật khẩu cần ít nhất 6 ký tự.');
      return;
    }

    setState(() {
      busy = true;
      error = null;
    });

    final message = await ref
        .read(appControllerProvider)
        .register(nameText, emailText, passwordText);

    if (mounted) {
      setState(() {
        busy = false;
        error = message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthShellLayout(
      title: 'Tạo tài khoản mới',
      subtitle: 'Đăng ký tài khoản để bắt đầu rèn luyện mục tiêu với LifeQuest.',
      formContent: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Họ và tên của bạn',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: name,
            decoration: const InputDecoration(
              hintText: 'Ví dụ: Minh Anh',
              prefixIcon: Icon(Icons.person_outline, color: Color(0xFF2563EB)),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Địa chỉ Email',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'user@lifequest.vn',
              prefixIcon: Icon(Icons.mail_outline, color: Color(0xFF2563EB)),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Mật khẩu (tối thiểu 6 ký tự)',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: password,
            obscureText: obscurePassword,
            decoration: InputDecoration(
              hintText: 'Tối thiểu 6 ký tự...',
              prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF2563EB)),
              suffixIcon: IconButton(
                icon: Icon(
                  obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 20,
                  color: const Color(0xFF64748B),
                ),
                onPressed: () => setState(() => obscurePassword = !obscurePassword),
              ),
            ),
          ),
          if (error != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: Text(
                error!,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFB91C1C),
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: const LinearGradient(
                colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.35),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: busy ? null : submit,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (busy)
                    const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  else ...[
                    const Text(
                      'Tạo tài khoản',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded, size: 18),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF2563EB),
              side: const BorderSide(color: Color(0xFFBFDBFE)),
            ),
            onPressed: busy ? null : () => context.go('/login'),
            child: const Text('Đã có tài khoản? Đăng nhập'),
          ),
        ],
      ),
    );
  }
}

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailController = TextEditingController();
  bool sent = false;
  bool busy = false;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  void handleReset() {
    final text = emailController.text.trim();
    if (text.isEmpty) return;
    setState(() => busy = true);
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) {
        setState(() {
          busy = false;
          sent = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AuthShellLayout(
      title: 'Quên mật khẩu?',
      subtitle: 'Khôi phục quyền truy cập vào tài khoản LifeQuest của bạn.',
      formContent: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (sent) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFA7F3D0)),
              ),
              child: const Column(
                children: [
                  Icon(Icons.check_circle_outline, color: Color(0xFF059669), size: 36),
                  SizedBox(height: 8),
                  Text(
                    'Đã gửi liên kết khôi phục!',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF065F46)),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Vui lòng kiểm tra hộp thư email của bạn. Nếu cần hỗ trợ thêm, hãy gửi thư tới support@lifequest.vn.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12.5, color: Color(0xFF047857)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ] else ...[
            const Text(
              'Địa chỉ Email đăng ký tài khoản',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'Nhập email của bạn...',
                prefixIcon: Icon(Icons.mark_email_read_outlined, color: Color(0xFF2563EB)),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: const LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: busy ? null : handleReset,
                child: busy
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Gửi yêu cầu khôi phục',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(height: 14),
          ],
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF2563EB),
              side: const BorderSide(color: Color(0xFFBFDBFE)),
            ),
            onPressed: () => context.go('/login'),
            child: const Text('Quay lại đăng nhập'),
          ),
        ],
      ),
    );
  }
}

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});
  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final Set<String> selected = {'Sức khỏe'};
  bool saving = false;

  static const interests = [
    'Sức khỏe',
    'Học tập',
    'Công việc',
    'Gia đình',
    'Tài chính',
    'Sáng tạo',
  ];

  Future<void> submit() async {
    setState(() => saving = true);
    try {
      await ref
          .read(appControllerProvider)
          .completeOnboarding(selected.toList());
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Thiết lập LifeQuest')),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF38BDF8)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.explore_rounded, size: 44, color: Colors.white),
              ),
              const SizedBox(height: 20),
              Text(
                'Bạn muốn tập trung vào điều gì?',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Chọn ít nhất một chủ đề. Bạn có thể thay đổi sau trong cài đặt.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: interests
                    .map(
                      (item) => FilterChip(
                        label: Text(item),
                        selected: selected.contains(item),
                        selectedColor: const Color(0xFFEFF6FF),
                        checkmarkColor: const Color(0xFF2563EB),
                        onSelected: (value) => setState(
                          () => value ? selected.add(item) : selected.remove(item),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 32),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                  ),
                ),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: selected.isEmpty || saving ? null : submit,
                  icon: saving
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.rocket_launch),
                  label: Text(saving ? 'Đang lưu...' : 'Bắt đầu hành trình'),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'LifeQuest khuyến khích tiến bộ vừa sức, không tạo áp lực hoặc thay thế tư vấn chuyên môn.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Layout XANH DƯƠNG - TRẮNG Dịu mắt cho LifeQuest
class AuthShellLayout extends StatelessWidget {
  const AuthShellLayout({
    required this.title,
    required this.subtitle,
    required this.formContent,
    super.key,
  });

  final String title;
  final String subtitle;
  final Widget formContent;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 860;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Top Brand Header Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'LifeQuest',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              letterSpacing: -0.3,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            'HỆ THỐNG QUẢN LÝ NHIỆM VỤ & MỤC TIÊU',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2563EB),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (width > 640) ...[
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFBFDBFE)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.shield_outlined, size: 13, color: Color(0xFF2563EB)),
                            SizedBox(width: 6),
                            Text(
                              'Hệ thống Bảo mật LifeQuest',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: Color(0xFF1D4ED8),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Main Card Container (Blue & White Dual-Pane on desktop)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1040),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 28,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: isDesktop
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Left Column (Ocean Blue Hero Panel)
                                Expanded(
                                  flex: 5,
                                  child: Container(
                                    padding: const EdgeInsets.all(40),
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [Color(0xFF1E40AF), Color(0xFF2563EB)],
                                      ),
                                    ),
                                    child: _buildHeroLeftPanel(),
                                  ),
                                ),
                                // Right Column (Pure White Form Panel)
                                Expanded(
                                  flex: 6,
                                  child: Container(
                                    color: Colors.white,
                                    padding: const EdgeInsets.all(40),
                                    child: _buildFormPanel(context),
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Top Blue Banner on mobile
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 26,
                                  ),
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [Color(0xFF1E40AF), Color(0xFF2563EB)],
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Text(
                                          'LIFEQUEST ECOSYSTEM',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 10,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      const Text(
                                        'LifeQuest Mobile & Web',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 22,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        'Nền tảng Quản lý Mục tiêu & Trợ lý Gamification thông minh.',
                                        style: TextStyle(
                                          color: Color(0xFFDBEAFE),
                                          fontSize: 12.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  color: Colors.white,
                                  padding: const EdgeInsets.all(24),
                                  child: _buildFormPanel(context),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),

              // Bottom Footer
              const Padding(
                padding: EdgeInsets.only(bottom: 24),
                child: Text(
                  '© 2026 LifeQuest · Nền tảng Gamification & Quản lý Nhiệm vụ Thông minh',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroLeftPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
          ),
          child: const Text(
            'LIFEQUEST PLATFORM',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 11,
              letterSpacing: 0.8,
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Một tài khoản cho toàn bộ hành trình mục tiêu của bạn',
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.w900,
            height: 1.25,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'Hệ thống quản lý thói quen, nhiệm vụ nhóm và trợ lý AI thông minh theo phương pháp Gamification.',
          style: TextStyle(
            color: Color(0xFFDBEAFE),
            fontSize: 13.5,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 36),
        const Text(
          'ỨNG DỤNG BẢO MẬT & ĐỒNG BỘ',
          style: TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Color(0xFF2563EB),
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LifeQuest Mobile & Web',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Đồng bộ thời gian thực SSE · Bảo mật JWT',
                      style: TextStyle(
                        color: Color(0xFFDBEAFE),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        const Row(
          children: [
            _HeroBadge(
              icon: Icons.lock_outline,
              label: 'Xác thực JWT / OAuth2',
            ),
            SizedBox(width: 12),
            _HeroBadge(
              icon: Icons.security,
              label: 'Bảo mật AES-256',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFormPanel(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F172A),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 24),
        formContent,
      ],
    );
  }
}

class _HeroBadge extends StatelessWidget {
  const _HeroBadge({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
