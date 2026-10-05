// lib/density/ui/density_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../constants/product_options.dart';
import '../../core/constants.dart';
import '../../home/bloc/ro_bloc.dart';
import '../../home/model/ro_config_model.dart';
import '../cubit/density_cubit.dart';
import '../cubit/density_state.dart';
import '../data/density_api_client.dart';
import '../data/density_repository.dart';

class DensityScreen extends StatelessWidget {
  const DensityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DensityCubit(
        repository: DensityRepository(
          apiClient: DensityApiClient(baseUrl: AppConstants.baseUrl),
        ),
      ),
      child: const _DensityView(),
    );
  }
}

class _DensityView extends StatefulWidget {
  const _DensityView();

  @override
  State<_DensityView> createState() => _DensityViewState();
}

class _DensityViewState extends State<_DensityView> {
  final _formKey = GlobalKey<FormState>();
  final _densityController = TextEditingController();

  int? _selectedTankNo;
  ProductOption? _selectedProduct;

  @override
  void dispose() {
    _densityController.dispose();
    super.dispose();
  }

  void _onFieldChanged() {
    final cubit = context.read<DensityCubit>();
    if (cubit.state is DensitySubmitted || cubit.state is DensityError) {
      cubit.reset();
    }
  }

  /// Walks /roconfig's duList → pumpList → nozzleList to collect
  /// unique tankNo values.
  List<int> _tankNumbers(RoConfigModel? config) {
    if (config == null) return const [];
    final set = <int>{};
    for (final du in config.duList) {
      for (final pump in du.pumpList) {
        for (final nozzle in pump.nozzleList) {
          if (nozzle.tankNo > 0) set.add(nozzle.tankNo);
        }
      }
    }
    final list = set.toList()..sort();
    return list;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedTankNo == null) {
      _showSnackBar('Please select a tank');
      return;
    }
    if (_selectedProduct == null) {
      _showSnackBar('Please select a product');
      return;
    }

    final runtimeRoCode = context.read<RoBloc>().runtimeRoCode;
    if (runtimeRoCode == null || runtimeRoCode == 0) {
      _showSnackBar('Outlet code not available. Reconnect to the server.');
      return;
    }

    context.read<DensityCubit>().submitDensityChange(
          roAutoId: runtimeRoCode,
          tankAutoId: _selectedTankNo!,
          productId: _selectedProduct!.id,
          density: double.parse(_densityController.text.trim()),
          updateBy: 1,
        );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = context.watch<RoBloc>().roConfig;
    final tanks = _tankNumbers(config);

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
          child: Container(
              height: 1, color: Colors.black.withValues(alpha: 0.08)),
        ),
        title: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Density Change',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ),
      ),
      body: BlocConsumer<DensityCubit, DensityState>(
        listener: (context, state) {
          if (state is DensitySubmitted || state is DensityError) {
            FocusScope.of(context).unfocus();
          }
        },
        builder: (context, state) {
          final isSubmitting = state is DensitySubmitting;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Result banner ────────────────────────────────
                  if (state is DensitySubmitted)
                    _ResultBanner(
                      message: state.response.displayMessage,
                      isSuccess: state.isSuccess,
                      isPending: state.isPending,
                      isFailure: state.isFailure,
                    ),

                  if (state is DensityError)
                    _ResultBanner(message: state.message, isError: true),

                  const SizedBox(height: 12),

                  // ── Tank Details ─────────────────────────────────
                  _SectionCard(
                    title: 'Tank Details',
                    children: [
                      if (config == null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.amber.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline_rounded,
                                  size: 18, color: Colors.amber.shade800),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Waiting for server configuration…',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.amber.shade800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 12),

                      // Tank dropdown
                      const Text(
                        'Tank Number',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF444444),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _DropdownField<int>(
                        value: _selectedTankNo,
                        hint: tanks.isEmpty ? 'No tanks available' : 'Select Tank',
                        enabled: tanks.isNotEmpty,
                        items: tanks
                            .map((t) => DropdownMenuItem<int>(
                                  value: t,
                                  child: Text('Tank $t'),
                                ))
                            .toList(),
                        onChanged: (v) {
                          setState(() => _selectedTankNo = v);
                          _onFieldChanged();
                        },
                      ),

                      const SizedBox(height: 12),

                      // Product dropdown (editable)
                      const Text(
                        'Product',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF444444),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _DropdownField<ProductOption>(
                        value: _selectedProduct,
                        hint: 'Select product',
                        enabled: true,
                        items: kProductOptions
                            .map((p) => DropdownMenuItem<ProductOption>(
                                  value: p,
                                  child: Text(p.name),
                                ))
                            .toList(),
                        onChanged: (v) {
                          setState(() => _selectedProduct = v);
                          _onFieldChanged();
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // ── Density Value ────────────────────────────────
                  _SectionCard(
                    title: 'Density Value',
                    children: [
                      _FieldInput(
                        label: 'Density (kg/m³)',
                        controller: _densityController,
                        hint: '720',
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d{0,2}')),
                        ],
                        onChanged: (_) => _onFieldChanged(),
                        validator: (v) {
                          if (v!.isEmpty) return 'Density is required';
                          final d = double.tryParse(v);
                          if (d == null || d <= 0) {
                            return 'Enter a valid density';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ── Submit ───────────────────────────────────────
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
                              'Submit Density Change',
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

// ── Reusable widgets (same style as preset screen) ────────────────────────

class _DropdownField<T> extends StatelessWidget {
  final T? value;
  final String hint;
  final List<DropdownMenuItem<T>> items;
  final bool enabled;
  final ValueChanged<T?> onChanged;

  const _DropdownField({
    required this.value,
    required this.hint,
    required this.items,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: enabled ? const Color(0xFFF8F8F8) : const Color(0xFFEEEEEE),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: Text(
            hint,
            style: TextStyle(
              fontSize: 14,
              color: enabled ? Colors.grey.shade500 : Colors.grey.shade400,
            ),
          ),
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xFF666666),
          ),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1A1A1A),
          ),
          onChanged: enabled ? onChanged : null,
          items: items,
        ),
      ),
    );
  }
}

class _ResultBanner extends StatelessWidget {
  final String message;
  final bool isSuccess;
  final bool isPending;
  final bool isFailure;
  final bool isError;

  const _ResultBanner({
    required this.message,
    this.isSuccess = false,
    this.isPending = false,
    this.isFailure = false,
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

class _FieldInput extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const _FieldInput({
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
            hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade400),
            filled: true,
            fillColor: const Color(0xFFF8F8F8),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
              borderSide:
                  const BorderSide(color: Color(0xFFF37022), width: 1.5),
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