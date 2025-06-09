// lib/features/auth/auth_setup.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'repositories/auth_repository.dart';
import 'services/auth_api_service.dart';
import 'cubit/auth_cubit.dart';

class AuthSetup {
  static List<BlocProvider> getProviders() {
    return [
      BlocProvider<AuthCubit>(
        create: (context) {
          final apiService = AuthApiService();
          final repository = AuthRepository(apiService);
          final cubit = AuthCubit(repository);
          
          // Verificar estado de autenticación al inicializar
          cubit.checkAuthStatus();
          
          return cubit;
        },
      ),
    ];
  }
}
