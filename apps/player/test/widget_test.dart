import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cb_player/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Player app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: PlayerApp()));
  });
}
