import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;

class AiServices {
  // ─────────────────────────────────────────────────────────────
  // Simple advice (no function calling needed)
  // ─────────────────────────────────────────────────────────────
  static Future<String> generateAdvice(String prompt) async {
    final keys = _getGeminiKeys();
    if (keys.isEmpty) return 'No API keys configured.';

    List<Map<String, String>> models = [];
    for (final key in keys) {
      models = await _getModelsForKey(key);
      if (models.isNotEmpty) break;
    }

    if (models.isEmpty) {
      return 'Could not fetch AI models. All API keys might be rate limited.';
    }

    for (final key in keys) {
      try {
        final result = await _geminiText(key, models, prompt);
        if (result != null) return result;
      } catch (_) {}
    }
    return 'Could not generate AI advice. All API keys are rate limited — please wait a moment.';
  }

  // ─────────────────────────────────────────────────────────────
  // Data Mining Reports with Agentic Tool Calling
  // ─────────────────────────────────────────────────────────────
  static Future<String> generateDataMiningReports(
    String prompt, {
    String? previousReportContext,
    List<Map<String, dynamic>>? tools,
    Future<Map<String, dynamic>> Function(String, Map<String, dynamic>)?
    onToolCall,
  }) async {
    final historyPrompt =
        previousReportContext != null && previousReportContext.isNotEmpty
        ? '\nPrevious Report Context (User is modifying this):\n$previousReportContext\n'
        : '';

    final fullPrompt =
        '''
You are a data analyst AI for a restaurant.
User query: $prompt
$historyPrompt
You have access to tools to query the restaurant\'s live data. You MUST call these tools if you need data to answer the user\'s query. DO NOT invent data.
Once you have the data, provide an analysis.
- You can generate multiple charts if the user asks for them or if it helps explain the data.
- ONLY output the NEW charts the user is asking for. DO NOT output charts they already have.
- If the user asks for a "text report", you MUST set the "type" field to "text", and the "data" field should be a detailed markdown string.
- If the user asks for a "table", you MUST set the "type" field to "table", and the "data" field should be an array of objects (e.g. `[{"Name": "Item", "Value": 10}]`).
- For standard charts ("bar", "pie", "line", "card"), ALWAYS return a simple Key-Value map for the "data" field where the value is a number (e.g. `{"Label": 10}`).
Respond EXCLUSIVELY in valid JSON format matching this structure:
{
  "textReport": "Brief acknowledgement or insight.",
  "reset": false,
  "charts": [
    {
      "title": "Chart Title",
      "type": "bar", // Can be: bar, line, pie, card, table, text
      "explanation": "A small text that explains the insights.",
      "data": { "Label1": 10.5, "Label2": 20.0 } // Format depends on 'type'
    }
  ]
}
Return ONLY valid JSON, no markdown blocks, no other text.
''';

    final keys = _getGeminiKeys();
    if (keys.isEmpty) {
      return '{"textReport": "No Gemini API keys configured.", "charts": []}';
    }

    List<Map<String, String>> models = [];
    for (final key in keys) {
      models = await _getModelsForKey(key);
      if (models.isNotEmpty) break;
    }

    if (models.isEmpty) {
      return '{"textReport": "Could not fetch AI models. All API keys might be rate limited.", "charts": []}';
    }

    for (final key in keys) {
      try {
        final result = await _geminiWithTools(
          key,
          models,
          fullPrompt,
          tools: tools,
          onToolCall: onToolCall,
        );
        if (result != null) return result;
      } catch (_) {}
    }

    return '{"textReport": "All Gemini API keys are currently rate limited. Please wait a moment and try again.", "charts": []}';
  }

