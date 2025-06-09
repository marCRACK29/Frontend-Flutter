// lib/features/auth/presentation/widgets/auth_wrapper.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/auth_cubit.dart';
import '../views/login_screen.dart';

class AuthWrapper extends StatelessWidget {
  final Widget child;

  const AuthWrapper({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading || state is AuthInitial) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        if (state is AuthAuthenticated) {
          return child;
        }
        
        //return const LoginScreen();
      },
    );
  }
}