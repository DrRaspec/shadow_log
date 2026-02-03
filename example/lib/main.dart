import 'package:flutter/material.dart';
import 'package:shadow_log/shadow_log.dart';

void main() {
  // Configure ShadowLog (Logcat + debug console).
  ShadowLog.configure(
    ShadowLogConfig(
      name: 'ShadowLogExample',
      minLevel: ShadowLogLevel.verbose,
      formatter: const ShadowPrettyFormatter(),
      outputs: const <ShadowLogOutput>[
        ShadowDeveloperLogOutput(),
        ShadowDebugPrintOutput(),
      ],
    ),
  );

  // Optional: forward Flutter + platform errors into ShadowLog.
  ShadowLog.installFlutterErrorHandler();

  // Optional: keep the last N logs in memory (useful for in-app log UIs).
  final history = ShadowLog.attachHistory(capacity: 200);

  runApp(ShadowLogExampleApp(history: history));
}

class ShadowLogExampleApp extends StatelessWidget {
  const ShadowLogExampleApp({super.key, required this.history});

  final ShadowLogHistory history;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShadowLog Example',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: ShadowLogExamplePage(history: history),
    );
  }
}

class ShadowLogExamplePage extends StatefulWidget {
  const ShadowLogExamplePage({super.key, required this.history});

  final ShadowLogHistory history;

  @override
  State<ShadowLogExamplePage> createState() => _ShadowLogExamplePageState();
}

class _ShadowLogExamplePageState extends State<ShadowLogExamplePage> {
  final ShadowLogger _log = ShadowLog.logger('Example');

  @override
  void initState() {
    super.initState();
    _log.d('App initialized');
  }

  void _logVerbose() {
    _log.v('This is a verbose message');
  }

  void _logDebug() {
    _log.d('This is a debug message');
  }

  void _logInfo() {
    _log.i('This is an info message');
  }

  void _logWarning() {
    _log.w('This is a warning message');
  }

  void _logError() {
    _log.e(
      'This is an error message',
      error: Exception('Sample exception'),
    );
  }

  void _logWTF() {
    _log.wtf(
      'Something went really wrong!',
      error: Exception('Critical error'),
    );
  }

  void _logWithFields() {
    _log.i(
      'Structured fields demo',
      fields: <String, Object?>{
        'userId': 123,
        'cached': false,
        'feature': 'shadow_log',
      },
    );
  }

  void _clearHistory() {
    widget.history.clear();
    _log.i('History cleared');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ShadowLog Example'),
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Clear history',
            onPressed: _clearHistory,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Tap buttons to log at different levels.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _logVerbose,
                    child: const Text('Verbose'),
                  ),
                  ElevatedButton(onPressed: _logDebug, child: const Text('Debug')),
                  ElevatedButton(onPressed: _logInfo, child: const Text('Info')),
                  ElevatedButton(
                    onPressed: _logWarning,
                    child: const Text('Warning'),
                  ),
                  ElevatedButton(onPressed: _logError, child: const Text('Error')),
                  ElevatedButton(onPressed: _logWTF, child: const Text('WTF')),
                  OutlinedButton(
                    onPressed: _logWithFields,
                    child: const Text('Fields'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'View logs in:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text('• Android: adb logcat | grep "ShadowLogExample"'),
                      SizedBox(height: 8),
                      Text('• Flutter console (debug builds)'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'In-app history (newest first)',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: AnimatedBuilder(
                            animation: widget.history,
                            builder: (context, _) {
                              final records = widget.history.recordsReversed;
                              if (records.isEmpty) {
                                return const Center(
                                  child: Text('No logs yet'),
                                );
                              }

                              return ListView.separated(
                                itemCount: records.length,
                                separatorBuilder: (_, _) =>
                                    const Divider(height: 1),
                                itemBuilder: (context, index) {
                                  final record = records[index];
                                  final color = switch (record.level) {
                                    ShadowLogLevel.verbose =>
                                      Colors.grey.shade600,
                                    ShadowLogLevel.debug =>
                                      Colors.blue.shade700,
                                    ShadowLogLevel.info =>
                                      Colors.green.shade700,
                                    ShadowLogLevel.warning =>
                                      Colors.orange.shade700,
                                    ShadowLogLevel.error =>
                                      Colors.red.shade700,
                                    ShadowLogLevel.wtf =>
                                      Colors.purple.shade700,
                                    _ => Colors.black,
                                  };

                                  final text =
                                      ShadowLog.config.formatter.format(record);

                                  return Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 6),
                                    child: Text(
                                      text,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: color,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
