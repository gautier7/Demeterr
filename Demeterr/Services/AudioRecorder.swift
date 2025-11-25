import Foundation
import AVFoundation
import Observation

@Observable
class AudioRecorder {
    var isRecording: Bool = false
    var audioLevel: Float = 0.0

    private var audioEngine: AVAudioEngine?
    private var audioFile: AVAudioFile?
    private var audioSession: AVAudioSession?

    func requestPermission() async -> Bool {
        await withCheckedContinuation { continuation in
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
    }

    func setupAudioSession() async throws {
        audioSession = AVAudioSession.sharedInstance()
        try audioSession?.setCategory(.record, mode: .measurement)
        try audioSession?.setActive(true)
    }

    func startRecording() throws {
        guard !isRecording else { return }

        // Create audio engine
        audioEngine = AVAudioEngine()

        guard let audioEngine = audioEngine else { return }

        // Get input node
        let inputNode = audioEngine.inputNode
        let inputFormat = inputNode.inputFormat(forBus: 0)

        // Create temporary file URL
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = UUID().uuidString + ".m4a"
        let fileURL = tempDir.appendingPathComponent(fileName)

        // Create audio file
        audioFile = try AVAudioFile(forWriting: fileURL, settings: [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVSampleRateKey: 16000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ])

        // Install tap on input node
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: inputFormat) { [weak self] buffer, time in
            self?.calculateLevel(from: buffer)
            // Convert and write to file
            if let audioFile = self?.audioFile {
                do {
                    try audioFile.write(from: buffer)
                } catch {
                    print("Error writing audio buffer: \(error)")
                }
            }
        }

        // Start engine
        try audioEngine.start()
        isRecording = true
    }

    func stopRecording() -> URL? {
        guard isRecording else { return nil }

        audioEngine?.stop()
        audioEngine?.inputNode.removeTap(onBus: 0)
        isRecording = false
        audioLevel = 0.0

        let fileURL = audioFile?.url
        audioFile = nil
        audioEngine = nil

        return fileURL
    }

    private func calculateLevel(from buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData?[0] else { return }

        let channelDataArray = Array(UnsafeBufferPointer(start: channelData, count: Int(buffer.frameLength)))

        // Calculate RMS
        let rms = sqrt(channelDataArray.map { $0 * $0 }.reduce(0, +) / Float(buffer.frameLength))

        // Normalize to 0-1 range (adjust multiplier as needed)
        audioLevel = min(rms * 10, 1.0)
    }
}