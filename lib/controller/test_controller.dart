import '../kayak_log_server.dart';
import '../model/user.dart';

class TestController extends ResourceController {
  TestController(this.context);

  final ManagedContext context;

  @Operation.post()
  Future<Response> testUser(@Bind.body() User user) async {

    return Response.ok(user);
  }
}