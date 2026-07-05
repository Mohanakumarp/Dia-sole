import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/sensor_reading.dart';
import 'ble_types.dart';
import 'sensor_reading_repository.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class TemperatureAsymmetryAlert {
  final String side;
  final String zone;
  final double difference;

  TemperatureAsymmetryAlert(this.side, this.zone, this.difference);
}

class HighPressureAlert {
  final DeviceSide side;
  final List<SensorZone> affectedZones;
  HighPressureAlert(this.side, this.affectedZones);
}

class SensorDataProvider extends ChangeNotifier {
  static const String _tag = '[SensorDataProvider]';

  final SensorReadingRepository _repository = SensorReadingRepository();
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  /// Real-time stream subscription for /live node
  StreamSubscription<DatabaseEvent>? _liveSubscription;

  final Map<DeviceSide, Map<SensorZone, SensorReading?>> _latestReadings = {
    DeviceSide.left: {
      SensorZone.heel: null,
      SensorZone.ball: null,
      SensorZone.toe: null,
      SensorZone.oppositeHeel: null,
      SensorZone.oppositeBall: null,
      SensorZone.oppositeToe: null,
    },
    DeviceSide.right: {
      SensorZone.heel: null,
      SensorZone.ball: null,
      SensorZone.toe: null,
      SensorZone.oppositeHeel: null,
      SensorZone.oppositeBall: null,
      SensorZone.oppositeToe: null,
    },
  };

  final Map<DeviceSide, BleConnectionStatus> _connectionStatus = {
    DeviceSide.left: BleConnectionStatus.connected,
    DeviceSide.right: BleConnectionStatus.connected,
  };

  final Map<DeviceSide, DateTime?> _lastUpdateTime = {
    DeviceSide.left: null,
    DeviceSide.right: null,
  };

  DateTime? lastSyncTime;

  SensorDataProvider() {
    final String initTimestamp = DateTime.now().toIso8601String();
    print('');
    print('╔══════════════════════════════════════════════════════════════╗');
    print('║  [DiaSole] SensorDataProvider initialized                   ║');
    print('║  Timestamp: $initTimestamp');
    print('║  Firebase RTDB: /live (real-time stream)                     ║');
    print('╚══════════════════════════════════════════════════════════════╝');
    print('');
    _startLiveStream();
  }

  /// Start a real-time listener on the Firebase /live node.
  /// Uses onValue to receive every data change instantly.
  void _startLiveStream() {
    // Cancel any existing subscription before starting a new one
    _liveSubscription?.cancel();

    final String startTimestamp = DateTime.now().toIso8601String();
    print('┌──────────────────────────────────────────────────────────────');
    print('│ [DiaSole] FIREBASE LIVE STREAM');
    print('│ Timestamp : $startTimestamp');
    print('│ Node      : /live');
    print('│ Method    : onValue (real-time listener)');
    print('└──────────────────────────────────────────────────────────────');
    print('');

    _liveSubscription = _dbRef.child('live').onValue.listen(
      (DatabaseEvent event) {
        final DateTime now = DateTime.now();
        final String timestamp = now.toIso8601String();

        if (event.snapshot.exists && event.snapshot.value != null) {
          final data = Map<String, dynamic>.from(event.snapshot.value as Map);
          print('');
          print('┌──────────────────────────────────────────────────────────────');
          print('│ [DiaSole] LIVE DATA RECEIVED');
          print('│ Timestamp : $timestamp');
          print('│ Node      : /live');
          print('├──────────────────────────────────────────────────────────────');
          print('│ Status    : ✅ Data received');
          _logFirebaseData(data, timestamp);
          _processCloudData(data);
          lastSyncTime = now;
          notifyListeners();
          print('└──────────────────────────────────────────────────────────────');
          print('');
        } else {
          print('');
          print('┌──────────────────────────────────────────────────────────────');
          print('│ [DiaSole] LIVE DATA EVENT');
          print('│ Timestamp : $timestamp');
          print('│ Status    : ⚠️  No data at /live (snapshot empty)');
          print('└──────────────────────────────────────────────────────────────');
          print('');
        }
      },
      onError: (error) {
        final String timestamp = DateTime.now().toIso8601String();
        print('');
        print('┌──────────────────────────────────────────────────────────────');
        print('│ [DiaSole] LIVE STREAM ERROR');
        print('│ Timestamp : $timestamp');
        print('│ Error     : $error');
        print('└──────────────────────────────────────────────────────────────');
        print('');
      },
    );
  }

  /// Logs all fetched Firebase data in a structured, readable format to the terminal.
  void _logFirebaseData(Map<String, dynamic> data, String timestamp) {
    print('│');
    print('│ ┌────────────────┬────────────┬──────────────┐');
    print('│ │ Sensor         │ Value      │ Type         │');
    print('│ ├────────────────┼────────────┼──────────────┤');
    int totalReadings = 0;
    for (int i = 1; i <= 6; i++) {
      if (data.containsKey('p$i')) {
        final pVal = data['p$i'];
        final p = pVal is num ? pVal.toDouble() : double.tryParse(pVal.toString()) ?? 0.0;
        print('│ │ p$i             │ ${p.toStringAsFixed(2).padRight(10)} │ Pressure     │');
        totalReadings++;
      }
    }
    for (int i = 1; i <= 5; i++) {
      if (data.containsKey('t$i')) {
        final tVal = data['t$i'];
        final t = tVal is num ? tVal.toDouble() : double.tryParse(tVal.toString()) ?? 0.0;
        print('│ │ t$i             │ ${t.toStringAsFixed(2).padRight(10)} │ Temperature  │');
        totalReadings++;
      }
    }
    print('│ └────────────────┴────────────┴──────────────┘');
    print('│');
    print('│ 📊 Total sensor readings fetched: $totalReadings');
    print('│ 🕐 Fetch timestamp: $timestamp');
  }

