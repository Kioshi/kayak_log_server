import '../kayak_log_server.dart';
import 'kayak_trip.dart';

class KayakTripData extends ManagedObject<_KayakTripData>
    implements _KayakTripData {
}

class _KayakTripData
{
  @primaryKey
  int id;

  @Column(omitByDefault: true)
  double lat;

  @Column(omitByDefault: true)
  double long;

  @Relate(Symbol('path'), onDelete: DeleteRule.cascade, isRequired: true)
  KayakTrip trip;

}
