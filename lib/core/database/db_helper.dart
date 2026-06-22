import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edu_presence/data/models/user_model.dart';
import 'package:edu_presence/data/models/coordinate_model.dart';
import 'package:edu_presence/data/models/attendance_model.dart';

class DbHelper {
  static final DbHelper instance = DbHelper._init();
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DbHelper._init();

  // Dummy getter to prevent breaking main.dart
  Future<dynamic> get database async => null;

  // --- USER OPERATIONS ---

  Future<String> registerUser(UserModel user) async {
    // 1. Create user in Firebase Auth
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: user.email,
      password: user.password,
    );

    final uid = userCredential.user!.uid;

    // 2. Save user profile to Firestore (exclude password for security)
    await _firestore.collection('users').doc(uid).set({
      'username': user.username,
      'email': user.email,
      'role': user.role,
      'is_active': user.isActive,
    });

    return uid;
  }

  Future<int> updateUser(UserModel user) async {
    if (user.id == null) return 0;
    
    await _firestore.collection('users').doc(user.id).update({
      'username': user.username,
      'email': user.email,
      'role': user.role,
      'is_active': user.isActive,
    });
    return 1;
  }

  Future<void> setUserActiveStatus(String uid, bool isActive) async {
    await _firestore.collection('users').doc(uid).update({
      'is_active': isActive,
    });
  }

  Future<UserModel?> loginUser(String identifier, String password) async {
    String email = identifier;
    
    // Check if identifier is email or username
    if (!identifier.contains('@')) {
      final usernameQuery = await _firestore
          .collection('users')
          .where('username', isEqualTo: identifier)
          .limit(1)
          .get();
          
      if (usernameQuery.docs.isEmpty) return null;
      email = usernameQuery.docs.first.get('email') as String;
    }

    // Sign in with Firebase Auth
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (userCredential.user != null) {
      final uid = userCredential.user!.uid;
      final userDoc = await _firestore.collection('users').doc(uid).get();
      
      if (userDoc.exists) {
        final data = userDoc.data()!;
        return UserModel.fromMap({
          ...data,
          'id': uid,
        });
      }
    }
    return null;
  }

  Future<bool> isUsernameTaken(String username) async {
    final query = await _firestore
        .collection('users')
        .where('username', isEqualTo: username)
        .limit(1)
        .get();
    return query.docs.isNotEmpty;
  }

  Future<int> getEmployeeCount() async {
    final query = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'user')
        .get();
    return query.docs.length;
  }

  Future<List<UserModel>> getAllEmployees() async {
    final query = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'user')
        .get();
        
    return query.docs.map((doc) {
      return UserModel.fromMap({
        ...doc.data(),
        'id': doc.id,
      });
    }).toList();
  }

  Future<int> deleteUser(String id) async {
    await _firestore.collection('users').doc(id).delete();
    return 1;
  }

  // --- CALENDAR & SCHEDULE OPERATIONS ---

  Future<void> saveCalendarSetting(String date, String status, {String? masuk, String? pulang}) async {
    final Map<String, dynamic> data = {
      'status': status,
    };
    if (masuk != null) data['masuk'] = masuk;
    if (pulang != null) data['pulang'] = pulang;
    await _firestore.collection('calendar').doc(date).set(data);
  }

  Future<void> deleteCalendarSetting(String date) async {
    await _firestore.collection('calendar').doc(date).delete();
  }

  Future<Map<String, Map<String, dynamic>>> getCalendarSettings() async {
    final query = await _firestore.collection('calendar').get();
    final Map<String, Map<String, dynamic>> exceptions = {};
    for (var doc in query.docs) {
      exceptions[doc.id] = doc.data();
    }
    return exceptions;
  }

  Future<Map<String, dynamic>?> getCalendarSetting(String date) async {
    final doc = await _firestore.collection('calendar').doc(date).get();
    if (doc.exists) {
      return doc.data();
    }
    return null;
  }

  Future<String> getDayStatus(String date, int weekday) async {
    final doc = await _firestore.collection('calendar').doc(date).get();
    if (doc.exists) {
      return doc.data()!['status'] as String;
    }
    // Default: Sunday is Holiday, others are Work Day
    if (weekday == DateTime.sunday) {
      return 'libur';
    }
    return 'kerja';
  }

  Future<void> saveGeneralSchedule(String masuk, String pulang) async {
    await _firestore.collection('schedules').doc('general').set({
      'masuk': masuk,
      'pulang': pulang,
    });
  }

  Future<Map<String, String>> getGeneralSchedule() async {
    final doc = await _firestore.collection('schedules').doc('general').get();
    if (doc.exists) {
      final data = doc.data()!;
      return {
        'masuk': data['masuk'] as String? ?? '07:00',
        'pulang': data['pulang'] as String? ?? '13:00',
      };
    }
    return {
      'masuk': '07:00',
      'pulang': '13:00',
    };
  }

  // --- COORDINATE OPERATIONS ---

  Future<String> setCoordinate(CoordinateModel coord) async {
    final docRef = await _firestore.collection('coordinates').add({
      'name': coord.name,
      'latitude': coord.latitude,
      'longitude': coord.longitude,
      'radius_meters': coord.radiusMeters,
    });
    return docRef.id;
  }

  Future<List<CoordinateModel>> getCoordinates() async {
    final query = await _firestore.collection('coordinates').get();
    
    // Seed default coordinate if database is completely empty
    if (query.docs.isEmpty) {
      final defaultCoord = CoordinateModel(
        name: 'Gedung TK EduPresence',
        latitude: -6.175392,
        longitude: 106.827153,
        radiusMeters: 100.0,
      );
      final id = await setCoordinate(defaultCoord);
      return [
        CoordinateModel(
          id: id,
          name: defaultCoord.name,
          latitude: defaultCoord.latitude,
          longitude: defaultCoord.longitude,
          radiusMeters: defaultCoord.radiusMeters,
        )
      ];
    }

    return query.docs.map((doc) {
      return CoordinateModel.fromMap({
        ...doc.data(),
        'id': doc.id,
      });
    }).toList();
  }

  Future<CoordinateModel?> getPrimaryCoordinate() async {
    final coords = await getCoordinates();
    if (coords.isNotEmpty) return coords.first;
    return null;
  }

  Future<int> updateCoordinate(CoordinateModel coord) async {
    if (coord.id == null) return 0;
    
    await _firestore.collection('coordinates').doc(coord.id).update({
      'name': coord.name,
      'latitude': coord.latitude,
      'longitude': coord.longitude,
      'radius_meters': coord.radiusMeters,
    });
    return 1;
  }

  Future<int> deleteCoordinate(String id) async {
    await _firestore.collection('coordinates').doc(id).delete();
    return 1;
  }

  // --- ATTENDANCE OPERATIONS ---

  Future<String> insertAttendance(AttendanceModel attendance) async {
    final docRef = await _firestore.collection('attendance').add({
      'user_id': attendance.userId,
      'user_name': attendance.userName,
      'date_time': attendance.dateTime,
      'latitude': attendance.latitude,
      'longitude': attendance.longitude,
      'photo_path': attendance.photoPath,
      'distance': attendance.distance,
      'status': attendance.status,
      'reason': attendance.reason,
      'admin_updated': attendance.adminUpdated,
    });
    return docRef.id;
  }

  Future<List<AttendanceModel>> getAttendanceLogs() async {
    final query = await _firestore
        .collection('attendance')
        .orderBy('date_time', descending: true)
        .get();
        
    return query.docs.map((doc) {
      return AttendanceModel.fromMap({
        ...doc.data(),
        'id': doc.id,
      });
    }).toList();
  }

  Future<List<AttendanceModel>> getAttendanceByUserId(String userId) async {
    final query = await _firestore
        .collection('attendance')
        .where('user_id', isEqualTo: userId)
        .orderBy('date_time', descending: true)
        .get();
        
    return query.docs.map((doc) {
      return AttendanceModel.fromMap({
        ...doc.data(),
        'id': doc.id,
      });
    }).toList();
  }

  Future<int> updateAttendance(AttendanceModel att) async {
    if (att.id == null) return 0;
    
    await _firestore.collection('attendance').doc(att.id).update({
      'user_id': att.userId,
      'user_name': att.userName,
      'date_time': att.dateTime,
      'latitude': att.latitude,
      'longitude': att.longitude,
      'photo_path': att.photoPath,
      'distance': att.distance,
      'status': att.status,
      'reason': att.reason,
      'admin_updated': att.adminUpdated,
    });
    return 1;
  }

  Future<int> deleteAttendance(String id) async {
    await _firestore.collection('attendance').doc(id).delete();
    return 1;
  }
}
