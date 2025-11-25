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

            VoiceInputTestView()
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

struct VoiceInputTestView: View {
    @State private var audioRecorder = AudioRecorder()
    @State private var permissionGranted = false
    @State private var recordedFileURL: URL?

    var body: some View {
        VStack(spacing: 20) {
            Text("Audio Recorder Test")
                .font(.title)

            Text("Permission: \(permissionGranted ? "Granted" : "Not Granted")")
                .foregroundColor(permissionGranted ? .green : .red)

            Text("Recording: \(audioRecorder.isRecording ? "Yes" : "No")")

            Text("Audio Level: \(String(format: "%.2f", audioRecorder.audioLevel))")

            // Visual representation of audio level
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 4)
                    .frame(width: 100, height: 100)

                Circle()
                    .trim(from: 0, to: CGFloat(audioRecorder.audioLevel))
                    .stroke(Color.blue, lineWidth: 4)
                    .frame(width: 100, height: 100)
                    .rotationEffect(.degrees(-90))
            }

            Button(action: {
                Task {
                    permissionGranted = await audioRecorder.requestPermission()
                }
            }) {
                Text("Request Permission")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }

            Button(action: {
                if audioRecorder.isRecording {
                    recordedFileURL = audioRecorder.stopRecording()
                } else {
                    Task {
                        do {
                            try await audioRecorder.setupAudioSession()
                            try audioRecorder.startRecording()
                        } catch {
                            print("Error starting recording: \(error)")
                        }
                    }
                }
            }) {
                Text(audioRecorder.isRecording ? "Stop Recording" : "Start Recording")
                    .padding()
                    .background(audioRecorder.isRecording ? Color.red : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .disabled(!permissionGranted)

            if let url = recordedFileURL {
                Text("Recorded file: \(url.lastPathComponent)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
    }
}

#Preview {
    MainTabView()
}