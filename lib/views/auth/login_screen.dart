import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../utils/theme.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  bool _isOtpSent = false;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeInOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty || phone.length < 8) {
      setState(() => _error = 'الرجاء إدخال رقم هاتف صحيح');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Check if phone is allowed
      final check = await ref.read(authProvider.notifier).checkPhone(phone, 'login');
      if (check['allowed'] != true) {
        setState(() {
          _isLoading = false;
          _error = check['reason'] == 'not_found'
              ? 'الرقم غير مسجل. الرجاء التسجيل أولاً.'
              : 'حدث خطأ في التحقق';
        });
        return;
      }

      await ref.read(authProvider.notifier).sendOtp(phone);
      setState(() {
        _isOtpSent = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'حدث خطأ: ${e.toString()}';
      });
    }
  }

  Future<void> _verifyOtp() async {
    final code = _otpController.text.trim();
    if (code.length != 6) {
      setState(() => _error = 'الرجاء إدخال رمز التحقق المكون من 6 أرقام');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await ref.read(authProvider.notifier).verifyOtp(
            _phoneController.text.trim(),
            code,
          );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'رمز التحقق غير صحيح';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A0E21),
              Color(0xFF141A36),
              Color(0xFF0A0E21),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo / Icon
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryBlue.withValues(alpha: 0.4),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.home_work_rounded,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Title
                    const Text(
                      'سمسار عقاري',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'إدارة العقارات بذكاء',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Phone input card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: AppTheme.cardGradient,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppTheme.divider),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _isOtpSent ? 'أدخل رمز التحقق' : 'تسجيل الدخول',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _isOtpSent
                                ? 'تم إرسال رمز التحقق إلى +965${_phoneController.text}'
                                : 'أدخل رقم هاتفك الكويتي',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),

                          if (!_isOtpSent) ...[
                            // Phone field
                            Directionality(
                              textDirection: TextDirection.ltr,
                              child: TextField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(8),
                                ],
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 18,
                                  letterSpacing: 2,
                                ),
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                  prefixIcon: Container(
                                    width: 60,
                                    alignment: Alignment.center,
                                    child: const Text(
                                      '+965',
                                      style: TextStyle(
                                        color: AppTheme.accentCyan,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  hintText: '12345678',
                                  hintStyle: TextStyle(
                                    color: AppTheme.textMuted.withValues(alpha: 0.5),
                                    fontSize: 18,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ),
                            ),
                          ] else ...[
                            // OTP field
                            Directionality(
                              textDirection: TextDirection.ltr,
                              child: TextField(
                                controller: _otpController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(6),
                                ],
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 28,
                                  letterSpacing: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                  hintText: '------',
                                  hintStyle: TextStyle(
                                    color: AppTheme.textMuted.withValues(alpha: 0.3),
                                    fontSize: 28,
                                    letterSpacing: 10,
                                  ),
                                ),
                              ),
                            ),
                          ],

                          if (_error != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              _error!,
                              style: const TextStyle(color: AppTheme.error, fontSize: 13),
                              textAlign: TextAlign.center,
                            ),
                          ],

                          const SizedBox(height: 24),

                          // Submit button
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _isLoading
                                  ? null
                                  : (_isOtpSent ? _verifyOtp : _sendOtp),
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      _isOtpSent ? 'تحقق' : 'إرسال رمز التحقق',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                            ),
                          ),

                          if (_isOtpSent) ...[
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _isOtpSent = false;
                                  _otpController.clear();
                                  _error = null;
                                });
                              },
                              child: const Text(
                                'تغيير رقم الهاتف',
                                style: TextStyle(color: AppTheme.accentCyan),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Skip login (browse as guest)
                    TextButton(
                      onPressed: () {
                        // Navigate directly to home without auth
                        Navigator.of(context).pushReplacementNamed('/home');
                      },
                      child: const Text(
                        'تصفح كزائر',
                        style: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 14,
                          decoration: TextDecoration.underline,
                          decorationColor: AppTheme.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
