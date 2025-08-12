import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/unified_theme.dart';
import '../models/animal_model.dart';
import '../models/financial_records_model.dart';
import '../../coins/providers/coin_provider.dart';
import 'add_financial_record_screen.dart';

class FinancialRecordsScreen extends StatefulWidget {
  final AnimalModel animal;
  
  const FinancialRecordsScreen({super.key, required this.animal});

  @override
  State<FinancialRecordsScreen> createState() => _FinancialRecordsScreenState();
}

class _FinancialRecordsScreenState extends State<FinancialRecordsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String selectedPeriod = 'This Month';
  String selectedCategory = 'All';
  
  // Mock data - in real app this would come from Firebase
  final List<FinancialRecord> financialRecords = [
    FinancialRecord(
      id: '1',
      animalId: 'animal_1',
      type: FinancialRecordType.income,
      amount: 12450.0,
      date: DateTime.now().subtract(const Duration(days: 1)),
      description: 'Daily milk sales to dairy co-operative',
      category: 'Milk Sales',
      status: FinancialRecordStatus.confirmed,
      notes: '50 liters @ ₹24.90 per liter',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    FinancialRecord(
      id: '2',
      animalId: 'animal_1',
      type: FinancialRecordType.expense,
      amount: 850.0,
      date: DateTime.now().subtract(const Duration(days: 2)),
      description: 'Premium cattle feed purchase',
      category: 'Feed & Fodder',
      status: FinancialRecordStatus.confirmed,
      notes: '25kg premium feed mix',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    FinancialRecord(
      id: '3',
      animalId: 'animal_1',
      type: FinancialRecordType.expense,
      amount: 450.0,
      date: DateTime.now().subtract(const Duration(days: 5)),
      description: 'Veterinary consultation and medication',
      category: 'Medical & Veterinary',
      status: FinancialRecordStatus.confirmed,
      notes: 'Routine checkup + vitamins',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    FinancialRecord(
      id: '4',
      animalId: 'animal_1',
      type: FinancialRecordType.income,
      amount: 25000.0,
      date: DateTime.now().subtract(const Duration(days: 30)),
      description: 'Calf sale to local farmer',
      category: 'Calf Sales',
      status: FinancialRecordStatus.confirmed,
      notes: '6-month old healthy male calf',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
  ];

  final List<DailyMilkProductionRecord> milkRecords = [
    DailyMilkProductionRecord(
      id: '1',
      animalId: 'animal_1',
      date: DateTime.now().subtract(const Duration(days: 1)),
      morningYield: 22.5,
      eveningYield: 20.0,
      fat: 4.2,
      snf: 8.8,
      pricePerLiter: 24.90,
      totalAmount: 1058.25,
      quality: MilkQuality.good,
      buyer: 'Amul Dairy Co-operative',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    DailyMilkProductionRecord(
      id: '2',
      animalId: 'animal_1',
      date: DateTime.now().subtract(const Duration(days: 2)),
      morningYield: 21.0,
      eveningYield: 19.5,
      fat: 4.0,
      snf: 8.6,
      pricePerLiter: 24.50,
      totalAmount: 992.25,
      quality: MilkQuality.good,
      buyer: 'Amul Dairy Co-operative',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.animal.typeEmoji} ${widget.animal.name}',
              style: const TextStyle(fontSize: 18),
            ),
            const Text(
              'Financial Records',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _showAddRecordMenu,
            icon: const Icon(Icons.add),
            tooltip: 'Add Record',
          ),
          IconButton(
            onPressed: _generateFinancialReport,
            icon: const Icon(Icons.assessment),
            tooltip: 'Generate Report',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.timeline), text: 'Overview'),
            Tab(icon: Icon(Icons.arrow_upward), text: 'Income'),
            Tab(icon: Icon(Icons.arrow_downward), text: 'Expenses'),
            Tab(icon: Icon(Icons.local_drink), text: 'Milk Records'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildIncomeTab(),
          _buildExpensesTab(),
          _buildMilkRecordsTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    final summary = FinancialSummary.fromRecords(financialRecords);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPeriodSelector(),
          const SizedBox(height: 16),
          _buildFinancialSummaryCard(summary),
          const SizedBox(height: 16),
          _buildProfitabilityCard(summary),
          const SizedBox(height: 16),
          _buildRecentTransactionsCard(),
          const SizedBox(height: 16),
          _buildQuickActionsCard(),
        ],
      ),
    );
  }

  Widget _buildIncomeTab() {
    final incomeRecords = financialRecords
        .where((r) => r.type == FinancialRecordType.income)
        .toList();
    
    return Column(
      children: [
        _buildFilterBar(),
        Expanded(
          child: incomeRecords.isEmpty
              ? _buildEmptyState('No income records found', Icons.trending_up)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: incomeRecords.length,
                  itemBuilder: (context, index) {
                    return _buildFinancialRecordCard(incomeRecords[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildExpensesTab() {
    final expenseRecords = financialRecords
        .where((r) => r.type == FinancialRecordType.expense)
        .toList();
    
    return Column(
      children: [
        _buildFilterBar(),
        Expanded(
          child: expenseRecords.isEmpty
              ? _buildEmptyState('No expense records found', Icons.trending_down)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: expenseRecords.length,
                  itemBuilder: (context, index) {
                    return _buildFinancialRecordCard(expenseRecords[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildMilkRecordsTab() {
    return milkRecords.isEmpty
        ? _buildEmptyState('No milk production records found', Icons.local_drink)
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: milkRecords.length,
            itemBuilder: (context, index) {
              return _buildMilkRecordCard(milkRecords[index]);
            },
          );
  }

  Widget _buildPeriodSelector() {
    final periods = ['Today', 'This Week', 'This Month', 'Last Month', 'This Year'];
    
    return Container(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: periods.length,
        itemBuilder: (context, index) {
          final period = periods[index];
          final isSelected = selectedPeriod == period;
          
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(period),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  selectedPeriod = selected ? period : 'This Month';
                });
              },
              selectedColor: const Color(0xFF4CAF50),
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterBar() {
    final categories = ['All', 'Milk Sales', 'Calf Sales', 'Feed & Fodder', 'Medical & Veterinary'];
    
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category;
          
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  selectedCategory = selected ? category : 'All';
                });
              },
              selectedColor: const Color(0xFF4CAF50),
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFinancialSummaryCard(FinancialSummary summary) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '💰 Financial Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4CAF50),
              ),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    'Total Income',
                    '₹${summary.totalIncome.toStringAsFixed(0)}',
                    Colors.green,
                    Icons.arrow_upward,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryItem(
                    'Total Expenses',
                    '₹${summary.totalExpenses.toStringAsFixed(0)}',
                    Colors.red,
                    Icons.arrow_downward,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: summary.netProfit >= 0 
                    ? [Colors.green.shade100, Colors.green.shade50]
                    : [Colors.red.shade100, Colors.red.shade50],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${summary.profitIcon} Net Profit',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '₹${summary.netProfit.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: summary.profitColor,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Profit Margin'),
                      Text(
                        '${summary.profitMargin.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: summary.profitColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfitabilityCard(FinancialSummary summary) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📊 Category Breakdown',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4CAF50),
              ),
            ),
            const SizedBox(height: 16),
            
            // Top income categories
            const Text('Top Income Sources:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...summary.incomeByCategory.entries.take(3).map((entry) =>
              _buildCategoryItem(entry.key, entry.value, Colors.green)
            ),
            
            const SizedBox(height: 16),
            
            // Top expense categories
            const Text('Top Expense Categories:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...summary.expensesByCategory.entries.take(3).map((entry) =>
              _buildCategoryItem(entry.key, entry.value, Colors.red)
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTransactionsCard() {
    final recentRecords = financialRecords.take(5).toList();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '📝 Recent Transactions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4CAF50),
                  ),
                ),
                TextButton(
                  onPressed: () => _tabController.animateTo(1),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...recentRecords.map((record) => _buildTransactionListItem(record)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '⚡ Quick Actions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4CAF50),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _addRecord(FinancialRecordType.income),
                    icon: const Icon(Icons.add_circle, color: Colors.green),
                    label: const Text('Add Income'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.green,
                      side: const BorderSide(color: Colors.green),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _addRecord(FinancialRecordType.expense),
                    icon: const Icon(Icons.remove_circle, color: Colors.red),
                    label: const Text('Add Expense'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _addMilkRecord,
                icon: const Icon(Icons.local_drink),
                label: const Text('Add Milk Production'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialRecordCard(FinancialRecord record) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: record.typeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(record.typeIcon, style: const TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.description,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        record.category ?? 'Other',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${record.type == FinancialRecordType.income ? '+' : '-'}₹${record.amount.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: record.typeColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildInfoChip(
                  Icons.calendar_today,
                  DateFormat('dd MMM yyyy').format(record.date),
                ),
                _buildInfoChip(
                  record.statusIcon.codeUnitAt(0) > 0 ? Icons.check_circle : Icons.pending,
                  record.status.displayName,
                ),
              ],
            ),
            if (record.notes != null && record.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                record.notes!,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMilkRecordCard(DailyMilkProductionRecord record) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('🥛', style: TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Daily Milk Production',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        DateFormat('dd MMM yyyy').format(record.date),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${record.totalYield.toStringAsFixed(1)}L',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    Text(
                      '₹${record.totalAmount.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMilkInfoItem(
                    'Morning',
                    '${record.morningYield.toStringAsFixed(1)}L',
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildMilkInfoItem(
                    'Evening',
                    '${record.eveningYield.toStringAsFixed(1)}L',
                    Colors.purple,
                  ),
                ),
                Expanded(
                  child: _buildMilkInfoItem(
                    'Fat %',
                    '${record.fat.toStringAsFixed(1)}%',
                    Colors.amber,
                  ),
                ),
                Expanded(
                  child: _buildMilkInfoItem(
                    'SNF %',
                    '${record.snf.toStringAsFixed(1)}%',
                    Colors.teal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('${record.qualityIcon} ${record.quality.displayName}'),
                const Spacer(),
                Text('₹${record.pricePerLiter.toStringAsFixed(2)}/L'),
              ],
            ),
            if (record.buyer != null)
              Text(
                'Sold to: ${record.buyer}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(String category, double amount, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(category)),
          Text(
            '₹${amount.toStringAsFixed(0)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionListItem(FinancialRecord record) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(record.typeIcon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.description,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  DateFormat('dd MMM').format(record.date),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Text(
            '${record.type == FinancialRecordType.income ? '+' : '-'}₹${record.amount.toStringAsFixed(0)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: record.typeColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMilkInfoItem(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.only(right: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _showAddRecordMenu,
            icon: const Icon(Icons.add),
            label: const Text('Add Record'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddRecordMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add Financial Record',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Text('💰', style: TextStyle(fontSize: 24)),
              title: const Text('Income Record'),
              subtitle: const Text('Add income from sales, subsidies, etc.'),
              onTap: () {
                Navigator.pop(context);
                _addRecord(FinancialRecordType.income);
              },
            ),
            ListTile(
              leading: const Text('💸', style: TextStyle(fontSize: 24)),
              title: const Text('Expense Record'),
              subtitle: const Text('Add expenses for feed, medical, etc.'),
              onTap: () {
                Navigator.pop(context);
                _addRecord(FinancialRecordType.expense);
              },
            ),
            ListTile(
              leading: const Text('🥛', style: TextStyle(fontSize: 24)),
              title: const Text('Milk Production'),
              subtitle: const Text('Record daily milk production'),
              onTap: () {
                Navigator.pop(context);
                _addMilkRecord();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _addRecord(FinancialRecordType type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddFinancialRecordScreen(
          animal: widget.animal,
          recordType: type,
        ),
      ),
    );
  }

  void _addMilkRecord() {
    // Navigate to add milk record screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Milk record form coming soon!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _generateFinancialReport() async {
    final coinProvider = context.read<CoinProvider>();
    const requiredCoins = 10;

    if (coinProvider.currentBalance < requiredCoins) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Insufficient coins! Need $requiredCoins coins to generate financial report.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Generating comprehensive financial report...'),
          ],
        ),
      ),
    );

    // Simulate report generation
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      Navigator.pop(context); // Close loading
      coinProvider.deductCoins(requiredCoins, 'Financial Report Generation');
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Financial report generated successfully! Check your downloads.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}