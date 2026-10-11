import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'MrSmart'**
  String get appTitle;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Control one room. Learn how smart homes work.'**
  String get welcomeTitle;

  /// No description provided for @welcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Start with a simulated room — no hardware, account or server needed. Connect your own Home Assistant when you\'re ready.'**
  String get welcomeBody;

  /// No description provided for @tryDemo.
  ///
  /// In en, this message translates to:
  /// **'Try demo'**
  String get tryDemo;

  /// No description provided for @connectHomeAssistant.
  ///
  /// In en, this message translates to:
  /// **'Connect to Home Assistant'**
  String get connectHomeAssistant;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @roomTitle.
  ///
  /// In en, this message translates to:
  /// **'My room'**
  String get roomTitle;

  /// No description provided for @modeDemo.
  ///
  /// In en, this message translates to:
  /// **'Demo'**
  String get modeDemo;

  /// No description provided for @modeHomeAssistant.
  ///
  /// In en, this message translates to:
  /// **'Home Assistant'**
  String get modeHomeAssistant;

  /// No description provided for @modeNone.
  ///
  /// In en, this message translates to:
  /// **'Not set up'**
  String get modeNone;

  /// No description provided for @simulatedBadge.
  ///
  /// In en, this message translates to:
  /// **'Simulated'**
  String get simulatedBadge;

  /// No description provided for @simulatedNotice.
  ///
  /// In en, this message translates to:
  /// **'Simulated data — not real device telemetry.'**
  String get simulatedNotice;

  /// No description provided for @connectionConnecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting…'**
  String get connectionConnecting;

  /// No description provided for @connectionConnected.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get connectionConnected;

  /// No description provided for @connectionReconnecting.
  ///
  /// In en, this message translates to:
  /// **'Offline — retrying in {seconds}s (attempt {attempt})'**
  String connectionReconnecting(int seconds, int attempt);

  /// No description provided for @connectionDisconnected.
  ///
  /// In en, this message translates to:
  /// **'Offline — controls are disabled'**
  String get connectionDisconnected;

  /// No description provided for @connectionAuthFailed.
  ///
  /// In en, this message translates to:
  /// **'Access token rejected. Reconfigure the connection in Settings.'**
  String get connectionAuthFailed;

  /// No description provided for @valueOn.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get valueOn;

  /// No description provided for @valueOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get valueOff;

  /// No description provided for @valueUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get valueUnknown;

  /// No description provided for @valueUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get valueUnavailable;

  /// No description provided for @deviceRemoved.
  ///
  /// In en, this message translates to:
  /// **'Removed from the source'**
  String get deviceRemoved;

  /// No description provided for @deviceLoading.
  ///
  /// In en, this message translates to:
  /// **'Waiting for first state…'**
  String get deviceLoading;

  /// No description provided for @lastConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Last confirmed {time}'**
  String lastConfirmed(String time);

  /// No description provided for @staleNote.
  ///
  /// In en, this message translates to:
  /// **'Last known value · confirmed {time}'**
  String staleNote(String time);

  /// No description provided for @commandPendingOn.
  ///
  /// In en, this message translates to:
  /// **'Turning on… waiting for confirmation'**
  String get commandPendingOn;

  /// No description provided for @commandPendingOff.
  ///
  /// In en, this message translates to:
  /// **'Turning off… waiting for confirmation'**
  String get commandPendingOff;

  /// No description provided for @commandFailedOn.
  ///
  /// In en, this message translates to:
  /// **'Turn on failed: {reason}'**
  String commandFailedOn(String reason);

  /// No description provided for @commandFailedOff.
  ///
  /// In en, this message translates to:
  /// **'Turn off failed: {reason}'**
  String commandFailedOff(String reason);

  /// No description provided for @commandUnconfirmedTimeout.
  ///
  /// In en, this message translates to:
  /// **'Not confirmed: the device didn\'t report the new state in time.'**
  String get commandUnconfirmedTimeout;

  /// No description provided for @commandUnconfirmedConnection.
  ///
  /// In en, this message translates to:
  /// **'Not confirmed: the connection dropped before the device reported back.'**
  String get commandUnconfirmedConnection;

  /// No description provided for @controlHintOffline.
  ///
  /// In en, this message translates to:
  /// **'Controls are disabled while offline.'**
  String get controlHintOffline;

  /// No description provided for @kindLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get kindLight;

  /// No description provided for @kindSwitch.
  ///
  /// In en, this message translates to:
  /// **'Switch'**
  String get kindSwitch;

  /// No description provided for @kindInputBoolean.
  ///
  /// In en, this message translates to:
  /// **'Helper toggle'**
  String get kindInputBoolean;

  /// No description provided for @kindTemperature.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get kindTemperature;

  /// No description provided for @leaveRoom.
  ///
  /// In en, this message translates to:
  /// **'Leave room'**
  String get leaveRoom;

  /// No description provided for @leaveRoomExplain.
  ///
  /// In en, this message translates to:
  /// **'Turns off only this room\'s selected devices. The app has to be open to run it. Anything that must happen on its own — on a schedule or when a sensor triggers — belongs in a Home Assistant automation.'**
  String get leaveRoomExplain;

  /// No description provided for @leaveRoomConfirm.
  ///
  /// In en, this message translates to:
  /// **'Turn off room devices'**
  String get leaveRoomConfirm;

  /// No description provided for @leaveRoomRunning.
  ///
  /// In en, this message translates to:
  /// **'Turning off and waiting for confirmation…'**
  String get leaveRoomRunning;

  /// No description provided for @leaveRoomAllOff.
  ///
  /// In en, this message translates to:
  /// **'All selected devices are confirmed off.'**
  String get leaveRoomAllOff;

  /// No description provided for @leaveRoomPartial.
  ///
  /// In en, this message translates to:
  /// **'Not everything turned off. Check each device below.'**
  String get leaveRoomPartial;

  /// No description provided for @leaveRoomNotConnected.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline, so nothing was sent.'**
  String get leaveRoomNotConnected;

  /// No description provided for @leaveRoomNothing.
  ///
  /// In en, this message translates to:
  /// **'This room has no controllable devices.'**
  String get leaveRoomNothing;

  /// No description provided for @leaveOutcomeConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Off (confirmed)'**
  String get leaveOutcomeConfirmed;

  /// No description provided for @leaveOutcomeAlreadyOff.
  ///
  /// In en, this message translates to:
  /// **'Already off'**
  String get leaveOutcomeAlreadyOff;

  /// No description provided for @leaveOutcomeFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get leaveOutcomeFailed;

  /// No description provided for @leaveOutcomeUnconfirmed.
  ///
  /// In en, this message translates to:
  /// **'Not confirmed'**
  String get leaveOutcomeUnconfirmed;

  /// No description provided for @leaveOutcomeSkipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get leaveOutcomeSkipped;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @activityTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent activity'**
  String get activityTitle;

  /// No description provided for @activityEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing yet.'**
  String get activityEmpty;

  /// No description provided for @activityCommandSentOn.
  ///
  /// In en, this message translates to:
  /// **'{device}: turn on requested'**
  String activityCommandSentOn(String device);

  /// No description provided for @activityCommandSentOff.
  ///
  /// In en, this message translates to:
  /// **'{device}: turn off requested'**
  String activityCommandSentOff(String device);

  /// No description provided for @activityConfirmed.
  ///
  /// In en, this message translates to:
  /// **'{device}: confirmed {value}'**
  String activityConfirmed(String device, String value);

  /// No description provided for @activityFailed.
  ///
  /// In en, this message translates to:
  /// **'{device}: command failed'**
  String activityFailed(String device);

  /// No description provided for @activityUnconfirmed.
  ///
  /// In en, this message translates to:
  /// **'{device}: not confirmed'**
  String activityUnconfirmed(String device);

  /// No description provided for @activityExternal.
  ///
  /// In en, this message translates to:
  /// **'{device} changed to {value} outside the app'**
  String activityExternal(String device, String value);

  /// No description provided for @activityReading.
  ///
  /// In en, this message translates to:
  /// **'{device}: new reading {value}'**
  String activityReading(String device, String value);

  /// No description provided for @activityUnavailable.
  ///
  /// In en, this message translates to:
  /// **'{device} became unavailable'**
  String activityUnavailable(String device);

  /// No description provided for @activityRemoved.
  ///
  /// In en, this message translates to:
  /// **'{device} was removed'**
  String activityRemoved(String device);

  /// No description provided for @activityConnectionLost.
  ///
  /// In en, this message translates to:
  /// **'Connection lost'**
  String get activityConnectionLost;

  /// No description provided for @activityReconnected.
  ///
  /// In en, this message translates to:
  /// **'Reconnected — states refreshed'**
  String get activityReconnected;

  /// No description provided for @demoControlsTitle.
  ///
  /// In en, this message translates to:
  /// **'Demo controls'**
  String get demoControlsTitle;

  /// No description provided for @demoControlsHint.
  ///
  /// In en, this message translates to:
  /// **'These fake real-world events so you can watch how the app reacts. Nothing here touches a real device.'**
  String get demoControlsHint;

  /// No description provided for @demoGoOffline.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get demoGoOffline;

  /// No description provided for @demoGoOnline.
  ///
  /// In en, this message translates to:
  /// **'Reconnect'**
  String get demoGoOnline;

  /// No description provided for @demoFailNext.
  ///
  /// In en, this message translates to:
  /// **'Fail next command'**
  String get demoFailNext;

  /// No description provided for @demoDropNext.
  ///
  /// In en, this message translates to:
  /// **'Drop next confirmation'**
  String get demoDropNext;

  /// No description provided for @demoArmed.
  ///
  /// In en, this message translates to:
  /// **'Armed'**
  String get demoArmed;

  /// No description provided for @demoFlip.
  ///
  /// In en, this message translates to:
  /// **'Flip {device} from outside'**
  String demoFlip(String device);

  /// No description provided for @demoMakeUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Make {device} unavailable'**
  String demoMakeUnavailable(String device);

  /// No description provided for @demoMakeAvailable.
  ///
  /// In en, this message translates to:
  /// **'Make {device} available'**
  String demoMakeAvailable(String device);

  /// No description provided for @demoNudgeTemperature.
  ///
  /// In en, this message translates to:
  /// **'New temperature reading'**
  String get demoNudgeTemperature;

  /// No description provided for @failureNetwork.
  ///
  /// In en, this message translates to:
  /// **'Can\'t reach the server. Check the address and that the phone is on the same network.'**
  String get failureNetwork;

  /// No description provided for @failureTimeout.
  ///
  /// In en, this message translates to:
  /// **'The server took too long to respond.'**
  String get failureTimeout;

  /// No description provided for @failureTls.
  ///
  /// In en, this message translates to:
  /// **'Secure connection failed: the certificate isn\'t trusted.'**
  String get failureTls;

  /// No description provided for @failureAuth.
  ///
  /// In en, this message translates to:
  /// **'Access token rejected. Check that it\'s complete and not revoked.'**
  String get failureAuth;

  /// No description provided for @failurePermission.
  ///
  /// In en, this message translates to:
  /// **'This account isn\'t allowed to do that.'**
  String get failurePermission;

  /// No description provided for @failureNotFound.
  ///
  /// In en, this message translates to:
  /// **'Not found at the source.'**
  String get failureNotFound;

  /// No description provided for @failureInvalidUrl.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid address, e.g. http://homeassistant.local:8123'**
  String get failureInvalidUrl;

  /// No description provided for @failureInsecureUrl.
  ///
  /// In en, this message translates to:
  /// **'This build only accepts https:// addresses. Plain HTTP is allowed in debug builds for local learning only.'**
  String get failureInsecureUrl;

  /// No description provided for @failureNotConnected.
  ///
  /// In en, this message translates to:
  /// **'Not connected.'**
  String get failureNotConnected;

  /// No description provided for @failureServer.
  ///
  /// In en, this message translates to:
  /// **'Home Assistant returned an error.'**
  String get failureServer;

  /// No description provided for @failureSimulated.
  ///
  /// In en, this message translates to:
  /// **'simulated failure (demo control)'**
  String get failureSimulated;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// No description provided for @settingsMode.
  ///
  /// In en, this message translates to:
  /// **'Mode'**
  String get settingsMode;

  /// No description provided for @currentMode.
  ///
  /// In en, this message translates to:
  /// **'Current: {mode}'**
  String currentMode(String mode);

  /// No description provided for @switchToDemo.
  ///
  /// In en, this message translates to:
  /// **'Switch to demo'**
  String get switchToDemo;

  /// No description provided for @chooseDevices.
  ///
  /// In en, this message translates to:
  /// **'Choose room devices'**
  String get chooseDevices;

  /// No description provided for @reconfigureConnection.
  ///
  /// In en, this message translates to:
  /// **'Reconfigure connection'**
  String get reconfigureConnection;

  /// No description provided for @leaveMode.
  ///
  /// In en, this message translates to:
  /// **'Back to start'**
  String get leaveMode;

  /// No description provided for @disconnectErase.
  ///
  /// In en, this message translates to:
  /// **'Disconnect and erase credentials'**
  String get disconnectErase;

  /// No description provided for @disconnectEraseBody.
  ///
  /// In en, this message translates to:
  /// **'The address, access token and room selection are deleted from this device. Also revoke the token in Home Assistant if you no longer need it.'**
  String get disconnectEraseBody;

  /// No description provided for @erase.
  ///
  /// In en, this message translates to:
  /// **'Erase'**
  String get erase;

  /// No description provided for @credentialsErased.
  ///
  /// In en, this message translates to:
  /// **'Credentials erased.'**
  String get credentialsErased;

  /// No description provided for @connectTitle.
  ///
  /// In en, this message translates to:
  /// **'Connect to Home Assistant'**
  String get connectTitle;

  /// No description provided for @connectIntro.
  ///
  /// In en, this message translates to:
  /// **'MrSmart talks directly to your Home Assistant on your local network. There\'s no MrSmart server.'**
  String get connectIntro;

  /// No description provided for @haUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Home Assistant address'**
  String get haUrlLabel;

  /// No description provided for @haUrlHint.
  ///
  /// In en, this message translates to:
  /// **'http://homeassistant.local:8123'**
  String get haUrlHint;

  /// No description provided for @haTokenLabel.
  ///
  /// In en, this message translates to:
  /// **'Long-lived access token'**
  String get haTokenLabel;

  /// No description provided for @haTokenHelp.
  ///
  /// In en, this message translates to:
  /// **'Create one in Home Assistant: your profile → Security → Long-lived access tokens. It can do everything your account can, so prefer a dedicated test user.'**
  String get haTokenHelp;

  /// No description provided for @haTokenRequired.
  ///
  /// In en, this message translates to:
  /// **'Paste the access token.'**
  String get haTokenRequired;

  /// No description provided for @showToken.
  ///
  /// In en, this message translates to:
  /// **'Show token'**
  String get showToken;

  /// No description provided for @hideToken.
  ///
  /// In en, this message translates to:
  /// **'Hide token'**
  String get hideToken;

  /// No description provided for @insecureHttpWarning.
  ///
  /// In en, this message translates to:
  /// **'HTTP is unencrypted: anyone on the network can read the token. Use it only on your own home network for learning — never over the internet.'**
  String get insecureHttpWarning;

  /// No description provided for @testAndSave.
  ///
  /// In en, this message translates to:
  /// **'Test and save'**
  String get testAndSave;

  /// No description provided for @testing.
  ///
  /// In en, this message translates to:
  /// **'Testing connection…'**
  String get testing;

  /// No description provided for @connectedTo.
  ///
  /// In en, this message translates to:
  /// **'Connected to {name} (Home Assistant {version})'**
  String connectedTo(String name, String version);

  /// No description provided for @selectTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose room devices'**
  String get selectTitle;

  /// No description provided for @selectSafety.
  ///
  /// In en, this message translates to:
  /// **'Pick a lamp or similar non-critical load. Don\'t use switches that run heaters, pumps, medical, security or other safety-critical equipment with this learning app.'**
  String get selectSafety;

  /// No description provided for @selectHint.
  ///
  /// In en, this message translates to:
  /// **'Only the entities you tick are shown and controlled. Nothing else in your home is touched.'**
  String get selectHint;

  /// No description provided for @selectSave.
  ///
  /// In en, this message translates to:
  /// **'Use {count} selected'**
  String selectSave(int count);

  /// No description provided for @selectEmpty.
  ///
  /// In en, this message translates to:
  /// **'No supported entities found. Supported: lights, switches, input booleans and temperature sensors.'**
  String get selectEmpty;

  /// No description provided for @errorTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorTitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
