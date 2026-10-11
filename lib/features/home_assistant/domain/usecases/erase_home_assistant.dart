import '../../../room/domain/repositories/room_selection_repository.dart';
import '../ha_credentials.dart';

/// Removes the stored address, token and room selection from the device.
class EraseHomeAssistant {
  const EraseHomeAssistant(this._credentials, this._selection);

  final CredentialsRepository _credentials;
  final RoomSelectionRepository _selection;

  Future<void> call() async {
    await _credentials.erase();
    await _selection.clear();
  }
}
