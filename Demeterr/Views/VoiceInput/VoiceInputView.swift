import SwiftUI
import SwiftData

struct VoiceInputView: View {
    @Environment(\.modelContext) var modelContext
    @Query var customFoods: [CustomFood]
    
    @State private var audioRecorder = AudioRecorder()
    @State private var isProcessing = false
    @State private var errorMessage: String?
    @State private var showError = false
    @State private var successMessage: String?
    @State private var showSuccess = false
    
    private let openAIService = OpenAIService()
    
    var body: some View {
        VStack(spacing: 40) {
            // Title
            Text("Add Food Entry")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 40)

            Spacer()

            // Recording Visualization
            if audioRecorder.isRecording {
                WaveformView(audioLevel: audioRecorder.audioLevel)
                    .frame(height: 200)
            } else {
                Image(systemName: "mic.circle.fill")
                    .resizable()
                    .frame(width: 120, height: 120)
                    .foregroundColor(.blue)
                    .opacity(isProcessing ? 0.5 : 1.0)
            }

            // Recording Button
            Button(action: toggleRecording) {
                ZStack {
                    Circle()
                        .fill(audioRecorder.isRecording ? Color.red : Color.blue)
                        .frame(width: 80, height: 80)
                        .shadow(radius: 5)

                    Image(systemName: audioRecorder.isRecording ? "stop.fill" : "mic.fill")
                        .foregroundColor(.white)
                        .font(.title)
                }
            }
            .disabled(isProcessing)

            // Status Text
            if isProcessing {
                HStack(spacing: 8) {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Processing...")
                        .foregroundColor(.secondary)
                }
            } else if audioRecorder.isRecording {
                Text("Recording... Tap to stop")
                    .foregroundColor(.secondary)
            } else {
                Text("Tap microphone to start recording")
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Error Message
            if showError, let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            // Success Message
            if showSuccess, let successMessage = successMessage {
                Text(successMessage)
                    .foregroundColor(.green)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 40)
        .alert("Microphone Permission Required", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            if let errorMessage = errorMessage {
                Text(errorMessage)
            }
        }
    }

    private func toggleRecording() {
        if audioRecorder.isRecording {
            stopAndProcess()
        } else {
            Task {
                await startRecording()
            }
        }
    }

    private func startRecording() async {
        do {
            // Request permission if needed
            let hasPermission = await audioRecorder.requestPermission()
            if !hasPermission {
                errorMessage = "Microphone access is required to record food entries. Please enable microphone permission in Settings."
                showError = true
                return
            }

            // Setup audio session
            try await audioRecorder.setupAudioSession()

            // Start recording
            try audioRecorder.startRecording()

        } catch {
            errorMessage = "Failed to start recording: \(error.localizedDescription)"
            showError = true
        }
    }

    private func stopAndProcess() {
        guard let audioFileURL = audioRecorder.stopRecording() else {
            errorMessage = "Failed to save audio recording"
            showError = true
            return
        }
        
        isProcessing = true
        showError = false
        showSuccess = false

        Task {
            do {
                // Step 1: Transcribe audio
                let transcribedText = try await openAIService.transcribeAudio(fileURL: audioFileURL)
                
                // Step 2: Analyze nutrition
                let analysisResponse = try await openAIService.analyzeNutrition(
                    text: transcribedText,
                    customFoods: customFoods
                )
                
                // Step 3: Create DailyEntry objects from analysis results
                for foodItem in analysisResponse.foods {
                    let entry = DailyEntry(
                        foodName: foodItem.name,
                        quantity: foodItem.quantity,
                        unit: foodItem.unit,
                        calories: foodItem.calories,
                        protein: foodItem.protein,
                        fat: foodItem.fat,
                        carbs: foodItem.carbs,
                        source: "estimated"
                    )
                    modelContext.insert(entry)
                }
                
                // Step 4: Save to database
                try modelContext.save()
                
                // Step 5: Show success feedback
                let foodCount = analysisResponse.foods.count
                successMessage = "✓ Added \(foodCount) food item\(foodCount > 1 ? "s" : "") (\(analysisResponse.total.calories) cal)"
                showSuccess = true
                
                // Clear success message after 2 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    showSuccess = false
                }
                
                // Clean up audio file
                try? FileManager.default.removeItem(at: audioFileURL)
                
            } catch {
                errorMessage = "Failed to process audio: \(error.localizedDescription)"
                showError = true
                
                // Clean up audio file on error
                try? FileManager.default.removeItem(at: audioFileURL)
            }
            
            isProcessing = false
        }
    }
}

#Preview {
    VoiceInputView()
        .modelContainer(for: [DailyEntry.self, CustomFood.self, DailyGoals.self])
}
