import 'package:flutter/material.dart';

class MSAInput extends StatelessWidget {
  final String? placeHolder;
  final String? label;
  final Widget? suffix;
  final Widget? prefixWidget;
  final Widget? prefix;
  final bool obscureText;
  final int? maxLines;
  final int? minLines;
  final double radius;
  final double fontSize;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final Function(String?)? onSaved;
  final Function(String?)? onChanged;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final Function()? onTap;
  final TextInputAction? textInputAction;
  final bool autoFocus;
  final AutovalidateMode? autovalidateMode;

  const MSAInput(
      {this.placeHolder,
      this.radius = 23,
      this.keyboardType,
      this.autoFocus = false,
      this.prefixWidget,
      this.suffix,
      this.autovalidateMode,
      this.label,
      this.obscureText = false,
      this.maxLines,
      this.fontSize = 16,
      this.minLines,
      this.validator,
      this.onSaved,
      this.onChanged,
      this.controller,
      this.focusNode,
      this.onTap,
      this.textInputAction,
      Key? key,
      this.prefix})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
          primarySwatch: Colors.blue, inputDecorationTheme: theme(radius)),
      child: TextFormField(
        autovalidateMode: autovalidateMode,
        autofocus: autoFocus,
        textInputAction: textInputAction,
        focusNode: focusNode,
        controller: controller,
        onSaved: onSaved,
        validator: validator,
        onChanged: onChanged,
        onTap: onTap,
        keyboardType: keyboardType,
        obscureText: obscureText,
        minLines: minLines,
        maxLines: maxLines,
        cursorRadius: const Radius.circular(4),
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          label: label != null ? Text(label!) : null,
          suffixIcon: suffix,
          fillColor: Colors.transparent,
          prefixIcon: prefix,
          prefix: prefixWidget,
          prefixIconColor: Colors.blue,
          hintText: placeHolder,
        ),
      ),
    );
  }

  InputDecorationTheme theme(double radius) => InputDecorationTheme(
        prefixIconColor: Colors.blue,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: Colors.blue),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: Colors.white),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: Colors.white),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: Colors.red),
        ),
        fillColor: const Color(0xFFF8F8F8),
        filled: true,
        hintStyle: TextStyle(
          color: const Color(0xFFB0B2C9),
          fontWeight: FontWeight.w700,
          fontSize: 17,
          // fontFamilyFallback: [GoogleFonts.roboto().fontFamily!],
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      );
}
