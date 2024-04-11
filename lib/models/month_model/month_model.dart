import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';
import '../../data/community_data.dart';

part 'month_model.freezed.dart';
// optional: Since our class is serializable, we must add this line.
// But if Person was not serializable, we could skip it.
// part 'month_model.g.dart';

@freezed
class Month with _$Month {
  const factory Month({
    required int month,
    required int year,

    /// The list is actually unnecessary. (i forgor and it's too late to change it)
    required List<Map<int, List<MabPost>>> daysList,
  }) = _Month;

  // factory Month.fromJson(Map<String, Object?> json) => _$MonthFromJson(json);
}
