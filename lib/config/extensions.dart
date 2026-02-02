// ignore_for_file: text_direction_code_point_in_literal

part of 'custom_classes.dart';

extension ExtensionList<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T) test, {T? Function()? orElse}) {
    try {
      return firstWhere(test);
    } catch (e) {
      return orElse?.call();
    }
  }

  T? lastWhereOrNull(bool Function(T) test) {
    try {
      return lastWhere(test);
    } catch (e) {
      return null;
    }
  }

  String? biggestString() {
    if (T != String) {
      return null;
    }

    String? biggest;
    forEach((element) {
      if (element.isNotNull && ((element as String).length) > (biggest?.length ?? 0)) {
        biggest = element;
      }
    });

    return biggest;
  }

  bool compareTo(List<T?> other) {
    if (length != other.length) {
      return false;
    }
    for (int i = 0; i < length; i++) {
      if (elementAt(i) != other.elementAt(i)) {
        return false;
      }
    }
    return true;
  }

  List<T>? whereOrNull(bool Function(T) test) {
    try {
      return where(test).toList();
    } catch (e) {
      return null;
    }
  }

  List<T> whereOrEmpty(bool Function(T) test) {
    try {
      return where(test).toList();
    } catch (e) {
      return <T>[];
    }
  }

  int? indexWhereOrNull(bool Function(T) test) {
    try {
      int? index;
      for (int i = 0; i < length; i++) {
        if (test(elementAt(i))) {
          index = i;
          break;
        }
      }
      return index;
    } catch (e) {
      return null;
    }
  }

  // getRandomElement
  T? getRandomElement() {
    if (isEmpty) return null;
    final randomIndex = math.Random().nextInt(length);
    return elementAt(randomIndex);
  }

  // takeUpTo(int i)
  List<T> takeUpTo(int i) {
    if (i >= length) {
      return toList();
    }
    return take(i).toList();
  }
}

extension ExtensionDateTime on DateTime {
  DateTime get yesterday {
    return subtract(const Duration(days: 1));
  }

  DateTime get previousMonth {
    int year = this.year;
    int month = this.month;
    int day = this.day;
    if (month == 1) {
      year--;
      month = 12;
    } else {
      month--;
    }
    return DateTime(year, month, day);
  }

  DateTime get tomorrow {
    return add(const Duration(days: 1));
  }

  DateTime get firstDayOfTheWeek {
    // Calculate how many days to subtract to get to the previous Monday (first day of the week)
    // Dart's DateTime days are 1-based and Monday is 1, so we calculate the difference accordingly.
    int daysToSubtract = weekday - DateTime.monday;
    DateTime firstDayOfTheWeek = subtract(Duration(days: daysToSubtract));

    return firstDayOfTheWeek;
  }

  DateTime get lastDayOfTheWeek {
    // Calculate how many days to add to get to the next Sunday (last day of the week)
    // Dart's DateTime days are 1-based and Sunday is 7, so we calculate the difference accordingly.
    int daysToAdd = DateTime.sunday - weekday;
    DateTime lastDayOfTheWeek = add(Duration(days: daysToAdd));

    return lastDayOfTheWeek;
  }

  DateTime get firstDayOfTheMonth {
    return DateTime(year, month, 1);
  }

  DateTime get lastDayOfTheMonth {
    final DateTime nextMonth = month < 12 ? DateTime(year, month + 1, 1) : DateTime(year + 1, 1, 1);
    return nextMonth.subtract(const Duration(days: 1));
  }

  DateTime get date {
    return DateTime(year, month, day);
  }

  bool overlaps(DateTime other) {
    return (isBefore(other) && other.isAfter(this)) || (isAfter(other) && other.isBefore(this));
  }

  DateTime get dateStart {
    return DateTime(year, month, day, 0, 0, 0);
  }

  DateTime get dateEnd {
    return DateTime(year, month, day, 23, 59, 59);
  }

  DateTime get roundTime {
    return DateTime(year, month, day, hour, 0).add(const Duration(hours: 1));
  }

  String formattedDate() {
    return ddMMMyyyy();
  }

  bool isSameMonth(DateTime other) {
    return year == other.year && month == other.month;
  }

  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  bool isSameHour(DateTime other) {
    return year == other.year && month == other.month && day == other.day && hour == other.hour;
  }

