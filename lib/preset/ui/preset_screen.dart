// lib/preset/ui/preset_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants.dart';
import '../../home/bloc/ro_bloc.dart';
import '../../home/model/ro_config_model.dart';
import '../cubit/preset_cubit.dart';
import '../cubit/preset_state.dart';
import '../data/preset_api_client.dart';
import '../data/preset_repository.dart';
import '../model/preset_model.dart';

class PresetScreen extends StatelessWidget {
  const PresetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PresetCubit(
        repository: PresetRepository(
          apiClient: PresetApiClient(baseUrl: AppConstants.baseUrl),
        ),
      ),
      child: const _PresetView(),
    );
  }
}

class _PresetView extends StatefulWidget {
  const _PresetView();

  @override
  State<_PresetView> createState() => _PresetViewState();
}

class _PresetViewState extends State<_PresetView> {
  final _formKey = GlobalKey<FormState>();

  final _presetValueController = TextEditingController();

  PresetMode _selectedMode = PresetMode.volume;
  PresetMop _selectedMop = PresetMop.cash;
  PresetOperation _selectedOperation = PresetOperation.normalPreset;

  // Cascading selections driven by RoConfig.
// NOTE: _selectedPumpNo holds the pump's `pumpNo` (display number),
// NOT its `pumpId`. Per senior's instruction, the PRESET packet's
// `pumpautoid:INTEGER` field carries the pump number.
int? _selectedDuNo;
int? _selectedPumpNo;
int? _selectedNozzleNo;
  @override
  void dispose() {
    _presetValueController.dispose();
    super.dispose();
  }

  void _onFieldChanged() {
    final cubit = context.read<PresetCubit>();
    if (cubit.state is PresetSubmitted || cubit.state is PresetError) {
      cubit.reset();
    }
  }

  // ── Cascading helpers ────────────────────────────────────────────────────
  List<DuConfig> _duList(RoConfigModel? config) =>
      config?.duList ?? const <DuConfig>[];

  List<PumpConfig> _pumpsForDu(RoConfigModel? config, int? duNo) {
    if (config == null || duNo == null) return const <PumpConfig>[];
    for (final du in config.duList) {
      if (du.duNo == duNo) return du.pumpList;
    }
    return const <PumpConfig>[];
  }

  List<NozzleConfig> _nozzlesForPump(
  RoConfigModel? config,
  int? duNo,
  int? pumpNo,
) {
  final pumps = _pumpsForDu(config, duNo);
  for (final p in pumps) {
    if (p.pumpNo == pumpNo) return p.nozzleList;
  }
  return const <NozzleConfig>[];
}

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDuNo == null ||
    _selectedPumpNo == null ||
    _selectedNozzleNo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select DU, Pump and Nozzle before submitting.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final config = context.read<RoBloc>().roConfig;

