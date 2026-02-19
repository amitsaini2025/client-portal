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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'full_address': fullAddress,
    };
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
    };
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'country_flag': flag,
    };
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
    final timeSlots = json['time_slots'] ?? {};
    final availability = json['availability'] ?? {};

    return ServiceTypeModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      price: (json['price'] is int)
          ? (json['price'] as int).toDouble()
          : (json['price'] ?? 0.0).toDouble(),
      priceDisplay: json['price_display'] ?? '',
      duration: json['duration'] ?? 0,
      durationUnit: json['duration_unit'] ?? '',
      startTime: timeSlots['start_time'] ?? '',
      endTime: timeSlots['end_time'] ?? '',
      timeFormat: timeSlots['time_format'] ?? '',
      availableDays: availability['days'] != null
          ? List<String>.from(availability['days'])
          : [],
      timeSlotDescription: availability['time_slots'] ?? '',
      description: json['description'] ?? '',
      includesVideoCall: json['includes_video_call'] ?? false,
      availableForOverseas: json['available_for_overseas'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'price_display': priceDisplay,
      'duration': duration,
      'duration_unit': durationUnit,
      'time_slots': {
        'start_time': startTime,
        'end_time': endTime,
        'time_format': timeFormat,
      },
      'availability': {
        'days': availableDays,
        'time_slots': timeSlotDescription,
      },
      'description': description,
      'includes_video_call': includesVideoCall,
      'available_for_overseas': availableForOverseas,
    };
  }
}

class SimpleServiceModel {
  final int id;
  final String name;

  SimpleServiceModel({
    required this.id,
    required this.name,
  });

  factory SimpleServiceModel.fromJson(Map<String, dynamic> json) {
    return SimpleServiceModel(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