  String get fromDateString {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime yesterday = today.subtract(const Duration(days: 1));

    // Check if _fromDate is today
    if (compareTo(today) == 0) {
      return "Aujourd'hui";
    }

    // Check if _fromDate is yesterday
    if (compareTo(yesterday) == 0) {
      return "Hier";
    }

    // Check if _fromDate is within the last week
    DateTime lastWeek = today.subtract(const Duration(days: 7));
    if (compareTo(lastWeek) >= 0) {
      return "Semaine dernière";
    }

    // Check if _fromDate is within the last month
    DateTime lastMonth = today.subtract(const Duration(days: 30));
    if (compareTo(lastMonth) >= 0) {
      return "Mois dernier";
    }

    // Check if _fromDate is within the last year
    DateTime lastYear = today.subtract(const Duration(days: 365));
    if (compareTo(lastYear) >= 0) {
      return "Année dernière";
    }

    // If none of the above, return this default
    return "Depuis le début";
  }

  List<DateTime> get upToHere {
    List<DateTime> dates = [];
    DateTime date = DateTime(1996, 4, 7);
    while (date.isBefore(this.date)) {
      dates.add(date);
      date = date.add(const Duration(days: 1));
    }
    return dates;
  }

  List<DateTime> get fromHere {
    List<DateTime> dates = [];
    DateTime max = DateTime(2030, 4, 7);
    DateTime date = this.date.add(const Duration(days: 1));
    while (date.isBefore(max)) {
      dates.add(date);
      date = date.add(const Duration(days: 1));
    }
    return dates;
  }

  bool gt(DateTime other) {
    return isAfter(other);
  }

  bool gte(DateTime other) {
    return isAfter(other) || isAtSameMomentAs(other);
  }

  bool eq(DateTime other) {
    return isAtSameMomentAs(other);
  }

  bool lt(DateTime other) {
    return isBefore(other);
  }

  bool lte(DateTime other) {
    return isBefore(other) || isAtSameMomentAs(other);
  }

  int get timestamp {
    return millisecondsSinceEpoch ~/ 1000;
  }

  DateTime toParisTime() {
    // return this;
    return tz.TZDateTime.from(this, tz.getLocation('Europe/Paris'));
  }

  String ddMMMyyyy() {
    // Use Intl to format dates based on the current locale.
    return intl.DateFormat('dd MMM yyyy').format(this).firstLetterUpperCase();
  }

  String toDbString() {
    // Format the date as "YYYY-MM-DDTHH:mm:ss"
    return "$year"
        "-${month.toString().padLeft(2, '0')}"
        "-${day.toString().padLeft(2, '0')}"
        "T${hour.toString().padLeft(2, '0')}"
        ":${minute.toString().padLeft(2, '0')}"
        ":${second.toString().padLeft(2, '0')}"
        ".000Z";
  }
}

extension ExtensionDuration on Duration {
  String get formatted {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(inHours);
    final minutes = twoDigits(inMinutes.remainder(60));
    final seconds = twoDigits(inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  String get formattedHMS {
    // 00:00:00
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(inHours);
    final minutes = twoDigits(inMinutes.remainder(60));
    final seconds = twoDigits(inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }
}

extension ExtensionTimeOfDay on TimeOfDay {
  String get formattedTime {
    return "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}";
  }

  bool isBefore(TimeOfDay other) {
    return hour < other.hour || (hour == other.hour && minute < other.minute);
  }

  bool isAfter(TimeOfDay other) {
    return hour > other.hour || (hour == other.hour && minute > other.minute);
  }

  bool isAtSameTime(TimeOfDay other) {
    return hour == other.hour && minute == other.minute;
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }

  String noAccent() {
    // Mappings of accented characters to their unaccented counterparts.
    // Lowercase mappings
    const accentsLower = 'àáâäãåăąæçćčđďèéêëěęìíîïıłĺľńňñòóôöõőøřŕśšşťùúûüůűýÿŷźžż';
    const plainLower = 'aaaaaaaaaceccddeeeeeeiiiiiilllnnnooooooorrsssstuuuuuuyyyyzzz';

    // Uppercase mappings
    const accentsUpper = 'ÀÁÂÄÃÅĂĄÆÇĆČĐĎÈÉÊËĚĘÌÍÎÏIŁĹĽŃŇÑÒÓÔÖÕŐØŘŔŚŠŞŤÙÚÛÜŮŰÝŸŶŹŽŻ';
    const plainUpper = 'AAAAAAAAACECCDDEEEEEEIIIIIILLLNNOOOOOOORRSSSTUUUUUUYYYZZZ';

    String result = this;

    // Replace lowercase accented characters
    for (int i = 0; i < accentsLower.length; i++) {
      result = result.replaceAll(accentsLower[i], plainLower[i]);
    }

    // Replace uppercase accented characters
    for (int i = 0; i < accentsUpper.length; i++) {
      result = result.replaceAll(accentsUpper[i], plainUpper[i]);
    }

    return result;
  }

  String noWhiteSpace() {
    return replaceAll("  ", " ").trim().replaceAll("  ", " ").replaceAll("‪", "").replaceAll("‬", "");
  }

  String noSpace() {
    return replaceAll(" ", "").replaceAll(" ", "").replaceAll("‪", "").replaceAll("‬", "").trim();
  }

  String get snakeCase {
    final regex = RegExp(r'(?<!^)(?=[A-Z])');
    return toLowerCase().split(regex).join('_').replaceAll(' ', '_').replaceAll('__', '_');
  }

  String firstLetterUpperCase() {
    if (isEmpty) return this;
    // remove leading and trailing spaces
    String trimmed = trim();
    if (trimmed.isEmpty) return this;
    // remove multiple spaces
    trimmed = trimmed.replaceAll(RegExp(r'\s+'), ' ');
    List<String> words = trimmed.split(' ');
    // The first letter of each word is capitalized
    List<String> capitalizedWords = words.map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).toList();
    return capitalizedWords.join(' ');
  }
}

enum FieldSort { asc, desc }

extension FieldSortExtension on FieldSort {
  String get value {
    switch (this) {
      case FieldSort.asc:
        return 'asc';
      case FieldSort.desc:
        return 'desc';
    }
  }
}

extension NumberExtension on num {
  String get formatted {
    // int number = toInt();
    // Format the number with commas as thousands separators
    return numberFormatter(this);
  }

  String get formattedWithCurrency {
    // Format the number with commas and add currency symbol
    return "${numberFormatter(this)} FCFA";
  }

// Format numbers to a string with commas as thousands separators
  numberFormatter(num number) {
    return number.toStringAsFixed(2).replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
        );
  }
}

// Extension for enums
extension EnumExtension on Enum {
  String get name {
    return toString().split('.').last;
  }

