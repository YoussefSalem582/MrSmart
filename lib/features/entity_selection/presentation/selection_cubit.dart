import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error/failure.dart';
import '../../room/domain/entities/entity_snapshot.dart';
import '../../room/domain/repositories/entity_catalog_repository.dart';
import '../../room/domain/repositories/room_selection_repository.dart';

class SelectionState extends Equatable {
  const SelectionState({
    this.isLoading = true,
    this.entities = const [],
    this.selected = const {},
    this.failure,
  });

  final bool isLoading;
  final List<EntitySnapshot> entities;
  final Set<String> selected;
  final Failure? failure;

  @override
  List<Object?> get props => [
    isLoading,
    entities,
    selected,
    failure?.runtimeType,
  ];
}

/// The user explicitly picks the room's entities. Nothing is pre-selected
/// except what they chose before.
class SelectionCubit extends Cubit<SelectionState> {
  SelectionCubit(this._catalog, this._selection)
    : super(const SelectionState());

  final EntityCatalogRepository _catalog;
  final RoomSelectionRepository _selection;

  Future<void> load() async {
    emit(const SelectionState());
    try {
      final entities = await _catalog.listSupportedEntities();
      final ids = entities.map((e) => e.id).toSet();
      final previous = _selection.read().where(ids.contains).toSet();
      if (!isClosed) {
        emit(
          SelectionState(
            isLoading: false,
            entities: entities,
            selected: previous,
          ),
        );
      }
    } on Failure catch (f) {
      if (!isClosed) emit(SelectionState(isLoading: false, failure: f));
    }
  }

  void toggle(String entityId) {
    final next = {...state.selected};
    next.contains(entityId) ? next.remove(entityId) : next.add(entityId);
    emit(
      SelectionState(
        isLoading: false,
        entities: state.entities,
        selected: next,
      ),
    );
  }

  /// Saves in catalog order.
  Future<void> save() => _selection.save([
    for (final e in state.entities)
      if (state.selected.contains(e.id)) e.id,
  ]);
}
