import 'package:flutter/material.dart';
import 'package:medicare_connect/services/firestore.dart';

class EditDoctorScreen extends StatefulWidget {
  final String doctorId;
  final String name;
  final String specialization;
  final String hospital;
  final String experience;
  final List<String> availableDays;

  const EditDoctorScreen({
    super.key,
    required this.doctorId,
    required this.name,
    required this.specialization,
    required this.hospital,
    required this.experience,
    this.availableDays = const [],
  });

  @override
  State<EditDoctorScreen> createState() => _EditDoctorScreenState();
}

class _EditDoctorScreenState extends State<EditDoctorScreen> {
  late TextEditingController nameController;
  late TextEditingController specializationController;
  late TextEditingController hospitalController;
  late TextEditingController experienceController;

  final _formKey = GlobalKey<FormState>();
  final firestore = FirestoreService();

  bool isSaving = false;
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  static const List<String> _allDays = [
    "Mon",
    "Tue",
    "Wed",
    "Thu",
    "Fri",
    "Sat",
    "Sun",
  ];

  late final Set<String> selectedDays;

  static const Color _accent = Color(0xFF2563EB);
  static const Color _primaryDark = Color(0xFF0F172A);

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.name);
    specializationController =
        TextEditingController(text: widget.specialization);
    hospitalController = TextEditingController(text: widget.hospital);
    experienceController = TextEditingController(text: widget.experience);

    selectedDays = {...widget.availableDays};
  }

  @override
  void dispose() {
    nameController.dispose();
    specializationController.dispose();
    hospitalController.dispose();
    experienceController.dispose();
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
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey.shade700),
      prefixIcon: Icon(icon, color: _accent),
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

    final orderedDays =
        _allDays.where((day) => selectedDays.contains(day)).toList();

    try {
      await firestore.updateDoctor(
        doctorId: widget.doctorId,
        name: nameController.text.trim(),
        specialization: specializationController.text.trim(),
        hospital: hospitalController.text.trim(),
        experience: experienceController.text.trim(),
        availableDays: orderedDays,
      );

      if (!mounted) return;
      _showSnack("Doctor Updated Successfully");
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      _showSnack("Failed to update doctor: $e", isError: true);
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text("Edit Doctor"),
        backgroundColor: _primaryDark,
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
                        "Update the doctor's profile information",
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
                            "Update Doctor",
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