  String get displayName {
    return name.replaceAll('_', ' ').capitalize();
  }

  String get snakeCase {
    return name.snakeCase;
  }
}

// Extension for classes
extension ClassExtension on Object? {
  String get name {
    if (this is String) {
      return this as String;
    }
    if (this is AppCountry) {
      return (this as AppCountry).name;
    }
    if (this is File) {
      return (this as File).path.split('/').last;
    }
    if (this is XFile) {
      return (this as XFile).name;
    }
    if (this is Map) {
      return (this as Map)['name']?.toString() ??
          (this as Map)['fileName']?.toString() ??
          (this as Map)['file_name']?.toString() ??
          "";
    }
    return runtimeType.toString().split('.').last;
  }

  Future<Uint8List?> get bytes async {
    if (this is File) {
      return (this as File).readAsBytesSync();
    }
    if (this is XFile) {
      return await (this as XFile).readAsBytes();
    }
    return null;
  }

  String? get path {
    if (this is File) {
      return (this as File).path;
    }
    if (this is XFile) {
      return (this as XFile).path;
    }
    return null;
  }

  // base64Content
  Future<String?> get base64Content async {
    final fileBytes = await bytes;
    if (fileBytes != null) {
      return base64Encode(fileBytes);
    }
    return null;
  }

  String get tileTitle {
    return (this as dynamic).name;
  }

  String get tileSubtitle {
    if (this is String) {
      return this as String;
    }
    if (this is AppCountry) {
      return (this as AppCountry).isoCode;
    }
    return "";
  }

  bool get isNotNull {
    return this != null;
  }

  bool get isEmptyOrNull {
    if (this is Iterable?) {
      return (this as Iterable?)?.isEmpty ?? true;
    }
    if (this is List?) {
      return (this as List?)?.isEmpty ?? true;
    }
    if (this is String?) {
      return (this as String?)?.isEmpty ?? true;
    }
    if (this is Map?) {
      return (this as Map?)?.isEmpty ?? true;
    }
    if (this is Set?) {
      return (this as Set?)?.isEmpty ?? true;
    }
    return this == null;
  }

  bool get isNotEmptyOrNull {
    if (this is Iterable?) {
      return (this as Iterable?)?.isNotEmpty ?? false;
    }
    if (this is List?) {
      return (this as List?)?.isNotEmpty ?? false;
    }
    if (this is String?) {
      return (this as String?)?.isNotEmpty ?? false;
    }
    if (this is Map?) {
      return (this as Map?)?.isNotEmpty ?? false;
    }
    if (this is Set?) {
      return (this as Set?)?.isNotEmpty ?? false;
    }
    return this != null;
  }

  bool get isNull {
    return this == null;
  }
}
