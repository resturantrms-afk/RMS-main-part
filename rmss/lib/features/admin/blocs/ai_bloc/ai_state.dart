import 'package:equatable/equatable.dart';
import 'ai_event.dart';

abstract class AiState extends Equatable {
  const AiState();

  @override
  List<Object?> get props => [];
}

class AiInitial extends AiState {}

class AiGenerating extends AiState {
  final AiLevel activeLevel;

  const AiGenerating({required this.activeLevel});

  @override
  List<Object?> get props => [activeLevel];
}

class AiReportReady extends AiState {
  final AiCanvasData canvasData;
  final AiLevel levelUsed;

  const AiReportReady({required this.canvasData, required this.levelUsed});

  @override
  List<Object?> get props => [canvasData, levelUsed];
}

class AiError extends AiState {
  final String message;
  final AiCanvasData? fallbackData; // Fallback to last data if refresh fails

  const AiError({required this.message, this.fallbackData});

  @override
  List<Object?> get props => [message, fallbackData];
}
