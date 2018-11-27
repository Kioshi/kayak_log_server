import 'dart:async';

import 'package:aqueduct/aqueduct.dart';   

class Migration3 extends Migration { 
  @override
  Future upgrade() async {
   database.addColumn("_KayakTrip", SchemaColumn("guid", ManagedPropertyType.string, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: false, isUnique: false), unencodedInitialValue: "123");

database.deleteColumn("_KayakTrip", "creatorId");

database.addColumn("_AcquiredAchievement", SchemaColumn("guid", ManagedPropertyType.string, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: false, isUnique: false), unencodedInitialValue: "123");



  }
  
  @override
  Future downgrade() async {}
  
  @override
  Future seed() async {}
}
    