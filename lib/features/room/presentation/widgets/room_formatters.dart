import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/entity_snapshot.dart';

extension RoomFormatters on AppLocalizations {
  String valueText(EntityValue value, Locale locale) => switch (value) {
    OnOffValue(:final isOn) => isOn ? valueOn : valueOff,
    // LTR isolate keeps "22.5 °C" in order inside right-to-left text.
    NumericValue(:final value, :final unit) =>
      '\u2066${NumberFormat('0.0', locale.toLanguageTag()).format(value)}'
          '${unit == null ? '' : ' $unit'}\u2069',
    UnknownValue() => valueUnknown,
    UnavailableValue() => valueUnavailable,
  };

  String kindText(DeviceKind kind) => switch (kind) {
    DeviceKind.light => kindLight,
    DeviceKind.switchDevice => kindSwitch,
    DeviceKind.inputBoolean => kindInputBoolean,
    DeviceKind.temperature => kindTemperature,
  };
}

IconData kindIcon(DeviceKind kind, {bool on = false}) => switch (kind) {
  DeviceKind.light => on ? Icons.lightbulb : Icons.lightbulb_outline,
  DeviceKind.switchDevice => on ? Icons.power : Icons.power_outlined,
  DeviceKind.inputBoolean => on ? Icons.toggle_on : Icons.toggle_off_outlined,
  DeviceKind.temperature => Icons.thermostat,
};

String formatTime(DateTime time, Locale locale) =>
    DateFormat.Hms(locale.toLanguageTag()).format(time);
