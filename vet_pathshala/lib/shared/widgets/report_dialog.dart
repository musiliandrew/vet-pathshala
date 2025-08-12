import 'package:flutter/material.dart';
import '../../core/theme/unified_theme.dart';
import '../../core/services/user_interaction_service.dart';

class ReportDialog extends StatefulWidget {
  final String contentId;
  final String contentType;
  final String userId;
  final String? contentTitle;
  final VoidCallback? onReported;

  const ReportDialog({
    super.key,
    required this.contentId,
    required this.contentType,
    required this.userId,
    this.contentTitle,
    this.onReported,
  });

  @override
  State<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  final UserInteractionService _interactionService = UserInteractionService();
  final TextEditingController _descriptionController = TextEditingController();
  
  String? _selectedReason;
  bool _isSubmitting = false;
  
  final List<Map<String, dynamic>> _reportReasons = [
    {
      'id': 'inappropriate_content',
      'title': 'Inappropriate Content',
      'description': 'Contains offensive, harmful, or inappropriate material',
      'icon': Icons.warning_outlined,
    },
    {
      'id': 'incorrect_information',
      'title': 'Incorrect Information',
      'description': 'Contains factually incorrect or misleading information',
      'icon': Icons.error_outline,
    },
    {
      'id': 'spam',
      'title': 'Spam',
      'description': 'Unwanted or repetitive content',
      'icon': Icons.block_outlined,
    },
    {
      'id': 'copyright_violation',
      'title': 'Copyright Violation',
      'description': 'Unauthorized use of copyrighted material',
      'icon': Icons.copyright_outlined,
    },
    {
      'id': 'technical_issue',
      'title': 'Technical Issue',
      'description': 'Content has formatting, display, or functionality problems',
      'icon': Icons.bug_report_outlined,
    },
    {
      'id': 'other',
      'title': 'Other',
      'description': 'Other concerns not listed above',
      'icon': Icons.help_outline,
    },
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    if (_selectedReason == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a reason for reporting'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final success = await _interactionService.reportContent(
        userId: widget.userId,
        contentId: widget.contentId,
        contentType: widget.contentType,
        reason: _selectedReason!,
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
      );

      if (success) {
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Report submitted successfully. Thank you for your feedback.'),
              backgroundColor: UnifiedTheme.primaryGreen,
              behavior: SnackBarBehavior.floating,
            ),
          );
          widget.onReported?.call();
        }
      } else {
        throw Exception('Failed to submit report');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit report: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.flag_outlined,
                    color: Colors.red.shade600,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Report Content',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.red.shade700,
                          ),
                        ),
                        if (widget.contentTitle != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            widget.contentTitle!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.red.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    color: Colors.red.shade600,
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Why are you reporting this ${widget.contentType}?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: UnifiedTheme.primaryText,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Report Reasons
                    ..._reportReasons.map((reason) => _buildReasonOption(reason)).toList(),

                    const SizedBox(height: 20),

                    // Additional Description
                    Text(
                      'Additional Details (Optional)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: UnifiedTheme.primaryText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Provide additional context or details about the issue...',
                        hintStyle: TextStyle(color: UnifiedTheme.tertiaryText),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: UnifiedTheme.primaryGreen),
                        ),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: UnifiedTheme.secondaryText),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitReport,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Submit Report'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReasonOption(Map<String, dynamic> reason) {
    final isSelected = _selectedReason == reason['id'];
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedReason = reason['id'];
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected 
              ? Colors.red.shade50 
              : Colors.grey.shade50,
          border: Border.all(
            color: isSelected 
                ? Colors.red.shade300 
                : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              reason['icon'] as IconData,
              color: isSelected 
                  ? Colors.red.shade600 
                  : UnifiedTheme.tertiaryText,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reason['title'],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isSelected 
                          ? Colors.red.shade700 
                          : UnifiedTheme.primaryText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    reason['description'],
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected 
                          ? Colors.red.shade600 
                          : UnifiedTheme.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Colors.red.shade600,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}