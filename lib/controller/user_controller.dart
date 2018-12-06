import 'package:kayak_log_server/model/acquired_achievement.dart';
import 'package:kayak_log_server/model/kayak_trip.dart';
import 'package:kayak_log_server/model/kayak_trip_data.dart';

import '../kayak_log_server.dart';
import '../model/user.dart';

class UserController extends ResourceController {
  UserController(this.context, this.authServer);

  final ManagedContext context;
  final AuthServer authServer;

  @Operation.get()
  Future<Response> getUsers() async {
    if (!request.authorization.isAuthorizedForScope("admin:users")) {
      return Response.unauthorized();
    }

    final query = Query<User>(context);
    final join = query.join(set: (u)=>u.trips);
    join.returningProperties((t) => [t.id, t.guid, t.description, t.name, t.publiclyAvailable, t.duration, t.timeCreated]);
    join.join(set: (t) => t.path);//.returningProperties((p) => [p.pos, p.lat, p.long]);
    query.join(set: (u)=>u.achievements).returningProperties((a) => [a.id, a.guid, a.achievementId, a.extraInfo, a.acquiredTime]);
    final u = await query.fetch();
    if (u == null) {
      return Response.notFound();
    }

    return Response.ok(u);
  }

  @Operation.get("id")
  Future<Response> getUser(@Bind.path("id") int id) async {
    if (request.authorization.ownerID != id &&
        !request.authorization.isAuthorizedForScope("admin:users")) {
      return Response.unauthorized();
    }

    final query = Query<User>(context)
      ..where((o) => o.id).equalTo(id);
    
      final join = query.join(set: (u)=>u.trips);
      join.returningProperties((t) => [t.id, t.guid, t.description, t.name, t.publiclyAvailable, t.duration, t.timeCreated]);
      join.join(set: (t) => t.path);//.returningProperties((p) => [p.pos, p.lat, p.long]);
      query.join(set: (u)=>u.achievements).returningProperties((a) => [a.id, a.guid, a.achievementId, a.extraInfo, a.acquiredTime]);
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

    final u = await query.fetchOne();

    {
      final q = Query<KayakTrip>(context)
        ..where((t)=>t.guid).oneOf(user.trips.map((t)=>t.guid));

      //TODO update trips
      final rows = await q.fetch();
      user.trips.removeWhere((t) => rows.map((t)=>t.guid).contains(t.guid));
    }
    {
      final q = Query<AcquiredAchievement>(context)
        ..where((a) => a.guid).oneOf(user.achievements.map((a) => a.guid));

      final rows = await q.fetch();
      user.achievements.removeWhere((a) => rows.map((a)=>a.guid).contains(a.guid));
    }

    await context.transaction((transaction) async {
      await Future.forEach(user.trips, (KayakTrip trip) async {
        trip.id = null;
        final q = Query<KayakTrip>(transaction)
          ..values = trip
          ..values.user = u;

        final res = await q.insert();
        await Future.forEach(trip.path, (KayakTripData path) async {
          path.id = null;
          final q = Query<KayakTripData>(transaction)
            ..values = path
            ..values.trip = res;
          return await q.insert();
        });
        return res;
      });

      await Future.forEach(user.achievements, (AcquiredAchievement achiev) async {
        achiev.id = null;
        final q = Query<AcquiredAchievement>(transaction)
          ..values = achiev
          ..values.user = u;

        return await q.insert();
      });
    });

    return Response.ok(null);
  }

  @Operation.delete("id")
  Future<Response> deleteUser(@Bind.path("id") int id) async {
    if (request.authorization.ownerID != id ||
        !request.authorization.isAuthorizedForScope("admin:deleteUser")) {
      return Response.unauthorized();
    }

    final query = Query<User>(context)
      ..where((o) => o.id).equalTo(id);
    await authServer.revokeAllGrantsForResourceOwner(id);
    await query.delete();

    return Response.ok(null);
  }
}
