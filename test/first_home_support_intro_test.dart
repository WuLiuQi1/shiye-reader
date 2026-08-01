import 'package:flutter_test/flutter_test.dart';
import 'package:xxread/pages/settings/settings_page.dart';

void main() {
  test('settings controller supports its lifecycle', () {
    final controller = SettingsPageController();

    expect(controller.hasListeners, isFalse);

    controller.dispose();
  });
}
