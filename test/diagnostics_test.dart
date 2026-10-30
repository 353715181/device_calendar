import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final plugin = DeviceCalendarPlugin();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() {
    plugin.diagnosticListener = null;
    messenger.setMockMethodCallHandler(DeviceCalendarPlugin.channel, null);
  });

  test('reports the original platform error and operation without arguments',
      () async {
    final events = <List<Object>>[];
    plugin.diagnosticListener =
        (operation, error, stack) => events.add([operation, error, stack]);
    messenger.setMockMethodCallHandler(
        DeviceCalendarPlugin.channel,
        (_) async =>
            throw PlatformException(code: '401', message: 'private account'));
    final result = await plugin.retrieveCalendars();
    expect(result.isSuccess, isFalse);
    expect(events, hasLength(1));
    expect(events.single[0], 'retrieveCalendars');
    expect((events.single[1] as PlatformException).code, '401');
    expect(events.single[2].toString(), isNotEmpty);
  });

  test('an observer failure does not change the original result', () async {
    plugin.diagnosticListener =
        (_, __, ___) => throw StateError('observer failed');
    messenger.setMockMethodCallHandler(DeviceCalendarPlugin.channel,
        (_) async => throw PlatformException(code: '500'));
    final result = await plugin.hasPermissions();
    expect(result.isSuccess, isFalse);
    expect(result.data, isNull);
  });
}
