import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc() : super(DashboardInitial()) {
    on<TabChanged>((event, emit) {
      emit(TabState(event.newIndex));
    });
    on<FavoriteStatusChanged>((event, emit) {
      emit(FavoriteStatusUpdated(
          subCategoryId: event.subCategoryId, isFavorite: event.isFavorite));
    });
  }
}
