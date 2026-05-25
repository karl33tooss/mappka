import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/auth_service.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {} 

class AuthLoading extends AuthState {} 

class AuthAuthenticated extends AuthState {
  final User user;
  AuthAuthenticated(this.user);
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService;
  late StreamSubscription<User?> _authSubscription;
  AuthCubit(this._authService) : super(AuthInitial()) {
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    });
  }

  Future<void> signIn(String email, String password) async {
    emit(AuthLoading());
    final result = await _authService.signInWithEmail(email, password);
    
    if (result == null) {
      emit(AuthError('Wrong email or password')); 
      emit(AuthUnauthenticated()); 
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required DateTime birthDate,
  }) async {
    emit(AuthLoading());
    final result = await _authService.signUpWithEmail(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      birthDate: birthDate,
    );
    
    if (result == null) {
      emit(AuthError('Registration error.'));
      emit(AuthUnauthenticated());
    }
  }

  Future<void> signOut() async {
    emit(AuthLoading());
    await _authService.signOut();
  }

  @override
  Future<void> close() {
    _authSubscription.cancel();
    return super.close();
  }
}