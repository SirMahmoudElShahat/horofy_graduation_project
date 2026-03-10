import '../../domain/entities/progress_entity.dart';

class ProgressModel extends ProgressEntity {
  const ProgressModel({
    super.id,
    required super.childId,
    required super.level,
    required super.letterId,
    super.listened,
    super.spoken,
    super.written,
  });

  factory ProgressModel.fromMap(Map<String, dynamic> map) {
    return ProgressModel(
      id: map['id'] as int?,
      childId: map['childId'] as int,
      level: map['level'] as String,
      letterId: map['letterId'] as int,
      listened: (map['listened'] as int) == 1,
      spoken: (map['spoken'] as int) == 1,
      written: (map['written'] as int) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'childId': childId,
      'level': level,
      'letterId': letterId,
      'listened': listened ? 1 : 0,
      'spoken': spoken ? 1 : 0,
      'written': written ? 1 : 0,
    };
  }

  ProgressEntity toEntity() {
    return ProgressEntity(
      id: id,
      childId: childId,
      level: level,
      letterId: letterId,
      listened: listened,
      spoken: spoken,
      written: written,
    );
  }
}
