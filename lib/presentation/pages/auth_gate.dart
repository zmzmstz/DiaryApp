import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/backlog_repository.dart';
import '../../logic/blocs/backlog_bloc.dart';
import '../../models/app_user.dart';
import 'login_page.dart';
import 'main_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  AppUser? _currentUser;

  void _onLoginSuccess(AppUser user) {
    final repo = context.read<BacklogRepository>();
    repo.setCurrentUser(user.username);
    context.read<BacklogBloc>().add(LoadBacklogItems());
    setState(() {
      _currentUser = user;
    });
  }

  void _logout() {
    setState(() {
      _currentUser = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return LoginPage(onLoginSuccess: _onLoginSuccess);
    }

    return MainScreen(
      currentUsername: _currentUser!.displayName,
      onLogout: _logout,
    );
  }
}
