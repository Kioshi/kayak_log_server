import '../kayak_log_server.dart';
import '../model/kayak_trip.dart';
import '../model/user.dart';

class TripController extends ResourceController {
  TripController(this.context, this.authServer);

  final ManagedContext context;
  final AuthServer authServer;

  @Operation.get()
  Future<Response> getTrips() async {
    final Query<User> userQuery = Query<User>(context)..where((u) => u.id).equalTo(request.authorization.ownerID);
    final u = await userQuery.fetchOne();
    if (u == null) {
      return Response.notFound();
    }

    return Response.ok(u.trips);
  }

  @Operation.get("id")
  Future<Response> getTrip(@Bind.path("id") int id) async {
    final query = Query<KayakTrip>(context)
      ..where((o) => o.id).equalTo(id);
    final t = await query.fetchOne();
    if (t == null) {
      return Response.notFound();
    }

    if (request.authorization.ownerID != t.user.id || !t.public) {
      return Response.unauthorized();
    }

    return Response.ok(t);
  }

  @Operation.post()
  Future<Response> updateTrip(@Bind.body() KayakTrip trip) async {

    final query = Query<KayakTrip>(context)..values = trip;

    final t = await query.insert();
    if (t == null)
    {
      return Response.badRequest();
    }

    return Response.ok(null);
  }

  @Operation.put()
  Future<Response> createTrip(@Bind.body() KayakTrip trip) async {


    final query = Query<KayakTrip>(context)..values = trip;

    final t = await query.insert();
    if (t == null)
    {
      return Response.badRequest();
    }

    final Query<User> userQuery = Query<User>(context)..where((u) => u.id).equalTo(request.authorization.ownerID)
      ..join(set: (user) => user.trips);
    final u = await userQuery.fetchOne();
    if (u == null)
    {
      return Response.badRequest();
    }

    u.trips ??= ManagedSet();
    u.trips.add(trip);
    final Query<User> updateQuery = Query<User>(context)..values = u;
    final result = await updateQuery.update();
    if (result == null)
    {
      return Response.badRequest();
    }

    return Response.ok(null);
  }

  @Operation.delete("id")
  Future<Response> deleteTrip(@Bind.path("id") int id) async {
    if (request.authorization.ownerID != id) {
      return Response.unauthorized();
    }

    final query = Query<KayakTrip>(context)
      ..where((o) => o.id).equalTo(id);
    await query.delete();

    return Response.ok(null);
  }
}
