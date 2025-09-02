import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/financial_records_model.dart';
import '../../../core/utils/firebase_availability.dart';

class FinancialService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<FinancialRecord>> getAnimalFinancialRecords(String animalId) async {
    if (!FirebaseAvailability.isAvailable) {
      throw Exception(FirebaseAvailability.unavailableMessage);
    }

    try {
      debugPrint('💰 FinancialService: Fetching financial records for animal: $animalId');
      
      final snapshot = await _firestore
          .collection('financial_records')
          .where('animalId', isEqualTo: animalId)
          .orderBy('date', descending: true)
          .get();

      final records = snapshot.docs
          .map((doc) => FinancialRecord.fromFirestore(doc))
          .toList();

      debugPrint('✅ FinancialService: Retrieved ${records.length} financial records');
      return records;
    } catch (e) {
      debugPrint('❌ FinancialService: Error fetching financial records: $e');
      throw Exception('Failed to fetch financial records: $e');
    }
  }

  Future<List<FinancialRecord>> getUserFinancialRecords(String userId, {
    FinancialRecordType? type,
    DateTime? startDate,
    DateTime? endDate,
    String? category,
  }) async {
    if (!FirebaseAvailability.isAvailable) {
      throw Exception(FirebaseAvailability.unavailableMessage);
    }

    try {
      debugPrint('💰 FinancialService: Fetching financial records for user: $userId');
      
      Query query = _firestore
          .collection('financial_records')
          .where('userId', isEqualTo: userId);

      if (type != null) {
        query = query.where('type', isEqualTo: type.name);
      }

      if (category != null) {
        query = query.where('category', isEqualTo: category);
      }

      if (startDate != null) {
        query = query.where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      if (endDate != null) {
        query = query.where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      final snapshot = await query
          .orderBy('date', descending: true)
          .get();

      final records = snapshot.docs
          .map((doc) => FinancialRecord.fromFirestore(doc))
          .toList();

      debugPrint('✅ FinancialService: Retrieved ${records.length} financial records');
      return records;
    } catch (e) {
      debugPrint('❌ FinancialService: Error fetching user financial records: $e');
      throw Exception('Failed to fetch financial records: $e');
    }
  }

  Future<FinancialRecord> addFinancialRecord(FinancialRecord record, String userId) async {
    if (!FirebaseAvailability.isAvailable) {
      throw Exception(FirebaseAvailability.unavailableMessage);
    }

    try {
      debugPrint('💰 FinancialService: Adding financial record: ${record.description}');

      final recordData = record.toFirestore();
      recordData['userId'] = userId;

      final docRef = await _firestore
          .collection('financial_records')
          .add(recordData);

      final createdRecord = FinancialRecord(
        id: docRef.id,
        animalId: record.animalId,
        type: record.type,
        amount: record.amount,
        date: record.date,
        description: record.description,
        category: record.category,
        status: record.status,
        receiptUrl: record.receiptUrl,
        notes: record.notes,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
      );

      debugPrint('✅ FinancialService: Financial record created with ID: ${docRef.id}');
      notifyListeners();
      return createdRecord;
    } catch (e) {
      debugPrint('❌ FinancialService: Error adding financial record: $e');
      throw Exception('Failed to add financial record: $e');
    }
  }

  Future<FinancialRecord> updateFinancialRecord(FinancialRecord record, String userId) async {
    if (!FirebaseAvailability.isAvailable) {
      throw Exception(FirebaseAvailability.unavailableMessage);
    }

    try {
      debugPrint('💰 FinancialService: Updating financial record: ${record.id}');

      final updatedRecord = record.copyWith(updatedAt: DateTime.now());
      final recordData = updatedRecord.toFirestore();
      recordData['userId'] = userId;

      await _firestore
          .collection('financial_records')
          .doc(record.id)
          .update(recordData);

      debugPrint('✅ FinancialService: Financial record updated successfully');
      notifyListeners();
      return updatedRecord;
    } catch (e) {
      debugPrint('❌ FinancialService: Error updating financial record: $e');
      throw Exception('Failed to update financial record: $e');
    }
  }

  Future<void> deleteFinancialRecord(String recordId) async {
    if (!FirebaseAvailability.isAvailable) {
      throw Exception(FirebaseAvailability.unavailableMessage);
    }

    try {
      debugPrint('💰 FinancialService: Deleting financial record: $recordId');

      await _firestore
          .collection('financial_records')
          .doc(recordId)
          .delete();

      debugPrint('✅ FinancialService: Financial record deleted successfully');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ FinancialService: Error deleting financial record: $e');
      throw Exception('Failed to delete financial record: $e');
    }
  }

  Future<DailyMilkProductionRecord> logMilkProduction(DailyMilkProductionRecord record, String userId) async {
    if (!FirebaseAvailability.isAvailable) {
      throw Exception(FirebaseAvailability.unavailableMessage);
    }

    try {
      debugPrint('🥛 FinancialService: Logging milk production for animal: ${record.animalId}');

      // Check if record already exists for this date
      final existingSnapshot = await _firestore
          .collection('daily_milk_production')
          .where('animalId', isEqualTo: record.animalId)
          .where('date', isEqualTo: Timestamp.fromDate(record.date))
          .get();

      String recordId;
      if (existingSnapshot.docs.isNotEmpty) {
        // Update existing record
        recordId = existingSnapshot.docs.first.id;
        final recordData = record.toFirestore();
        recordData['userId'] = userId;
        
        await _firestore
            .collection('daily_milk_production')
            .doc(recordId)
            .update(recordData);
            
        debugPrint('✅ FinancialService: Milk production updated');
      } else {
        // Create new record
        final recordData = record.toFirestore();
        recordData['userId'] = userId;
        
        final docRef = await _firestore
            .collection('daily_milk_production')
            .add(recordData);
        recordId = docRef.id;
        
        debugPrint('✅ FinancialService: Milk production created with ID: $recordId');
      }

      // Also create/update financial record for income
      if (record.totalAmount > 0) {
        await _createMilkIncomeRecord(record, userId);
      }

      final finalRecord = DailyMilkProductionRecord(
        id: recordId,
        animalId: record.animalId,
        date: record.date,
        morningYield: record.morningYield,
        eveningYield: record.eveningYield,
        fat: record.fat,
        snf: record.snf,
        pricePerLiter: record.pricePerLiter,
        totalAmount: record.totalAmount,
        quality: record.quality,
        buyer: record.buyer,
        notes: record.notes,
        createdAt: record.createdAt,
      );

      notifyListeners();
      return finalRecord;
    } catch (e) {
      debugPrint('❌ FinancialService: Error logging milk production: $e');
      throw Exception('Failed to log milk production: $e');
    }
  }

  Future<List<DailyMilkProductionRecord>> getMilkProductionHistory(String animalId, {
    DateTime? startDate,
    DateTime? endDate,
    int? limitDays,
  }) async {
    if (!FirebaseAvailability.isAvailable) {
      throw Exception(FirebaseAvailability.unavailableMessage);
    }

    try {
      debugPrint('🥛 FinancialService: Fetching milk production history for animal: $animalId');
      
      Query query = _firestore
          .collection('daily_milk_production')
          .where('animalId', isEqualTo: animalId);

      if (startDate != null) {
        query = query.where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      if (endDate != null) {
        query = query.where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      if (limitDays != null && startDate == null) {
        final cutoffDate = DateTime.now().subtract(Duration(days: limitDays));
        query = query.where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(cutoffDate));
      }

      final snapshot = await query
          .orderBy('date', descending: true)
          .limit(100)
          .get();

      final records = snapshot.docs
          .map((doc) => DailyMilkProductionRecord.fromFirestore(doc))
          .toList();

      debugPrint('✅ FinancialService: Retrieved ${records.length} milk production records');
      return records;
    } catch (e) {
      debugPrint('❌ FinancialService: Error fetching milk production history: $e');
      throw Exception('Failed to fetch milk production history: $e');
    }
  }

  Future<FinancialSummary> getFinancialSummary(String userId, {
    DateTime? startDate,
    DateTime? endDate,
    String? animalId,
  }) async {
    try {
      debugPrint('📊 FinancialService: Generating financial summary for user: $userId');
      
      List<FinancialRecord> records;
      
      if (animalId != null) {
        records = await getAnimalFinancialRecords(animalId);
      } else {
        records = await getUserFinancialRecords(
          userId,
          startDate: startDate,
          endDate: endDate,
        );
      }

      // Filter by date range if provided
      if (startDate != null || endDate != null) {
        records = records.where((record) {
          if (startDate != null && record.date.isBefore(startDate)) return false;
          if (endDate != null && record.date.isAfter(endDate)) return false;
          return true;
        }).toList();
      }

      final summary = FinancialSummary.fromRecords(records);
      
      debugPrint('✅ FinancialService: Financial summary generated - Profit: ${summary.netProfit}');
      return summary;
    } catch (e) {
      debugPrint('❌ FinancialService: Error generating financial summary: $e');
      throw Exception('Failed to generate financial summary: $e');
    }
  }

  Future<Map<String, double>> getMilkProductionStats(String animalId, {int? days}) async {
    try {
      debugPrint('📊 FinancialService: Calculating milk production stats for animal: $animalId');
      
      final records = await getMilkProductionHistory(
        animalId,
        limitDays: days,
      );
      
      if (records.isEmpty) {
        return {
          'totalProduction': 0.0,
          'averageDaily': 0.0,
          'averageMorning': 0.0,
          'averageEvening': 0.0,
          'totalIncome': 0.0,
          'averagePrice': 0.0,
          'averageFat': 0.0,
          'averageSNF': 0.0,
          'recordCount': 0.0,
        };
      }

      final totalProduction = records.fold<double>(0.0, (sum, record) => sum + record.totalYield);
      final totalMorning = records.fold<double>(0.0, (sum, record) => sum + record.morningYield);
      final totalEvening = records.fold<double>(0.0, (sum, record) => sum + record.eveningYield);
      final totalIncome = records.fold<double>(0.0, (sum, record) => sum + record.totalAmount);
      final totalFat = records.fold<double>(0.0, (sum, record) => sum + record.fat);
      final totalSNF = records.fold<double>(0.0, (sum, record) => sum + record.snf);
      
      final stats = {
        'totalProduction': totalProduction,
        'averageDaily': totalProduction / records.length,
        'averageMorning': totalMorning / records.length,
        'averageEvening': totalEvening / records.length,
        'totalIncome': totalIncome,
        'averagePrice': totalIncome / (totalProduction > 0 ? totalProduction : 1),
        'averageFat': totalFat / records.length,
        'averageSNF': totalSNF / records.length,
        'recordCount': records.length.toDouble(),
      };

      debugPrint('✅ FinancialService: Milk production stats calculated');
      return stats;
    } catch (e) {
      debugPrint('❌ FinancialService: Error calculating milk stats: $e');
      throw Exception('Failed to calculate milk production statistics: $e');
    }
  }

  Future<Map<String, dynamic>> getMonthlyReport(String userId, {
    required int year,
    required int month,
    String? animalId,
  }) async {
    try {
      debugPrint('📈 FinancialService: Generating monthly report for $year-$month');
      
      final startDate = DateTime(year, month, 1);
      final endDate = DateTime(year, month + 1, 0); // Last day of month

      List<FinancialRecord> financialRecords;
      List<DailyMilkProductionRecord> milkRecords = [];

      if (animalId != null) {
        financialRecords = await getAnimalFinancialRecords(animalId);
        milkRecords = await getMilkProductionHistory(
          animalId,
          startDate: startDate,
          endDate: endDate,
        );
      } else {
        financialRecords = await getUserFinancialRecords(
          userId,
          startDate: startDate,
          endDate: endDate,
        );
        
        // Get milk records for all user's animals
        final userAnimals = await _getUserAnimalIds(userId);
        for (final animalId in userAnimals) {
          final animalMilkRecords = await getMilkProductionHistory(
            animalId,
            startDate: startDate,
            endDate: endDate,
          );
          milkRecords.addAll(animalMilkRecords);
        }
      }

      // Filter financial records by date range
      financialRecords = financialRecords.where((record) {
        return !record.date.isBefore(startDate) && !record.date.isAfter(endDate);
      }).toList();

      final financialSummary = FinancialSummary.fromRecords(financialRecords);
      
      // Calculate milk-specific metrics
      final totalMilkProduced = milkRecords.fold<double>(0.0, (sum, record) => sum + record.totalYield);
      final totalMilkIncome = milkRecords.fold<double>(0.0, (sum, record) => sum + record.totalAmount);
      final averageFat = milkRecords.isEmpty ? 0.0 : 
          milkRecords.fold<double>(0.0, (sum, record) => sum + record.fat) / milkRecords.length;
      final averageSNF = milkRecords.isEmpty ? 0.0 : 
          milkRecords.fold<double>(0.0, (sum, record) => sum + record.snf) / milkRecords.length;

      final report = {
        'period': '$year-${month.toString().padLeft(2, '0')}',
        'financial': {
          'totalIncome': financialSummary.totalIncome,
          'totalExpenses': financialSummary.totalExpenses,
          'netProfit': financialSummary.netProfit,
          'profitMargin': financialSummary.profitMargin,
          'incomeByCategory': financialSummary.incomeByCategory,
          'expensesByCategory': financialSummary.expensesByCategory,
        },
        'milk': {
          'totalProduced': totalMilkProduced,
          'totalIncome': totalMilkIncome,
          'averageDaily': totalMilkProduced / DateTime(year, month + 1, 0).day,
          'averageFat': averageFat,
          'averageSNF': averageSNF,
          'recordCount': milkRecords.length,
        },
        'summary': {
          'recordCount': financialRecords.length,
          'milkRecordCount': milkRecords.length,
          'generatedAt': DateTime.now().toIso8601String(),
        }
      };

      debugPrint('✅ FinancialService: Monthly report generated');
      return report;
    } catch (e) {
      debugPrint('❌ FinancialService: Error generating monthly report: $e');
      throw Exception('Failed to generate monthly report: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getFinancialTrends(String userId, {
    required int months,
    String? animalId,
  }) async {
    try {
      debugPrint('📈 FinancialService: Calculating financial trends for $months months');
      
      final trends = <Map<String, dynamic>>[];
      final now = DateTime.now();

      for (int i = 0; i < months; i++) {
        final monthDate = DateTime(now.year, now.month - i, 1);
        final report = await getMonthlyReport(
          userId,
          year: monthDate.year,
          month: monthDate.month,
          animalId: animalId,
        );
        
        trends.add({
          'month': '${monthDate.year}-${monthDate.month.toString().padLeft(2, '0')}',
          'monthName': _getMonthName(monthDate.month),
          'year': monthDate.year,
          'income': report['financial']['totalIncome'],
          'expenses': report['financial']['totalExpenses'],
          'profit': report['financial']['netProfit'],
          'milkProduced': report['milk']['totalProduced'],
          'milkIncome': report['milk']['totalIncome'],
        });
      }

      trends.sort((a, b) => a['month'].compareTo(b['month']));
      
      debugPrint('✅ FinancialService: Financial trends calculated for $months months');
      return trends;
    } catch (e) {
      debugPrint('❌ FinancialService: Error calculating trends: $e');
      throw Exception('Failed to calculate financial trends: $e');
    }
  }

  Future<Map<String, double>> getCostPerAnimal(String userId, {DateTime? startDate, DateTime? endDate}) async {
    try {
      debugPrint('💰 FinancialService: Calculating cost per animal for user: $userId');
      
      final records = await getUserFinancialRecords(
        userId,
        type: FinancialRecordType.expense,
        startDate: startDate,
        endDate: endDate,
      );

      final costPerAnimal = <String, double>{};
      
      for (final record in records.where((r) => r.status == FinancialRecordStatus.confirmed)) {
        costPerAnimal[record.animalId] = (costPerAnimal[record.animalId] ?? 0) + record.amount;
      }

      debugPrint('✅ FinancialService: Cost per animal calculated for ${costPerAnimal.length} animals');
      return costPerAnimal;
    } catch (e) {
      debugPrint('❌ FinancialService: Error calculating cost per animal: $e');
      throw Exception('Failed to calculate cost per animal: $e');
    }
  }

  Future<Map<String, double>> getRevenuePerAnimal(String userId, {DateTime? startDate, DateTime? endDate}) async {
    try {
      debugPrint('💰 FinancialService: Calculating revenue per animal for user: $userId');
      
      final records = await getUserFinancialRecords(
        userId,
        type: FinancialRecordType.income,
        startDate: startDate,
        endDate: endDate,
      );

      final revenuePerAnimal = <String, double>{};
      
      for (final record in records.where((r) => r.status == FinancialRecordStatus.confirmed)) {
        revenuePerAnimal[record.animalId] = (revenuePerAnimal[record.animalId] ?? 0) + record.amount;
      }

      debugPrint('✅ FinancialService: Revenue per animal calculated for ${revenuePerAnimal.length} animals');
      return revenuePerAnimal;
    } catch (e) {
      debugPrint('❌ FinancialService: Error calculating revenue per animal: $e');
      throw Exception('Failed to calculate revenue per animal: $e');
    }
  }

  Stream<List<FinancialRecord>> watchFinancialRecords(String userId, {String? animalId}) {
    if (!FirebaseAvailability.isAvailable) {
      throw Exception(FirebaseAvailability.unavailableMessage);
    }

    debugPrint('🔄 FinancialService: Starting real-time watch for financial records');
    
    Query query = _firestore
        .collection('financial_records')
        .where('userId', isEqualTo: userId);
    
    if (animalId != null) {
      query = query.where('animalId', isEqualTo: animalId);
    }

    return query
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
          final records = snapshot.docs
              .map((doc) => FinancialRecord.fromFirestore(doc))
              .toList();
          debugPrint('🔄 FinancialService: Real-time update - ${records.length} financial records');
          return records;
        });
  }

  Future<void> _createMilkIncomeRecord(DailyMilkProductionRecord milkRecord, String userId) async {
    try {
      final incomeRecord = FinancialRecord(
        id: '',
        animalId: milkRecord.animalId,
        type: FinancialRecordType.income,
        amount: milkRecord.totalAmount,
        date: milkRecord.date,
        description: 'Milk sales - ${milkRecord.totalYield}L at ₹${milkRecord.pricePerLiter}/L',
        category: IncomeCategory.milkSales.displayName,
        status: FinancialRecordStatus.confirmed,
        notes: 'Auto-generated from milk production log',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await addFinancialRecord(incomeRecord, userId);
    } catch (e) {
      debugPrint('⚠️ FinancialService: Could not create milk income record: $e');
    }
  }

  Future<List<String>> _getUserAnimalIds(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('animals')
          .where('ownerId', isEqualTo: userId)
          .get();

      return snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      debugPrint('❌ FinancialService: Error fetching user animal IDs: $e');
      return [];
    }
  }

  String _getMonthName(int month) {
    const monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return monthNames[month - 1];
  }

  Future<List<String>> getIncomeCategories() async {
    return IncomeCategory.values.map((c) => c.displayName).toList();
  }

  Future<List<String>> getExpenseCategories() async {
    return ExpenseCategory.values.map((c) => c.displayName).toList();
  }

  Future<void> confirmPendingRecord(String recordId) async {
    if (!FirebaseAvailability.isAvailable) {
      throw Exception(FirebaseAvailability.unavailableMessage);
    }

    try {
      await _firestore
          .collection('financial_records')
          .doc(recordId)
          .update({
            'status': FinancialRecordStatus.confirmed.name,
            'updatedAt': FieldValue.serverTimestamp(),
          });

      notifyListeners();
    } catch (e) {
      throw Exception('Failed to confirm financial record: $e');
    }
  }

  Future<void> cancelRecord(String recordId) async {
    if (!FirebaseAvailability.isAvailable) {
      throw Exception(FirebaseAvailability.unavailableMessage);
    }

    try {
      await _firestore
          .collection('financial_records')
          .doc(recordId)
          .update({
            'status': FinancialRecordStatus.cancelled.name,
            'updatedAt': FieldValue.serverTimestamp(),
          });

      notifyListeners();
    } catch (e) {
      throw Exception('Failed to cancel financial record: $e');
    }
  }
}