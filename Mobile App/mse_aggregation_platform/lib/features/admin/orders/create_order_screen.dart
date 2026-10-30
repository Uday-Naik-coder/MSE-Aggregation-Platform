import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../app/theme.dart';
import '../../../core/utils/validators.dart';
import '../../../features/auth/controllers/auth_controller.dart';
import '../../../services/api_service.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import 'orders_controller.dart';

class CreateOrderScreen extends ConsumerStatefulWidget {
  const CreateOrderScreen({super.key});
  @override
  ConsumerState<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends ConsumerState<CreateOrderScreen> {
  final _formKey     = GlobalKey<FormState>();
  final _descCtrl    = TextEditingController();
  final _qtyCtrl     = TextEditingController();
  final _priceCtrl   = TextEditingController();
  DateTime? _deadline;
  bool _loading = false;
  String? _error;

  @override
  void dispose() { _descCtrl.dispose(); _qtyCtrl.dispose(); _priceCtrl.dispose(); super.dispose(); }

  Future<void> _pickDeadline() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) setState(() => _deadline = date);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (Validators.futureDate(_deadline) != null) {
      setState(() => _error = 'Please select a valid deadline');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      await ApiService(ref.read(apiClientProvider)).createOrder({
        'description':   _descCtrl.text.trim(),
        'totalQuantity': int.parse(_qtyCtrl.text.trim()),
        'pricePerUnit':  double.parse(_priceCtrl.text.trim()),
        'deadline':      _deadline!.toIso8601String(),
      });
      ref.invalidate(adminOrdersProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order created successfully!')));
        context.go('/admin/orders');
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs  = Theme.of(context).colorScheme;
    final fmt = DateFormat('dd MMM yyyy');
    return Scaffold(
      appBar: AppBar(title: const Text('Create Order')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (_error != null)
              Container(width: double.infinity, margin: const EdgeInsets.only(bottom: AppSpacing.md),
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(color: cs.errorContainer, borderRadius: AppRadius.md),
                child: Text(_error!, style: TextStyle(color: cs.error, fontSize: 13))),

            AppTextField(label: 'Order Description', controller: _descCtrl,
              maxLines: 3, textInputAction: TextInputAction.next,
              validator: (v) => Validators.required(v, fieldName: 'Description')),
            const SizedBox(height: AppSpacing.md),
            AppTextField(label: 'Total Quantity (units)', controller: _qtyCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              prefixIcon: Icons.inventory_2_outlined,
              validator: (v) => Validators.positiveNumber(v, fieldName: 'Quantity')),
            const SizedBox(height: AppSpacing.md),
            AppTextField(label: 'Price Per Unit (₹)', controller: _priceCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              prefixIcon: Icons.currency_rupee_outlined,
              validator: (v) => Validators.positiveNumber(v, fieldName: 'Price')),
            const SizedBox(height: AppSpacing.md),

            // Deadline picker
            GestureDetector(
              onTap: _pickDeadline,
              child: Container(
                width: double.infinity, padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: cs.brightness == Brightness.light ? const Color(0xFFF1F3F9) : const Color(0xFF2A2D38),
                  borderRadius: AppRadius.md),
                child: Row(children: [
                  Icon(Icons.calendar_today_outlined, color: cs.onSurface.withValues(alpha: 0.5), size: 20),
                  const SizedBox(width: 12),
                  Text(_deadline == null ? 'Select Deadline *' : fmt.format(_deadline!),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: _deadline == null ? cs.onSurface.withValues(alpha: 0.4) : cs.onSurface)),
                ]),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(label: 'Create Order', isLoading: _loading, onPressed: _submit,
              icon: Icons.check_circle_outline),
          ]),
        ),
      ),
    );
  }
}
