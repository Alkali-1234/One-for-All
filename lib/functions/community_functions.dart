import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../main.dart';

interface class CommunityFunctions {
  //* Join community
  Future<String> joinCommunity(String communityID, String communityPassword, AppState appState) async {
    //* Call firebase function to join community
    HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('joinCommunity');
    final results = await callable.call(<String, dynamic>{
      'communityId': communityID,
      'password': communityPassword,
    });
    if (results.data == 'Successfully joined community') {
      appState.getCurrentUser.assignedCommunity = communityID;
      appState.thisNotifyListeners();
      return "Successfully joined community";
    }
    return results.data;
  }

  //* Leave community
  Future<String> leaveCommunity(String communityID, AppState appState) async {
    //* Call firebase function to leave community
    HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('leaveCommunity');
    final results = await callable.call(<String, dynamic>{});
    if (results.data == 'Successfully left community') {
      appState.getCurrentUser.assignedCommunity = "0";
      appState.thisNotifyListeners();
      return "Successfully left community";
    }
    return results.data;
  }

  //* Join section
  Future<String> joinSection(String sectionID, AppState appState, String password) async {
    //* Call firebase function to join section
    HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('joinSection');
    final results = await callable.call(<String, dynamic>{
      'sectionId': sectionID,
      'password': password,
    });
    if (results.data == 'Successfully joined section') {
      appState.getCurrentUser.assignedSection = sectionID;
      appState.thisNotifyListeners();
      return results.data;
    }
    return results.data;
  }

  //* Leave section
  Future<String> leaveSection(String sectionID, AppState appState) async {
    //* Call firebase function to leave section
    HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('leaveSection');
    final results = await callable.call(<String, dynamic>{
      'sectionId': sectionID,
    });
    if (results.data == 'Successfully left section') {
      appState.getCurrentUser.assignedSection = "0";
      return results.data;
    }
    return results.data;
  }
}
