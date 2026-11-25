import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_settings_provider.dart';
import '../theme/app_theme.dart';

class BackendStatusDialog extends StatefulWidget {
  const BackendStatusDialog({super.key});

  @override
  State<BackendStatusDialog> createState() => _BackendStatusDialogState();
}

class _BackendStatusDialogState extends State<BackendStatusDialog> {
  late TextEditingController _urlController;
  String? _testMessage;
  bool? _testSuccess;

  @override
  void initState() {
    super.initState();
    final settings = Provider.of<AppSettingsProvider>(context, listen: false);
    _urlController = TextEditingController(text: settings.baseUrl);
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AppSettingsProvider>(context);

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.dns_rounded, color: AppTheme.primary),
          SizedBox(width: 10),
          Text('Local Backend API Configuration', style: TextStyle(fontSize: 16)),
        ],
      ),
      content: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Configure the base URL of your local ticket backend API. By default, the system probes this endpoint and gracefully falls back to the high-fidelity in-memory enterprise database if the local server is offline.',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'Backend Base URL',
                hintText: 'http://localhost:8080/api',
                prefixIcon: Icon(Icons.link_rounded),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: settings.isTestingConnection
                      ? null
                      : () async {
                          final ok = await settings.updateBaseUrl(_urlController.text);
                          setState(() {
                            _testSuccess = ok;
                            _testMessage = ok
                                ? 'Connection successful! Local backend is active.'
                                : 'Endpoint unreachable. Using graceful Mock DB fallback.';
                          });
                        },
                  icon: settings.isTestingConnection
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Test Connection & Save'),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    _urlController.text = 'http://localhost:8080/api';
                  },
                  child: const Text('Reset Default'),
                ),
              ],
            ),
            if (_testMessage != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _testSuccess == true
                      ? AppTheme.statusResolved.withValues(alpha: 0.1)
                      : Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _testSuccess == true
                        ? AppTheme.statusResolved.withValues(alpha: 0.4)
                        : Colors.orange.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _testSuccess == true ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                      color: _testSuccess == true ? AppTheme.statusResolved : Colors.orange,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _testMessage!,
                        style: TextStyle(
                          fontSize: 12,
                          color: _testSuccess == true ? AppTheme.statusResolved : Colors.orange.shade800,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'Supported Local Backend Endpoints:\n'
              '• GET  /health - Health check\n'
              '• GET  /tickets - Filtered list of tickets\n'
              '• POST /tickets - Create ticket\n'
              '• PUT  /tickets/:id/status - Status transitions\n'
              '• PUT  /tickets/:id/assign - Manual & rule-based assignment\n'
              '• POST /tickets/:id/comments - Public replies & internal notes\n'
              '• POST /tickets/:id/feedback - Customer CSAT feedback',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 11, height: 1.4, fontFamily: 'Consolas'),
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Done'),
        ),
      ],
    );
  }
}
