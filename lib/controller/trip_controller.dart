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
      ..returningProperties((t) => [t.name, t.timeCreated, t.guid, t.duration, t.description, t.publiclyAvailable]);
    query..join(set: (t) => t.path);

    final t = await query.fetchOne();
    if (t == null) {
      return Response.notFound();
    }

    if (request.authorization.ownerID != t.user.id || !t.publiclyAvailable) {
      return Response.unauthorized();
    }

    return Response.ok(t);
  }

  @Operation.post("guid")
  Future<Response> updateTrip(@Bind.path("guid") String guid, @Bind.body() KayakTrip trip) async {

    trip.guid = guid;
    trip.id = null;
    final query = Query<KayakTrip>(context)
      ..where((t)=> t.user.id).equalTo(request.authorization.ownerID)
      ..where((t) => t.guid).equalTo(guid)
      ..values = trip;

    final t = await query.update();
    if (t == null)
    {
      return Response.badRequest();
    }

    return Response.ok(null);
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
