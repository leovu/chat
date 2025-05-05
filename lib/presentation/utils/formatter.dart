import 'package:intl/intl.dart';

String formatDate(DateTime? date, {String fallback = ''}) {
  if (date == null) return fallback;
  return DateFormat('dd/MM/yyyy').format(date);
}

DateTime? parseDate(String? dateString) {
  if (dateString == null || dateString.isEmpty) return null;
  try {
    return DateFormat('dd/MM/yyyy').parseStrict(dateString);
  } catch (e) {
    return null;
  }
}

String formatDateByISO(String isoString) {
  final dateTime =
      DateTime.parse(isoString).toLocal(); // Chuyển về giờ local (GMT+7)
  return DateFormat('dd/MM/yyyy').format(dateTime);
}

String formatDateTime(String isoString) {
  final dateTime = DateTime.parse(isoString).toLocal(); // Chuyển về giờ local
  return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
}

int calculateHoursFromISO(String startIso, String endIso) {
  final startTime = DateTime.parse(startIso);
  final endTime = DateTime.parse(endIso);

  final duration = endTime.difference(startTime);
  return duration.inHours;
}

Map<String, String> extractDayAndMonth(String dateString) {
  try {
    final parts = dateString.split('/');
    if (parts.length != 3) throw FormatException("Sai định dạng ngày");

    final day = parts[0];
    final month = parts[1];

    return {
      'day': day,
      'month': 'tháng $month',
    };
  } catch (e) {
    return {
      'day': '',
      'month': '',
    };
  }
}

String calculateTimeDiff(String isoTimeString) {
  try {
    final dateTime =
        DateTime.parse(isoTimeString).toLocal(); // chuyển sang giờ VN
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds} giây trước';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays < 30) {
      return '${difference.inDays} ngày trước';
    } else {
      final months = (difference.inDays / 30).floor();
      return '$months tháng trước';
    }
  } catch (e) {
    return 'Thời gian không hợp lệ';
  }
}
