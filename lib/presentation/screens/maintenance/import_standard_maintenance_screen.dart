import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:carvita/core/constants/app_colors.dart';
import 'package:carvita/core/theme/app_theme.dart';
import 'package:carvita/core/widgets/gradient_background.dart';
import 'package:carvita/data/models/maintenance_plan_item.dart';
import 'package:carvita/data/models/standard_maintenance_item.dart';
import 'package:carvita/i18n/generated/app_localizations.dart';
import 'package:carvita/presentation/manager/locale_provider.dart';
import 'package:carvita/presentation/manager/maintenance_plan/maintenance_plan_cubit.dart';
import 'package:carvita/presentation/manager/maintenance_plan/maintenance_plan_state.dart';
import 'package:carvita/presentation/manager/service_log/service_log_cubit.dart';
import 'package:carvita/presentation/manager/standard_maintenance/standard_maintenance_cubit.dart';
import 'package:carvita/presentation/manager/standard_maintenance/standard_maintenance_state.dart';
import 'package:carvita/presentation/manager/upcoming_maintenance/upcoming_maintenance_cubit.dart';

class ImportStandardMaintenanceScreen extends StatefulWidget {
  final int vehicleId;
  final String vehicleName;

  const ImportStandardMaintenanceScreen({
    super.key,
    required this.vehicleId,
    required this.vehicleName,
  });

  @override
  State<ImportStandardMaintenanceScreen> createState() =>
      _ImportStandardMaintenanceScreenState();
}

class _ImportStandardMaintenanceScreenState
    extends State<ImportStandardMaintenanceScreen> {
  final Set<StandardMaintenanceItem> _selectedItems = {};

  @override
  void initState() {
    super.initState();
    context.read<StandardMaintenanceCubit>().loadStandardItems();
  }

  void _onItemChecked(StandardMaintenanceItem item, bool? isChecked) {
    setState(() {
      if (isChecked == true) {
        _selectedItems.add(item);
      } else {
        _selectedItems.remove(item);
      }
    });
  }

  Future<void> _importSelectedItems() async {
    if (_selectedItems.isEmpty) return;

    final cubit = context.read<MaintenancePlanCubit>();

    // Process all selected items
    for (var standardItem in _selectedItems) {
      final planItem = MaintenancePlanItem(
        vehicleId: widget.vehicleId,
        itemName: standardItem.itemName,
        intervalTimeMonths: standardItem.intervalTimeMonths,
        intervalMileage: standardItem.intervalMileage,
        firstIntervalTimeMonths: standardItem.firstIntervalTimeMonths,
        firstIntervalMileage: standardItem.firstIntervalMileage,
        notes: standardItem.notes,
      );
      await cubit.addPlanItem(planItem);
    }

    if (mounted &&
        (cubit.state is MaintenancePlanOperationSuccess ||
            cubit.state is MaintenancePlanLoaded)) {
      context.read<UpcomingMaintenanceCubit>().loadAllUpcomingMaintenance(
        AppLocalizations.of(context),
      );
      context.read<ServiceLogCubit>().fetchServiceLogs();
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.importSuccessCount(
              _selectedItems.length,
            ),
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  String _formatInterval(StandardMaintenanceItem item) {
    final localeProvider = context.watch<LocaleProvider>();
    List<String> parts = [];
    if (item.intervalMileage != null) {
      parts.add(
        AppLocalizations.of(
          context,
        )!.everyNMileage(item.intervalMileage!, localeProvider.mileageUnit),
      );
    }
    if (item.intervalTimeMonths != null) {
      parts.add(
        AppLocalizations.of(context)!.everyNMonth(item.intervalTimeMonths!),
      );
    }
    if (parts.isEmpty) return "";
    return "${AppLocalizations.of(context)!.regularInterval}: ${parts.join(' / ')}";
  }

  @override
  Widget build(BuildContext context) {
    final themeExtensions = Theme.of(context).extension<AppThemeExtensions>()!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GradientBackground(
      gradient: themeExtensions.primaryGradient,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.importStandardTasks),
          backgroundColor: Theme.of(
            context,
          ).colorScheme.inverseSurface.withValues(alpha: 0.1),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            TextButton(
              onPressed:
                  _selectedItems.isNotEmpty ? _importSelectedItems : null,
              child: Text(
                AppLocalizations.of(context)!.import,
                style: TextStyle(
                  color:
                      _selectedItems.isNotEmpty
                          ? (isDark
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.primary)
                          : Theme.of(
                            context,
                          ).disabledColor, // Visually disable
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                AppLocalizations.of(context)!.importStandardTasksDesc(
                  widget.vehicleName,
                ),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<
                StandardMaintenanceCubit,
                StandardMaintenanceState
              >(
                builder: (context, state) {
                  if (state is StandardMaintenanceLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is StandardMaintenanceLoaded) {
                    if (state.items.isEmpty) {
                      return Center(
                        child: Text(
                          AppLocalizations.of(context)!.noStandardItems,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 20,
                        bottom: 20,
                      ),
                      itemCount: state.items.length,
                      itemBuilder: (context, index) {
                        final item = state.items[index];
                        final regularIntervalString = _formatInterval(item);
                        final isSelected = _selectedItems.contains(item);

                        return Card(
                          color:
                              Theme.of(
                                context,
                              ).colorScheme.surfaceContainerLowest,
                          elevation: 1,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color:
                                  isSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.outline,
                              width: isSelected ? 2.0 : 0.2,
                            ),
                          ),
                          child: InkWell(
                            onTap: () {
                              _onItemChecked(item, !isSelected);
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Checkbox(
                                    value: isSelected,
                                    onChanged:
                                        (bool? value) =>
                                            _onItemChecked(item, value),
                                    activeColor:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.itemName,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.onSurface,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        if (regularIntervalString.isNotEmpty)
                                          Text(
                                            regularIntervalString,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withValues(alpha: 0.8),
                                            ),
                                          ),
                                        if (item.notes != null &&
                                            item.notes!.isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            "${AppLocalizations.of(context)!.notes}: ${item.notes}",
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withValues(alpha: 0.7),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  } else if (state is StandardMaintenanceError) {
                    return Center(
                      child: Text(
                        state.message,
                        style: TextStyle(color: AppColors.urgentReminderText),
                      ),
                    );
                  }
                  return Container();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
