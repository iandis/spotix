import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

enum AuthStatus { authorized, authorizing, unauthorized }

@JsonSerializable()
class SpotifyAuthorizationState with EquatableMixin {
  const SpotifyAuthorizationState({
    required this.status,
    required this.token,
  });

  static const SpotifyAuthorizationState defaultValue =
      SpotifyAuthorizationState(status: AuthStatus.unauthorized, token: null);

  factory SpotifyAuthorizationState.fromJson(Map<dynamic, dynamic> json) {
    return SpotifyAuthorizationState(
      status: AuthStatus.values.firstWhere(
        (AuthStatus status) => status.index == json['status'],
        orElse: () => AuthStatus.unauthorized,
      ),
      token: json['token'] as String?,
    );
  }

  final AuthStatus status;

  final String? token;

  @override
  List<Object?> get props => <Object?>[status, token];
}
