class AppointmentModel {
  final int id;
  final String enquiryTypeDisplay;
  final String serviceType;
  final String meetingTypeDisplay;
  final String location;
  final String statusDisplay;
  final String appointmentDate;
  final String appointmentTime;

  AppointmentModel({
    required this.id,
    required this.enquiryTypeDisplay,
    required this.serviceType,
    required this.meetingTypeDisplay,
    required this.location,
    required this.statusDisplay,
    required this.appointmentDate,
    required this.appointmentTime,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'],
      enquiryTypeDisplay: json['enquiry_type_display'],
      serviceType: json['service_type'],
      meetingTypeDisplay: json['meeting_type_display'],
      location: json['location'],
      statusDisplay: json['status_display'],
      appointmentDate: json['appointment_date'],
      appointmentTime: json['appointment_time'],
    );
  }
}
