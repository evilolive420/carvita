import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:carvita/core/constants/app_colors.dart';
import 'package:carvita/core/theme/app_theme.dart';
import 'package:carvita/core/widgets/gradient_background.dart';
import 'package:carvita/data/models/standard_maintenance_item.dart';
import 'package:carvita/i18n/generated/app_localizations.dart';
import 'package:carvita/presentation/manager/locale_provider.dart';
import 'package:carvita/presentation/manager/standard_maintenance/standard_maintenance_cubit.dart';

class AddEditStandardMaintenanceItemScreen extends StatefulWidget {
  final StandardMaintenanceItem? itemToEdit;

  const AddEditStandardMaintenanceItemScreen({super.key, this.itemToEdit});

  @override
  State<AddEditStandardMaintenanceItemScreen> createState() =>
      _AddEditStandardMaintenanceItemScreenState();
}

class _AddEditStandardMaintenanceItemScreenState
    extends State<AddEditStandardMaintenanceItemScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _itemNameController;
  late TextEditingController _intervalTimeMonthsController;
  late TextEditingController _intervalMileageController;
  late TextEditingController _firstIntervalTimeMonthsController;
  late TextEditingController _firstIntervalMileageController;
  late TextEditingController _notesController;

  bool get _isEditing => widget.itemToEdit != null;

  @override
  void initState() {
    super.initState();
    final item = widget.itemToEdit;
    _itemNameController = TextEditingController(text: item?.itemName ?? '');
    _intervalTimeMonthsController = TextEditingController(
      text: item?.intervalTimeMonths?.toString() ?? '',
    );
    _intervalMileageController = TextEditingController(
      text: item?.intervalMileage?.toString() ?? '',
    );
    _firstIntervalTimeMonthsController = TextEditingController(
      text: item?.firstIntervalTimeMonths?.toString() ?? '',
    );
    _firstIntervalMileageController = TextEditingController(
      text: item?.firstIntervalMileage?.toString() ?? '',
    );
    _notesController = TextEditingController(text: item?.notes ?? '');
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    _intervalTimeMonthsController.dispose();
    _intervalMileageController.dispose();
    _firstIntervalTimeMonthsController.dispose();
    _firstIntervalMileageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final itemName = _itemNameController.text.trim();

      final String regularTimeText = _intervalTimeMonthsController.text.trim();
      final String regularMileageText = _intervalMileageController.text.trim();
      final int? intervalTimeMonths = int.tryParse(regularTimeText);
      final int? intervalMileage = int.tryParse(regularMileageText);

      final String firstTimeText =
          _firstIntervalTimeMonthsController.text.trim();
      final String firstMileageText =
          _firstIntervalMileageController.text.trim();
      final int? firstIntervalTimeMonths = int.tryParse(firstTimeText);
      final int? firstIntervalMileage = int.tryParse(firstMileageText);

      final String notes = _notesController.text.trim();

      bool isValidRegularIntervalSet =
          (intervalTimeMonths != null && intervalTimeMonths > 0) ||
          (intervalMileage != null && intervalMileage > 0);

      if (!isValidRegularIntervalSet) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.invalidRegularInterval,
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
            ),
            backgroundColor: AppColors.urgentReminderText,
            duration: const Duration(seconds: 3),
          ),
        );
        return;
      }

      final item = StandardMaintenanceItem(
        id: widget.itemToEdit?.id,
        itemName: itemName,
        intervalTimeMonths: intervalTimeMonths,
        intervalMileage: intervalMileage,
        firstIntervalTimeMonths: firstIntervalTimeMonths,
        firstIntervalMileage: firstIntervalMileage,
        notes: notes.isNotEmpty ? notes : null,
      );

      final cubit = context.read<StandardMaintenanceCubit>();
      if (_isEditing) {
        cubit.updateStandardItem(item);
      } else {
        cubit.addStandardItem(item);
      }

      Navigator.of(context).pop();
    }
  }

  Widget _buildIntervalGroup({
    required String title,
    required TextEditingController timeController,
    required TextEditingController mileageController,
    required String timeHint,
    required String mileageHint,
  }) {
    final themeExtensions = Theme.of(context).extension<AppThemeExtensions>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: themeExtensions.textColorOnBackground.withValues(alpha: 0.9),
          ),
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: timeController,
                style: TextStyle(color: themeExtensions.textColorOnBackground),
                decoration: InputDecoration(
                  hintText: timeHint,
                  labelText: timeHint,
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: TextFormField(
                controller: mileageController,
                style: TextStyle(color: themeExtensions.textColorOnBackground),
                decoration: InputDecoration(
                  hintText: mileageHint,
                  labelText: mileageHint,
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          AppLocalizations.of(context)!.hintComesFirst,
          style: TextStyle(
            fontSize: 12,
            color: themeExtensions.textColorOnBackground.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    final themeExtensions = Theme.of(context).extension<AppThemeExtensions>()!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        isDark
            ? Theme.of(context).colorScheme.onPrimaryContainer
            : Theme.of(context).colorScheme.onPrimary;

    return GradientBackground(
      gradient: themeExtensions.primaryGradient,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            _isEditing
                ? AppLocalizations.of(context)!.editStandardItem
                : AppLocalizations.of(context)!.addStandardItem,
          ),
          backgroundColor: Theme.of(
            context,
          ).colorScheme.inverseSurface.withValues(alpha: 0.1),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextFormField(
                  controller: _itemNameController,
                  style: TextStyle(
                    color: themeExtensions.textColorOnBackground,
                  ),
                  decoration: InputDecoration(
                    labelText: '${AppLocalizations.of(context)!.itemName}*',
                    hintText: AppLocalizations.of(context)!.itemNameHint,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return AppLocalizations.of(context)!.invalidEmptyEntry(
                        AppLocalizations.of(context)!.itemName,
                      );
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _buildIntervalGroup(
                  title: AppLocalizations.of(context)!.regularInterval,
                  timeController: _intervalTimeMonthsController,
                  mileageController: _intervalMileageController,
                  timeHint: AppLocalizations.of(context)!.timeHint,
                  mileageHint: AppLocalizations.of(
                    context,
                  )!.mileageHint(localeProvider.mileageUnit),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _notesController,
                  style: TextStyle(
                    color: themeExtensions.textColorOnBackground,
                  ),
                  decoration: InputDecoration(
                    labelText:
                        "${AppLocalizations.of(context)!.notes} (${AppLocalizations.of(context)!.optionalEntry})",
                    hintText:
                        AppLocalizations.of(context)!.noteMaintenanceItemHint,
                  ),
                  maxLines: 3,
                  minLines: 1,
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: bgColor,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(
                      context,
                    )!.addEditButtonText(_isEditing ? 'edit' : 'add'),
                    style: TextStyle(
                      color:
                          isDark
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
