import 'package:cloud_firestore/cloud_firestore.dart';

class AnimalModel {
  final String id;
  final String name;
  final String type; // cow, buffalo, goat, sheep, dog
  final String tagId;
  final DateTime dateOfBirth;
  final String gender;
  final String? dam; // Mother
  final String? sire; // Father
  final String origin; // home-born, purchased
  final DateTime? purchaseDate;
  final double? purchasePrice;
  final String breed;
  final String? specialMarks;
  final List<String> customTags;
  final List<VaccinationRecord> vaccinations;
  final String? notes;
  final String? photoUrl;
  final String qrCode;
  final String ownerId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final AnimalStatus status;

  AnimalModel({
    required this.id,
    required this.name,
    required this.type,
    required this.tagId,
    required this.dateOfBirth,
    required this.gender,
    this.dam,
    this.sire,
    required this.origin,
    this.purchaseDate,
    this.purchasePrice,
    required this.breed,
    this.specialMarks,
    required this.customTags,
    required this.vaccinations,
    this.notes,
    this.photoUrl,
    required this.qrCode,
    required this.ownerId,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
  });

  factory AnimalModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return AnimalModel(
      id: doc.id,
      name: data['name'] ?? '',
      type: data['type'] ?? '',
      tagId: data['tagId'] ?? '',
      dateOfBirth: (data['dateOfBirth'] as Timestamp).toDate(),
      gender: data['gender'] ?? '',
      dam: data['dam'],
      sire: data['sire'],
      origin: data['origin'] ?? '',
      purchaseDate: data['purchaseDate'] != null 
          ? (data['purchaseDate'] as Timestamp).toDate() 
          : null,
      purchasePrice: data['purchasePrice']?.toDouble(),
      breed: data['breed'] ?? '',
      specialMarks: data['specialMarks'],
      customTags: List<String>.from(data['customTags'] ?? []),
      vaccinations: (data['vaccinations'] as List<dynamic>? ?? [])
          .map((v) => VaccinationRecord.fromMap(v))
          .toList(),
      notes: data['notes'],
      photoUrl: data['photoUrl'],
      qrCode: data['qrCode'] ?? '',
      ownerId: data['ownerId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      status: AnimalStatus.values.firstWhere(
        (s) => s.name == data['status'],
        orElse: () => AnimalStatus.healthy,
      ),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'type': type,
      'tagId': tagId,
      'dateOfBirth': Timestamp.fromDate(dateOfBirth),
      'gender': gender,
      'dam': dam,
      'sire': sire,
      'origin': origin,
      'purchaseDate': purchaseDate != null ? Timestamp.fromDate(purchaseDate!) : null,
      'purchasePrice': purchasePrice,
      'breed': breed,
      'specialMarks': specialMarks,
      'customTags': customTags,
      'vaccinations': vaccinations.map((v) => v.toMap()).toList(),
      'notes': notes,
      'photoUrl': photoUrl,
      'qrCode': qrCode,
      'ownerId': ownerId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'status': status.name,
    };
  }

  AnimalModel copyWith({
    String? name,
    String? type,
    String? tagId,
    DateTime? dateOfBirth,
    String? gender,
    String? dam,
    String? sire,
    String? origin,
    DateTime? purchaseDate,
    double? purchasePrice,
    String? breed,
    String? specialMarks,
    List<String>? customTags,
    List<VaccinationRecord>? vaccinations,
    String? notes,
    String? photoUrl,
    String? qrCode,
    DateTime? updatedAt,
    AnimalStatus? status,
  }) {
    return AnimalModel(
      id: id,
      name: name ?? this.name,
      type: type ?? this.type,
      tagId: tagId ?? this.tagId,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      dam: dam ?? this.dam,
      sire: sire ?? this.sire,
      origin: origin ?? this.origin,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      breed: breed ?? this.breed,
      specialMarks: specialMarks ?? this.specialMarks,
      customTags: customTags ?? this.customTags,
      vaccinations: vaccinations ?? this.vaccinations,
      notes: notes ?? this.notes,
      photoUrl: photoUrl ?? this.photoUrl,
      qrCode: qrCode ?? this.qrCode,
      ownerId: ownerId,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      status: status ?? this.status,
    );
  }

  String get ageString {
    final now = DateTime.now();
    final difference = now.difference(dateOfBirth);
    final years = difference.inDays ~/ 365;
    final months = (difference.inDays % 365) ~/ 30;
    
    if (years > 0) {
      return '$years year${years > 1 ? 's' : ''}';
    } else if (months > 0) {
      return '$months month${months > 1 ? 's' : ''}';
    } else {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''}';
    }
  }

  String get typeEmoji {
    switch (type.toLowerCase()) {
      case 'cow':
        return '🐄';
      case 'buffalo':
        return '🐃';
      case 'goat':
        return '🐐';
      case 'sheep':
        return '🐑';
      case 'dog':
        return '🐕';
      default:
        return '🐾';
    }
  }
}

