// lib/price_change/ui/price_change_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/price_change_cubit.dart';
import '../cubit/price_change_state.dart';
import '../data/price_change_api_client.dart';
import '../data/price_change_repository.dart';
import '../../core/constants.dart';
import '../model/price_change_model.dart';

class PriceChangeScreen extends StatelessWidget {
  const PriceChangeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PriceChangeCubit(
        repository: PriceChangeRepository(
          apiClient: PriceChangeApiClient(baseUrl: AppConstants.baseUrl),
        ),
      ),
      child: const _PriceChangeView(),
    );
  }
}

class _PriceChangeView extends StatefulWidget {
  const _PriceChangeView();

  @override
  State<_PriceChangeView> createState() => _PriceChangeViewState();
}

class _PriceChangeViewState extends State<_PriceChangeView> {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();
  
  ProductOption? _selectedProduct;

  @override
  void dispose() {
    _priceController.dispose();
    
    super.dispose();
  }


  void _onFieldChanged() {
    final cubit = context.read<PriceChangeCubit>();
    if (cubit.state is PriceChangeSubmitted ||
        cubit.state is PriceChangeError) {
      cubit.reset();
    }
  }

  void _submit() {
  if (!_formKey.currentState!.validate()) return;
  if (_selectedProduct == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please select a product')),
    );
    return;
  }

  context.read<PriceChangeCubit>().submitPriceChange(
        roCode: '384619',                          // hardcoded
        roAutoId: 384619,                          // hardcoded
        productAutoId: _selectedProduct!.id,
        price: double.parse(_priceController.text.trim()),
        effectiveFrom: DateTime.now(),              // hardcoded
        effectiveTo: DateTime.now().add(const Duration(days: 365)), // hardcoded
        updateBy: 1,                                // hardcoded
      );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF1A1A1A), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Colors.black.withValues(alpha: 0.08)),
        ),
        title: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Price Change',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ),
      ),
      body: BlocConsumer<PriceChangeCubit, PriceChangeState>(
        listener: (context, state) {
          // Dismiss keyboard when result comes back
          if (state is PriceChangeSubmitted || state is PriceChangeError) {
            FocusScope.of(context).unfocus();
          }
        },
        builder: (context, state) {
          final isSubmitting = state is PriceChangeSubmitting;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Result banner ────────────────────────────────────
                  if (state is PriceChangeSubmitted)
                    _ResultBanner(
                      message: state.response.displayMessage,
                      isSuccess: state.isSuccess,
                      isPending: state.isPending,
                    ),

                  if (state is PriceChangeError)
                    _ResultBanner(
                      message: state.message,
                      isError: true,
                    ),

                 

                  _SectionCard(
  title: 'Price Details',
  children: [
    const Text(
      'Product',
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Color(0xFF444444),
      ),
    ),
    const SizedBox(height: 6),
    DropdownButtonFormField<ProductOption>(
      initialValue: _selectedProduct,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF8F8F8),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      hint: const Text('Select product'),
      items: kProductOptions.map((product) {
        return DropdownMenuItem(
          value: product,
          child: Text(product.name),
        );
      }).toList(),
      onChanged: (value) {
        setState(() => _selectedProduct = value);
        _onFieldChanged();
      },
      validator: (value) => value == null ? 'Please select a product' : null,
    ),
    const SizedBox(height: 12),
    _FormField(
      label: 'New Price (₹)',
      controller: _priceController,
      hint: '70',
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      ],
      onChanged: (_) => _onFieldChanged(),
      validator: (v) {
        if (v!.isEmpty) return 'Price is required';
        final price = double.tryParse(v);
        if (price == null || price <= 0) {
          return 'Enter a valid price';
        }
        return null;
      },
    ),
    const SizedBox(height: 12),
    
  ],
),
                  // ── Submit button ────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isSubmitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF37022),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                            const Color(0xFFF37022).withValues(alpha: 0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: isSubmitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text(
                              'Submit Price Change',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Result banner ──────────────────────────────────────────────────────────────
class _ResultBanner extends StatelessWidget {
  final String message;
  final bool isSuccess;
  final bool isPending;
  final bool isError;

  const _ResultBanner({
    required this.message,
    this.isSuccess = false,
    this.isPending = false,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color textColor;
    final IconData icon;

    if (isSuccess) {
      bg = Colors.green.shade50;
      textColor = Colors.green.shade800;
      icon = Icons.check_circle_rounded;
    } else if (isPending) {
      bg = Colors.amber.shade50;
      textColor = Colors.amber.shade800;
      icon = Icons.schedule_rounded;
    } else {
      bg = Colors.red.shade50;
      textColor = Colors.red.shade800;
      icon = Icons.error_rounded;
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section card wrapper ───────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF888888),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

// ── Reusable text field ────────────────────────────────────────────────────────
class _FormField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const _FormField({
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF444444),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
          validator: validator,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1A1A1A),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade400,
            ),
            filled: true,
            fillColor: const Color(0xFFF8F8F8),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFFF37022),
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.red.shade400),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

