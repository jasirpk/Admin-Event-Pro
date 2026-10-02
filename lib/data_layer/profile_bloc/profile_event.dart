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
  final String companyName;
  final String about;
  final String phoneNumber;
  final String emailAddress;
  final String website;

  /// The portfolio editor's rows, in display order.
  final List<PortfolioRow> portfolio;
  final List<String> links;

  /// The stored avatar, carried over when the user did not replace it.
  final String? existingProfileImage;

  /// A freshly picked avatar, uploaded during the save.
  final File? newProfileImage;

  SaveProfile({
    required this.companyName,
    required this.about,
    required this.phoneNumber,
    required this.emailAddress,
    required this.website,
    required this.portfolio,
    required this.links,
    this.existingProfileImage,
    this.newProfileImage,
  });
}
