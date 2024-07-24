part of 'dashboard_bloc.dart';

sealed class DashboardEvent {}

class TabChanged extends DashboardEvent {
  final int newIndex;

  TabChanged(this.newIndex);
}

class LoadCoverImages extends DashboardEvent {}

class SelectCoverImage extends DashboardEvent {
  final int index;

  SelectCoverImage(this.index);
}

class UploadCoverImage extends DashboardEvent {
  final String uid;

  UploadCoverImage(this.uid);
}
