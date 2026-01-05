import 'package:equatable/equatable.dart';

class MaintenanceSupply extends Equatable {
  final int? id;
  final int maintenancePlanItemId;
  final String type; // 'Part' or 'Fluid'
  final String maker;
  final String code;
  final String? quantity;
  final String? notes;

  const MaintenanceSupply({
    this.id,
    required this.maintenancePlanItemId,
    required this.type,
    required this.maker,
    required this.code,
    this.quantity,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'maintenancePlanItemId': maintenancePlanItemId,
      'type': type,
      'maker': maker,
      'code': code,
      'quantity': quantity,
      'notes': notes,
    };
  }

  factory MaintenanceSupply.fromMap(Map<String, dynamic> map) {
    return MaintenanceSupply(
      id: map['id'] as int?,
      maintenancePlanItemId: map['maintenancePlanItemId'] as int,
      type: map['type'] as String,
      maker: map['maker'] as String,
      code: map['code'] as String,
      quantity: map['quantity'] as String?,
      notes: map['notes'] as String?,
    );
  }

  MaintenanceSupply copyWith({
    int? id,
    int? maintenancePlanItemId,
    String? type,
    String? maker,
    String? code,
    String? quantity,
    String? notes,
  }) {
    return MaintenanceSupply(
      id: id ?? this.id,
      maintenancePlanItemId: maintenancePlanItemId ?? this.maintenancePlanItemId,
      type: type ?? this.type,
      maker: maker ?? this.maker,
      code: code ?? this.code,
      quantity: quantity ?? this.quantity,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
    id,
    maintenancePlanItemId,
    type,
    maker,
    code,
    quantity,
    notes,
  ];

  @override
  String toString() {
    return 'MaintenanceSupply{id: $id, type: $type, maker: $maker, code: $code}';
  }
}
