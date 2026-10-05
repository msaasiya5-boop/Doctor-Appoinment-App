import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:medicare_connect/screen/booking_appoinment.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medicare_connect/screen/my_appoinment.dart';
import 'package:medicare_connect/screen/profile.dart';
import 'package:medicare_connect/services/firestore.dart';

class PatientHome extends StatefulWidget {
  const PatientHome({super.key});

  @override
  State<PatientHome> createState() => _PatientHomeState();
}

class _PatientHomeState extends State<PatientHome> {
  int selectedIndex = 0;

  final List<Widget> pages = const [
    HomePage(),
    AppointmentPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: "Appointments",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirestoreService firestore = FirestoreService();

  String search = "";

  static const Color _accent = Color(0xFF2563EB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Find Doctors"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search Doctor",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  search = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: firestore.getDoctors(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text("No Doctors Available"),
                  );
                }

                final doctors = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: doctors.length,
                  itemBuilder: (context, index) {
                    final doctor =
                        doctors[index].data() as Map<String, dynamic>;

                    final name = doctor["name"].toString().toLowerCase();

                    final specialization =
                        doctor["specialization"].toString().toLowerCase();

                    if (!name.contains(search) &&
                        !specialization.contains(search)) {
                      return const SizedBox.shrink();
                    }

                    // availableDays may not exist on older docs, so default
                    // to an empty list to avoid crashes.
                    final List<String> availableDays =
                        (doctor["availableDays"] as List?)
                                ?.map((e) => e.toString())
                                .toList() ??
                            [];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 8,
                      ),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundImage: doctor["image"] != null &&
                                      doctor["image"].toString().isNotEmpty
                                  ? NetworkImage(
                                      doctor["image"],
                                    )
                                  : null,
                              child: doctor["image"] == null ||
                                      doctor["image"].toString().isEmpty
                                  ? const Icon(Icons.person)
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    doctor["name"],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15.5,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(doctor["specialization"]),
                                  Text(doctor["hospital"]),
                                  Text(
                                    "${doctor["experience"]} Years Experience",
                                  ),
                                  if (availableDays.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_month_outlined,
                                          size: 14,
                                          color: Colors.grey.shade600,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          "Available",
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 6,
                                      children: availableDays.map((day) {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 9,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _accent.withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            day,
                                            style: const TextStyle(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w600,
                                              color: _accent,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      IconButton(
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        icon: const Icon(
                                          Icons.favorite_border,
                                          color: Colors.red,
                                        ),
                                        onPressed: () async {
                                          await firestore.addFavorite(
                                            patientId: FirebaseAuth
                                                .instance.currentUser!.uid,
                                            doctorId: doctor["id"],
                                          );

                                          if (!mounted) return;

                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content:
                                                  Text("Added to Favorites"),
                                            ),
                                          );
                                        },
                                      ),
                                      const Spacer(),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: _accent,
                                          foregroundColor: Colors.white,
                                        ),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => BookAppointment(
                                                doctorId: doctor["id"],
                                                doctorName: doctor["name"],
                                                availableDays:
                                                    List<String>.from(doctor[
                                                            "availableDays"] ??
                                                        []),
                                              ),
                                            ),
                                          );
                                        },
                                        child: const Text("Book"),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
