import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:torch_light/torch_light.dart';
import 'package:vibration/vibration.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:uuid/uuid.dart';
import 'package:permission_handler/permission_handler.dart';
import 'config/env_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await EnvConfig.initialize();
  
  // Validate environment configuration
  EnvConfig.validate();

  // Initialize Supabase with environment variables
  await Supabase.initialize(
    url: EnvConfig.supabaseUrl,
    anonKey: EnvConfig.supabaseAnonKey,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Android Receiver',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ReceiverHomePage(),
    );
  }
}

class ReceiverHomePage extends StatefulWidget {
  const ReceiverHomePage({super.key});

  @override
  State<ReceiverHomePage> createState() => _ReceiverHomePageState();
}

class _ReceiverHomePageState extends State<ReceiverHomePage> {
  String _deviceId = '';
  String _status = 'Initializing...';
  RealtimeChannel? _channel;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isFlashOn = false;

  @override
  void initState() {
    super.initState();
    _initializeDevice();
  }

  Future<void> _initializeDevice() async {
    // Generate a persistent UUID for this session (or load from storage if needed)
    // For this demo, we generate a new one each time or you could use shared_preferences
    const uuid = Uuid();
    setState(() {
      _deviceId = uuid.v4().substring(0, 8); // Shorten for easier typing
      _status = 'Connecting to Supabase...';
    });

    _connectToSupabase();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.camera, // For Flashlight
      Permission.notification,
    ].request();
  }

  void _connectToSupabase() {
    final supabase = Supabase.instance.client;
    final channelName = 'device_$_deviceId';

    _channel = supabase.channel(channelName);

    _channel!.onBroadcast(event: 'command', callback: (payload) {
      _handleCommand(payload);
    }).subscribe((status, error) {
      if (status == RealtimeSubscribeStatus.subscribed) {
        setState(() {
          _status = 'Connected. Waiting for commands...';
        });
      } else if (status == RealtimeSubscribeStatus.closed) {
        setState(() {
          _status = 'Disconnected.';
        });
      } else {
        setState(() {
          _status = 'Connection Status: ${status.name}';
        });
      }
    });
  }

  void _handleCommand(Map<String, dynamic> payload) async {
    final command = payload['command'] as String?;
    if (command == null) return;

    print('Received command: $command');
    setState(() {
      _status = 'Executing: $command';
    });

    try {
      switch (command) {
        case 'flash_on':
          await _toggleFlash(true);
          break;
        case 'flash_off':
          await _toggleFlash(false);
          break;
        case 'vibrate':
          if (await Vibration.hasVibrator() ?? false) {
            Vibration.vibrate(duration: 500);
          }
          break;
        case 'play_sound':
          await _audioPlayer.play(AssetSource('ping.mp3')); // Ensure ping.mp3 is in assets
          // Fallback or alternative if asset not present, maybe system sound?
          // For simplicity, we assume asset. Or we can just log it.
          break;
        default:
          print('Unknown command: $command');
      }

      // Send acknowledgment
      _channel?.sendBroadcastMessage(
        event: 'response',
        payload: {
          'status': 'success',
          'command': command,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      print('Error executing command: $e');
      _channel?.sendBroadcastMessage(
        event: 'response',
        payload: {
          'status': 'error',
          'command': command,
          'error': e.toString(),
        },
      );
    }
  }

  Future<void> _toggleFlash(bool on) async {
    try {
      if (on) {
        await TorchLight.enableTorch();
        _isFlashOn = true;
      } else {
        await TorchLight.disableTorch();
        _isFlashOn = false;
      }
    } catch (e) {
      print('Torch Error: $e');
      // Handle torch unavailable
    }
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Android Receiver'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.phonelink_ring, size: 80, color: Colors.deepPurple),
            const SizedBox(height: 32),
            Text(
              'Device ID:',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: _deviceId));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Device ID copied to clipboard')),
                );
              },
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _deviceId,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.copy, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _status.contains('Connected')
                    ? Colors.green.shade100
                    : Colors.orange.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _status,
                style: TextStyle(
                  color: _status.contains('Connected')
                      ? Colors.green.shade800
                      : Colors.orange.shade800,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
