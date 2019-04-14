import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:flutter_firebase_authentication/login/login.dart';
import 'package:flutter_firebase_authentication/form/form.dart';
import 'package:flutter_firebase_authentication/authentication/authentication.dart';

class LoginBloc extends Bloc<FormEvent, FormState> {
  UserRepository _userRepository;
  AuthenticationBloc _authenticationBloc;

  LoginBloc({
    @required UserRepository userRepository,
    @required AuthenticationBloc authenticationBloc,
  })  : assert(userRepository != null),
        assert(authenticationBloc != null),
        _userRepository = userRepository,
        _authenticationBloc = authenticationBloc;

  @override
  FormState get initialState => Initial();

  @override
  Stream<FormState> mapEventToState(FormEvent event) async* {
    if (event is EmailChanged) {
      yield* _mapEmailChangedToState(event.email);
    } else if (event is PasswordChanged) {
      yield* _mapPasswordChangedToState(event.password);
    } else if (event is LoginWithGooglePressed) {
      yield* _mapLoginWithGooglePressedToState();
    } else if (event is LoginWithCredentialsPressed) {
      yield* _mapLoginWithCredentialsPressedToState(
        email: event.email,
        password: event.password,
      );
    }
  }

  Stream<FormState> _mapEmailChangedToState(String email) async* {
    if (currentState is! Editing) {
      yield Editing.empty().copyWith(
        isEmailValid: email.isNotEmpty,
      );
    } else {
      yield (currentState as Editing).update(
        isEmailValid: email.isNotEmpty,
      );
    }
  }

  Stream<FormState> _mapPasswordChangedToState(
    String password,
  ) async* {
    if (currentState is! Editing) {
      yield Editing.empty().copyWith(
        isPasswordValid: password.isNotEmpty,
      );
    } else {
      yield (currentState as Editing).update(
        isPasswordValid: password.isNotEmpty,
      );
    }
  }

  Stream<FormState> _mapLoginWithGooglePressedToState() async* {
    try {
      await _userRepository.signInWithGoogle();
      _authenticationBloc.dispatch(LoggedIn());
      yield Editing.success();
    } catch (_) {
      yield Editing.failure();
    }
  }

  Stream<FormState> _mapLoginWithCredentialsPressedToState({
    String email,
    String password,
  }) async* {
    yield Editing.loading();
    try {
      await _userRepository.signInWithCredentials(email, password);
      _authenticationBloc.dispatch(LoggedIn());
      yield Editing.success();
    } catch (_) {
      yield Editing.failure();
    }
  }
}