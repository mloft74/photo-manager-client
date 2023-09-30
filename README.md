# Photo Manager Client

An app to upload and manage photos on a [server](https://github.com/mloft74/photo-manager-server).

## Installing

Currently, only Android is supported.

### Android

Check out the [releases](https://github.com/mloft74/photo-manager-client/releases) page for prebuilt APKs.

If you want to build an APK yourself, run these commands:
- `flutter pub get`: grabs dependencies from [pub.dev](https://pub.dev)
- `dart run build_runner build --delete-conflicting-outputs`: runs code generation that packages like [Riverpod](https://pub.dev/packages/flutter_riverpod) and [Freezed](https://pub.dev/packages/freezed) use
- `flutter build apk --release`: builds the APK in release mode

## Guide

When you first install the app, you'll have to configure a server that will host the images.

![The app showing no server is selected.](docs/images/no_server_is_selected.png)
![The app showing no servers are configured.](docs/images/you_have_no_servers.png)

When configuring a server, make sure to include http or https. If you are using the server linked at the top of the readme, make sure to include the port 3000.

![The app showing the Manage Server screen.](docs/images/manage_server.png)

Once you have configured a server, you can then add images.

![The app showing that the server has no images.](docs/images/no_images_found.png)
![The app showing the Upload Photo page.](docs/images/upload_photo.png)

You can tap on an image to manage it.

![The app showing the main grid of photos.](docs/images/photo_view.png)
![The app showing the Manage Photo page.](docs/images/manage_photo.png)

The photos used in this guide come from the Library of Congress' [Gardens collection](https://www.loc.gov/free-to-use/gardens/).

## UI layout

The basic idea behind the layout of the app is to make it easily usable with a single hand. When using a phone with one hand, your thumb resides near the bottom of the phone, so all operations are placed at the bottom to accomodate this.
