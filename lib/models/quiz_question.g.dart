// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz_question.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$QuizQuestionImpl _$$QuizQuestionImplFromJson(Map<String, dynamic> json) =>
    _$QuizQuestionImpl(
      id: (json['id'] as num).toInt(),
      question: json['question'] as String,
      answers:
          (json['answers'] as List<dynamic>).map((e) => e as String).toList(),
      correctAnswer: (json['correctAnswer'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      imagePath: json['imagePath'] as String?,
      type: $enumDecodeNullable(_$QuizTypesEnumMap, json['type']),
    );

Map<String, dynamic> _$$QuizQuestionImplToJson(_$QuizQuestionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'question': instance.question,
      'answers': instance.answers,
      'correctAnswer': instance.correctAnswer,
      'imagePath': instance.imagePath,
      'type': _$QuizTypesEnumMap[instance.type],
    };

const _$QuizTypesEnumMap = {
  QuizTypes.multipleChoice: 'multipleChoice',
  QuizTypes.trueFalse: 'trueFalse',
  QuizTypes.dropdown: 'dropdown',
  QuizTypes.reorder: 'reorder',
};
