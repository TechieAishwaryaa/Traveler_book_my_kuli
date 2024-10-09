class Traveler {
  final String id;
  final String name;
  final String currentLocation;
  final String destination;
  final String phoneNumber;
  final String? photoUrl; // Nullable, since the traveler may or may not upload a photo

  Traveler({
    required this.id,
    required this.name,
    required this.currentLocation,
    required this.destination,
    required this.phoneNumber,
     this.photoUrl,
  });
}