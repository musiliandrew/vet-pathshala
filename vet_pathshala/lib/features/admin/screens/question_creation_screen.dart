import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../../../shared/services/enhanced_admin_service.dart';
import '../../../core/theme/unified_theme.dart';

class QuestionCreationScreen extends StatefulWidget {
  const QuestionCreationScreen({super.key});

  @override
  State<QuestionCreationScreen> createState() => _QuestionCreationScreenState();
}

class _QuestionCreationScreenState extends State<QuestionCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final _explanationController = TextEditingController();
  final _categoryController = TextEditingController();
  final _subcategoryController = TextEditingController();
  final _subjectController = TextEditingController();
  final _topicController = TextEditingController();
  final _tagsController = TextEditingController();
  
  final List<TextEditingController> _optionControllers = List.generate(
    4,
    (index) => TextEditingController(),
  );
  
  final EnhancedAdminService _adminService = EnhancedAdminService();
  
  String _selectedQuestionType = 'mcq';
  String _selectedDifficulty = 'easy';
  int _correctAnswerIndex = 0;
  String _correctAnswer = '';
  List<String> _selectedRoles = ['doctor'];
  
  Uint8List? _imageFile;
  String? _imageFileName;
  
  bool _isCreating = false;
  
  final List<String> _questionTypes = ['mcq', 'true_false', 'fill_blank'];
  final List<String> _difficulties = ['easy', 'medium', 'hard'];
  final List<String> _availableRoles = ['doctor', 'pharmacist', 'farmer'];
  
  final List<String> _commonCategories = [
    'Veterinary Medicine',
    'Animal Anatomy',
    'Pharmacology',
    'Surgery',
    'Pathology',
    'Microbiology',
    'Animal Husbandry',
    'Parasitology',
    'Clinical Medicine',
    'Public Health',
  ];

  @override
  void dispose() {
    _questionController.dispose();
    _explanationController.dispose();
    _categoryController.dispose();
    _subcategoryController.dispose();
    _subjectController.dispose();
    _topicController.dispose();
    _tagsController.dispose();
    
    for (final controller in _optionControllers) {
      controller.dispose();
    }
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Question'),
        backgroundColor: UnifiedTheme.primary,
        foregroundColor: Colors.white,
        actions: [
          if (_isCreating)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Question Type Selection
              _buildQuestionTypeSection(),
              const SizedBox(height: 24),
              
              // Question Content
              _buildQuestionContentSection(),
              const SizedBox(height: 24),
              
              // Answer Options (for MCQ and True/False)
              if (_selectedQuestionType == 'mcq' || _selectedQuestionType == 'true_false')
                _buildAnswerOptionsSection(),
              
              // Fill in the blank answer
              if (_selectedQuestionType == 'fill_blank')
                _buildFillBlankSection(),
              
              const SizedBox(height: 24),
              
              // Explanation
              _buildExplanationSection(),
              const SizedBox(height: 24),
              
              // Categorization
              _buildCategorizationSection(),
              const SizedBox(height: 24),
              
              // Difficulty and Target Roles
              _buildMetadataSection(),
              const SizedBox(height: 24),
              
              // Tags
              _buildTagsSection(),
              const SizedBox(height: 24),
              
              // Image Upload (Optional)
              _buildImageSection(),
              const SizedBox(height: 32),
              
              // Create Button
              _buildCreateButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionTypeSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Question Type',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            DropdownButtonFormField<String>(
              value: _selectedQuestionType,
              decoration: const InputDecoration(
                labelText: 'Type *',
                border: OutlineInputBorder(),
              ),
              items: _questionTypes.map((type) {
                String displayName;
                switch (type) {
                  case 'mcq':
                    displayName = 'Multiple Choice Question';
                    break;
                  case 'true_false':
                    displayName = 'True/False';
                    break;
                  case 'fill_blank':
                    displayName = 'Fill in the Blank';
                    break;
                  default:
                    displayName = type;
                }
                return DropdownMenuItem(
                  value: type,
                  child: Text(displayName),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedQuestionType = value!;
                  _correctAnswerIndex = 0;
                  _correctAnswer = '';
                  // Clear options when switching types
                  for (final controller in _optionControllers) {
                    controller.clear();
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionContentSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Question Content',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _questionController,
              decoration: const InputDecoration(
                labelText: 'Question *',
                hintText: 'Enter your question here',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Question is required';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerOptionsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Answer Options',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            if (_selectedQuestionType == 'mcq') ...[
              // Multiple choice options
              for (int i = 0; i < 4; i++) ...[
                Row(
                  children: [
                    Radio<int>(
                      value: i,
                      groupValue: _correctAnswerIndex,
                      onChanged: (value) {
                        setState(() {
                          _correctAnswerIndex = value!;
                        });
                      },
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: _optionControllers[i],
                        decoration: InputDecoration(
                          labelText: 'Option ${String.fromCharCode(65 + i)} *',
                          hintText: 'Enter option ${String.fromCharCode(65 + i)}',
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Option ${String.fromCharCode(65 + i)} is required';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ] else if (_selectedQuestionType == 'true_false') ...[
              // True/False options
              Row(
                children: [
                  Radio<int>(
                    value: 0,
                    groupValue: _correctAnswerIndex,
                    onChanged: (value) {
                      setState(() {
                        _correctAnswerIndex = value!;
                      });
                    },
                  ),
                  const Text('True'),
                  const SizedBox(width: 32),
                  Radio<int>(
                    value: 1,
                    groupValue: _correctAnswerIndex,
                    onChanged: (value) {
                      setState(() {
                        _correctAnswerIndex = value!;
                      });
                    },
                  ),
                  const Text('False'),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFillBlankSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Correct Answer',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Answer *',
                hintText: 'Enter the correct answer',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                _correctAnswer = value;
              },
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Answer is required';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExplanationSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Explanation',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _explanationController,
              decoration: const InputDecoration(
                labelText: 'Explanation *',
                hintText: 'Explain why this is the correct answer',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Explanation is required';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorizationSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Categorization',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _categoryController,
              decoration: InputDecoration(
                labelText: 'Category *',
                hintText: 'e.g., Veterinary Medicine',
                border: const OutlineInputBorder(),
                suffixIcon: PopupMenuButton<String>(
                  icon: const Icon(Icons.arrow_drop_down),
                  onSelected: (value) {
                    _categoryController.text = value;
                  },
                  itemBuilder: (context) => _commonCategories
                      .map((category) => PopupMenuItem(
                            value: category,
                            child: Text(category),
                          ))
                      .toList(),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Category is required';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _subcategoryController,
              decoration: const InputDecoration(
                labelText: 'Subcategory (Optional)',
                hintText: 'e.g., Small Animal Medicine',
                border: OutlineInputBorder(),
              ),
            ),
            
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _subjectController,
              decoration: const InputDecoration(
                labelText: 'Subject *',
                hintText: 'e.g., Anatomy',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Subject is required';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _topicController,
              decoration: const InputDecoration(
                labelText: 'Topic *',
                hintText: 'e.g., Skeletal System',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Topic is required';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetadataSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Difficulty & Target Audience',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            DropdownButtonFormField<String>(
              value: _selectedDifficulty,
              decoration: const InputDecoration(
                labelText: 'Difficulty Level *',
                border: OutlineInputBorder(),
              ),
              items: _difficulties.map((difficulty) {
                return DropdownMenuItem(
                  value: difficulty,
                  child: Text(difficulty.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDifficulty = value!;
                });
              },
            ),
            
            const SizedBox(height: 16),
            
            const Text('Target Roles *'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableRoles.map((role) {
                final isSelected = _selectedRoles.contains(role);
                return FilterChip(
                  label: Text(role.toUpperCase()),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedRoles.add(role);
                      } else {
                        _selectedRoles.remove(role);
                      }
                    });
                  },
                  selectedColor: UnifiedTheme.primary.withOpacity(0.3),
                  checkmarkColor: UnifiedTheme.primary,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tags',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _tagsController,
              decoration: const InputDecoration(
                labelText: 'Tags (Optional)',
                hintText: 'anatomy, bones, structure (comma-separated)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Question Image (Optional)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _imageFile != null ? Icons.image : Icons.image_outlined,
                          color: _imageFile != null ? Colors.green : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _imageFileName ?? 'No image selected',
                            style: TextStyle(
                              color: _imageFile != null ? Colors.black : Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _pickImageFile,
                  child: const Text('Browse'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isCreating ? null : _createQuestion,
        style: ElevatedButton.styleFrom(
          backgroundColor: UnifiedTheme.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: _isCreating
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text('Creating...'),
                ],
              )
            : const Text(
                'Create Question',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Future<void> _pickImageFile() async {
    try {
      final picker = ImagePicker();
      final result = await picker.pickImage(source: ImageSource.gallery);
      
      if (result != null) {
        final bytes = await result.readAsBytes();
        setState(() {
          _imageFile = bytes;
          _imageFileName = result.name;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<void> _createQuestion() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedRoles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one target role')),
      );
      return;
    }

    setState(() {
      _isCreating = true;
    });

    try {
      // Prepare options and correct answer based on question type
      List<String> options = [];
      String correctAnswer = '';

      switch (_selectedQuestionType) {
        case 'mcq':
          options = _optionControllers
              .map((controller) => controller.text.trim())
              .toList();
          correctAnswer = _optionControllers[_correctAnswerIndex].text.trim();
          break;
        case 'true_false':
          options = ['True', 'False'];
          correctAnswer = _correctAnswerIndex == 0 ? 'True' : 'False';
          break;
        case 'fill_blank':
          options = [];
          correctAnswer = _correctAnswer.trim();
          break;
      }

      final tags = _tagsController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();

      final questionId = await _adminService.addQuestion(
        question: _questionController.text.trim(),
        questionType: _selectedQuestionType,
        options: options,
        correctAnswer: correctAnswer,
        explanation: _explanationController.text.trim(),
        category: _categoryController.text.trim(),
        subcategory: _subcategoryController.text.trim(),
        subject: _subjectController.text.trim(),
        topic: _topicController.text.trim(),
        difficulty: _selectedDifficulty,
        targetRoles: _selectedRoles,
        tags: tags,
        imageFile: _imageFile,
        imageFileName: _imageFileName,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Question created successfully! ID: $questionId'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
        
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Creation failed: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }
}