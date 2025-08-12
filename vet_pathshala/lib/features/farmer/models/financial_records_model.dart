import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// Financial Record Model
class FinancialRecord {
  final String id;
  final String animalId;
  final FinancialRecordType type;
  final double amount;
  final DateTime date;
  final String description;
  final String? category;
  final FinancialRecordStatus status;
  final String? receiptUrl;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  FinancialRecord({
    required this.id,
    required this.animalId,
    required this.type,
    required this.amount,
    required this.date,
    required this.description,
    this.category,
    required this.status,
    this.receiptUrl,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FinancialRecord.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return FinancialRecord(
      id: doc.id,
      animalId: data['animalId'] ?? '',
      type: FinancialRecordType.values.firstWhere(
        (t) => t.name == data['type'],
        orElse: () => FinancialRecordType.expense,
      ),
      amount: data['amount']?.toDouble() ?? 0.0,
      date: (data['date'] as Timestamp).toDate(),
      description: data['description'] ?? '',
      category: data['category'],
      status: FinancialRecordStatus.values.firstWhere(
        (s) => s.name == data['status'],
        orElse: () => FinancialRecordStatus.confirmed,
      ),
      receiptUrl: data['receiptUrl'],
      notes: data['notes'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'animalId': animalId,
      'type': type.name,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'description': description,
      'category': category,
      'status': status.name,
      'receiptUrl': receiptUrl,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  FinancialRecord copyWith({
    String? id,
    String? animalId,
    FinancialRecordType? type,
    double? amount,
    DateTime? date,
    String? description,
    String? category,
    FinancialRecordStatus? status,
    String? receiptUrl,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FinancialRecord(
      id: id ?? this.id,
      animalId: animalId ?? this.animalId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      description: description ?? this.description,
      category: category ?? this.category,
      status: status ?? this.status,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get typeIcon => type.icon;
  Color get typeColor => type.color;
  String get statusIcon => status.icon;
  Color get statusColor => status.color;
}

enum FinancialRecordType {
  income,
  expense,
}

extension FinancialRecordTypeExtension on FinancialRecordType {
  String get displayName {
    switch (this) {
      case FinancialRecordType.income:
        return 'Income';
      case FinancialRecordType.expense:
        return 'Expense';
    }
  }

  String get icon {
    switch (this) {
      case FinancialRecordType.income:
        return '💰';
      case FinancialRecordType.expense:
        return '💸';
    }
  }

  Color get color {
    switch (this) {
      case FinancialRecordType.income:
        return const Color(0xFF4CAF50);
      case FinancialRecordType.expense:
        return const Color(0xFFF44336);
    }
  }
}

enum FinancialRecordStatus {
  pending,
  confirmed,
  cancelled,
}

extension FinancialRecordStatusExtension on FinancialRecordStatus {
  String get displayName {
    switch (this) {
      case FinancialRecordStatus.pending:
        return 'Pending';
      case FinancialRecordStatus.confirmed:
        return 'Confirmed';
      case FinancialRecordStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get icon {
    switch (this) {
      case FinancialRecordStatus.pending:
        return '⏳';
      case FinancialRecordStatus.confirmed:
        return '✅';
      case FinancialRecordStatus.cancelled:
        return '❌';
    }
  }

  Color get color {
    switch (this) {
      case FinancialRecordStatus.pending:
        return const Color(0xFF2196F3);
      case FinancialRecordStatus.confirmed:
        return const Color(0xFF4CAF50);
      case FinancialRecordStatus.cancelled:
        return const Color(0xFF757575);
    }
  }
}

// Income Categories
enum IncomeCategory {
  milkSales,
  calvingSales,
  breeding,
  insurance,
  subsidy,
  other,
}

extension IncomeCategoryExtension on IncomeCategory {
  String get displayName {
    switch (this) {
      case IncomeCategory.milkSales:
        return 'Milk Sales';
      case IncomeCategory.calvingSales:
        return 'Calf Sales';
      case IncomeCategory.breeding:
        return 'Breeding Services';
      case IncomeCategory.insurance:
        return 'Insurance Claim';
      case IncomeCategory.subsidy:
        return 'Government Subsidy';
      case IncomeCategory.other:
        return 'Other Income';
    }
  }

  String get icon {
    switch (this) {
      case IncomeCategory.milkSales:
        return '🥛';
      case IncomeCategory.calvingSales:
        return '🐄';
      case IncomeCategory.breeding:
        return '💕';
      case IncomeCategory.insurance:
        return '🛡️';
      case IncomeCategory.subsidy:
        return '🏛️';
      case IncomeCategory.other:
        return '💎';
    }
  }
}

// Expense Categories
enum ExpenseCategory {
  feed,
  medical,
  breeding,
  labor,
  equipment,
  transportation,
  insurance,
  utilities,
  maintenance,
  other,
}

extension ExpenseCategoryExtension on ExpenseCategory {
  String get displayName {
    switch (this) {
      case ExpenseCategory.feed:
        return 'Feed & Fodder';
      case ExpenseCategory.medical:
        return 'Medical & Veterinary';
      case ExpenseCategory.breeding:
        return 'Breeding Costs';
      case ExpenseCategory.labor:
        return 'Labor Costs';
      case ExpenseCategory.equipment:
        return 'Equipment';
      case ExpenseCategory.transportation:
        return 'Transportation';
      case ExpenseCategory.insurance:
        return 'Insurance Premium';
      case ExpenseCategory.utilities:
        return 'Utilities';
      case ExpenseCategory.maintenance:
        return 'Maintenance';
      case ExpenseCategory.other:
        return 'Other Expenses';
    }
  }

  String get icon {
    switch (this) {
      case ExpenseCategory.feed:
        return '🌾';
      case ExpenseCategory.medical:
        return '💊';
      case ExpenseCategory.breeding:
        return '🎯';
      case ExpenseCategory.labor:
        return '👷';
      case ExpenseCategory.equipment:
        return '🔧';
      case ExpenseCategory.transportation:
        return '🚚';
      case ExpenseCategory.insurance:
        return '📋';
      case ExpenseCategory.utilities:
        return '💡';
      case ExpenseCategory.maintenance:
        return '🔨';
      case ExpenseCategory.other:
        return '📦';
    }
  }

  Color get color {
    switch (this) {
      case ExpenseCategory.feed:
        return const Color(0xFF8BC34A);
      case ExpenseCategory.medical:
        return const Color(0xFF2196F3);
      case ExpenseCategory.breeding:
        return const Color(0xFFE91E63);
      case ExpenseCategory.labor:
        return const Color(0xFF9C27B0);
      case ExpenseCategory.equipment:
        return const Color(0xFF607D8B);
      case ExpenseCategory.transportation:
        return const Color(0xFF795548);
      case ExpenseCategory.insurance:
        return const Color(0xFF3F51B5);
      case ExpenseCategory.utilities:
        return const Color(0xFFFF9800);
      case ExpenseCategory.maintenance:
        return const Color(0xFF009688);
      case ExpenseCategory.other:
        return const Color(0xFF757575);
    }
  }
}

// Daily Milk Production Record for detailed milk income tracking
class DailyMilkProductionRecord {
  final String id;
  final String animalId;
  final DateTime date;
  final double morningYield; // in liters
  final double eveningYield; // in liters
  final double fat; // percentage
  final double snf; // Solid Not Fat percentage
  final double pricePerLiter;
  final double totalAmount;
  final MilkQuality quality;
  final String? buyer;
  final String? notes;
  final DateTime createdAt;

  DailyMilkProductionRecord({
    required this.id,
    required this.animalId,
    required this.date,
    required this.morningYield,
    required this.eveningYield,
    required this.fat,
    required this.snf,
    required this.pricePerLiter,
    required this.totalAmount,
    required this.quality,
    this.buyer,
    this.notes,
    required this.createdAt,
  });

  factory DailyMilkProductionRecord.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return DailyMilkProductionRecord(
      id: doc.id,
      animalId: data['animalId'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      morningYield: data['morningYield']?.toDouble() ?? 0.0,
      eveningYield: data['eveningYield']?.toDouble() ?? 0.0,
      fat: data['fat']?.toDouble() ?? 0.0,
      snf: data['snf']?.toDouble() ?? 0.0,
      pricePerLiter: data['pricePerLiter']?.toDouble() ?? 0.0,
      totalAmount: data['totalAmount']?.toDouble() ?? 0.0,
      quality: MilkQuality.values.firstWhere(
        (q) => q.name == data['quality'],
        orElse: () => MilkQuality.good,
      ),
      buyer: data['buyer'],
      notes: data['notes'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'animalId': animalId,
      'date': Timestamp.fromDate(date),
      'morningYield': morningYield,
      'eveningYield': eveningYield,
      'fat': fat,
      'snf': snf,
      'pricePerLiter': pricePerLiter,
      'totalAmount': totalAmount,
      'quality': quality.name,
      'buyer': buyer,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  double get totalYield => morningYield + eveningYield;
  String get qualityIcon => quality.icon;
  Color get qualityColor => quality.color;
}

enum MilkQuality {
  excellent,
  good,
  average,
  poor,
}

extension MilkQualityExtension on MilkQuality {
  String get displayName {
    switch (this) {
      case MilkQuality.excellent:
        return 'Excellent';
      case MilkQuality.good:
        return 'Good';
      case MilkQuality.average:
        return 'Average';
      case MilkQuality.poor:
        return 'Poor';
    }
  }

  String get icon {
    switch (this) {
      case MilkQuality.excellent:
        return '⭐';
      case MilkQuality.good:
        return '✅';
      case MilkQuality.average:
        return '🟡';
      case MilkQuality.poor:
        return '🔴';
    }
  }

  Color get color {
    switch (this) {
      case MilkQuality.excellent:
        return const Color(0xFFFFD700);
      case MilkQuality.good:
        return const Color(0xFF4CAF50);
      case MilkQuality.average:
        return const Color(0xFFFF9800);
      case MilkQuality.poor:
        return const Color(0xFFF44336);
    }
  }
}

// Financial Summary Helper Class
class FinancialSummary {
  final double totalIncome;
  final double totalExpenses;
  final double netProfit;
  final double profitMargin;
  final Map<String, double> incomeByCategory;
  final Map<String, double> expensesByCategory;

  FinancialSummary({
    required this.totalIncome,
    required this.totalExpenses,
    required this.incomeByCategory,
    required this.expensesByCategory,
  }) : netProfit = totalIncome - totalExpenses,
       profitMargin = totalIncome > 0 ? ((totalIncome - totalExpenses) / totalIncome) * 100 : 0;

  static FinancialSummary fromRecords(List<FinancialRecord> records) {
    double totalIncome = 0;
    double totalExpenses = 0;
    Map<String, double> incomeByCategory = {};
    Map<String, double> expensesByCategory = {};

    for (final record in records.where((r) => r.status == FinancialRecordStatus.confirmed)) {
      if (record.type == FinancialRecordType.income) {
        totalIncome += record.amount;
        final category = record.category ?? 'Other';
        incomeByCategory[category] = (incomeByCategory[category] ?? 0) + record.amount;
      } else {
        totalExpenses += record.amount;
        final category = record.category ?? 'Other';
        expensesByCategory[category] = (expensesByCategory[category] ?? 0) + record.amount;
      }
    }

    return FinancialSummary(
      totalIncome: totalIncome,
      totalExpenses: totalExpenses,
      incomeByCategory: incomeByCategory,
      expensesByCategory: expensesByCategory,
    );
  }

  Color get profitColor => netProfit >= 0 ? const Color(0xFF4CAF50) : const Color(0xFFF44336);
  String get profitIcon => netProfit >= 0 ? '📈' : '📉';
}