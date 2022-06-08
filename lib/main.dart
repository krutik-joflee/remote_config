// import 'package:firebase_core/firebase_core.dart';
// ignore_for_file: prefer_equal_for_default_values, use_key_in_widget_constructors, avoid_print

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:remote_config/firebase_options.dart';

Future<FirebaseRemoteConfig> setupRemoteConfig() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;
  await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval: const Duration(hours: 1)));
  await remoteConfig.setDefaults({
    'welcome': 'default welcome',
    'hello': 'default hello',
  });
  RemoteConfigValue(null, ValueSource.valueStatic);
  return remoteConfig;
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
      title: 'Remote Config Example',
      home: FutureBuilder<FirebaseRemoteConfig>(
        future: setupRemoteConfig(),
        builder: (BuildContext context,
            AsyncSnapshot<FirebaseRemoteConfig> snapshot) {
          return snapshot.hasData
              ? WelcomeWidget(remoteConfig: snapshot.requireData)
              : Container();
        },
      )));
}

class WelcomeWidget extends StatelessWidget {
  const WelcomeWidget({Key? key, required this.remoteConfig}) : super(key: key);
  final FirebaseRemoteConfig remoteConfig;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Remote Config Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '(${remoteConfig.getString('welcome')})',
            ),
            const SizedBox(
              height: 20,
            ),
            Text('(${remoteConfig.getValue('welcome').source})'),
            Text('(${remoteConfig.lastFetchTime})'),
            Text('(${remoteConfig.lastFetchStatus})')
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            await remoteConfig.setConfigSettings(RemoteConfigSettings(
                fetchTimeout: const Duration(seconds: 10),
                minimumFetchInterval: Duration.zero));
            await remoteConfig.fetchAndActivate();
          } on PlatformException catch (exception) {
            print(exception);
          } catch (exception) {
            print(
                'Unable to fetch remote config. Cached or default values will be '
                'used');
          }
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
