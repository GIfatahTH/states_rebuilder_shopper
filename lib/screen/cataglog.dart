import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import 'package:states_rebuilder_shopper/models/cart.dart';
import 'package:states_rebuilder_shopper/models/catalog.dart';

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
                        catalogStateRM.setState(
                          (s) => s.getItems(),
                        );
                        Navigator.of(context).pop();
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
    print('rebuild');
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
      splashColor: Theme.of(context).primaryColor,
      child: cartRM.state.items.contains(item)
          ? Icon(Icons.check, semanticLabel: 'ADDED')
          : Text('ADD'),
    );
  }
}

class _MyAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      title: Text('Catalog'),
      floating: true,
      actions: [
        IconButton(
          icon: Icon(Icons.shopping_cart),
          onPressed: () => Navigator.pushNamed(context, '/cart'),
        ),
      ],
    );
  }
}

class _MyListItem extends StatelessWidget {
  final Item item;

  _MyListItem(this.item, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme.headline6;

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
            Scaffold.of(context).showSnackBar(
              SnackBar(
                content: Text('error.message'),
              ),
            );
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
