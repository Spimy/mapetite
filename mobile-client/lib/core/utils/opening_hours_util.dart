/// One day's operating hours, matching the shape returned by
/// GET /api/stores/`<id>`/operating-hours/ and the `operating_hours`
/// field nested in StoreProfileSerializer / NearbyStoreSerializer.
class OperatingHourModel {
  final int dayOfWeek; // 0 = Monday .. 6 = Sunday (backend convention)
  final bool isClosed;
  final String? openTime; // "HH:MM:SS" or null
  final String? closeTime; // "HH:MM:SS" or null

  const OperatingHourModel({
    required this.dayOfWeek,
    required this.isClosed,
    this.openTime,
    this.closeTime,
  });

  factory OperatingHourModel.fromJson(Map<String, dynamic> json) {
    return OperatingHourModel(
      dayOfWeek: json['day_of_week'] as int,
      isClosed: json['is_closed'] as bool? ?? false,
      openTime: json['open_time'] as String?,
      closeTime: json['close_time'] as String?,
    );
  }
}

class OpenStatus {
  final bool isOpen;
  final String closingTimeLabel;

  const OpenStatus({required this.isOpen, required this.closingTimeLabel});
}

int _minutesSinceMidnight(String hhmmss) {
  final parts = hhmmss.split(':');
  return int.parse(parts[0]) * 60 + int.parse(parts[1]);
}

String _formatLabel(String hhmmss) {
  final parts = hhmmss.split(':');
  var hour = int.parse(parts[0]);
  final minute = parts[1];
  final period = hour >= 12 ? 'PM' : 'AM';
  hour = hour % 12;
  if (hour == 0) hour = 12;
  return '$hour:$minute $period';
}

/// Computes whether a store is open right now from its weekly schedule.
/// The backend does not compute this server-side — every screen that
/// shows "Open"/"Closed" or a closing time must go through this function
/// instead of reimplementing the logic.
OpenStatus computeOpenStatus(
  List<OperatingHourModel> operatingHours,
  DateTime now,
) {
  final todayIndex = now.weekday - 1; // Dart: 1=Monday..7=Sunday -> 0..6
  OperatingHourModel? today;
  for (final hour in operatingHours) {
    if (hour.dayOfWeek == todayIndex) {
      today = hour;
      break;
    }
  }

  if (today == null ||
      today.isClosed ||
      today.openTime == null ||
      today.closeTime == null) {
    return const OpenStatus(isOpen: false, closingTimeLabel: 'Closed');
  }

  final nowMinutes = now.hour * 60 + now.minute;
  final openMinutes = _minutesSinceMidnight(today.openTime!);
  final closeMinutes = _minutesSinceMidnight(today.closeTime!);

  final isOvernight = closeMinutes <= openMinutes;
  final isOpenNow = isOvernight
      ? (nowMinutes >= openMinutes || nowMinutes < closeMinutes)
      : (nowMinutes >= openMinutes && nowMinutes < closeMinutes);

  return OpenStatus(
    isOpen: isOpenNow,
    closingTimeLabel: isOpenNow ? _formatLabel(today.closeTime!) : 'Closed',
  );
}
