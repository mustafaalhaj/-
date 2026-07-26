import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/home_layout_provider.dart';
import '../widgets/glass_background.dart';

class HomeLayoutEditorScreen extends StatefulWidget {
  const HomeLayoutEditorScreen({super.key});

  @override
  State<HomeLayoutEditorScreen> createState() => _HomeLayoutEditorScreenState();
}

class _HomeLayoutEditorScreenState extends State<HomeLayoutEditorScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HomeLayoutProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'تخطيط الشاشة الرئيسية',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.restore),
            tooltip: 'إعادة تعيين',
            onPressed: () {
              provider.resetLayout();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم استعادة التخطيط الافتراضي')),
              );
            },
          ),
        ],
      ),
      body: GlassBackground(
        child: provider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : ReorderableListView(
                padding: const EdgeInsets.only(top: 100, bottom: 20),
                // ignore: deprecated_member_use
                onReorder: (oldIndex, newIndex) {
                  provider.updateOrder(oldIndex, newIndex);
                },
                children: provider.allWidgets.map((item) {
                  return Card(
                    key: ValueKey(item.type),
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    color: Colors.white.withValues(alpha: 0.1),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      leading: Icon(Icons.drag_handle, color: Colors.white70),
                      title: Text(
                        _getWidgetTitle(item.type),
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: Switch(
                        value: item.isVisible,
                        onChanged: (val) {
                          provider.toggleVisibility(item.type);
                        },
                        activeTrackColor: colorScheme.primary,
                        activeThumbColor: Colors.white,
                      ),
                    ),
                  );
                }).toList(),
              ),
      ),
    );
  }

  String _getWidgetTitle(HomeWidgetType type) {
    switch (type) {
      case HomeWidgetType.header:
        return 'التحية والتنبيهات';
      case HomeWidgetType.nextPrayer:
        return 'الصلاة القادمة';
      case HomeWidgetType.quickActions:
        return 'الوصول السريع';
      case HomeWidgetType.dailyVerse:
        return 'آية اليوم';
      case HomeWidgetType.hijriDate:
        return 'التاريخ الهجري';
    }
  }
}
