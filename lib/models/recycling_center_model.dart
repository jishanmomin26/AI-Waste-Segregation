class RecyclingCenterModel {
  final String id;
  final String name;
  final String address;
  final String distance;
  final String timing;
  final String phone;
  final List<String> acceptedMaterials;
  final bool openNow;
  final String description;

  const RecyclingCenterModel({
    required this.id,
    required this.name,
    required this.address,
    required this.distance,
    required this.timing,
    required this.phone,
    required this.acceptedMaterials,
    required this.openNow,
    required this.description,
  });
}
