import '../model/user.dart';
import '../kayak_log_server.dart';

class IdentityController extends ResourceController {
  IdentityController(this.context);

  final ManagedContext context;

  @Operation.get()
  Future<Response> getIdentity() async {
    final q = Query<User>(context)
      ..where((o) => o.id).equalTo(request.authorization.ownerID);

    final join = q.join(set: (u)=>u.trips);
    join.returningProperties((t) => [t.id, t.guid, t.description, t.name, t.publiclyAvailable, t.duration, t.timeCreated]);
    join.join(set: (t) => t.path);//.returningProperties((p) => [p.pos, p.lat, p.long]);
    q.join(set: (u)=>u.achievements).returningProperties((a) => [a.id, a.guid, a.achievementId, a.extraInfo, a.acquiredTime]);

    final u = await q.fetchOne();
    if (u == null) {
      return Response.notFound();
    }

    return Response.ok(u);
  }
}
