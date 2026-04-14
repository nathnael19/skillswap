import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/widgets.dart';

class PresenceService with WidgetsBindingObserver {
  static final PresenceService instance = PresenceService._internal();

  PresenceService._internal() {
    WidgetsBinding.instance.addObserver(this);
  }

  final FirebaseDatabase _db = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  bool _isOnline = false;

  Future<void> goOnline(String uid) async {
    if (_isOnline) return;
    _isOnline = true;
    
    final presenceRef = _db.ref('presence/$uid');
    
    // Set up onDisconnect hook
    await presenceRef.onDisconnect().update({
      'online': false,
      'last_seen': ServerValue.timestamp,
    });
    
    // Set current status to online
    await presenceRef.update({
      'online': true,
      'last_seen': ServerValue.timestamp,
    });
  }

  Future<void> goOffline(String uid) async {
    if (!_isOnline) return;
    _isOnline = false;
    
    final presenceRef = _db.ref('presence/$uid');
    
    // Remove onDisconnect hook
    await presenceRef.onDisconnect().cancel();
    
    // Set status to offline
    await presenceRef.update({
      'online': false,
      'last_seen': ServerValue.timestamp,
    });
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    
    if (state == AppLifecycleState.resumed) {
      goOnline(uid);
    } else if (state == AppLifecycleState.paused || 
               state == AppLifecycleState.detached || 
               state == AppLifecycleState.hidden) {
      goOffline(uid);
    }
  }

  // --- Realtime Streams ---

  Stream<bool> watchPresence(String uid) {
    return _db.ref('presence/$uid/online').onValue.map((event) {
      final val = event.snapshot.value;
      return val == true;
    });
  }

  Stream<DateTime?> watchLastSeen(String uid) {
    return _db.ref('presence/$uid/last_seen').onValue.map((event) {
      final val = event.snapshot.value;
      if (val is int) {
        return DateTime.fromMillisecondsSinceEpoch(val);
      }
      return null;
    });
  }

  // --- Typing Indicators ---

  void setTyping(String matchId, bool isTyping) {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    _db.ref('typing/$matchId/$uid').update({
      'is_typing': isTyping,
      'updated_at': ServerValue.timestamp,
    });
  }

  Stream<bool> watchTyping(String matchId, String peerId) {
    return _db.ref('typing/$matchId/$peerId/is_typing').onValue.map((event) {
      final val = event.snapshot.value;
      return val == true;
    });
  }
  
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }
}
