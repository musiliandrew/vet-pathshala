import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../shared/models/drug_model.dart';

class DrugService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _drugsCollection = 'drugs';
  static const String _calculationsCollection = 'drug_calculations';
  static const String _bookmarksCollection = 'drug_bookmarks';

  // Get all drugs with pagination
  static Future<List<DrugModel>> getDrugs({
    int limit = 20,
    DocumentSnapshot? lastDocument,
    String? category,
    String? searchTerm,
    bool? isVeterinarySpecific,
    List<String>? targetSpecies,
  }) async {
    try {
      Query query = _firestore
          .collection(_drugsCollection)
          .where('isActive', isEqualTo: true);

      // Apply filters
      if (category != null && category.isNotEmpty) {
        query = query.where('category', isEqualTo: category);
      }

      if (isVeterinarySpecific != null) {
        query = query.where('isVeterinarySpecific', isEqualTo: isVeterinarySpecific);
      }

      if (targetSpecies != null && targetSpecies.isNotEmpty) {
        query = query.where('targetSpecies', arrayContainsAny: targetSpecies);
      }

      // Apply search filter
      if (searchTerm != null && searchTerm.isNotEmpty) {
        // Note: Firestore doesn't support full-text search natively
        // This is a basic implementation using array-contains for keywords
        final searchTermLower = searchTerm.toLowerCase();
        query = query.orderBy('name');
      } else {
        query = query.orderBy('name');
      }

      // Apply pagination
      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      query = query.limit(limit);

      final QuerySnapshot snapshot = await query.get();

      List<DrugModel> drugs = snapshot.docs
          .map((doc) => DrugModel.fromMap({
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              }))
          .toList();

      // Apply client-side search filtering if needed
      if (searchTerm != null && searchTerm.isNotEmpty) {
        final searchTermLower = searchTerm.toLowerCase();
        drugs = drugs.where((drug) {
          return drug.name.toLowerCase().contains(searchTermLower) ||
                 drug.genericName.toLowerCase().contains(searchTermLower) ||
                 drug.brandName.toLowerCase().contains(searchTermLower) ||
                 drug.indication.toLowerCase().contains(searchTermLower);
        }).toList();
      }

      return drugs;
    } catch (e) {
      // If Firestore access fails, return sample data
      if (e.toString().contains('permission-denied') || 
          e.toString().contains('PERMISSION_DENIED')) {
        return _getSampleDrugs(
          limit: limit,
          category: category,
          searchTerm: searchTerm,
          isVeterinarySpecific: isVeterinarySpecific,
          targetSpecies: targetSpecies,
        );
      }
      throw Exception('Failed to fetch drugs: $e');
    }
  }

  // Get drug by ID
  static Future<DrugModel?> getDrugById(String drugId) async {
    try {
      final DocumentSnapshot doc = await _firestore
          .collection(_drugsCollection)
          .doc(drugId)
          .get();

      if (doc.exists) {
        return DrugModel.fromMap({
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        });
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch drug: $e');
    }
  }

  // Get drug categories
  static Future<List<String>> getDrugCategories() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_drugsCollection)
          .where('isActive', isEqualTo: true)
          .get();

      final Set<String> categories = {};
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['category'] != null) {
          categories.add(data['category']);
        }
      }

      return categories.toList()..sort();
    } catch (e) {
      // If Firestore access fails, return sample categories
      if (e.toString().contains('permission-denied') || 
          e.toString().contains('PERMISSION_DENIED')) {
        return ['Antibiotics', 'NSAIDs', 'Anthelmintics', 'Vaccines', 'Sedatives'];
      }
      throw Exception('Failed to fetch drug categories: $e');
    }
  }

  // Get target species
  static Future<List<String>> getTargetSpecies() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_drugsCollection)
          .where('isActive', isEqualTo: true)
          .where('isVeterinarySpecific', isEqualTo: true)
          .get();

      final Set<String> species = {};
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['targetSpecies'] != null) {
          final List<String> drugSpecies = List<String>.from(data['targetSpecies']);
          species.addAll(drugSpecies);
        }
      }

      return species.toList()..sort();
    } catch (e) {
      // If Firestore access fails, return sample species
      if (e.toString().contains('permission-denied') || 
          e.toString().contains('PERMISSION_DENIED')) {
        return ['Dogs', 'Cats', 'Cattle', 'Sheep', 'Goats', 'Horses', 'Pigs'];
      }
      throw Exception('Failed to fetch target species: $e');
    }
  }

  // Bookmark/unbookmark drug
  static Future<void> toggleBookmark(String userId, String drugId) async {
    try {
      final String bookmarkId = '${userId}_$drugId';
      final DocumentReference bookmarkRef = _firestore
          .collection(_bookmarksCollection)
          .doc(bookmarkId);

      final DocumentSnapshot bookmarkDoc = await bookmarkRef.get();

      if (bookmarkDoc.exists) {
        // Remove bookmark
        await bookmarkRef.delete();
      } else {
        // Add bookmark
        await bookmarkRef.set({
          'userId': userId,
          'drugId': drugId,
          'bookmarkedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw Exception('Failed to toggle bookmark: $e');
    }
  }

  // Get user bookmarks
  static Future<List<String>> getUserBookmarks(String userId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_bookmarksCollection)
          .where('userId', isEqualTo: userId)
          .get();

      return snapshot.docs
          .map((doc) => (doc.data() as Map<String, dynamic>)['drugId'] as String)
          .toList();
    } catch (e) {
      // Handle permission denied gracefully by returning empty list
      if (e.toString().contains('permission-denied') || 
          e.toString().contains('PERMISSION_DENIED')) {
        return [];
      }
      throw Exception('Failed to fetch bookmarks: $e');
    }
  }

  // Get bookmarked drugs
  static Future<List<DrugModel>> getBookmarkedDrugs(String userId) async {
    try {
      final List<String> bookmarkedIds = await getUserBookmarks(userId);
      
      if (bookmarkedIds.isEmpty) {
        return [];
      }

      // Firestore has a limit of 10 items for whereIn queries
      // We'll batch the requests if there are more bookmarks
      final List<DrugModel> bookmarkedDrugs = [];
      
      for (int i = 0; i < bookmarkedIds.length; i += 10) {
        final batch = bookmarkedIds.skip(i).take(10).toList();
        
        final QuerySnapshot snapshot = await _firestore
            .collection(_drugsCollection)
            .where(FieldPath.documentId, whereIn: batch)
            .where('isActive', isEqualTo: true)
            .get();

        final batchDrugs = snapshot.docs
            .map((doc) => DrugModel.fromMap({
                  'id': doc.id,
                  ...doc.data() as Map<String, dynamic>,
                }))
            .toList();
        
        bookmarkedDrugs.addAll(batchDrugs);
      }

      return bookmarkedDrugs;
    } catch (e) {
      throw Exception('Failed to fetch bookmarked drugs: $e');
    }
  }

  // Check if drug is bookmarked
  static Future<bool> isDrugBookmarked(String userId, String drugId) async {
    try {
      final String bookmarkId = '${userId}_$drugId';
      final DocumentSnapshot doc = await _firestore
          .collection(_bookmarksCollection)
          .doc(bookmarkId)
          .get();

      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  // Drug Calculator Methods
  
  // Calculate dosage
  static Map<String, dynamic> calculateDosage({
    required DrugModel drug,
    required double animalWeight,
    required String weightUnit,
    required String species,
    String? indication,
  }) {
    try {
      // This is a simplified calculation - in a real app, you'd have
      // more complex formulas based on the drug and species
      
      // Convert weight to kg if needed
      double weightInKg = animalWeight;
      if (weightUnit.toLowerCase() == 'lbs' || weightUnit.toLowerCase() == 'pounds') {
        weightInKg = animalWeight * 0.453592;
      }

      // Extract dosage information from drug.dosage string
      // This is simplified - real implementation would parse complex dosage strings
      final dosageMatch = RegExp(r'(\d+(?:\.\d+)?)\s*-?\s*(\d+(?:\.\d+)?)?\s*(mg|g|ml|mcg)(?:/kg)?')
          .firstMatch(drug.dosage.toLowerCase());

      if (dosageMatch == null) {
        throw Exception('Unable to parse dosage information');
      }

      double minDose = double.parse(dosageMatch.group(1)!);
      double maxDose = dosageMatch.group(2) != null 
          ? double.parse(dosageMatch.group(2)!) 
          : minDose;
      String unit = dosageMatch.group(3)!;

      // Calculate total dose
      double totalMinDose = minDose * weightInKg;
      double totalMaxDose = maxDose * weightInKg;

      // Calculate frequency (simplified)
      int frequency = 1;
      if (drug.dosage.toLowerCase().contains('twice') || 
          drug.dosage.toLowerCase().contains('bid') ||
          drug.dosage.toLowerCase().contains('q12h')) {
        frequency = 2;
      } else if (drug.dosage.toLowerCase().contains('three times') || 
                 drug.dosage.toLowerCase().contains('tid') ||
                 drug.dosage.toLowerCase().contains('q8h')) {
        frequency = 3;
      } else if (drug.dosage.toLowerCase().contains('four times') || 
                 drug.dosage.toLowerCase().contains('qid') ||
                 drug.dosage.toLowerCase().contains('q6h')) {
        frequency = 4;
      }

      return {
        'animalWeight': animalWeight,
        'weightUnit': weightUnit,
        'weightInKg': weightInKg,
        'species': species,
        'indication': indication ?? drug.indication,
        'minDose': totalMinDose,
        'maxDose': totalMaxDose,
        'doseUnit': unit,
        'frequency': frequency,
        'dailyMinDose': totalMinDose * frequency,
        'dailyMaxDose': totalMaxDose * frequency,
        'recommendations': _generateRecommendations(drug, species, weightInKg),
        'warnings': _generateWarnings(drug, species, weightInKg),
      };
    } catch (e) {
      throw Exception('Failed to calculate dosage: $e');
    }
  }

  // Save calculation
  static Future<void> saveCalculation({
    required String userId,
    required DrugCalculation calculation,
  }) async {
    try {
      await _firestore
          .collection(_calculationsCollection)
          .doc(calculation.id)
          .set(calculation.toMap());
    } catch (e) {
      throw Exception('Failed to save calculation: $e');
    }
  }

  // Get user calculations
  static Future<List<DrugCalculation>> getUserCalculations(
    String userId, {
    int limit = 20,
  }) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_calculationsCollection)
          .where('calculatedBy', isEqualTo: userId)
          .orderBy('calculatedAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => DrugCalculation.fromMap({
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              }))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch calculations: $e');
    }
  }

  // Helper methods
  static List<String> _generateRecommendations(DrugModel drug, String species, double weightInKg) {
    List<String> recommendations = [];
    
    recommendations.add('Monitor animal for side effects during treatment');
    recommendations.add('Complete the full course of treatment as prescribed');
    
    if (drug.withdrawalPeriod.isNotEmpty) {
      recommendations.add('Withdrawal period: ${drug.withdrawalPeriod}');
    }
    
    if (drug.storage.isNotEmpty) {
      recommendations.add('Storage: ${drug.storage}');
    }

    return recommendations;
  }

  static List<String> _generateWarnings(DrugModel drug, String species, double weightInKg) {
    List<String> warnings = [];
    
    if (drug.contraindication.isNotEmpty) {
      warnings.add('Contraindications: ${drug.contraindication}');
    }
    
    if (drug.precautions.isNotEmpty) {
      warnings.add('Precautions: ${drug.precautions}');
    }
    
    if (drug.isControlled) {
      warnings.add('This is a controlled substance (${drug.controlledClass})');
    }

    return warnings;
  }

  // Seed sample data (for development)
  static Future<void> seedSampleDrugs() async {
    try {
      final List<Map<String, dynamic>> sampleDrugs = [
        {
          'name': 'Amoxicillin',
          'genericName': 'Amoxicillin',
          'brandName': 'Amoxil',
          'category': 'Antibiotics',
          'classification': 'Penicillin',
          'dosageForm': 'Tablet',
          'strength': '500mg',
          'route': 'Oral',
          'indication': 'Bacterial infections',
          'contraindication': 'Penicillin allergy',
          'sideEffects': 'Nausea, diarrhea, allergic reactions',
          'dosage': '20-40 mg/kg twice daily',
          'mechanism': 'Inhibits bacterial cell wall synthesis',
          'pharmacokinetics': 'Well absorbed orally, excreted in urine',
          'interactions': 'May reduce effectiveness of oral contraceptives',
          'precautions': 'Use with caution in animals with kidney disease',
          'storage': 'Store at room temperature, protect from moisture',
          'manufacturer': 'VetPharma Inc.',
          'price': 25.99,
          'currency': 'USD',
          'isVeterinarySpecific': true,
          'targetSpecies': ['Dogs', 'Cats'],
          'withdrawalPeriod': '7 days for meat, 3 days for milk',
          'isControlled': false,
          'controlledClass': '',
          'createdAt': DateTime.now().millisecondsSinceEpoch,
          'updatedAt': DateTime.now().millisecondsSinceEpoch,
          'isActive': true,
        },
        {
          'name': 'Meloxicam',
          'genericName': 'Meloxicam',
          'brandName': 'Metacam',
          'category': 'NSAIDs',
          'classification': 'Non-steroidal anti-inflammatory',
          'dosageForm': 'Oral Suspension',
          'strength': '1.5mg/ml',
          'route': 'Oral',
          'indication': 'Pain and inflammation in dogs and cats',
          'contraindication': 'Kidney disease, liver disease, pregnancy',
          'sideEffects': 'Vomiting, diarrhea, kidney damage',
          'dosage': '0.1-0.2 mg/kg once daily',
          'mechanism': 'Selective COX-2 inhibitor',
          'pharmacokinetics': 'Metabolized in liver, excreted in feces',
          'interactions': 'Do not use with other NSAIDs or corticosteroids',
          'precautions': 'Monitor kidney and liver function',
          'storage': 'Store below 25°C, do not freeze',
          'manufacturer': 'Boehringer Ingelheim',
          'price': 45.50,
          'currency': 'USD',
          'isVeterinarySpecific': true,
          'targetSpecies': ['Dogs', 'Cats'],
          'withdrawalPeriod': '5 days',
          'isControlled': false,
          'controlledClass': '',
          'createdAt': DateTime.now().millisecondsSinceEpoch,
          'updatedAt': DateTime.now().millisecondsSinceEpoch,
          'isActive': true,
        },
        {
          'name': 'Fenbendazole',
          'genericName': 'Fenbendazole',
          'brandName': 'Panacur',
          'category': 'Anthelmintics',
          'classification': 'Benzimidazole',
          'dosageForm': 'Oral Suspension',
          'strength': '100mg/ml',
          'route': 'Oral',
          'indication': 'Treatment of roundworms, hookworms, whipworms, and tapeworms',
          'contraindication': 'Hypersensitivity to benzimidazoles',
          'sideEffects': 'Rare: vomiting, diarrhea',
          'dosage': '50 mg/kg once daily for 3 days',
          'mechanism': 'Interferes with parasite metabolism',
          'pharmacokinetics': 'Poorly absorbed, acts locally in GI tract',
          'interactions': 'None known',
          'precautions': 'Safe in pregnant animals',
          'storage': 'Store at room temperature',
          'manufacturer': 'MSD Animal Health',
          'price': 32.75,
          'currency': 'USD',
          'isVeterinarySpecific': true,
          'targetSpecies': ['Dogs', 'Cats', 'Cattle', 'Sheep', 'Goats'],
          'withdrawalPeriod': '8 days for meat, 3 days for milk',
          'isControlled': false,
          'controlledClass': '',
          'createdAt': DateTime.now().millisecondsSinceEpoch,
          'updatedAt': DateTime.now().millisecondsSinceEpoch,
          'isActive': true,
        },
      ];

      final batch = _firestore.batch();
      
      for (var drugData in sampleDrugs) {
        final docRef = _firestore.collection(_drugsCollection).doc();
        batch.set(docRef, drugData);
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to seed sample drugs: $e');
    }
  }

  // Get sample drugs when Firestore access fails
  static List<DrugModel> _getSampleDrugs({
    int limit = 20,
    String? category,
    String? searchTerm,
    bool? isVeterinarySpecific,
    List<String>? targetSpecies,
  }) {
    final List<Map<String, dynamic>> sampleData = [
      {
        'id': '1',
        'name': 'Amoxicillin',
        'genericName': 'Amoxicillin',
        'brandName': 'Amoxil',
        'category': 'Antibiotics',
        'classification': 'Penicillin',
        'dosageForm': 'Tablet',
        'strength': '500mg',
        'route': 'Oral',
        'indication': 'Bacterial infections in dogs and cats',
        'contraindication': 'Penicillin allergy',
        'sideEffects': 'Nausea, diarrhea, allergic reactions',
        'dosage': '20-40 mg/kg twice daily',
        'mechanism': 'Inhibits bacterial cell wall synthesis',
        'pharmacokinetics': 'Well absorbed orally, excreted in urine',
        'interactions': 'May reduce effectiveness of oral contraceptives',
        'precautions': 'Use with caution in animals with kidney disease',
        'storage': 'Store at room temperature, protect from moisture',
        'manufacturer': 'VetPharma Inc.',
        'price': 25.99,
        'currency': 'USD',
        'isVeterinarySpecific': true,
        'targetSpecies': ['Dogs', 'Cats'],
        'withdrawalPeriod': '7 days for meat, 3 days for milk',
        'isControlled': false,
        'controlledClass': '',
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
        'isActive': true,
      },
      {
        'id': '2',
        'name': 'Meloxicam',
        'genericName': 'Meloxicam',
        'brandName': 'Metacam',
        'category': 'NSAIDs',
        'classification': 'Non-steroidal anti-inflammatory',
        'dosageForm': 'Oral Suspension',
        'strength': '1.5mg/ml',
        'route': 'Oral',
        'indication': 'Pain and inflammation in dogs and cats',
        'contraindication': 'Kidney disease, liver disease, pregnancy',
        'sideEffects': 'Vomiting, diarrhea, kidney damage',
        'dosage': '0.1-0.2 mg/kg once daily',
        'mechanism': 'Selective COX-2 inhibitor',
        'pharmacokinetics': 'Metabolized in liver, excreted in feces',
        'interactions': 'Do not use with other NSAIDs or corticosteroids',
        'precautions': 'Monitor kidney and liver function',
        'storage': 'Store below 25°C, do not freeze',
        'manufacturer': 'Boehringer Ingelheim',
        'price': 45.50,
        'currency': 'USD',
        'isVeterinarySpecific': true,
        'targetSpecies': ['Dogs', 'Cats'],
        'withdrawalPeriod': '5 days',
        'isControlled': false,
        'controlledClass': '',
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
        'isActive': true,
      },
      {
        'id': '3',
        'name': 'Fenbendazole',
        'genericName': 'Fenbendazole',
        'brandName': 'Panacur',
        'category': 'Anthelmintics',
        'classification': 'Benzimidazole',
        'dosageForm': 'Oral Suspension',
        'strength': '100mg/ml',
        'route': 'Oral',
        'indication': 'Treatment of roundworms, hookworms, whipworms, and tapeworms',
        'contraindication': 'Hypersensitivity to benzimidazoles',
        'sideEffects': 'Rare: vomiting, diarrhea',
        'dosage': '50 mg/kg once daily for 3 days',
        'mechanism': 'Interferes with parasite metabolism',
        'pharmacokinetics': 'Poorly absorbed, acts locally in GI tract',
        'interactions': 'None known',
        'precautions': 'Safe in pregnant animals',
        'storage': 'Store at room temperature',
        'manufacturer': 'MSD Animal Health',
        'price': 32.75,
        'currency': 'USD',
        'isVeterinarySpecific': true,
        'targetSpecies': ['Dogs', 'Cats', 'Cattle', 'Sheep', 'Goats'],
        'withdrawalPeriod': '8 days for meat, 3 days for milk',
        'isControlled': false,
        'controlledClass': '',
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
        'isActive': true,
      },
      {
        'id': '4',
        'name': 'Xylazine',
        'genericName': 'Xylazine',
        'brandName': 'Rompun',
        'category': 'Sedatives',
        'classification': 'Alpha-2 agonist',
        'dosageForm': 'Injectable',
        'strength': '20mg/ml',
        'route': 'Intramuscular/Intravenous',
        'indication': 'Sedation and anesthesia in veterinary medicine',
        'contraindication': 'Severe cardiac disease',
        'sideEffects': 'Bradycardia, hypotension, respiratory depression',
        'dosage': '1-2 mg/kg IM or 0.5-1 mg/kg IV',
        'mechanism': 'Alpha-2 adrenergic receptor agonist',
        'pharmacokinetics': 'Rapid onset, duration 1-3 hours',
        'interactions': 'Potentiates other CNS depressants',
        'precautions': 'Monitor cardiovascular function',
        'storage': 'Store at room temperature, protect from light',
        'manufacturer': 'Bayer Animal Health',
        'price': 85.00,
        'currency': 'USD',
        'isVeterinarySpecific': true,
        'targetSpecies': ['Dogs', 'Cats', 'Cattle', 'Horses'],
        'withdrawalPeriod': '7 days for meat',
        'isControlled': true,
        'controlledClass': 'Schedule III',
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
        'isActive': true,
      },
      {
        'id': '5',
        'name': 'Rabies Vaccine',
        'genericName': 'Rabies Vaccine',
        'brandName': 'Nobivac Rabies',
        'category': 'Vaccines',
        'classification': 'Inactivated virus vaccine',
        'dosageForm': 'Injectable',
        'strength': '1ml dose',
        'route': 'Subcutaneous/Intramuscular',
        'indication': 'Prevention of rabies in dogs and cats',
        'contraindication': 'Severe illness, immunosuppression',
        'sideEffects': 'Local swelling, mild fever, lethargy',
        'dosage': '1ml annually',
        'mechanism': 'Stimulates antibody production against rabies virus',
        'pharmacokinetics': 'Immunity develops within 2-4 weeks',
        'interactions': 'May interfere with other live vaccines',
        'precautions': 'Do not vaccinate pregnant animals',
        'storage': 'Refrigerate at 2-8°C, do not freeze',
        'manufacturer': 'MSD Animal Health',
        'price': 15.25,
        'currency': 'USD',
        'isVeterinarySpecific': true,
        'targetSpecies': ['Dogs', 'Cats'],
        'withdrawalPeriod': 'Not applicable',
        'isControlled': false,
        'controlledClass': '',
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
        'isActive': true,
      },
    ];

    List<DrugModel> drugs = sampleData.map((data) => DrugModel.fromMap(data)).toList();

    // Apply filters
    if (category != null && category.isNotEmpty) {
      drugs = drugs.where((drug) => drug.category == category).toList();
    }

    if (isVeterinarySpecific != null) {
      drugs = drugs.where((drug) => drug.isVeterinarySpecific == isVeterinarySpecific).toList();
    }

    if (targetSpecies != null && targetSpecies.isNotEmpty) {
      drugs = drugs.where((drug) => 
        drug.targetSpecies.any((species) => targetSpecies.contains(species))
      ).toList();
    }

    if (searchTerm != null && searchTerm.isNotEmpty) {
      final searchLower = searchTerm.toLowerCase();
      drugs = drugs.where((drug) {
        return drug.name.toLowerCase().contains(searchLower) ||
               drug.genericName.toLowerCase().contains(searchLower) ||
               drug.brandName.toLowerCase().contains(searchLower) ||
               drug.indication.toLowerCase().contains(searchLower);
      }).toList();
    }

    return drugs.take(limit).toList();
  }
}