library arriba_server.src.routes;

import 'package:angel_auth/angel_auth.dart';
import 'package:angel_auth_oauth2/angel_auth_oauth2.dart';
import 'package:angel_cors/angel_cors.dart';
import 'package:angel_framework/angel_framework.dart';
import 'package:angel_mongo/angel_mongo.dart';
import 'package:angel_proxy/angel_proxy.dart';
import 'package:angel_static/angel_static.dart';
import 'package:angel_websocket/server.dart';
import 'package:arriba_server/src/models/user.dart';
import 'package:file/file.dart';
import 'package:googleapis/oauth2/v2.dart';
import 'package:http/io_client.dart' as http;
import 'package:kilobyte/kilobyte.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:path/path.dart' as p;

import 'controllers/controllers.dart' as controllers;

/// Put your app routes here!
///
/// See the wiki for information about routing, requests, and responses:
/// * https://github.com/angel-dart/angel/wiki/Basic-Routing
/// * https://github.com/angel-dart/angel/wiki/Requests-&-Responses
AngelConfigurer configureServer(FileSystem fs) {
  return (Angel app) async {
    var db = app.container.make<Db>();
    var uploadDir = fs.directory('uploads');
    await uploadDir.create(recursive: true);

    app.fallback(cors(CorsOptions(origin: '*')));

    // Typically, you want to mount controllers first, after any global middleware.
    await app.configure(controllers.configureServer);

    // Set up auth.
    var userDb = MongoService(db.collection('users'))
        .map(UserSerializer.fromMap, UserSerializer.toMap);
    var auth = AngelAuth<User>(
      allowCookie: false,
      allowTokenInQuery: true,
      jwtKey: app.configuration['jwt_secret'] as String,
      serializer: (user) => user.id,
      deserializer: (id) async {
        return await userDb.findOne({
          'query': where.eq(UserFields.id, id.toString())
        }).catchError((_) => throw AngelHttpException.notAuthenticated(
            message: 'No such user exists.'));
      },
    );

    // Google config
    auth.strategies['google'] = OAuth2Strategy<User>(
      ExternalAuthOptions.fromMap(app.configuration['google'] as Map),
      Uri.parse('https://accounts.google.com/o/oauth2/v2/auth'),
      Uri.parse('https://www.googleapis.com/oauth2/v4/token'),
      (client, req, res) async {
        var api = Oauth2Api(client);
        var user = await api.userinfo.v2.me.get();
        var params = {
          'query': {UserFields.googleId: user.id}
        };
        var existing = await userDb.findOne(params).catchError((_) => null);
        if (existing != null) {
          existing =
              existing.copyWith(name: user.name, avatarUrl: user.picture);
          return await userDb.modify(existing.id, existing);
        } else {
          return await userDb.create(User(
            googleId: user.id,
            name: user.name,
            avatarUrl: user.picture,
          ));
        }
      },
      (e, req, res) {
        app.logger.severe('Google auth error', e);
        res.write('Whoops! Something went wrong :(');
      },
    );

    // Auth routes
    app.fallback(auth.decodeJwt);
    app.get('/auth/google', auth.authenticate('google'));
    app.post('/auth/token', auth.reviveJwt);
    app.get(
      '/auth/google/callback',
      auth.authenticate(
        'google',
        AngelAuthOptions<User>(
          callback: confirmPopupAuthentication(),
        ),
      ),
    );

    // Set up WebSockets.
    var ws = AngelWebSocket(app);
    app.chain([requireAuthentication<User>()]).get('/ws', ws.handleRequest);
    await app.configure(ws.configureServer);

    void broadcast(String type, value) {
      ws.batchEvent(WebSocketEvent(eventName: type, data: value));
    }

    ws.onConnection.listen((sock) {
      // Tell everyone else when someone logs in.
      var user = sock.request.container.make<User>();
      broadcast('join', user.toJson());

      // Tell them about everyone else.
      for (var client in ws.clients) {
        sock.send('join', client.request.container.make<User>().toJson());
      }
    });

    ws.onDisconnection.listen((sock) {
      var user = sock.request.container.make<User>();
      broadcast('leave', user.toJson());
    });

    // Download
    app.get('/api/download/*', (req, res) async {
      var diff =
          p.relative(Uri.decodeComponent(req.uri.path), from: '/api/download');
      var file = uploadDir.childFile(diff);
      await res.download(file);
    });

    app.get(
      '/api/me',
      chain([
        requireAuthentication<User>(),
        (req, res) => req.container.make<User>(),
      ]),
    );

    // Upload route.
    app.post(
        '/api/upload',
        chain([
          requireAuthentication<User>(),
          (req, res) async {
            var user = req.container.make<User>();
            await req.parseBody();
            if (req.uploadedFiles.isEmpty)
              throw AngelHttpException.badRequest(
                  message: 'Must upload a file.');
            var userFile = req.uploadedFiles.first;
            var file =
                uploadDir.childFile('${user.googleId}_${userFile.filename}');
            await userFile.data.pipe(file.openWrite());
            var stat = await file.stat();
            broadcast('upload', {
              'user': user.toJson(),
              'filename': userFile.filename,
              'mime_type': userFile.contentType?.toString(),
              'size': Size(bytes: stat.size).toString(),
              'url': p.join('/api', 'download', p.basename(file.path)),
            });
            await res.close();
          },
        ]));

    // Proxy over Parcel in dev.
    if (!app.environment.isProduction) {
      var proxy = Proxy(http.IOClient(), Uri.parse('http://localhost:1234'));
      app
        ..fallback(proxy.handleRequest)
        ..shutdownHooks.add((_) => proxy.close());
    }

    // Mount static server at web in development.
    // The `CachingVirtualDirectory` variant of `VirtualDirectory` also sends `Cache-Control` headers.
    //
    // In production, however, prefer serving static files through NGINX or a
    // similar reverse proxy.
    //
    // Read the following two sources for documentation:
    // * https://medium.com/the-angel-framework/serving-static-files-with-the-angel-framework-2ddc7a2b84ae
    // * https://github.com/angel-dart/static
    if (app.environment.isProduction) {
      var vDir = VirtualDirectory(
        app,
        fs,
        source: fs.directory('../arriba_web/dist'),
      );
      app.fallback(vDir.handleRequest);
    }

    // Throw a 404 if no route matched the request.
    app.fallback((req, res) => throw AngelHttpException.notFound());
  };
}
