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
            Text("Dashboard")
                .tabItem {
                    Label("Dashboard", systemImage: "chart.pie.fill")
                }

            Text("Voice Input")
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