import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../services/firebase_notification_service.dart';
import '../services/notification_service.dart';
import '../widgets/islamic_loader.dart';
import '../widgets/glass_background.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final FirebaseNotificationService _service = FirebaseNotificationService();
  List<NotificationMessage> _messages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final msgs = await _service.getSavedNotifications();
    setState(() {
      _messages = msgs;
      _isLoading = false;
    });
    // نعلم الكل كمقروء بمجرد عرضها
    await _service.markAllAsRead();
  }

  Future<void> _clearAll() async {
    await _service.clearNotifications();
    _loadMessages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'الإشعارات',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_messages.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep, color: Colors.red),
              onPressed: _clearAll,
              tooltip: 'مسح الكل',
            ),
          // Debug Button
          IconButton(
            icon: const Icon(
              Icons.notifications_active_outlined,
              color: Colors.blue,
            ),
            onPressed: () async {
              await NotificationService().schedulePrayerNotification(
                999,
                'تجربة الإشعارات',
                'هذا إشعار تجريبي للآذان',
                DateTime.now().add(const Duration(seconds: 5)),
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم جدولة إشعار تجريبي بعد 5 ثوانٍ'),
                  ),
                );
              }
            },
            tooltip: 'تجدربة الإشعار',
          ),
        ],
      ),
      body: GlassBackground(
        child: _isLoading
            ? const IslamicLoader(size: 60)
            : _messages.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_off,
                      size: 80,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'لا توجد إشعارات حالياً',
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).primaryColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.notifications_active,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      title: Text(
                        msg.title,
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 6),
                          Text(
                            msg.body,
                            style: GoogleFonts.cairo(fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            DateFormat.yMMMd('ar').add_jm().format(msg.date),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
