import 'package:flutter_bloc/flutter_bloc.dart';
import 'ai_event.dart';
import 'ai_state.dart';

class AiBloc extends Bloc<AiEvent, AiState> {
  // Store the last canvas data for the refresh feature
  AiCanvasData? _lastCanvasData;
  AiLevel? _lastLevelUsed;

  AiBloc() : super(AiInitial()) {
    on<GenerateAiReport>((event, emit) async {
      emit(AiGenerating(activeLevel: event.preferredLevel));
      try {
        // Here we would call the AI service (e.g. Gemini), fallback if quota over.
        // Mocking the data returned by AI for now:
        final mockData = AiCanvasData(
          originalQuery: event.query,
          textReport: "Based on the data, the sales have been steady...",
          charts: [
            AiChartData(title: "Sales over time", type: "line", data: {}),
          ],
          lastRefreshed: DateTime.now(),
        );

        _lastCanvasData = mockData;
        _lastLevelUsed = event.preferredLevel;

        emit(AiReportReady(canvasData: mockData, levelUsed: event.preferredLevel));
      } catch (e) {
        emit(AiError(message: e.toString(), fallbackData: _lastCanvasData));
      }
    });

    on<RefreshLastAiReport>((event, emit) async {
      if (_lastCanvasData != null && _lastLevelUsed != null) {
        add(GenerateAiReport(
            query: _lastCanvasData!.originalQuery, 
            preferredLevel: _lastLevelUsed!));
      }
    });

    on<RequestAiComment>((event, emit) async {
      // Here we would send the data to the AI and ask for a comment
      // We emit a temporary generating state
      emit(const AiGenerating(activeLevel: AiLevel.basic));
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call
      
      final mockData = AiCanvasData(
        originalQuery: "Generate comment for data",
        textReport: "AI Comment: The provided data shows exceptional performance in this category.",
        charts: [],
        lastRefreshed: DateTime.now(),
      );

      _lastCanvasData = mockData;
      _lastLevelUsed = AiLevel.basic;

      emit(AiReportReady(canvasData: mockData, levelUsed: AiLevel.basic));
    });
  }
}
