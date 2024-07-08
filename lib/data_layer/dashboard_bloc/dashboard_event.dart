part of 'dashboard_bloc.dart';

sealed class DashboardEvent {}

class TabChanged extends DashboardEvent {
  final int newIndex;

  TabChanged(this.newIndex);
}

class FavoriteStatusChanged extends DashboardEvent {
  final String subCategoryId;
  final bool isFavorite;

  FavoriteStatusChanged(this.subCategoryId, this.isFavorite);
}
