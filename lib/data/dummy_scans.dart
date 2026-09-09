import '../models/scan_history_model.dart';

class DummyScans {
  static const List<ScanHistoryModel> scans = [
    ScanHistoryModel(
      id: '1',
      wasteName: 'Plastic Bottle',
      category: 'Plastic',
      confidence: 0.94,
      date: '07 Sep 2026',
      time: '10:30 AM',
      recyclable: true,
      description: 'This item appears to be a recyclable plastic bottle.',
    ),
    ScanHistoryModel(
      id: '2',
      wasteName: 'Cardboard Box',
      category: 'Paper',
      confidence: 0.91,
      date: '06 Sep 2026',
      time: '04:15 PM',
      recyclable: true,
      description: 'This item appears to be a recyclable cardboard box.',
    ),
    ScanHistoryModel(
      id: '3',
      wasteName: 'Glass Bottle',
      category: 'Glass',
      confidence: 0.96,
      date: '05 Sep 2026',
      time: '01:20 PM',
      recyclable: true,
      description: 'This item appears to be a recyclable glass bottle.',
    ),
    ScanHistoryModel(
      id: '4',
      wasteName: 'Battery',
      category: 'E-Waste',
      confidence: 0.89,
      date: '04 Sep 2026',
      time: '06:45 PM',
      recyclable: false,
      description:
          'This item should not be disposed of with regular household waste.',
    ),
    ScanHistoryModel(
      id: '5',
      wasteName: 'Aluminium Can',
      category: 'Metal',
      confidence: 0.93,
      date: '03 Sep 2026',
      time: '11:10 AM',
      recyclable: true,
      description: 'This item appears to be a recyclable aluminium can.',
    ),
  ];
}
