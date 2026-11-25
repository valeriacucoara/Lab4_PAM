import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/cart_cubit.dart';
import '../widgets/store_sections.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(title: const Text('My Cart'), backgroundColor: Colors.white),
    body: BlocBuilder<CartCubit, CartState>(builder: (context, cart) {
      if (cart.items.isEmpty) return const Center(child: Text('Your cart is empty'));
      return Column(children: [
        Expanded(child: ListView(children: cart.items.values.map((item) => ListTile(
          leading: ClipRRect(borderRadius: BorderRadius.circular(8), child: ApiImage(
            url: item.product.imageUrl, width: 58, height: 58)),
          title: Text(item.product.name),
          subtitle: Text('\$ ${item.product.price.toStringAsFixed(2)}'),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: () =>
              context.read<CartCubit>().decrease(item.product.id)),
            Text('${item.quantity}'),
            IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () =>
              context.read<CartCubit>().add(item.product)),
          ]),
        )).toList())),
        Padding(padding: const EdgeInsets.all(25), child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Total', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
            Text('\$ ${cart.total.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ])),
      ]);
    }),
  );
}
