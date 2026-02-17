import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Dark input field. Inherits all styling from the central theme.
class CBTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? errorText;
  final InputDecoration? decoration;
  final bool autofocus;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final bool enabled;
  final bool readOnly;
  final TextCapitalization textCapitalization;
  final bool monospace;
  final bool hapticOnChange;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final TextStyle? textStyle;
  final TextAlign textAlign;

  const CBTextField({
    super.key,
    this.controller,
    this.hintText,
    this.errorText,
    this.decoration,
    this.autofocus = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.keyboardType,
    this.textInputAction,
    this.focusNode,
    this.enabled = true,
    this.readOnly = false,
    this.textCapitalization = TextCapitalization.none,
    this.monospace = false,
    this.hapticOnChange = false,
    this.onChanged,
    this.onSubmitted,
    this.inputFormatters,
    this.textStyle,
    this.textAlign = TextAlign.start,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseDecoration = decoration ?? const InputDecoration();
    final effectiveDecoration = baseDecoration.copyWith(
      hintText: hintText ?? baseDecoration.hintText,
      errorText: errorText ?? baseDecoration.errorText,
    );
    return TextField(
      controller: controller,
      autofocus: autofocus,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      focusNode: focusNode,
      enabled: enabled,
      readOnly: readOnly,
      onChanged: (val) {
        if (hapticOnChange && val.isNotEmpty) {
          HapticFeedback.selectionClick();
        }
        onChanged?.call(val);
      },
      onSubmitted: onSubmitted,
      textCapitalization: textCapitalization,
      textAlign: textAlign,
      style: textStyle ??
          (monospace
              ? theme.textTheme.bodyLarge!
                  .copyWith(fontFamily: 'monospace')
              : theme.textTheme.bodyLarge!),
      inputFormatters: [
        ...?inputFormatters,
        // Safety net: if no explicit limit is set via maxLength,
        // apply a generous default limit to prevent memory exhaustion attacks.
        if (maxLength == null) LengthLimitingTextInputFormatter(8192),
      ],
      cursorColor: theme.colorScheme.primary,
      decoration: effectiveDecoration,
    );
  }
}

