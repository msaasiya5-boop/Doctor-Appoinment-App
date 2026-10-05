class DoctorModel {
  final String id;
  final String name;
  final String specialization;
  final String hospital;
  final String experience;
  final String image;

  DoctorModel({
    required this.id,
    required this.name,
    required this.specialization,
    required this.hospital,
    required this.experience,
    required this.image,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "specialization": specialization,
      "hospital": hospital,
      "experience": experience,
      "image": image,
    };
  }

  factory DoctorModel.fromMap(Map<String, dynamic> map) {
    return DoctorModel(
      id: map["id"] ?? "",
      name: map["name"] ?? "",
      specialization: map["specialization"] ?? "",
      hospital: map["hospital"] ?? "",
      experience: map["experience"] ?? "",
      image: map["image"] ?? "",
    );
  }
}
