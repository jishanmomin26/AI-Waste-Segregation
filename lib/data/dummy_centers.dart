import '../models/recycling_center_model.dart';

class DummyCenters {
  static const List<RecyclingCenterModel> centers = [
    RecyclingCenterModel(
      id: '1',
      name: 'GreenCycle Recycling Center',
      address: 'Sector 10, Navi Mumbai',
      distance: '1.2 km',
      timing: '9:00 AM - 7:00 PM',
      phone: '+91 98765 43210',
      acceptedMaterials: ['Plastic', 'Paper', 'Glass', 'Metal'],
      openNow: true,
      description:
          'A local recycling center that accepts common household recyclable materials.',
    ),
    RecyclingCenterModel(
      id: '2',
      name: 'EcoDrop Collection Point',
      address: 'Palm Beach Road, Navi Mumbai',
      distance: '2.4 km',
      timing: '10:00 AM - 6:00 PM',
      phone: '+91 98765 12345',
      acceptedMaterials: ['Plastic', 'E-Waste', 'Metal'],
      openNow: true,
      description:
          'Convenient collection point for recyclable waste and selected electronic items.',
    ),
    RecyclingCenterModel(
      id: '3',
      name: 'Clean Earth Recycling Hub',
      address: 'Vashi, Navi Mumbai',
      distance: '3.1 km',
      timing: '8:30 AM - 6:30 PM',
      phone: '+91 99887 66554',
      acceptedMaterials: ['Paper', 'Glass', 'Plastic', 'Organic'],
      openNow: false,
      description:
          'A community-focused recycling hub supporting multiple waste categories.',
    ),
    RecyclingCenterModel(
      id: '4',
      name: 'Green Bin Collection Center',
      address: 'Sanpada, Navi Mumbai',
      distance: '4.0 km',
      timing: '9:30 AM - 5:30 PM',
      phone: '+91 91234 56789',
      acceptedMaterials: ['Plastic', 'Paper', 'Metal'],
      openNow: true,
      description:
          'Collection center for household recyclable materials and reusable waste.',
    ),
  ];
}
