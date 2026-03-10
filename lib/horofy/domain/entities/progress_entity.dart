import 'package:equatable/equatable.dart';

class ProgressEntity extends Equatable {
  final int? id;
  final int childId;
  final String level;
  final int letterId;
  final bool listened;
  final bool spoken;
  final bool written;

  const ProgressEntity({
    this.id,
    required this.childId,
    required this.level,
    required this.letterId,
    this.listened = false,
    this.spoken = false,
    this.written = false,
  });

  @override
  List<Object?> get props => [
    id,
    childId,
    level,
    letterId,
    listened,
    spoken,
    written,
  ];
}
