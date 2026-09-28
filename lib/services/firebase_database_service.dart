import 'package:firebase_database/firebase_database.dart';
import '../services/firebase_service.dart';

class FirebaseDatabaseService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  // Add donor to database
  Future<void> addDonor(Map<String, dynamic> donor) async {
    try {
      final newDonorRef = _database.child('donors').push();
      await newDonorRef.set({
        'full_name': donor['name'],
        'blood_group': donor['bloodGroup'],
        'hospital_location': donor['location'],
        'phone_number': donor['phone'],
        'organs_donated': Map.fromIterable(
          donor['organs'],
          key: (organ) => organ.toString().toLowerCase(),
          value: (organ) => true,
        ),
        'timestamp': ServerValue.timestamp,
      });
      
      FirebaseService.logEvent('donor_added_to_database');
    } catch (e, stack) {
      FirebaseService.recordError(e, stack);
      rethrow;
    }
  }

  // Add recipient to database
  Future<void> addRecipient(Map<String, dynamic> recipient) async {
    try {
      final newRecipientRef = _database.child('recipients').push();
      await newRecipientRef.set({
        'full_name': recipient['name'],
        'blood_group': recipient['bloodGroup'],
        'hospital_location': recipient['location'],
        'phone_number': recipient['phone'],
        'organs_needed': {
          recipient['organ'].toString().toLowerCase(): true,
        },
        'is_urgent': recipient['isUrgent'] ?? false,
        'timestamp': ServerValue.timestamp,
      });
      
      FirebaseService.logEvent('recipient_added_to_database');
    } catch (e, stack) {
      FirebaseService.recordError(e, stack);
      rethrow;
    }
  }

  // Get all donors
  Stream<List<Map<String, dynamic>>> getDonorsStream() {
    return _database.child('donors').onValue.map((event) {
      final Map<dynamic, dynamic>? data = event.snapshot.value as Map?;
      if (data == null) return [];
      
      return data.entries.map((entry) {
        final donor = Map<String, dynamic>.from(entry.value);
        donor['id'] = entry.key;
        return donor;
      }).toList();
    });
  }

  // Get all recipients
  Stream<List<Map<String, dynamic>>> getRecipientsStream() {
    return _database.child('recipients').onValue.map((event) {
      final Map<dynamic, dynamic>? data = event.snapshot.value as Map?;
      if (data == null) return [];
      
      return data.entries.map((entry) {
        final recipient = Map<String, dynamic>.from(entry.value);
        recipient['id'] = entry.key;
        return recipient;
      }).toList();
    });
  }
} 