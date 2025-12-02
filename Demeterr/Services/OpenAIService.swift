//
//  OpenAIService.swift
//  Demeterr
//
//  Created by Kilo Code on 2024.
//

import Foundation

/// Service for communicating with OpenAI API
/// Handles both transcription and nutritional analysis
class OpenAIService {
    private let apiKey: String
    private let baseURL = "https://api.openai.com/v1"
    
    init() {
        self.apiKey = APIConfiguration.openAIKey
    }
    
    // MARK: - Transcription
    
    /// Transcribe audio file to text using OpenAI's speech recognition
    /// - Parameter fileURL: URL to the audio file (M4A format)
    /// - Returns: Transcribed text
    func transcribeAudio(fileURL: URL) async throws -> String {
        let url = URL(string: "\(baseURL)/audio/transcriptions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        // Create multipart form data
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // Add model parameter
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"model\"\r\n\r\n".data(using: .utf8)!)
        body.append("whisper-1\r\n".data(using: .utf8)!)
        
        // Add audio file
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"audio.m4a\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: audio/mp4\r\n\r\n".data(using: .utf8)!)
        
        let audioData = try Data(contentsOf: fileURL)
        body.append(audioData)
        body.append("\r\n".data(using: .utf8)!)
        
        // Add boundary end
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Check for HTTP errors
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            let errorMessage = try? JSONDecoder().decode(OpenAIErrorResponse.self, from: data)
            throw APIError.apiError(errorMessage?.error.message ?? "Unknown API error")
        }
        
        // Decode response
        let transcriptionResponse = try JSONDecoder().decode(TranscriptionResponse.self, from: data)
        return transcriptionResponse.text
    }
    
    // MARK: - Nutrition Analysis
    
    /// Analyze transcribed text and extract nutritional information
    /// - Parameters:
    ///   - text: Transcribed food entry text
    ///   - customFoods: Array of custom foods for database lookup
    /// - Returns: Structured nutrition analysis response
    func analyzeNutrition(text: String, customFoods: [CustomFood]) async throws -> NutritionAnalysisResponse {
        let url = URL(string: "\(baseURL)/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let systemPrompt = buildSystemPrompt(customFoods: customFoods)
        
        let requestBody: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [
                [
                    "role": "system",
                    "content": systemPrompt
                ],
                [
                    "role": "user",
                    "content": "Parse this food input and return ONLY valid JSON: \(text)"
                ]
            ],
            "temperature": 0.3,
            "response_format": ["type": "json_object"]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Check for HTTP errors
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            let errorMessage = try? JSONDecoder().decode(OpenAIErrorResponse.self, from: data)
            throw APIError.apiError(errorMessage?.error.message ?? "Unknown API error")
        }
        
        // Decode response
        let chatResponse = try JSONDecoder().decode(ChatCompletionResponse.self, from: data)
        
        guard let content = chatResponse.choices.first?.message.content else {
            throw APIError.invalidResponse
        }
        
        // Parse the JSON content
        guard let jsonData = content.data(using: .utf8) else {
            throw APIError.decodingError(NSError(domain: "JSON", code: -1))
        }
        
        let analysisResponse = try JSONDecoder().decode(NutritionAnalysisResponse.self, from: jsonData)
        return analysisResponse
    }
    
    // MARK: - Helper Methods
    
    /// Build system prompt for nutrition analysis
    /// Includes custom foods database for accurate matching
    private func buildSystemPrompt(customFoods: [CustomFood]) -> String {
        var prompt = """
        You are a nutritional analysis assistant. Your task is to parse food entries and extract structured nutritional data.
        
        IMPORTANT: You MUST respond with ONLY valid JSON, no other text.
        
        When analyzing food entries:
        1. Extract all food items mentioned
        2. Identify quantities and units (grams, cups, pieces, etc.)
        3. Calculate nutritional values based on standard nutritional databases
        4. Return structured JSON with the exact format specified below
        
        JSON Response Format (REQUIRED):
        {
            "foods": [
                {
                    "name": "food name",
                    "quantity": number,
                    "unit": "grams/cups/pieces/etc",
                    "calories": number,
                    "protein": number,
                    "fat": number,
                    "carbs": number
                }
            ],
            "total": {
                "calories": number,
                "protein": number,
                "fat": number,
                "carbs": number
            }
        }
        
        Example Input: "200g chicken breast and 100g rice"
        Example Output:
        {
            "foods": [
                {
                    "name": "chicken breast",
                    "quantity": 200,
                    "unit": "grams",
                    "calories": 330,
                    "protein": 62,
                    "fat": 7.2,
                    "carbs": 0
                },
                {
                    "name": "rice",
                    "quantity": 100,
                    "unit": "grams",
                    "calories": 130,
                    "protein": 2.7,
                    "fat": 0.3,
                    "carbs": 28
                }
            ],
            "total": {
                "calories": 460,
                "protein": 64.7,
                "fat": 7.5,
                "carbs": 28
            }
        }
        
        """
        
        // Add custom foods database if available
        if !customFoods.isEmpty {
            prompt += "\nCUSTOM FOODS DATABASE (use these values when foods match):\n"
            for food in customFoods {
                prompt += "- \(food.name): \(food.caloriesPer100g) cal, \(food.proteinPer100g)g protein, \(food.fatPer100g)g fat, \(food.carbsPer100g)g carbs per 100g\n"
            }
        }
        
        return prompt
    }
}

// MARK: - API Response Models

struct ChatCompletionResponse: Codable {
    let choices: [Choice]
    
    struct Choice: Codable {
        let message: Message
        
        struct Message: Codable {
            let content: String
        }
    }
}

struct OpenAIErrorResponse: Codable {
    let error: ErrorDetail
    
    struct ErrorDetail: Codable {
        let message: String
    }
}
