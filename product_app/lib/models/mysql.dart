import 'package:mysql1/mysql1.dart';

class Mysql {
  static String host = 'localhost';
  static int port = 3306;
  static String user = 'root';
  static String password = '1234';
  static String db = 'product_app_db';

 

  Future<MySqlConnection> connect() async {
    return await MySqlConnection.connect(ConnectionSettings(
      host: host,
      port: port,
      user: user,
      password: password,
      db: db,
    ));
  }
}