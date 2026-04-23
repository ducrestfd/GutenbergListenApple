//
//  TextToSpeech.swift
//  GutenbergListen
//
//  Created by ducrestfd on 1/2/26.
//

/*
Gutenberg Listen's raison d'être is to provide simple access to
the Gutenberg Project website of 70,000 plus books to both
sighted and blind users.  It is provided without charge under the
agpl-3.0 license.

    Copyright (C) 2025 Frank D. Ducrest

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published
by the Free Software Foundation, either version 3 of the License, or
any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */


import AVFoundation
import SwiftUI
import NaturalLanguage

struct TextToSpeech: View {
    let selectedSavedBook: LinkItem
    let database: FileDataAccess
    @Binding var path: NavigationPath

    @StateObject private var speechManager = TextToSpeechManager()
    @State private var rate: Float = 0.5
    @State private var pitch: Float = 1.2
    @State private var isLoading = false

    @State private var sampleParagraph: String = ""
    @State private var sentences: [String] = []
    @State private var currentSentenceIndex: Int = 0
    

    var body: some View {
        ScrollView {
            VStack {

                Text("Gutenberg Listen!")
                    .bold()

                Spacer(minLength: 12)

                Text(selectedSavedBook.label)
                    .bold()

                if isLoading {
                    // 1. Show the spinner while loading
                    ProgressView("Reading file...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                } else {

                    Spacer(minLength: 36)

                    if speechManager.isSpeaking {
                        Button(action: {
                            speechManager.pausePlayback()
                        }) {
                            Label(
                                "\(speechManager.speakingIsPaused() ? "Resume" : "Pause")",
                                systemImage: "pause.circle.fill"
                            )
                            .foregroundColor(.black)
                            .background(.teal)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.teal)  // Keeps the list row clickable behavior clean
                        .padding(.vertical, 2)
                        .padding(.horizontal, 24)

                    } else {
                        Button(action: {
                            speechManager.speak()
                        }) {
                            Label(
                                "Start Speaking",
                                systemImage: "play.circle.fill"
                            )
                            .foregroundColor(.black)
                            .background(.teal)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.teal)  // Keeps the list row clickable behavior clean
                        .padding(.vertical, 2)
                        .padding(.horizontal, 24)

                    }

                    if speechManager.isSpeaking {
                        Button(action: { speechManager.reset() }) {
                            Label(
                                "Reset",
                                systemImage: "stop.circle.fill"
                            )
                            .foregroundColor(.black)
                            .background(.teal)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.teal)  // Keeps the list row clickable behavior clean
                        .padding(.vertical, 2)
                        .padding(.horizontal, 24)

                    }

                }
            }
            .padding()
            .onAppear {
               //print(//
               //     "onAppear: \(selectedSavedBook.label.replacingOccurrences(of: " (text)", with: ""))"
               // )
                isLoading = true
                sampleParagraph = readFileFromDocuments(
                    fileName: selectedSavedBook.label.replacingOccurrences(
                        of: " (text)",
                        with: ""
                    )
                )
                let languageMap: [String: NLLanguage] = [
                    "(French)": .french,
                    "(German)": .german,
                    "(Spanish)": .spanish,
                    "(Italian)": .italian,
                ]

                // Find the first key that exists in the label, or default to English
                var language:NLLanguage? = languageMap.first { selectedSavedBook.label.contains($0.key) }?.value ?? nil
                                
                if language == nil {
                    let recognizer = NLLanguageRecognizer()
                    recognizer.processString(sampleParagraph)
                    language = recognizer.dominantLanguage // Returns .french, .english, etc.
                }
                
                let sentences = splitIntoSentences(text: sampleParagraph, language: language ?? .english)
                isLoading = false
                
                /*
                for asentence in sentences {
                    print(asentence)
                    let characterCount = asentence.count
                    let startIdx = characterCount >= 3 ? asentence.index(asentence.endIndex, offsetBy: -3) : asentence.startIndex
                    for charis in asentence[startIdx...] {
                        print(charis.asciiValue ?? 0)
                    }
                }
                 */
                
                //print("language found: \(language!.rawValue)")
                
                if !speechManager.factorySetup(selectedSavedBook: selectedSavedBook, fileDataAccess: database, sentences: sentences, language: language ?? .english) {
                    return
                }
            }

            VStack {
                Divider()

                Text("Position by Sentence")

                Text(
                    "\(speechManager.currentSentenceIndex) / \(speechManager.getNumberSentences() == 0 ? "###" : String(speechManager.getNumberSentences()))"
                )
                .frame(width: 200, height: 50)

                HStack {
                    
                    
                    Button(action: {
                        speechManager.jumpBackward30Sentences()
                    }) {
                        Image(systemName: "gobackward.30")
                            .resizable()
                            .frame(width: 35, height: 35)
                            .foregroundColor(.blue)
                            .accessibilityHidden(true)
                    }
                    .accessibilityLabel("Jump backward 30 sentences")
                    
                    Button(action: {
                        speechManager.jumpBackward10Sentences()
                    }) {
                        Image(systemName: "gobackward.10")
                            .resizable()
                            .frame(width: 35, height: 35)
                            .foregroundColor(.blue)
                            .accessibilityHidden(true)
                    }
                    .accessibilityLabel("Jump backward 10 sentences")
                    
                    Button(action: {
                        speechManager.jumpForward10Sentences()
                    }) {
                        Image(systemName: "goforward.10")
                            .resizable()
                            .frame(width: 35, height: 35)
                            .foregroundColor(.blue)
                            .accessibilityHidden(true)
                    }
                    .accessibilityLabel("Jump forward 10 sentences")
                    
                    Button(action: {
                        speechManager.jumpForward30Sentences()
                    }) {
                        Image(systemName: "goforward.30")
                            .resizable()
                            .frame(width: 35, height: 35)
                            .foregroundColor(.blue)
                            .accessibilityHidden(true)
                    }
                    .accessibilityLabel("Jump forward 30 sentences")
                    
                    
                    Button(action: {
                        speechManager.jumpForward100Sentences()
                    }) {
                        Text("+100")
                            //.frame(width: 35, height: 35)
                            .bold()
                            .foregroundColor(.blue)
                            .accessibilityHidden(true)
                    }
                }
                .accessibilityLabel("Jump forward 100 sentences")
                
                Divider()

                Text("Playback Speed")
                    .frame(height: 50)

                HStack {
                    Button(action: {
                        speechManager.rateDown()
                    }) {
                        Image(systemName: "minus.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.blue)
                            .accessibilityHidden(true)
                    }
                    .accessibilityLabel("Decrease playback speed")

                    Text(String(format: "%.2f", speechManager.getRate()))
                        .bold()

                    Button(action: {
                        speechManager.rateUp()
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.blue)
                            .accessibilityHidden(true)
                    }
                    .accessibilityLabel("Increase playback speed")
                }


                Text("Pitch")
                    .frame(height: 30)

                HStack {
                    Button(action: {
                        speechManager.pitchDown()
                    }) {
                        Image(systemName: "minus.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.blue)
                            .accessibilityHidden(true)
                    }
                    .accessibilityLabel("Lower pitch")

                    Text(String(format: "%.2f", speechManager.getPitch()))
                        .bold()

                    Button(action: {
                        speechManager.pitchUp()
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.blue)
                            .accessibilityHidden(true)
                    }
                    .accessibilityLabel("Raise pitch")
                }
            }
            .frame(width: 250)
            
            Divider()
            
            VStack(spacing: 8) {
                Text("Sleep Timer")
                    .font(.headline)
                HStack(spacing: 12) {
                    Button("05 min") { speechManager.startSleepTimer(duration: 300) }
                    Button("10 min") { speechManager.startSleepTimer(duration: 600) }
                    Button("15 min") { speechManager.startSleepTimer(duration: 900) }
                    Button("30 min") { speechManager.startSleepTimer(duration: 1800) }
                    Button("60 min") { speechManager.startSleepTimer(duration: 3600) }
                    Button("Cancel") { speechManager.cancelSleepTimer() }
                }
                if let remaining = speechManager.sleepTimerRemaining, remaining > 0 {
                    Text("Timer: \(Int(remaining)/60):\(String(format: "%02d", Int(remaining)%60)) left")
                        .font(.subheadline)
                        .foregroundColor(.purple)
                }
            }
            .frame(width: 250)

            /*
            Divider()
            
            if (speechManager.availableVoices.count > 0) {
                // Added voice selection picker here
                VStack {
                    Text("Select Voice")
                    Picker("Voice", selection: $speechManager.selectedVoiceIdentifier) {
                        ForEach(speechManager.availableVoices, id: \.identifier) { voice in
                            Text("\(voice.name) (\(voice.language))").tag(voice.identifier as String?)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(height: 120)
                }
                .frame(width: 250)
                
                Divider()
            }
             */

            Spacer()
        }
        .toolbar {

            // TopBar Title -> Home Button
            ToolbarItem(placement: .principal) {
                Button("Home") {
                    //print("Going back... \(path.count)")
                    path = NavigationPath()  // Go home
                }
            }
        }

    }

    func readFileFromDocuments(fileName: String) -> String {
        // 1. Get the URL for the Documents directory
        let fileManager = FileManager.default
        guard
            let documentsURL = fileManager.urls(
                for: .documentDirectory,
                in: .userDomainMask
            ).first
        else {
            return "Directory not found"
        }

        // 2. Append the filename to the directory path
        let fileURL = documentsURL.appendingPathComponent(fileName)

        // 3. Attempt to read the file
        do {
            let content = try String(contentsOf: fileURL, encoding: .utf8)
            return content
        } catch {
            return "Error reading file: \(error.localizedDescription)"
        }
    }
    
    func splitIntoSentences(text: String, language: NLLanguage, ) -> [String] {
        var sentences: [String] = []
        
        // Replace single newlines with a space, but keep double newlines (paragraphs)
        /*var sanitizedText = text.replacingOccurrences(
            of: "(?<!\\n)\\n(?!\\n)",
            with: " ",
            options: .regularExpression
        )
         */
        
        let sanitizedText = sanitizeTextForTTS(text)
        
        // 1. Initialize the tokenizer for sentences
        let tokenizer = NLTokenizer(unit: .sentence)
        tokenizer.string = sanitizedText
        tokenizer.setLanguage(language)
        
        // 2. Enumerate through the identified ranges
        tokenizer.enumerateTokens(in: sanitizedText.startIndex..<sanitizedText.endIndex) { tokenRange, _ in
            sentences.append(String(sanitizedText[tokenRange]))
            return true // Keep going until the end
        }
        
        return sentences
    }
    
    func sanitizeTextForTTS(_ text: String) -> String {
        // 1. Replace single newlines with a space if they are not part of a paragraph break
        // Logic: Find a newline \n that is NOT preceded by another \n and NOT followed by another \n
        let singleNewlineRegex = "(?<!\\R)\\R(?!\\R)" //"(?<!\\n)\\n(?!\\n)"
        
        let midSentenceCleaned = text.replacingOccurrences(
            of: singleNewlineRegex,
            with: " ",
            options: .regularExpression
        )
        
        // 2. Collapse multiple spaces that might have been created
        let extraSpaceRegex = " +"
        let finalClean = midSentenceCleaned.replacingOccurrences(
            of: extraSpaceRegex,
            with: " ",
            options: .regularExpression
        )
        
        return finalClean.trimmingCharacters(in: .whitespacesAndNewlines)
    }

}
