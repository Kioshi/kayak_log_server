import '../kayak_log_server.dart';
import 'user.dart';

class AcquiredAchievement extends ManagedObject<_AcquiredAchievement>
    implements _AcquiredAchievement {
}

class _AcquiredAchievement
{
  @primaryKey
  int id;

  @Column(omitByDefault: true)
  int achievementId;

  @Column(omitByDefault: true)
  DateTime acquiredTime;

  @Column(omitByDefault: true)
  String extraInfo;

  @Relate(Symbol('achievements'), onDelete: DeleteRule.cascade, isRequired: true)
  User user;
}
