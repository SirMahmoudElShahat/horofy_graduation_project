import '../../domain/entities/submission_entity.dart';

class SubmissionModel extends SubmissionEntity {
  const SubmissionModel({
    super.id,
    required super.childId,
    required super.level,
    required super.exerciseType,
    super.status,
    super.attemptsCount,
    super.duration,
    super.totalItems,
    super.mistakes,
    super.metadata,
    super.exerciseId,
    super.createdAt,
  });

  // ── To API request body ───────────────────────────────────
  Map<String, dynamic> toJson() {
    final body = <String, dynamic>{
      'childId': childId,
      'level': level,
      'exerciseType': exerciseType,
      'status': status,
      'attemptsCount': attemptsCount,
      'duration': duration,
      'totalItems': totalItems,
      'mistakes': mistakes,
      'metadata': metadata,
    };
    if (exerciseId != null) body['exerciseId'] = exerciseId;
    return body;
  }

  // ── From API response ─────────────────────────────────────
  factory SubmissionModel.fromJson(Map<String, dynamic> json) {
    return SubmissionModel(
      id: json['id'] as int?,
      childId: json['childId'] as int? ?? 0,
      level: json['level']?.toString() ?? '',
      exerciseType: json['exerciseType']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pass',
      attemptsCount: json['attemptsCount'] as int? ?? 1,
      duration: json['duration'] as int? ?? 0,
      totalItems: json['totalItems'] as int? ?? 1,
      mistakes: (json['mistakes'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      metadata: (json['metadata'] as Map<String, dynamic>?) ?? const {},
      exerciseId: json['exerciseId'] as int?,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    );
  }

  // ── Convert entity to model ───────────────────────────────
  factory SubmissionModel.fromEntity(SubmissionEntity entity) {
    return SubmissionModel(
      id: entity.id,
      childId: entity.childId,
      level: entity.level,
      exerciseType: entity.exerciseType,
      status: entity.status,
      attemptsCount: entity.attemptsCount,
      duration: entity.duration,
      totalItems: entity.totalItems,
      mistakes: entity.mistakes,
      metadata: entity.metadata,
      exerciseId: entity.exerciseId,
      createdAt: entity.createdAt,
    );
  }

  SubmissionEntity toEntity() {
    return SubmissionEntity(
      id: id,
      childId: childId,
      level: level,
      exerciseType: exerciseType,
      status: status,
      attemptsCount: attemptsCount,
      duration: duration,
      totalItems: totalItems,
      mistakes: mistakes,
      metadata: metadata,
      exerciseId: exerciseId,
      createdAt: createdAt,
    );
  }
}