//
//  CalorieProgressRing.swift
//  Demeterr
//
//  Created by Kilo Code on 2024.
//

import SwiftUI

struct CalorieProgressRing: View {
    let current: Int
    let goal: Int
    
    var progress: Double {
        guard goal > 0 else { return 0 }
        return Double(current) / Double(goal)
    }
    
    var progressColor: Color {
        let percentage = progress * 100
        if percentage > 100 {
            return .red
        } else if percentage > 90 {
            return .yellow
        } else {
            return .green
        }
    }
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 20)
            
            // Progress circle
            Circle()
                .trim(from: 0, to: min(progress, 1.0))
                .stroke(progressColor, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.5), value: progress)
            
            // Center text
            VStack(spacing: 4) {
                Text("\(current)")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.primary)
                
                Text("/ \(goal)")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.secondary)
                
                Text("calories")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.secondary)
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

#Preview {
    VStack(spacing: 20) {
        CalorieProgressRing(current: 1500, goal: 2000)
            .frame(height: 250)
        
        CalorieProgressRing(current: 1900, goal: 2000)
            .frame(height: 250)
        
        CalorieProgressRing(current: 2100, goal: 2000)
            .frame(height: 250)
    }
    .padding()
}
