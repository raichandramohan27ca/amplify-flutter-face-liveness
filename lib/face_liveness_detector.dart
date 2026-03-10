import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A Flutter widget that provides AWS Rekognition Face Liveness detection functionality.
///
/// This widget requires a valid AWS Rekognition Face Liveness session ID and region.
/// It uses native platform views to integrate with the AWS Amplify Face Liveness SDK.
class FaceLivenessDetector extends StatefulWidget {
  /// The AWS Rekognition Face Liveness session ID obtained from your backend.
  final String sessionId;

  /// The AWS region where the Face Liveness session was created.
  final String region;

  /// Optional parameter for the disabling the intial view with instructions,
  /// default = false
  final bool disableStartView;

  /// Callback that is called when face liveness check is completed successfully.
  final VoidCallback? onComplete;

  /// Callback that is called when an error occurs during face liveness check.
  /// The error code is passed as a parameter.
  final ValueChanged<String>? onError;

  /// Creates a Face Liveness detector widget.
  ///
  /// [sessionId] is required and must be a valid AWS Rekognition Face Liveness session ID.
  /// [region] is required and must be a valid AWS region where the session was created.
  /// [disableStartView] is not required and allows disable initial view for your 
  /// bussines logic purpose.
  /// [onComplete] is called when the face liveness check is completed successfully.
  /// [onError] is called when an error occurs during the face liveness check.
  const FaceLivenessDetector({
    super.key,
    required this.sessionId,
    required this.region,
    this.disableStartView = false,
    this.onComplete,
    this.onError,
  });

  @override
  State<FaceLivenessDetector> createState() => _FaceLivenessDetectorState();
}

class _FaceLivenessDetectorState extends State<FaceLivenessDetector> {
  final _eventChannel = EventChannel('face_liveness_event');

  @override
  void initState() {
    super.initState();
    _eventChannel.receiveBroadcastStream().listen((event) {
      if (event == 'complete') {
        widget.onComplete?.call();
      } else {
        widget.onError?.call(event);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return UiKitView(
        viewType: 'face_liveness_view',
        layoutDirection: TextDirection.ltr,
        creationParams: {
          'sessionId': widget.sessionId,
          'region': widget.region,
          'disableStartView': widget.disableStartView,
        },
        creationParamsCodec: const StandardMessageCodec(),
      );
    }
    return AndroidView(
      viewType: 'face_liveness_view',
      layoutDirection: TextDirection.ltr,
      creationParams: {
        'sessionId': widget.sessionId,
        'region': widget.region,
        'disableStartView': widget.disableStartView,
      },
      creationParamsCodec: const StandardMessageCodec(),
    );
  }
}
