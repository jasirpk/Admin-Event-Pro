part of 'profile_bloc.dart';

@immutable
sealed class ProfileEvent {}

class IncreamentEvent extends ProfileEvent {}

class DecrementEvent extends ProfileEvent {}

class AddMoreFields extends ProfileEvent {}

class Reducefield extends ProfileEvent {}

class PickImageEvent extends ProfileEvent {
  final int index;
  PickImageEvent(this.index);
}

class RemoveImageEvent extends ProfileEvent {
  final int index;
  RemoveImageEvent(this.index);
}

class PickImage extends ProfileEvent {}

class ClearImages extends ProfileEvent {}
