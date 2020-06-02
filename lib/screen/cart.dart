import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import 'package:states_rebuilder_shopper/models/cart.dart';

final _theme = RM.theme;

class MyCart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
        backgroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.yellow,
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: _CartList(),
              ),
            ),
            Divider(height: 4, color: Colors.black),
            _CartTotal()
          ],
        ),
      ),
    );
  }
}

class _CartList extends StatelessWidget {
  final cart = IN.get<CartState>();
  final itemNameStyle = _theme.textTheme.headline6;
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: cart.items.length,
      itemBuilder: (context, index) => ListTile(
        leading: Icon(Icons.done),
        title: Text(
          cart.items[index].name,
          style: itemNameStyle,
        ),
      ),
    );
  }
}

class _CartTotal extends StatelessWidget {
  final cart = IN.get<CartState>();
  final hugeStyle = _theme.textTheme.headline1.copyWith(fontSize: 48);
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Center(
        child: StateBuilder<int>(
            observe: () => RM.create(cart.totalPrice),
            builder: (context, totalPriceRM) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('\$${totalPriceRM.state}', style: hugeStyle),
                  SizedBox(width: 24),
                  FlatButton(
                    onPressed: () {
                      totalPriceRM.setState((s) {
                        // some api coll ...
                        throw Exception('Buying not supported yet.');
                      }, onError: (context, error) {
                        RM.scaffold.showSnackBar(
                          SnackBar(
                            content: Text('${error.message}'),
                          ),
                        );
                      });
                    },
                    color: Colors.white,
                    child: Text('BUY'),
                  ),
                ],
              );
            }),
      ),
    );
  }
}
