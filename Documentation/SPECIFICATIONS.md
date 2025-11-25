# iOS Nutrition Tracker App - Functional Specifications

## 📱 Executive Summary

**App Name**: Demeterr  
**Platform**: iOS (iPhone)  
**Core Purpose**: Voice-controlled daily nutrition tracking with AI-powered food recognition and analysis

### Vision Statement
Demeterr simplifies nutrition tracking by allowing users to speak their meals naturally and receive instant, accurate nutritional feedback. The app combines voice recognition, artificial intelligence, and a personalized food database to make calorie and macro tracking effortless.

### Key Value Propositions
- **Effortless Input**: Speak your meals instead of typing or searching
- **Intelligent Recognition**: AI understands natural language and calculates nutrition automatically
- **Personal Accuracy**: Custom food database for your frequently eaten items
- **Real-time Feedback**: Instant progress tracking against daily goals
- **Simple Interface**: One-screen overview of your daily nutrition

---

## 🎯 User Personas & Use Cases

### Primary User Persona: Health-Conscious Professional
**Profile**: 25-45 years old, busy lifestyle, wants to track nutrition but finds traditional apps too time-consuming

**Goals**:
- Track daily calorie and macro intake without spending 10+ minutes per meal
- Maintain consistency with nutrition goals
- Understand what they're eating without complex calculations

**Pain Points with Current Solutions**:
- Too many steps to log a meal (search, select, adjust portions, confirm)
- Generic food databases don't match their specific foods
- Tedious manual entry discourages consistent tracking

**How Demeterr Solves This**:
- One-tap voice recording captures entire meal in seconds
- Personal food database ensures accuracy for regular meals
- AI handles all calculations automatically

### Use Case Scenarios

#### Scenario 1: Quick Food Entry
**Context**: User wants to log food at any time

**Flow**:
1. Opens app
2. Taps microphone button
3. Says "200 grams chicken breast and 100 grams rice"
4. AI processes and automatically adds to database (3 seconds)
5. Sees updated daily progress

**Time**: ~10 seconds total

#### Scenario 2: Custom Food Entry
**Context**: User regularly eats homemade protein pancakes

**Flow**:
1. Opens food database
2. Creates new entry: "Protein Pancakes"
3. Enters nutrition per 100g (from recipe calculation)
4. Saves to personal database
5. Future voice entries automatically recognize this food

**Benefit**: One-time setup, lifetime accuracy

#### Scenario 3: Daily Goal Tracking
**Context**: User wants to hit 2000 calories, 150g protein daily

**Flow**:
1. Sets goals in settings (one-time)
2. Throughout day, adds meals via voice
3. Dashboard shows real-time progress with visual indicators
4. Knows exactly how much more to eat to hit targets

---

## 🔄 Complete System Flow

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        USER INTERFACE                        │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   Dashboard  │  │ Voice Input  │  │Food Database │      │
│  │   (Main)     │  │   Screen     │  │  Management  │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                     APPLICATION LOGIC                        │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │Voice Handler │  │  LLM Service │  │Data Manager  │      │
│  │   (Audio)    │  │  (Analysis)  │  │  (Storage)   │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      DATA & SERVICES                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ Local Storage│  │  OpenAI API  │  │User Database │      │
│  │  (Core Data) │  │(gpt-4o-mini   │  │ (Custom Foods)│     │
│  │              │  │  transcribe)  │  │              │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
```

### End-to-End Process Flow

#### Phase 1: Voice Capture
```
User Action → Audio Recording → Audio File Created
```

**What Happens**:
- User taps microphone button
- iOS AVFoundation captures audio in real-time
- Visual feedback shows recording in progress
- User speaks naturally: "200g chicken and 100g rice"
- Audio saved as temporary M4A file

**Duration**: 2-5 seconds

#### Phase 2: Speech-to-Text Transcription
```
Audio File → OpenAI gpt-4o-mini-transcribe → Text Transcription
```

**What Happens**:
- Audio file sent to OpenAI gpt-4o-mini-transcribe API
- API converts speech to text
- Returns transcribed string: "200g chicken and 100g rice"
- Text automatically processed (no user display)

**Duration**: 1-2 seconds

**Error Handling**:
- If transcription fails: Prompt user to speak again or type manually
- If audio unclear: Show "Could not understand" message with retry option

#### Phase 3: Food Database Lookup
```
Transcribed Text → Check User Database → Match or Not Found
```

**What Happens**:
- System searches user's custom food database first
- Looks for exact or fuzzy matches on food names
- If "chicken breast" exists in user database: Use those exact values
- If not found: Proceed to AI analysis

**Decision Logic**:
- **Match Found**: Use user's custom nutritional values (100% accurate)
- **No Match**: Use AI estimation (flag as "estimated")

#### Phase 4: AI Nutritional Analysis
```
Text + Context → GPT-4o-mini → Structured JSON Response
```

**What Happens**:
- Text sent to GPT-4o-mini with specialized prompt
- AI parses food items, quantities, and units
- AI calculates nutritional values based on knowledge base
- Returns structured JSON with all nutritional data

**AI Processing Logic**:
1. **Parse Input**: Extract food names, quantities, units
2. **Identify Foods**: Recognize each food item mentioned
3. **Calculate Nutrition**: Apply nutritional values per quantity
4. **Sum Totals**: Calculate total calories, protein, fat, carbs
5. **Format Response**: Return structured JSON

**Example AI Reasoning**:
```
Input: "200g chicken breast and 100g rice"

