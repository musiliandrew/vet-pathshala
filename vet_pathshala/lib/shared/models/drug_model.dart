class DrugModel {
  final String id;
  final String name;
  final String genericName;
  final String brandName;
  final String category;
  final String classification;
  final String dosageForm;
  final String strength;
  final String route;
  final String indication;
  final String contraindication;
  final String sideEffects;
  final String dosage;
  final String mechanism;
  final String pharmacokinetics;
  final String interactions;
  final String precautions;
  final String storage;
  final String manufacturer;
  final double price;
  final String currency;
  final bool isVeterinarySpecific;
  final List<String> targetSpecies;
  final String withdrawalPeriod;
  final bool isControlled;
  final String controlledClass;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  DrugModel({
    required this.id,
    required this.name,
    required this.genericName,
    required this.brandName,
    required this.category,
    required this.classification,
    required this.dosageForm,
    required this.strength,
    required this.route,
    required this.indication,
    required this.contraindication,
    required this.sideEffects,
    required this.dosage,
    required this.mechanism,
    required this.pharmacokinetics,
    required this.interactions,
    required this.precautions,
    required this.storage,
    required this.manufacturer,
    required this.price,
    this.currency = 'USD',
    required this.isVeterinarySpecific,
    required this.targetSpecies,
    required this.withdrawalPeriod,
    required this.isControlled,
    required this.controlledClass,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  factory DrugModel.fromMap(Map<String, dynamic> map) {
    return DrugModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      genericName: map['genericName'] ?? '',
      brandName: map['brandName'] ?? '',
      category: map['category'] ?? '',
      classification: map['classification'] ?? '',
      dosageForm: map['dosageForm'] ?? '',
      strength: map['strength'] ?? '',
      route: map['route'] ?? '',
      indication: map['indication'] ?? '',
      contraindication: map['contraindication'] ?? '',
      sideEffects: map['sideEffects'] ?? '',
      dosage: map['dosage'] ?? '',
      mechanism: map['mechanism'] ?? '',
      pharmacokinetics: map['pharmacokinetics'] ?? '',
      interactions: map['interactions'] ?? '',
      precautions: map['precautions'] ?? '',
      storage: map['storage'] ?? '',
      manufacturer: map['manufacturer'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      currency: map['currency'] ?? 'USD',
      isVeterinarySpecific: map['isVeterinarySpecific'] ?? false,
      targetSpecies: List<String>.from(map['targetSpecies'] ?? []),
      withdrawalPeriod: map['withdrawalPeriod'] ?? '',
      isControlled: map['isControlled'] ?? false,
      controlledClass: map['controlledClass'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'genericName': genericName,
      'brandName': brandName,
      'category': category,
      'classification': classification,
      'dosageForm': dosageForm,
      'strength': strength,
      'route': route,
      'indication': indication,
      'contraindication': contraindication,
      'sideEffects': sideEffects,
      'dosage': dosage,
      'mechanism': mechanism,
      'pharmacokinetics': pharmacokinetics,
      'interactions': interactions,
      'precautions': precautions,
      'storage': storage,
      'manufacturer': manufacturer,
      'price': price,
      'currency': currency,
      'isVeterinarySpecific': isVeterinarySpecific,
      'targetSpecies': targetSpecies,
      'withdrawalPeriod': withdrawalPeriod,
      'isControlled': isControlled,
      'controlledClass': controlledClass,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'isActive': isActive,
    };
  }

  DrugModel copyWith({
    String? id,
    String? name,
    String? genericName,
    String? brandName,
    String? category,
    String? classification,
    String? dosageForm,
    String? strength,
    String? route,
    String? indication,
    String? contraindication,
    String? sideEffects,
    String? dosage,
    String? mechanism,
    String? pharmacokinetics,
    String? interactions,
    String? precautions,
    String? storage,
    String? manufacturer,
    double? price,
    String? currency,
    bool? isVeterinarySpecific,
    List<String>? targetSpecies,
    String? withdrawalPeriod,
    bool? isControlled,
    String? controlledClass,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return DrugModel(
      id: id ?? this.id,
      name: name ?? this.name,
      genericName: genericName ?? this.genericName,
      brandName: brandName ?? this.brandName,
      category: category ?? this.category,
      classification: classification ?? this.classification,
      dosageForm: dosageForm ?? this.dosageForm,
      strength: strength ?? this.strength,
      route: route ?? this.route,
      indication: indication ?? this.indication,
      contraindication: contraindication ?? this.contraindication,
      sideEffects: sideEffects ?? this.sideEffects,
      dosage: dosage ?? this.dosage,
      mechanism: mechanism ?? this.mechanism,
      pharmacokinetics: pharmacokinetics ?? this.pharmacokinetics,
      interactions: interactions ?? this.interactions,
      precautions: precautions ?? this.precautions,
      storage: storage ?? this.storage,
      manufacturer: manufacturer ?? this.manufacturer,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      isVeterinarySpecific: isVeterinarySpecific ?? this.isVeterinarySpecific,
      targetSpecies: targetSpecies ?? this.targetSpecies,
      withdrawalPeriod: withdrawalPeriod ?? this.withdrawalPeriod,
      isControlled: isControlled ?? this.isControlled,
      controlledClass: controlledClass ?? this.controlledClass,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }
}

class DrugCalculation {
  final String id;
  final String drugId;
  final String calculationType;
  final Map<String, dynamic> inputs;
  final Map<String, dynamic> results;
  final String animalSpecies;
  final double animalWeight;
  final String weightUnit;
  final DateTime calculatedAt;
  final String calculatedBy;

  DrugCalculation({
    required this.id,
    required this.drugId,
    required this.calculationType,
    required this.inputs,
    required this.results,
    required this.animalSpecies,
    required this.animalWeight,
    required this.weightUnit,
    required this.calculatedAt,
    required this.calculatedBy,
  });

  factory DrugCalculation.fromMap(Map<String, dynamic> map) {
    return DrugCalculation(
      id: map['id'] ?? '',
      drugId: map['drugId'] ?? '',
      calculationType: map['calculationType'] ?? '',
      inputs: Map<String, dynamic>.from(map['inputs'] ?? {}),
      results: Map<String, dynamic>.from(map['results'] ?? {}),
      animalSpecies: map['animalSpecies'] ?? '',
      animalWeight: (map['animalWeight'] ?? 0.0).toDouble(),
      weightUnit: map['weightUnit'] ?? 'kg',
      calculatedAt: DateTime.fromMillisecondsSinceEpoch(map['calculatedAt'] ?? 0),
      calculatedBy: map['calculatedBy'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'drugId': drugId,
      'calculationType': calculationType,
      'inputs': inputs,
      'results': results,
      'animalSpecies': animalSpecies,
      'animalWeight': animalWeight,
      'weightUnit': weightUnit,
      'calculatedAt': calculatedAt.millisecondsSinceEpoch,
      'calculatedBy': calculatedBy,
    };
  }
}