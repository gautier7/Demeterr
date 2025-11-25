# Demeterr - Technology Stack & Implementation Guide

## Overview
This document outlines the specific technologies and frameworks to use for each feature of the Demeterr nutrition tracking app. The project is built on iOS using SwiftUI and SwiftData.

---

## 🏗️ Core Architecture

### Foundation
| Component | Technology | Reason |
|-----------|-----------|--------|
| **UI Framework** | SwiftUI | Already integrated; modern, declarative UI; native iOS support |
| **Data Persistence** | SwiftData | Already integrated; modern replacement for Core Data; simpler API |
| **Language** | Swift 5.9+ | Required for SwiftUI and SwiftData; type-safe |
| **Minimum iOS** | iOS 17.0+ | Required for SwiftData; aligns with project setup |

---

## 📱 Feature-by-Feature Technology Stack

### 1. **Voice Recording & Audio Capture**

**Feature**: User taps microphone button to record food entry

| Aspect | Technology | Implementation Details |
|--------|-----------|------------------------|
| **Audio Recording** | AVFoundation (AVAudioEngine) | Native iOS framework for audio capture |
| **Audio Format** | M4A (AAC codec) | Compressed format; good quality at small file size |
| **Sample Rate** | 16kHz | Sufficient for speech recognition; reduces file size |
| **Microphone Permission** | AVAudioSession + Info.plist | Request microphone access on first launch |
| **Visual Feedback** | SwiftUI Animation | Animated waveform or pulsing microphone icon |
| **Recording State** | @State property | Track recording/stopped state in SwiftUI |

**Key Files to Create**:
- `AudioRecorder.swift` - Handles AVAudioEngine setup and recording
- `AudioRecorderView.swift` - SwiftUI view for recording interface

**Dependencies**: None (AVFoundation is built-in)

---

### 2. **Speech-to-Text Transcription**

**Feature**: Convert audio to text using OpenAI gpt-4o-mini-transcribe

| Aspect | Technology | Implementation Details |
|--------|-----------|------------------------|
| **API Service** | OpenAI API (gpt-4o-mini-transcribe) | Official OpenAI endpoint for audio transcription |
| **HTTP Client** | URLSession | Built-in iOS networking; sufficient for API calls |
| **Request Format** | multipart/form-data | Required for sending audio files to OpenAI |
| **Response Parsing** | Codable + JSONDecoder | Swift's native JSON parsing |
| **Error Handling** | Custom Result type | Handle network errors, API errors gracefully |
| **Async/Await** | Swift Concurrency | Modern async pattern; built into Swift 5.5+ |

**Key Files to Create**:
- `OpenAIService.swift` - Handles all OpenAI API calls
- `TranscriptionRequest.swift` - Models for API requests/responses
- `APIConfiguration.swift` - Stores API key from project files

**API Key Management**:
- Store in `Config.xcconfig` file (not in code)
- Load at build time via build settings
- Never expose in app UI or logs

**Dependencies**: None (URLSession is built-in)

---

### 3. **AI Nutritional Analysis**

**Feature**: Parse food text and extract nutritional data using GPT-4o-mini

| Aspect | Technology | Implementation Details |
|--------|-----------|------------------------|
| **API Service** | OpenAI API (GPT-4o-mini) | Same OpenAI account; cost-effective model |
| **HTTP Client** | URLSession | Same as transcription service |
| **Prompt Engineering** | Custom system prompt | Structured JSON output with specific schema |
| **Response Format** | JSON Mode | Ensures parseable structured output |
| **Response Model** | Codable struct | Define FoodEntry, NutritionData models |
| **Async Processing** | Swift Concurrency | Non-blocking API calls |

**Key Files to Create**:
- `NutritionAnalysisService.swift` - Handles GPT-4o-mini calls
- `FoodEntry.swift` - Models for parsed food data
- `NutritionData.swift` - Nutritional values model

