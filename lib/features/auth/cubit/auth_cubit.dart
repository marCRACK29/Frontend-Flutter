// lib/features/auth/presentation/cubit/auth_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/cliente_model.dart';
import '../repositories/auth_repository.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit(this._authRepository) : super(AuthInitial());

  Future<void> checkAuthStatus() async {
    emit(AuthLoading());
    try {
      final isLoggedIn = await _authRepository.isLoggedIn();
      if (isLoggedIn) {
        final cliente = await _authRepository.getProfile();
        emit(AuthAuthenticated(cliente));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final cliente = await _authRepository.login(email, password);
      emit(AuthAuthenticated(cliente));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> registerCliente({
    required String rut,
    required String nombre,
    required String correo,
    required String contrasena,
    required int numeroDomicilio,
    required String calle,
    required String ciudad,
    required String region,
    required int codigoPostal,
  }) async {
    emit(AuthLoading());
    try {
      final cliente = await _authRepository.registerCliente(
        rut: rut,
        nombre: nombre,
        correo: correo,
        contrasena: contrasena,
        numeroDomicilio: numeroDomicilio,
        calle: calle,
        ciudad: ciudad,
        region: region,
        codigoPostal: codigoPostal,
      );
      emit(AuthRegistered(cliente));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> logout() async {
    emit(AuthLoading());
    try {
      await _authRepository.logout();
      emit(AuthUnauthenticated());
    } catch (e) {
      // Incluso si el logout falla, consideramos que el usuario está desautenticado
      emit(AuthUnauthenticated());
    }
  }

  Future<void> updateProfile({String? name}) async {
    if (state is! AuthAuthenticated) return;
    
    try {
      final updatedCliente = await _authRepository.updateProfile(name: name);
      emit(AuthAuthenticated(updatedCliente));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  void clearError() {
    if (state is AuthError) {
      emit(AuthUnauthenticated());
    }
  }
}