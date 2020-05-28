import 'package:flutter/material.dart';
import 'package:states_rebuilder_shopper/repository/catalog_repository.dart';

@immutable
class CatalogState {
  CatalogState({
    @required this.repository,
    @required this.items,
  });
  //
  final CatalogRepository repository;
  final List<Item> items;

  //After getting items from the repository,
  //A new CatalogState is return with the
  Future<CatalogState> getItems() async {
    final items = await repository.fetchItems();
    return copyWith(
      items: items,
    );
  }

  static Stream<CatalogState> deleteItem(
    CatalogState currentState,
    Item item,
  ) async* {
    try {
      //yield the new state.
      //states_rebuilder will refresh the UI to display the new state
      yield currentState.copyWith(
        items: currentState.items.where((e) => e.id != item.id).toList(),
      );
      //remove the item from the backend
      await currentState.repository.removeItem(item);
    } catch (e) {
      //on error, yield the old state
      //states_rebuilder will refresh the UI to display the old state
      yield currentState;
      //rethrow the error; states_rebuilder will catch the error
      //display a SnackBar.
      rethrow;
    }
  }

  CatalogState copyWith({
    List<Item> items,
    CatalogRepository repository,
  }) {
    return CatalogState(
      items: items ?? this.items,
      repository: repository ?? this.repository,
    );
  }
}

//mutable class
// class CatalogState {
//   CatalogState({
//     @required this.repository,
//   });
//   //
//   final CatalogRepository repository;
//   List<Item> items = [];

//   Future<CatalogState> getItems() async {
//     items = await repository.fetchItems();
//     return this;
//   }

//   static Stream<void> deleteItem(
//     CatalogState currentState,
//     Item item,
//   ) async* {
//     final oldItems = [...currentState.items];
//     try {
//       currentState.items = oldItems.where((e) => e.id != item.id).toList();
//       await currentState.repository.removeItem(item);
//     } catch (e) {
//       yield currentState.items = oldItems;
//       rethrow;
//     }
//   }
// }

//This is the initial state.
class CatalogInitialState extends CatalogState {
  CatalogInitialState(CatalogRepository repository)
      : super(
          items: [],
          repository: repository,
        );
}

@immutable
class Item {
  final int id;
  final String name;
  final Color color;
  final int price = 42;

  Item(this.id, this.name)
      // To make the sample app look nicer, each item is given one of the
      // Material Design primary colors.
      : color = Colors.primaries[id % Colors.primaries.length];

  @override
  int get hashCode => id;

  @override
  bool operator ==(Object other) => other is Item && other.id == id;
}
