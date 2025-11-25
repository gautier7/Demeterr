//
//  CustomFood.swift
//  Demeterr
//
//  Created by Kilo Code on 2024.
//

import Foundation
import SwiftData

@Model
final class CustomFood {
    var id: UUID
    var name: String
    var caloriesPer100g: Int
    var proteinPer100g: Double
    var fatPer100g: Double
    var carbsPer100g: Double
    var createdDate: Date

    init(name: String, caloriesPer100g: Int, proteinPer100g: Double, fatPer100g: Double, carbsPer100g: Double) {
        self.id = UUID()
        self.name = name
        self.caloriesPer100g = caloriesPer100g
        self.proteinPer100g = proteinPer100g
        self.fatPer100g = fatPer100g
        self.carbsPer100g = carbsPer100g
        self.createdDate = Date()
    }

    /// Calculate nutrition values for a specific quantity in grams
    func nutritionFor(grams: Double) -> (calories: Int, protein: Double, fat: Double, carbs: Double) {
        let factor = grams / 100.0
        return (
            calories: Int(Double(caloriesPer100g) * factor),
            protein: proteinPer100g * factor,
            fat: fatPer100g * factor,
            carbs: carbsPer100g * factor
        )
    }
}