import 'package:flutter/material.dart';
import '../../../core/theme/unified_theme.dart';

class SuccessStoriesScreen extends StatefulWidget {
  const SuccessStoriesScreen({super.key});

  @override
  State<SuccessStoriesScreen> createState() => _SuccessStoriesScreenState();
}

class _SuccessStoriesScreenState extends State<SuccessStoriesScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Doctors', 'Pharmacists', 'Farmers'];

  @override
  Widget build(BuildContext context) {
    final filteredStories = _getFilteredStories();
    
    return Scaffold(
      backgroundColor: UnifiedTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Success Stories'),
        backgroundColor: UnifiedTheme.backgroundColor,
        foregroundColor: UnifiedTheme.primaryText,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Filter Tabs
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = _selectedFilter == filter;
                
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    selected: isSelected,
                    label: Text(filter),
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                    backgroundColor: UnifiedTheme.cardBackground,
                    selectedColor: UnifiedTheme.primaryGreen.withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: isSelected ? UnifiedTheme.primaryGreen : UnifiedTheme.tertiaryText,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    side: BorderSide(
                      color: isSelected ? UnifiedTheme.primaryGreen : UnifiedTheme.borderColor,
                    ),
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Stories List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredStories.length,
              itemBuilder: (context, index) {
                final story = filteredStories[index];
                return _buildStoryCard(story);
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredStories() {
    if (_selectedFilter == 'All') {
      return _allSuccessStories;
    }
    
    String roleFilter = '';
    switch (_selectedFilter) {
      case 'Doctors':
        roleFilter = 'Veterinary';
        break;
      case 'Pharmacists':
        roleFilter = 'Pharmacist';
        break;
      case 'Farmers':
        roleFilter = 'Farmer';
        break;
    }
    
    return _allSuccessStories
        .where((story) => story['role'].toString().contains(roleFilter))
        .toList();
  }

  Widget _buildStoryCard(Map<String, dynamic> story) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: UnifiedTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: UnifiedTheme.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Header
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: story['roleColor'],
                child: Text(
                  story['name'][0],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      story['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      story['role'],
                      style: TextStyle(
                        fontSize: 14,
                        color: story['roleColor'],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (story['location'] != null) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 12,
                            color: UnifiedTheme.tertiaryText,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            story['location'],
                            style: TextStyle(
                              fontSize: 12,
                              color: UnifiedTheme.tertiaryText,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              // Achievement Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: UnifiedTheme.goldAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: UnifiedTheme.goldAccent.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star,
                      size: 12,
                      color: UnifiedTheme.goldAccent,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      story['achievement'],
                      style: TextStyle(
                        fontSize: 10,
                        color: UnifiedTheme.goldAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Story Content
          Text(
            story['story'],
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
              color: UnifiedTheme.secondaryText,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Stats
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  Icons.quiz,
                  'Quizzes Passed',
                  story['quizzesPassed'].toString(),
                  UnifiedTheme.primaryGreen,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  Icons.schedule,
                  'Study Hours',
                  '${story['studyTime']} hrs',
                  UnifiedTheme.blueAccent,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  Icons.trending_up,
                  'Improvement',
                  '${story['improvement']}%',
                  UnifiedTheme.goldAccent,
                ),
              ),
            ],
          ),
          
          if (story['testimonial'] != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: UnifiedTheme.primaryGreen.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: UnifiedTheme.primaryGreen.withOpacity(0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.format_quote,
                    color: UnifiedTheme.primaryGreen,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      story['testimonial'],
                      style: TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: UnifiedTheme.primaryGreen,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: UnifiedTheme.tertiaryText,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// Extended success stories data
final List<Map<String, dynamic>> _allSuccessStories = [
  {
    'name': 'Dr. Priya Sharma',
    'role': 'Veterinary Doctor',
    'location': 'Mumbai, Maharashtra',
    'roleColor': UnifiedTheme.primaryGreen,
    'achievement': 'Top Performer',
    'story': 'Vet-Pathshala transformed my practice! The drug calculator helped me prescribe accurate dosages, and the quiz system improved my diagnostic skills significantly. I went from 70% to 95% accuracy in my diagnoses.',
    'testimonial': 'This app is a must-have for every veterinary professional. It\'s like having a senior expert with you all the time!',
    'quizzesPassed': 45,
    'studyTime': 120,
    'improvement': 35,
  },
  {
    'name': 'Rahul Patel',
    'role': 'Pharmacist',
    'location': 'Ahmedabad, Gujarat',
    'roleColor': UnifiedTheme.blueAccent,
    'achievement': 'Expert Level',
    'story': 'The drug interaction checker is a game-changer! I can now confidently handle complex prescriptions and provide better counseling to pet owners. My knowledge of veterinary pharmacology has improved tremendously.',
    'testimonial': 'The drug database is incredibly comprehensive. It covers everything I need for my daily practice.',
    'quizzesPassed': 38,
    'studyTime': 85,
    'improvement': 42,
  },
  {
    'name': 'Farmer Suresh Kumar',
    'role': 'Progressive Farmer',
    'location': 'Pune, Maharashtra',
    'roleColor': Colors.brown,
    'achievement': 'Smart Farmer',
    'story': 'The animal management system helped me track my 50+ cattle efficiently. The health records and breeding tracking features increased my farm productivity by 25%. Now I earn 30% more from my dairy business!',
    'testimonial': 'QR code system for animals is brilliant! I can access any animal\'s complete history in seconds.',
    'quizzesPassed': 25,
    'studyTime': 60,
    'improvement': 25,
  },
  {
    'name': 'Dr. Anjali Reddy',
    'role': 'Veterinary Surgeon',
    'location': 'Hyderabad, Telangana',
    'roleColor': UnifiedTheme.primaryGreen,
    'achievement': 'Quiz Master',
    'story': 'The PYP section and mock tests prepared me perfectly for my specialty certification exam. I scored 92% in my surgery specialization exam thanks to the comprehensive study materials.',
    'testimonial': 'The AI-generated summaries saved me hours of study time. Absolutely fantastic!',
    'quizzesPassed': 52,
    'studyTime': 150,
    'improvement': 28,
  },
  {
    'name': 'Dr. Kavita Joshi',
    'role': 'Small Animal Practitioner',
    'location': 'Jaipur, Rajasthan',
    'roleColor': UnifiedTheme.primaryGreen,
    'achievement': 'Specialist',
    'story': 'As a new graduate, Vet-Pathshala gave me the confidence I needed. The short notes and flashcards helped me memorize complex drug protocols quickly.',
    'testimonial': 'Perfect for fresh graduates like me. The content is updated and very practical.',
    'quizzesPassed': 35,
    'studyTime': 95,
    'improvement': 50,
  },
  {
    'name': 'Ramesh Verma',
    'role': 'Livestock Farmer',
    'location': 'Mathura, Uttar Pradesh',
    'roleColor': Colors.brown,
    'achievement': 'Tech Savvy',
    'story': 'I was hesitant about using technology, but this app is so simple! The milk production tracking helped me identify my best performing animals and optimize feed.',
    'testimonial': 'Simple interface, powerful features. Even my teenage son is impressed!',
    'quizzesPassed': 18,
    'studyTime': 45,
    'improvement': 35,
  },
  {
    'name': 'Dr. Vikram Singh',
    'role': 'Poultry Consultant',
    'location': 'Chandigarh, Punjab',
    'roleColor': UnifiedTheme.primaryGreen,
    'achievement': 'Industry Expert',
    'story': 'The disease management protocols in the notes section are exceptional. I\'ve reduced mortality rates in client farms by 15% using the preventive care guidelines.',
    'testimonial': 'Most comprehensive veterinary resource I\'ve ever used. Highly recommended!',
    'quizzesPassed': 41,
    'studyTime': 110,
    'improvement': 32,
  },
];