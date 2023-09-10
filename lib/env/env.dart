import 'package:envied/envied.dart';

// part 'env.g.dart';

@Envied(path: '.env', obfuscate: true)
abstract class Env {
  // @EnviedField(varName: 'NOTIFICATIONPRIVATEKEY')
  // static final String notificationPrivateKey = _Env.notificationPrivateKey;
  // @EnviedField(varName: 'NOTIFICATIONCLIENTEMAIL')
  // static final String notificationClientEmail = _Env.notificationClientEmail;
  // @EnviedField(varName: 'PRIVATEKEYID')
  // static final String notificationClientId = _Env.notificationClientId;
  // @EnviedField(varName: 'CLIENTID')
  // static final String notificationPrivateKeyId = _Env.notificationPrivateKeyId;
}
