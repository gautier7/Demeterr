//
//  APIConfiguration.swift
//  Demeterr
//
//  Created by Kilo Code on 2024.
//

import Foundation

/// Configuration for API keys and external service settings
struct APIConfiguration {
    /// OpenAI API key loaded from build configuration
    static let openAIKey: String = {
        // Try to get from Info.plist first (for generated builds)
        if let key = Bundle.main.infoDictionary?["OPENAI_API_KEY"] as? String, !key.isEmpty {
            return key
        }

        // Fallback: try to read from Config.xcconfig file directly
        // This is useful during development when the config file might not be processed into Info.plist
        if let configPath = Bundle.main.path(forResource: "Config", ofType: "xcconfig"),
           let content = try? String(contentsOfFile: configPath),
           let keyLine = content.components(separatedBy: "\n").first(where: { $0.hasPrefix("OPENAI_API_KEY") }),
           let key = keyLine.components(separatedBy: "=").last?.trimmingCharacters(in: .whitespaces) {
            return key
        }

        fatalError("OpenAI API key not found in configuration. Please check Config.xcconfig setup.")
    }()
}