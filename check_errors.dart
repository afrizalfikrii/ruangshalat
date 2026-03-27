import 'dart:io';

void main() async {
  final result = await Process.run('dart', ['analyze', 'lib/features/guide/guide_screen.dart']);
  print('--- ANAYLYZE OUTPUT START ---');
  print(result.stdout);
  print(result.stderr);
  print('--- ANAYLYZE OUTPUT END ---');
  
  if (result.exitCode == 0) {
    print('NO ERRORS FOUND.');
  } else {
    print('ERRORS EXIST. EXIT CODE: \${result.exitCode}');
  }
}
