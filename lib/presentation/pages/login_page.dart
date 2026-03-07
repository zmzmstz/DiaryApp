import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/backlog_repository.dart';
import '../../models/app_user.dart';

class LoginPage extends StatefulWidget {
  final void Function(AppUser user) onLoginSuccess;

  const LoginPage({
    super.key,
    required this.onLoginSuccess,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _isRegisterMode = false;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _displayNameController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      _isRegisterMode = !_isRegisterMode;
      _errorMessage = null;
    });
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final repository = context.read<BacklogRepository>();

    try {
      final user = await repository.login(
        _usernameController.text,
        _passwordController.text,
      );

      if (!mounted) return;

      if (user == null) {
        setState(() {
          _errorMessage = 'Invalid username or password.';
          _isLoading = false;
        });
        return;
      }

      widget.onLoginSuccess(user);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Login failed: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final repository = context.read<BacklogRepository>();

    try {
      final user = await repository.register(
        username: _usernameController.text,
        password: _passwordController.text,
        displayName: _displayNameController.text,
      );

      if (!mounted) return;
      widget.onLoginSuccess(user);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Registration failed: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Diary App',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isRegisterMode
                            ? 'Create a new account'
                            : 'Sign in to continue',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      if (_isRegisterMode) ...[
                        TextFormField(
                          controller: _displayNameController,
                          decoration: const InputDecoration(
                            labelText: 'Display name',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (!_isRegisterMode) return null;
                            if (value == null || value.trim().isEmpty) {
                              return 'Display name is required.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                      ],
                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Username is required.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password is required.';
                          }
                          if (_isRegisterMode && value.length < 6) {
                            return 'Password must be at least 6 characters.';
                          }
                          return null;
                        },
                        onFieldSubmitted: (_) {
                          if (_isLoading) return;
                          if (_isRegisterMode) {
                            _register();
                          } else {
                            _login();
                          }
                        },
                      ),
                      if (_isRegisterMode) ...[
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Confirm password',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (!_isRegisterMode) return null;
                            if (value != _passwordController.text) {
                              return 'Passwords do not match.';
                            }
                            return null;
                          },
                          onFieldSubmitted: (_) {
                            if (_isLoading) return;
                            if (_isRegisterMode) {
                              _register();
                            } else {
                              _login();
                            }
                          },
                        ),
                      ],
                      const SizedBox(height: 16),
                      if (_errorMessage != null) ...[
                        Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                      ],
                      FilledButton(
                        onPressed: _isLoading
                            ? null
                            : (_isRegisterMode ? _register : _login),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(_isRegisterMode ? 'Register' : 'Login'),
                      ),
                      TextButton(
                        onPressed: _isLoading ? null : _toggleMode,
                        child: Text(
                          _isRegisterMode
                              ? 'Already have an account? Login'
                              : 'Don\'t have an account? Register',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
