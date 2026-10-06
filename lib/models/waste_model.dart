class WasteModel {
  final String id;
  final String name;
  final String description;
  final String icon;
  final bool recyclable;
  final int totalScans;

  const WasteModel({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.recyclable,
    required this.totalScans,
  });
}