AI Analysis:
- Food 1: Chicken breast
  - Quantity: 200g
  - Per 100g: 165 cal, 31g protein, 3.6g fat, 0g carbs
  - For 200g: 330 cal, 62g protein, 7.2g fat, 0g carbs

- Food 2: Rice (cooked)
  - Quantity: 100g
  - Per 100g: 130 cal, 2.7g protein, 0.3g fat, 28g carbs
  - For 100g: 130 cal, 2.7g protein, 0.3g fat, 28g carbs

Total: 460 cal, 64.7g protein, 7.5g fat, 28g carbs
```

**Duration**: 2-3 seconds

#### Phase 5: Automatic Data Storage
```
Processed Results → Save to Database → Update Dashboard
```

**What Happens**:
- AI analysis completes automatically
- Entry saved to local Core Data database without user confirmation
- Timestamped with current date/time
- Linked to today's date for daily tracking
- Dashboard automatically refreshes with new totals

**Data Stored**:
- Food name
- Quantity and unit
- Nutritional values (calories, protein, fat, carbs)
- Timestamp
- Source (custom or estimated)
- Date

#### Phase 6: Progress Update
```
New Entry → Recalculate Totals → Update Visual Progress
```

**What Happens**:
- System sums all entries for current day
- Compares against user's daily goals
- Updates progress ring/bars
- Shows percentage of goals achieved
- Highlights if over/under targets

**Visual Feedback**:
- Green: On track or under goal
- Yellow: Approaching goal (90-100%)
- Red: Over goal (>100%)

---

## 🎨 User Interface & Experience Design

### Screen Hierarchy

```
Main Dashboard (Home)
├── Daily Progress Overview
│   ├── Calorie Progress Ring (Main indicator)
│   ├── Protein Progress Bar
│   ├── Fat Progress Bar
│   └── Carbs Progress Bar
├── Today's Food Entries
│   ├── All entries (time-agnostic)
│   └── [+] Add Food (Voice)
├── Quick Actions
│   ├── [⚙️] Settings
│   └── Food Database
└── Navigation
    ├── Target Goals
    ├── History
    └── Food Database

Voice Input Screen
├── Recording Interface
│   ├── Microphone Animation
│   └── Recording Timer
├── Actions
│   ├── [●] Start/Stop Recording
│   └── [⌨️] Type Manually
└── Back to Dashboard

Food Database Screen
├── Search Bar
├── Custom Foods List
│   ├── Food Item 1
│   ├── Food Item 2
│   └── [+] Add New Food
└── Food Detail/Edit View

