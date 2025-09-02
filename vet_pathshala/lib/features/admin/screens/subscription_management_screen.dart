import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/unified_theme.dart';
import '../../payments/services/dynamic_subscription_service.dart';
import '../../payments/models/subscription_model.dart';

class SubscriptionManagementScreen extends StatefulWidget {
  const SubscriptionManagementScreen({super.key});

  @override
  State<SubscriptionManagementScreen> createState() => _SubscriptionManagementScreenState();
}

class _SubscriptionManagementScreenState extends State<SubscriptionManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final DynamicSubscriptionService _subscriptionService = DynamicSubscriptionService();
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }
  
  Future<void> _loadData() async {
    await Future.wait([
      _subscriptionService.loadSubscriptionPlans(),
      _subscriptionService.loadFeatureSubscriptions(),
    ]);
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UnifiedTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Subscription Management'),
        backgroundColor: UnifiedTheme.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Plans', icon: Icon(Icons.subscriptions)),
            Tab(text: 'Features', icon: Icon(Icons.featured_play_list)),
            Tab(text: 'Analytics', icon: Icon(Icons.analytics)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSubscriptionPlansTab(),
          _buildFeatureSubscriptionsTab(),
          _buildAnalyticsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreatePlanDialog,
        backgroundColor: UnifiedTheme.primaryGreen,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSubscriptionPlansTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: Column(
        children: [
          // Header Stats
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Plans',
                    '${_subscriptionService.plans.length}',
                    Icons.subscriptions,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Active Plans',
                    '${_subscriptionService.plans.where((p) => p.isActive).length}',
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // Plans List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _subscriptionService.plans.length,
              itemBuilder: (context, index) {
                final plan = _subscriptionService.plans[index];
                return _buildPlanCard(plan);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureSubscriptionsTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Features',
                    '${_subscriptionService.featureSubscriptions.length}',
                    Icons.featured_play_list,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _showCreateFeatureDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Feature'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: UnifiedTheme.primaryGreen,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // Features List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _subscriptionService.featureSubscriptions.length,
              itemBuilder: (context, index) {
                final feature = _subscriptionService.featureSubscriptions[index];
                return _buildFeatureCard(feature);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 80,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Analytics Dashboard',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Coming Soon',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(SubscriptionPlan plan) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: plan.isActive ? UnifiedTheme.primaryGreen.withOpacity(0.1) : Colors.red.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            plan.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (plan.isPopular) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'POPULAR',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        plan.description,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${plan.price}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: UnifiedTheme.primaryGreen,
                      ),
                    ),
                    Text(
                      plan.durationText,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status and Category
                Row(
                  children: [
                    _buildChip(
                      plan.isActive ? 'Active' : 'Inactive',
                      plan.isActive ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    _buildChip(plan.category.toUpperCase(), Colors.blue),
                    const Spacer(),
                    Text(
                      'Max ${plan.maxDevices} device${plan.maxDevices > 1 ? 's' : ''}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Features
                if (plan.features.isNotEmpty) ...[
                  const Text(
                    'Features:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: plan.features.map((feature) => 
                      Chip(
                        label: Text(
                          feature,
                          style: const TextStyle(fontSize: 12),
                        ),
                        backgroundColor: Colors.grey.shade200,
                      ),
                    ).toList(),
                  ),
                  const SizedBox(height: 12),
                ],
                
                // Target Roles
                if (plan.targetRoles.isNotEmpty) ...[
                  const Text(
                    'Target Roles:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 4,
                    children: plan.targetRoles.map((role) => 
                      _buildChip(role.toUpperCase(), Colors.purple),
                    ).toList(),
                  ),
                  const SizedBox(height: 12),
                ],
                
                // Actions
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _editPlan(plan),
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('Edit'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _togglePlanStatus(plan),
                        icon: Icon(
                          plan.isActive ? Icons.visibility_off : Icons.visibility,
                          size: 16,
                        ),
                        label: Text(plan.isActive ? 'Deactivate' : 'Activate'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: plan.isActive ? Colors.red : Colors.green,
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

  Widget _buildFeatureCard(FeatureSubscription feature) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        feature.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        feature.description,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${feature.price}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: UnifiedTheme.primaryGreen,
                      ),
                    ),
                    Text(
                      '${feature.duration} days',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                _buildChip(feature.featureId.toUpperCase(), Colors.orange),
                const SizedBox(width: 8),
                _buildChip(feature.isActive ? 'Active' : 'Inactive', 
                    feature.isActive ? Colors.green : Colors.red),
                const Spacer(),
                IconButton(
                  onPressed: () => _editFeature(feature),
                  icon: const Icon(Icons.edit),
                  tooltip: 'Edit Feature',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Dialog Methods
  void _showCreatePlanDialog() {
    _showPlanDialog();
  }

  void _showCreateFeatureDialog() {
    _showFeatureDialog();
  }

  void _editPlan(SubscriptionPlan plan) {
    _showPlanDialog(plan: plan);
  }

  void _editFeature(FeatureSubscription feature) {
    _showFeatureDialog(feature: feature);
  }

  void _showPlanDialog({SubscriptionPlan? plan}) {
    final isEdit = plan != null;
    final formKey = GlobalKey<FormState>();
    
    final nameController = TextEditingController(text: plan?.name ?? '');
    final descController = TextEditingController(text: plan?.description ?? '');
    final priceController = TextEditingController(text: plan?.price.toString() ?? '');
    final durationController = TextEditingController(text: plan?.duration.toString() ?? '30');
    final maxDevicesController = TextEditingController(text: plan?.maxDevices.toString() ?? '1');
    
    String selectedCategory = plan?.category ?? 'notes';
    List<String> features = List.from(plan?.features ?? []);
    List<String> featureIds = List.from(plan?.featureIds ?? []);
    List<String> targetRoles = List.from(plan?.targetRoles ?? []);
    bool isPopular = plan?.isPopular ?? false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(isEdit ? 'Edit Subscription Plan' : 'Create Subscription Plan'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Plan Name'),
                    validator: (v) => v?.isEmpty == true ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: descController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 2,
                    validator: (v) => v?.isEmpty == true ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: priceController,
                    decoration: const InputDecoration(labelText: 'Price (₹)'),
                    keyboardType: TextInputType.number,
                    validator: (v) => v?.isEmpty == true ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: durationController,
                    decoration: const InputDecoration(labelText: 'Duration (days)'),
                    keyboardType: TextInputType.number,
                    validator: (v) => v?.isEmpty == true ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: maxDevicesController,
                    decoration: const InputDecoration(labelText: 'Max Devices'),
                    keyboardType: TextInputType.number,
                    validator: (v) => v?.isEmpty == true ? 'Required' : null,
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: ['notes', 'quiz', 'premium', 'drug_center', 'lecture', 'ebooks', 'gamification']
                        .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                        .toList(),
                    onChanged: (value) => setState(() => selectedCategory = value!),
                  ),
                  CheckboxListTile(
                    title: const Text('Popular Plan'),
                    value: isPopular,
                    onChanged: (value) => setState(() => isPopular = value!),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  bool success;
                  if (isEdit) {
                    success = await _subscriptionService.updateSubscriptionPlan(
                      plan!.id,
                      {
                        'name': nameController.text,
                        'description': descController.text,
                        'price': double.parse(priceController.text),
                        'duration': int.parse(durationController.text),
                        'maxDevices': int.parse(maxDevicesController.text),
                        'category': selectedCategory,
                        'isPopular': isPopular,
                      },
                    );
                  } else {
                    success = await _subscriptionService.createSubscriptionPlan(
                      name: nameController.text,
                      description: descController.text,
                      price: double.parse(priceController.text),
                      currency: 'INR',
                      duration: int.parse(durationController.text),
                      features: features,
                      category: selectedCategory,
                      featureIds: featureIds,
                      isPopular: isPopular,
                      targetRoles: targetRoles,
                      maxDevices: int.parse(maxDevicesController.text),
                    );
                  }
                  
                  if (success) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(isEdit ? 'Plan updated!' : 'Plan created!')),
                    );
                    setState(() {});
                  }
                }
              },
              child: Text(isEdit ? 'Update' : 'Create'),
            ),
          ],
        ),
      ),
    );
  }

  void _showFeatureDialog({FeatureSubscription? feature}) {
    final isEdit = feature != null;
    final formKey = GlobalKey<FormState>();
    
    final featureIdController = TextEditingController(text: feature?.featureId ?? '');
    final nameController = TextEditingController(text: feature?.name ?? '');
    final descController = TextEditingController(text: feature?.description ?? '');
    final priceController = TextEditingController(text: feature?.price.toString() ?? '');
    final durationController = TextEditingController(text: feature?.duration.toString() ?? '30');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Edit Feature Subscription' : 'Create Feature Subscription'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: featureIdController,
                decoration: const InputDecoration(labelText: 'Feature ID'),
                enabled: !isEdit,
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Feature Name'),
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              TextFormField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 2,
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              TextFormField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Price (₹)'),
                keyboardType: TextInputType.number,
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              TextFormField(
                controller: durationController,
                decoration: const InputDecoration(labelText: 'Duration (days)'),
                keyboardType: TextInputType.number,
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final success = await _subscriptionService.createFeatureSubscription(
                  featureId: featureIdController.text,
                  name: nameController.text,
                  description: descController.text,
                  price: double.parse(priceController.text),
                  currency: 'INR',
                  duration: int.parse(durationController.text),
                );
                
                if (success) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Feature created!')),
                  );
                  setState(() {});
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Future<void> _togglePlanStatus(SubscriptionPlan plan) async {
    final success = await _subscriptionService.updateSubscriptionPlan(
      plan.id,
      {'isActive': !plan.isActive},
    );
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(plan.isActive ? 'Plan deactivated' : 'Plan activated'),
        ),
      );
      setState(() {});
    }
  }
}