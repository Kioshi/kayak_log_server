import '../kayak_log_server.dart';
import 'kayak_trip.dart';

class KayakTripData extends ManagedObject<_KayakTripData>
    implements _KayakTripData {
}

class _KayakTripData
{
  @primaryKey
  int id;

  @Column(omitByDefault: false)
  int pos;

  @Column(omitByDefault: false)
  double lat;

  @Column(omitByDefault: false)
  double long;

  @Relate(Symbol('path'), onDelete: DeleteRule.cascade, isRequired: true)
  KayakTrip trip;

}
