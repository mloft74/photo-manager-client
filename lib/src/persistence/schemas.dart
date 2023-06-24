import 'package:isar/isar.dart';
import 'package:photo_manager_client/src/persistence/server/models/selected_server_db.dart';
import 'package:photo_manager_client/src/persistence/server/models/server_db.dart';

const isarSchemas = <CollectionSchema<dynamic>>[
  ServerDBSchema,
  SelectedServerDBSchema,
];
