import '../models/waste_model.dart';

class DummyWaste {
  static const List<WasteModel> categories = [
    WasteModel(
      id: 'waste_001',
      name: 'Plastic',
      description:
          'Plastic bottles, containers and recyclable plastic packaging.',
      icon: 'plastic',
      recyclable: true,
      totalScans: 48,
    ),
    WasteModel(
      id: 'waste_002',
      name: 'Paper',
      description:
          'Paper, newspapers, cardboard and other paper-based materials.',
      icon: 'paper',
      recyclable: true,
      totalScans: 35,
    ),
    WasteModel(
      id: 'waste_003',
      name: 'Glass',
      description: 'Glass bottles, jars and recyclable glass containers.',
      icon: 'glass',
      recyclable: true,
      totalScans: 27,
    ),
    WasteModel(
      id: 'waste_004',
      name: 'Metal',
      description:
          'Aluminium cans, steel containers and other recyclable metals.',
      icon: 'metal',
      recyclable: true,
      totalScans: 31,
    ),
    WasteModel(
      id: 'waste_005',
      name: 'E-Waste',
      description: 'Electronic devices, batteries, chargers and related items.',
      icon: 'e_waste',
      recyclable: false,
      totalScans: 19,
    ),
    WasteModel(
      id: 'waste_006',
      name: 'Organic',
      description:
          'Food scraps, fruit and vegetable waste and biodegradable materials.',
      icon: 'organic',
      recyclable: true,
      totalScans: 22,
    ),
  ];
}
