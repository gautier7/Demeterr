//
//  DailyEntry.swift
//  Demeterr
//
//  Created by Kilo Code on 2024.
//

import Foundation
import SwiftData

@Model
final class DailyEntry {
    var id: UUID
    var foodName: String
    var quantity: Double
    var unit: String
    var calories: Int
    var protein: Double
    var fat: Double
    var carbs: Double
    var timestamp: Date
    var date: Date
    var source: String

    init(
        id: UUID = UUID(),
        foodName: String,
        quantity: Double,
        unit: String,
        calories: Int,
        protein: Double,
        fat: Double,
        carbs: Double,
        timestamp: Date = Date(),
        source: String = "estimated"
    ) {
        self.id = id
        self.foodName = foodName
        self.quantity = quantity
        self.unit = unit
        self.calories = calories
        self.protein = protein
        self.fat = fat
        self.carbs = carbs
        self.timestamp = timestamp
        self.date = Calendar.current.startOfDay(for: timestamp)
        self.source = source
    }
}