    context.read<PresetCubit>().submitPreset(
          roAutoId: config?.roCode ?? 166616,
          duid: _selectedDuNo!,
          pumpAutoId: _selectedPumpNo!,
          nozzleAutoId: _selectedNozzleNo!,
          operationId: _selectedOperation,
          presetMode: _selectedMode,
          presetMop: _selectedMop,
          presetValue: _presetValueController.text.trim(),
          updateBy: 1,
        );
  }

  @override
  Widget build(BuildContext context) {
    final config = context.watch<RoBloc>().roConfig;
    final duList = _duList(config);
    final pumpList = _pumpsForDu(config, _selectedDuNo);
    final nozzleList = _nozzlesForPump(config, _selectedDuNo, _selectedPumpNo);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF1A1A1A),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Colors.black.withValues(alpha: 0.08),
          ),
        ),
        title: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Preset',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ),
      ),
      body: BlocConsumer<PresetCubit, PresetState>(
        listener: (context, state) {
          if (state is PresetSubmitted || state is PresetError) {
            FocusScope.of(context).unfocus();
          }
        },
        builder: (context, state) {
          final isSubmitting = state is PresetSubmitting;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Result banner ────────────────────────────────
                  if (state is PresetSubmitted)
                    _ResultBanner(
                      message: state.response.displayMessage,
                      isSuccess: state.isSuccess,
                      isPending: state.isPending,
                      isFailure: state.isFailure,
                    ),

                  if (state is PresetError)
                    _ResultBanner(message: state.message, isError: true),

                  const SizedBox(height: 12),

                  // ── Pump details ─────────────────────────────────
                  _SectionCard(
                    title: 'Pump Details',
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

                      // DU dropdown
                      const Text(
                        'DU Number',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF444444),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _DropdownField<int>(
                        value: _selectedDuNo,
                        hint: duList.isEmpty ? 'No DUs available' : 'Select DU',
                        enabled: duList.isNotEmpty,
                        items: duList
                            .map((du) => DropdownMenuItem<int>(
                                  value: du.duNo,
                                  child: Text('DU ${du.duNo}'),
                                ))
                            .toList(),
                        onChanged: (v) {
                           setState(() {
                            _selectedDuNo = v;
                            _selectedPumpNo = null;
                            _selectedNozzleNo = null;
                               });
                          _onFieldChanged();
                          },
                      ),

                      const SizedBox(height: 12),

                      // Pump dropdown
                      const Text(
                        'Pump Auto ID',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF444444),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _DropdownField<int>(
                            value: _selectedPumpNo,
                            hint: _selectedDuNo == null
                                ? 'Select DU first'
                                : (pumpList.isEmpty
                                    ? 'No pumps in this DU'
                                    : 'Select Pump'),
                            enabled: pumpList.isNotEmpty,
                            items: pumpList
                                .map((p) => DropdownMenuItem<int>(
                                      value: p.pumpNo,               // ← sends pumpNo, not pumpId
                                      child: Text('Pump ${p.pumpNo}'),
                                    ))
                                .toList(),
                            onChanged: (v) {
                              setState(() {
                                _selectedPumpNo = v;
                                _selectedNozzleNo = null;
                              });
                              _onFieldChanged();
                            },
                          ),

                      const SizedBox(height: 12),

                      // Nozzle dropdown
                      const Text(
                        'Nozzle Auto ID',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF444444),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _DropdownField<int>(
                        value: _selectedNozzleNo,
                        hint: _selectedPumpNo == null
                          ? 'Select Pump first'
                          : (nozzleList.isEmpty
                              ? 'No nozzles in this Pump'
                              : 'Select Nozzle'),
                        enabled: nozzleList.isNotEmpty,
                        items: nozzleList
                            .map((n) => DropdownMenuItem<int>(
                                  value: n.nozzleNo,
                                  child: Text(
                                    'Nozzle ${n.nozzleNo}  '
                                    '(Product ${n.productNo})',
                                  ),
                                ))
                            .toList(),
                        onChanged: (v) {
                          setState(() => _selectedNozzleNo = v);
                          _onFieldChanged();
                        },
                      ),

                      const SizedBox(height: 12),

                      // Operation dropdown
                      const Text(
                        'Operation',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF444444),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F8F8),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<PresetOperation>(
                            value: _selectedOperation,
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
                            onChanged: (op) {
                              if (op != null) {
                                setState(() => _selectedOperation = op);
                                _onFieldChanged();
                              }
                            },
                            items: PresetOperation.values
                                .map((op) => DropdownMenuItem(
                                      value: op,
                                      child: Text(op.label),
                                    ))
                                .toList(),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // ── Preset config ────────────────────────────────
                  _SectionCard(
                    title: 'Preset Configuration',
                    children: [
                      const Text(
                        'Preset Mode',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF444444),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: PresetMode.values.map((mode) {
                          final selected = _selectedMode == mode;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() => _selectedMode = mode);
                                _onFieldChanged();
                              },
                              child: Container(
                                margin: EdgeInsets.only(
                                  right: mode == PresetMode.volume ? 6 : 0,
                                  left: mode == PresetMode.amount ? 6 : 0,
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? const Color(0xFFF37022)
                                      : const Color(0xFFF8F8F8),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: selected
                                        ? const Color(0xFFF37022)
                                        : Colors.grey.shade200,
                                  ),
                                ),
                                child: Text(
                                  mode.label,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: selected
                                        ? Colors.white
                                        : const Color(0xFF666666),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 14),

                      const Text(
                        'Method of Payment',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF444444),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F8F8),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<PresetMop>(
                            value: _selectedMop,
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
                            onChanged: (mop) {
                              if (mop != null) {
                                setState(() => _selectedMop = mop);
                                _onFieldChanged();
                              }
                            },
                            items: PresetMop.values
                                .map((mop) => DropdownMenuItem(
                                      value: mop,
                                      child: Text(mop.label),
                                    ))
                                .toList(),
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      _FieldInput(
                        label: _selectedMode == PresetMode.volume
                            ? 'Preset Value (Litres)'
                            : 'Preset Value (₹)',
                        controller: _presetValueController,
                        hint: '100',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d{0,2}'),
                          ),
                        ],
                        onChanged: (_) => _onFieldChanged(),
                        validator: (v) {
                          if (v!.isEmpty) return 'Preset value is required';
                          final val = double.tryParse(v);
                          if (val == null || val <= 0) {
                            return 'Enter a valid value';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),

                  const SizedBox(height: 24),

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
                              'Submit Preset',
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

// ─────────────────────────────────────────────────────────────────────────────
// Reusable widgets
// ─────────────────────────────────────────────────────────────────────────────

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