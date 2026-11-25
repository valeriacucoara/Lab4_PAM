import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import 'domain/repositories/store_repository.dart';
import 'data/datasources/store_api_service.dart';
import 'data/repositories/store_repository_impl.dart';
import 'presentation/cubit/cart_cubit.dart';
import 'presentation/cubit/store_cubit.dart';
import 'presentation/screens/home_page.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<StoreRepository>(
      create: (_) => StoreRepositoryImpl(StoreApiService(http.Client())),
      dispose: (repository) => repository.dispose(),
      child: MultiBlocProvider(
        providers: [
          BlocProvider<StoreCubit>(
            create: (context) => StoreCubit(context.read<StoreRepository>())..loadProducts(),
          ),
          BlocProvider<CartCubit>(create: (_) => CartCubit()),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          // Pe web/desktop aplicatia ramane cat un ecran de telefon.
          builder: (context, child) => Container(
            color: const Color(0xFFEDEDED),
            alignment: Alignment.center,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: child,
            ),
          ),
          title: 'Lab4 - GemStore',
          theme: ThemeData(
            useMaterial3: true,
            scaffoldBackgroundColor: Colors.white,
            colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4E8E82)),
          ),
          home: const HomePage(),
        ),
      ),
    );
  }
}