Settings Screen
├── Target Goals
│   ├── Calorie Target
│   ├── Protein Target
│   ├── Fat Target
│   └── Carbs Target
├── App Preferences
└── Data Management
```

### User Interaction Patterns

#### Primary Interaction: Voice Input
**Design Philosophy**: One-tap access, minimal friction

**Interaction Flow**:
1. **Trigger**: Large, prominent microphone button on main screen
2. **Feedback**: Button animates, shows recording state
3. **Recording**: Waveform visualization shows audio capture
4. **Completion**: Automatic stop after silence or manual stop
5. **Processing**: Loading indicator during transcription/analysis
6. **Auto-Save**: Results automatically added to database and dashboard updated

**Accessibility Considerations**:
- Large touch targets (minimum 44x44 points)
- Clear visual feedback for all states
- VoiceOver support for screen readers
- Haptic feedback on button press

#### Secondary Interaction: Manual Entry
**When Used**: Voice fails, user prefers typing, or in quiet environment

**Interaction Flow**:
1. Tap "Type Manually" option
2. Text field appears with keyboard
3. User types food entry
4. Same AI processing as voice input
5. Results automatically added to database

#### Tertiary Interaction: Database Management
**When Used**: Adding custom foods, editing existing entries

**Interaction Flow**:
1. Navigate to Food Database
2. Tap "Add New Food"
3. Enter food name
4. Enter nutritional values per 100g
5. Save to personal database
6. Food now available for future voice recognition

---

## 🧠 AI Integration Strategy

### Two-Stage AI Processing

#### Stage 1: Speech Recognition (OpenAI gpt-4o-mini-transcribe)
**Purpose**: Convert audio to text accurately

**Input**: Audio file (M4A format, 16kHz sample rate)
**Output**: Text string
**Model**: gpt-4o-mini-transcribe (OpenAI's speech recognition model)

**Why gpt-4o-mini-transcribe**:
- Industry-leading accuracy for speech recognition
- Handles various accents and speaking styles
- Robust to background noise
- Fast processing (1-2 seconds)
- Integrated with GPT-4o-mini for seamless analysis

**API Configuration**:
- Endpoint: `/v1/audio/transcriptions`
- Language: Auto-detect (primarily English)
- Response format: Plain text

#### Stage 2: Nutritional Analysis (GPT-4o-mini)
**Purpose**: Parse text and extract structured nutritional data

**Input**: Transcribed text + system prompt
**Output**: Structured JSON with nutritional breakdown
**Model**: GPT-4o-mini (cost-effective, fast, accurate)

**Why GPT-4o-mini**:
- Excellent at structured data extraction
- Understands natural language variations
- Fast response time (2-3 seconds)
- Cost-effective for high-volume usage
- JSON mode ensures parseable output

**Prompt Engineering Strategy**:

**System Prompt Components**:
1. **Role Definition**: "You are a nutritional analysis assistant"
2. **Output Format**: Strict JSON schema specification
3. **Parsing Rules**: How to handle quantities, units, multiple items
4. **Calculation Logic**: Use standard nutritional values per 100g
5. **Examples**: Show expected input/output pairs

**User Prompt Template**:
```
Parse this food input: "{transcribed_text}"

Extract:
- All food items mentioned
- Exact quantities and units
- Calculate nutritional values for specified quantities
- Return structured JSON only
```

**JSON Response Schema**:
```json
{
  "foods": [
    {
      "name": "string",
      "quantity": number,
      "unit": "string",
      "calories": number,
      "protein": number,
      "fat": number,
      "carbs": number
    }
  ],
  "total": {
    "calories": number,
    "protein": number,
    "fat": number,
    "carbs": number
  }
}
```

### Database Lookup Integration

**Decision Tree**:
```
Transcribed Text Received
    │
    ├─→ Search User Database
    │       │
    │       ├─→ Exact Match Found?
    │       │       │
    │       │       ├─→ YES: Use Custom Values
    │       │       │         (Skip AI Analysis)
    │       │       │
    │       │       └─→ NO: Continue to AI
    │       │
    │       └─→ Fuzzy Match Found?
    │               │
    │               ├─→ YES: Ask User to Confirm
    │               │         (Use custom or AI?)
    │               │
    │               └─→ NO: Use AI Analysis
    │
    └─→ AI Analysis
            │
            └─→ Return Estimated Values
                (Flag as "Estimated")
