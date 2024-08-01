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

class SaveProfile extends ProfileEvent {
  final String uid;
  final String companyName;
  final String about;
  final String imagePath;
  final String phoneNumber;
  final String emailAddress;
  final String website;
  final List<Map<String, dynamic>> images;
  final List<Map<String, dynamic>> links;
  final double rating;

  SaveProfile(
      {required this.uid,
      required this.companyName,
      required this.about,
      required this.imagePath,
      required this.phoneNumber,
      required this.emailAddress,
      required this.website,
      required this.images,
      required this.links,
      required this.rating});
}
