import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/auth_cubit.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.select<AuthCubit, String?>(
      (cubit) => (cubit.state is AuthAuthenticated)
          ? (cubit.state as AuthAuthenticated).cliente.nombre
          : null,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Bienvenido')),
      body: Center(
        child: Text(
          user != null
              ? '¡Bienvenido, $user!'
              : '¡Sesión iniciada!',
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
