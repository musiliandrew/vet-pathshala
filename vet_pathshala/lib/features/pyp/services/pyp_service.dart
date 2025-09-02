import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/pyp_model.dart';

class PYPService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get PYP categories
  Future<List<PYPCategory>> getCategories() async {
    final query = await _firestore
        .collection('pyp_categories')
        .where('isActive', isEqualTo: true)
        .orderBy('order')
        .get();

    return query.docs.map((doc) => PYPCategory.fromFirestore(doc)).toList();
  }

  // Get PYP papers
  Future<List<PYPPaper>> getPapers() async {
    final query = await _firestore
        .collection('pyp_papers')
        .where('isActive', isEqualTo: true)
        .orderBy('year', descending: true)
        .get();

    return query.docs.map((doc) => PYPPaper.fromFirestore(doc)).toList();
  }

  // Download paper
  Future<bool> downloadPaper(String paperId) async {
    try {
      // Update download count in Firestore
      await _firestore.collection('pyp_papers').doc(paperId).update({
        'downloads': FieldValue.increment(1),
      });
      return true;
    } catch (e) {
      print('Error downloading paper: $e');
      return false;
    }
  }

  // Rate paper
  Future<void> ratePaper(String paperId, double rating) async {
    try {
      await _firestore.collection('pyp_papers').doc(paperId).update({
        'ratings': FieldValue.arrayUnion([rating]),
      });
    } catch (e) {
      throw Exception('Failed to rate paper: $e');
    }
  }


}