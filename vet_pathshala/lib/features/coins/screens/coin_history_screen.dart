import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/coin_provider.dart';
import '../services/coin_service.dart';
import '../../../features/auth/providers/auth_provider.dart';

class CoinHistoryScreen extends StatefulWidget {
  const CoinHistoryScreen({super.key});

  @override
  State<CoinHistoryScreen> createState() => _CoinHistoryScreenState();
}

class _CoinHistoryScreenState extends State<CoinHistoryScreen> {
  String _selectedFilter = 'all';
  
  final Map<String, String> _filterOptions = {
    'all': 'All Transactions',
    'earn': 'Earned',
    'spend': 'Spent',
    'purchase': 'Purchased',
  };

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  void _loadTransactions() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      final coinProvider = context.read<CoinProvider>();
      
      if (authProvider.currentUser != null) {
        coinProvider.loadTransactions(authProvider.currentUser!.id, refresh: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Coin History',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedFilter = value;
              });
            },
            itemBuilder: (context) => _filterOptions.entries
                .map((entry) => PopupMenuItem<String>(
                      value: entry.key,
                      child: Text(entry.value),
                    ))
                .toList(),
            child: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer2<CoinProvider, AuthProvider>(
          builder: (context, coinProvider, authProvider, child) {
            if (coinProvider.isLoading && coinProvider.transactions.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading transaction history...'),
                  ],
                ),
              );
            }

            final filteredTransactions = _getFilteredTransactions(coinProvider.transactions);

            if (filteredTransactions.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.history,
                      size: 64,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No transactions found',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _selectedFilter == 'all' 
                          ? 'Start earning coins to see your history'
                          : 'No ${_filterOptions[_selectedFilter]?.toLowerCase()} transactions',
                      style: const TextStyle(color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => coinProvider.loadTransactions(
                authProvider.currentUser?.id ?? '',
                refresh: true,
              ),
              child: Column(
                children: [
                  // Summary Card
                  if (_selectedFilter == 'all') _buildSummaryCard(coinProvider),
                  
                  // Filter Chips
                  _buildFilterChips(),
                  
                  // Transaction List
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: filteredTransactions.length,
                      itemBuilder: (context, index) {
                        final transaction = filteredTransactions[index];
                        return _buildTransactionCard(transaction);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSummaryCard(CoinProvider coinProvider) {
    final stats = coinProvider.stats;
    if (stats == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    const Text(
                      'Total Earned',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${stats.totalEarned}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white30,
              ),
              Expanded(
                child: Column(
                  children: [
                    const Text(
                      'Total Spent',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${stats.totalSpent}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white30,
              ),
              Expanded(
                child: Column(
                  children: [
                    const Text(
                      'Current Balance',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${coinProvider.currentBalance}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: _filterOptions.entries.map((entry) {
          final isSelected = _selectedFilter == entry.key;
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(entry.value),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = entry.key;
                });
              },
              backgroundColor: AppColors.surface,
              selectedColor: AppColors.primary.withOpacity(0.1),
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.border,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTransactionCard(CoinTransaction transaction) {
    final isEarned = transaction.type == CoinService.transactionTypeEarn;
    final isPurchase = transaction.type == CoinService.transactionTypePurchase;
    
    Color color;
    IconData icon;
    String prefix;
    
    if (isPurchase) {
      color = AppColors.info;
      icon = Icons.shopping_cart;
      prefix = '+';
    } else if (isEarned) {
      color = AppColors.success;
      icon = Icons.add_circle;
      prefix = '+';
    } else {
      color = AppColors.error;
      icon = Icons.remove_circle;
      prefix = '-';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.description,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatTransactionType(transaction.type, transaction.reason),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$prefix${transaction.amount} 🪙',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: color,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDateTime(transaction.createdAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            // Balance info
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.textTertiary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Balance: ${transaction.balanceBefore} → ${transaction.balanceAfter}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            
            // Additional metadata if available
            if (transaction.metadata.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildMetadataInfo(transaction.metadata),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetadataInfo(Map<String, dynamic> metadata) {
    final List<Widget> metadataWidgets = [];
    
    // Show relevant metadata based on transaction type
    if (metadata['questionsCorrect'] != null && metadata['totalQuestions'] != null) {
      metadataWidgets.add(
        _buildMetadataChip(
          'Quiz: ${metadata['questionsCorrect']}/${metadata['totalQuestions']} correct',
          Icons.quiz,
        ),
      );
    }
    
    if (metadata['packageId'] != null) {
      metadataWidgets.add(
        _buildMetadataChip(
          'Package: ${metadata['packageId']}',
          Icons.shopping_bag,
        ),
      );
    }
    
    if (metadata['feature'] != null) {
      metadataWidgets.add(
        _buildMetadataChip(
          'Feature: ${metadata['feature'].toString().replaceAll('_', ' ')}',
          Icons.star,
        ),
      );
    }
    
    if (metadata['adProvider'] != null) {
      metadataWidgets.add(
        _buildMetadataChip(
          'Ad viewed',
          Icons.play_circle,
        ),
      );
    }

    if (metadataWidgets.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      children: metadataWidgets,
    );
  }

  Widget _buildMetadataChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: AppColors.info,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.info,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  List<CoinTransaction> _getFilteredTransactions(List<CoinTransaction> transactions) {
    if (_selectedFilter == 'all') {
      return transactions;
    }
    
    return transactions.where((transaction) {
      return transaction.type == _selectedFilter;
    }).toList();
  }

  String _formatTransactionType(String type, String reason) {
    switch (type) {
      case 'earn':
        switch (reason) {
          case 'quiz_complete':
            return 'Quiz Completion';
          case 'daily_login':
            return 'Daily Login Bonus';
          case 'referral':
            return 'Referral Reward';
          case 'achievement':
            return 'Achievement Reward';
          case 'watch_ad':
            return 'Video Ad Reward';
          default:
            return 'Earned';
        }
      case 'spend':
        switch (reason) {
          case 'drug_calculator':
            return 'Drug Calculator';
          case 'interaction_checker':
            return 'Interaction Checker';
          case 'prescription_helper':
            return 'Prescription Helper';
          case 'premium_content':
            return 'Premium Content';
          default:
            return 'Spent';
        }
      case 'purchase':
        return 'Coin Purchase';
      default:
        return type.toUpperCase();
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}