import SwiftUI

struct WaveformView: View {
    let audioLevel: Float
    
    // Number of bars for the waveform
    private let barCount = 40
    // Animation namespace for synchronized effects
    @Namespace private var animationNamespace
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<barCount, id: \.self) { index in
                let intensity = calculateBarIntensity(for: index)
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.blue)
                    .frame(
                        width: 4,
                        height: CGFloat(intensity) * 200
                    )
                    .matchedGeometryEffect(
                        id: "bar\(index)",
                        in: animationNamespace
                    )
                    .animation(
                        .spring(response: 0.3, dampingFraction: 0.8),
                        value: audioLevel
                    )
            }
        }
        .frame(height: 200)
        .padding(.horizontal, 20)
    }
    
    /// Calculate intensity for each bar based on audio level and position
    private func calculateBarIntensity(for index: Int) -> Float {
        let normalizedPosition = Float(index) / Float(barCount)
        
        // Create a pulsing effect based on audio level
        let baseIntensity = max(0.1, audioLevel)
        
        // Add some variation across bars for visual interest
        let variation = sin(normalizedPosition * .pi * 2) * 0.3 + 0.7
        
        // Calculate final intensity
        let intensity = baseIntensity * variation
        
        return min(intensity, 1.0)
    }
}

#Preview {
    WaveformView(audioLevel: 0.7)
}