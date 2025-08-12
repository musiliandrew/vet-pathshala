import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// Heat Cycle Record Model
class HeatCycleRecord {
  final String id;
  final String animalId;
  final DateTime detectedDate;
  final DateTime? matingDate;
  final HeatCycleIntensity intensity;
  final List<String> symptoms;
  final HeatCycleResult result;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  HeatCycleRecord({
    required this.id,
    required this.animalId,
    required this.detectedDate,
    this.matingDate,
    required this.intensity,
    this.symptoms = const [],
    required this.result,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory HeatCycleRecord.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return HeatCycleRecord(
      id: doc.id,
      animalId: data['animalId'] ?? '',
      detectedDate: (data['detectedDate'] as Timestamp).toDate(),
      matingDate: data['matingDate'] != null
          ? (data['matingDate'] as Timestamp).toDate()
          : null,
      intensity: HeatCycleIntensity.values.firstWhere(
        (i) => i.name == data['intensity'],
        orElse: () => HeatCycleIntensity.moderate,
      ),
      symptoms: List<String>.from(data['symptoms'] ?? []),
      result: HeatCycleResult.values.firstWhere(
        (r) => r.name == data['result'],
        orElse: () => HeatCycleResult.pending,
      ),
      notes: data['notes'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'animalId': animalId,
      'detectedDate': Timestamp.fromDate(detectedDate),
      'matingDate': matingDate != null ? Timestamp.fromDate(matingDate!) : null,
      'intensity': intensity.name,
      'symptoms': symptoms,
      'result': result.name,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Calculate next expected heat cycle (typical cycle is 21 days)
  DateTime get nextExpectedHeat => detectedDate.add(const Duration(days: 21));
  
  // Check if cycle is overdue (allowing 3 days variance)
  bool get isOverdue => DateTime.now().isAfter(nextExpectedHeat.add(const Duration(days: 3)));
  
  // Days until next cycle
  int get daysUntilNextCycle => nextExpectedHeat.difference(DateTime.now()).inDays;

  String get intensityIcon => intensity.icon;
  Color get intensityColor => intensity.color;
  String get resultIcon => result.icon;
  Color get resultColor => result.color;
}

enum HeatCycleIntensity {
  mild,
  moderate,
  strong,
}

extension HeatCycleIntensityExtension on HeatCycleIntensity {
  String get displayName {
    switch (this) {
      case HeatCycleIntensity.mild:
        return 'Mild';
      case HeatCycleIntensity.moderate:
        return 'Moderate';
      case HeatCycleIntensity.strong:
        return 'Strong';
    }
  }

  String get icon {
    switch (this) {
      case HeatCycleIntensity.mild:
        return '🟡';
      case HeatCycleIntensity.moderate:
        return '🟠';
      case HeatCycleIntensity.strong:
        return '🔴';
    }
  }

  Color get color {
    switch (this) {
      case HeatCycleIntensity.mild:
        return const Color(0xFFFFC107);
      case HeatCycleIntensity.moderate:
        return const Color(0xFFFF9800);
      case HeatCycleIntensity.strong:
        return const Color(0xFFF44336);
    }
  }
}

enum HeatCycleResult {
  pending,
  bred,
  missed,
  notBred,
}

extension HeatCycleResultExtension on HeatCycleResult {
  String get displayName {
    switch (this) {
      case HeatCycleResult.pending:
        return 'Pending';
      case HeatCycleResult.bred:
        return 'Bred';
      case HeatCycleResult.missed:
        return 'Missed';
      case HeatCycleResult.notBred:
        return 'Not Bred';
    }
  }

  String get icon {
    switch (this) {
      case HeatCycleResult.pending:
        return '⏳';
      case HeatCycleResult.bred:
        return '✅';
      case HeatCycleResult.missed:
        return '⚠️';
      case HeatCycleResult.notBred:
        return '❌';
    }
  }

  Color get color {
    switch (this) {
      case HeatCycleResult.pending:
        return const Color(0xFF2196F3);
      case HeatCycleResult.bred:
        return const Color(0xFF4CAF50);
      case HeatCycleResult.missed:
        return const Color(0xFFFF9800);
      case HeatCycleResult.notBred:
        return const Color(0xFF757575);
    }
  }
}

// Artificial Insemination Record Model
class AIRecord {
  final String id;
  final String animalId;
  final DateTime aiDate;
  final String bullId;
  final String bullBreed;
  final String? semenBatch;
  final String technician;
  final AIMethod method;
  final double? cost;
  final AIResult result;
  final DateTime? pregnancyCheckDate;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  AIRecord({
    required this.id,
    required this.animalId,
    required this.aiDate,
    required this.bullId,
    required this.bullBreed,
    this.semenBatch,
    required this.technician,
    required this.method,
    this.cost,
    required this.result,
    this.pregnancyCheckDate,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AIRecord.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return AIRecord(
      id: doc.id,
      animalId: data['animalId'] ?? '',
      aiDate: (data['aiDate'] as Timestamp).toDate(),
      bullId: data['bullId'] ?? '',
      bullBreed: data['bullBreed'] ?? '',
      semenBatch: data['semenBatch'],
      technician: data['technician'] ?? '',
      method: AIMethod.values.firstWhere(
        (m) => m.name == data['method'],
        orElse: () => AIMethod.cervical,
      ),
      cost: data['cost']?.toDouble(),
      result: AIResult.values.firstWhere(
        (r) => r.name == data['result'],
        orElse: () => AIResult.pending,
      ),
      pregnancyCheckDate: data['pregnancyCheckDate'] != null
          ? (data['pregnancyCheckDate'] as Timestamp).toDate()
          : null,
      notes: data['notes'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'animalId': animalId,
      'aiDate': Timestamp.fromDate(aiDate),
      'bullId': bullId,
      'bullBreed': bullBreed,
      'semenBatch': semenBatch,
      'technician': technician,
      'method': method.name,
      'cost': cost,
      'result': result.name,
      'pregnancyCheckDate': pregnancyCheckDate != null
          ? Timestamp.fromDate(pregnancyCheckDate!)
          : null,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Expected pregnancy check date (typically 30-60 days after AI)
  DateTime get expectedPregnancyCheck => aiDate.add(const Duration(days: 35));
  
  bool get isPregnancyCheckDue => 
      pregnancyCheckDate == null && 
      DateTime.now().isAfter(expectedPregnancyCheck);

  String get methodIcon => method.icon;
  String get resultIcon => result.icon;
  Color get resultColor => result.color;
}

enum AIMethod {
  cervical,
  intrauterine,
  embryoTransfer,
}

extension AIMethodExtension on AIMethod {
  String get displayName {
    switch (this) {
      case AIMethod.cervical:
        return 'Cervical';
      case AIMethod.intrauterine:
        return 'Intrauterine';
      case AIMethod.embryoTransfer:
        return 'Embryo Transfer';
    }
  }

  String get icon {
    switch (this) {
      case AIMethod.cervical:
        return '🎯';
      case AIMethod.intrauterine:
        return '🔬';
      case AIMethod.embryoTransfer:
        return '🧬';
    }
  }
}

enum AIResult {
  pending,
  conceived,
  notConceived,
  repeatBreeding,
}

extension AIResultExtension on AIResult {
  String get displayName {
    switch (this) {
      case AIResult.pending:
        return 'Pending Check';
      case AIResult.conceived:
        return 'Conceived';
      case AIResult.notConceived:
        return 'Not Conceived';
      case AIResult.repeatBreeding:
        return 'Repeat Breeding';
    }
  }

  String get icon {
    switch (this) {
      case AIResult.pending:
        return '⏳';
      case AIResult.conceived:
        return '🤰';
      case AIResult.notConceived:
        return '❌';
      case AIResult.repeatBreeding:
        return '🔄';
    }
  }

  Color get color {
    switch (this) {
      case AIResult.pending:
        return const Color(0xFF2196F3);
      case AIResult.conceived:
        return const Color(0xFF4CAF50);
      case AIResult.notConceived:
        return const Color(0xFFF44336);
      case AIResult.repeatBreeding:
        return const Color(0xFFFF9800);
    }
  }
}

// Pregnancy Record Model
class PregnancyRecord {
  final String id;
  final String animalId;
  final DateTime conceptionDate;
  final DateTime expectedCalvingDate;
  final DateTime? actualCalvingDate;
  final String? sireId;
  final PregnancyStatus status;
  final List<PregnancyCheck> checks;
  final String? veterinarian;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  PregnancyRecord({
    required this.id,
    required this.animalId,
    required this.conceptionDate,
    required this.expectedCalvingDate,
    this.actualCalvingDate,
    this.sireId,
    required this.status,
    this.checks = const [],
    this.veterinarian,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PregnancyRecord.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return PregnancyRecord(
      id: doc.id,
      animalId: data['animalId'] ?? '',
      conceptionDate: (data['conceptionDate'] as Timestamp).toDate(),
      expectedCalvingDate: (data['expectedCalvingDate'] as Timestamp).toDate(),
      actualCalvingDate: data['actualCalvingDate'] != null
          ? (data['actualCalvingDate'] as Timestamp).toDate()
          : null,
      sireId: data['sireId'],
      status: PregnancyStatus.values.firstWhere(
        (s) => s.name == data['status'],
        orElse: () => PregnancyStatus.ongoing,
      ),
      checks: (data['checks'] as List<dynamic>? ?? [])
          .map((c) => PregnancyCheck.fromMap(c))
          .toList(),
      veterinarian: data['veterinarian'],
      notes: data['notes'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'animalId': animalId,
      'conceptionDate': Timestamp.fromDate(conceptionDate),
      'expectedCalvingDate': Timestamp.fromDate(expectedCalvingDate),
      'actualCalvingDate': actualCalvingDate != null
          ? Timestamp.fromDate(actualCalvingDate!)
          : null,
      'sireId': sireId,
      'status': status.name,
      'checks': checks.map((c) => c.toMap()).toList(),
      'veterinarian': veterinarian,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Calculate current pregnancy stage
  int get currentDayOfPregnancy => DateTime.now().difference(conceptionDate).inDays;
  
  // Calculate current month of pregnancy
  int get currentMonthOfPregnancy => (currentDayOfPregnancy / 30).ceil();
  
  // Days until expected calving
  int get daysUntilCalving => expectedCalvingDate.difference(DateTime.now()).inDays;
  
  // Check if calving is overdue
  bool get isOverdue => DateTime.now().isAfter(expectedCalvingDate) && status == PregnancyStatus.ongoing;
  
  // Pregnancy progress percentage
  double get pregnancyProgress => (currentDayOfPregnancy / 280).clamp(0.0, 1.0); // 280 days = ~9 months

  String get statusIcon => status.icon;
  Color get statusColor => status.color;
}

enum PregnancyStatus {
  ongoing,
  completed,
  aborted,
  complications,
}

extension PregnancyStatusExtension on PregnancyStatus {
  String get displayName {
    switch (this) {
      case PregnancyStatus.ongoing:
        return 'Ongoing';
      case PregnancyStatus.completed:
        return 'Completed';
      case PregnancyStatus.aborted:
        return 'Aborted';
      case PregnancyStatus.complications:
        return 'Complications';
    }
  }

  String get icon {
    switch (this) {
      case PregnancyStatus.ongoing:
        return '🤰';
      case PregnancyStatus.completed:
        return '🍼';
      case PregnancyStatus.aborted:
        return '💔';
      case PregnancyStatus.complications:
        return '⚠️';
    }
  }

  Color get color {
    switch (this) {
      case PregnancyStatus.ongoing:
        return const Color(0xFF2196F3);
      case PregnancyStatus.completed:
        return const Color(0xFF4CAF50);
      case PregnancyStatus.aborted:
        return const Color(0xFFF44336);
      case PregnancyStatus.complications:
        return const Color(0xFFFF9800);
    }
  }
}

// Pregnancy Check Model
class PregnancyCheck {
  final DateTime checkDate;
  final int dayOfPregnancy;
  final PregnancyCheckResult result;
  final String? veterinarian;
  final String? notes;

  PregnancyCheck({
    required this.checkDate,
    required this.dayOfPregnancy,
    required this.result,
    this.veterinarian,
    this.notes,
  });

  factory PregnancyCheck.fromMap(Map<String, dynamic> map) {
    return PregnancyCheck(
      checkDate: (map['checkDate'] as Timestamp).toDate(),
      dayOfPregnancy: map['dayOfPregnancy'] ?? 0,
      result: PregnancyCheckResult.values.firstWhere(
        (r) => r.name == map['result'],
        orElse: () => PregnancyCheckResult.positive,
      ),
      veterinarian: map['veterinarian'],
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'checkDate': Timestamp.fromDate(checkDate),
      'dayOfPregnancy': dayOfPregnancy,
      'result': result.name,
      'veterinarian': veterinarian,
      'notes': notes,
    };
  }

  String get resultIcon => result.icon;
  Color get resultColor => result.color;
}

enum PregnancyCheckResult {
  positive,
  negative,
  uncertain,
}

extension PregnancyCheckResultExtension on PregnancyCheckResult {
  String get displayName {
    switch (this) {
      case PregnancyCheckResult.positive:
        return 'Positive';
      case PregnancyCheckResult.negative:
        return 'Negative';
      case PregnancyCheckResult.uncertain:
        return 'Uncertain';
    }
  }

  String get icon {
    switch (this) {
      case PregnancyCheckResult.positive:
        return '✅';
      case PregnancyCheckResult.negative:
        return '❌';
      case PregnancyCheckResult.uncertain:
        return '❓';
    }
  }

  Color get color {
    switch (this) {
      case PregnancyCheckResult.positive:
        return const Color(0xFF4CAF50);
      case PregnancyCheckResult.negative:
        return const Color(0xFFF44336);
      case PregnancyCheckResult.uncertain:
        return const Color(0xFFFF9800);
    }
  }
}

// Calving Record Model
class CalvingRecord {
  final String id;
  final String motherId;
  final DateTime calvingDate;
  final CalvingType type;
  final CalvingDifficulty difficulty;
  final List<CalfRecord> calves;
  final String? veterinarian;
  final String? complications;
  final double? cost;
  final String? notes;
  final DateTime createdAt;

  CalvingRecord({
    required this.id,
    required this.motherId,
    required this.calvingDate,
    required this.type,
    required this.difficulty,
    this.calves = const [],
    this.veterinarian,
    this.complications,
    this.cost,
    this.notes,
    required this.createdAt,
  });

  factory CalvingRecord.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return CalvingRecord(
      id: doc.id,
      motherId: data['motherId'] ?? '',
      calvingDate: (data['calvingDate'] as Timestamp).toDate(),
      type: CalvingType.values.firstWhere(
        (t) => t.name == data['type'],
        orElse: () => CalvingType.normal,
      ),
      difficulty: CalvingDifficulty.values.firstWhere(
        (d) => d.name == data['difficulty'],
        orElse: () => CalvingDifficulty.easy,
      ),
      calves: (data['calves'] as List<dynamic>? ?? [])
          .map((c) => CalfRecord.fromMap(c))
          .toList(),
      veterinarian: data['veterinarian'],
      complications: data['complications'],
      cost: data['cost']?.toDouble(),
      notes: data['notes'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'motherId': motherId,
      'calvingDate': Timestamp.fromDate(calvingDate),
      'type': type.name,
      'difficulty': difficulty.name,
      'calves': calves.map((c) => c.toMap()).toList(),
      'veterinarian': veterinarian,
      'complications': complications,
      'cost': cost,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  String get typeIcon => type.icon;
  String get difficultyIcon => difficulty.icon;
  Color get difficultyColor => difficulty.color;
}

enum CalvingType {
  normal,
  twins,
  cesarean,
  assisted,
}

extension CalvingTypeExtension on CalvingType {
  String get displayName {
    switch (this) {
      case CalvingType.normal:
        return 'Normal';
      case CalvingType.twins:
        return 'Twins';
      case CalvingType.cesarean:
        return 'Cesarean';
      case CalvingType.assisted:
        return 'Assisted';
    }
  }

  String get icon {
    switch (this) {
      case CalvingType.normal:
        return '🍼';
      case CalvingType.twins:
        return '👥';
      case CalvingType.cesarean:
        return '⚕️';
      case CalvingType.assisted:
        return '🤝';
    }
  }
}

enum CalvingDifficulty {
  easy,
  moderate,
  difficult,
  emergency,
}

extension CalvingDifficultyExtension on CalvingDifficulty {
  String get displayName {
    switch (this) {
      case CalvingDifficulty.easy:
        return 'Easy';
      case CalvingDifficulty.moderate:
        return 'Moderate';
      case CalvingDifficulty.difficult:
        return 'Difficult';
      case CalvingDifficulty.emergency:
        return 'Emergency';
    }
  }

  String get icon {
    switch (this) {
      case CalvingDifficulty.easy:
        return '🟢';
      case CalvingDifficulty.moderate:
        return '🟡';
      case CalvingDifficulty.difficult:
        return '🟠';
      case CalvingDifficulty.emergency:
        return '🔴';
    }
  }

  Color get color {
    switch (this) {
      case CalvingDifficulty.easy:
        return const Color(0xFF4CAF50);
      case CalvingDifficulty.moderate:
        return const Color(0xFFFF9800);
      case CalvingDifficulty.difficult:
        return const Color(0xFFFF5722);
      case CalvingDifficulty.emergency:
        return const Color(0xFFF44336);
    }
  }
}

// Calf Record Model
class CalfRecord {
  final String id;
  final String? tagId;
  final CalfGender gender;
  final double? birthWeight;
  final CalfHealth health;
  final bool isAlive;
  final String? notes;

  CalfRecord({
    required this.id,
    this.tagId,
    required this.gender,
    this.birthWeight,
    required this.health,
    this.isAlive = true,
    this.notes,
  });

  factory CalfRecord.fromMap(Map<String, dynamic> map) {
    return CalfRecord(
      id: map['id'] ?? '',
      tagId: map['tagId'],
      gender: CalfGender.values.firstWhere(
        (g) => g.name == map['gender'],
        orElse: () => CalfGender.male,
      ),
      birthWeight: map['birthWeight']?.toDouble(),
      health: CalfHealth.values.firstWhere(
        (h) => h.name == map['health'],
        orElse: () => CalfHealth.healthy,
      ),
      isAlive: map['isAlive'] ?? true,
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tagId': tagId,
      'gender': gender.name,
      'birthWeight': birthWeight,
      'health': health.name,
      'isAlive': isAlive,
      'notes': notes,
    };
  }

  String get genderIcon => gender.icon;
  String get healthIcon => health.icon;
  Color get healthColor => health.color;
}

enum CalfGender {
  male,
  female,
}

extension CalfGenderExtension on CalfGender {
  String get displayName {
    switch (this) {
      case CalfGender.male:
        return 'Male';
      case CalfGender.female:
        return 'Female';
    }
  }

  String get icon {
    switch (this) {
      case CalfGender.male:
        return '♂️';
      case CalfGender.female:
        return '♀️';
    }
  }
}

enum CalfHealth {
  healthy,
  weak,
  sick,
  deceased,
}

extension CalfHealthExtension on CalfHealth {
  String get displayName {
    switch (this) {
      case CalfHealth.healthy:
        return 'Healthy';
      case CalfHealth.weak:
        return 'Weak';
      case CalfHealth.sick:
        return 'Sick';
      case CalfHealth.deceased:
        return 'Deceased';
    }
  }

  String get icon {
    switch (this) {
      case CalfHealth.healthy:
        return '💚';
      case CalfHealth.weak:
        return '💛';
      case CalfHealth.sick:
        return '🧡';
      case CalfHealth.deceased:
        return '💔';
    }
  }

  Color get color {
    switch (this) {
      case CalfHealth.healthy:
        return const Color(0xFF4CAF50);
      case CalfHealth.weak:
        return const Color(0xFFFF9800);
      case CalfHealth.sick:
        return const Color(0xFFFF5722);
      case CalfHealth.deceased:
        return const Color(0xFF424242);
    }
  }
}