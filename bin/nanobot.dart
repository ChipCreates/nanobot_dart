import 'package:nanobot_dart/src/cli/commands.dart';

Future<void> main(List<String> args) async {
  await NanobotCommandRunner().run(args);
}
