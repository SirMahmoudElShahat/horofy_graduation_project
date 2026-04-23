import 'package:equatable/equatable.dart';
import '../../domain/entities/child_entity.dart';

abstract class ChildState extends Equatable {
  const ChildState();

  @override
  List<Object> get props => [];
}

class ChildInitial extends ChildState {}

class ChildAddLoading extends ChildState {}

class ChildAddSuccess extends ChildState {}

class ChildAddError extends ChildState {
  final String message;

  const ChildAddError(this.message);

  @override
  List<Object> get props => [message];
}

class ChildUpdateLoading extends ChildState {}

class ChildUpdateSuccess extends ChildState {}

class ChildUpdateError extends ChildState {
  final String message;

  const ChildUpdateError(this.message);

  @override
  List<Object> get props => [message];
}

class ChildDeleteLoading extends ChildState {}

class ChildDeleteSuccess extends ChildState {}

class ChildDeleteError extends ChildState {
  final String message;

  const ChildDeleteError(this.message);

  @override
  List<Object> get props => [message];
}

class ChildLoading extends ChildState {}

class ChildLoaded extends ChildState {
  final List<ChildEntity> children;

  const ChildLoaded(this.children);

  @override
  List<Object> get props => [children];
}
