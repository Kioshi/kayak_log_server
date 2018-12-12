import 'dart:async';

import 'package:aqueduct/aqueduct.dart';   

class Migration5 extends Migration { 
  @override
  Future upgrade() async {
   database.addColumn("_KayakTrip", SchemaColumn("publiclyAvailable", ManagedPropertyType.boolean, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: false, isUnique: false), unencodedInitialValue: "false");

database.deleteColumn("_KayakTrip", "public");


  }
  
  @override
  Future downgrade() async {}
  
  @override
  Future seed() async {}
}
    