typedef Validator = String? Function(String?);

class V {
  static Validator required([String msg = 'Поле обязательно']) =>
      (v) => (v == null || v.trim().isEmpty) ? msg : null;

  static Validator length({int min = 0, int max = 255}) => (v) {
        final t = v?.trim() ?? '';
        if (t.length < min) return 'Не короче $min символов';
        if (t.length > max) return 'Не длиннее $max символов';
        return null;
      };

  static Validator integer({int? min, int? max}) => (v) {
        final n = int.tryParse(v?.trim() ?? '');
        if (n == null) return 'Введите целое число';
        if (min != null && n < min) return 'Не меньше $min';
        if (max != null && n > max) return 'Не больше $max';
        return null;
      };

  static Validator positiveNumber() => (v) {
        final n = double.tryParse(v?.trim() ?? '');
        if (n == null) return 'Введите число';
        if (n < 0) return 'Не может быть отрицательным';
        return null;
      };

  static Validator email() {
    final re = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');
    return (v) => re.hasMatch(v?.trim() ?? '') ? null : 'Некорректный адрес';
  }

  static Validator password({int min = 8}) => (v) {
        final t = v ?? '';
        if (t.length < min) return 'Пароль не короче $min символов';
        if (!RegExp(r'\d').hasMatch(t)) return 'Добавьте хотя бы одну цифру';
        return null;
      };

  static Validator combine(List<Validator> list) => (v) {
        for (final f in list) {
          final e = f(v);
          if (e != null) return e;
        }
        return null;
      };
}