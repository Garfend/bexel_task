import 'package:intl/intl.dart';

extension DateExtensions on DateTime {
  String get formattedDateTime =>
      DateFormat('dd MMM yyyy, HH:mm').format(toLocal());

  String formatDateTime({String pattern = 'dd MMM yyyy, HH:mm'}) =>
      DateFormat(pattern).format(toLocal());
}