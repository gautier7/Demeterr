//
//  DashboardView.swift
//  Demeterr
//
//  Created by Kilo Code on 2024.
//

import SwiftUI
import SwiftData

struct DashboardView: View {
    @Query var goals: [DailyGoals]
    @Query var entries: [DailyEntry]
    @Environment(\.modelContext) var modelContext
    
    var dailyGoals: DailyGoals? {
        goals.first
    }
    
    var todayEntries: [DailyEntry] {
        let today = Calendar.current.startOfDay(for: Date())
        return entries
            .filter { $0.date == today }
            .sorted { $0.timestamp > $1.timestamp }
    }
    
    var totals: (calories: Int, protein: Double, fat: Double, carbs: Double) {
        let totalCalories = todayEntries.reduce(0) { $0 + $1.calories }
        let totalProtein = todayEntries.reduce(0) { $0 + $1.protein }
        let totalFat = todayEntries.reduce(0) { $0 + $1.fat }
        let totalCarbs = todayEntries.reduce(0) { $0 + $1.carbs }
        
        return (totalCalories, totalProtein, totalFat, totalCarbs)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Today's Progress")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text(Date().formatted(date: .abbreviated, time: .omitted))
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    
                    // Calorie Progress Ring
                    if let goals = dailyGoals {
                        VStack(spacing: 16) {
                            CalorieProgressRing(
                                current: totals.calories,
                                goal: goals.calorieTarget
                            )
                            .frame(height: 250)
                            
                            // Remaining calories
                            let remaining = max(0, goals.calorieTarget - totals.calories)
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Remaining")
                                        .font(.system(size: 12, weight: .regular))
                                        .foregroundColor(.secondary)
                                    
                                    Text("\(remaining) cal")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.primary)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text("Percentage")
                                        .font(.system(size: 12, weight: .regular))
                                        .foregroundColor(.secondary)
                                    
                                    let percentage = (Double(totals.calories) / Double(goals.calorieTarget)) * 100
                                    Text(String(format: "%.0f%%", percentage))
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.primary)
                                }
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                        
                        // Macro Progress Bars
                        VStack(spacing: 16) {
                            Text("Macronutrients")
                                .font(.system(size: 16, weight: .semibold))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            MacroProgressBar(
                                name: "Protein",
                                current: totals.protein,
                                goal: goals.proteinTarget,
                                unit: "g",
                                color: .blue
                            )
                            
                            MacroProgressBar(
                                name: "Fat",
                                current: totals.fat,
                                goal: goals.fatTarget,
                                unit: "g",
                                color: .orange
                            )
                            
                            MacroProgressBar(
                                name: "Carbs",
                                current: totals.carbs,
                                goal: goals.carbsTarget,
                                unit: "g",
                                color: .purple
                            )
                        }
                        .padding()
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                    
                    // Today's Entries
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Today's Entries")
                            .font(.system(size: 16, weight: .semibold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        if todayEntries.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "fork.knife")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray)
                                
                                Text("No entries yet")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.primary)
                                
                                Text("Add your first meal using the microphone button")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(32)
                            .background(Color.gray.opacity(0.05))
                            .cornerRadius(12)
                        } else {
                            VStack(spacing: 8) {
                                ForEach(todayEntries, id: \.id) { entry in
                                    EntryRowView(entry: entry)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    Spacer()
                        .frame(height: 20)
                }
                .padding(.vertical)
                .onAppear {
                    if goals.isEmpty {
                        let defaultGoals = DailyGoals()
                        modelContext.insert(defaultGoals)
                        try? modelContext.save()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.primary)
                    }
                }
            }
        }
    }
}

// MARK: - Entry Row View
struct EntryRowView: View {
    let entry: DailyEntry
    
    var timeString: String {
        entry.timestamp.formatted(date: .omitted, time: .shortened)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.foodName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text("\(String(format: "%.0f", entry.quantity)) \(entry.unit)")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(entry.calories) cal")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(timeString)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.secondary)
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(8)
    }
}

// MARK: - Settings View Placeholder
struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @Query var goals: [DailyGoals]
    @Environment(\.modelContext) var modelContext
    
    @State private var calorieTarget: String = ""
    @State private var proteinTarget: String = ""
    @State private var fatTarget: String = ""
    @State private var carbsTarget: String = ""
    @State private var showSuccess = false
    
    var isValid: Bool {
        !calorieTarget.isEmpty && !proteinTarget.isEmpty &&
        !fatTarget.isEmpty && !carbsTarget.isEmpty &&
        Int(calorieTarget) != nil && Double(proteinTarget) != nil &&
        Double(fatTarget) != nil && Double(carbsTarget) != nil
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Daily Goals") {
                    TextField("Calorie Target", text: $calorieTarget)
                        .keyboardType(.numberPad)
                    
                    TextField("Protein Target (g)", text: $proteinTarget)
                        .keyboardType(.decimalPad)
                    
                    TextField("Fat Target (g)", text: $fatTarget)
                        .keyboardType(.decimalPad)
                    
                    TextField("Carbs Target (g)", text: $carbsTarget)
                        .keyboardType(.decimalPad)
                }
                
                Section {
                    Button(action: saveGoals) {
                        Text("Save Goals")
                            .frame(maxWidth: .infinity)
                    }
                    .disabled(!isValid)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadGoals()
            }
            .alert("Success", isPresented: $showSuccess) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Your goals have been updated successfully.")
            }
        }
    }
    
    private func loadGoals() {
        if let goal = goals.first {
            calorieTarget = String(goal.calorieTarget)
            proteinTarget = String(goal.proteinTarget)
            fatTarget = String(goal.fatTarget)
            carbsTarget = String(goal.carbsTarget)
        }
    }
    
    private func saveGoals() {
        guard let calories = Int(calorieTarget),
              let protein = Double(proteinTarget),
              let fat = Double(fatTarget),
              let carbs = Double(carbsTarget) else {
            return
        }
        
        if let existingGoal = goals.first {
            existingGoal.calorieTarget = calories
            existingGoal.proteinTarget = protein
            existingGoal.fatTarget = fat
            existingGoal.carbsTarget = carbs
            existingGoal.lastUpdated = Date()
        } else {
            let newGoal = DailyGoals(
                calorieTarget: calories,
                proteinTarget: protein,
                fatTarget: fat,
                carbsTarget: carbs
            )
            modelContext.insert(newGoal)
        }
        
        try? modelContext.save()
        showSuccess = true
    }
}

#Preview {
    DashboardView()
        .modelContainer(for: [DailyEntry.self, DailyGoals.self, CustomFood.self])
}
