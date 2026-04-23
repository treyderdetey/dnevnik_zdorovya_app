import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class FeedbackUtils {
  static const String _supportEmail = 'timonin.rabota@gmail.com';

  static Future<void> sendFeedback() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    
    String deviceModel = '';
    String osVersion = '';
    
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      deviceModel = androidInfo.model;
      osVersion = 'Android ${androidInfo.version.release}';
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      deviceModel = iosInfo.utsname.machine;
      osVersion = 'iOS ${iosInfo.systemVersion}';
    }

    final String subject = Uri.encodeComponent('Баг-репорт: ${packageInfo.appName}');
    final String body = Uri.encodeComponent(
      '\n\n--- Техническая информация ---\n'
      'Приложение: ${packageInfo.appName} (${packageInfo.version})\n'
      'Устройство: $deviceModel\n'
      'ОС: $osVersion\n'
      '------------------------------\n'
    );

    final Uri emailUri = Uri.parse('mailto:$_supportEmail?subject=$subject&body=$body');

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }
}
