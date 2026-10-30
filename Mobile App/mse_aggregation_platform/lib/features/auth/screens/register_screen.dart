import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../controllers/auth_controller.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});
  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey       = GlobalKey<FormState>();
  final _nameCtrl      = TextEditingController();
  final _bizNameCtrl   = TextEditingController();
  final _regIdCtrl     = TextEditingController();
  final _emailCtrl     = TextEditingController();
  final _passCtrl      = TextEditingController();
  final _confirmCtrl   = TextEditingController();
  bool _loading = false;
  String? _error;
  bool _success = false;

  @override
  void dispose() {
    _nameCtrl.dispose(); _bizNameCtrl.dispose(); _regIdCtrl.dispose();
    _emailCtrl.dispose(); _passCtrl.dispose(); _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      await ref.read(authControllerProvider.notifier).register(
        name: _nameCtrl.text, businessName: _bizNameCtrl.text,
        registrationId: _regIdCtrl.text, email: _emailCtrl.text, password: _passCtrl.text,
      );
      setState(() => _success = true);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (_success) return _SuccessBanner(onLogin: () => context.go('/login'));

    return Scaffold(
      appBar: AppBar(title: const Text('Create Account'), leading: BackButton(
        onPressed: () => context.go('/login'))),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('MSE Registration', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 4),
                Text('Fill in your business details to get started.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.6))),
                const SizedBox(height: AppSpacing.lg),

                if (_error != null)
                  Container(
                    width: double.infinity, margin: const EdgeInsets.only(bottom: AppSpacing.md),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(color: cs.errorContainer, borderRadius: AppRadius.md),
                    child: Text(_error!, style: TextStyle(color: cs.error, fontSize: 13)),
                  ),

                AppTextField(label: 'Full Name', controller: _nameCtrl, prefixIcon: Icons.person_outline,
                  validator: (v) => Validators.required(v, fieldName: 'Name')),
                const SizedBox(height: AppSpacing.md),
                AppTextField(label: 'Business Name', controller: _bizNameCtrl, prefixIcon: Icons.business_outlined,
                  validator: (v) => Validators.required(v, fieldName: 'Business name')),
                const SizedBox(height: AppSpacing.md),
                AppTextField(label: 'Registration ID', controller: _regIdCtrl, prefixIcon: Icons.badge_outlined,
                  hint: 'e.g. MSME123456',
                  validator: (v) => Validators.required(v, fieldName: 'Registration ID')),
                const SizedBox(height: AppSpacing.md),
                AppTextField(label: 'Email Address', controller: _emailCtrl, prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress, validator: Validators.email),
                const SizedBox(height: AppSpacing.md),
                AppTextField(label: 'Password', controller: _passCtrl, prefixIcon: Icons.lock_outline,
                  obscureText: true, validator: Validators.password),
                const SizedBox(height: AppSpacing.md),
                AppTextField(label: 'Confirm Password', controller: _confirmCtrl,
                  prefixIcon: Icons.lock_outline, obscureText: true,
                  validator: (v) => Validators.confirmPassword(v, _passCtrl.text),
                  textInputAction: TextInputAction.done),
                const SizedBox(height: AppSpacing.xl),

                AppButton(label: 'Create Account', isLoading: _loading, onPressed: _register,
                  icon: Icons.how_to_reg_outlined),
                const SizedBox(height: AppSpacing.md),
                Center(child: TextButton(
                  onPressed: () => context.go('/login'),
                  child: RichText(text: TextSpan(
                    text: 'Already have an account? ',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.65)),
                    children: [TextSpan(text: 'Sign In',
                      style: TextStyle(color: cs.primary, fontWeight: FontWeight.w600))],
                  )),
                )),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SuccessBanner extends StatelessWidget {
  final VoidCallback onLogin;
  const _SuccessBanner({required this.onLogin});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.check_circle_outline_rounded, size: 80, color: AppColors.success),
            const SizedBox(height: AppSpacing.lg),
            Text('Registration Successful!', style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700), textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Your account has been submitted for review. An administrator will approve your account soon. You will be able to log in once approved.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65)),
              textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.xl),
            AppButton(label: 'Back to Login', onPressed: onLogin, icon: Icons.login),
          ]),
        ),
      ),
    );
  }
}