```

**Fuzzy Matching Logic**:
- Check for similar food names (Levenshtein distance)
- Handle plurals and variations ("chicken" vs "chickens")
- Account for common misspellings
- Suggest closest matches to user

**Example**:
```
User says: "chicken brest"
Database has: "chicken breast"
System: "Did you mean 'chicken breast' from your database?"
```

---

## 📊 Data Management & Storage

### Data Architecture

#### Local Storage (Core Data)
**Why Local Storage**:
- Fast access (no network latency)
- Works offline
- User privacy (data stays on device)
- No cloud storage costs

**Data Entities**:

1. **DailyEntry**
   - Represents one food item logged
   - Linked to specific date
   - Contains nutritional breakdown
   - Timestamped for meal timing

2. **CustomFood**
   - User-created food definitions
   - Nutritional values per 100g
   - Reusable across entries
   - Searchable by name

3. **DailyGoals**
   - User's target values
   - One record per user
   - Editable in settings
   - Used for progress calculation

4. **DailySummary**
   - Aggregated totals per day
   - Cached for performance
   - Updated on each new entry
   - Used for history view

### Data Relationships

```
User (1)
    │
    ├─→ DailyGoals (1)
    │
    ├─→ CustomFoods (many)
    │       │
    │       └─→ Referenced by DailyEntries
    │
    └─→ DailyEntries (many)
            │
            └─→ Grouped by Date
                    │
                    └─→ DailySummary (1 per date)
```

### Data Lifecycle

#### Entry Creation Flow
```
Voice Input → Transcription → AI Analysis → Auto-Save Entry
                                                                      │
                                                                      ├─→ Update DailySummary
                                                                      ├─→ Refresh Dashboard
                                                                      └─→ Trigger Notifications (if goals met)
```

#### Entry Modification Flow
```
User Selects Entry → Edit Screen → Modify Values → Save Changes
                                                          │
                                                          ├─→ Recalculate DailySummary
                                                          └─→ Update Dashboard
```

#### Entry Deletion Flow
```
User Deletes Entry → Confirm Deletion → Remove from Database
                                                │
                                                ├─→ Recalculate DailySummary
                                                └─→ Update Dashboard
