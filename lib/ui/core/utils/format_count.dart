/// Formats [count] with a `.` thousands separator, e.g. `1842` -> `'1.842'`.
String formatCount(int count) {
  final digits = count.toString();
  final buffer = StringBuffer();

  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
    buffer.write(digits[i]);
  }

  return buffer.toString();
}
