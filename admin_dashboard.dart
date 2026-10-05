// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:medicare_connect/admin/add_doctor.dart';
// import 'package:medicare_connect/services/firestore.dart';

// class AdminHome extends StatelessWidget {
//   const AdminHome({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final firestore = FirestoreService();

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Admin Dashboard"),
//         centerTitle: true,
//       ),
//       floatingActionButton: FloatingActionButton(
//         child: const Icon(Icons.add),
//         onPressed: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (_) => const AddDoctorScreen(),
//             ),
//           );
//         },
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: firestore.getDoctors(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(
//               child: CircularProgressIndicator(),
//             );
//           }

//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return const Center(
//               child: Text("No Doctors"),
//             );
//           }

//           final doctors = snapshot.data!.docs;

//           return ListView.builder(
//             itemCount: doctors.length,
//             itemBuilder: (context, index) {
//               final doctor = doctors[index].data() as Map<String, dynamic>;

//               return Card(
//                 margin: const EdgeInsets.all(10),
//                 child: ListTile(
//                   leading: const CircleAvatar(
//                     child: Icon(Icons.person),
//                   ),
//                   title: Text(doctor["name"]),
//                   subtitle: Text(
//                     doctor["specialization"],
//                   ),
//                   trailing: IconButton(
//                     icon: const Icon(
//                       Icons.delete,
//                       color: Colors.red,
//                     ),
//                     onPressed: () async {
//                       await firestore.deleteDoctor(
//                         doctor["id"],
//                       );
//                     },
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
