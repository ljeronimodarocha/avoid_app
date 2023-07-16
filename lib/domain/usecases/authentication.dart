import 'package:equatable/equatable.dart';

import '../../domain/entities/entities.dart';

abstract class Authentication {
  Future<AccountEntity> auth(AuthenticationParams params);
}

class AuthenticationParams extends Equatable {
  final String userName;
  final String secret;

  AuthenticationParams({required this.userName, required this.secret});

  @override
  List get props => [userName, secret];
}
