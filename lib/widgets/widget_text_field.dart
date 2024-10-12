import 'package:flutter/material.dart';
import 'package:todo_flutter_pwa/widgets/my_text_form_field_kf.dart';

class WidgetTextField extends StatelessWidget {
  ///
  /// Icono que se visualiza a un costado derecho del control a modo de identificacion
  /// y sentido donde se emplea dicho control
  final Widget? suffixIcon;
  final bool isEnable;
  final String label;
  final TextEditingController textEditingController;
  final FocusNode? focusNode;
  final bool required;
  final int? maxLength;
  final int? maxLines;
  final double topControl;
  final double paddingTop;
  final double rowHeight;
  final bool enable;
  final bool onlyDigits;
  final bool onlyNumber;
  final bool onlyPhoneNumber;
  final bool onlyText;
  final bool onlyCreditCard;
  final bool onlydateCreditCard;
  final double fontSizeLabel;
  final int decimalDigits;
  final bool isSignMoney;
  final Color backColor;
  final Color textColor;
  final bool counterText;
  final TextCapitalization textCapitalization;
  final String? Function(String? text) validator;
  final void Function(String text) onChanged;
  final void Function()? onTap;
  final void Function(String text)? onFieldSubmitted;
  final void Function()? onEditingComplete;
  final void Function(PointerDownEvent value)? onTapeOutSide;

  ///
  const WidgetTextField({
    super.key,
    this.isEnable = false,
    required this.label,
    required this.textEditingController,
    this.focusNode,
    this.suffixIcon,
    this.required = false,
    this.maxLength = 30,
    this.maxLines,
    this.topControl = 13,
    this.paddingTop = 5,
    this.rowHeight = 70,
    this.enable = true,
    this.onlyDigits = false,
    this.onlyNumber = false,
    this.onlyPhoneNumber = false,
    this.onlyText = false,
    this.onlyCreditCard = false,
    this.onlydateCreditCard = false,
    this.fontSizeLabel = 15,
    this.decimalDigits = 2,
    this.isSignMoney = false,
    this.backColor = Colors.white,
    this.textColor = const Color(0xFF9E9E9E),
    this.counterText = false,
    this.textCapitalization = TextCapitalization.none,
    required this.validator,
    required this.onChanged,
    this.onTap,
    this.onFieldSubmitted,
    this.onEditingComplete,
    this.onTapeOutSide,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: rowHeight,
      child: MyTextFormFieldKF(
        label: label,
        maxLength: maxLength,
        maxLines: maxLines,
        topControl: topControl,
        paddingTop: paddingTop,
        focusNode: focusNode,
        backColor: backColor,
        textColor: isEnable ? Colors.black : textColor,
        fontSize: 13,
        fontSizeLabel: 13,
        decimalDigits: decimalDigits,
        counterText: counterText,
        readOnly: !enable,
        onlyDigits: onlyDigits,
        onlyNumber: onlyNumber,
        onlyText: onlyText,
        onlyCreditCard: onlyCreditCard,
        dateCreditCard: onlydateCreditCard,
        onlyPhoneNumber: onlyPhoneNumber,
        isSignMoney: isSignMoney,
        textCapitalization: textCapitalization,
        rowHeight: rowHeight,
        textEditingController: textEditingController,
        isEnable: isEnable,
        validator: validator,
        onChanged: onChanged,
        onTap: onTap,
        onFieldSubmitted: onFieldSubmitted,
        onEditingComplete: onEditingComplete,
        suffixIcon: suffixIcon,
      ),
    );
  }
}
