import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/unified_theme.dart';
import '../models/animal_model.dart';
import '../models/financial_records_model.dart';
import '../../coins/providers/coin_provider.dart';

class AddFinancialRecordScreen extends StatefulWidget {
  final AnimalModel animal;
  final FinancialRecordType recordType;
  
  const AddFinancialRecordScreen({
    super.key,
    required this.animal,
    required this.recordType,
  });

  @override
  State<AddFinancialRecordScreen> createState() => _AddFinancialRecordScreenState();
}

class _AddFinancialRecordScreenState extends State<AddFinancialRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  String? _selectedCategory;
  FinancialRecordStatus _selectedStatus = FinancialRecordStatus.confirmed;
  
  @override
  void initState() {
    super.initState();
    _initializeDefaults();
  }

  void _initializeDefaults() {
    // Set default category based on record type
    if (widget.recordType == FinancialRecordType.income) {
      _selectedCategory = 'Milk Sales';
    } else {
      _selectedCategory = 'Feed & Fodder';
    }
  }

  List<String> get _availableCategories {
    if (widget.recordType == FinancialRecordType.income) {
      return IncomeCategory.values.map((c) => c.displayName).toList();
    } else {
      return ExpenseCategory.values.map((c) => c.displayName).toList();
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.recordType == FinancialRecordType.income 
        ? Colors.green.shade50 
        : Colors.red.shade50,
      appBar: AppBar(
        backgroundColor: widget.recordType == FinancialRecordType.income 
          ? const Color(0xFF4CAF50) 
          : const Color(0xFFF44336),
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${widget.recordType.icon} Add ${widget.recordType.displayName}'),
            Text(
              '${widget.animal.typeEmoji} ${widget.animal.name}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _showQuickTemplates,
            icon: const Icon(Icons.auto_awesome),
            tooltip: 'Quick Templates',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildBasicInfoCard(),
              const SizedBox(height: 16),
              _buildAmountCard(),
              const SizedBox(height: 16),
              _buildCategoryCard(),
              const SizedBox(height: 16),
              _buildDateStatusCard(),
              const SizedBox(height: 16),
              _buildNotesCard(),
              const SizedBox(height: 24),
              _buildSaveButton(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  widget.recordType.icon,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 8),
                Text(
                  'Basic Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: widget.recordType.color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description *',
                hintText: 'Enter transaction description',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '💰 Amount Details',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: widget.recordType.color,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'Amount (₹) *',
                hintText: 'Enter ${widget.recordType.displayName.toLowerCase()} amount',
                border: const OutlineInputBorder(),
                prefixText: '₹ ',
                suffixIcon: IconButton(
                  onPressed: _showCalculator,
                  icon: const Icon(Icons.calculate),
                  tooltip: 'Calculator',
                ),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an amount';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'Please enter a valid amount';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            if (_amountController.text.isNotEmpty)
              _buildAmountPreview(),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountPreview() {
    final amount = double.tryParse(_amountController.text);
    if (amount == null) return const SizedBox();
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.recordType.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: widget.recordType.color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Text(
            widget.recordType == FinancialRecordType.income ? '📈' : '📉',
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Transaction Amount',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  '₹${amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: widget.recordType.color,
                  ),
                ),
              ],
            ),
          ),
          Text(
            widget.recordType.displayName,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: widget.recordType.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📂 Category',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: widget.recordType.color,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: _availableCategories.map((category) {
                String icon = '';
                if (widget.recordType == FinancialRecordType.income) {
                  final incomeCategory = IncomeCategory.values
                      .firstWhere((c) => c.displayName == category);
                  icon = incomeCategory.icon;
                } else {
                  final expenseCategory = ExpenseCategory.values
                      .firstWhere((c) => c.displayName == category);
                  icon = expenseCategory.icon;
                }
                
                return DropdownMenuItem(
                  value: category,
                  child: Row(
                    children: [
                      Text(icon, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Text(category),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select a category';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            _buildCategoryQuickButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryQuickButtons() {
    final quickCategories = widget.recordType == FinancialRecordType.income
        ? ['Milk Sales', 'Calf Sales', 'Other Income']
        : ['Feed & Fodder', 'Medical & Veterinary', 'Other Expenses'];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: quickCategories.map((category) {
        final isSelected = _selectedCategory == category;
        return FilterChip(
          label: Text(category),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _selectedCategory = selected ? category : null;
            });
          },
          selectedColor: widget.recordType.color.withOpacity(0.2),
          backgroundColor: Colors.grey.shade200,
          labelStyle: TextStyle(
            fontSize: 12,
            color: isSelected ? widget.recordType.color : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDateStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📅 Date & Status',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: widget.recordType.color,
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _selectDate,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.grey),
                    const SizedBox(width: 8),
                    const Text('Date: '),
                    Text(
                      DateFormat('dd MMM yyyy').format(_selectedDate),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    const Icon(Icons.arrow_drop_down, color: Colors.grey),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<FinancialRecordStatus>(
              value: _selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              items: FinancialRecordStatus.values.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Row(
                    children: [
                      Text(status.icon),
                      const SizedBox(width: 8),
                      Text(status.displayName),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📝 Additional Notes',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: widget.recordType.color,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                hintText: 'Enter any additional notes, receipt details, or observations',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _saveRecord,
        icon: const Icon(Icons.save),
        label: Text('Save ${widget.recordType.displayName} Record'),
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.recordType.color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 2)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  void _showCalculator() {
    // Show a simple calculator modal or navigate to calculator screen
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quick Calculator'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Common calculations:'),
            const SizedBox(height: 16),
            _buildCalculatorItem('Daily Milk (45L @ ₹25/L)', 1125.0),
            _buildCalculatorItem('Weekly Feed (7 days @ ₹120/day)', 840.0),
            _buildCalculatorItem('Monthly Medical Budget', 500.0),
            _buildCalculatorItem('Calf Sale (6 months old)', 25000.0),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculatorItem(String description, double amount) {
    return ListTile(
      title: Text(description, style: const TextStyle(fontSize: 14)),
      trailing: Text('₹${amount.toStringAsFixed(0)}'),
      onTap: () {
        _amountController.text = amount.toString();
        Navigator.pop(context);
        setState(() {});
      },
    );
  }

  void _showQuickTemplates() {
    final templates = _getQuickTemplates();
    if (templates.isEmpty) return;

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '⚡ Quick Templates - ${widget.recordType.displayName}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...templates.map((template) => ListTile(
              leading: Text(widget.recordType.icon, style: const TextStyle(fontSize: 20)),
              title: Text(template['title']),
              subtitle: Text('${template['category']} - ₹${template['amount']}'),
              onTap: () {
                _descriptionController.text = template['title'];
                _amountController.text = template['amount'].toString();
                _selectedCategory = template['category'];
                setState(() {});
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getQuickTemplates() {
    if (widget.recordType == FinancialRecordType.income) {
      return [
        {'title': 'Daily Milk Sales to Co-operative', 'amount': 1125.0, 'category': 'Milk Sales'},
        {'title': 'Weekly Milk Sales - Direct', 'amount': 8000.0, 'category': 'Milk Sales'},
        {'title': '6-month Calf Sale', 'amount': 25000.0, 'category': 'Calf Sales'},
        {'title': 'Breeding Service Fee', 'amount': 500.0, 'category': 'Breeding Services'},
        {'title': 'Government Subsidy', 'amount': 2000.0, 'category': 'Government Subsidy'},
      ];
    } else {
      return [
        {'title': 'Premium Cattle Feed (25kg)', 'amount': 850.0, 'category': 'Feed & Fodder'},
        {'title': 'Veterinary Consultation', 'amount': 300.0, 'category': 'Medical & Veterinary'},
        {'title': 'Vaccination - FMD', 'amount': 150.0, 'category': 'Medical & Veterinary'},
        {'title': 'AI Service Charges', 'amount': 200.0, 'category': 'Breeding Costs'},
        {'title': 'Transportation to Market', 'amount': 400.0, 'category': 'Transportation'},
      ];
    }
  }

  void _saveRecord() async {
    if (!_formKey.currentState!.validate()) {
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
            Text('Saving financial record...'),
          ],
        ),
      ),
    );

    try {
      final record = FinancialRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        animalId: widget.animal.id,
        type: widget.recordType,
        amount: double.parse(_amountController.text),
        date: _selectedDate,
        description: _descriptionController.text,
        category: _selectedCategory,
        status: _selectedStatus,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Simulate saving to database
      await Future.delayed(const Duration(seconds: 1));

      // Award coins based on record type
      final coinsEarned = widget.recordType == FinancialRecordType.income ? 2 : 3;
      context.read<CoinProvider>().addCoins(coinsEarned, 'Financial Record Added');

      if (mounted) {
        Navigator.pop(context); // Close loading
        Navigator.pop(context, record); // Return to previous screen with record
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${widget.recordType.displayName} record saved successfully! +$coinsEarned coins earned'),
            backgroundColor: Colors.green,
          ),
        );
      }

    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save record: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}