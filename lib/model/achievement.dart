import '../kayak_log_server.dart';
import 'kayak_trip_data.dart';

class Achievement extends ManagedObject<_Achievement>
    implements _Achievement {
}

class _Achievement
{
  @primaryKey
  int id;

  @Column(omitByDefault: true)
  String name;

  @Column(omitByDefault: true)
  String desc;
}
