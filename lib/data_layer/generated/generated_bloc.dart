import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';

part 'generated_event.dart';
part 'generated_state.dart';

class GeneratedBloc extends Bloc<GeneratedEvent, GeneratedState> {
  int updatedItemCount = 0;
  int timeLineIndex = 1;

  GeneratedBloc()
      : super(GeneratedInitial(listViewCount: 1, timeLineCount: 1)) {
    on<IncreamentEvent>(increamentEvent);
    on<DecrementEvent>(decrementEvent);
    on<AddMoreTimeLineEvent>(addMoreTimeLine);
    on<ReduceTimeLineField>(reduceTimeLineField);
  }

  FutureOr<void> increamentEvent(
      IncreamentEvent event, Emitter<GeneratedState> emit) {
    if (state is GeneratedInitial) {
      updatedItemCount = (state as GeneratedInitial).listViewCount + 1;
      emit(GeneratedInitial(
        listViewCount: updatedItemCount,
        timeLineCount: (state as GeneratedInitial).timeLineCount,
      ));
    }
  }

  FutureOr<void> decrementEvent(
      DecrementEvent event, Emitter<GeneratedState> emit) {
    if (state is GeneratedInitial &&
        (state as GeneratedInitial).listViewCount > 1) {
      updatedItemCount = (state as GeneratedInitial).listViewCount - 1;
      emit(GeneratedInitial(
        listViewCount: updatedItemCount,
        timeLineCount: (state as GeneratedInitial).timeLineCount,
      ));
    }
  }

  FutureOr<void> addMoreTimeLine(
      AddMoreTimeLineEvent event, Emitter<GeneratedState> emit) {
    if (state is GeneratedInitial) {
      timeLineIndex = (state as GeneratedInitial).timeLineCount + 1;
      emit(GeneratedInitial(
        listViewCount: (state as GeneratedInitial).listViewCount,
        timeLineCount: timeLineIndex,
      ));
    }
  }

  FutureOr<void> reduceTimeLineField(
      ReduceTimeLineField event, Emitter<GeneratedState> emit) {
    if (state is GeneratedInitial &&
        (state as GeneratedInitial).timeLineCount > 1) {
      timeLineIndex = (state as GeneratedInitial).timeLineCount - 1;
      emit(GeneratedInitial(
        listViewCount: (state as GeneratedInitial).listViewCount,
        timeLineCount: timeLineIndex,
      ));
    }
  }
}
