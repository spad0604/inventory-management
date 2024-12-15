import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:la_tech/home_page/controllers/home_page_controller/home_page_controller.dart';
import 'package:la_tech/home_page/views/home_page_views/home_page_view.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/auth_io.dart';

import 'env/app_route.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyBxuEflztZGUb7VAGyXbxGAX-NWbAjo1kQ',
      appId: '1:43603538044:android:8abc3962a9b845059c59f9',
      messagingSenderId: '43603538044',
      projectId: 'inventory-management-e4022',
      storageBucket: 'inventory-management-e4022.firebasestorage.app',
      databaseURL:
          'https://inventory-management-e4022-default-rtdb.firebaseio.com',
    ),
  );
  Get.put(HomePageController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData(fontFamily: 'Poppins'),
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoute.HOME_PAGE,
      getPages: AppRoute.generateGetPages,
      home: const HomePageView(),
    );
  }
}

const _storage = FlutterSecureStorage();
const _scopes = [drive.DriveApi.driveFileScope];

Future<AuthClient> authenticate() async {
  final clientId = ClientId(
    "952322245424-d47h4s9c41d42b1c9vttoda5oho8ahk7.apps.googleusercontent.com",
    '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',
  );

  final storedToken = await _storage.read(key: "google_auth_token");
  if (storedToken != null) {
    final tokenData = jsonDecode(storedToken);
    final credentials = AccessCredentials(
      AccessToken(tokenData['type'], tokenData['data'],
          DateTime.parse(tokenData['expiry'])),
      tokenData['refreshToken'],
      _scopes,
    );
    return authenticatedClient(http.Client(), credentials);
  }

  final authClient = await clientViaUserConsent(clientId, _scopes, (url) {
    print("Hãy mở URL sau và đăng nhập: $url");
  });

  final credentials = authClient.credentials;
  final tokenData = {
    "type": credentials.accessToken.type,
    "data": credentials.accessToken.data,
    "expiry": credentials.accessToken.expiry.toIso8601String(),
    "refreshToken": credentials.refreshToken,
  };
  await _storage.write(key: "google_auth_token", value: jsonEncode(tokenData));

  return authClient;
}

Future<drive.DriveApi> getDriveApi() async {
  final client = await authenticate();
  return drive.DriveApi(client);
}

Future<void> uploadFile(String filePath) async {
  final driveApi = await getDriveApi();

  final file = drive.File()..name = 'example.jpg';
  final fileContent =
      await http.ByteStream.fromBytes(await File(filePath).readAsBytes());

  final uploadedFile = await driveApi.files.create(
    file,
    uploadMedia: drive.Media(fileContent, File(filePath).lengthSync()),
  );

  print("File uploaded. File ID: ${uploadedFile.id}");
}
