import 'package:equatable/equatable.dart';

class AppUser extends Equatable {
  final String username;
  final String displayName;

  const AppUser({
    required this.username,
    required this.displayName,
  });

  @override
  List<Object?> get props => [username, displayName];
}
