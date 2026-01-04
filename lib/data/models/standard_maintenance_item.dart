import 'package:equatable/equatable.dart';

class StandardMaintenanceItem extends Equatable {
  final int? id;
  final String itemName;
  final int? intervalTimeMonths;
  final int? intervalMileage;
  final int? firstIntervalTimeMonths;
  final int? firstIntervalMileage;
  final String? notes;

  const StandardMaintenanceItem({
    this.id,
    required this.itemName,
    this.intervalTimeMonths,
    this.intervalMileage,
    this.firstIntervalTimeMonths,
    this.firstIntervalMileage,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'itemName': itemName,
      'intervalTimeMonths': intervalTimeMonths,
      'intervalMileage': intervalMileage,
      'firstIntervalTimeMonths': firstIntervalTimeMonths,
      'firstIntervalMileage': firstIntervalMileage,
      'notes': notes,
    };
  }

  factory StandardMaintenanceItem.fromMap(Map<String, dynamic> map) {
    return StandardMaintenanceItem(
      id: map['id'] as int?,
      itemName: map['itemName'] as String,
      intervalTimeMonths: map['intervalTimeMonths'] as int?,
      intervalMileage: map['intervalMileage'] as int?,
      firstIntervalTimeMonths: map['firstIntervalTimeMonths'] as int?,
      firstIntervalMileage: map['firstIntervalMileage'] as int?,
      notes: map['notes'] as String?,
    );
  }

  StandardMaintenanceItem copyWith({
    int? id,
    String? itemName,
    int? intervalTimeMonths,
    int? intervalMileage,
    int? firstIntervalTimeMonths,
    int? firstIntervalMileage,
    String? notes,
    bool setNotesToNull = false,
    bool setIntervalTimeMonthsToNull = false,
    bool setIntervalMileageToNull = false,
    bool setFirstIntervalTimeMonthsToNull = false,
    bool setFirstIntervalMileageToNull = false,
  }) {
    return StandardMaintenanceItem(
      id: id ?? this.id,
      itemName: itemName ?? this.itemName,
      intervalTimeMonths:
          setIntervalTimeMonthsToNull
              ? null
              : (intervalTimeMonths ?? this.intervalTimeMonths),
      intervalMileage:
          setIntervalMileageToNull
              ? null
              : (intervalMileage ?? this.intervalMileage),
      firstIntervalTimeMonths:
          setFirstIntervalTimeMonthsToNull
              ? null
              : (firstIntervalTimeMonths ?? this.firstIntervalTimeMonths),
      firstIntervalMileage:
          setFirstIntervalMileageToNull
              ? null
              : (firstIntervalMileage ?? this.firstIntervalMileage),
      notes: setNotesToNull ? null : (notes ?? this.notes),
    );
  }

  @override
  List<Object?> get props => [
    id,
    itemName,
    intervalTimeMonths,
    intervalMileage,
    firstIntervalTimeMonths,
    firstIntervalMileage,
    notes,
  ];

  @override
  String toString() {
    return 'StandardMaintenanceItem{id: $id, itemName: $itemName}';
  }
}
