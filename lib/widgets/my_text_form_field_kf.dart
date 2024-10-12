import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:todo_flutter_pwa/widgets/my_decimal_formatter.dart';

class MyTextFormFieldKF extends StatelessWidget {
  final bool isEnable;

  /// Texto que se visualiza antes de que se teclee algun caracter en el control
  final String label;

  /// Tamaño del texto
  final double fontSizeLabel;

  /// Tamaño de la fuente
  final double fontSize;

  /// Ancho, en pixeles, del control
  final double width;

  /// Maximo de caracteres que se pueden capturar en el control.
  /// Cuando se especifica una cantidad en la parte inferior derecha se muestra
  /// un contador de los caracteres tecleados y la cantidad restante de
  /// caracteres que faltan para llegar al limite.
  final int? maxLength;

  /// Icono que se visualiza a un costado derecho del control a modo de identificacion
  /// y sentido donde se emplea dicho control
  final Widget? suffixIcon;

  /// Icono que se visualiza a un costado derecho del control a modo de identificacion
  /// y sentido donde se emplea dicho control
  //final Widget? suffixIcon;

  final int? maxLines;
  final double topControl;
  final double paddingTop;

  /// Color de fondo del control
  final Color? backColor;

  /// Propiedad para controlar el contenido del control.
  final TextEditingController textEditingController;

  /// Especifica el tipo de teclado que si visualizar al momento de que el control
  /// obtenga el foco. El efecto de esta propiedad solo se visualiza cuando la
  /// app se ejecuta en un dispositivo movil
  final TextInputType keyboardType;

  final bool readOnly;

  final Color textColor;

  final FocusNode? focusNode;

  final bool onlyDigits;
  final bool isSignMoney;

  /// Determina los caracteres permitidos para su captura. Si su valor es true
  /// (por default es false) el control solo permite la captura de numeros,
  /// punto decimal y signo menos.
  final bool onlyNumber;

  final bool onlyPhoneNumber;

  final bool onlyText;

  final bool onlyCreditCard;

  final bool dateCreditCard;

  /// Muestra u oculta el texto que se esta escribiendo
  final bool obscureText;

  final bool? counterText;

  final TextCapitalization textCapitalization;
  final double rowHeight;

  final int decimalDigits;

  /// Evento para validar el dato introducido (segun lo que se defina)
  final String? Function(String? text) validator;

  /// Funcion de parametro que ejecuta cada vez que cambia el valor del texto
  final void Function(String text) onChanged;

  final void Function(String text)? onFieldSubmitted;

  final void Function()? onTap;
  final void Function()? onEditingComplete;
  //
  const MyTextFormFieldKF({
    super.key,
    this.isEnable = false,
    this.label = '',
    this.fontSizeLabel = 20,
    this.fontSize = 18,
    this.width = 200,
    this.maxLength,
    this.suffixIcon,
    this.maxLines,
    this.topControl = 13,
    this.paddingTop = 5,
    this.backColor = Colors.white,
    this.textColor = const Color(0xFF9E9E9E),
    //this.suffixIcon,
    required this.textEditingController,
    this.keyboardType = TextInputType.name,
    this.onlyDigits = false,
    this.isSignMoney = false,
    this.onlyNumber = false,
    this.onlyPhoneNumber = false,
    this.onlyCreditCard = false,
    this.dateCreditCard = false,
    this.onlyText = false,
    this.readOnly = false,
    this.focusNode,
    this.obscureText = false,
    this.counterText = true,
    this.textCapitalization = TextCapitalization.none,
    this.rowHeight = 90,
    this.decimalDigits = 2,
    required this.validator,
    required this.onChanged,
    this.onFieldSubmitted,
    this.onTap,
    this.onEditingComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: rowHeight,
      padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
      decoration: BoxDecoration(
        color: backColor,
      ),
      child: Container(
        padding: EdgeInsets.only(top: topControl),
        child: TextFormField(
          controller: textEditingController,
          textCapitalization: textCapitalization,
          readOnly: readOnly,
          focusNode: focusNode,
          maxLength: maxLength,
          maxLines: maxLines,
          expands: false,
          cursorColor: const Color(0xFF108C89),
          decoration: InputDecoration(
            //alignLabelWithHint: true,
            prefix: const SizedBox(),
            prefixStyle: const TextStyle(fontSize: 5),
            border: const OutlineInputBorder(),
            suffixIcon: suffixIcon,

            //suffixIcon: suffixIcon,

            /// border: const OutlineInputBorder(
            ///   borderSide: BorderSide(color: Colors.red, width: 5.0),
            /// ),

            enabledBorder: isEnable
                ? const OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF108C89), width: 2),
                  )
                : null,
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0xFF108C89), width: 2),
              borderRadius: BorderRadius.circular(10.0),
            ),
            hintText: '',
            isCollapsed: false,
            contentPadding: EdgeInsets.fromLTRB(10, paddingTop, 0, 0),
            labelText: label == '' ? null : label,
            counterText: counterText as bool ? null : '',
            filled: false,
            labelStyle: TextStyle(
              fontSize: fontSizeLabel,
              color: readOnly ? textColor : textColor,
            ),
          ),
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: TextStyle(
            fontSize: fontSize,
            color: readOnly ? textColor : Colors.black,
          ),
          inputFormatters: _getInputFormatters(),
          validator: validator,
          onChanged: onChanged,
          onFieldSubmitted: onFieldSubmitted,
          onTap: onTap,
          onEditingComplete: onEditingComplete,
        ),
      ),
    );
  }

  /// Método para obtener los formateadores de entrada adecuados
  List<TextInputFormatter>? _getInputFormatters() {
    if (onlyDigits) {
      return <TextInputFormatter>[
        MyDecimalFormatter(decimalDigits: 0),
      ];
    } else if (onlyPhoneNumber) {
      return <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
      ];
    } else if (onlyNumber) {
      return <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp(r"[0-9.-]")),
        MyDecimalFormatter(decimalDigits: decimalDigits, isSignMoney: isSignMoney),
      ];
    } else if (onlyCreditCard) {
      return <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
        _CreditCardFormatter(),
      ];
    } else if (dateCreditCard) {
      return <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
        _DateFormatter(), // Formateador personalizado para fechas
      ];
    } else {
      if (onlyText) {
        return <TextInputFormatter>[
          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
        ];
      } else {
        return <TextInputFormatter>[
          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\s,.-/]')),
        ];
      }
      // Solo acepta letras (texto)
    }
  }
}

class _CreditCardFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String newText = newValue.text.replaceAll(RegExp(r'\s+'), '');

    if (newText.length > 16) {
      return oldValue;
    }

    List<String> groups = [];
    for (int i = 0; i < newText.length; i += 4) {
      groups.add(newText.substring(i, i + 4 > newText.length ? newText.length : i + 4));
    }

    String formatted = groups.join(' ');
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _DateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String newText = newValue.text.replaceAll(RegExp(r'\s+'), '');

    if (newText.length > 5) {
      return oldValue;
    }

    List<String> groups = [];
    for (int i = 0; i < newText.length; i += 2) {
      groups.add(newText.substring(i, i + 2 > newText.length ? newText.length : i + 2));
    }

    String formatted = groups.join('/');
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