**JSON Response Schema**:
```swift
struct AnalysisResponse: Codable {
    let foods: [FoodItem]
    let total: NutritionTotal
}

struct FoodItem: Codable {
    let name: String
    let quantity: Double
    let unit: String
    let calories: Int
    let protein: Double
    let fat: Double
    let carbs: Double
}

struct NutritionTotal: Codable {
    let calories: Int
    let protein: Double
    let fat: Double
    let carbs: Double
}
```

**Dependencies**: None (URLSession is built-in)

---

### 4. **Data Storage & Persistence**

**Feature**: Store food entries, custom foods, and user goals locally

| Aspect | Technology | Implementation Details |
|--------|-----------|------------------------|
| **Database** | SwiftData | Already integrated; modern, type-safe |
| **Models** | @Model macro | Define data entities with SwiftData |
| **Relationships** | SwiftData relationships | Link entries to dates, custom foods |
| **Queries** | @Query property wrapper | Fetch and filter data in SwiftUI views |
| **Transactions** | ModelContext | Handle save/delete operations |

**Key Data Models**:
- `DailyEntry.swift` - Individual food entry (name, quantity, nutrition, timestamp)
- `CustomFood.swift` - User-created food definitions (name, nutrition per 100g)
- `DailyGoals.swift` - User's target values (calories, protein, fat, carbs)
- `DailySummary.swift` - Cached daily totals (for performance)

**Example Model Structure**:
```swift
@Model
final class DailyEntry {
    var foodName: String
    var quantity: Double
    var unit: String
    var calories: Int
    var protein: Double
    var fat: Double
    var carbs: Double
    var timestamp: Date
    var date: Date // For grouping by day
    var source: String // "custom" or "estimated"
}

@Model
final class CustomFood {
    var name: String
    var caloriesPer100g: Int
    var proteinPer100g: Double
    var fatPer100g: Double
    var carbsPer100g: Double
    var createdDate: Date
}

@Model
final class DailyGoals {
    var calorieTarget: Int
    var proteinTarget: Double
    var fatTarget: Double
    var carbsTarget: Double
    var lastUpdated: Date
}
```

**Dependencies**: None (SwiftData is built-in)

---

### 5. **Dashboard & Progress Visualization**

**Feature**: Display daily progress with calorie ring and macro bars

| Aspect | Technology | Implementation Details |
|--------|-----------|------------------------|
| **Progress Ring** | SwiftUI Canvas + Circle | Custom circular progress indicator |
| **Progress Bars** | SwiftUI ProgressView | Built-in progress bar component |
| **Charts** | SwiftUI Charts framework | Optional: for historical data visualization |
| **Color Coding** | SwiftUI Color + Conditional logic | Green/Yellow/Red based on progress |
| **Real-time Updates** | @Query + @State | Automatic UI refresh when data changes |
| **Animations** | SwiftUI .animation() | Smooth transitions when values update |

**Key Files to Create**:
- `DashboardView.swift` - Main dashboard screen
- `CalorieProgressRing.swift` - Custom circular progress indicator
- `MacroProgressBar.swift` - Reusable progress bar component
- `DailyEntryListView.swift` - List of today's entries

**Key Calculations**:
```swift
let progressPercentage = (currentValue / goalValue) * 100
let remainingValue = max(0, goalValue - currentValue)
let statusColor = progressPercentage > 100 ? .red : 
                  progressPercentage > 90 ? .yellow : .green
```

**Dependencies**: None (SwiftUI Charts is built-in)

---

### 6. **Food Database Management**

**Feature**: Create, edit, and search custom foods

| Aspect | Technology | Implementation Details |
|--------|-----------|------------------------|
| **CRUD Operations** | SwiftData ModelContext | Create, read, update, delete custom foods |
| **Search** | SwiftUI SearchField + @Query filter | Filter custom foods by name |
| **Fuzzy Matching** | String similarity algorithm | Optional: for suggesting similar foods |
| **List Display** | SwiftUI List + ForEach | Display custom foods with edit/delete options |
| **Form Input** | SwiftUI Form + TextField | Input fields for food name and nutrition values |

**Key Files to Create**:
- `FoodDatabaseView.swift` - Main food database screen
- `AddCustomFoodView.swift` - Form to add new custom food
- `EditCustomFoodView.swift` - Form to edit existing food
- `FoodSearchView.swift` - Search and filter custom foods

