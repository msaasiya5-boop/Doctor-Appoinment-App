// import 'dart:convert';
// import 'dart:typed_data';

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
// import 'package:medicare_connect/services/firestore.dart';

// class AddDoctorScreen extends StatefulWidget {
//   const AddDoctorScreen({super.key});

//   @override
//   State<AddDoctorScreen> createState() => _AddDoctorScreenState();
// }

// class _AddDoctorScreenState extends State<AddDoctorScreen> {
//   final nameController = TextEditingController();
//   final specializationController = TextEditingController();
//   final hospitalController = TextEditingController();
//   final experienceController = TextEditingController();

//   final _formKey = GlobalKey<FormState>();
//   final firestore = FirestoreService();
//   final ImagePicker _picker = ImagePicker();

//   bool isSaving = false;
//   AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

//   Uint8List? _selectedImageBytes;
//   String? _selectedImageName;

//   // Cloudinary (unsigned upload)
//   static const String _cloudinaryUploadPreset = "Tourbooking";
//   static const String _cloudinaryCloudName = "dotnhabff";

//   static const List<String> _allDays = [
//     "Mon",
//     "Tue",
//     "Wed",
//     "Thu",
//     "Fri",
//     "Sat",
//     "Sun",
//   ];

//   final Set<String> selectedDays = {};

//   static const Color _accent = Color(0xFF2563EB);

//   @override
//   void dispose() {
//     nameController.dispose();
//     specializationController.dispose();
//     hospitalController.dispose();
//     experienceController.dispose();
//     super.dispose();
//   }

//   void _showSnack(String message, {bool isError = false}) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         margin: const EdgeInsets.all(16),
//       ),
//     );
//   }

//   InputDecoration _fieldDecoration({
//     required String label,
//     required IconData icon,
//   }) {
//     return InputDecoration(
//       labelText: label,
//       labelStyle: TextStyle(color: Colors.grey.shade700),
//       prefixIcon: Icon(icon, color: _accent),
//       filled: true,
//       fillColor: Colors.grey.shade50,
//       contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(14),
//         borderSide: BorderSide.none,
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(14),
//         borderSide: BorderSide(color: Colors.grey.shade200),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(14),
//         borderSide: const BorderSide(color: _accent, width: 1.6),
//       ),
//       errorBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(14),
//         borderSide: BorderSide(color: Colors.red.shade400, width: 1.4),
//       ),
//       focusedErrorBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(14),
//         borderSide: BorderSide(color: Colors.red.shade600, width: 1.8),
//       ),
//       errorStyle: TextStyle(
//         color: Colors.red.shade600,
//         fontSize: 12.5,
//         fontWeight: FontWeight.w600,
//       ),
//     );
//   }

//   Future<void> _pickImage() async {
//     try {
//       final pickedFile = await _picker.pickImage(
//         source: ImageSource.gallery,
//         maxWidth: 1024,
//         imageQuality: 85,
//       );
//       if (pickedFile != null) {
//         final bytes = await pickedFile.readAsBytes();
//         setState(() {
//           _selectedImageBytes = bytes;
//           _selectedImageName = pickedFile.name;
//         });
//       }
//     } catch (e) {
//       if (!mounted) return;
//       _showSnack("Failed to pick image: $e", isError: true);
//     }
//   }

//   Future<String> _uploadImage(Uint8List bytes, String fileName) async {
//     final uri = Uri.parse(
//       "https://api.cloudinary.com/v1_1/$_cloudinaryCloudName/image/upload",
//     );

//     final request = http.MultipartRequest("POST", uri)
//       ..fields["upload_preset"] = _cloudinaryUploadPreset
//       ..files.add(
//         http.MultipartFile.fromBytes("file", bytes, filename: fileName),
//       );

//     final streamedResponse = await request.send();
//     final response = await http.Response.fromStream(streamedResponse);

//     if (response.statusCode != 200) {
//       throw Exception("Cloudinary upload failed: ${response.body}");
//     }

//     final data = jsonDecode(response.body) as Map<String, dynamic>;
//     return data["secure_url"] as String;
//   }

//   Future<void> _submit() async {
//     final formValid = _formKey.currentState!.validate();

