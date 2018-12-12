import 'package:kayak_log_server/model/acquired_achievement.dart';
import 'package:kayak_log_server/model/kayak_trip_data.dart';
import 'package:kayak_log_server/model/user.dart';

import '../kayak_log_server.dart';
import '../model/kayak_trip.dart';

class AchievementsController extends ResourceController {
  AchievementsController(this.context, this.authServer);

  final ManagedContext context;
  final AuthServer authServer;

  @Operation.put()
  Future<Response> insertAchievement(@Bind.body() AcquiredAchievement achiev) async {

      final uq = Query<User>(context)..where((u) => u.id).equalTo(request.authorization.ownerID);
      final u = await uq.fetchOne();

      if (u == null)
      {
       return Response.badRequest();
      }

      achiev.removePropertyFromBackingMap("id");
      final q = Query<AcquiredAchievement>(context)
        ..values = achiev
        ..values.user = u;

      final res = await q.insert();
      if (res == null)
      {
        return Response.badRequest();
      }

      return Response.ok(null);
  }
}
