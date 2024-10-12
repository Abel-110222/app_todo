abstract class FormsValidate {
  ///
  static String? select(dynamic itemValue, String leyend) {
    if (itemValue == null) {
      return leyend;
    }
    return null;
  }

  static String? inputString(String? strValue, String leyend) {
    if (strValue!.trim().isEmpty) {
      return leyend;
    }
    return null;
  }

  static String? email(String? value) {
    const pattern = r"(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'"
        r'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-'
        r'\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*'
        r'[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4]'
        r'[0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9]'
        r'[0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\'
        r'x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])';
    final regex = RegExp(pattern);

    return value!.isNotEmpty && !regex.hasMatch(value)
        ? "Correo electrónico inválido"
        : value == ''
            ? "Especificar Correo Electrónico"
            : null;
  }

  static String? password(String? value) {
    RegExp regex = RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!"@%#\/$&()=?¡¿*~]).{8,}$');
    var passNonNullValue = value ?? "";
    if (passNonNullValue.isEmpty) {
      return "Especificar una contraseña";
    } else if (passNonNullValue.length < 8) {
      return "Especificar una contraseña";
    } else if (!regex.hasMatch(passNonNullValue)) {
      return "La contraseña debe contener dígitos, mayúsculas, minúsculas y carácteres especiales";
    }
    return null;
  }

  // static String? rfc(String? strValue) {
  //   if (strValue!.trim().isEmpty) {
  //     return gl.lanC[gl.lanD]!['app_edit_validate_rfc1_text']!;
  //   }

  //   if (strValue.trim().length < 12) {
  //     return gl.lanC[gl.lanD]!['app_edit_validate_rfc2_text']!;
  //   }

  //   // Validación de signos especiales
  //   RegExp specialCharacters = RegExp(r'[^\w&]');
  //   if (specialCharacters.hasMatch(strValue)) {
  //     return gl.lanC[gl.lanD]!['app_edit_validate_rfc3_text'] ??
  //         'El RFC no puede tener caracteres especiales';
  //     // Reemplaza 'empresa_edit_validate_rfc3_text' con el mensaje deseado para esta validación.
  //   }
  //   return null;
  // }

  // static bool implementationERP(bool evaluateField, int createEditView) {
  //   if (createEditView == 3) {
  //     //! Si esta en modo de "View" no permitir modificar
  //     return false;
  //   }
  //   return evaluateField;
  // }
}
