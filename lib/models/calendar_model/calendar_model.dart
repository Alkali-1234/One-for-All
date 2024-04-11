import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

import '../month_model/month_model.dart';

part 'calendar_model.freezed.dart';
// optional: Since our class is serializable, we must add this line.
// But if Person was not serializable, we could skip it.
// part 'calendar_model.g.dart';

@freezed
class Calendar with _$Calendar {
  const factory Calendar({
    required List<Month> months,
  }) = _Calendar;

  // factory Calendar.fromJson(Map<String, Object?> json) => _$CalendarFromJson(json);
}
