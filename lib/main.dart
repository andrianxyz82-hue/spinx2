import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:torch_light/torch_light.dart';
import 'package:vibration/vibration.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:uuid/uuid.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:async_wallpaper/async_wallpaper.dart';
import 'config/env_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String? initError;
  
  try {
    // Validate environment configuration
    EnvConfig.validate();

    // Initialize Supabase with environment variables
    await Supabase.initialize(
      url: EnvConfig.supabaseUrl,
      anonKey: EnvConfig.supabaseAnonKey,
    );
    
    // Initialize foreground service for background execution
    if (!kIsWeb) {
      FlutterForegroundTask.init(
        androidNotificationOptions: AndroidNotificationOptions(
          channelId: 'remote_receiver_channel',
          channelName: 'Remote Receiver Service',
          channelDescription: 'Keeps the app running to receive remote commands',
          channelImportance: NotificationChannelImportance.LOW,
          priority: NotificationPriority.LOW,
          iconData: const NotificationIconData(
            resType: ResourceType.mipmap,
            resPrefix: ResourcePrefix.ic,
            name: 'launcher',
          ),
        ),
        iosNotificationOptions: const IOSNotificationOptions(),
        foregroundTaskOptions: const ForegroundTaskOptions(
          interval: 5000,
          isOnceEvent: false,
          autoRunOnBoot: true,
          allowWakeLock: true,
          allowWifiLock: true,
        ),
      );
    }
  } catch (e) {
    print('Initialization error: $e');
    initError = e.toString();
  }

  runApp(MyApp(initError: initError));
}

class MyApp extends StatelessWidget {
  final String? initError;
  
  const MyApp({super.key, this.initError});

  @override
  Widget build(BuildContext context) {
    if (initError != null) {
      return MaterialApp(
        title: 'Android Receiver - Error',
        home: Scaffold(
          backgroundColor: Colors.red.shade50,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 80, color: Colors.red),
                  const SizedBox(height: 24),
                  const Text(
                    'Initialization Failed',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    initError!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Please check:\n• .env file exists\n• Supabase credentials are correct\n• Internet connection',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    
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

    // Keep the screen/CPU awake to prevent app from sleeping
    if (!kIsWeb) {
      try {
        await WakelockPlus.enable();
        print('Wakelock enabled');
      } catch (e) {
        print('Failed to enable wakelock: $e');
      }
      
      // Start foreground service for background execution
      await _startForegroundService();
    }

    _connectToSupabase();
    _requestPermissions();
  }
  
  Future<void> _startForegroundService() async {
    if (kIsWeb) return;
    
    try {
      // Request notification permission first (required for Android 13+)
      if (await Permission.notification.isDenied) {
        await Permission.notification.request();
      }
      
      // Start foreground service
      await FlutterForegroundTask.startService(
        notificationTitle: 'Remote Receiver Active',
        notificationText: 'Device ID: $_deviceId - Waiting for commands',
        callback: startCallback,
      );
      
      print('Foreground service started');
    } catch (e) {
      print('Failed to start foreground service: $e');
    }
  }

  Future<void> _requestPermissions() async {
    if (kIsWeb) return;
    
    // Request critical permissions for background execution and hardware access
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera, // For Flashlight
      Permission.notification, // For foreground service/status
      Permission.ignoreBatteryOptimizations, // To run in background
    ].request();

    // Log status
    statuses.forEach((permission, status) {
      print('$permission: $status');
    });

    if (statuses[Permission.camera] != PermissionStatus.granted) {
      setState(() {
        _status = 'Camera permission needed for Flashlight!';
      });
    }
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
      } else if (status == RealtimeSubscribeStatus.channelError) {
        setState(() {
          _status = 'Channel Error - Check Supabase Realtime settings';
        });
        print('Channel error: $error');
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
          if (!kIsWeb && (await Vibration.hasVibrator() ?? false)) {
            Vibration.vibrate(duration: 500);
          } else if (kIsWeb) {
            print('Vibration not supported on web');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Vibration command received (Web: simulated)')),
            );
          }
          break;
        case 'play_sound':
          await _audioPlayer.play(AssetSource('ping.mp3')); // Ensure ping.mp3 is in assets
          break;
        case 'change_wallpaper':
          if (!kIsWeb) {
            await _changeWallpaper();
          } else {
            print('Wallpaper change not supported on web');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Wallpaper change command received (Web: not supported)')),
            );
          }
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
    if (kIsWeb) {
      print('Flashlight not supported on web');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Flashlight ${on ? 'ON' : 'OFF'} (Web: simulated)')),
      );
      return;
    }
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
  
  Future<void> _changeWallpaper() async {
    if (kIsWeb) return;
    
    try {
      // Set wallpaper from assets
      // You can put multiple wallpapers and randomly select one
      String result = await AsyncWallpaper.setWallpaperFromAsset(
        assetPath: 'assets/wallpapers/1.png',
        wallpaperLocation: AsyncWallpaper.HOME_SCREEN,
      );
      
      print('Wallpaper changed: $result');
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wallpaper changed successfully!')),
      );
    } catch (e) {
      print('Wallpaper Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to change wallpaper: $e')),
      );
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
                            fontSize: 20,
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

// Foreground task callback handler
@pragma('vm:entry-point')
void startCallback() {
  // This callback runs in an isolate, we can't access UI state here
  // Just keep the service alive to maintain Supabase connection
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}

class MyTaskHandler extends TaskHandler {
  @override
  void onStart(DateTime timestamp) {
    print('Foreground task started at $timestamp');
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    // This runs every 5 seconds (interval set in init)
    // Keep the service alive
    FlutterForegroundTask.updateService(
      notificationTitle: 'Remote Receiver Active',
      notificationText: 'Listening for commands...',
    );
  }

  @override
  void onDestroy(DateTime timestamp) {
    print('Foreground task destroyed at $timestamp');
  }
}
