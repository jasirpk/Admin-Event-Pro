part of 'generated_bloc.dart';

@immutable
sealed class GeneratedEvent {}

class IncreamentEvent extends GeneratedEvent {}

class DecrementEvent extends GeneratedEvent {}

class AddMoreTimeLineEvent extends GeneratedEvent {}

class ReduceTimeLineField extends GeneratedEvent {}

class PickImageEvent extends GeneratedEvent {
  final int index;
  PickImageEvent(this.index);
}

class RemoveImageEvent extends GeneratedEvent {
  final int index;
  RemoveImageEvent(this.index);
}

class PickImage extends GeneratedEvent {}

class FetchLocation extends GeneratedEvent {}

class ResetFormEvent extends GeneratedEvent {}
