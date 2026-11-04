import 'package:flutter/services.dart';
import 'package:device_calendar_plus/device_calendar_plus.dart';

/// How far into the future events are read when a profile has no
/// explicit horizon set. Matches the historical hard-coded value.
const int kDefaultHorizonDays = 30;

/// Horizons offered in the profile settings, in days.
const List<int> kHorizonChoices = [30, 90, 180, 365, 730];

class CalendarService {
  final DeviceCalendar _plugin = DeviceCalendar.instance;
  static const _channel = MethodChannel('calsync/calendar');

  Future<List<Calendar>> listCalendars() async {
    try {
      return await _plugin.listCalendars();
    } on DeviceCalendarException {
      return [];
    }
  }

  /// Reads events from [calendarId], starting now and reaching
  /// [horizonDays] days into the future.
  Future<List<Event>> listEvents(
    String calendarId, {
    int horizonDays = kDefaultHorizonDays,
  }) async {
    final now = DateTime.now();
    try {
      return await _plugin.listEvents(
        now,
        now.add(Duration(days: horizonDays)),
        calendarIds: [calendarId],
      );
    } on DeviceCalendarException {
      return [];
    }
  }

  Future<String?> createEvent(
    String calendarId,
    String title,
    DateTime start,
    DateTime end, {
    String? description,
    bool? isAllDay,
    RecurrenceRule? recurrenceRule,
    String? location,
  }) async {
    try {
      return await _plugin.createEvent(
        calendarId: calendarId,
        title: title,
        startDate: start,
        endDate: end,
        description: description,
        isAllDay: isAllDay ?? false,
        recurrenceRule: recurrenceRule,
        location: location,
      );
    } on DeviceCalendarException {
      return null;
    }
  }

  Future<Event?> getEvent(String eventId) async {
    try {
      return await _plugin.getEvent(eventId);
    } on DeviceCalendarException {
      return null;
    }
  }

  Future<CalendarDeleteResult> deleteEvent(String eventId) async {
    try {
      final ok = await _channel.invokeMethod<bool>(
        'deleteEvent',
        {'eventId': eventId},
      );
      return CalendarDeleteResult(success: ok == true);
    } catch (_) {
      return const CalendarDeleteResult(success: false);
    }
  }
}

class CalendarDeleteResult {
  final bool success;

  const CalendarDeleteResult({
    required this.success,
  });
}
