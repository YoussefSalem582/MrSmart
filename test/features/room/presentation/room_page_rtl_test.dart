import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mr_smart/core/theme/app_theme.dart';
import 'package:mr_smart/features/room/domain/entities/connection_status.dart';
import 'package:mr_smart/features/room/domain/entities/entity_snapshot.dart';
import 'package:mr_smart/features/room/domain/services/room_controller.dart';
import 'package:mr_smart/features/room/domain/usecases/leave_room.dart';
import 'package:mr_smart/features/room/presentation/cubit/room_cubit.dart';
import 'package:mr_smart/features/room/presentation/pages/room_page.dart';
import 'package:mr_smart/l10n/generated/app_localizations.dart';

import '../../../helpers/fake_room_backend.dart';

void main() {
  Future<FakeRoomBackend> pumpRoom(WidgetTester tester, Locale locale) async {
    final backend = FakeRoomBackend([
      snap('light.lamp', const OnOffValue(true)),
      snap('sensor.temp', const NumericValue(21, '°C')),
    ]);
    final room = RoomController(
      states: backend,
      commands: backend,
      entityIds: const ['light.lamp', 'sensor.temp'],
    );
    await tester.pumpWidget(
      MaterialApp(
        locale: locale,
        theme: AppTheme.light(locale),
        supportedLocales: const [Locale('en'), Locale('ar')],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: BlocProvider(
          create: (_) => RoomCubit(room, LeaveRoom(room))..start(),
          child: const RoomPage(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
    addTearDown(room.dispose);
    return backend;
  }

  testWidgets('Arabic renders right-to-left with translated labels', (
    tester,
  ) async {
    await pumpRoom(tester, const Locale('ar'));
    final context = tester.element(find.byType(RoomPage));
    expect(Directionality.of(context), TextDirection.rtl);
    expect(find.text('غرفتي'), findsOneWidget);
    expect(find.text('متصل'), findsOneWidget);
    expect(find.text('مغادرة الغرفة'), findsOneWidget);
  });

  testWidgets('connection loss shows the offline banner and disables '
      'switches', (tester) async {
    final backend = await pumpRoom(tester, const Locale('en'));
    backend.emitStatus(const ConnectionStatus.disconnected());
    await tester.pump();
    expect(find.text('Offline — controls are disabled'), findsOneWidget);
    final toggle = tester.widget<Switch>(find.byType(Switch));
    expect(toggle.onChanged, isNull);
    expect(find.textContaining('Last known value'), findsWidgets);
  });
}
