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
    final query = Query<User>(context)
      ..where((o) => o.id).equalTo(id);
    final u = await query.fetchOne();
    if (u == null) {
      return Response.notFound();
    }

    if (request.authorization.ownerID != id) {
      // Filter out stuff for non-owner of user
    }

    return Response.ok(u);
  }

  @Operation.put()
  Future<Response> updateUser(@Bind.body() User user) async {
    if (request.authorization.ownerID != user.id) {
      return Response.unauthorized();
    }

    final query = Query<User>(context)
      ..values = user
      ..where((o) => o.id).equalTo(user.id);

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