class VaccinationRecord {
  final String vaccineName;
  final DateTime date;
  final String? notes;
  final String? veterinarian;

  VaccinationRecord({
    required this.vaccineName,
    required this.date,
    this.notes,
    this.veterinarian,
  });

  factory VaccinationRecord.fromMap(Map<String, dynamic> map) {
    return VaccinationRecord(
      vaccineName: map['vaccineName'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      notes: map['notes'],
      veterinarian: map['veterinarian'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'vaccineName': vaccineName,
      'date': Timestamp.fromDate(date),
      'notes': notes,
      'veterinarian': veterinarian,
    };
  }
}

enum AnimalStatus {
  healthy,
  monitoring,
  urgent,
  sick,
  pregnant,
  recovered,
}

extension AnimalStatusExtension on AnimalStatus {
  String get displayName {
    switch (this) {
      case AnimalStatus.healthy:
        return 'Healthy';
      case AnimalStatus.monitoring:
        return 'Monitoring';
      case AnimalStatus.urgent:
        return 'Urgent';
      case AnimalStatus.sick:
        return 'Sick';
      case AnimalStatus.pregnant:
        return 'Pregnant';
      case AnimalStatus.recovered:
        return 'Recovered';
    }
  }

  String get emoji {
    switch (this) {
      case AnimalStatus.healthy:
        return '🟢';
      case AnimalStatus.monitoring:
        return '🟡';
      case AnimalStatus.urgent:
        return '🔴';
      case AnimalStatus.sick:
        return '🔴';
      case AnimalStatus.pregnant:
        return '🤰';
      case AnimalStatus.recovered:
        return '💚';
    }
  }

  Color get color {
    switch (this) {
      case AnimalStatus.healthy:
        return const Color(0xFF4CAF50);
      case AnimalStatus.monitoring:
        return const Color(0xFFFF9800);
      case AnimalStatus.urgent:
      case AnimalStatus.sick:
        return const Color(0xFFF44336);
      case AnimalStatus.pregnant:
        return const Color(0xFF9C27B0);
      case AnimalStatus.recovered:
        return const Color(0xFF4CAF50);
    }
  }
}

class MilkProductionRecord {
  final String id;
  final String animalId;
  final DateTime date;
  final double morningMilk;
  final double eveningMilk;
  final String? remarks;
  final DateTime createdAt;

  MilkProductionRecord({
    required this.id,
    required this.animalId,
    required this.date,
    required this.morningMilk,
    required this.eveningMilk,
    this.remarks,
    required this.createdAt,
  });

  double get totalMilk => morningMilk + eveningMilk;

  factory MilkProductionRecord.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return MilkProductionRecord(
      id: doc.id,
      animalId: data['animalId'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      morningMilk: (data['morningMilk'] ?? 0.0).toDouble(),
      eveningMilk: (data['eveningMilk'] ?? 0.0).toDouble(),
      remarks: data['remarks'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'animalId': animalId,
      'date': Timestamp.fromDate(date),
      'morningMilk': morningMilk,
      'eveningMilk': eveningMilk,
      'remarks': remarks,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

class FarmAlert {
  final String id;
  final String animalId;
  final String title;
  final String description;
  final AlertType type;
  final AlertPriority priority;
  final DateTime dueDate;
  final bool isCompleted;
  final DateTime createdAt;

  FarmAlert({
    required this.id,
    required this.animalId,
    required this.title,
    required this.description,
    required this.type,
    required this.priority,
    required this.dueDate,
    required this.isCompleted,
    required this.createdAt,
  });

  factory FarmAlert.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return FarmAlert(
      id: doc.id,
      animalId: data['animalId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      type: AlertType.values.firstWhere(
        (t) => t.name == data['type'],
        orElse: () => AlertType.general,
      ),
      priority: AlertPriority.values.firstWhere(
        (p) => p.name == data['priority'],
        orElse: () => AlertPriority.medium,
      ),
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      isCompleted: data['isCompleted'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'animalId': animalId,
      'title': title,
      'description': description,
      'type': type.name,
      'priority': priority.name,
      'dueDate': Timestamp.fromDate(dueDate),
      'isCompleted': isCompleted,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

enum AlertType {
  vaccination,
  deworming,
  breeding,
  health,
  feeding,
  general,
}

enum AlertPriority {
  low,
  medium,
  high,
  urgent,
}

extension AlertPriorityExtension on AlertPriority {
  String get emoji {
    switch (this) {
      case AlertPriority.low:
        return '🟢';
      case AlertPriority.medium:
        return '🟡';
      case AlertPriority.high:
        return '🟠';
      case AlertPriority.urgent:
        return '🔴';
    }
  }

  Color get color {
    switch (this) {
      case AlertPriority.low:
        return const Color(0xFF4CAF50);
      case AlertPriority.medium:
        return const Color(0xFFFF9800);
      case AlertPriority.high:
        return const Color(0xFFFF5722);
      case AlertPriority.urgent:
        return const Color(0xFFF44336);
    }
  }
}