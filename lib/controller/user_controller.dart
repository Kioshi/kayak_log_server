import 'package:kayak_log_server/model/acquired_achievement.dart';
import 'package:kayak_log_server/model/kayak_trip.dart';

import '../kayak_log_server.dart';
import '../model/user.dart';

class UserController extends ResourceController {
  UserController(this.context, this.authServer);

  final ManagedContext context;
  final AuthServer authServer;

  @Operation.get()
  Future<Response> getUsers() async {
    final query = Query<User>(context);
    final u = await query.fetch();
    if (u == null) {
      return Response.notFound();
    }

    return Response.ok(u);
  }

  @Operation.get("id")
  Future<Response> getUser(@Bind.path("id") int id) async {
    if (request.authorization.ownerID != id) {
      return Response.unauthorized();
      // Filter out stuff for non-owner of user
    }

    final query = Query<User>(context)
      ..where((o) => o.id).equalTo(id)
      ..join(set: (u)=>u.trips)
      ..join(set: (u)=>u.achievements);
    final u = await query.fetchOne();
    if (u == null) {
      return Response.notFound();
    }


    return Response.ok(u);
  }

  @Operation.post()
  Future<Response> updateUser(@Bind.body() User user) async {
    final query = Query<User>(context)
      ..values = user
      ..where((o) => o.id).equalTo(request.authorization.ownerID);

    {
      final q = Query<KayakTrip>(context)/*..where((t)=>t.user.id).equalTo(request.authorization.ownerID)*/
        ..where((t)=>t.guid).oneOf(user.trips.map((t)=>t.guid));

      final rows = await q.fetch();
      user.trips.removeWhere((t) => rows.map((t)=>t.guid).contains(t.guid));
    }
    {
      final q = Query<AcquiredAchievement>(
          context) /*..where((a)=>a.user.id).equalTo(request.authorization.ownerID)*/
        ..where((a) => a.guid).oneOf(user.achievements.map((a) => a.guid));

      final rows = await q.fetch();
      user.achievements.removeWhere((a) => rows.map((a)=>a.guid).contains(a.guid));
    }

    final u = await query.updateOne();
    if (u == null) {
      return Response.notFound();
    }

    return Response.ok(u);
  }

  @Operation.delete("id")
  Future<Response> deleteUser(@Bind.path("id") int id) async {
    if (request.authorization.ownerID != id) {
      return Response.unauthorized();
    }

    final query = Query<User>(context)
      ..where((o) => o.id).equalTo(id);
    await authServer.revokeAllGrantsForResourceOwner(id);
    await query.delete();

    return Response.ok(null);
  }
}
