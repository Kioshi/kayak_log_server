import '../kayak_log_server.dart';
import 'kayak_trip_data.dart';
import 'user.dart';

class KayakTrip extends ManagedObject<_KayakTrip>
    implements _KayakTrip {
}

class _KayakTrip
{
  @primaryKey
  int id;

  @Column(omitByDefault: false)
  String guid;

  @Column(omitByDefault: false)
  String name;

  @Column(omitByDefault: true)
  String description;

  @Column(omitByDefault: false)
  DateTime timeCreated;

  @Column(omitByDefault: true)
  int duration;

  @Column(omitByDefault: true)
  bool public;

  @Relate(Symbol('trips'), onDelete: DeleteRule.cascade, isRequired: true)
  User user;

  ManagedSet<KayakTripData> path;

}
