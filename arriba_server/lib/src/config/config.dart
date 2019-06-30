library arriba_server.src.config;

import 'package:angel_configuration/angel_configuration.dart';
import 'package:angel_framework/angel_framework.dart';
import 'package:angel_jael/angel_jael.dart';
import 'package:file/file.dart';
import 'package:mongo_dart/mongo_dart.dart';

import 'plugins/plugins.dart' as plugins;

/// This is a perfect place to include configuration and load plug-ins.
AngelConfigurer configureServer(FileSystem fileSystem) {
  return (Angel app) async {
    // Load configuration from the `config/` directory.
    //
    // See: https://github.com/angel-dart/configuration
    await app.configure(configuration(fileSystem));

    // Configure our application to render Jael templates from the `views/` directory.
    //
    // See: https://github.com/angel-dart/jael
    await app.configure(jael(fileSystem.directory('views')));

    // MongoDB setup
    var db = Db(app.configuration['mongo_db'] as String);
    await db.open();
    app
      ..container.registerSingleton(db)
      ..shutdownHooks.add((_) => db.close());

    // Apply another plug-ins, i.e. ones that *you* have written.
    //
    // Typically, the plugins in `lib/src/config/plugins/plugins.dart` are plug-ins
    // that add functionality specific to your application.
    //
    // If you write a plug-in that you plan to use again, or are
    // using one created by the community, include it in
    // `lib/src/config/config.dart`.
    await plugins.configureServer(app);
  };
}
