part of 'generated_bloc.dart';

@immutable
sealed class GeneratedState {}

final class GeneratedInitial extends GeneratedState {
  final int listViewCount;
  final int timeLineCount;

  GeneratedInitial({required this.listViewCount, required this.timeLineCount});
}

class ComponentLoadedState extends GeneratedState {
  final int listviewItemCount;
  ComponentLoadedState(this.listviewItemCount);
}

class ComponentDecrementState extends GeneratedState {
  final int decrementCount;

  ComponentDecrementState(this.decrementCount);
}

class TimeLineAddedState extends GeneratedState {
  final int TimeVeiwCount;

  TimeLineAddedState(this.TimeVeiwCount);
}

class TimeLineReduceState extends GeneratedState {
  final int TimeReduceCount;

  TimeLineReduceState(this.TimeReduceCount);
}
