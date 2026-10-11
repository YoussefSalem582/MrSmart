import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../storage/storage_keys.dart';

/// Persisted app language. Defaults to the device language when it is
/// Arabic, otherwise English.
class LocaleCubit extends Cubit<Locale> {
  LocaleCubit(this._prefs, {Locale? deviceLocale})
    : super(_read(_prefs, deviceLocale));

  final SharedPreferences _prefs;

  static const supportedLocales = [Locale('en'), Locale('ar')];

  static Locale _read(SharedPreferences prefs, Locale? device) {
    final stored = prefs.getString(StorageKeys.locale) ?? device?.languageCode;
    return stored == 'ar' ? const Locale('ar') : const Locale('en');
  }

  Future<void> setLocale(Locale locale) async {
    emit(locale);
    await _prefs.setString(StorageKeys.locale, locale.languageCode);
  }
}