**Dependencies**: None (all built-in SwiftUI)

---

### 7. **Settings & Goal Configuration**

**Feature**: Allow users to set custom nutrition targets

| Aspect | Technology | Implementation Details |
|--------|-----------|------------------------|
| **Settings Storage** | SwiftData (DailyGoals model) | Persist user targets |
| **Settings UI** | SwiftUI Form + Stepper/TextField | Input fields for calorie/macro targets |
| **Validation** | Custom validation logic | Ensure positive values, reasonable ranges |
| **Persistence** | ModelContext.save() | Auto-save when user updates values |

**Key Files to Create**:
- `SettingsView.swift` - Settings screen
- `GoalSettingsView.swift` - Goal configuration form

**Dependencies**: None (all built-in SwiftUI)

---

### 8. **Navigation & App Structure**

**Feature**: Navigate between dashboard, voice input, database, and settings

| Aspect | Technology | Implementation Details |
|--------|-----------|------------------------|
| **Navigation** | NavigationStack (iOS 16+) | Modern navigation pattern |
| **Tab Navigation** | TabView | Bottom tabs for main sections |
| **State Management** | @State, @StateObject | Manage navigation state |
| **Deep Linking** | NavigationLink | Link between screens |

**App Structure**:
```
DemeterrApp
├── MainTabView
│   ├── DashboardView (Tab 1)
│   ├── VoiceInputView (Tab 2)
│   ├── FoodDatabaseView (Tab 3)
│   └── SettingsView (Tab 4)
```

**Key Files to Create**:
- `MainTabView.swift` - Tab navigation container
- `AppCoordinator.swift` - Optional: centralized navigation logic

**Dependencies**: None (SwiftUI navigation is built-in)

---

## 🔐 API Key Management

### Implementation Strategy

**File Structure**:
```
Demeterr/
├── Config.xcconfig (NOT in git)
├── Config.example.xcconfig (template in git)
└── APIConfiguration.swift
```

**Config.xcconfig** (local, not committed):
```
OPENAI_API_KEY = your_actual_key_here
```

**Config.example.xcconfig** (template):
```
OPENAI_API_KEY = YOUR_API_KEY_HERE
```

**APIConfiguration.swift**:
```swift
struct APIConfiguration {
    static let openAIKey: String = {
        guard let key = Bundle.main.infoDictionary?["OPENAI_API_KEY"] as? String else {
            fatalError("API key not found in configuration")
        }
        return key
    }()
}
```

**Build Settings**:
- Link Config.xcconfig in Xcode project settings
- Use `INFOPLIST_KEY_OPENAI_API_KEY = "$(OPENAI_API_KEY)"` in build settings
- Info.plist is generated automatically (`GENERATE_INFOPLIST_FILE = YES`)

---

## 📦 External Dependencies

### Required
- **None** - All features use built-in iOS frameworks

### Optional (for future enhancements)
- **Alamofire** - If you want more advanced HTTP handling (not needed for MVP)
- **SwiftyJSON** - If JSON parsing becomes complex (not needed; Codable is sufficient)
- **Kingfisher** - If adding image caching (not needed for MVP)

---

