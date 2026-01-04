import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:carvita/data/models/standard_maintenance_item.dart';
import 'package:carvita/data/repositories/maintenance_repository.dart';
import 'package:carvita/presentation/manager/standard_maintenance/standard_maintenance_state.dart';

class StandardMaintenanceCubit extends Cubit<StandardMaintenanceState> {
  final MaintenanceRepository _repository;

  StandardMaintenanceCubit(this._repository)
    : super(StandardMaintenanceInitial());

  Future<void> loadStandardItems() async {
    emit(StandardMaintenanceLoading());
    try {
      final items = await _repository.getAllStandardItems();
      emit(StandardMaintenanceLoaded(items));
    } catch (e) {
      emit(StandardMaintenanceError('Failed to load standard items: $e'));
    }
  }

  Future<void> addStandardItem(StandardMaintenanceItem item) async {
    emit(StandardMaintenanceLoading());
    try {
      await _repository.addStandardItem(item);
      emit(const StandardMaintenanceOperationSuccess('Item added successfully'));
      loadStandardItems();
    } catch (e) {
      emit(StandardMaintenanceError('Failed to add item: $e'));
      // Reload items to show the list again
      loadStandardItems();
    }
  }

  Future<void> updateStandardItem(StandardMaintenanceItem item) async {
    emit(StandardMaintenanceLoading());
    try {
      await _repository.updateStandardItem(item);
      emit(
        const StandardMaintenanceOperationSuccess('Item updated successfully'),
      );
      loadStandardItems();
    } catch (e) {
      emit(StandardMaintenanceError('Failed to update item: $e'));
      loadStandardItems();
    }
  }

  Future<void> deleteStandardItem(int id) async {
    emit(StandardMaintenanceLoading());
    try {
      await _repository.deleteStandardItem(id);
      emit(
        const StandardMaintenanceOperationSuccess('Item deleted successfully'),
      );
      loadStandardItems();
    } catch (e) {
      emit(StandardMaintenanceError('Failed to delete item: $e'));
      loadStandardItems();
    }
  }
}
