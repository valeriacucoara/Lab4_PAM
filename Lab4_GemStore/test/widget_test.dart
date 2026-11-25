import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lab4_gemstore/presentation/cubit/cart_cubit.dart';
import 'package:lab4_gemstore/presentation/screens/cart_page.dart';

void main() {
  testWidgets('Cosul local are stare Empty', (tester) async {
    final cubit = CartCubit();
    await tester.pumpWidget(BlocProvider<CartCubit>.value(
      value: cubit, child: const MaterialApp(home: CartPage())));
    expect(find.text('My Cart'), findsOneWidget);
    expect(find.text('Your cart is empty'), findsOneWidget);
    await cubit.close();
  });
}
