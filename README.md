# sikantin

A new Flutter project.

## Getting Started

- ## Edit The pubspec.yml
name: sikantin
description: "Aplikasi SiKantin menggunakan Supabase, Hive, GetX."
publish_to: 'none'

version: 1.0.0+1

environment:
  sdk: ^3.6.1

dependencies:
  flutter:
    sdk: flutter

  # STATE MANAGEMENT
  get: ^4.6.6

  # SUPABASE AUTH + DATABASE
  supabase_flutter: ^2.3.4

  # LOCAL STORAGE
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  shared_preferences: ^2.2.2

  # FILE PATH & UTIL
  path_provider: ^2.1.3

  # SUPPORT LIBRARIES
  uuid: ^4.2.1
  dio: ^5.4.0

  # ICON
  cupertino_icons: ^1.0.8


dev_dependencies:
  flutter_test:
    sdk: flutter

  flutter_lints: ^5.0.0

  # Hive Code Generator
  hive_generator: ^2.0.1
  build_runner: ^2.4.6


flutter:
  uses-material-design: true

## RUN "flutter pub get"
