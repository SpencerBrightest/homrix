/// String extensions used across the project
extension StringExtensions on String {
  /// Capitalize first letter
  String get capitalize => '${this[0].toUpperCase()}${substring(1).toLowerCase()}';

  /// Convert snake_case to PascalCase
  String get toPascal => split('_').map((str) => str.capitalize).join();

  /// Convert snake_case to camelCase
  String get toCamel => split('_').map((str) => str.capitalize).first +
      split('_').skip(1).map((str) => str.toLowerCase()).join();

  /// Truncate string with ellipsis if longer than max length
  String trunculate({int maxLength = 100}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - 3)}...';
  }

  /// Format as currency (simple version)
  String formatCurrency({String symbol = '\$'}) {
    final number = replaceAll(',', '');
    final double parsed = double.tryParse(number) ?? 0.0;
    return '$symbol${parsed.toStringAsFixed(2)}';
  }
}

/// DateTime extensions
extension DateTimeExtensions on DateTime {
  /// Format as "MMM d, yyyy"
  String formatShortDate() =>
      '${_monthAbbreviation[month]} ${day}, $year';

  /// Format as "h:mm a"
  String formatTime() => '${hour % 12 == 0 ? 12 : hour % 12}:${minute.toString().padLeft(2, '0')} ${hour < 12 ? 'AM' : 'PM}';

  /// Check if same day
  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;

  /// Get days difference from another date
  int daysDiff(DateTime other) {
    final difference = differenceInDays(other);
    return difference;
  }

  int differenceInDays(DateTime other) {
    final utc1 = this.toUtc();
    final utc2 = other.toUtc();
    return utc2.difference(utc1).inDays;
  }

  /// Get abbreviated month name
  static final Map<int, String> _monthAbbreviation = {
    1: 'Jan',
    2: 'Feb',
    3: 'Mar',
    4: 'Apr',
    5: 'May',
    6: 'Jun',
    7: 'Jul',
    8: 'Aug',
    9: 'Sep',
    10: 'Oct',
    11: 'Nov',
    12: 'Dec',
  };
}

/// Double extension for calculations
extension DoubleExtensions on double {
  /// Round to specified decimal places
  double roundTo(int places) => pow(10, places) * this).round().toDouble() / pow(10, places);

  /// Format as currency
  String formatCurrency({String symbol = '\$'}) => '$symbol${this.toStringAsFixed(2)}';

  /// Clamp value between min and max
  double clamp(double min, double max) => max(min, min(max, this));
}

/// List extensions
extension ListExtensions<T> on List<T> {
  /// Get single item by index or default value
  T getSingle({required int index, required T defaultValue}) {
    if (index >= 0 && index < length) {
      return this[index];
    }
    return defaultValue;
  }

  /// Chunk list into n-sized groups
  List<List<T>> chunk(int size) {
    final List<List<T>> chunks = [];
    for (var i = 0; i < length; i += size) {
      chunks.add(sublist(i, i + size > length ? length : i + size));
    }
    return chunks;
  }
}