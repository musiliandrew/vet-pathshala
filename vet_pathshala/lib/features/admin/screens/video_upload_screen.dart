import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../../../shared/services/enhanced_admin_service.dart';
import '../../../core/theme/unified_theme.dart';

class VideoUploadScreen extends StatefulWidget {
  const VideoUploadScreen({super.key});

  @override
  State<VideoUploadScreen> createState() => _VideoUploadScreenState();
}

class _VideoUploadScreenState extends State<VideoUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _instructorController = TextEditingController();
  final _instructorBioController = TextEditingController();
  final _subcategoryController = TextEditingController();
  final _tagsController = TextEditingController();
  
  final EnhancedAdminService _adminService = EnhancedAdminService();
  
  String _selectedCategory = 'Veterinary Medicine';
  String _selectedDifficulty = 'beginner';
  String _selectedAccessLevel = 'free';
  int _coinCost = 0;
  List<String> _selectedRoles = ['doctor'];
  
  Uint8List? _videoFile;
  String? _videoFileName;
  Uint8List? _thumbnailFile;
  String? _thumbnailFileName;
  
  bool _isUploading = false;
  
  final List<String> _categories = [
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
  
  final List<String> _difficulties = ['beginner', 'intermediate', 'advanced'];
  final List<String> _accessLevels = ['free', 'premium'];
  final List<String> _availableRoles = ['doctor', 'pharmacist', 'farmer'];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _instructorController.dispose();
    _instructorBioController.dispose();
    _subcategoryController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Video'),
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
              // Video File Selection
              _buildFileSelectionSection(),
              const SizedBox(height: 24),
              
              // Basic Information
              _buildBasicInfoSection(),
              const SizedBox(height: 24),
              
              // Instructor Information
              _buildInstructorSection(),
              const SizedBox(height: 24),
              
              // Categorization
              _buildCategorizationSection(),
              const SizedBox(height: 24),
              
              // Access and Pricing
              _buildAccessSection(),
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

  Widget _buildFileSelectionSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Media Files',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Video File
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Video File *'),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _videoFile != null ? Icons.video_file : Icons.video_call,
                              color: _videoFile != null ? Colors.green : Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _videoFileName ?? 'No video selected',
                                style: TextStyle(
                                  color: _videoFile != null ? Colors.black : Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _pickVideoFile,
                  child: const Text('Browse'),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Thumbnail File
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Thumbnail (Optional)'),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _thumbnailFile != null ? Icons.image : Icons.image_outlined,
                              color: _thumbnailFile != null ? Colors.green : Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _thumbnailFileName ?? 'No thumbnail selected',
                                style: TextStyle(
                                  color: _thumbnailFile != null ? Colors.black : Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _pickThumbnailFile,
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
                hintText: 'Enter video title',
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
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description *',
                hintText: 'Enter detailed video description',
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

  Widget _buildInstructorSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Instructor Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _instructorController,
              decoration: const InputDecoration(
                labelText: 'Instructor Name *',
                hintText: 'Dr. John Doe',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Instructor name is required';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _instructorBioController,
              decoration: const InputDecoration(
                labelText: 'Instructor Bio (Optional)',
                hintText: 'Brief bio about the instructor',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
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
            
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category *',
                border: OutlineInputBorder(),
              ),
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
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
                hintText: 'surgery, anatomy, beginner (comma-separated)',
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
        onPressed: _isUploading ? null : _uploadVideo,
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
                'Upload Video',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Future<void> _pickVideoFile() async {
    try {
      final picker = ImagePicker();
      final result = await picker.pickVideo(source: ImageSource.gallery);
      
      if (result != null) {
        final bytes = await result.readAsBytes();
        setState(() {
          _videoFile = bytes;
          _videoFileName = result.name;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking video: $e')),
      );
    }
  }

  Future<void> _pickThumbnailFile() async {
    try {
      final picker = ImagePicker();
      final result = await picker.pickImage(source: ImageSource.gallery);
      
      if (result != null) {
        final bytes = await result.readAsBytes();
        setState(() {
          _thumbnailFile = bytes;
          _thumbnailFileName = result.name;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking thumbnail: $e')),
      );
    }
  }

  Future<void> _uploadVideo() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_videoFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a video file')),
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

      final videoId = await _adminService.uploadVideo(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        instructor: _instructorController.text.trim(),
        instructorBio: _instructorBioController.text.trim(),
        category: _selectedCategory,
        subcategory: _subcategoryController.text.trim(),
        targetRoles: _selectedRoles,
        accessLevel: _selectedAccessLevel,
        coinCost: _coinCost,
        difficulty: _selectedDifficulty,
        tags: tags,
        videoFile: _videoFile!,
        fileName: _videoFileName!,
        thumbnailFile: _thumbnailFile,
        thumbnailFileName: _thumbnailFileName,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Video uploaded successfully! ID: $videoId'),
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