```

---

## 🎯 Goal Tracking & Progress Visualization

### Goal Setting

Users can input their own target values for:
- Calories
- Protein 
- Fat
- Carbs

**Features**:
- Fully customizable targets
- Adjusted anytime in settings
- Persist across app sessions
- Used for real-time progress tracking and remaining consumption calculation

### Progress Calculation

**Formula**:
```
Progress Percentage = (Current Value / Goal Value) × 100
```

**Status Indicators**:
- **0-70%**: Under target (Green)
- **71-90%**: Approaching target (Yellow)
- **91-100%**: On target (Green)
- **>100%**: Over target (Red)

### Visual Representation

**Progress Visualization**:
- **Calorie Ring**: Primary circular progress indicator for main tracking
- **Macro Bars**: Progress bars for protein, fat, and carbs
- Color-coded by status for all indicators
- Shows both absolute values and percentages
- Animated updates when new entries added

**Daily Summary Card**:
- Total calories consumed vs goal
- All food entries (time-agnostic)
- Remaining calories/macros to hit goals

---

## 🔒 Privacy & Security

### Data Privacy Principles

1. **Local-First Storage**
   - All user data stored on device
   - No cloud backup (for POC)
   - User has full control

2. **API Data Handling**
   - Audio sent to OpenAI for transcription only
   - Text sent to OpenAI for analysis only
   - No permanent storage on OpenAI servers
   - Audio files deleted after processing

3. **API Key Security**
   - Stored in project files (not app configuration)
   - Never exposed in user interface
   - Secure compilation with build settings
   - Accessible only during app compilation

### User Consent & Transparency

**First Launch**:
- Privacy policy displayed
- Explain what data is sent to OpenAI
- Microphone permission request
- User must accept to proceed

---

## 🚀 Implementation Phases

### Phase 1: Core MVP (Weeks 1-3)
**Goal**: Basic functional app with manual entry

**Deliverables**:
- iOS app structure with SwiftUI
- Core Data setup and models
- Manual food entry (text input)
- Daily tracking and progress display
- Basic UI with progress visualization

**Success Criteria**:
- User can manually enter food
- App calculates and displays totals
- Progress rings show accurate percentages
- Data persists across app sessions

### Phase 2: Voice Integration (Weeks 4-6)
**Goal**: Add voice input and AI processing

**Deliverables**:
- OpenAI API integration (Whisper + GPT-4o-mini)
- Voice recording functionality
- Speech-to-text transcription
- AI-powered nutritional analysis
- Confirmation screen for parsed results

**Success Criteria**:
- User can record voice input
- Audio transcribed accurately (>90% accuracy)
- AI parses food items correctly (>85% accuracy)
- Results automatically added to database

### Phase 3: Custom Database (Weeks 7-8)
**Goal**: Personal food database for accuracy

**Deliverables**:
- Food database management UI
- CRUD operations for custom foods
- Database lookup before AI analysis
- Fuzzy matching for similar foods
- Import/export functionality

**Success Criteria**:
- User can create custom foods
- Voice input checks database first
- Custom foods used when matched
- Database searchable and editable

### Phase 4: Polish & Launch (Weeks 9-10)
**Goal**: Production-ready app

**Deliverables**:
- Comprehensive testing (unit, integration, UI)
- Performance optimization
- Error handling and edge cases
- App Store preparation
- User documentation

**Success Criteria**:
- App runs smoothly on all iOS devices
- No critical bugs
- Passes App Store review
- Ready for beta testing

---

## 📈 Success Metrics

### User Engagement Metrics
- **Daily Active Users**: Target 70% of registered users
- **Entries Per Day**: Target 3-5 entries per active user
- **Voice Input Usage**: Target 80% of entries via voice
- **Retention Rate**: Target 60% after 30 days

### Technical Performance Metrics
- **Voice Transcription Accuracy**: Target >90%
- **AI Parsing Success Rate**: Target >85%
- **App Response Time**: Target <3 seconds for full flow
- **Crash-Free Sessions**: Target >99.5%

### User Satisfaction Metrics
- **App Store Rating**: Target 4.5+ stars
- **Time to Log Meal**: Target <30 seconds
- **User-Reported Accuracy**: Target >90% satisfaction
- **Feature Adoption**: Target 60% use custom database

---

## 🔮 Future Enhancements

### Phase 5: Advanced Features (Post-Launch)
- **Barcode Scanning**: Scan packaged foods for instant nutrition
- **Meal Planning**: AI-suggested meals to hit goals
- **Recipe Analysis**: Calculate nutrition for entire recipes
- **HealthKit Integration**: Sync with Apple Health
- **Social Features**: Share meals and progress with friends
- **Advanced Analytics**: Weekly/monthly trends and insights
- **Meal Photos**: Visual food diary with AI recognition
- **Restaurant Database**: Common restaurant meals pre-loaded

### Phase 6: Platform Expansion
- **iPad Optimization**: Larger screen layouts
- **Apple Watch**: Quick logging from wrist
- **Widget Support**: Home screen progress widgets
- **Siri Integration**: "Hey Siri, log my meal"

---

## 💰 Cost Considerations

### OpenAI API Costs (Estimated)

**gpt-4o-mini-transcribe API**:
- $0.006 per minute of audio (estimated)
- Average entry: 5 seconds = $0.0005 per entry
- 100 entries/day = $0.05/day = $1.50/month per user

**GPT-4o-mini API**:
- $0.150 per 1M input tokens
- $0.600 per 1M output tokens
- Average entry: ~200 input tokens, ~150 output tokens
- Cost per entry: ~$0.00012
- 100 entries/day = $0.012/day = $0.36/month per user

**Total API Cost**: ~$1.86/month per active user

**Scaling Considerations**:
- 1,000 users: $1,860/month
- 10,000 users: $18,600/month
- Optimization: Cache common foods, batch requests, use custom database

---

## 🛠️ Technical Requirements

### iOS Requirements
- **Minimum iOS Version**: iOS 17.0+
- **Device Support**: iPhone (primary), iPad (compatible)
- **Xcode Version**: 15.0+
- **Swift Version**: 5.9+

### External Dependencies
- **OpenAI API**: Account and API key required
- **Network**: Internet connection required for voice processing
- **Microphone**: Required for voice input
- **Storage**: ~50MB for app + user data

### Development Tools
- Xcode 15+
- SwiftUI for UI
- Core Data for storage
- AVFoundation for audio
- Combine for reactive programming

---

*This functional specification provides a comprehensive blueprint for developing Demeterr, focusing on user experience, system architecture, and business logic rather than implementation details.*