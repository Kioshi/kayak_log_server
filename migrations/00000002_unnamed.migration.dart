import 'dart:async';

import 'package:aqueduct/aqueduct.dart';   

class Migration2 extends Migration { 
  @override
  Future upgrade() async {
   database.createTable(SchemaTable("_KayakTrip", [
SchemaColumn("id", ManagedPropertyType.bigInteger, isPrimaryKey: true, autoincrement: true, isIndexed: false, isNullable: false, isUnique: false),
SchemaColumn("creatorId", ManagedPropertyType.integer, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: false, isUnique: false),
SchemaColumn("name", ManagedPropertyType.string, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: false, isUnique: false),
SchemaColumn("description", ManagedPropertyType.string, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: false, isUnique: false),
SchemaColumn("timeCreated", ManagedPropertyType.datetime, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: false, isUnique: false),
SchemaColumn("duration", ManagedPropertyType.integer, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: false, isUnique: false),
SchemaColumn("public", ManagedPropertyType.boolean, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: false, isUnique: false),
SchemaColumn.relationship("user", ManagedPropertyType.bigInteger, relatedTableName: "_User", relatedColumnName: "id", rule: DeleteRule.cascade, isNullable: false, isUnique: false),
],
));

database.createTable(SchemaTable("_AcquiredAchievement", [
SchemaColumn("id", ManagedPropertyType.bigInteger, isPrimaryKey: true, autoincrement: true, isIndexed: false, isNullable: false, isUnique: false),
SchemaColumn("achievementId", ManagedPropertyType.integer, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: false, isUnique: false),
SchemaColumn("acquiredTime", ManagedPropertyType.datetime, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: false, isUnique: false),
SchemaColumn("extraInfo", ManagedPropertyType.string, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: false, isUnique: false),
SchemaColumn.relationship("user", ManagedPropertyType.bigInteger, relatedTableName: "_User", relatedColumnName: "id", rule: DeleteRule.cascade, isNullable: false, isUnique: false),
],
));

database.createTable(SchemaTable("_KayakTripData", [
SchemaColumn("id", ManagedPropertyType.bigInteger, isPrimaryKey: true, autoincrement: true, isIndexed: false, isNullable: false, isUnique: false),
SchemaColumn("lat", ManagedPropertyType.doublePrecision, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: false, isUnique: false),
SchemaColumn("long", ManagedPropertyType.doublePrecision, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: false, isUnique: false),
SchemaColumn.relationship("trip", ManagedPropertyType.bigInteger, relatedTableName: "_KayakTrip", relatedColumnName: "id", rule: DeleteRule.cascade, isNullable: false, isUnique: false),
],
));


  }
  
  @override
  Future downgrade() async {}
  
  @override
  Future seed() async {}
}
    