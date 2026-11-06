import 'package:home_widget/home_widget.dart';
import 'package:moreki/features/widget/domain/widget_snapshot.dart';

/// Something that can show a [WidgetSnapshot] on the home screen.
/// Tests use a fake one; the real one talks to Android.
abstract class WidgetUpdater {
  Future<void> update(WidgetSnapshot snapshot);
}

/// Sends the snapshot to the Android home-screen widget.
class HomeWidgetUpdater implements WidgetUpdater {
  /// Must match the Kotlin class MorekiWidgetProvider in the Android folder.
  static const String androidProvider =
      'com.cubiccode.moreki.MorekiWidgetProvider';

  @override
  Future<void> update(WidgetSnapshot snapshot) async {
    for (final item in snapshot.toMap().entries) {
      await HomeWidget.saveWidgetData<String>(item.key, item.value);
    }
    await HomeWidget.updateWidget(qualifiedAndroidName: androidProvider);
  }
}