import 'package:flutter/material.dart';

import 'package:carvita/core/constants/app_colors.dart';
import 'package:carvita/core/theme/app_theme.dart';
import 'package:carvita/data/models/maintenance_supply.dart';
import 'package:carvita/i18n/generated/app_localizations.dart';

class MaintenanceSupplyListEditor extends StatefulWidget {
  final List<MaintenanceSupply> initialSupplies;
  final ValueChanged<List<MaintenanceSupply>> onSuppliesChanged;

  const MaintenanceSupplyListEditor({
    super.key,
    required this.initialSupplies,
    required this.onSuppliesChanged,
  });

  @override
  State<MaintenanceSupplyListEditor> createState() =>
      _MaintenanceSupplyListEditorState();
}

class _MaintenanceSupplyListEditorState
    extends State<MaintenanceSupplyListEditor> {
  late List<MaintenanceSupply> _supplies;

  // Controllers for the "Add" form
  final _makerController = TextEditingController();
  final _codeController = TextEditingController();
  final _quantityController = TextEditingController();
  String _selectedType = 'Part';

  bool _isAdding = false;

  @override
  void initState() {
    super.initState();
    _supplies = List.from(widget.initialSupplies);
  }

  @override
  void didUpdateWidget(covariant MaintenanceSupplyListEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialSupplies != widget.initialSupplies) {
        // If the parent updates the list (e.g. after loading), sync it unless we are editing.
        // Simple approach: trust parent if our list is empty or matches old parent list.
        if (_supplies.isEmpty && widget.initialSupplies.isNotEmpty) {
             _supplies = List.from(widget.initialSupplies);
        }
    }
  }

  @override
  void dispose() {
    _makerController.dispose();
    _codeController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _addSupply() {
    setState(() {
      _isAdding = true;
      // Reset form
      _makerController.clear();
      _codeController.clear();
      _quantityController.clear();
      _selectedType = 'Part';
    });
  }

  void _cancelAdd() {
    setState(() {
      _isAdding = false;
    });
  }

  void _confirmAdd() {
    final maker = _makerController.text.trim();
    final code = _codeController.text.trim();
    final quantity = _quantityController.text.trim();

    if (maker.isEmpty || code.isEmpty) {
        // Basic validation
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.invalidEmptyEntry("Maker / Code"))),
        );
        return;
    }

    final newSupply = MaintenanceSupply(
        maintenancePlanItemId: 0, // Placeholder, updated by parent on save
        type: _selectedType,
        maker: maker,
        code: code,
        quantity: quantity.isNotEmpty ? quantity : null,
    );

    setState(() {
      _supplies.add(newSupply);
      _isAdding = false;
    });
    widget.onSuppliesChanged(_supplies);
  }

  void _removeSupply(int index) {
    setState(() {
      _supplies.removeAt(index);
    });
    widget.onSuppliesChanged(_supplies);
  }

  @override
  Widget build(BuildContext context) {
    final themeExtensions = Theme.of(context).extension<AppThemeExtensions>()!;
    final loc = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              loc.supplies,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: themeExtensions.textColorOnBackground,
              ),
            ),
            if (!_isAdding)
              TextButton.icon(
                onPressed: _addSupply,
                icon: Icon(Icons.add_circle_outline, size: 20),
                label: Text(loc.addSupply),
                style: TextButton.styleFrom(
                   foregroundColor: isDark ? AppColors.accentBlue : Theme.of(context).colorScheme.primary,
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),

        // List
        if (_supplies.isNotEmpty)
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _supplies.length,
            separatorBuilder: (c, i) => Divider(height: 1),
            itemBuilder: (context, index) {
              final item = _supplies[index];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                    item.type == 'Fluid' ? Icons.water_drop : Icons.build,
                    color: item.type == 'Fluid' ? Colors.blue : Colors.grey,
                ),
                title: Text("${item.maker} ${item.code}"),
                subtitle: item.quantity != null ? Text("${loc.supplyQuantity}: ${item.quantity}") : null,
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: () => _removeSupply(index),
                ),
              );
            },
          ),

        if (_supplies.isEmpty && !_isAdding)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              "No supplies added yet.",
              style: TextStyle(color: themeExtensions.textColorOnBackground.withValues(alpha: 0.6), fontStyle: FontStyle.italic),
            ),
          ),

        // Add Form
        if (_isAdding)
          Container(
            margin: const EdgeInsets.only(top: 10),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: themeExtensions.textColorOnBackground.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Type Selector
                Row(
                  children: [
                    Text(loc.supplyType, style: TextStyle(color: themeExtensions.textColorOnBackground)),
                    const SizedBox(width: 15),
                    ChoiceChip(
                      label: Text(loc.supplyTypePart),
                      selected: _selectedType == 'Part',
                      onSelected: (b) => setState(() => _selectedType = 'Part'),
                    ),
                    const SizedBox(width: 10),
                    ChoiceChip(
                      label: Text(loc.supplyTypeFluid),
                      selected: _selectedType == 'Fluid',
                      onSelected: (b) => setState(() => _selectedType = 'Fluid'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Maker & Code
                Row(
                    children: [
                        Expanded(child: TextField(
                            controller: _makerController,
                            style: TextStyle(color: themeExtensions.textColorOnBackground),
                            decoration: InputDecoration(
                                labelText: "${loc.supplyMaker}*",
                                hintText: loc.supplyMakerHint,
                                isDense: true,
                            ),
                        )),
                        const SizedBox(width: 10),
                        Expanded(child: TextField(
                            controller: _codeController,
                            style: TextStyle(color: themeExtensions.textColorOnBackground),
                            decoration: InputDecoration(
                                labelText: "${loc.supplyCode}*",
                                hintText: loc.supplyCodeHint,
                                isDense: true,
                            ),
                        )),
                    ],
                ),
                const SizedBox(height: 10),
                // Quantity
                 TextField(
                    controller: _quantityController,
                    style: TextStyle(color: themeExtensions.textColorOnBackground),
                    decoration: InputDecoration(
                        labelText: loc.supplyQuantity,
                        hintText: loc.supplyQuantityHint,
                        isDense: true,
                    ),
                ),
                const SizedBox(height: 15),
                Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                        TextButton(onPressed: _cancelAdd, child: Text(loc.cancel)),
                        const SizedBox(width: 10),
                        ElevatedButton(onPressed: _confirmAdd, child: Text(loc.addEditButtonText('add'))),
                    ],
                )
              ],
            ),
          ),
      ],
    );
  }
}
