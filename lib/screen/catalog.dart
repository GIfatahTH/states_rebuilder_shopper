import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import 'package:states_rebuilder_shopper/models/cart.dart';
import 'package:states_rebuilder_shopper/models/catalog.dart';

//define a global final private variable as get the theme without the context
//The will result in a performance increase, because theme are often used inside
//build method which may be executed each frame.
//So if you use Theme.of(context), it will be executed 60 times per second (animation).
//But if you use the global theme variable, the method will be executed one time.
final _theme = RM.theme;

class MyCatalog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WhenRebuilder<CatalogState>(
        // Create a new ReactiveModel and subscribe to this WhenRebuilder
        // and invoke getItems method.
        //
        observe: () => RM.get<CatalogState>().future(
              (CatalogState s, Future<CatalogState> _) => s.getItems(),
            ),
        //OnSetState is used for side effects
        onSetState: (context, catalogStateRM) {
          if (catalogStateRM.hasError) {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  content: Text('Check net work connection'),
                  actions: [
                    RaisedButton(
                      child: Text('Try again'),
                      onPressed: () {
                        //call getItems again.
                        catalogStateRM.refresh();
                        //With states_rebuilder you can navigate without context,
                        RM.navigator.pop();
                      },
                    )
                  ],
                );
              },
            );
          }
        },
        onIdle: () => Text('onIdle'),
        onWaiting: () => Center(child: CircularProgressIndicator()),
        onError: (error) => Container(color: Colors.red),
        onData: (data) {
          // As we want to rebuild the list of items when removing an item,
          // we used this StateBuilder and subscribe to the global registered
          // ReactiveModel
          return StateBuilder<CatalogState>(
            observe: () => RM.get<CatalogState>(),
            builder: (context, catalogStateRM) {
              return CustomScrollView(
                slivers: [
                  _MyAppBar(),
                  SliverToBoxAdapter(child: SizedBox(height: 12)),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) =>
                          _MyListItem(catalogStateRM.state.items[index]),
                      childCount: catalogStateRM.state.items.length,
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final Item item;
  const _AddButton({Key key, @required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the registered cartState ReactiveModel
    final cartRM = RM.get<CartState>();
    return FlatButton(
      onPressed: cartRM.state.items.contains(item)
          ? null
          : () async {
              await cartRM.setState(
                (currentState) => CartState.add(
                  currentState,
                  item,
                ),
                //cartRM has no observer yet
                // silent no-observer exception
                silent: true,
              );
              //Notify the global CatalogState ReactiveModel to rebuild.
              RM.get<CatalogState>().notify();
            },
      //with states_rebuilder you can get the current them without explicitly using the context
      splashColor: _theme.primaryColor,
      child: cartRM.state.items.contains(item)
          ? Icon(Icons.check, semanticLabel: 'ADDED')
          : Text('ADD'),
    );
  }
}

class _MyAppBar extends StatelessWidget {
  //With states_rebuilder you can navigate without explicitly using the context
  void _navigateTo() => RM.navigator.pushNamed('/cart');

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      title: Text('Catalog'),
      floating: true,
      actions: [
        IconButton(
          icon: Icon(Icons.shopping_cart),
          onPressed: _navigateTo,
        ),
      ],
    );
  }
}

class _MyListItem extends StatelessWidget {
  final Item item;

  _MyListItem(this.item, {Key key}) : super(key: key);

  //with states_rebuilder you can get the current them without BuildContext
  final textTheme = _theme.textTheme.headline6;

  void _displaySnackBar() {
    //with states_rebuilder you can get the active ScaffoldState without
    // explicitly using the BuildContext
    RM.scaffold.showSnackBar(
      SnackBar(
        content: Text('error.message'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('${item.id}'),
      onDismissed: (_) {
        // Get the global CatalogState ReactiveModel
        RM.get<CatalogState>().setState(
          // Invoke deleteItem
          (currentState) => CatalogState.deleteItem(
            currentState,
            item,
          ),
          onError: (context, error) {
            // Display SnackBar
            _displaySnackBar();
          },
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: LimitedBox(
          maxHeight: 48,
          child: Row(
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: Container(
                  color: item.color,
                ),
              ),
              SizedBox(width: 24),
              Expanded(
                child: Text(item.name, style: textTheme),
              ),
              SizedBox(width: 24),
              _AddButton(item: item),
            ],
          ),
        ),
      ),
    );
  }
}
