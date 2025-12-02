//
//  MacroProgressBar.swift
//  Demeterr
//
//  Created by Kilo Code on 2024.
//

import SwiftUI

struct MacroProgressBar: View {
    let name: String
    let current: Double
    let goal: Double
    let unit: String
    let color: Color
    
    var progress: Double {
        guard goal > 0 else { return 0 }
        return current / goal
    }
    
    var progressColor: Color {
        let percentage = progress * 100
        if percentage > 100 {
            return .red
        } else if percentage > 90 {
            return .yellow
        } else {
            return color
        }
    }
    
    var formattedCurrent: String {
        if current.truncatingRemainder(dividingBy: 1) == 0 {
            return String(Int(current))
        }
        return String(format: "%.1f", current)
    }
    
    var formattedGoal: String {
        if goal.truncatingRemainder(dividingBy: 1) == 0 {
            return String(Int(goal))
        }
        return String(format: "%.1f", goal)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header with name and values
            HStack {
                Text(name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(formattedCurrent) / \(formattedGoal) \(unit)")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            
            // Progress bar
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 12)
                
                // Progress
                RoundedRectangle(cornerRadius: 8)
                    .fill(progressColor)
                    .frame(width: max(0, CGFloat(min(progress, 1.0)) * (UIScreen.main.bounds.width - 32)), height: 12)
                    .animation(.easeInOut(duration: 0.5), value: progress)
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        MacroProgressBar(
            name: "Protein",
            current: 120,
            goal: 150,
            unit: "g",
            color: .blue
        )
        
        MacroProgressBar(
            name: "Fat",
            current: 58,
            goal: 65,
            unit: "g",
            color: .orange
        )
        
        MacroProgressBar(
            name: "Carbs",
            current: 240,
            goal: 250,
            unit: "g",
            color: .purple
        )
        
        MacroProgressBar(
            name: "Protein (Over)",
            current: 180,
            goal: 150,
            unit: "g",
            color: .blue
        )
    }
    .padding()
}