  // ─────────────────────────────────────────────────────────────
  // Transform Chart Data Formats
  // ─────────────────────────────────────────────────────────────
  static Future<String> transformChartData(
    dynamic originalData,
    String oldType,
    String newType,
  ) async {
    final fullPrompt =
        '''
You are a data formatter AI.
You are given data that was originally formatted for a "$oldType". You need to reformat this data so it fits a "$newType".
Original Data:
${jsonEncode(originalData)}

Instructions:
- If the target newType is "text", output a markdown string detailing the data.
- If the target newType is "table", output an array of objects (e.g. `[{"Category": "A", "Value": 10}]`).
- If the target newType is a chart (like "bar", "line", "pie", "donut", "card"), output a flat Key-Value map mapping labels (String) to numbers (Number).
- Extract or transform the provided data logically to fit the target format.

Respond EXCLUSIVELY with valid JSON containing ONLY the "data" field:
{
  "data": <transformed_data>
}
Return ONLY valid JSON, no markdown blocks, no other text.
''';

    final keys = _getGeminiKeys();
    if (keys.isEmpty) return '{"data": {}}';

    List<Map<String, String>> models = [];
    for (final key in keys) {
      models = await _getModelsForKey(key);
      if (models.isNotEmpty) break;
    }

    if (models.isEmpty) return '{"data": {}}';

    for (final key in keys) {
      try {
        final result = await _geminiText(key, models, fullPrompt);
        if (result != null) return result;
      } catch (_) {}
    }

    return '{"data": {}}';
  }

  // ─────────────────────────────────────────────────────────────
  // Get available Gemini models (used in model selector UI)
  // Uses the first configured key to fetch the list.
  // ─────────────────────────────────────────────────────────────
  static Future<List<Map<String, String>>> getAvailableModels() async {
    final keys = _getGeminiKeys();
    for (final key in keys) {
      final models = await _getModelsForKey(key);
      if (models.isNotEmpty) return models;
    }
    return [];
  }

  // ─────────────────────────────────────────────────────────────
  // Internals
  // ─────────────────────────────────────────────────────────────

  /// Returns all configured non-empty Gemini API keys in order.
  static List<String> _getGeminiKeys() {
    final keys = <String>[];
    for (int i = 1; i <= 5; i++) {
      final key = dotenv.env['GEMINI_API_KEY_$i'] ?? '';
      if (key.isNotEmpty) keys.add(key);
    }
    return keys;
  }

