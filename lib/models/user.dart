class User {
  final String name;
  final String bloodGroup;
  final String location;
  final bool isDonor;
  final List<String> organsToDonate;

  User({
    required this.name,
    required this.bloodGroup,
    required this.location,
    this.isDonor = false,
    this.organsToDonate = const [],
  });
}