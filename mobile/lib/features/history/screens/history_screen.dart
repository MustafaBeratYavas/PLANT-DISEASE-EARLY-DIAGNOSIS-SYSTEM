import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/utils/disease_label_mapper.dart';
import '../../../../core/widgets/circular_icon_button.dart';
import '../../library/screens/disease_detail_screen.dart';
import '../controllers/history_controller.dart';
import '../widgets/history_item_tile.dart';
import '../widgets/history_filter_sheet.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final HistoryController _controller = getIt<HistoryController>();

  @override
  void initState() {
    super.initState();
    // Load initial data
    _controller.loadHistory();
  }

  void _navigateToDetail(BuildContext context, String rawDiseaseId) {
    // Skip healthy plants
    if (rawDiseaseId.toLowerCase().contains('healthy')) return;

    final jsonKey = DiseaseLabelMapper.getJsonKey(rawDiseaseId);
    
    if (jsonKey == null) return;

    final localizedName = DiseaseLabelMapper.getLocalizedLabel(context, jsonKey);
    
    // Open disease details
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DiseaseDetailScreen(
          diseaseName: localizedName,
          diseaseId: jsonKey,
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    // Display filter sheet
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => HistoryFilterSheet(controller: _controller),
    );
  }

  void _showClearAllDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    // Confirm history clearance
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.dialogClearTitle),
        content: Text(l10n.dialogClearMessage),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.actionCancel, 
              style: const TextStyle(color: Colors.grey)
            ),
          ),
          TextButton(
            onPressed: () {
              _controller.clearHistory();
              Navigator.pop(context);
            },
            child: Text(
              l10n.actionDelete, 
              style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      // Action bar controls
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: size.height * 0.22,
        actions: [
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 32.0, bottom: 12.0),
                // Dynamic action buttons
                child: ListenableBuilder(
                  listenable: _controller,
                  builder: (context, _) {
                    return Row(
                      children: [
                        CircularIconButton(
                          icon: Icons.filter_list_rounded,
                          tooltip: l10n.filterTitle,
                          onPressed: () => _showFilterSheet(context),
                        ),
                        if (_controller.history.isNotEmpty)
                          CircularIconButton(
                            icon: Icons.delete_sweep_outlined, 
                            tooltip: l10n.dialogClearTitle,
                            onPressed: () => _showClearAllDialog(context),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      // Layered UI layout
      body: Stack(
        children: [
          // Background image
          Image.asset(
            AppAssets.bgHistory,
            width: size.width,
            height: size.height,
            fit: BoxFit.cover,
          ),
          SafeArea(
            // Reactive history list
            child: ListenableBuilder(
              listenable: _controller,
              builder: (context, _) {
                // Handle empty state
                if (_controller.history.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history_toggle_off_rounded, 
                          size: 80, 
                          color: theme.colorScheme.onSurface.withOpacity(0.3)
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.historyEmpty,
                          style: TextStyle(
                            fontSize: 16,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Render history list
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
                  itemCount: _controller.history.length,
                  itemBuilder: (context, index) {
                    final item = _controller.history[index];
                    
                    // Swipe deletion logic
                    return Dismissible(
                      key: Key(item.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
                      ),
                      onDismissed: (direction) {
                        _controller.deleteScan(item.id);
                      },
                      child: HistoryItemTile(
                        item: item,
                        onTap: () => _navigateToDetail(context, item.diseaseId),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}