import 'package:equatable/equatable.dart';

class SubmissionEntity extends Equatable {
  final int? id;
  final int childId;
  final String level;
  final String exerciseType;
  final String status;
  final int attemptsCount;
  final int duration;
  final int totalItems;
  final List<String> mistakes;
  final Map<String, dynamic> metadata;
  final int? exerciseId;
  final DateTime? createdAt;

  const SubmissionEntity({
    this.id,
    required this.childId,
    required this.level,
    required this.exerciseType,
    this.status = 'pass',
    this.attemptsCount = 1,
    this.duration = 0,
    this.totalItems = 1,
    this.mistakes = const [],
    this.metadata = const {},
    this.exerciseId,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    childId,
    level,
    exerciseType,
    status,
    attemptsCount,
    duration,
    totalItems,
    mistakes,
    metadata,
    exerciseId,
    createdAt,
  ];
}