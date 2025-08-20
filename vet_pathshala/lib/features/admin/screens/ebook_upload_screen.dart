import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../../shared/services/enhanced_admin_service.dart';
import '../../../core/theme/unified_theme.dart';

class EbookUploadScreen extends StatefulWidget {
  const EbookUploadScreen({super.key});

  @override
  State<EbookUploadScreen> createState() => _EbookUploadScreenState();
}

class _EbookUploadScreenState extends State<EbookUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  final _subcategoryController = TextEditingController();
  final _pagesController = TextEditingController();
  final _tagsController = TextEditingController();
  
  final EnhancedAdminService _adminService = EnhancedAdminService();
  
  String _selectedAccessLevel = 'free';
  String _selectedLanguage = 'en';
  int _coinCost = 0;
  List<String> _selectedRoles = ['doctor'];
  
  Uint8List? _pdfFile;
  String? _pdfFileName;
  Uint8List? _coverImageFile;
  String? _coverImageFileName;
  
  bool _isUploading = false;
  
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
    'Veterinary Ethics',
    'Practice Management',
  ];
  
  final List<String> _accessLevels = ['free', 'premium'];
  final List<String> _languages = ['en', 'hi', 'es', 'fr', 'de'];
  final List<String> _availableRoles = ['doctor', 'pharmacist', 'farmer'];
  
  final Map<String, String> _languageNames = {
    'en': 'English',
    'hi': 'Hindi',
    'es': 'Spanish',
    'fr': 'French',
    'de': 'German',
  };

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _subcategoryController.dispose();
    _pagesController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload E-book'),
        backgroundColor: UnifiedTheme.primary,
        foregroundColor: Colors.white,
        actions: [
          if (_isUploading)
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
              // File Upload Section
              _buildFileUploadSection(),
              const SizedBox(height: 24),
              
              // Basic Information
              _buildBasicInfoSection(),
              const SizedBox(height: 24),
              
              // Categorization
              _buildCategorizationSection(),
              const SizedBox(height: 24),
              
              // Access and Pricing
              _buildAccessSection(),
              const SizedBox(height: 24),
              
              // Metadata
              _buildMetadataSection(),
              const SizedBox(height: 24),
              
              // Target Roles
              _buildTargetRolesSection(),
              const SizedBox(height: 24),
              
              // Tags
              _buildTagsSection(),
              const SizedBox(height: 32),
              
              // Upload Button
              _buildUploadButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFileUploadSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Files',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // PDF File
            const Text('PDF File *'),
            const SizedBox(height: 8),
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
                          _pdfFile != null ? Icons.picture_as_pdf : Icons.upload_file,
                          color: _pdfFile != null ? Colors.red : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _pdfFileName ?? 'No PDF selected',
                            style: TextStyle(
                              color: _pdfFile != null ? Colors.black : Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _pickPdfFile,
                  child: const Text('Browse'),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Cover Image
            const Text('Cover Image (Optional)'),
            const SizedBox(height: 8),
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
                          _coverImageFile != null ? Icons.image : Icons.image_outlined,
                          color: _coverImageFile != null ? Colors.green : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _coverImageFileName ?? 'No cover image selected',
                            style: TextStyle(
                              color: _coverImageFile != null ? Colors.black : Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _pickCoverImageFile,
                  child: const Text('Browse'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title *',
                hintText: 'Enter book title',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Title is required';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _authorController,
              decoration: const InputDecoration(
                labelText: 'Author *',
                hintText: 'Enter author name(s)',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Author is required';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description *',
                hintText: 'Enter detailed book description',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Description is required';
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
                hintText: 'e.g., Small Animal Surgery',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccessSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Access & Pricing',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            DropdownButtonFormField<String>(
              value: _selectedAccessLevel,
              decoration: const InputDecoration(
                labelText: 'Access Level *',
                border: OutlineInputBorder(),
              ),
              items: _accessLevels.map((level) {
                return DropdownMenuItem(
                  value: level,
                  child: Text(level.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedAccessLevel = value!;
                });
              },
            ),
            
            if (_selectedAccessLevel == 'premium') ...[
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Coin Cost *',
                  hintText: '0',
                  border: OutlineInputBorder(),
                  suffixText: 'coins',
                ),
                keyboardType: TextInputType.number,
                initialValue: _coinCost.toString(),
                onChanged: (value) {
                  _coinCost = int.tryParse(value) ?? 0;
                },
                validator: _selectedAccessLevel == 'premium' ? (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Coin cost is required for premium content';
                  }
                  final cost = int.tryParse(value);
                  if (cost == null || cost < 0) {
                    return 'Enter a valid coin cost';
                  }
                  return null;
                } : null,
              ),
            ],
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
              'Metadata',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _pagesController,
                    decoration: const InputDecoration(
                      labelText: 'Number of Pages',
                      hintText: '0',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedLanguage,
                    decoration: const InputDecoration(
                      labelText: 'Language *',
                      border: OutlineInputBorder(),
                    ),
                    items: _languages.map((lang) {
                      return DropdownMenuItem(
                        value: lang,
                        child: Text(_languageNames[lang] ?? lang.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedLanguage = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetRolesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Target Roles',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
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
                hintText: 'textbook, reference, anatomy (comma-separated)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isUploading ? null : _uploadEbook,
        style: ElevatedButton.styleFrom(
          backgroundColor: UnifiedTheme.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: _isUploading
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
                  Text('Uploading...'),
                ],
              )
            : const Text(
                'Upload E-book',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Future<void> _pickPdfFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.bytes != null) {
        setState(() {
          _pdfFile = result.files.single.bytes!;
          _pdfFileName = result.files.single.name;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking PDF: $e')),
      );
    }
  }

  Future<void> _pickCoverImageFile() async {
    try {
      final picker = ImagePicker();
      final result = await picker.pickImage(source: ImageSource.gallery);
      
      if (result != null) {
        final bytes = await result.readAsBytes();
        setState(() {
          _coverImageFile = bytes;
          _coverImageFileName = result.name;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking cover image: $e')),
      );
    }
  }

  Future<void> _uploadEbook() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_pdfFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a PDF file')),
      );
      return;
    }

    if (_selectedRoles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one target role')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final tags = _tagsController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();

      final pages = int.tryParse(_pagesController.text) ?? 0;

      final ebookId = await _adminService.uploadEbook(
        title: _titleController.text.trim(),
        author: _authorController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _categoryController.text.trim(),
        subcategory: _subcategoryController.text.trim(),
        targetRoles: _selectedRoles,
        accessLevel: _selectedAccessLevel,
        coinCost: _coinCost,
        pages: pages,
        language: _selectedLanguage,
        tags: tags,
        pdfFile: _pdfFile!,
        pdfFileName: _pdfFileName!,
        coverImageFile: _coverImageFile,
        coverImageFileName: _coverImageFileName,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('E-book uploaded successfully! ID: $ebookId'),
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
            content: Text('Upload failed: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }
}