import '../kayak_log_server.dart';
import '../model/kayak_trip.dart';
import '../model/user.dart';

class TripController extends ResourceController {
  TripController(this.context, this.authServer);

  final ManagedContext context;
  final AuthServer authServer;

  @Operation.get()
  Future<Response> getTrips() async {
    final query = Query<User>(context);
    final u = await query.fetchOne();
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

    if (request.authorization.ownerID != t.creatorId || !t.public) {
      return Response.unauthorized();
    }

    return Response.ok(t);
  }

  @Operation.put("id")
  Future<Response> updateTrip(@Bind.path("id") int id, @Bind.body() KayakTrip trip) async {
    if (request.authorization.ownerID != trip.creatorId) {
      return Response.unauthorized();
    }

    final query = Query<KayakTrip>(context)
      ..values = trip
      ..where((o) => o.id).equalTo(id);

    final t = await query.updateOne();
    if (t == null) {
      return Response.notFound();
    }

    return Response.ok(t);
  }

  @Operation.post()
  Future<Response> createTrip(@Bind.body() KayakTrip trip) async {

    trip.creatorId = request.authorization.ownerID;

    final query = Query<KayakTrip>(context)..values = trip;

    final t = await query.insert();
    if (t == null)
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
