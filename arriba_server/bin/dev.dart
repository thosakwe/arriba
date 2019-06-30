import 'dart:io';
import 'package:arriba_server/src/pretty_logging.dart';
import 'package:arriba_server/arriba_server.dart';
import 'package:angel_container/mirrors.dart';
import 'package:angel_framework/angel_framework.dart';
import 'package:angel_hot/angel_hot.dart';
import 'package:logging/logging.dart';

main() async {
  // Watch the config/ and web/ directories for changes, and hot-reload the server.
  var hot = new HotReloader(() async {
    var app = new Angel(reflector: MirrorsReflector());
    await app.configure(configureServer);
    hierarchicalLoggingEnabled = true;
    app.logger = new Logger.detached('arriba_server')
      ..onRecord.listen(prettyLog);
    return app;
  }, [
    new Directory('config'),
    new Directory('lib'),
  ]);

  var server = await hot.startServer('127.0.0.1', 3000);
  print(
      'arriba_server server listening at http://${server.address.address}:${server.port}');
}
