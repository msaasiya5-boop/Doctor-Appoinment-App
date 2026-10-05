// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:medicare_connect/services/firestore.dart';

// class DoctorHome extends StatelessWidget {
//   const DoctorHome({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final firestore = FirestoreService();

//     // The doctor's profile document id == their Firebase Auth uid
//     // (this is how add_doctor.dart now links a doctor's login to their
//     // profile), so we filter appointments by that uid.
//     final doctorId = FirebaseAuth.instance.currentUser!.uid;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Doctor Dashboard"),
//         centerTitle: true,
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: firestore.getDoctorAppointments(doctorId),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(
//               child: CircularProgressIndicator(),
//             );
//           }

//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return const Center(
//               child: Text("No Appointment Requests"),
//             );
//           }

//           final appointments = snapshot.data!.docs;

//           return ListView.builder(
//             itemCount: appointments.length,
//             itemBuilder: (context, index) {
//               final appointment =
//                   appointments[index].data() as Map<String, dynamic>;

//               return Card(
//                 margin: const EdgeInsets.all(10),
//                 child: Padding(
//                   padding: const EdgeInsets.all(12),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         appointment["patientName"],
//                         style: const TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Text("Doctor : ${appointment["doctorName"]}"),
//                       Text("Date : ${appointment["date"]}"),
//                       Text("Time : ${appointment["time"]}"),
//                       Text(
//                         "Status : ${appointment["status"]}",
//                         style: TextStyle(
//                           color: appointment["status"] == "Approved"
//                               ? Colors.green
//                               : appointment["status"] == "Rejected"
//                                   ? Colors.red
//                                   : Colors.orange,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 15),
//                       Row(
//                         children: [
//                           Expanded(
//                             child: ElevatedButton(
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.green,
//                               ),
//                               onPressed: () async {
//                                 await firestore.updateAppointmentStatus(
//                                   appointment["id"],
//                                   "Approved",
//                                 );
//                               },
//                               child: const Text("Approve"),
//                             ),
//                           ),
//                           const SizedBox(width: 10),
//                           Expanded(
//                             child: ElevatedButton(
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.red,
//                               ),
//                               onPressed: () async {
//                                 await firestore.updateAppointmentStatus(
//                                   appointment["id"],
//                                   "Rejected",
//                                 );
//                               },
//                               child: const Text("Reject"),
//                             ),
//                           ),
//                         ],
//                       )
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:medicare_connect/services/firestore.dart';

class DoctorHome extends StatelessWidget {
  const DoctorHome({super.key});

  @override
  Widget build(BuildContext context) {
    final firestore = FirestoreService();

    // The doctor's profile document id == their Firebase Auth uid
    // (this is how add_doctor.dart now links a doctor's login to their
    // profile), so we filter appointments by that uid.
    final doctorId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Doctor Dashboard"),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore.getDoctorAppointments(doctorId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.red, size: 40),
                    const SizedBox(height: 12),
                    const Text(
                      "Couldn't load appointments",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${snapshot.error}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No Appointment Requests"),
            );
          }

          final appointments = snapshot.data!.docs;

          return ListView.builder(
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final appointment =
                  appointments[index].data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment["patientName"],
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text("Doctor : ${appointment["doctorName"]}"),
                      Text("Date : ${appointment["date"]}"),
                      Text("Time : ${appointment["time"]}"),
                      Text(
                        "Status : ${appointment["status"]}",
                        style: TextStyle(
                          color: appointment["status"] == "Approved"
                              ? Colors.green
                              : appointment["status"] == "Rejected"
                                  ? Colors.red
                                  : Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                              onPressed: () async {
                                await firestore.updateAppointmentStatus(
                                  appointment["id"],
                                  "Approved",
                                );
                              },
                              child: const Text("Approve"),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              onPressed: () async {
                                await firestore.updateAppointmentStatus(
                                  appointment["id"],
                                  "Rejected",
                                );
                              },
                              child: const Text("Reject"),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
