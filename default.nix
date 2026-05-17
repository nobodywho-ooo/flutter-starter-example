{
  lib,
  flutter,
  patchelf,
  vulkan-loader,
  nobodywho_flutter_rust,
}:

flutter.buildFlutterApplication rec {
  pname = "flutter_starter_example";
  version = "0.1.0";

  src = lib.fileset.toSource {
    root = ./.;
    fileset = lib.fileset.unions [
      ./lib
      ./pubspec.yaml
      ./pubspec.lock
      ./linux
      ./assets
      ./test
      ./analysis_options.yaml
    ];
  };

  env.NOBODYWHO_FLUTTER_LIB_PATH = "${nobodywho_flutter_rust.lib}/lib/libnobodywho_flutter.so";

  # Force offline mode to prevent network access attempts
  PUB_OFFLINE = true;
  FLUTTER_OFFLINE = true;

  # Additional dart/flutter build flags
  pubGetFlags = "--offline";

  nativeBuildInputs = [ patchelf ];

  # see: https://github.com/fzyzcjy/flutter_rust_bridge/issues/2527
  fixupPhase = ''
    bundleLib=$out/app/${pname}/lib

    # The nobodywho .so is a dangling symlink — replace it with the real file so we can patchelf it
    rm $bundleLib/libnobodywho_flutter.so
    cp ${nobodywho_flutter_rust.lib}/lib/libnobodywho_flutter.so $bundleLib/libnobodywho_flutter.so
    chmod +w $bundleLib/libnobodywho_flutter.so

    patchelf --add-rpath '$ORIGIN' $bundleLib/libflutter_linux_gtk.so
    patchelf --add-rpath '${vulkan-loader}/lib' $bundleLib/libnobodywho_flutter.so
  '';

  # read pubspec using IFD
  autoPubspecLock = ./pubspec.lock;
}
