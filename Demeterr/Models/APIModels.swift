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
    let calories: Double
    let protein: Double
    let fat: Double
    let carbs: Double
    
    /// Calories as integer for display and storage
    var caloriesInt: Int {
        Int(calories.rounded())
    }
}

struct NutritionTotal: Codable {
    let calories: Double
    let protein: Double
    let fat: Double
    let carbs: Double
    
    /// Calories as integer for display and storage
    var caloriesInt: Int {
        Int(calories.rounded())
    }
}

enum APIError: Error {
    case networkError(Error)
    case decodingError(Error)
    case invalidResponse
    case apiError(String)
    case unknownError
}