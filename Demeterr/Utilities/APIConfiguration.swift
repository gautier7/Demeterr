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

        // Fallback: check environment variable
        if let key = ProcessInfo.processInfo.environment["OPENAI_API_KEY"], !key.isEmpty {
            return key
        }

        fatalError("OpenAI API key not found. Please ensure OPENAI_API_KEY is set in your build configuration via Config.xcconfig file.")
    }()
}