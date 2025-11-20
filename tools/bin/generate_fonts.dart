import '../font_generator.dart';

Future<void> main() async {
  print('Starting font asset generation...');
  await FontGenerator.copyFonts();
  print('Font asset generation finished.');
}
