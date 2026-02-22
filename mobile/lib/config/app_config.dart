enum Environment { dev, staging, prod }

class AppConfig {
  static Environment environment = Environment.dev;

  static String get apiBaseUrl {
    switch (environment) {
      case Environment.dev:
        return 'http://localhost:3000';
      case Environment.staging:
        return 'https://staging.tulip.app';
      case Environment.prod:
        return 'https://tulip-planner-261067158343.herokuapp.com';
    }
  }

  static String get appName => 'Tulip';

  static Duration get tokenRefreshThreshold => Duration(minutes: 5);

  static Duration get cacheExpiration => Duration(hours: 24);

  static void setEnvironment(Environment env) {
    environment = env;
  }
}
