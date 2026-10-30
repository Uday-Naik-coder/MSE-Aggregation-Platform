import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../controllers/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey    = GlobalKey<FormState>();
  final _emailCtrl  = TextEditingController();
  final _passCtrl   = TextEditingController();
  bool _loading     = false;
  String? _error;

  @override
  void dispose() { _emailCtrl.dispose(); _passCtrl.dispose(); super.dispose(); }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      await ref.read(authControllerProvider.notifier).login(
        _emailCtrl.text, _passCtrl.text);
      // Router will auto-redirect based on auth state
    } catch (e) {
      setState(() { _error = e.toString(); });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.xl),
                // Header
                Row(children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: cs.primaryContainer, borderRadius: AppRadius.md),
                    child: Icon(Icons.hub_rounded, color: cs.primary, size: 28),
                  ),
                ]),
                const SizedBox(height: AppSpacing.lg),
                Text('Welcome back', style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700)),
                const SizedBox(height: AppSpacing.sm),
                Text('Sign in to MSE Aggregation Platform',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.6))),
                const SizedBox(height: AppSpacing.xl),

                // Error banner
                if (_error != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    margin: const EdgeInsets.only(bottom: AppSpacing.md),
                    decoration: BoxDecoration(
                      color: cs.errorContainer, borderRadius: AppRadius.md),
                    child: Row(children: [
                      Icon(Icons.error_outline, color: cs.error, size: 18),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_error!,
                        style: TextStyle(color: cs.error, fontSize: 13))),
                    ]),
                  ),

                AppTextField(
                  label: 'Email Address',
                  hint: 'you@example.com',
                  controller: _emailCtrl,
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'Password',
                  controller: _passCtrl,
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                  validator: Validators.password,
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: AppSpacing.xl),

                AppButton(
                  label: 'Sign In',
                  isLoading: _loading,
                  onPressed: _login,
                  icon: Icons.login,
                ),
                const SizedBox(height: AppSpacing.md),

                Center(child: TextButton(
                  onPressed: () => context.go('/register'),
                  child: RichText(text: TextSpan(
                    text: "Don't have an account? ",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.65)),
                    children: [TextSpan(
                      text: 'Register',
                      style: TextStyle(color: cs.primary, fontWeight: FontWeight.w600),
                    )],
                  )),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
