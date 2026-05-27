class AuthToken {
  static String? _token;

  static String? get token => _token;

  static void set(String token) => _token = token;

  static void clear() => _token = null;

  static bool get isSet => _token != null;
}
