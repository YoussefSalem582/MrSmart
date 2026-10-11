import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mr_smart/features/home_assistant/data/ha_connection_tester_impl.dart';
import 'package:mr_smart/features/home_assistant/domain/usecases/connect_home_assistant.dart';
import 'package:mr_smart/features/home_assistant/presentation/connect_cubit.dart';
import 'package:mr_smart/features/home_assistant/presentation/connect_page.dart';
import 'package:mr_smart/l10n/generated/app_localizations.dart';

import '../../helpers/fake_home_assistant.dart';
import 'connect_home_assistant_test.dart' show MemoryCredentials;

void main() {
  testWidgets('a rejected token shows the auth error and a HTTP warning', (
    tester,
  ) async {
    final ha = FakeHomeAssistant();
    final store = MemoryCredentials();
    final cubit = ConnectCubit(
      ConnectHomeAssistant(
        HaConnectionTesterImpl((c) => ha.rest(withToken: c.token)),
        store,
        allowInsecureHttp: true,
      ),
      store,
    );
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('ar')],
        home: BlocProvider.value(value: cubit, child: const ConnectPage()),
      ),
    );

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'http://ha.test:8123');
    await tester.pump();
    expect(find.textContaining('HTTP is unencrypted'), findsOneWidget);

    await tester.enterText(fields.at(1), 'wrong-token');
    await tester.tap(find.text('Test and save'));
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.textContaining('Access token rejected'), findsOneWidget);
    expect(store.stored, isNull);
  });
}
