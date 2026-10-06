import '../models/learning_model.dart';

class DummyLearning {
  static const List<LearningModel> lessons = [
    // ======================================================
    // PLASTIC
    // ======================================================

    LearningModel(
      id: '1',
      title: 'How to Recycle Plastic',
      category: 'Plastic',
      description:
          'Learn how to identify, prepare, and recycle common plastic items.',
      content:
          'Plastic is one of the most common materials found in household waste. '
          'Before recycling a plastic container, empty and rinse it to remove '
          'food or liquid residue. Check the local recycling guidelines because '
          'different recycling systems may accept different types of plastic. '
          'Avoid placing plastic bags, contaminated containers, or non-recyclable '
          'plastic items into regular recycling unless your local facility accepts them.',
      readTime: '3 min read',
      imageAsset: 'assets/images/plastic.png',
    ),

    // ======================================================
    // PAPER
    // ======================================================
    LearningModel(
      id: '2',
      title: 'How to Recycle Paper',
      category: 'Paper',
      description:
          'Discover the right way to separate and recycle paper and cardboard.',
      content:
          'Paper and cardboard are widely recyclable materials. Keep paper clean '
          'and dry before placing it in the recycling bin. Flatten cardboard boxes '
          'to save space and remove unnecessary plastic or other packaging. '
          'Paper contaminated with food, oil, or other substances may not be '
          'accepted by some recycling facilities.',
      readTime: '3 min read',
      imageAsset: 'assets/images/paper.png',
    ),

    // ======================================================
    // GLASS
    // ======================================================
    LearningModel(
      id: '3',
      title: 'How to Recycle Glass',
      category: 'Glass',
      description:
          'Understand how glass bottles and containers should be prepared for recycling.',
      content:
          'Glass bottles and jars can often be recycled when they are properly '
          'prepared. Empty and rinse the container before recycling it. Remove '
          'caps or lids according to local recycling instructions. Do not place '
          'broken glass, mirrors, ceramics, or drinking glasses into a recycling '
          'container unless your local facility specifically accepts them.',
      readTime: '2 min read',
      imageAsset: 'assets/images/glass.png',
    ),

    // ======================================================
    // METAL
    // ======================================================
    LearningModel(
      id: '4',
      title: 'How to Recycle Metal',
      category: 'Metal',
      description:
          'Learn how cans and other common metal items can be recycled.',
      content:
          'Metal is a valuable recyclable material that can often be recovered '
          'and reused. Aluminium cans and steel food cans are commonly accepted '
          'in recycling programs. Empty and rinse containers before recycling '
          'them. Large metal objects, sharp items, and other special materials '
          'may require separate collection at a recycling facility.',
      readTime: '2 min read',
      imageAsset: 'assets/images/metal.png',
    ),

    // ======================================================
    // E-WASTE
    // ======================================================
    LearningModel(
      id: '5',
      title: 'Understanding E-Waste',
      category: 'E-Waste',
      description:
          'Learn why electronic waste needs special handling and collection.',
      content:
          'Electronic waste includes items such as old phones, computers, '
          'chargers, batteries, and other electronic devices. These items may '
          'contain materials that require specialized recycling processes. '
          'Do not put batteries or electronic devices into regular household '
          'recycling unless your local program specifically allows them. '
          'Instead, take e-waste to an authorized collection point or recycling '
          'facility.',
      readTime: '4 min read',
      imageAsset: 'assets/images/e_waste.png',
    ),

    // ======================================================
    // ORGANIC
    // ======================================================
    LearningModel(
      id: '6',
      title: 'Managing Organic Waste',
      category: 'Organic',
      description:
          'Learn how food and other organic waste can be managed responsibly.',
      content:
          'Organic waste includes food scraps, fruit and vegetable waste, '
          'and other biodegradable materials. Where composting is available, '
          'organic waste can be separated and converted into useful compost. '
          'Keep organic waste separate from recyclable materials to reduce '
          'contamination and improve waste management.',
      readTime: '3 min read',
      imageAsset: 'assets/images/organic.png',
    ),
  ];
}
