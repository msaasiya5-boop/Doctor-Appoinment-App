class AppointmentModel {
  final String id;
  final String patientId;
  final String doctorId;
  final String doctorName;
  final String patientName;
  final String date;
  final String time;
  final String status;

  AppointmentModel({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.doctorName,
    required this.patientName,
    required this.date,
    required this.time,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "patientId": patientId,
      "doctorId": doctorId,
      "doctorName": doctorName,
      "patientName": patientName,
      "date": date,
      "time": time,
      "status": status,
    };
  }
}