//     if (!formValid || selectedDays.isEmpty) {
//       setState(() {
//         _autovalidateMode = AutovalidateMode.onUserInteraction;
//       });
//       if (selectedDays.isEmpty) {
//         _showSnack("Please select at least one available day", isError: true);
//       } else {
//         _showSnack("Please fix the highlighted fields", isError: true);
//       }
//       return;
//     }

//     setState(() => isSaving = true);

//     // Sort selected days in weekday order before saving
//     final orderedDays =
//         _allDays.where((day) => selectedDays.contains(day)).toList();

//     try {
//       String imageUrl = "";
//       if (_selectedImageBytes != null) {
//         imageUrl = await _uploadImage(
//           _selectedImageBytes!,
//           _selectedImageName ?? "photo.jpg",
//         );
//       }

//       await firestore.addDoctor(
//         name: nameController.text.trim(),
//         specialization: specializationController.text.trim(),
//         hospital: hospitalController.text.trim(),
//         experience: experienceController.text.trim(),
//         image: imageUrl,
//         availableDays: orderedDays,
//       );

//       if (!mounted) return;
//       _showSnack("Doctor Added Successfully");
//       Navigator.pop(context);
//     } catch (e) {
//       if (!mounted) return;
//       _showSnack("Failed to add doctor: $e", isError: true);
//     } finally {
//       if (mounted) {
//         setState(() => isSaving = false);
//       }
//     }
//   }

