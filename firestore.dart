// import 'package:cloud_firestore/cloud_firestore.dart';

// class FirestoreService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   // ==========================
//   // USER
//   // ==========================

//   Future<void> saveUser({
//     required String uid,
//     required String name,
//     required String email,
//     required String role,
//   }) async {
//     await _firestore.collection("users").doc(uid).set({
//       "uid": uid,
//       "name": name,
//       "email": email,
//       "role": role,
//       "createdAt": FieldValue.serverTimestamp(),
//     });
//   }

//   Future<String?> getUserRole(String uid) async {
//     final doc = await _firestore.collection("users").doc(uid).get();

//     if (doc.exists) {
//       return doc.data()?["role"];
//     }

//     return null;
//   }

//   // ==========================
//   // DOCTOR
//   // ==========================
//   // Add Doctor
//   Future<void> addDoctor({
//     required String name,
//     required String specialization,
//     required String hospital,
//     required String experience,
//     required String image,
//     required List<String> availableDays,
//   }) async {
//     final doc = _firestore.collection("doctors").doc();

//     await doc.set({
//       "id": doc.id,
//       "name": name,
//       "specialization": specialization,
//       "hospital": hospital,
//       "experience": experience,
//       "image": image,
//       "availableDays": availableDays,
//       "createdAt": FieldValue.serverTimestamp(),
//     });
//   }

//   Stream<QuerySnapshot> getDoctors() {
//     return _firestore
//         .collection("doctors")
//         .orderBy("createdAt", descending: true)
//         .snapshots();
//   }

//   // Delete Doctor
//   Future<void> deleteDoctor(String doctorId) async {
//     await _firestore.collection("doctors").doc(doctorId).delete();
//   }

//   // Update Doctor
//   Future<void> updateDoctor({
//     required String doctorId,
//     required String name,
//     required String specialization,
//     required String hospital,
//     required String experience,
//     String? image,
//     List<String>? availableDays,
//   }) async {
//     final data = <String, dynamic>{
//       "name": name,
//       "specialization": specialization,
//       "hospital": hospital,
//       "experience": experience,
//     };

//     if (image != null) data["image"] = image;
//     if (availableDays != null) data["availableDays"] = availableDays;

//     await _firestore.collection("doctors").doc(doctorId).update(data);
//   }

//   // ==========================
//   // APPOINTMENTS
//   // ==========================

//   Future<void> bookAppointment({
//     required String patientId,
//     required String doctorId,
//     required String doctorName,
//     required String patientName,
//     required String date,
//     required String time,
//   }) async {
//     final doc = _firestore.collection("appointments").doc();

//     await doc.set({
//       "id": doc.id,
//       "patientId": patientId,
//       "doctorId": doctorId,
//       "doctorName": doctorName,
//       "patientName": patientName,
//       "date": date,
//       "time": time,
//       "status": "Pending",
//       "createdAt": FieldValue.serverTimestamp(),
//     });
//   }

//   // Doctor - All Appointments
//   Stream<QuerySnapshot> getAppointments() {
//     return _firestore
//         .collection("appointments")
//         .orderBy("createdAt", descending: true)
//         .snapshots();
//   }

//   // Patient - Own Appointments
//   Stream<QuerySnapshot> getPatientAppointments(String patientId) {
//     return _firestore
//         .collection("appointments")
//         .where("patientId", isEqualTo: patientId)
//         .orderBy("createdAt", descending: true)
//         .snapshots();
//   }

//   // Update Status
//   Future<void> updateAppointmentStatus(
//     String appointmentId,
//     String status,
//   ) async {
//     await _firestore.collection("appointments").doc(appointmentId).update({
//       "status": status,
//     });
//   }

//   // Delete Appointment
//   Future<void> deleteAppointment(String appointmentId) async {
//     await _firestore.collection("appointments").doc(appointmentId).delete();
//   }

//   // ==========================
//   // FAVORITES
//   // ==========================

//   Future<void> addFavorite({
//     required String patientId,
//     required String doctorId,
//   }) async {
//     await _firestore.collection("favorites").add({
//       "patientId": patientId,
//       "doctorId": doctorId,
//       "createdAt": FieldValue.serverTimestamp(),
//     });
//   }

//   Future<void> removeFavorite(String favoriteId) async {
//     await _firestore.collection("favorites").doc(favoriteId).delete();
//   }

//   Stream<QuerySnapshot> getFavorites(String patientId) {
//     return _firestore
//         .collection("favorites")
//         .where("patientId", isEqualTo: patientId)
//         .snapshots();
//   }
// }



