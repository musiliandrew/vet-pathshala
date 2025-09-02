import 'package:flutter/material.dart';
import '../../../core/theme/unified_theme.dart';
import '../screens/success_stories_screen.dart';

class SuccessStoriesWidget extends StatelessWidget {
  const SuccessStoriesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.star,
                  color: UnifiedTheme.goldAccent,
                  size: 24,
                ),
                SizedBox(width: 8),
                Text(
                  'Success Stories',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: UnifiedTheme.primaryText,
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SuccessStoriesScreen(),
                  ),
                );
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'See All',
                    style: TextStyle(
                      color: UnifiedTheme.primaryGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: UnifiedTheme.primaryGreen,
                  ),
                ],
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Success Stories List
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _sampleStories.length,
            itemBuilder: (context, index) {
              final story = _sampleStories[index];
              return Container(
                width: 280,
                margin: const EdgeInsets.only(right: 16),
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
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User Info
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: story['roleColor'],
                            child: Text(
                              story['name'][0],
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  story['name'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  story['role'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: story['roleColor'],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
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
                      
                      const SizedBox(height: 12),
                      
                      // Story Content
                      Expanded(
                        child: Text(
                          story['story'],
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.4,
                            color: UnifiedTheme.secondaryText,
                          ),
                          maxLines: 6,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Stats
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildStoryStatChip(
                            Icons.quiz,
                            '${story['quizzesPassed']} Quizzes',
                            UnifiedTheme.primaryGreen,
                          ),
                          _buildStoryStatChip(
                            Icons.schedule,
                            '${story['studyTime']} hrs',
                            UnifiedTheme.blueAccent,
                          ),
                          _buildStoryStatChip(
                            Icons.trending_up,
                            '${story['improvement']}%',
                            UnifiedTheme.goldAccent,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStoryStatChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// Sample success stories data
final List<Map<String, dynamic>> _sampleStories = [
  {
    'name': 'Dr. Priya Sharma',
    'role': 'Veterinary Doctor',
    'roleColor': UnifiedTheme.primaryGreen,
    'achievement': 'Top Performer',
    'story': 'Vet-Pathshala transformed my practice! The drug calculator helped me prescribe accurate dosages, and the quiz system improved my diagnostic skills significantly. I went from 70% to 95% accuracy in my diagnoses.',
    'quizzesPassed': 45,
    'studyTime': 120,
    'improvement': 35,
  },
  {
    'name': 'Rahul Patel',
    'role': 'Pharmacist',
    'roleColor': UnifiedTheme.blueAccent,
    'achievement': 'Expert Level',
    'story': 'The drug interaction checker is a game-changer! I can now confidently handle complex prescriptions and provide better counseling to pet owners. My knowledge of veterinary pharmacology has improved tremendously.',
    'quizzesPassed': 38,
    'studyTime': 85,
    'improvement': 42,
  },
  {
    'name': 'Farmer Suresh Kumar',
    'role': 'Progressive Farmer',
    'roleColor': Colors.brown,
    'achievement': 'Smart Farmer',
    'story': 'The animal management system helped me track my 50+ cattle efficiently. The health records and breeding tracking features increased my farm productivity by 25%. Now I earn 30% more from my dairy business!',
    'quizzesPassed': 25,
    'studyTime': 60,
    'improvement': 25,
  },
  {
    'name': 'Dr. Anjali Reddy',
    'role': 'Veterinary Surgeon',
    'roleColor': UnifiedTheme.primaryGreen,
    'achievement': 'Quiz Master',
    'story': 'The PYP section and mock tests prepared me perfectly for my specialty certification exam. I scored 92% in my surgery specialization exam thanks to the comprehensive study materials.',
    'quizzesPassed': 52,
    'studyTime': 150,
    'improvement': 28,
  },
  {
    'name': 'Mohan Singh',
    'role': 'Rural Pharmacist',
    'roleColor': UnifiedTheme.blueAccent,
    'achievement': 'Community Helper',
    'story': 'Vet-Pathshala helped me serve my rural community better. The offline notes feature works great in areas with poor internet, and I can now provide expert advice on animal medications.',
    'quizzesPassed': 30,
    'studyTime': 75,
    'improvement': 40,
  },
];