  /// Fetches and sorts the available models for a given API key.
  ///
  /// Filtering: only keeps models that support `generateContent` AND
  /// start with "gemini-" (excludes imagen, veo, lyria, aqa, embedding, etc.)
  /// AND don't contain special-purpose keywords (tts, image, robotics, etc.)
  ///
  /// Sorting (future-proof, no hardcoded version numbers):
  ///  1. lite/flash-lite first  (fastest, cheapest, most free quota)
  ///  2. flash next             (fast, good free quota)
  ///  3. pro / everything else  (powerful but slower)
  ///  4. Within each tier: highest version number first (newest = best)
  static Future<List<Map<String, String>>> _getModelsForKey(
    String apiKey,
  ) async {
    if (apiKey.isEmpty) return [];

    try {
      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models?key=$apiKey',
      );
      final response = await http.get(url);
      if (response.statusCode != 200) return [];

      final json = jsonDecode(response.body);
      final List<dynamic> models = json['models'] ?? [];

      // Keywords that indicate a model is NOT a general text/chat model
      const specialPurposeKeywords = [
        'tts',
        'image',
        'embedding',
        'robotics',
        'computer-use',
        'omni',
        'deep-research',
        'latest',
      ];

      final List<Map<String, String>> result = [];
      for (var model in models) {
        final supportedMethods =
            model['supportedGenerationMethods'] as List<dynamic>? ?? [];
        if (!supportedMethods.contains('generateContent')) continue;

        final String name =
            model['name']?.toString().replaceFirst('models/', '') ?? '';
        if (name.isEmpty) continue;

        // Only keep gemini-* chat models
        if (!name.startsWith('gemini-')) continue;
        if (specialPurposeKeywords.any((kw) => name.contains(kw))) continue;

        final String displayName = model['displayName']?.toString() ?? name;
        result.add({'value': name, 'label': displayName});
      }

      // ── Dynamic sorting (no hardcoded version numbers) ──────────────────
      // Determine type tier from model name keywords
      int _typeTier(String id) {
        if (id.contains('flash-lite') ||
            (id.contains('lite') && id.contains('flash')))
          return 0;
        if (id.contains('flash')) return 1;
        return 2; // pro, or anything else
      }

      // Extract the highest version number found in the model name
      double _versionScore(String id) {
        final matches = RegExp(r'(\d+\.\d+|\d+)').allMatches(id);
        double best = 0;
        for (final m in matches) {
          final v = double.tryParse(m.group(1)!) ?? 0;
          if (v > best) best = v;
        }
        return best;
      }

      result.sort((a, b) {
        final tierDiff = _typeTier(a['value']!) - _typeTier(b['value']!);
        if (tierDiff != 0) return tierDiff;
        // Within same tier: higher version = better → sort descending
        return _versionScore(b['value']!).compareTo(_versionScore(a['value']!));
      });

      return result;
    } catch (_) {
      return [];
    }
  }

  // ───────── GEMINI TEXT (no tools) ─────────

  static Future<String?> _geminiText(
    String apiKey,
    List<Map<String, String>> models,
    String prompt,
  ) async {
    if (models.isEmpty) return null;
    final modelId = models.first['value']!;

    try {
      final model = GenerativeModel(model: modelId, apiKey: apiKey);
      final response = await model.generateContent([Content.text(prompt)]);
      return response.text?.trim();
    } on GenerativeAIException {
      return null; // rate limited or error — caller will try the next key
    } catch (_) {
      return null;
    }
  }

  // ───────── GEMINI WITH TOOLS (agentic loop) ─────────

  static Future<String?> _geminiWithTools(
    String apiKey,
    List<Map<String, String>> models,
    String prompt, {
    List<Map<String, dynamic>>? tools,
    Future<Map<String, dynamic>> Function(String, Map<String, dynamic>)?
    onToolCall,
  }) async {
    if (models.isEmpty) return null;
    final modelId = models.first['value']!;

    try {
      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/$modelId:generateContent?key=$apiKey',
      );

      final List<Map<String, dynamic>> contents = [
        {
          "role": "user",
          "parts": [
            {"text": prompt},
          ],
        },
      ];

      final Map<String, dynamic> requestBody = {
        "contents": contents,
        if (tools != null && tools.isNotEmpty)
          "tools": [
            {"functionDeclarations": tools},
          ],
      };

      for (int turn = 0; turn < 5; turn++) {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(requestBody),
        );

        if (response.statusCode != 200) {
          return null; // Rate limited or other error
        }

        final data = jsonDecode(response.body);
        final candidates = data['candidates'] as List<dynamic>? ?? [];
        if (candidates.isEmpty) return null;

        final candidate = candidates.first as Map<String, dynamic>;
        final content = candidate['content'] as Map<String, dynamic>?;
        if (content == null) return null;

        final parts = content['parts'] as List<dynamic>? ?? [];

        // Check for function calls
        final functionCalls = parts
            .where((p) => p['functionCall'] != null)
            .toList();

        if (functionCalls.isEmpty) {
          // No tools called, return text
          final textPart =
              parts.firstWhere(
                    (p) => p['text'] != null,
                    orElse: () => <String, dynamic>{},
                  )
                  as Map<String, dynamic>;
          final text = _stripMarkdown(textPart['text']?.toString() ?? '');
          return text.isEmpty ? null : text;
        }

        if (onToolCall == null) break;

        // Add the model's response to history (preserving ALL fields like thought_signature)
        contents.add(content);

        // Execute tools
        final List<Map<String, dynamic>> functionResponses = [];
        for (final callPart in functionCalls) {
          final call = callPart['functionCall'] as Map<String, dynamic>;
          final name = call['name'] as String;
          final args = call['args'] as Map<String, dynamic>? ?? {};

          final result = await onToolCall(name, args);
          functionResponses.add({
            "functionResponse": {"name": name, "response": result},
          });
        }

        // Add tool responses to history
        contents.add({"role": "user", "parts": functionResponses});
      }

      return null;
    } on GenerativeAIException catch (e) {
      print('GenerativeAIException: $e');
      return null; // rate limited — caller will try the next key
    } catch (e) {
      print('General Exception: $e');
      return null;
    }
  }

  // ───────── Helpers ─────────

  static SchemaType _schemaType(String type) {
    switch (type.toUpperCase()) {
      case 'NUMBER':
        return SchemaType.number;
      case 'INTEGER':
        return SchemaType.integer;
      case 'BOOLEAN':
        return SchemaType.boolean;
      case 'ARRAY':
        return SchemaType.array;
      default:
        return SchemaType.string;
    }
  }

  static String _stripMarkdown(String text) {
    final start = text.indexOf('{');
    final end = text.lastIndexOf('}');
    if (start != -1 && end != -1 && end >= start) {
      return text.substring(start, end + 1);
    }

    if (text.startsWith('```json')) text = text.substring(7);
    if (text.startsWith('```')) text = text.substring(3);
    if (text.endsWith('```')) text = text.substring(0, text.length - 3);
    return text.trim();
  }
}
