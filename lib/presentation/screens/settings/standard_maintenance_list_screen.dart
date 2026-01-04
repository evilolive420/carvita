import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:carvita/core/constants/app_colors.dart';
import 'package:carvita/core/constants/app_routes.dart';
import 'package:carvita/core/theme/app_theme.dart';
import 'package:carvita/core/widgets/gradient_background.dart';
import 'package:carvita/data/models/standard_maintenance_item.dart';
import 'package:carvita/i18n/generated/app_localizations.dart';
import 'package:carvita/presentation/manager/locale_provider.dart';
import 'package:carvita/presentation/manager/standard_maintenance/standard_maintenance_cubit.dart';
import 'package:carvita/presentation/manager/standard_maintenance/standard_maintenance_state.dart';

class StandardMaintenanceListScreen extends StatefulWidget {
  const StandardMaintenanceListScreen({super.key});

  @override
  State<StandardMaintenanceListScreen> createState() =>
      _StandardMaintenanceListScreenState();
}

class _StandardMaintenanceListScreenState
    extends State<StandardMaintenanceListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<StandardMaintenanceCubit>().loadStandardItems();
  }

  Future<void> _confirmDeleteItem(
    BuildContext context,
    StandardMaintenanceItem item,
  ) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
          title: Text(
            AppLocalizations.of(context)!.confirmDelete,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 24,
            ),
          ),
          content: Text(
            AppLocalizations.of(context)!.deleteConfirmStandardItem(
              item.itemName,
            ),
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                AppLocalizations.of(context)!.cancel,
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
              onPressed: () => Navigator.of(dialogContext).pop(false),
            ),
            TextButton(
              child: Text(
                AppLocalizations.of(context)!.delete,
                style: TextStyle(color: AppColors.urgentReminderText),
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmed == true && item.id != null && context.mounted) {
      context.read<StandardMaintenanceCubit>().deleteStandardItem(item.id!);
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

    return GradientBackground(
      gradient: themeExtensions.primaryGradient,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.manageStandardMaintenance),
          backgroundColor: Theme.of(
            context,
          ).colorScheme.inverseSurface.withValues(alpha: 0.1),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.addEditStandardItemRoute,
                );
              },
            ),
          ],
        ),
        body: BlocConsumer<StandardMaintenanceCubit, StandardMaintenanceState>(
          listener: (context, state) {
            if (state is StandardMaintenanceOperationSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (state is StandardMaintenanceError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.urgentReminderText,
                ),
              );
            }
          },
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
                padding: const EdgeInsets.all(20),
                itemCount: state.items.length,
                itemBuilder: (context, index) {
                  final item = state.items[index];
                  final regularIntervalString = _formatInterval(item);

                  return Card(
                    color: Theme.of(context).colorScheme.surfaceContainerLowest,
                    elevation: 1,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.outline,
                        width: 0.2,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                          PopupMenuButton<String>(
                            icon: Icon(
                              Icons.more_vert,
                              color: Theme.of(context).colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                            ),
                            onSelected: (String value) {
                              if (value == 'edit') {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.addEditStandardItemRoute,
                                  arguments: item,
                                );
                              } else if (value == 'delete') {
                                _confirmDeleteItem(context, item);
                              }
                            },
                            itemBuilder:
                                (BuildContext context) =>
                                    <PopupMenuEntry<String>>[
                                      PopupMenuItem<String>(
                                        value: 'edit',
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.edit_outlined,
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).colorScheme.primary,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              AppLocalizations.of(
                                                context,
                                              )!.edit,
                                              style: TextStyle(
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).colorScheme.onSurface,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      PopupMenuItem<String>(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.delete_outline,
                                              color:
                                                  AppColors.urgentReminderText,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              AppLocalizations.of(
                                                context,
                                              )!.delete,
                                              style: TextStyle(
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).colorScheme.onSurface,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
            return Container();
          },
        ),
      ),
    );
  }
}
