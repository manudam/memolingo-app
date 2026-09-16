import 'dart:async';
import 'dart:io';

const _outputDirOption = '--output-dir=';
const _defaultOutputDir = 'build/marketing/ios_listing';

const _captures = <({String name, String screen})>[
  (name: '01-practice.png', screen: 'listing-practice'),
  (name: '02-game.png', screen: 'listing-game'),
  (name: '03-result.png', screen: 'listing-result'),
  (name: '04-library.png', screen: 'listing-library'),
  (name: '05-category-words.png', screen: 'listing-category-words'),
  (name: '06-stats.png', screen: 'listing-stats'),
];

const _targets = <_CaptureTarget>[
  _CaptureTarget(
    folderName: 'iphone_67',
    label: 'iPhone 6.7"',
    canvasWidth: 428,
    canvasHeight: 926,
    deviceWidth: 428,
    deviceHeight: 926,
    pixelRatio: 3,
  ),
  _CaptureTarget(
    folderName: 'ipad_13',
    label: 'iPad 13" (landscape)',
    canvasWidth: 1366,
    canvasHeight: 1024,
    deviceWidth: 1366,
    deviceHeight: 1024,
    pixelRatio: 2,
  ),
];

Future<void> main(List<String> args) async {
  final outputDirPath =
      _extractOption(args, _outputDirOption) ?? _defaultOutputDir;
  final outputDir = Directory(outputDirPath);
  await outputDir.create(recursive: true);

  for (final target in _targets) {
    final targetDir = Directory('${outputDir.path}/${target.folderName}');
    await targetDir.create(recursive: true);

    for (final capture in _captures) {
      final outputPath = File(
        '${targetDir.path}/${capture.name}',
      ).absolute.path;
      stdout.writeln('Generating ${capture.name} for ${target.label}...');
      final exitCode = await _runCapture(
        screen: capture.screen,
        outputPath: outputPath,
        target: target,
      );
      if (exitCode != 0) {
        stderr.writeln(
          'Failed while generating ${capture.name} for ${target.label}.',
        );
        exit(exitCode);
      }
    }
  }

  stdout.writeln('Saved iOS listing screenshots to ${outputDir.absolute.path}');
}

String? _extractOption(List<String> args, String prefix) {
  for (final arg in args) {
    if (arg.startsWith(prefix)) {
      return arg.substring(prefix.length);
    }
  }
  return null;
}

Future<int> _runCapture({
  required String screen,
  required String outputPath,
  required _CaptureTarget target,
}) async {
  final process = await Process.start(
    'flutter',
    [
      'run',
      '-d',
      'macos',
      '-t',
      'lib/marketing_capture.dart',
      '--dart-define=MARKETING_SCREEN=$screen',
      '--dart-define=MARKETING_OUTPUT_PATH=$outputPath',
      '--dart-define=MARKETING_CANVAS_WIDTH=${target.canvasWidth}',
      '--dart-define=MARKETING_CANVAS_HEIGHT=${target.canvasHeight}',
      '--dart-define=MARKETING_DEVICE_WIDTH=${target.deviceWidth}',
      '--dart-define=MARKETING_DEVICE_HEIGHT=${target.deviceHeight}',
      '--dart-define=MARKETING_CAPTURE_PIXEL_RATIO=${target.pixelRatio}',
    ],
    environment: {
      'MARKETING_WINDOW_WIDTH': '${target.canvasWidth}',
      'MARKETING_WINDOW_HEIGHT': '${target.canvasHeight}',
    },
  );

  final forwardStdout = stdout.addStream(process.stdout);
  final forwardStderr = stderr.addStream(process.stderr);

  await Future.wait([forwardStdout, forwardStderr]);
  return process.exitCode;
}

class _CaptureTarget {
  const _CaptureTarget({
    required this.folderName,
    required this.label,
    required this.canvasWidth,
    required this.canvasHeight,
    required this.deviceWidth,
    required this.deviceHeight,
    required this.pixelRatio,
  });

  final String folderName;
  final String label;
  final int canvasWidth;
  final int canvasHeight;
  final int deviceWidth;
  final int deviceHeight;
  final int pixelRatio;
}
