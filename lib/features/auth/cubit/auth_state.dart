// lib/features/auth/presentation/cubit/auth_state.dart
part of 'auth_cubit.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final ClienteModel cliente;

  const AuthAuthenticated(this.cliente);

  @override
  List<Object> get props => [cliente];
}

class AuthUnauthenticated extends AuthState {}

class AuthRegistered extends AuthState {
  final ClienteModel cliente;

  const AuthRegistered(this.cliente);

  @override
  List<Object> get props => [cliente];
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object> get props => [message];
}