class LocationModel {
  final int id;
  final String name;
  final String fullAddress;

  LocationModel({
    required this.id,
    required this.name,
    required this.fullAddress,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id'],
      name: json['name'],
      fullAddress: json['full_address'],
    );
  }
}

class MeetingTypeModel {
  final int id;
  final String name;
  final String description;
  final String icon;

  MeetingTypeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
  });

  factory MeetingTypeModel.fromJson(Map<String, dynamic> json) {
    return MeetingTypeModel(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      icon: json['icon'],
    );
  }
}

class LanguageModel {
  final int id;
  final String name;
  final String flag;

  LanguageModel({
    required this.id,
    required this.name,
    required this.flag,
  });

  factory LanguageModel.fromJson(Map<String, dynamic> json) {
    return LanguageModel(
      id: json['id'],
      name: json['name'],
      flag: json['country_flag'] ?? '',
    );
  }
}


class ServiceTypeModel {
  final int id;
  final String name;
  final double price;
  final String priceDisplay;
  final int duration;
  final String durationUnit;
  final String startTime;
  final String endTime;
  final String timeFormat;
  final List<String> availableDays;
  final String timeSlotDescription;
  final String description;
  final bool includesVideoCall;
  final bool availableForOverseas;

  ServiceTypeModel({
    required this.id,
    required this.name,
    required this.price,
    required this.priceDisplay,
    required this.duration,
    required this.durationUnit,
    required this.startTime,
    required this.endTime,
    required this.timeFormat,
    required this.availableDays,
    required this.timeSlotDescription,
    required this.description,
    required this.includesVideoCall,
    required this.availableForOverseas,
  });

  factory ServiceTypeModel.fromJson(Map<String, dynamic> json) {
    return ServiceTypeModel(
      id: json['id'],
      name: json['name'],
      price: (json['price'] is int)
          ? (json['price'] as int).toDouble()
          : json['price'] ?? 0.0,
      priceDisplay: json['price_display'] ?? '',
      duration: json['duration'] ?? 0,
      durationUnit: json['duration_unit'] ?? '',
      startTime: json['time_slots']?['start_time'] ?? '',
      endTime: json['time_slots']?['end_time'] ?? '',
      timeFormat: json['time_slots']?['time_format'] ?? '',
      availableDays: List<String>.from(json['availability']?['days'] ?? []),
      timeSlotDescription: json['availability']?['time_slots'] ?? '',
      description: json['description'] ?? '',
      includesVideoCall: json['includes_video_call'] ?? false,
      availableForOverseas: json['available_for_overseas'] ?? false,
    );
  }
}

class SimpleServiceModel {
  final int id;
  final String name;

  SimpleServiceModel({required this.id, required this.name});

  factory SimpleServiceModel.fromJson(Map<String, dynamic> json) {
    return SimpleServiceModel(
      id: json['id'],
      name: json['name'],
    );
  }
}
