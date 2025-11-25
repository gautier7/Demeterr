//
//  APIModels.swift
//  Demeterr
//
//  Created by Kilo Code on 2024.
//

import Foundation

// MARK: - API Response Models

struct TranscriptionResponse: Codable {
    let text: String
}

struct NutritionAnalysisResponse: Codable {
    let foods: [FoodItem]
    let total: NutritionTotal
}

struct FoodItem: Codable {
    let name: String
    let quantity: Double
    let unit: String
    let calories: Int
    let protein: Double
    let fat: Double
    let carbs: Double
}

struct NutritionTotal: Codable {
    let calories: Int
    let protein: Double
    let fat: Double
    let carbs: Double
}

enum APIError: Error {
    case networkError(Error)
    case decodingError(Error)
    case invalidResponse
    case apiError(String)
    case unknownError
}