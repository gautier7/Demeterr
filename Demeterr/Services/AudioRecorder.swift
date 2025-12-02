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
    private var converter: AVAudioConverter?
    private var outputFormat: AVAudioFormat?

    func requestPermission() async -> Bool {
        await withCheckedContinuation { continuation in
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
    }

    func setupAudioSession() async throws {
        audioSession = AVAudioSession.sharedInstance()
        try audioSession?.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
        try audioSession?.setActive(true)
    }

    func startRecording() throws {
        guard !isRecording else { return }

        // Create audio engine
        audioEngine = AVAudioEngine()

        guard let audioEngine = audioEngine else { return }

        // Get input node and its format
        let inputNode = audioEngine.inputNode
        let inputFormat = inputNode.inputFormat(forBus: 0)
        
        print("🎙️ Input format: \(inputFormat)")

        // Create output format for the file (16kHz mono PCM for better compatibility)
        guard let outputFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: 16000, channels: 1, interleaved: false) else {
            throw NSError(domain: "AudioRecorder", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create output format"])
        }
        self.outputFormat = outputFormat
        
        print("🎙️ Output format: \(outputFormat)")

        // Create converter
        guard let converter = AVAudioConverter(from: inputFormat, to: outputFormat) else {
            throw NSError(domain: "AudioRecorder", code: -2, userInfo: [NSLocalizedDescriptionKey: "Failed to create audio converter"])
        }
        self.converter = converter

        // Create temporary file URL - use WAV format for better compatibility
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = UUID().uuidString + ".wav"
        let fileURL = tempDir.appendingPathComponent(fileName)

        // Create audio file with PCM format (WAV)
        audioFile = try AVAudioFile(forWriting: fileURL, settings: [
            AVFormatIDKey: kAudioFormatLinearPCM,
            AVSampleRateKey: 16000,
            AVNumberOfChannelsKey: 1,
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsFloatKey: false,
            AVLinearPCMIsBigEndianKey: false
        ])
        
        print("🎙️ Audio file created at: \(fileURL)")

        // Install tap on input node
        inputNode.installTap(onBus: 0, bufferSize: 4096, format: inputFormat) { [weak self] buffer, time in
            self?.calculateLevel(from: buffer)
            self?.convertAndWriteBuffer(buffer)
        }

        // Start engine
        try audioEngine.start()
        isRecording = true
        print("🎙️ Recording started")
    }
    
    private func convertAndWriteBuffer(_ inputBuffer: AVAudioPCMBuffer) {
        guard let converter = converter,
              let outputFormat = outputFormat,
              let audioFile = audioFile else { return }
        
        // Calculate output frame capacity based on sample rate ratio
        let inputSampleRate = inputBuffer.format.sampleRate
        let outputSampleRate = outputFormat.sampleRate
        let ratio = outputSampleRate / inputSampleRate
        let outputFrameCapacity = AVAudioFrameCount(Double(inputBuffer.frameLength) * ratio)
        
        guard let outputBuffer = AVAudioPCMBuffer(pcmFormat: outputFormat, frameCapacity: outputFrameCapacity) else {
            print("❌ Failed to create output buffer")
            return
        }
        
        var error: NSError?
        let inputBlock: AVAudioConverterInputBlock = { inNumPackets, outStatus in
            outStatus.pointee = .haveData
            return inputBuffer
        }
        
        converter.convert(to: outputBuffer, error: &error, withInputFrom: inputBlock)
        
        if let error = error {
            print("❌ Conversion error: \(error)")
            return
        }
        
        // Write converted buffer to file
        do {
            try audioFile.write(from: outputBuffer)
        } catch {
            print("❌ Error writing audio buffer: \(error)")
        }
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
        converter = nil
        outputFormat = nil
        
        print("🎙️ Recording stopped, file at: \(fileURL?.path ?? "nil")")

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