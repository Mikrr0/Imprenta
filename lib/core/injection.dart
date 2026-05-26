import "../features/auth/presentation/viewmodels/login_viewmodel.dart";

class AppDependencies {
  static LoginViewModel buildLoginViewModel() {
    return LoginViewModel();
  }
}