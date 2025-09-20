class User {
  final int id;
  final String email;
  final String name;
  final String surname;
  final String? token;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.surname,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      surname: json['surname'] ?? '',
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'email': email, 'name': name, 'surname': surname, 'token': token};
  }
}

class RegisterRequest {
  final String email;
  final String name;
  final String surname;
  final String password;
  final String passwordConfirmation;
  final String? onesignalId;

  RegisterRequest({
    required this.email,
    required this.name,
    required this.surname,
    required this.password,
    required this.passwordConfirmation,
    this.onesignalId,
  });

  Map<String, dynamic> toJson() {
    final data = {
      'email': email,
      'name': name,
      'surname': surname,
      'password': password,
      'password_confirmation': passwordConfirmation,
    };

    if (onesignalId != null) {
      data['onesignal_id'] = onesignalId!;
    }

    return data;
  }
}

class LoginRequest {
  final String email;
  final String password;
  final String? onesignalId;

  LoginRequest({required this.email, required this.password, this.onesignalId});

  Map<String, dynamic> toJson() {
    final data = {'email': email, 'password': password};

    if (onesignalId != null) {
      data['onesignal_id'] = onesignalId!;
    }

    return data;
  }
}
