import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/utils/firebase_availability.dart';

class ReferralService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> generateReferralCode(String userId) async {
    if (!FirebaseAvailability.isAvailable) {
      return 'REF${userId.substring(0, 6).toUpperCase()}';
    }

    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        String? existingCode = data['referralCode'];
        
        if (existingCode != null) {
          return existingCode;
        }
        
        final newCode = 'VET${userId.substring(0, 6).toUpperCase()}';
        await _firestore.collection('users').doc(userId).update({
          'referralCode': newCode,
        });
        
        return newCode;
      }
      
      return 'REF${userId.substring(0, 6).toUpperCase()}';
    } catch (e) {
      return 'REF${userId.substring(0, 6).toUpperCase()}';
    }
  }

  Future<void> shareReferralCode(String referralCode, String userName) async {
    final message = '''
🎓 Join Vet-Pathshala - The Ultimate Learning Platform for Veterinary Professionals!

Hi! I'm $userName and I'm learning so much on Vet-Pathshala. 

Use my referral code: *$referralCode* to get:
✅ 100 Free Drug Coins
✅ Premium features access
✅ Exclusive study materials

Download now and start your veterinary education journey!

#VetPathshala #VeterinaryEducation #Learning
''';

    await Share.share(
      message,
      subject: 'Join me on Vet-Pathshala!',
    );
  }

  Future<Map<String, dynamic>> getReferralStats(String userId) async {
    if (!FirebaseAvailability.isAvailable) {
      return {
        'totalReferrals': 0,
        'successfulReferrals': 0,
        'coinsEarned': 0,
        'recentReferrals': <Map<String, dynamic>>[],
      };
    }

    try {
      final snapshot = await _firestore
          .collection('referrals')
          .where('referrerId', isEqualTo: userId)
          .get();

      int totalReferrals = snapshot.docs.length;
      int successfulReferrals = 0;
      int coinsEarned = 0;
      List<Map<String, dynamic>> recentReferrals = [];

      for (final doc in snapshot.docs) {
        final data = doc.data();
        if (data['status'] == 'completed') {
          successfulReferrals++;
          coinsEarned += (data['rewardAmount'] ?? 50) as int;
        }
        
        if (recentReferrals.length < 5) {
          recentReferrals.add({
            'refereeEmail': data['refereeEmail'] ?? 'Unknown',
            'status': data['status'] ?? 'pending',
            'date': (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
            'rewardAmount': data['rewardAmount'] ?? 50,
          });
        }
      }

      return {
        'totalReferrals': totalReferrals,
        'successfulReferrals': successfulReferrals,
        'coinsEarned': coinsEarned,
        'recentReferrals': recentReferrals,
      };
    } catch (e) {
      return {
        'totalReferrals': 0,
        'successfulReferrals': 0,
        'coinsEarned': 0,
        'recentReferrals': <Map<String, dynamic>>[],
      };
    }
  }

  Future<bool> processReferral(String referralCode, String newUserId, String newUserEmail) async {
    if (!FirebaseAvailability.isAvailable) return false;

    try {
      final referrerQuery = await _firestore
          .collection('users')
          .where('referralCode', isEqualTo: referralCode)
          .limit(1)
          .get();

      if (referrerQuery.docs.isEmpty) {
        return false;
      }

      final referrerId = referrerQuery.docs.first.id;
      
      final existingReferral = await _firestore
          .collection('referrals')
          .where('referrerId', isEqualTo: referrerId)
          .where('refereeId', isEqualTo: newUserId)
          .limit(1)
          .get();

      if (existingReferral.docs.isNotEmpty) {
        return false;
      }

      final referralDoc = await _firestore.collection('referrals').add({
        'referrerId': referrerId,
        'refereeId': newUserId,
        'refereeEmail': newUserEmail,
        'referralCode': referralCode,
        'status': 'completed',
        'rewardAmount': 50,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await _firestore.collection('users').doc(referrerId).update({
        'coins': FieldValue.increment(50),
      });

      await _firestore.collection('users').doc(newUserId).update({
        'coins': FieldValue.increment(100),
      });

      await _firestore.collection('coin_transactions').add({
        'userId': referrerId,
        'amount': 50,
        'type': 'earned',
        'reason': 'referral_bonus',
        'referenceId': referralDoc.id,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await _firestore.collection('coin_transactions').add({
        'userId': newUserId,
        'amount': 100,
        'type': 'earned',
        'reason': 'referral_welcome',
        'referenceId': referralDoc.id,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print('🔴 ReferralService: Error processing referral: $e');
      return false;
    }
  }
}