  void _processCloudData(Map<String, dynamic> data) {
    bool hasUpdates = false;
    final now = DateTime.now();

    // Map p1-p6 and t1-t5 to Right foot zones
    final zones = [
      SensorZone.heel,
      SensorZone.ball,
      SensorZone.toe,
      SensorZone.oppositeHeel,
      SensorZone.oppositeBall,
      SensorZone.oppositeToe,
    ];

    for (int i = 0; i < 6; i++) {
      final pKey = 'p${i + 1}';
      final tKey = 't${i + 1}';

      if (data.containsKey(pKey) || data.containsKey(tKey)) {
        final pVal = data[pKey];
        final tVal = data[tKey];

        final p = pVal is num ? pVal.toDouble() : double.tryParse(pVal.toString()) ?? 0.0;
        final t = tVal is num ? tVal.toDouble() : double.tryParse(tVal.toString()) ?? 0.0;

        final reading = SensorReading(
          side: DeviceSide.right, // Map to right foot as the canonical foot in UI
          zone: zones[i],
          pressure: p,
          temperature: t,
          timestamp: now,
        );

        _latestReadings[DeviceSide.right]![zones[i]] = reading;
        _repository.insertReading(reading);
        hasUpdates = true;
      }
    }
    
    if (hasUpdates) {
      _lastUpdateTime[DeviceSide.right] = now;
      notifyListeners();
    }
  }

  List<double>? getPressures(DeviceSide side) {
    return [
      _latestReadings[side]?[SensorZone.heel]?.pressure ?? 0.0,
      _latestReadings[side]?[SensorZone.ball]?.pressure ?? 0.0,
      _latestReadings[side]?[SensorZone.toe]?.pressure ?? 0.0,
      _latestReadings[side]?[SensorZone.oppositeHeel]?.pressure ?? 0.0,
      _latestReadings[side]?[SensorZone.oppositeBall]?.pressure ?? 0.0,
      _latestReadings[side]?[SensorZone.oppositeToe]?.pressure ?? 0.0,
    ];
  }

  List<double>? getTemperatures(DeviceSide side) {
    return [
      _latestReadings[side]?[SensorZone.heel]?.temperature ?? 0.0,
      _latestReadings[side]?[SensorZone.ball]?.temperature ?? 0.0,
      _latestReadings[side]?[SensorZone.toe]?.temperature ?? 0.0,
      _latestReadings[side]?[SensorZone.oppositeHeel]?.temperature ?? 0.0,
      _latestReadings[side]?[SensorZone.oppositeBall]?.temperature ?? 0.0,
      _latestReadings[side]?[SensorZone.oppositeToe]?.temperature ?? 0.0,
    ];
  }

  TemperatureAsymmetryAlert? getTemperatureAsymmetryAlert() {
    final leftT = getTemperatures(DeviceSide.left);
    final rightT = getTemperatures(DeviceSide.right);
    if (leftT == null || rightT == null) return null;

    final zoneNames = [
      'Heel',
      'Ball',
      'Toe',
      'Opposite Heel',
      'Opposite Ball',
      'Opposite Toe',
    ];

    for (int i = 0; i < 6; i++) {
      if (leftT[i] <= 0 || rightT[i] <= 0) continue;
      final diff = (leftT[i] - rightT[i]).abs();
      if (diff >= 2.0) {
        String highSide = leftT[i] > rightT[i] ? "Left" : "Right";
        return TemperatureAsymmetryAlert(highSide, zoneNames[i], diff);
      }
    }
    return null;
  }

  HighPressureAlert? getHighPressureAlert({double threshold = 0.8}) {
    for (final side in [DeviceSide.left, DeviceSide.right]) {
      final p = getPressures(side);
      if (p == null) continue;
      final highZones = <SensorZone>[];
      if (p[0] > threshold) highZones.add(SensorZone.heel);
      if (p[1] > threshold) highZones.add(SensorZone.ball);
      if (p[2] > threshold) highZones.add(SensorZone.toe);
      if (p[3] > threshold) highZones.add(SensorZone.oppositeHeel);
      if (p[4] > threshold) highZones.add(SensorZone.oppositeBall);
      if (p[5] > threshold) highZones.add(SensorZone.oppositeToe);
      if (highZones.isNotEmpty) return HighPressureAlert(side, highZones);
    }
    return null;
  }

  bool isConnected(DeviceSide side) => true;
  bool get hasAnyConnection => true;
  BleConnectionStatus getConnectionStatus(DeviceSide side) =>
      _connectionStatus[side]!;

  @override
  void dispose() {
    // Cancel the real-time Firebase stream subscription
    _liveSubscription?.cancel();
    _liveSubscription = null;
    print('[DiaSole] Live stream subscription cancelled.');
    super.dispose();
  }

  Future<List<BleScannedDevice>> scanForDevices() async => [];
  Future<void> connectToDevice(BluetoothDevice device, DeviceSide side) async {}
  Future<void> disconnectSide(DeviceSide side) async {}
}