import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==========================
  // USER
  // ==========================

  Future<void> saveUser({
    required String uid,
    required String name,
    required String email,
    required String role,
  }) async {
    await _firestore.collection("users").doc(uid).set({
      "uid": uid,
      "name": name,
      "email": email,
      "role": role,
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  Future<String?> getUserRole(String uid) async {
    final doc = await _firestore.collection("users").doc(uid).get();

    if (doc.exists) {
      return doc.data()?["role"];
    }

    return null;
  }

  // ==========================
  // DOCTOR
  // ==========================

  // Add Doctor
  // If `doctorId` is passed (the Firebase Auth uid created for this doctor),
  // the doctor profile document is saved with that SAME id, so the doctor's
  // login account and their public profile are linked together.
  // If no doctorId is passed, an auto id is used (old behaviour, doctor
  // won't be able to log in / see their own appointments).
  Future<String> addDoctor({
    String? doctorId,
    required String name,
    required String specialization,
    required String hospital,
    required String experience,
    required String image,
    required List<String> availableDays,
  }) async {
    final doc = doctorId != null
        ? _firestore.collection("doctors").doc(doctorId)
        : _firestore.collection("doctors").doc();

    await doc.set({
      "id": doc.id,
      "name": name,
      "specialization": specialization,
      "hospital": hospital,
      "experience": experience,
      "image": image,
      "availableDays": availableDays,
      "createdAt": FieldValue.serverTimestamp(),
    });

    return doc.id;
  }

  Stream<QuerySnapshot> getDoctors() {
    return _firestore
        .collection("doctors")
        .orderBy("createdAt", descending: true)
        .snapshots();
  }

  // Delete Doctor
  Future<void> deleteDoctor(String doctorId) async {
    await _firestore.collection("doctors").doc(doctorId).delete();
  }

  // Update Doctor
  Future<void> updateDoctor({
    required String doctorId,
    required String name,
    required String specialization,
    required String hospital,
    required String experience,
    String? image,
    List<String>? availableDays,
  }) async {
    final data = <String, dynamic>{
      "name": name,
      "specialization": specialization,
      "hospital": hospital,
      "experience": experience,
    };

    if (image != null) data["image"] = image;
    if (availableDays != null) data["availableDays"] = availableDays;

    await _firestore.collection("doctors").doc(doctorId).update(data);
  }

  // ==========================
  // APPOINTMENTS
  // ==========================

  Future<void> bookAppointment({
    required String patientId,
    required String doctorId,
    required String doctorName,
    required String patientName,
    required String date,
    required String time,
  }) async {
    final doc = _firestore.collection("appointments").doc();

    await doc.set({
      "id": doc.id,
      "patientId": patientId,
      "doctorId": doctorId,
      "doctorName": doctorName,
      "patientName": patientName,
      "date": date,
      "time": time,
      "status": "Pending",
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  // Doctor - All Appointments (kept for Admin use, e.g. a future admin
  // "all appointments" screen).
  Stream<QuerySnapshot> getAppointments() {
    return _firestore
        .collection("appointments")
        .orderBy("createdAt", descending: true)
        .snapshots();
  }

  // Doctor - ONLY that doctor's own appointments.
  // doctor_home.dart should use this instead of getAppointments(),
  // filtering by the logged-in doctor's uid (== doctors/{uid}).
  Stream<QuerySnapshot> getDoctorAppointments(String doctorId) {
    return _firestore
        .collection("appointments")
        .where("doctorId", isEqualTo: doctorId)
        .orderBy("createdAt", descending: true)
        .snapshots();
  }

  // Patient - Own Appointments
  Stream<QuerySnapshot> getPatientAppointments(String patientId) {
    return _firestore
        .collection("appointments")
        .where("patientId", isEqualTo: patientId)
        .orderBy("createdAt", descending: true)
        .snapshots();
  }

  // Update Status
  Future<void> updateAppointmentStatus(
    String appointmentId,
    String status,
  ) async {
    await _firestore.collection("appointments").doc(appointmentId).update({
      "status": status,
    });
  }

  // Delete Appointment
  Future<void> deleteAppointment(String appointmentId) async {
    await _firestore.collection("appointments").doc(appointmentId).delete();
  }

  // ==========================
  // FAVORITES
  // ==========================

  Future<void> addFavorite({
    required String patientId,
    required String doctorId,
  }) async {
    await _firestore.collection("favorites").add({
      "patientId": patientId,
      "doctorId": doctorId,
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeFavorite(String favoriteId) async {
    await _firestore.collection("favorites").doc(favoriteId).delete();
  }

  Stream<QuerySnapshot> getFavorites(String patientId) {
    return _firestore
        .collection("favorites")
        .where("patientId", isEqualTo: patientId)
        .snapshots();
  }
}