import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

/// خدمة إدارة الصلاحيات
class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  /// طلب صلاحية الموقع
  Future<bool> requestLocationPermission() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  /// طلب صلاحية الموقع الدقيق
  Future<bool> requestPreciseLocationPermission() async {
    final status = await Permission.locationWhenInUse.request();
    return status.isGranted;
  }

  /// طلب صلاحية الموقع في الخلفية
  Future<bool> requestBackgroundLocationPermission() async {
    final status = await Permission.locationAlways.request();
    return status.isGranted;
  }

  /// طلب صلاحية الإشعارات
  Future<bool> requestNotificationPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  /// فحص صلاحية الموقع
  Future<bool> checkLocationPermission() async {
    final status = await Permission.location.status;
    return status.isGranted;
  }

  /// فحص صلاحية الإشعارات
  Future<bool> checkNotificationPermission() async {
    final status = await Permission.notification.status;
    return status.isGranted;
  }

  /// طلب جميع الصلاحيات المطلوبة
  Future<Map<String, bool>> requestAllPermissions() async {
    final Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.locationWhenInUse,
      Permission.notification,
    ].request();

    return {
      'location': statuses[Permission.location]?.isGranted ?? false,
      'locationWhenInUse':
          statuses[Permission.locationWhenInUse]?.isGranted ?? false,
      'notification': statuses[Permission.notification]?.isGranted ?? false,
    };
  }

  /// عرض dialog لشرح سبب طلب الصلاحية
  Future<void> showPermissionRationale(
    BuildContext context,
    String title,
    String message,
    VoidCallback onAccept,
  ) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onAccept();
            },
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }

  /// فتح إعدادات التطبيق
  Future<bool> openAppSettings() async {
    return await openAppSettings();
  }

  /// طلب صلاحية الموقع مع شرح
  Future<bool> requestLocationWithRationale(BuildContext context) async {
    // فحص الصلاحية أولاً
    final status = await Permission.location.status;

    if (status.isGranted) {
      return true;
    }

    // إذا تم الرفض نهائياً، نأخذ المستخدم للإعدادات
    if (status.isPermanentlyDenied) {
      if (context.mounted) {
        await showPermissionRationale(
          context,
          'صلاحية الموقع مطلوبة',
          'نحتاج صلاحية الموقع لتحديد أوقات الصلاة بدقة. يرجى تفعيل الصلاحية من الإعدادات.',
          () => openAppSettings(),
        );
      }
      return false;
    }

    // طلب الصلاحية
    if (context.mounted && status.isDenied) {
      await showPermissionRationale(
        context,
        'صلاحية الموقع',
        'نحتاج صلاحية الموقع الجغرافي لحساب أوقات الصلاة بدقة حسب موقعك الحالي.',
        () async {
          await Permission.location.request();
        },
      );
    }

    final newStatus = await Permission.location.request();
    return newStatus.isGranted;
  }

  /// طلب صلاحية الإشعارات مع شرح
  Future<bool> requestNotificationWithRationale(BuildContext context) async {
    final status = await Permission.notification.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isPermanentlyDenied) {
      if (context.mounted) {
        await showPermissionRationale(
          context,
          'صلاحية الإشعارات مطلوبة',
          'نحتاج صلاحية الإشعارات لتنبيهك بمواعيد الصلاة. يرجى تفعيلها من الإعدادات.',
          () => openAppSettings(),
        );
      }
      return false;
    }

    if (context.mounted && status.isDenied) {
      await showPermissionRationale(
        context,
        'صلاحية الإشعارات',
        'نحتاج صلاحية الإشعارات لإرسال تنبيهات مواعيد الصلاة.',
        () async {
          await Permission.notification.request();
        },
      );
    }

    final newStatus = await Permission.notification.request();
    return newStatus.isGranted;
  }
}
