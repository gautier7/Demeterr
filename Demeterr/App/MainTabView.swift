//
//  MainTabView.swift
//  Demeterr
//
//  Created by Kilo Code on 2024.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "chart.pie.fill")
                }

            VoiceInputView()
                .tabItem {
                    Label("Add Food", systemImage: "mic.fill")
                }

            Text("Food Database")
                .tabItem {
                    Label("Database", systemImage: "fork.knife")
                }

            Text("Settings")
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
    }
}


#Preview {
    MainTabView()
}