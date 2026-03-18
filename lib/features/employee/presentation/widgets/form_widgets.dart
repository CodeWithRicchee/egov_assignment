import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/employee_entities.dart';

// ── Label ─────────────────────────────────────────────────────────────────────
class FieldLabel extends StatelessWidget {
  final String label;
  final bool isRequired;
  const FieldLabel({super.key, required this.label, this.isRequired = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          text: label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
          children: isRequired
              ? const [TextSpan(text: ' *', style: TextStyle(color: AppTheme.error))]
              : [],
        ),
      ),
    );
  }
}

// ── Text Input ────────────────────────────────────────────────────────────────
class AppTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isRequired;
  final bool obscureText;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final int? maxLength;
  final int maxLines;
  final String? hint;
  final bool readOnly;
  final String? errorText;

  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    this.isRequired = false,
    this.obscureText = false,
    this.suffixIcon,
    this.prefixIcon,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.maxLength,
    this.maxLines = 1,
    this.hint,
    this.readOnly = false,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(label: label, isRequired: isRequired),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          onChanged: onChanged,
          maxLength: maxLength,
          maxLines: maxLines,
          readOnly: readOnly,
          decoration: InputDecoration(
            hintText: hint ?? 'Enter $label',
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            counterText: '',
            errorText: errorText,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTheme.error),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 14,
              vertical: maxLines > 1 ? 14 : 0,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Password Input ────────────────────────────────────────────────────────────
class AppPasswordField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final bool isRequired;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final String? hint;
  final String? errorText;

  const AppPasswordField({
    super.key,
    required this.label,
    required this.controller,
    this.isRequired = false,
    this.validator,
    this.onChanged,
    this.hint,
    this.errorText,
  });

  @override
  State<AppPasswordField> createState() => _AppPasswordFieldState();
}

class _AppPasswordFieldState extends State<AppPasswordField> {
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: widget.label,
      controller: widget.controller,
      isRequired: widget.isRequired,
      obscureText: !_visible,
      hint: widget.hint,
      errorText: widget.errorText,
      validator: widget.validator,
      onChanged: widget.onChanged,
      suffixIcon: IconButton(
        icon: Icon(
          _visible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: Colors.grey.shade500,
          size: 20,
        ),
        onPressed: () => setState(() => _visible = !_visible),
      ),
    );
  }
}

// ── Dropdown ──────────────────────────────────────────────────────────────────
class AppDropdown extends StatelessWidget {
  final String label;
  final bool isRequired;
  final String? value;
  final List<DropdownOption> options;
  final bool isLoading;
  final void Function(String?) onChanged;
  final String? errorText;
  final String? hint;

  const AppDropdown({
    super.key,
    required this.label,
    required this.options,
    required this.onChanged,
    this.isRequired = false,
    this.value,
    this.isLoading = false,
    this.errorText,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(label: label, isRequired: isRequired),
        DropdownButtonFormField<String>(
          value: value,
          isExpanded: true,
          hint: isLoading
              ? const Row(children: [
                  SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
                  SizedBox(width: 8),
                  Text('Loading…', style: TextStyle(fontSize: 14)),
                ])
              : Text(hint ?? 'Select $label',
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
          decoration: InputDecoration(
            errorText: errorText,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTheme.error),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
          ),
          items: options
              .map((o) => DropdownMenuItem(
                    value: o.code,
                    child: Text(o.name, style: const TextStyle(fontSize: 14)),
                  ))
              .toList(),
          onChanged: isLoading ? null : onChanged,
        ),
      ],
    );
  }
}

// ── Multi-Select Dropdown ─────────────────────────────────────────────────────
class AppMultiSelectDropdown extends StatefulWidget {
  final String label;
  final bool isRequired;
  final List<DropdownOption> options;
  final List<DropdownOption> selectedOptions;
  final bool isLoading;
  final void Function(List<DropdownOption>) onChanged;
  final String? errorText;

  const AppMultiSelectDropdown({
    super.key,
    required this.label,
    required this.options,
    required this.selectedOptions,
    required this.onChanged,
    this.isRequired = false,
    this.isLoading = false,
    this.errorText,
  });

  @override
  State<AppMultiSelectDropdown> createState() => _AppMultiSelectDropdownState();
}

