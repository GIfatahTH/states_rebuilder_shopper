import 'dart:math';

import 'package:states_rebuilder_shopper/models/catalog.dart';

class CatalogRepository {
  List<String> itemNames = [
    'Code Smell',
    'Control Flow',
    'Interpreter',
    'Recursion',
    'Sprint',
    'Heisenbug',
    'Spaghetti',
    'Hydra Code',
    'Off-By-One',
    'Scope',
    'Callback',
    'Closure',
    'Automata',
    'Bit Shift',
    'Currying',
  ];
  Future<List<Item>> fetchItems() async {
    await Future.delayed(Duration(seconds: 2));
    if (Random().nextBool()) {
      throw Exception('Network Exception');
    }

    return itemNames.map((e) => Item(itemNames.indexOf(e), e)).toList();
  }

  Future<bool> removeItem(Item item) async {
    await Future.delayed(Duration(seconds: 2));
    if (Random().nextBool()) throw Exception('Network Exception');
    itemNames.remove(item.name);
    return true;
  }
}
