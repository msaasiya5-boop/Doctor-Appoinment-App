// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:medicare_connect/services/firestore.dart';

// class BookAppointment extends StatefulWidget {
//   final String doctorId;
//   final String doctorName;

//   const BookAppointment({
//     super.key,
//     required this.doctorId,
//     required this.doctorName,
//   });

//   @override
//   State<BookAppointment> createState() => _BookAppointmentState();
// }

// class _BookAppointmentState extends State<BookAppointment> {
//   final patientController = TextEditingController();

//   DateTime? selectedDate;

//   String selectedTime = "09:00 AM";

//   bool isLoading = false;

//   final List<String> availableSlots = [
//     "09:00 AM",
//     "09:30 AM",
//     "10:00 AM",
//     "10:30 AM",
//     "11:00 AM",
//     "11:30 AM",
//     "02:00 PM",
//     "02:30 PM",
//     "03:00 PM",
//     "03:30 PM",
//     "04:00 PM",
//   ];

//   @override
//   void dispose() {
//     patientController.dispose();
//     super.dispose();
//   }

//   Future<void> bookAppointment() async {
//     if (patientController.text.trim().isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("Enter Patient Name"),
//         ),
//       );
//       return;
//     }

//     if (selectedDate == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("Select Appointment Date"),
//         ),
//       );
//       return;
//     }

//     setState(() {
//       isLoading = true;
//     });

//     await FirestoreService().bookAppointment(
//       patientId: FirebaseAuth.instance.currentUser!.uid,
//       doctorId: widget.doctorId,
//       doctorName: widget.doctorName,
//       patientName: patientController.text.trim(),
//       date: "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
//       time: selectedTime,
//     );

//     setState(() {
//       isLoading = false;
//     });

//     if (!mounted) return;

//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text("Appointment Booked Successfully"),
//         backgroundColor: Colors.green,
//       ),
//     );

//     Navigator.pop(context);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.doctorName),
//         centerTitle: true,
//       ),
//       body: ListView(
//         padding: const EdgeInsets.all(20),
//         children: [
//           TextField(
//             controller: patientController,
//             decoration: const InputDecoration(
//               labelText: "Patient Name",
//               prefixIcon: Icon(Icons.person),
//               border: OutlineInputBorder(),
//             ),
//           ),
//           const SizedBox(height: 20),
//           Card(
//             child: ListTile(
//               leading: const Icon(Icons.calendar_month),
//               title: Text(
//                 selectedDate == null
//                     ? "Select Appointment Date"
//                     : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
//               ),
//               trailing: const Icon(Icons.arrow_drop_down),
//               onTap: () async {
//                 final picked = await showDatePicker(
//                   context: context,
//                   initialDate: DateTime.now(),
//                   firstDate: DateTime.now(),
//                   lastDate: DateTime(2035),
//                 );

//                 if (picked != null) {
//                   setState(() {
//                     selectedDate = picked;
//                   });
//                 }
//               },
//             ),
//           ),
//           const SizedBox(height: 20),
//           DropdownButtonFormField<String>(
//             value: selectedTime,
//             decoration: const InputDecoration(
//               labelText: "Select Time Slot",
//               border: OutlineInputBorder(),
//               prefixIcon: Icon(Icons.access_time),
//             ),
//             items: availableSlots.map((time) {
//               return DropdownMenuItem(
//                 value: time,
//                 child: Text(time),
//               );
//             }).toList(),
//             onChanged: (value) {
//               setState(() {
//                 selectedTime = value!;
//               });
//             },
//           ),
//           const SizedBox(height: 35),
//           SizedBox(
//             height: 50,
//             child: ElevatedButton(
//               onPressed: isLoading ? null : bookAppointment,
//               child: isLoading
//                   ? const CircularProgressIndicator(
//                       color: Colors.white,
//                     )
//                   : const Text(
//                       "Book Appointment",
//                       style: TextStyle(fontSize: 18),
//                     ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:medicare_connect/services/firestore.dart';

/// Maps the short day labels used on the doctor card (e.g. "Mon", "Wed")
/// to Dart's DateTime.weekday values.
const Map<String, int> _dayNameToWeekday = {
  "Mon": DateTime.monday,
  "Tue": DateTime.tuesday,
  "Wed": DateTime.wednesday,
  "Thu": DateTime.thursday,
  "Fri": DateTime.friday,
  "Sat": DateTime.saturday,
  "Sun": DateTime.sunday,
};

