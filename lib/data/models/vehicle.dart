import 'dart:typed_data';

import 'package:equatable/equatable.dart';

class Vehicle extends Equatable {
  final int? id;
  final String name;
  final double mileage;
  final DateTime mileageLastUpdated;
  final DateTime boughtDate;
  final Uint8List? image;
  final String? make;
  final String? model;
  final int? modelYear;
  final String? plateNumber;
  final String? vin;
  final String? engineNumber;

  const Vehicle({
    this.id,
    required this.name,
    required this.mileage,
    required this.mileageLastUpdated,
    required this.boughtDate,
    this.image,
    this.make,
    this.model,
    this.modelYear,
    this.plateNumber,
    this.vin,
    this.engineNumber,
  });

  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
      id: map['id'] as int?,
      name: map['name'] as String,
      mileage: (map['mileage'] as num).toDouble(),
      mileageLastUpdated: DateTime.parse(map['mileage_last_updated'] as String),
      boughtDate: DateTime.parse(map['bought_date'] as String),
      image: map['image'] as Uint8List?,
      make: map['make'] as String?,
      model: map['model'] as String?,
      modelYear: map['model_year'] as int?,
      plateNumber: map['plate_number'] as String?,
      vin: map['vin'] as String?,
      engineNumber: map['engine_number'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'mileage': mileage,
      'mileage_last_updated': mileageLastUpdated.toIso8601String(),
      'bought_date': boughtDate.toIso8601String(),
      'image': image,
      'make': make,
      'model': model,
      'model_year': modelYear,
      'plate_number': plateNumber,
      'vin': vin,
      'engine_number': engineNumber,
    };
  }

  Vehicle copyWith({
    int? id,
    String? name,
    double? mileage,
    DateTime? mileageLastUpdated,
    DateTime? boughtDate,
    Uint8List? image,
    String? make,
    String? model,
    int? modelYear,
    String? plateNumber,
    String? vin,
    String? engineNumber,
    bool clearImage = false, // Special flag to nullify image
  }) {
    return Vehicle(
      id: id ?? this.id,
      name: name ?? this.name,
      mileage: mileage ?? this.mileage,
      mileageLastUpdated: mileageLastUpdated ?? this.mileageLastUpdated,
      boughtDate: boughtDate ?? this.boughtDate,
      image: clearImage ? null : (image ?? this.image),
      make: make ?? this.make,
      model: model ?? this.model,
      modelYear: modelYear ?? this.modelYear,
      plateNumber: plateNumber ?? this.plateNumber,
      vin: vin ?? this.vin,
      engineNumber: engineNumber ?? this.engineNumber,
    );
  }

  bool isIdentical(Vehicle other) {
    return id == other.id &&
        name == other.name &&
        mileage == other.mileage &&
        mileageLastUpdated == other.mileageLastUpdated &&
        boughtDate == other.boughtDate &&
        image == other.image &&
        make == other.make &&
        model == other.model &&
        modelYear == other.modelYear &&
        plateNumber == other.plateNumber &&
        vin == other.vin &&
        engineNumber == other.engineNumber;
  }

  @override
  List<Object?> get props => [
    id,
    name,
    mileage,
    mileageLastUpdated,
    boughtDate,
    image,
    make,
    model,
    modelYear,
    plateNumber,
    vin,
    engineNumber,
  ];

  @override
  String toString() {
    return 'Vehicle{id: $id, name: $name}';
  }
}
