import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqflite/sqflite.dart';

part 'db_pod.g.dart';

@riverpod
Database db(DbRef ref) => throw UnimplementedError(
      'Ensure the db provider is overridden in the provider scope',
    );
