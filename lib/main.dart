import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'common/theme.dart';
import 'models/cart.dart';
import 'models/catalog.dart';
import 'repository/catalog_repository.dart';
import 'screen/cart.dart';
import 'screen/catalog.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Injector(
      inject: [
        // Inject the CatalogState.
        Inject<CatalogState>(
          // The starting state is CatalogInitialState
          () => CatalogInitialState(CatalogRepository()),
        ),
        //Inject CartState with initial state of empty items
        Inject<CartState>(() => CartState(items: [])),
      ],
      builder: (context) => MaterialApp(
        title: 'Provider Demo',
        theme: appTheme,
        initialRoute: '/',
        routes: {
          '/': (context) => MyCatalog(),
          '/cart': (context) => MyCart(),
        },
      ),
    );
  }
}
