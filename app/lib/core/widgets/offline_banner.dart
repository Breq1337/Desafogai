import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Banner that shows when Firestore is operating from cache (offline).
class OfflineBanner extends StatefulWidget {
  const OfflineBanner({super.key});

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner> {
  late final StreamSubscription<DocumentSnapshot> _sub;
  Timer? _serverProbeTimer;
  bool _isOffline = false;
  int _consecutiveServerFailures = 0;

  @override
  void initState() {
    super.initState();
    // Avoid false positives: cache metadata is not enough to classify offline.
    _sub = FirebaseFirestore.instance
        .collection('_connectivity')
        .doc('ping')
        .snapshots(includeMetadataChanges: true)
        .listen((snapshot) {
      if (!snapshot.metadata.isFromCache) {
        _consecutiveServerFailures = 0;
        if (mounted && _isOffline) {
          setState(() => _isOffline = false);
        }
      }
    }, onError: (_) {
      // Keep state untouched; explicit server probe defines offline mode.
    });

    _probeServerConnectivity();
    _serverProbeTimer = Timer.periodic(
      const Duration(seconds: 20),
      (_) => _probeServerConnectivity(),
    );
  }

  Future<void> _probeServerConnectivity() async {
    try {
      await FirebaseFirestore.instance
          .collection('_connectivity')
          .doc('ping')
          .get(const GetOptions(source: Source.server));
      _consecutiveServerFailures = 0;
      if (mounted && _isOffline) {
        setState(() => _isOffline = false);
      }
    } on FirebaseException catch (e) {
      final isConnectivityError =
          e.code == 'unavailable' || e.code == 'deadline-exceeded';
      if (!isConnectivityError) {
        _consecutiveServerFailures = 0;
        if (mounted && _isOffline) {
          setState(() => _isOffline = false);
        }
        return;
      }

      _consecutiveServerFailures += 1;
      if (_consecutiveServerFailures >= 2 && mounted && !_isOffline) {
        setState(() => _isOffline = true);
      }
    } catch (_) {
      _consecutiveServerFailures += 1;
      if (_consecutiveServerFailures >= 2 && mounted && !_isOffline) {
        setState(() => _isOffline = true);
      }
    }
  }

  @override
  void dispose() {
    _sub.cancel();
    _serverProbeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isOffline) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.warning.withValues(alpha: 0.15),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off_rounded, color: AppColors.warning, size: 16),
          SizedBox(width: 8),
          Text(
            'Modo offline — alterações serão sincronizadas',
            style: TextStyle(
              color: AppColors.warning,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
