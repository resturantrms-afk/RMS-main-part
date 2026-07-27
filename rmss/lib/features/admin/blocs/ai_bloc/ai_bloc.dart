import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rmss/core/services/ai_services.dart';
import 'ai_event.dart';
import 'ai_state.dart';

class AiBloc extends Bloc<AiEvent, AiState> {
  // Store the last canvas data for the refresh feature
  AiCanvasData? _lastCanvasData;
  AiLevel? _lastLevelUsed;

  AiBloc() : super(AiInitial()) {
    on<GenerateAiReport>((event, emit) async {
      emit(AiGenerating(activeLevel: event.preferredLevel, fallbackData: _lastCanvasData));
      try {
        String? previousContext;
        if (_lastCanvasData != null) {
          previousContext =
              "Text Report: ${_lastCanvasData!.textReport}\nCharts:\n";
          for (var chart in _lastCanvasData!.charts) {
            previousContext =
                previousContext! +
                "- ${chart.title} (${chart.type}): ${jsonEncode(chart.data)}\n";
          }
        }

        Map<String, dynamic> rawContext = {};
        try {
          rawContext = jsonDecode(event.contextData);
        } catch (_) {}

        final tools = [
          {
            "name": "get_sales_volume",
            "description": "Gets total units sold, optionally grouped by 'item' or 'category'.",
            "parameters": {
              "type": "OBJECT",
              "properties": {
                "groupBy": {
                  "type": "STRING",
                  "description": "Either 'item' or 'category'"
                },
                "timeRange": {
                  "type": "STRING",
                  "description": "Optional: 'today', 'thisWeek', 'thisMonth', 'allTime'. Default is 'allTime'."
                }
              }
            }
          },
          {
            "name": "get_revenue_over_time",
            "description": "Gets historical daily revenue.",
            "parameters": {
              "type": "OBJECT",
              "properties": {
                "timeRange": {
                  "type": "STRING",
                  "description": "Optional: 'today', 'thisWeek', 'thisMonth', 'allTime'. Default is 'allTime'."
                }
              }
            }
          },
          {
            "name": "get_staff_and_table_metrics",
            "description": "Gets current staff and table utilization.",
            "parameters": {
              "type": "OBJECT",
              "properties": {
                "timeRange": {
                  "type": "STRING",
                  "description": "Optional: 'today', 'thisWeek', 'thisMonth', 'allTime'. Default is 'allTime'."
                }
              }
            }
          },
          {
            "name": "get_peak_hours",
            "description": "Gets order volume grouped by hour of the day.",
            "parameters": {"type": "OBJECT", "properties": {
                "timeRange": {
                  "type": "STRING",
                  "description": "Optional: 'today', 'thisWeek', 'thisMonth', 'allTime'. Default is 'allTime'."
                }
            }}
          },
          {
            "name": "get_kitchen_efficiency",
            "description": "Gets average preparation time in minutes for orders.",
            "parameters": {"type": "OBJECT", "properties": {
                "timeRange": {
                  "type": "STRING",
                  "description": "Optional: 'today', 'thisWeek', 'thisMonth', 'allTime'. Default is 'allTime'."
                }
            }}
          },
          {
            "name": "get_sales_by_source",
            "description": "Gets order volume grouped by source (e.g. POS vs Web).",
            "parameters": {"type": "OBJECT", "properties": {
                "timeRange": {
                  "type": "STRING",
                  "description": "Optional: 'today', 'thisWeek', 'thisMonth', 'allTime'. Default is 'allTime'."
                }
            }}
          },
          {
            "name": "get_revenue_by_payment_method",
            "description": "Gets revenue grouped by payment method (e.g. cash vs card).",
            "parameters": {"type": "OBJECT", "properties": {
                "timeRange": {
                  "type": "STRING",
                  "description": "Optional: 'today', 'thisWeek', 'thisMonth', 'allTime'. Default is 'allTime'."
                }
            }}
          },
          {
            "name": "get_staff_performance",
            "description": "Gets total revenue processed by each staff member.",
            "parameters": {"type": "OBJECT", "properties": {
                "timeRange": {
                  "type": "STRING",
                  "description": "Optional: 'today', 'thisWeek', 'thisMonth', 'allTime'. Default is 'allTime'."
                }
            }}
          },
          {
            "name": "get_item_cancellations",
            "description": "Gets the count of cancelled units for each menu item.",
            "parameters": {"type": "OBJECT", "properties": {
                "timeRange": {
                  "type": "STRING",
                  "description": "Optional: 'today', 'thisWeek', 'thisMonth', 'allTime'. Default is 'allTime'."
                }
            }}
          },
          {
            "name": "get_profit_margins",
            "description": "Gets estimated net profit per menu item (assuming standard food cost margins).",
            "parameters": {"type": "OBJECT", "properties": {
                "timeRange": {
                  "type": "STRING",
                  "description": "Optional: 'today', 'thisWeek', 'thisMonth', 'allTime'. Default is 'allTime'."
                }
            }}
          },
          {
            "name": "get_menu_details",
            "description": "Gets raw menu data including names, prices, and categories for all items on the menu.",
            "parameters": {"type": "OBJECT", "properties": {}}
          },
          {
            "name": "get_user_details",
            "description": "Gets detailed list of users/staff including their names, roles (e.g. kitchen, cashier), and active status.",
            "parameters": {"type": "OBJECT", "properties": {}}
          },
          {
            "name": "get_detailed_orders",
            "description": "Gets a raw list of individual orders (including items, totals, and the specific cashier/admin who processed them) for a specific time range. Use this to give specific user-level breakdowns of orders.",
            "parameters": {
              "type": "OBJECT",
              "properties": {
                "timeRange": {
                  "type": "STRING",
                  "description": "Optional: 'today', 'thisWeek', 'thisMonth', 'allTime'. Default is 'allTime'."
                }
              }
            }
          }
        ];

        Future<Map<String, dynamic>> handleToolCall(String name, Map<String, dynamic> args) async {
           final timeRange = args["timeRange"] ?? "allTime";
           final rangeData = rawContext[timeRange] ?? rawContext["allTime"] ?? {};

           if (name == "get_revenue_over_time") {
             return {
               "totalRevenue": rangeData["totalRevenue"],
               "revenueByDate": rangeData["revenueByDate"]
             };
           } else if (name == "get_staff_and_table_metrics") {
             return {
               "tables": rangeData["tables"],
               "users": rangeData["users"]
             };
           } else if (name == "get_sales_volume") {
             final groupBy = args["groupBy"] ?? "item";
             if (groupBy == "item") {
               return {"itemUnitsSold": rangeData["itemUnitsSold"]};
             } else {
               return {"categoryUnitsSold": rangeData["categoryUnitsSold"]}; 
             }
           } else if (name == "get_peak_hours") {
             return {"ordersByHour": rangeData["ordersByHour"]};
           } else if (name == "get_kitchen_efficiency") {
             return {"avgPrepTimeMinutes": rangeData["avgPrepTimeMinutes"]};
           } else if (name == "get_sales_by_source") {
             return {"ordersBySource": rangeData["ordersBySource"]};
           } else if (name == "get_revenue_by_payment_method") {
             return {"revenueByMethod": rangeData["revenueByMethod"]};
           } else if (name == "get_staff_performance") {
             return {"staffPerformance": rangeData["staffPerformance"]};
           } else if (name == "get_item_cancellations") {
             return {"cancelledItems": rangeData["cancelledItems"]};
           } else if (name == "get_profit_margins") {
             return {"itemProfits": rangeData["itemProfits"]};
           } else if (name == "get_menu_details") {
             return {"rawMenu": rawContext["rawMenu"]};
           } else if (name == "get_user_details") {
             return {"detailedUsers": rawContext["detailedUsers"]};
           } else if (name == "get_detailed_orders") {
             return {"detailedOrders": rangeData["detailedOrders"]};
           }
           return {"error": "Unknown tool"};
        }

        final response = await AiServices.generateDataMiningReports(
          event.query,
          previousReportContext: previousContext,
          tools: tools,
          onToolCall: handleToolCall,
        );

        Map<String, dynamic> decoded;
        try {
          decoded = jsonDecode(response);
        } catch (_) {
          decoded = {'textReport': response, 'charts': []};
        }

        final String textReport =
            decoded['textReport'] ?? "No report generated.";
        final List<dynamic> chartsList = decoded['charts'] ?? [];

        final List<AiChartData> charts = chartsList.map((c) {
          return AiChartData(
            title: c['title'] ?? 'Chart',
            type: c['type'] ?? 'bar',
            explanation: c['explanation'] ?? '',
            data: c['data'] ?? {},
          );
        }).toList();

        final bool reset = decoded['reset'] ?? false;

        List<AiChartData> previousCharts = [];
        if (!reset && _lastCanvasData != null) {
          previousCharts = List.from(_lastCanvasData!.charts);
        }

        final List<AiChartData> allCharts = [...previousCharts, ...charts];

        final mockData = AiCanvasData(
          originalQuery: event.query,
          textReport: textReport,
          charts: allCharts,
          lastRefreshed: DateTime.now(),
        );

        _lastCanvasData = mockData;
        _lastLevelUsed = event.preferredLevel;

        emit(
          AiReportReady(canvasData: mockData, levelUsed: event.preferredLevel),
        );
      } catch (e) {
        emit(AiError(message: e.toString(), fallbackData: _lastCanvasData));
      }
    });

    on<RefreshLastAiReport>((event, emit) async {
      if (_lastCanvasData != null && _lastLevelUsed != null) {
        add(
          GenerateAiReport(
            query: _lastCanvasData!.originalQuery,
            contextData: "Refreshed Data",
            preferredLevel: _lastLevelUsed!,
          ),
        );
      }
    });

    on<RequestAiComment>((event, emit) async {
      emit(AiGenerating(activeLevel: AiLevel.basic, fallbackData: _lastCanvasData));

      try {
        final prompt =
            "Provide a very short 1-sentence AI comment summarizing this data: ${event.data}";
        final response = await AiServices.generateAdvice(prompt);

        final mockData = AiCanvasData(
          originalQuery: "Generate comment for data",
          textReport: response,
          charts: [],
          lastRefreshed: DateTime.now(),
        );

        _lastCanvasData = mockData;
        _lastLevelUsed = AiLevel.basic;

        emit(AiReportReady(canvasData: mockData, levelUsed: AiLevel.basic));
      } catch (e) {
        emit(AiError(message: e.toString(), fallbackData: _lastCanvasData));
      }
    });

    on<RemoveChart>((event, emit) async {
      if (_lastCanvasData != null && _lastLevelUsed != null) {
        final List<AiChartData> updatedCharts = List.from(_lastCanvasData!.charts);
        if (event.index >= 0 && event.index < updatedCharts.length) {
          updatedCharts.removeAt(event.index);
          
          final mockData = AiCanvasData(
            originalQuery: _lastCanvasData!.originalQuery,
            textReport: _lastCanvasData!.textReport,
            charts: updatedCharts,
            lastRefreshed: DateTime.now(),
          );
          
          _lastCanvasData = mockData;
          emit(AiReportReady(canvasData: mockData, levelUsed: _lastLevelUsed!));
        }
      }
    });

    on<TransformChart>((event, emit) async {
      if (_lastCanvasData != null && _lastLevelUsed != null) {
        final List<AiChartData> updatedCharts = List.from(_lastCanvasData!.charts);
        if (event.index >= 0 && event.index < updatedCharts.length) {
          final chart = updatedCharts[event.index];
          
          // Emit transforming state for this chart
          updatedCharts[event.index] = chart.copyWith(isTransforming: true);
          var mockData = AiCanvasData(
            originalQuery: _lastCanvasData!.originalQuery,
            textReport: _lastCanvasData!.textReport,
            charts: updatedCharts,
            lastRefreshed: DateTime.now(),
          );
          _lastCanvasData = mockData;
          emit(AiReportReady(canvasData: mockData, levelUsed: _lastLevelUsed!));

          try {
            // Call AI to transform
            final response = await AiServices.transformChartData(
              chart.data,
              chart.type,
              event.newType,
            );
            
            dynamic newData = chart.data;
            try {
              final decoded = jsonDecode(response);
              if (decoded.containsKey('data')) {
                newData = decoded['data'];
              } else {
                newData = decoded;
              }
            } catch (_) {}

            // Update with new data and type
            updatedCharts[event.index] = chart.copyWith(
              isTransforming: false,
              type: event.newType,
              data: newData,
            );
          } catch (e) {
             // Revert loading on error
             updatedCharts[event.index] = chart.copyWith(isTransforming: false);
          }

          mockData = AiCanvasData(
            originalQuery: _lastCanvasData!.originalQuery,
            textReport: _lastCanvasData!.textReport,
            charts: updatedCharts,
            lastRefreshed: DateTime.now(),
          );
          _lastCanvasData = mockData;
          emit(AiReportReady(canvasData: mockData, levelUsed: _lastLevelUsed!));
        }
      }
    });
  }
}
