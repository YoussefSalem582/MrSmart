// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'MrSmart';

  @override
  String get welcomeTitle => 'Control one room. Learn how smart homes work.';

  @override
  String get welcomeBody =>
      'Start with a simulated room — no hardware, account or server needed. Connect your own Home Assistant when you\'re ready.';

  @override
  String get tryDemo => 'Try demo';

  @override
  String get connectHomeAssistant => 'Connect to Home Assistant';

  @override
  String get settings => 'Settings';

  @override
  String get roomTitle => 'My room';

  @override
  String get modeDemo => 'Demo';

  @override
  String get modeHomeAssistant => 'Home Assistant';

  @override
  String get modeNone => 'Not set up';

  @override
  String get simulatedBadge => 'Simulated';

  @override
  String get simulatedNotice => 'Simulated data — not real device telemetry.';

  @override
  String get connectionConnecting => 'Connecting…';

  @override
  String get connectionConnected => 'Live';

  @override
  String connectionReconnecting(int seconds, int attempt) {
    return 'Offline — retrying in ${seconds}s (attempt $attempt)';
  }

  @override
  String get connectionDisconnected => 'Offline — controls are disabled';

  @override
  String get connectionAuthFailed =>
      'Access token rejected. Reconfigure the connection in Settings.';

  @override
  String get valueOn => 'On';

  @override
  String get valueOff => 'Off';

  @override
  String get valueUnknown => 'Unknown';

  @override
  String get valueUnavailable => 'Unavailable';

  @override
  String get deviceRemoved => 'Removed from the source';

  @override
  String get deviceLoading => 'Waiting for first state…';

  @override
  String lastConfirmed(String time) {
    return 'Last confirmed $time';
  }

  @override
  String staleNote(String time) {
    return 'Last known value · confirmed $time';
  }

  @override
  String get commandPendingOn => 'Turning on… waiting for confirmation';

  @override
  String get commandPendingOff => 'Turning off… waiting for confirmation';

  @override
  String commandFailedOn(String reason) {
    return 'Turn on failed: $reason';
  }

  @override
  String commandFailedOff(String reason) {
    return 'Turn off failed: $reason';
  }

  @override
  String get commandUnconfirmedTimeout =>
      'Not confirmed: the device didn\'t report the new state in time.';

  @override
  String get commandUnconfirmedConnection =>
      'Not confirmed: the connection dropped before the device reported back.';

  @override
  String get controlHintOffline => 'Controls are disabled while offline.';

  @override
  String get kindLight => 'Light';

  @override
  String get kindSwitch => 'Switch';

  @override
  String get kindInputBoolean => 'Helper toggle';

  @override
  String get kindTemperature => 'Temperature';

  @override
  String get leaveRoom => 'Leave room';

  @override
  String get leaveRoomExplain =>
      'Turns off only this room\'s selected devices. The app has to be open to run it. Anything that must happen on its own — on a schedule or when a sensor triggers — belongs in a Home Assistant automation.';

  @override
  String get leaveRoomConfirm => 'Turn off room devices';

  @override
  String get leaveRoomRunning => 'Turning off and waiting for confirmation…';

  @override
  String get leaveRoomAllOff => 'All selected devices are confirmed off.';

  @override
  String get leaveRoomPartial =>
      'Not everything turned off. Check each device below.';

  @override
  String get leaveRoomNotConnected => 'You\'re offline, so nothing was sent.';

  @override
  String get leaveRoomNothing => 'This room has no controllable devices.';

  @override
  String get leaveOutcomeConfirmed => 'Off (confirmed)';

  @override
  String get leaveOutcomeAlreadyOff => 'Already off';

  @override
  String get leaveOutcomeFailed => 'Failed';

  @override
  String get leaveOutcomeUnconfirmed => 'Not confirmed';

  @override
  String get leaveOutcomeSkipped => 'Skipped';

  @override
  String get close => 'Close';

  @override
  String get cancel => 'Cancel';

  @override
  String get retry => 'Retry';

  @override
  String get activityTitle => 'Recent activity';

  @override
  String get activityEmpty => 'Nothing yet.';

  @override
  String activityCommandSentOn(String device) {
    return '$device: turn on requested';
  }

  @override
  String activityCommandSentOff(String device) {
    return '$device: turn off requested';
  }

  @override
  String activityConfirmed(String device, String value) {
    return '$device: confirmed $value';
  }

  @override
  String activityFailed(String device) {
    return '$device: command failed';
  }

  @override
  String activityUnconfirmed(String device) {
    return '$device: not confirmed';
  }

  @override
  String activityExternal(String device, String value) {
    return '$device changed to $value outside the app';
  }

  @override
  String activityReading(String device, String value) {
    return '$device: new reading $value';
  }

  @override
  String activityUnavailable(String device) {
    return '$device became unavailable';
  }

  @override
  String activityRemoved(String device) {
    return '$device was removed';
  }

  @override
  String get activityConnectionLost => 'Connection lost';

  @override
  String get activityReconnected => 'Reconnected — states refreshed';

  @override
  String get demoControlsTitle => 'Demo controls';

  @override
  String get demoControlsHint =>
      'These fake real-world events so you can watch how the app reacts. Nothing here touches a real device.';

  @override
  String get demoGoOffline => 'Disconnect';

  @override
  String get demoGoOnline => 'Reconnect';

  @override
  String get demoFailNext => 'Fail next command';

  @override
  String get demoDropNext => 'Drop next confirmation';

  @override
  String get demoArmed => 'Armed';

  @override
  String demoFlip(String device) {
    return 'Flip $device from outside';
  }

  @override
  String demoMakeUnavailable(String device) {
    return 'Make $device unavailable';
  }

  @override
  String demoMakeAvailable(String device) {
    return 'Make $device available';
  }

  @override
  String get demoNudgeTemperature => 'New temperature reading';

  @override
  String get failureNetwork =>
      'Can\'t reach the server. Check the address and that the phone is on the same network.';

  @override
  String get failureTimeout => 'The server took too long to respond.';

  @override
  String get failureTls =>
      'Secure connection failed: the certificate isn\'t trusted.';

  @override
  String get failureAuth =>
      'Access token rejected. Check that it\'s complete and not revoked.';

  @override
  String get failurePermission => 'This account isn\'t allowed to do that.';

  @override
  String get failureNotFound => 'Not found at the source.';

  @override
  String get failureInvalidUrl =>
      'Enter a valid address, e.g. http://homeassistant.local:8123';

  @override
  String get failureInsecureUrl =>
      'This build only accepts https:// addresses. Plain HTTP is allowed in debug builds for local learning only.';

  @override
  String get failureNotConnected => 'Not connected.';

  @override
  String get failureServer => 'Home Assistant returned an error.';

  @override
  String get failureSimulated => 'simulated failure (demo control)';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'العربية';

  @override
  String get settingsMode => 'Mode';

  @override
  String currentMode(String mode) {
    return 'Current: $mode';
  }

  @override
  String get switchToDemo => 'Switch to demo';

  @override
  String get chooseDevices => 'Choose room devices';

  @override
  String get reconfigureConnection => 'Reconfigure connection';

  @override
  String get leaveMode => 'Back to start';

  @override
  String get disconnectErase => 'Disconnect and erase credentials';

  @override
  String get disconnectEraseBody =>
      'The address, access token and room selection are deleted from this device. Also revoke the token in Home Assistant if you no longer need it.';

  @override
  String get erase => 'Erase';

  @override
  String get credentialsErased => 'Credentials erased.';

  @override
  String get connectTitle => 'Connect to Home Assistant';

  @override
  String get connectIntro =>
      'MrSmart talks directly to your Home Assistant on your local network. There\'s no MrSmart server.';

  @override
  String get haUrlLabel => 'Home Assistant address';

  @override
  String get haUrlHint => 'http://homeassistant.local:8123';

  @override
  String get haTokenLabel => 'Long-lived access token';

  @override
  String get haTokenHelp =>
      'Create one in Home Assistant: your profile → Security → Long-lived access tokens. It can do everything your account can, so prefer a dedicated test user.';

  @override
  String get haTokenRequired => 'Paste the access token.';

  @override
  String get showToken => 'Show token';

  @override
  String get hideToken => 'Hide token';

  @override
  String get insecureHttpWarning =>
      'HTTP is unencrypted: anyone on the network can read the token. Use it only on your own home network for learning — never over the internet.';

  @override
  String get testAndSave => 'Test and save';

  @override
  String get testing => 'Testing connection…';

  @override
  String connectedTo(String name, String version) {
    return 'Connected to $name (Home Assistant $version)';
  }

  @override
  String get selectTitle => 'Choose room devices';

  @override
  String get selectSafety =>
      'Pick a lamp or similar non-critical load. Don\'t use switches that run heaters, pumps, medical, security or other safety-critical equipment with this learning app.';

  @override
  String get selectHint =>
      'Only the entities you tick are shown and controlled. Nothing else in your home is touched.';

  @override
  String selectSave(int count) {
    return 'Use $count selected';
  }

  @override
  String get selectEmpty =>
      'No supported entities found. Supported: lights, switches, input booleans and temperature sensors.';

  @override
  String get errorTitle => 'Something went wrong';
}