class BookAppointment extends StatefulWidget {
  final String doctorId;
  final String doctorName;

  /// e.g. ["Mon", "Wed", "Fri", "Sun"] — comes from the doctor's profile
  /// (same list shown as chips on the Find Doctors card).
  final List<String> availableDays;

  const BookAppointment({
    super.key,
    required this.doctorId,
    required this.doctorName,
    required this.availableDays,
  });

  @override
  State<BookAppointment> createState() => _BookAppointmentState();
}

class _BookAppointmentState extends State<BookAppointment> {
  final patientController = TextEditingController();

  DateTime? selectedDate;

  String selectedTime = "09:00 AM";

  bool isLoading = false;

  final List<String> availableSlots = [
    "09:00 AM",
    "09:30 AM",
    "10:00 AM",
    "10:30 AM",
    "11:00 AM",
    "11:30 AM",
    "02:00 PM",
    "02:30 PM",
    "03:00 PM",
    "03:30 PM",
    "04:00 PM",
  ];

  /// Weekday ints (1-7) the doctor is available on, derived from
  /// widget.availableDays. Falls back to "every day" if the list is
  /// somehow empty, so booking is never accidentally blocked entirely.
  late final Set<int> availableWeekdays = () {
    final days = widget.availableDays
        .map((d) => _dayNameToWeekday[d])
        .whereType<int>()
        .toSet();
    return days.isEmpty ? {1, 2, 3, 4, 5, 6, 7} : days;
  }();

  /// Finds the soonest date (starting today) that falls on one of the
  /// doctor's available weekdays. Needed because showDatePicker requires
  /// initialDate to satisfy selectableDayPredicate, or it throws.
  DateTime _firstAvailableDate() {
    DateTime date = DateTime.now();
    for (int i = 0; i < 7; i++) {
      if (availableWeekdays.contains(date.weekday)) return date;
      date = date.add(const Duration(days: 1));
    }
    return DateTime.now();
  }

  String get _availableDaysLabel => widget.availableDays.join(", ");

  @override
  void dispose() {
    patientController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _firstAvailableDate(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
      selectableDayPredicate: (date) =>
          availableWeekdays.contains(date.weekday),
    );

    if (picked == null) return;

    // Safety net in case selectableDayPredicate is ever bypassed
    // (e.g. platform date picker quirks).
    if (!availableWeekdays.contains(picked.weekday)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Dr. ${widget.doctorName} is not available on this day. "
            "Available days: $_availableDaysLabel",
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      selectedDate = picked;
    });
  }

  Future<void> bookAppointment() async {
    if (patientController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Enter Patient Name"),
        ),
      );
      return;
    }

    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Select Appointment Date"),
        ),
      );
      return;
    }

    // Final guard right before writing to Firestore.
    if (!availableWeekdays.contains(selectedDate!.weekday)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Dr. ${widget.doctorName} is not available on this day. "
            "Available days: $_availableDaysLabel",
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    await FirestoreService().bookAppointment(
      patientId: FirebaseAuth.instance.currentUser!.uid,
      doctorId: widget.doctorId,
      doctorName: widget.doctorName,
      patientName: patientController.text.trim(),
      date: "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
      time: selectedTime,
    );

    setState(() {
      isLoading = false;
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Appointment Booked Successfully"),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.doctorName),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: patientController,
            decoration: const InputDecoration(
              labelText: "Patient Name",
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              "Available on: $_availableDaysLabel",
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.calendar_month),
              title: Text(
                selectedDate == null
                    ? "Select Appointment Date"
                    : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
              ),
              trailing: const Icon(Icons.arrow_drop_down),
              onTap: _pickDate,
            ),
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            value: selectedTime,
            decoration: const InputDecoration(
              labelText: "Select Time Slot",
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.access_time),
            ),
            items: availableSlots.map((time) {
              return DropdownMenuItem(
                value: time,
                child: Text(time),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedTime = value!;
              });
            },
          ),
          const SizedBox(height: 35),
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: isLoading ? null : bookAppointment,
              child: isLoading
                  ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                  : const Text(
                      "Book Appointment",
                      style: TextStyle(fontSize: 18),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
