import 'package:flutter/material.dart';
import '../../../core/theme/unified_theme.dart';

class FinancialManagementScreen extends StatefulWidget {
  const FinancialManagementScreen({super.key});

  @override
  State<FinancialManagementScreen> createState() => _FinancialManagementScreenState();
}

class _FinancialManagementScreenState extends State<FinancialManagementScreen> {
  String selectedMonth = 'Aug';
  final List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  
  // Transaction form variables
  String selectedEntryType = 'Income';
  String selectedCategory = 'Milk Sales';
  String amount = '';
  String selectedDate = '3 Aug 2024';
  String selectedPaymentMethod = 'UPI';
  String selectedSource = 'Dairy Co-op';
  String quantity = '65';
  String rate = '45';
  String selectedVendor = 'ABC Feeds';
  String selectedItems = 'Cattle Feed';
  String selectedPurpose = 'Routine Purchase';
  
  final List<String> entryTypes = ['Income', 'Expense', 'Investment'];
  final List<String> incomeCategories = ['Milk Sales', 'Animal Sales', 'Product Sales', 'Other Income'];
  final List<String> expenseCategories = ['Feed Costs', 'Healthcare', 'Equipment', 'Labor', 'Utilities', 'Other Expense'];
  final List<String> paymentMethods = ['UPI', 'Cash', 'Bank'];
  final List<String> incomeSources = ['Dairy Co-op', 'Local Market', 'Direct Sale', 'Online Platform'];
  final List<String> vendors = ['ABC Feeds', 'XYZ Veterinary', 'Local Supplier', 'Equipment Store'];
  final List<String> feedItems = ['Cattle Feed', 'Mineral Mix', 'Silage', 'Hay', 'Concentrates'];
  final List<String> purposes = ['Routine Purchase', 'Emergency', 'Bulk Order', 'Seasonal Stock'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        title: Row(
          children: [
            const Text('💰', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'FINANCIAL MANAGEMENT',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedMonth,
                  onChanged: (value) => setState(() => selectedMonth = value!),
                  icon: const Text('▼', style: TextStyle(color: Colors.white, fontSize: 12)),
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  dropdownColor: const Color(0xFF2E7D32),
                  items: months.map((month) => DropdownMenuItem(
                    value: month,
                    child: Text('📅 $month', style: const TextStyle(color: Colors.white)),
                  )).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Overview
            _buildQuickOverviewSection(),
            
            const SizedBox(height: 16),
            
            // Daily Transactions
            _buildDailyTransactionsSection(),
            
            const SizedBox(height: 16),
            
            // Category Breakdown
            _buildCategoryBreakdownSection(),
            
            const SizedBox(height: 20),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _addTransaction(),
                    icon: const Text('➕'),
                    label: const Text('Add Transaction'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _exportFinancialReport(),
                    icon: const Text('📤'),
                    label: const Text('Export'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orange,
                      side: const BorderSide(color: Colors.orange),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _viewTrends(),
                    icon: const Text('📊'),
                    label: const Text('View Trends'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      side: const BorderSide(color: Colors.blue),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickOverviewSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: const Center(
              child: Text(
                '░░░░░░░░░░░░░░░ QUICK OVERVIEW ░░░░░░░░░░░░░░░░░░░',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Income and Expenses
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.withOpacity(0.3)),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Aug 2024 Income:  ₹24,500',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text('Aug 2024 Expenses: ₹12,300', 
                                 style: TextStyle(fontSize: 14, color: Colors.grey)),
                            Text('Daily Avg: ₹790', 
                                 style: TextStyle(fontSize: 14, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.withOpacity(0.3)),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '🟢 Profit: ₹12,200',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text('▲15% from July', 
                                 style: TextStyle(fontSize: 14, color: Colors.green)),
                            Text('Yearly: ₹1,48,000', 
                                 style: TextStyle(fontSize: 14, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyTransactionsSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: const Row(
              children: [
                Expanded(
                  child: Text(
                    '▼ DAILY TRANSACTIONS (Aug 3)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ),
                Icon(Icons.expand_more, color: Color(0xFF2E7D32)),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            height: 1,
            color: Colors.grey.withOpacity(0.3),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Income section
                  const Text(
                    '💵 Income:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('• Milk Sales - 65L @₹45/L = ₹2,925', 
                       style: TextStyle(fontSize: 14, color: Colors.grey)),
                  const Text('• Calf Sale = ₹6,500', 
                       style: TextStyle(fontSize: 14, color: Colors.grey)),
                  
                  const SizedBox(height: 16),
                  
                  // Expenses section
                  const Text(
                    '🏽 Expenses:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('• Cattle Feed (200kg) = ₹1,600', 
                       style: TextStyle(fontSize: 14, color: Colors.grey)),
                  const Text('• Vet Visit = ₹500', 
                       style: TextStyle(fontSize: 14, color: Colors.grey)),
                  const Text('• Labor = ₹300', 
                       style: TextStyle(fontSize: 14, color: Colors.grey)),
                  
                  const SizedBox(height: 16),
                  
                  // Daily balance
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: const Text(
                      'Daily Balance: ₹7,025 (Income) - ₹2,400 = ₹4,625',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdownSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: const Row(
              children: [
                Expanded(
                  child: Text(
                    '▼ CATEGORY BREAKDOWN (Monthly)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ),
                Icon(Icons.expand_more, color: Color(0xFF2E7D32)),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            height: 1,
            color: Colors.grey.withOpacity(0.3),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  // Income categories
                  _buildCategoryBar('🥛 Milk Income:', '65%', 0.65, Colors.blue),
                  const SizedBox(height: 12),
                  _buildCategoryBar('🐄 Animal Sales:', '22%', 0.22, Colors.green),
                  
                  const SizedBox(height: 20),
                  
                  // Expense categories  
                  _buildCategoryBar('🌾 Feed Costs:', '45%', 0.45, Colors.orange),
                  const SizedBox(height: 12),
                  _buildCategoryBar('🏥 Healthcare:', '18%', 0.18, Colors.red),
                  const SizedBox(height: 12),
                  _buildCategoryBar('🔧 Equipment:', '12%', 0.12, Colors.purple),
                  
                  const SizedBox(height: 20),
                  
                  // Summary
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: const Row(
                      children: [
                        Text('📊', style: TextStyle(fontSize: 16)),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Net Profit Margin: 49.8% | ROI: 24.3%',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBar(String label, String percentage, double fraction, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ),
            Text(
              percentage,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 12,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: Colors.grey.withOpacity(0.2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: fraction,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _generateProgressBar(fraction),
          style: const TextStyle(fontSize: 10, fontFamily: 'monospace', color: Colors.grey),
        ),
      ],
    );
  }

  String _generateProgressBar(double fraction) {
    final int filled = (fraction * 20).round();
    final int empty = 20 - filled;
    return '█' * filled + '▒' * empty;
  }

  void _addTransaction() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.95,
          height: MediaQuery.of(context).size.height * 0.9,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Text('➕', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'ADD TRANSACTION',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Text('❌', style: TextStyle(fontSize: 18)),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Entry Type Selection
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  border: Border.all(color: Colors.grey.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    '░░░░░░░░░░░░░░░ ENTRY TYPE ░░░░░░░░░░░░░░░░░░░░░░░░',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Radio buttons for entry type
              Row(
                children: entryTypes.map((type) {
                  final isSelected = selectedEntryType == type;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() {
                        selectedEntryType = type;
                        // Update category based on type
                        if (type == 'Income') {
                          selectedCategory = 'Milk Sales';
                        } else if (type == 'Expense') {
                          selectedCategory = 'Feed Costs';
                        } else {
                          selectedCategory = 'Equipment';
                        }
                      }),
                      child: Row(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey),
                              color: isSelected ? const Color(0xFF2E7D32) : Colors.white,
                            ),
                            child: isSelected 
                              ? const Icon(Icons.circle, size: 12, color: Colors.white)
                              : null,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              type,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? const Color(0xFF2E7D32) : Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 20),
              
              // Form content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Basic transaction details
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.withOpacity(0.3)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            _buildFormRow('Category:', _buildDropdown(selectedCategory, _getCategoriesForType(), (value) => setState(() => selectedCategory = value!))),
                            _buildFormRow('Amount:', Row(
                              children: [
                                const Text('₹', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildAmountField(),
                                ),
                              ],
                            )),
                            _buildFormRow('Date:', _buildDropdown(selectedDate, ['3 Aug 2024', '2 Aug 2024', '1 Aug 2024'], (value) => setState(() => selectedDate = value!))),
                            _buildFormRow('Payment Method:', _buildPaymentMethodSelection()),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Conditional details based on entry type
                      if (selectedEntryType == 'Income') _buildIncomeDetailsSection(),
                      if (selectedEntryType == 'Expense') _buildExpenseDetailsSection(),
                    ],
                  ),
                ),
              ),
              
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _saveTransaction(),
                      icon: const Text('📌'),
                      label: const Text('Save'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _setRecurring(),
                      icon: const Text('🔄'),
                      label: const Text('Recurring'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue,
                        side: const BorderSide(color: Colors.blue),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _attachBill(),
                      icon: const Text('📁'),
                      label: const Text('Attach Bill'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.orange,
                        side: const BorderSide(color: Colors.orange),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


  void _exportFinancialReport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Text('📤', style: TextStyle(fontSize: 24)),
            SizedBox(width: 8),
            Text('Export Financial Report', style: TextStyle(fontSize: 16)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Export Options:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Text('• Monthly income/expense summary'),
            Text('• Daily transaction logs'),
            Text('• Category-wise breakdown'),
            Text('• Profit/loss analysis'),
            Text('• Tax documentation'),
            SizedBox(height: 16),
            Text('Format: PDF | Excel | CSV'),
            SizedBox(height: 8),
            Text('Cost: 4 Coins per report', 
                 style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('📤 Financial report exported! (4 coins deducted)'),
                  backgroundColor: Color(0xFF4CAF50),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50)),
            child: const Text('Export (4 Coins)', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _viewTrends() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Text('📊', style: TextStyle(fontSize: 24)),
            SizedBox(width: 8),
            Text('Financial Trends', style: TextStyle(fontSize: 16)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('6-Month Trend Analysis:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Text('Profit Growth:'),
            Text('• Mar: ₹8,500'),
            Text('• Apr: ₹9,200 (+8%)'),
            Text('• May: ₹10,100 (+10%)'),
            Text('• Jun: ₹10,800 (+7%)'),
            Text('• Jul: ₹11,200 (+4%)'),
            Text('• Aug: ₹12,200 (+9%)', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Text('Key Insights:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('• Milk prices increased 8% this quarter'),
            Text('• Feed costs stabilizing'),
            Text('• Best ROI: Holstein cows'),
            Text('• Peak season: Summer months'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('📈 Detailed analytics coming soon!'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('Detailed Analysis', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  List<String> _getCategoriesForType() {
    switch (selectedEntryType) {
      case 'Income':
        return incomeCategories;
      case 'Expense':
        return expenseCategories;
      case 'Investment':
        return ['Equipment', 'Infrastructure', 'Animals', 'Technology'];
      default:
        return incomeCategories;
    }
  }

  Widget _buildFormRow(String label, Widget field) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: field),
        ],
      ),
    );
  }

  Widget _buildDropdown(String value, List<String> options, Function(String?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          onChanged: onChanged,
          isExpanded: true,
          icon: const Text('▼', style: TextStyle(fontSize: 12)),
          items: options.map((option) => DropdownMenuItem(
            value: option,
            child: Text(option, style: const TextStyle(fontSize: 14)),
          )).toList(),
        ),
      ),
    );
  }

  Widget _buildAmountField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: TextEditingController(text: amount),
        onChanged: (value) => setState(() => amount = value),
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          border: InputBorder.none,
          isDense: true,
          hintText: '_____',
        ),
      ),
    );
  }

  Widget _buildPaymentMethodSelection() {
    return Row(
      children: paymentMethods.map((method) {
        final isSelected = selectedPaymentMethod == method;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => selectedPaymentMethod = method),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF2E7D32) : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? const Color(0xFF2E7D32) : Colors.grey.withOpacity(0.5),
                ),
              ),
              child: Center(
                child: Text(
                  method,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.white : Colors.grey,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildIncomeDetailsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '▼ INCOME DETAILS (if selected)',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                _buildFormRow('Source:', _buildDropdown(selectedSource, incomeSources, (value) => setState(() => selectedSource = value!))),
                
                // Quantity calculation for milk sales
                if (selectedCategory == 'Milk Sales') ...[
                  Row(
                    children: [
                      const SizedBox(width: 120, child: Text('Quantity:', style: TextStyle(fontWeight: FontWeight.w500))),
                      Expanded(
                        child: Row(
                          children: [
                            SizedBox(
                              width: 60,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.withOpacity(0.5)),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: TextField(
                                  controller: TextEditingController(text: quantity),
                                  onChanged: (value) => setState(() {
                                    quantity = value;
                                    _updateAmount();
                                  }),
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    isDense: true,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text('L @ ₹', style: TextStyle(fontSize: 14)),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 60,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.withOpacity(0.5)),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: TextField(
                                  controller: TextEditingController(text: rate),
                                  onChanged: (value) => setState(() {
                                    rate = value;
                                    _updateAmount();
                                  }),
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    isDense: true,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text('/L = ₹${_calculateAmount()}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
                
                const SizedBox(height: 12),
                _buildFormRow('Receipt:', Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _addReceiptImage(),
                      icon: const Text('📷'),
                      label: const Text('Add Image'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green,
                        side: const BorderSide(color: Colors.green),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ],
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseDetailsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '▼ EXPENSE DETAILS (if selected)',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                _buildFormRow('Vendor:', _buildDropdown(selectedVendor, vendors, (value) => setState(() => selectedVendor = value!))),
                _buildFormRow('Items:', Row(
                  children: [
                    Expanded(
                      child: _buildDropdown(selectedItems, feedItems, (value) => setState(() => selectedItems = value!)),
                    ),
                    const SizedBox(width: 8),
                    const Text('200kg', style: TextStyle(fontSize: 14, color: Colors.grey)),
                  ],
                )),
                _buildFormRow('Purpose:', _buildDropdown(selectedPurpose, purposes, (value) => setState(() => selectedPurpose = value!))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _calculateAmount() {
    try {
      final qty = double.tryParse(quantity) ?? 0;
      final r = double.tryParse(rate) ?? 0;
      return (qty * r).toStringAsFixed(0);
    } catch (e) {
      return '0';
    }
  }

  void _updateAmount() {
    amount = _calculateAmount();
  }

  void _addReceiptImage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📷 Receipt image capture coming soon!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _setRecurring() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('🔄 Set Recurring Transaction'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Make this transaction recurring?'),
            SizedBox(height: 12),
            Text('Frequency options:'),
            Text('• Daily (feed costs)'),
            Text('• Weekly (labor payments)'),
            Text('• Monthly (utilities)'),
            Text('• Custom interval'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🔄 Recurring transaction set up!'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('Set Recurring', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _attachBill() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📁 Bill attachment feature coming soon!'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _saveTransaction() {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('💾 ${selectedEntryType.toLowerCase()} transaction saved successfully!'),
        backgroundColor: const Color(0xFF4CAF50),
      ),
    );
  }
}