class _AppMultiSelectDropdownState extends State<AppMultiSelectDropdown> {
  void _showDialog() {
    final temp = List<DropdownOption>.from(widget.selectedOptions);
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          title: Text('Select ${widget.label}'),
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: widget.options.length,
              itemBuilder: (_, i) {
                final opt = widget.options[i];
                final sel = temp.any((s) => s.code == opt.code);
                return CheckboxListTile(
                  dense: true,
                  value: sel,
                  title: Text(opt.name, style: const TextStyle(fontSize: 14)),
                  activeColor: AppTheme.primary,
                  onChanged: (v) {
                    setDlgState(() {
                      if (v == true) {
                        temp.add(opt);
                      } else {
                        temp.removeWhere((s) => s.code == opt.code);
                      }
                    });
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                widget.onChanged(temp);
                Navigator.pop(ctx);
              },
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final label = widget.selectedOptions.isEmpty
        ? 'Select ${widget.label}'
        : widget.selectedOptions.map((o) => o.name).join(', ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(label: widget.label, isRequired: widget.isRequired),
        GestureDetector(
          onTap: widget.isLoading ? null : _showDialog,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: widget.errorText != null ? AppTheme.error : Colors.grey.shade300,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: widget.isLoading
                      ? const Row(children: [
                          SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2)),
                          SizedBox(width: 8),
                          Text('Loading…', style: TextStyle(fontSize: 14)),
                        ])
                      : Text(
                          label,
                          style: TextStyle(
                            fontSize: 14,
                            color: widget.selectedOptions.isEmpty
                                ? Colors.grey.shade400
                                : AppTheme.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                ),
                const Icon(Icons.arrow_drop_down, color: Colors.grey),
              ],
            ),
          ),
        ),
        if (widget.selectedOptions.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Wrap(
              spacing: 6,
              runSpacing: 4,
              children: widget.selectedOptions
                  .map((o) => Chip(
                        label: Text(o.name, style: const TextStyle(fontSize: 12)),
                        deleteIcon: const Icon(Icons.close, size: 14),
                        onDeleted: () {
                          final updated = widget.selectedOptions.where((s) => s.code != o.code).toList();
                          widget.onChanged(updated);
                        },
                        backgroundColor: AppTheme.primary.withOpacity(0.1),
                        side: BorderSide(color: AppTheme.primary.withOpacity(0.3)),
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ))
                  .toList(),
            ),
          ),
        if (widget.errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 14),
            child: Text(
              widget.errorText!,
              style: const TextStyle(color: AppTheme.error, fontSize: 12),
            ),
          ),
      ],
    );
  }
}

// ── Date Picker ───────────────────────────────────────────────────────────────
class AppDatePickerField extends StatelessWidget {
  final String label;
  final bool isRequired;
  final DateTime? value;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final void Function(DateTime) onDateSelected;
  final String? errorText;
  final String? hint;

  const AppDatePickerField({
    super.key,
    required this.label,
    required this.onDateSelected,
    this.isRequired = false,
    this.value,
    this.firstDate,
    this.lastDate,
    this.errorText,
    this.hint,
  });

  Future<void> _pick(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: value ?? (lastDate ?? now),
      firstDate: firstDate ?? DateTime(1900),
      lastDate: lastDate ?? now,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppTheme.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) onDateSelected(picked);
  }

  @override
  Widget build(BuildContext context) {
    final display = value == null
        ? null
        : '${value!.day.toString().padLeft(2, '0')}/${value!.month.toString().padLeft(2, '0')}/${value!.year}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(label: label, isRequired: isRequired),
        GestureDetector(
          onTap: () => _pick(context),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: errorText != null ? AppTheme.error : Colors.grey.shade300,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 18, color: Colors.grey),
                const SizedBox(width: 10),
                Text(
                  display ?? (hint ?? 'Select date'),
                  style: TextStyle(
                    fontSize: 14,
                    color: value == null ? Colors.grey.shade400 : AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 14),
            child: Text(errorText!, style: const TextStyle(color: AppTheme.error, fontSize: 12)),
          ),
      ],
    );
  }
}

// ── Validation Status ─────────────────────────────────────────────────────────
class AsyncValidationIndicator extends StatelessWidget {
  final bool isChecking;
  final bool? isValid;
  final String? errorText;

  const AsyncValidationIndicator({
    super.key,
    required this.isChecking,
    this.isValid,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    if (isChecking) {
      return const Padding(
        padding: EdgeInsets.only(top: 6, left: 14),
        child: Row(
          children: [
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary),
            ),
            SizedBox(width: 6),
            Text('Checking availability…', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      );
    }
    if (errorText != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 6, left: 14),
        child: Row(
          children: [
            const Icon(Icons.error_outline, size: 14, color: AppTheme.error),
            const SizedBox(width: 4),
            Text(errorText!, style: const TextStyle(fontSize: 12, color: AppTheme.error)),
          ],
        ),
      );
    }
    if (isValid == true) {
      return const Padding(
        padding: EdgeInsets.only(top: 6, left: 14),
        child: Row(
          children: [
            Icon(Icons.check_circle_outline, size: 14, color: AppTheme.success),
            SizedBox(width: 4),
            Text('Available', style: TextStyle(fontSize: 12, color: AppTheme.success)),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
