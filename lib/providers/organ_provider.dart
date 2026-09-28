import 'package:flutter/foundation.dart';
import '../models/organ.dart';
import '../services/firebase_service.dart';
import '../services/firebase_database_service.dart';

class OrganProvider with ChangeNotifier {
  final FirebaseDatabaseService _databaseService = FirebaseDatabaseService();
  List<Map<String, dynamic>> _donors = [];
  List<Map<String, dynamic>> _requests = [];

  OrganProvider() {
    // Listen to donors stream
    _databaseService.getDonorsStream().listen((donors) {
      _donors = donors;
      notifyListeners();
    });

    // Listen to recipients stream
    _databaseService.getRecipientsStream().listen((recipients) {
      _requests = recipients;
      notifyListeners();
    });
  }

  List<Map<String, dynamic>> get donors => _donors;
  List<Map<String, dynamic>> get requests => _requests;

  void addDonor(Map<String, dynamic> donor) async {
    try {
      await _databaseService.addDonor(donor);
      FirebaseService.logEvent('donor_registered', parameters: {
        'blood_group': donor['bloodGroup'],
        'organ': donor['organs'].toString(),
      });
    } catch (e, stack) {
      FirebaseService.recordError(e, stack);
      rethrow;
    }
  }

  void addRequest(Map<String, dynamic> request) async {
    try {
      await _databaseService.addRecipient(request);
      FirebaseService.logEvent('recipient_registered', parameters: {
        'blood_group': request['bloodGroup'],
        'organ': request['organ'].toString(),
      });
    } catch (e, stack) {
      FirebaseService.recordError(e, stack);
      rethrow;
    }
  }

  List<Map<String, dynamic>> findMatches(Map<String, dynamic> request) {
    final matches = _donors.where((donor) {
      // Check for exact blood group match
      if (donor['blood_group'] != request['bloodGroup']) {
        return false;
      }

      // Check for exact hospital location match
      if (donor['hospital_location'] != request['location']) {
        return false;
      }

      // Check for exact organ match
      final organNeeded = request['organ'].toString().toLowerCase();
      final donorOrgans = (donor['organs_donated'] as Map<dynamic, dynamic>?) ?? {};
      return donorOrgans[organNeeded] == true;
    }).map((donor) => {
      'name': donor['full_name'],
      'bloodGroup': donor['blood_group'],
      'location': donor['hospital_location'],
      'phone': donor['phone_number'],
      'organs': (donor['organs_donated'] as Map<dynamic, dynamic>).keys.toList(),
    }).toList();

    return matches;
  }

  List<Map<String, dynamic>> searchDonors({
    String? bloodGroup,
    String? organ,
    String? location,
  }) {
    return _donors.where((donor) {
      bool matches = true;
      
      if (bloodGroup != null) {
        // Exact blood group match
        matches = matches && donor['blood_group'] == bloodGroup;
      }
      
      if (organ != null) {
        final donorOrgans = (donor['organs_donated'] as Map<dynamic, dynamic>?) ?? {};
        matches = matches && donorOrgans[organ.toLowerCase()] == true;
      }
      
      if (location != null && location.isNotEmpty) {
        // Exact hospital location match
        matches = matches && donor['hospital_location'] == location;
      }
      
      return matches;
    }).toList();
  }

  // Get recent requests for dashboard
  List<Map<String, dynamic>> getRecentRequests() {
    final sortedRequests = List<Map<String, dynamic>>.from(_requests);
    sortedRequests.sort((a, b) => 
      (b['timestamp'] ?? '').compareTo(a['timestamp'] ?? ''));
    return sortedRequests.take(5).toList();
  }

  // Get statistics for dashboard
  Map<String, int> getStatistics() {
    return {
      'totalDonors': _donors.length,
      'totalRequests': _requests.length,
      'urgentRequests': _requests.where((r) => r['isUrgent'] == true).length,
      'availableOrgans': _donors.fold(0, (sum, donor) => 
        sum + (donor['organs'] as List).length),
    };
  }

  List<Map<String, dynamic>> getUnmatchedRequests() {
    return _requests.where((request) {
      final matches = findMatches(request);
      return matches.isEmpty;
    }).toList();
  }
}