## 🔄 Data Flow Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    USER INTERFACE (SwiftUI)                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │  Dashboard   │  │ Voice Input  │  │Food Database │      │
│  │   View       │  │   View       │  │   View       │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                  SERVICE LAYER (Swift)                      │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │AudioRecorder │  │OpenAIService │  │Nutrition     │      │
│  │              │  │              │  │AnalysisService│     │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                   DATA LAYER (SwiftData)                    │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │DailyEntry   │  │CustomFood    │  │DailyGoals    │      │
│  │             │  │              │  │              │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                  EXTERNAL SERVICES                          │
│  ┌──────────────┐  ┌──────────────┐                        │
│  │ OpenAI API   │  │ Local Storage│                        │
│  │(Transcribe   │  │ (SwiftData)  │                        │
│  │+ GPT-4o-mini)│  │              │                        │
│  └──────────────┘  └──────────────┘                        │
└─────────────────────────────────────────────────────────────┘
```

---

## 🚀 Implementation Roadmap

### Phase 1: Core Data & UI (Week 1)
- [ ] Define SwiftData models (DailyEntry, CustomFood, DailyGoals)
- [ ] Create dashboard view with progress visualization
- [ ] Create settings view for goal configuration
- [ ] Implement basic navigation structure

**Technologies**: SwiftUI, SwiftData

### Phase 2: Voice & Transcription (Week 2)
- [ ] Implement audio recording with AVFoundation
- [ ] Create voice input UI with recording feedback
- [ ] Integrate OpenAI transcription API
- [ ] Handle transcription errors and retries

**Technologies**: AVFoundation, URLSession, OpenAI API

### Phase 3: AI Analysis & Auto-Save (Week 3)
- [ ] Integrate GPT-4o-mini for nutritional analysis
- [ ] Implement automatic entry saving (no confirmation)
- [ ] Update dashboard in real-time
- [ ] Add error handling and user feedback

**Technologies**: URLSession, OpenAI API, SwiftData

### Phase 4: Food Database (Week 4)
- [ ] Create food database management UI
- [ ] Implement CRUD operations for custom foods
- [ ] Add search and fuzzy matching
- [ ] Integrate database lookup in analysis flow

**Technologies**: SwiftUI, SwiftData

### Phase 5: Polish & Testing (Week 5)
- [ ] Comprehensive error handling
- [ ] Performance optimization
- [ ] User testing and feedback
- [ ] App Store preparation

**Technologies**: XCTest, SwiftUI Preview

---

## 💡 Best Practices & Recommendations

### Code Organization
```
Demeterr/
├── App/
│   ├── DemeterrApp.swift
│   └── MainTabView.swift
├── Views/
│   ├── Dashboard/
│   ├── VoiceInput/
│   ├── FoodDatabase/
│   └── Settings/
├── Services/
│   ├── AudioRecorder.swift
│   ├── OpenAIService.swift
│   └── NutritionAnalysisService.swift
├── Models/
│   ├── DailyEntry.swift
│   ├── CustomFood.swift
│   ├── DailyGoals.swift
│   └── APIModels.swift
├── Utilities/
│   ├── APIConfiguration.swift
│   └── Extensions.swift
└── Resources/
    └── Config.xcconfig
```

### Error Handling
- Use Result type for API calls
- Show user-friendly error messages
- Log errors for debugging
- Implement retry logic for network failures

### Performance
- Use @Query with filters to avoid loading all data
- Cache API responses when appropriate
- Lazy load views with NavigationStack
- Use .onAppear() for data fetching

### Testing
- Unit test service layer (OpenAIService, AudioRecorder)
- UI test main flows (voice input → save → dashboard update)
- Test data models with sample data

---

## 📋 Summary Table

| Feature | Primary Tech | Secondary Tech | Complexity |
|---------|-------------|----------------|-----------|
| Voice Recording | AVFoundation | SwiftUI | Medium |
| Transcription | URLSession + OpenAI | Codable | Low |
| AI Analysis | URLSession + OpenAI | Codable | Low |
| Data Storage | SwiftData | @Model | Low |
| Dashboard | SwiftUI | Canvas | Medium |
| Food Database | SwiftData | SwiftUI | Low |
| Settings | SwiftUI | SwiftData | Low |
| Navigation | SwiftUI | TabView | Low |

---

## ✅ Next Steps

1. **Review this document** - Ensure all technologies align with your vision
2. **Set up API key management** - Create Config.xcconfig and APIConfiguration.swift
3. **Create data models** - Define SwiftData entities
4. **Build service layer** - Implement OpenAIService and AudioRecorder
5. **Develop UI views** - Create SwiftUI screens following the structure above
6. **Integrate features** - Connect services to views
7. **Test thoroughly** - Verify all flows work correctly

---

*This technical document provides a clear roadmap for implementation using proven, modern iOS technologies. All recommendations prioritize quick implementation and maintainability.*
