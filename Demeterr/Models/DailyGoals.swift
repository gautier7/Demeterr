//
//  DailyGoals.swift
//  Demeterr
//
//  Created by Kilo Code on 2024.
//

import Foundation
import SwiftData

@Model
class DailyGoals {
    var id: UUID
    var calorieTarget: Int
    var proteinTarget: Double
    var fatTarget: Double
    var carbsTarget: Double
    var lastUpdated: Date

    init(
        id: UUID = UUID(),
        calorieTarget: Int = 2000,
        proteinTarget: Double = 150,
        fatTarget: Double = 65,
        carbsTarget: Double = 250,
        lastUpdated: Date = Date()
    ) {
        self.id = id
        self.calorieTarget = calorieTarget
        self.proteinTarget = proteinTarget
        self.fatTarget = fatTarget
        self.carbsTarget = carbsTarget
        self.lastUpdated = lastUpdated
    }
}