import 'package:equatable/equatable.dart';

import 'package:carvita/data/models/standard_maintenance_item.dart';

abstract class StandardMaintenanceState extends Equatable {
  const StandardMaintenanceState();

  @override
  List<Object?> get props => [];
}

class StandardMaintenanceInitial extends StandardMaintenanceState {}

class StandardMaintenanceLoading extends StandardMaintenanceState {}

class StandardMaintenanceLoaded extends StandardMaintenanceState {
  final List<StandardMaintenanceItem> items;

  const StandardMaintenanceLoaded(this.items);

  @override
  List<Object?> get props => [items];
}

class StandardMaintenanceOperationSuccess extends StandardMaintenanceState {
  final String message;

  const StandardMaintenanceOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class StandardMaintenanceError extends StandardMaintenanceState {
  final String message;

  const StandardMaintenanceError(this.message);

  @override
  List<Object?> get props => [message];
}
