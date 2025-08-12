import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// Health Records Model for comprehensive animal health tracking
class HealthRecord {
  final String id;
  final String animalId;
  final HealthRecordType type;
  final String title;
  final String description;
  final DateTime date;
  final String? veterinarian;
  final String? medication;
  final double? cost;
  final String? notes;
  final List<String> attachments; // Photo/document URLs
  final HealthRecordStatus status;
  final DateTime? nextDueDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  HealthRecord({
    required this.id,
    required this.animalId,
    required this.type,
    required this.title,
    required this.description,
    required this.date,
    this.veterinarian,
    this.medication,
    this.cost,
    this.notes,
    this.attachments = const [],
    required this.status,
    this.nextDueDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory HealthRecord.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return HealthRecord(
      id: doc.id,
      animalId: data['animalId'] ?? '',
      type: HealthRecordType.values.firstWhere(
        (t) => t.name == data['type'],
        orElse: () => HealthRecordType.general,
      ),
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      veterinarian: data['veterinarian'],
      medication: data['medication'],
      cost: data['cost']?.toDouble(),
      notes: data['notes'],
      attachments: List<String>.from(data['attachments'] ?? []),
      status: HealthRecordStatus.values.firstWhere(
        (s) => s.name == data['status'],
        orElse: () => HealthRecordStatus.completed,
      ),
      nextDueDate: data['nextDueDate'] != null
          ? (data['nextDueDate'] as Timestamp).toDate()
          : null,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'animalId': animalId,
      'type': type.name,
      'title': title,
      'description': description,
      'date': Timestamp.fromDate(date),
      'veterinarian': veterinarian,
      'medication': medication,
      'cost': cost,
      'notes': notes,
      'attachments': attachments,
      'status': status.name,
      'nextDueDate': nextDueDate != null ? Timestamp.fromDate(nextDueDate!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  HealthRecord copyWith({
    String? title,
    String? description,
    DateTime? date,
    String? veterinarian,
    String? medication,
    double? cost,
    String? notes,
    List<String>? attachments,
    HealthRecordStatus? status,
    DateTime? nextDueDate,
    DateTime? updatedAt,
  }) {
    return HealthRecord(
      id: id,
      animalId: animalId,
      type: type,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      veterinarian: veterinarian ?? this.veterinarian,
      medication: medication ?? this.medication,
      cost: cost ?? this.cost,
      notes: notes ?? this.notes,
      attachments: attachments ?? this.attachments,
      status: status ?? this.status,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  String get typeIcon => type.icon;
  Color get typeColor => type.color;
  String get statusIcon => status.icon;
  Color get statusColor => status.color;
}

enum HealthRecordType {
  vaccination,
  deworming,
  treatment,
  checkup,
  surgery,
  illness,
  injury,
  medication,
  general,
}

extension HealthRecordTypeExtension on HealthRecordType {
  String get displayName {
    switch (this) {
      case HealthRecordType.vaccination:
        return 'Vaccination';
      case HealthRecordType.deworming:
        return 'Deworming';
      case HealthRecordType.treatment:
        return 'Treatment';
      case HealthRecordType.checkup:
        return 'Health Checkup';
      case HealthRecordType.surgery:
        return 'Surgery';
      case HealthRecordType.illness:
        return 'Illness';
      case HealthRecordType.injury:
        return 'Injury';
      case HealthRecordType.medication:
        return 'Medication';
      case HealthRecordType.general:
        return 'General';
    }
  }

  String get icon {
    switch (this) {
      case HealthRecordType.vaccination:
        return '💉';
      case HealthRecordType.deworming:
        return '🪱';
      case HealthRecordType.treatment:
        return '🩺';
      case HealthRecordType.checkup:
        return '🔍';
      case HealthRecordType.surgery:
        return '⚕️';
      case HealthRecordType.illness:
        return '🤒';
      case HealthRecordType.injury:
        return '🩹';
      case HealthRecordType.medication:
        return '💊';
      case HealthRecordType.general:
        return '📋';
    }
  }

  Color get color {
    switch (this) {
      case HealthRecordType.vaccination:
        return const Color(0xFF4CAF50);
      case HealthRecordType.deworming:
        return const Color(0xFFFF9800);
      case HealthRecordType.treatment:
        return const Color(0xFF2196F3);
      case HealthRecordType.checkup:
        return const Color(0xFF9C27B0);
      case HealthRecordType.surgery:
        return const Color(0xFFF44336);
      case HealthRecordType.illness:
        return const Color(0xFFE91E63);
      case HealthRecordType.injury:
        return const Color(0xFF795548);
      case HealthRecordType.medication:
        return const Color(0xFF00BCD4);
      case HealthRecordType.general:
        return const Color(0xFF607D8B);
    }
  }
}

enum HealthRecordStatus {
  scheduled,
  inProgress,
  completed,
  cancelled,
  overdue,
}

extension HealthRecordStatusExtension on HealthRecordStatus {
  String get displayName {
    switch (this) {
      case HealthRecordStatus.scheduled:
        return 'Scheduled';
      case HealthRecordStatus.inProgress:
        return 'In Progress';
      case HealthRecordStatus.completed:
        return 'Completed';
      case HealthRecordStatus.cancelled:
        return 'Cancelled';
      case HealthRecordStatus.overdue:
        return 'Overdue';
    }
  }

  String get icon {
    switch (this) {
      case HealthRecordStatus.scheduled:
        return '⏰';
      case HealthRecordStatus.inProgress:
        return '🔄';
      case HealthRecordStatus.completed:
        return '✅';
      case HealthRecordStatus.cancelled:
        return '❌';
      case HealthRecordStatus.overdue:
        return '🚨';
    }
  }

  Color get color {
    switch (this) {
      case HealthRecordStatus.scheduled:
        return const Color(0xFF2196F3);
      case HealthRecordStatus.inProgress:
        return const Color(0xFFFF9800);
      case HealthRecordStatus.completed:
        return const Color(0xFF4CAF50);
      case HealthRecordStatus.cancelled:
        return const Color(0xFF757575);
      case HealthRecordStatus.overdue:
        return const Color(0xFFF44336);
    }
  }
}

// Deworming Schedule Model
class DewormingSchedule {
  final String id;
  final String animalId;
  final DateTime lastDeworming;
  final DateTime nextDueDate;
  final String medicationUsed;
  final double? weight; // Animal weight at time of deworming
  final String? notes;
  final bool isCompleted;
  final DateTime createdAt;

  DewormingSchedule({
    required this.id,
    required this.animalId,
    required this.lastDeworming,
    required this.nextDueDate,
    required this.medicationUsed,
    this.weight,
    this.notes,
    this.isCompleted = false,
    required this.createdAt,
  });

  factory DewormingSchedule.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return DewormingSchedule(
      id: doc.id,
      animalId: data['animalId'] ?? '',
      lastDeworming: (data['lastDeworming'] as Timestamp).toDate(),
      nextDueDate: (data['nextDueDate'] as Timestamp).toDate(),
      medicationUsed: data['medicationUsed'] ?? '',
      weight: data['weight']?.toDouble(),
      notes: data['notes'],
      isCompleted: data['isCompleted'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'animalId': animalId,
      'lastDeworming': Timestamp.fromDate(lastDeworming),
      'nextDueDate': Timestamp.fromDate(nextDueDate),
      'medicationUsed': medicationUsed,
      'weight': weight,
      'notes': notes,
      'isCompleted': isCompleted,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  bool get isOverdue => DateTime.now().isAfter(nextDueDate) && !isCompleted;
  int get daysUntilDue => nextDueDate.difference(DateTime.now()).inDays;
}

// Treatment Plan Model
class TreatmentPlan {
  final String id;
  final String animalId;
  final String condition;
  final String treatment;
  final DateTime startDate;
  final DateTime? endDate;
  final List<String> medications;
  final String? veterinarian;
  final List<String> instructions;
  final TreatmentStatus status;
  final String? notes;
  final DateTime createdAt;

  TreatmentPlan({
    required this.id,
    required this.animalId,
    required this.condition,
    required this.treatment,
    required this.startDate,
    this.endDate,
    this.medications = const [],
    this.veterinarian,
    this.instructions = const [],
    required this.status,
    this.notes,
    required this.createdAt,
  });

  factory TreatmentPlan.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return TreatmentPlan(
      id: doc.id,
      animalId: data['animalId'] ?? '',
      condition: data['condition'] ?? '',
      treatment: data['treatment'] ?? '',
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: data['endDate'] != null
          ? (data['endDate'] as Timestamp).toDate()
          : null,
      medications: List<String>.from(data['medications'] ?? []),
      veterinarian: data['veterinarian'],
      instructions: List<String>.from(data['instructions'] ?? []),
      status: TreatmentStatus.values.firstWhere(
        (s) => s.name == data['status'],
        orElse: () => TreatmentStatus.active,
      ),
      notes: data['notes'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'animalId': animalId,
      'condition': condition,
      'treatment': treatment,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'medications': medications,
      'veterinarian': veterinarian,
      'instructions': instructions,
      'status': status.name,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  String get statusIcon => status.icon;
  Color get statusColor => status.color;
}

enum TreatmentStatus {
  scheduled,
  active,
  completed,
  cancelled,
  onHold,
}

extension TreatmentStatusExtension on TreatmentStatus {
  String get displayName {
    switch (this) {
      case TreatmentStatus.scheduled:
        return 'Scheduled';
      case TreatmentStatus.active:
        return 'Active';
      case TreatmentStatus.completed:
        return 'Completed';
      case TreatmentStatus.cancelled:
        return 'Cancelled';
      case TreatmentStatus.onHold:
        return 'On Hold';
    }
  }

  String get icon {
    switch (this) {
      case TreatmentStatus.scheduled:
        return '📅';
      case TreatmentStatus.active:
        return '🏃';
      case TreatmentStatus.completed:
        return '✅';
      case TreatmentStatus.cancelled:
        return '❌';
      case TreatmentStatus.onHold:
        return '⏸️';
    }
  }

  Color get color {
    switch (this) {
      case TreatmentStatus.scheduled:
        return const Color(0xFF2196F3);
      case TreatmentStatus.active:
        return const Color(0xFF4CAF50);
      case TreatmentStatus.completed:
        return const Color(0xFF4CAF50);
      case TreatmentStatus.cancelled:
        return const Color(0xFF757575);
      case TreatmentStatus.onHold:
        return const Color(0xFFFF9800);
    }
  }
}

// Health Issues Model for tracking current and past health problems
class HealthIssue {
  final String id;
  final String animalId;
  final String issue;
  final String description;
  final HealthIssueSeverity severity;
  final DateTime detectedDate;
  final DateTime? resolvedDate;
  final List<String> symptoms;
  final String? diagnosis;
  final String? treatment;
  final String? veterinarian;
  final List<String> medications;
  final HealthIssueStatus status;
  final String? notes;
  final DateTime createdAt;

  HealthIssue({
    required this.id,
    required this.animalId,
    required this.issue,
    required this.description,
    required this.severity,
    required this.detectedDate,
    this.resolvedDate,
    this.symptoms = const [],
    this.diagnosis,
    this.treatment,
    this.veterinarian,
    this.medications = const [],
    required this.status,
    this.notes,
    required this.createdAt,
  });

  factory HealthIssue.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return HealthIssue(
      id: doc.id,
      animalId: data['animalId'] ?? '',
      issue: data['issue'] ?? '',
      description: data['description'] ?? '',
      severity: HealthIssueSeverity.values.firstWhere(
        (s) => s.name == data['severity'],
        orElse: () => HealthIssueSeverity.moderate,
      ),
      detectedDate: (data['detectedDate'] as Timestamp).toDate(),
      resolvedDate: data['resolvedDate'] != null
          ? (data['resolvedDate'] as Timestamp).toDate()
          : null,
      symptoms: List<String>.from(data['symptoms'] ?? []),
      diagnosis: data['diagnosis'],
      treatment: data['treatment'],
      veterinarian: data['veterinarian'],
      medications: List<String>.from(data['medications'] ?? []),
      status: HealthIssueStatus.values.firstWhere(
        (s) => s.name == data['status'],
        orElse: () => HealthIssueStatus.active,
      ),
      notes: data['notes'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'animalId': animalId,
      'issue': issue,
      'description': description,
      'severity': severity.name,
      'detectedDate': Timestamp.fromDate(detectedDate),
      'resolvedDate': resolvedDate != null ? Timestamp.fromDate(resolvedDate!) : null,
      'symptoms': symptoms,
      'diagnosis': diagnosis,
      'treatment': treatment,
      'veterinarian': veterinarian,
      'medications': medications,
      'status': status.name,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  String get severityIcon => severity.icon;
  Color get severityColor => severity.color;
  String get statusIcon => status.icon;
  Color get statusColor => status.color;
}

enum HealthIssueSeverity {
  low,
  moderate,
  high,
  critical,
}

extension HealthIssueSeverityExtension on HealthIssueSeverity {
  String get displayName {
    switch (this) {
      case HealthIssueSeverity.low:
        return 'Low';
      case HealthIssueSeverity.moderate:
        return 'Moderate';
      case HealthIssueSeverity.high:
        return 'High';
      case HealthIssueSeverity.critical:
        return 'Critical';
    }
  }

  String get icon {
    switch (this) {
      case HealthIssueSeverity.low:
        return '🟢';
      case HealthIssueSeverity.moderate:
        return '🟡';
      case HealthIssueSeverity.high:
        return '🟠';
      case HealthIssueSeverity.critical:
        return '🔴';
    }
  }

  Color get color {
    switch (this) {
      case HealthIssueSeverity.low:
        return const Color(0xFF4CAF50);
      case HealthIssueSeverity.moderate:
        return const Color(0xFFFF9800);
      case HealthIssueSeverity.high:
        return const Color(0xFFFF5722);
      case HealthIssueSeverity.critical:
        return const Color(0xFFF44336);
    }
  }
}

enum HealthIssueStatus {
  active,
  monitoring,
  resolved,
  chronic,
}

extension HealthIssueStatusExtension on HealthIssueStatus {
  String get displayName {
    switch (this) {
      case HealthIssueStatus.active:
        return 'Active';
      case HealthIssueStatus.monitoring:
        return 'Monitoring';
      case HealthIssueStatus.resolved:
        return 'Resolved';
      case HealthIssueStatus.chronic:
        return 'Chronic';
    }
  }

  String get icon {
    switch (this) {
      case HealthIssueStatus.active:
        return '🚨';
      case HealthIssueStatus.monitoring:
        return '👁️';
      case HealthIssueStatus.resolved:
        return '✅';
      case HealthIssueStatus.chronic:
        return '🔄';
    }
  }

  Color get color {
    switch (this) {
      case HealthIssueStatus.active:
        return const Color(0xFFF44336);
      case HealthIssueStatus.monitoring:
        return const Color(0xFFFF9800);
      case HealthIssueStatus.resolved:
        return const Color(0xFF4CAF50);
      case HealthIssueStatus.chronic:
        return const Color(0xFF9C27B0);
    }
  }
}