//   Widget _buildImagePicker() {
//     return GestureDetector(
//       onTap: isSaving ? null : _pickImage,
//       child: Container(
//         height: 160,
//         width: double.infinity,
//         clipBehavior: Clip.antiAlias,
//         decoration: BoxDecoration(
//           color: Colors.grey.shade50,
//           borderRadius: BorderRadius.circular(14),
//           border: Border.all(color: Colors.grey.shade200),
//         ),
//         child: _selectedImageBytes != null
//             ? Stack(
//                 fit: StackFit.expand,
//                 children: [
//                   Image.memory(_selectedImageBytes!, fit: BoxFit.cover),
//                   Positioned.fill(
//                     child: Container(
//                       alignment: Alignment.bottomCenter,
//                       padding: const EdgeInsets.symmetric(vertical: 8),
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           begin: Alignment.topCenter,
//                           end: Alignment.bottomCenter,
//                           colors: [
//                             Colors.transparent,
//                             Colors.black.withOpacity(0.45),
//                           ],
//                         ),
//                       ),
//                       child: const Text(
//                         "Tap to change photo",
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 12.5,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ),
//                   Positioned(
//                     top: 8,
//                     right: 8,
//                     child: GestureDetector(
//                       onTap: isSaving
//                           ? null
//                           : () => setState(() {
//                                 _selectedImageBytes = null;
//                                 _selectedImageName = null;
//                               }),
//                       child: Container(
//                         padding: const EdgeInsets.all(6),
//                         decoration: BoxDecoration(
//                           color: Colors.black.withOpacity(0.55),
//                           shape: BoxShape.circle,
//                         ),
//                         child: const Icon(
//                           Icons.close,
//                           color: Colors.white,
//                           size: 16,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               )
//             : Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.add_a_photo_outlined, color: _accent, size: 30),
//                   const SizedBox(height: 8),
//                   Text(
//                     "Tap to select doctor photo",
//                     style: TextStyle(
//                       color: Colors.grey.shade600,
//                       fontSize: 13,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ],
//               ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF3F4F6),
//       appBar: AppBar(
//         title: const Text("Add Doctor"),
//         backgroundColor: const Color(0xFF0F172A),
//         foregroundColor: Colors.white,
//         elevation: 0,
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(20),
//           child: Form(
//             key: _formKey,
//             autovalidateMode: _autovalidateMode,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(20),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(20),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.05),
//                         blurRadius: 12,
//                         offset: const Offset(0, 4),
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         "Doctor Details",
//                         style: TextStyle(
//                           fontSize: 17,
//                           fontWeight: FontWeight.w700,
//                           color: Color(0xFF111827),
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         "Fill in the doctor's profile information",
//                         style: TextStyle(
//                           fontSize: 12.5,
//                           color: Colors.grey.shade500,
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//                       TextFormField(
//                         controller: nameController,
//                         decoration: _fieldDecoration(
//                           label: "Doctor Name",
//                           icon: Icons.person_outline,
//                         ),
//                         validator: (value) => (value == null || value.isEmpty)
//                             ? "Enter doctor name"
//                             : null,
//                       ),
//                       const SizedBox(height: 16),
//                       TextFormField(
//                         controller: specializationController,
//                         decoration: _fieldDecoration(
//                           label: "Specialization",
//                           icon: Icons.local_hospital_outlined,
//                         ),
//                         validator: (value) => (value == null || value.isEmpty)
//                             ? "Enter specialization"
//                             : null,
//                       ),
//                       const SizedBox(height: 16),
//                       TextFormField(
//                         controller: hospitalController,
//                         decoration: _fieldDecoration(
//                           label: "Hospital",
//                           icon: Icons.apartment_outlined,
//                         ),
//                         validator: (value) => (value == null || value.isEmpty)
//                             ? "Enter hospital"
//                             : null,
//                       ),
//                       const SizedBox(height: 16),
//                       TextFormField(
//                         controller: experienceController,
//                         keyboardType: TextInputType.number,
//                         decoration: _fieldDecoration(
//                           label: "Experience (Years)",
//                           icon: Icons.timeline_outlined,
//                         ),
//                         validator: (value) => (value == null || value.isEmpty)
//                             ? "Enter years of experience"
//                             : null,
//                       ),
//                       const SizedBox(height: 16),
//                       Text(
//                         "Doctor Photo",
//                         style: TextStyle(
//                           fontSize: 13.5,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.grey.shade700,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       _buildImagePicker(),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 Container(
//                   padding: const EdgeInsets.all(20),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(20),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.05),
//                         blurRadius: 12,
//                         offset: const Offset(0, 4),
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           const Icon(Icons.calendar_month_outlined,
//                               color: _accent, size: 20),
//                           const SizedBox(width: 8),
//                           const Text(
//                             "Available Days",
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w700,
//                               color: Color(0xFF111827),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         "Select the days this doctor is available",
//                         style: TextStyle(
//                           fontSize: 12.5,
//                           color: Colors.grey.shade500,
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       Wrap(
//                         spacing: 10,
//                         runSpacing: 10,
//                         children: _allDays.map((day) {
//                           final isSelected = selectedDays.contains(day);
//                           return GestureDetector(
//                             onTap: () {
//                               setState(() {
//                                 if (isSelected) {
//                                   selectedDays.remove(day);
//                                 } else {
//                                   selectedDays.add(day);
//                                 }
//                               });
//                             },
//                             child: AnimatedContainer(
//                               duration: const Duration(milliseconds: 180),
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 16,
//                                 vertical: 10,
//                               ),
//                               decoration: BoxDecoration(
//                                 color:
//                                     isSelected ? _accent : Colors.grey.shade100,
//                                 borderRadius: BorderRadius.circular(12),
//                                 border: Border.all(
//                                   color: isSelected
//                                       ? _accent
//                                       : Colors.grey.shade300,
//                                 ),
//                               ),
//                               child: Text(
//                                 day,
//                                 style: TextStyle(
//                                   color: isSelected
//                                       ? Colors.white
//                                       : Colors.grey.shade700,
//                                   fontWeight: FontWeight.w600,
//                                   fontSize: 13,
//                                 ),
//                               ),
//                             ),
//                           );
//                         }).toList(),
//                       ),
//                       if (_autovalidateMode ==
//                               AutovalidateMode.onUserInteraction &&
//                           selectedDays.isEmpty) ...[
//                         const SizedBox(height: 10),
//                         Text(
//                           "Select at least one day",
//                           style: TextStyle(
//                             color: Colors.red.shade600,
//                             fontSize: 12.5,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ],
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 28),
//                 SizedBox(
//                   width: double.infinity,
//                   height: 52,
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: _accent,
//                       foregroundColor: Colors.white,
//                       elevation: isSaving ? 0 : 4,
//                       shadowColor: _accent.withOpacity(0.4),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(14),
//                       ),
//                     ),
//                     onPressed: isSaving ? null : _submit,
//                     child: isSaving
//                         ? const SizedBox(
//                             height: 22,
//                             width: 22,
//                             child: CircularProgressIndicator(
//                               color: Colors.white,
//                               strokeWidth: 2.4,
//                             ),
//                           )
//                         : const Text(
//                             "Add Doctor",
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:medicare_connect/services/firestore.dart';

class AddDoctorScreen extends StatefulWidget {
  const AddDoctorScreen({super.key});

  @override
  State<AddDoctorScreen> createState() => _AddDoctorScreenState();
}

class _AddDoctorScreenState extends State<AddDoctorScreen> {
  final nameController = TextEditingController();
  final specializationController = TextEditingController();
  final hospitalController = TextEditingController();
  final experienceController = TextEditingController();

  // NEW: login credentials for the doctor being created.
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final firestore = FirestoreService();
  final ImagePicker _picker = ImagePicker();

  bool isSaving = false;
  bool obscurePassword = true;
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  Uint8List? _selectedImageBytes;
  String? _selectedImageName;

  // Cloudinary (unsigned upload)
  static const String _cloudinaryUploadPreset = "Tourbooking";
  static const String _cloudinaryCloudName = "dotnhabff";

  static const List<String> _allDays = [
    "Mon",
    "Tue",
    "Wed",
    "Thu",
    "Fri",
    "Sat",
    "Sun",
  ];

  final Set<String> selectedDays = {};

  static const Color _accent = Color(0xFF2563EB);

  @override
  void dispose() {
    nameController.dispose();
    specializationController.dispose();
    hospitalController.dispose();
    experienceController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  InputDecoration _fieldDecoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey.shade700),
      prefixIcon: Icon(icon, color: _accent),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _accent, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.red.shade400, width: 1.4),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.red.shade600, width: 1.8),
      ),
      errorStyle: TextStyle(
        color: Colors.red.shade600,
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _selectedImageBytes = bytes;
          _selectedImageName = pickedFile.name;
        });
      }
    } catch (e) {
      if (!mounted) return;
      _showSnack("Failed to pick image: $e", isError: true);
    }
  }

  Future<String> _uploadImage(Uint8List bytes, String fileName) async {
    final uri = Uri.parse(
      "https://api.cloudinary.com/v1_1/$_cloudinaryCloudName/image/upload",
    );

    final request = http.MultipartRequest("POST", uri)
      ..fields["upload_preset"] = _cloudinaryUploadPreset
      ..files.add(
        http.MultipartFile.fromBytes("file", bytes, filename: fileName),
      );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      throw Exception("Cloudinary upload failed: ${response.body}");
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data["secure_url"] as String;
  }

  // Creates a Firebase Auth account for the doctor WITHOUT logging the
  // admin out. This is done via a temporary secondary FirebaseApp, since
  // FirebaseAuth.instance.createUserWithEmailAndPassword() on the default
  // app would sign the admin's session out and sign in as the new doctor.
  Future<String> _createDoctorAuthAccount({
    required String email,
    required String password,
  }) async {
    FirebaseApp secondaryApp = await Firebase.initializeApp(
      name: "DoctorCreation_${DateTime.now().millisecondsSinceEpoch}",
      options: Firebase.app().options,
    );

    try {
      final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);

      final credential = await secondaryAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;

      // Sign out of the secondary app's session (doesn't affect admin).
      await secondaryAuth.signOut();

      return uid;
    } finally {
      await secondaryApp.delete();
    }
  }

  Future<void> _submit() async {
    final formValid = _formKey.currentState!.validate();

    if (!formValid || selectedDays.isEmpty) {
      setState(() {
        _autovalidateMode = AutovalidateMode.onUserInteraction;
      });
      if (selectedDays.isEmpty) {
        _showSnack("Please select at least one available day", isError: true);
      } else {
        _showSnack("Please fix the highlighted fields", isError: true);
      }
      return;
    }

    setState(() => isSaving = true);

    // Sort selected days in weekday order before saving
    final orderedDays =
        _allDays.where((day) => selectedDays.contains(day)).toList();

    try {
      String imageUrl = "";
      if (_selectedImageBytes != null) {
        imageUrl = await _uploadImage(
          _selectedImageBytes!,
          _selectedImageName ?? "photo.jpg",
        );
      }

      // 1. Create the doctor's login account.
      final doctorUid = await _createDoctorAuthAccount(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // 2. Save the "users" record so login.dart can resolve role == "Doctor".
      await firestore.saveUser(
        uid: doctorUid,
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        role: "Doctor",
      );

      // 3. Save the public doctor profile using the SAME id as the auth uid,
      //    so it's linked to the account created above.
      await firestore.addDoctor(
        doctorId: doctorUid,
        name: nameController.text.trim(),
        specialization: specializationController.text.trim(),
        hospital: hospitalController.text.trim(),
        experience: experienceController.text.trim(),
        image: imageUrl,
        availableDays: orderedDays,
      );

      if (!mounted) return;
      _showSnack(
          "Doctor Added — they can now log in with the given email/password");
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      _showSnack(e.message ?? "Failed to create doctor login", isError: true);
    } catch (e) {
      if (!mounted) return;
      _showSnack("Failed to add doctor: $e", isError: true);
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: isSaving ? null : _pickImage,
      child: Container(
        height: 160,
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: _selectedImageBytes != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  Image.memory(_selectedImageBytes!, fit: BoxFit.cover),
                  Positioned.fill(
                    child: Container(
                      alignment: Alignment.bottomCenter,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.45),
                          ],
                        ),
                      ),
                      child: const Text(
                        "Tap to change photo",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: isSaving
                          ? null
                          : () => setState(() {
                                _selectedImageBytes = null;
                                _selectedImageName = null;
                              }),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.55),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo_outlined, color: _accent, size: 30),
                  const SizedBox(height: 8),
                  Text(
                    "Tap to select doctor photo",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text("Add Doctor"),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            autovalidateMode: _autovalidateMode,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Doctor Details",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Fill in the doctor's profile information",
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: nameController,
                        decoration: _fieldDecoration(
                          label: "Doctor Name",
                          icon: Icons.person_outline,
                        ),
                        validator: (value) => (value == null || value.isEmpty)
                            ? "Enter doctor name"
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: specializationController,
                        decoration: _fieldDecoration(
                          label: "Specialization",
                          icon: Icons.local_hospital_outlined,
                        ),
                        validator: (value) => (value == null || value.isEmpty)
                            ? "Enter specialization"
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: hospitalController,
                        decoration: _fieldDecoration(
                          label: "Hospital",
                          icon: Icons.apartment_outlined,
                        ),
                        validator: (value) => (value == null || value.isEmpty)
                            ? "Enter hospital"
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: experienceController,
                        keyboardType: TextInputType.number,
                        decoration: _fieldDecoration(
                          label: "Experience (Years)",
                          icon: Icons.timeline_outlined,
                        ),
                        validator: (value) => (value == null || value.isEmpty)
                            ? "Enter years of experience"
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Doctor Photo",
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildImagePicker(),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // NEW: Login credentials card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Doctor Login",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "This email/password will be given to the doctor to log in",
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: _fieldDecoration(
                          label: "Doctor Email",
                          icon: Icons.email_outlined,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Enter doctor email";
                          }
                          if (!value.contains("@")) {
                            return "Enter a valid email";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: passwordController,
                        obscureText: obscurePassword,
                        decoration: _fieldDecoration(
                          label: "Temporary Password",
                          icon: Icons.lock_outline,
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: Colors.grey.shade600,
                            ),
                            onPressed: () {
                              setState(() {
                                obscurePassword = !obscurePassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.length < 6) {
                            return "Minimum 6 characters";
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_month_outlined,
                              color: _accent, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            "Available Days",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF111827),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Select the days this doctor is available",
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: _allDays.map((day) {
                          final isSelected = selectedDays.contains(day);
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  selectedDays.remove(day);
                                } else {
                                  selectedDays.add(day);
                                }
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isSelected ? _accent : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? _accent
                                      : Colors.grey.shade300,
                                ),
                              ),
                              child: Text(
                                day,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.grey.shade700,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      if (_autovalidateMode ==
                              AutovalidateMode.onUserInteraction &&
                          selectedDays.isEmpty) ...[
                        const SizedBox(height: 10),
                        Text(
                          "Select at least one day",
                          style: TextStyle(
                            color: Colors.red.shade600,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accent,
                      foregroundColor: Colors.white,
                      elevation: isSaving ? 0 : 4,
                      shadowColor: _accent.withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: isSaving ? null : _submit,
                    child: isSaving
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.4,
                            ),
                          )
                        : const Text(
                            "Add Doctor",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
