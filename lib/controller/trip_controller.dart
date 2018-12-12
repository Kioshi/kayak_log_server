import 'package:kayak_log_server/model/kayak_trip_data.dart';
import 'package:kayak_log_server/model/user.dart';

import '../kayak_log_server.dart';
import '../model/kayak_trip.dart';

class TripController extends ResourceController {
  TripController(this.context, this.authServer);

  final ManagedContext context;
  final AuthServer authServer;

  @Operation.get()
  Future<Response> getTrips() async {
    final Query<KayakTrip> q = Query<KayakTrip>(context)..where((t) => t.user.id).equalTo(request.authorization.ownerID)
      ..returningProperties((t) => [t.guid, t.timeCreated, t.name]);
    final trips = await q.fetch();
    if (trips == null) {
      return Response.notFound();
    }

    return Response.ok(trips);
  }

  @Operation.get("guid")
  Future<Response> getTrip(@Bind.path("guid") String guid) async {
    final query = Query<KayakTrip>(context)
      ..where((o) => o.guid).equalTo(guid)
      ..returningProperties((t) => [t.name, t.timeCreated, t.guid, t.duration, t.description, t.publiclyAvailable])
      ..join(set: (t) => t.path);

    final t = await query.fetchOne();
    if (t == null) {
      return Response.notFound();
    }

    if (request.authorization.ownerID != t.user.id || !t.publiclyAvailable) {
      return Response.unauthorized();
    }

    return Response.ok(t);
  }

  @Operation.post()
  Future<Response> updateTrip(@Bind.body() KayakTrip trip) async {
      trip.removePropertyFromBackingMap("id");
      final query = Query<KayakTrip>(context)
        ..where((t) => t.user.id).equalTo(request.authorization.ownerID)
        ..where((t) => t.guid).equalTo(trip.guid)
        ..values.name = trip.name
        ..values.description = trip.description
        ..values.publiclyAvailable = trip.publiclyAvailable;

      final t = await query.update();
      if (t == null) {
        return Response.badRequest();
      }

      return Response.ok(null);
  }

  @Operation.put()
  Future<Response> insertTrip(@Bind.body() KayakTrip trip) async {
    return await context.transaction<Response>((transaction) async {
      final uq = Query<User>(transaction)
        ..where((u) => u.id).equalTo(request.authorization.ownerID);
      final u = await uq.fetchOne();

      if (u == null) {
        return Response.badRequest();
      }

      trip.removePropertyFromBackingMap("id");
      final q = Query<KayakTrip>(transaction)
        ..values = trip
        ..values.user = u;

      final res = await q.insert();
      await Future.forEach(trip.path, (KayakTripData path) async {
        path.removePropertyFromBackingMap("id");
        final q = Query<KayakTripData>(transaction)
          ..values = path
          ..values.trip = res;
        return await q.insert();
      });

      return Response.ok(null);
    });
  }

  @Operation.delete("guid")
  Future<Response> deleteTrip(@Bind.path("guid") int id) async {

    final query = Query<KayakTrip>(context)
      ..where((t)=> t.user.id).equalTo(request.authorization.ownerID)
      ..where((o) => o.id).equalTo(id);
    await query.delete();

    return Response.ok(null);
  }
}
