//
//  Settings.swift
//  GutenbergListen
//
//  Created by ducrestfd on 1/1/26.
//

/*
Gutenberg Listen's raison d'être is to provide simple access to
the Gutenberg Project website of 70,000 plus books to both
sighted and blind users.  It is provided without charge under the
agpl-3.0 license.

    Copyright (C) 2026 Frank D. Ducrest

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
import Combine
import SwiftUI

// A simple manager to handle playback
class SpeechPreviewManager: NSObject, ObservableObject {
    private let synthesizer = AVSpeechSynthesizer()

    func playSample(identifier: String) {
        // Stop any current speech
        synthesizer.stopSpeaking(at: .immediate)

        // Find the voice
        guard let voice = AVSpeechSynthesisVoice(identifier: identifier) else {
            return
        }

        let utterance = AVSpeechUtterance(
            string: "This is a sample of this voice."
        )
        utterance.voice = voice
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate

        synthesizer.speak(utterance)
    }
}

struct Settings: View {
    @AppStorage("defaultReadingSpeed") private var readingSpeed: Double = 0.5
    @AppStorage("defaultReadingPitch") private var readingPitch: Double = 1.25
    @AppStorage("defaultPlayingSpeed") private var playingSpeed: Double = 1.0
    @AppStorage("tts_selected_voice") private var selectedVoiceIdentifier:
        String = ""

    // Add the manager
    @StateObject private var previewManager = SpeechPreviewManager()

    private let voices = AVSpeechSynthesisVoice.speechVoices()

    private let range = 0.2...0.8
    private let step: Double = 0.05

    private let pitchRange = 0.5...2.0
    private let pitchStep: Double = 0.05

    private let playingRange = 0.5...2.0
    private let playingStep: Double = 0.1

    var body: some View {
        VStack(spacing: 0) {
            // Header Content
            VStack(spacing: 4) {

                Text("Gutenberg Listen!")
                    .bold()

                Spacer().frame(height: 24)

                Text(
                    "Default eBook speaking speed: \(readingSpeed, specifier: "%.2f")x"
                )
                .foregroundColor(Color.black)  // Sets the text color to black
                .bold()
                .padding(.horizontal, 20)
                .padding(5)  // Adds padding around the text
                .background(Color.teal)
                .clipShape(Capsule())

                HStack(spacing: 12) {

                    SpeedButton(
                        icon: "minus.circle.fill",
                        step: -step,
                        range: range,
                        readingSpeed: $readingSpeed
                    ).disabled(readingSpeed <= range.lowerBound)  // Greys out when at minimum
                        .opacity(readingSpeed <= range.lowerBound ? 0.5 : 1.0)

                    Slider(value: $readingSpeed, in: range, step: step)

                    SpeedButton(
                        icon: "plus.circle.fill",
                        step: step,
                        range: range,
                        readingSpeed: $readingSpeed
                    )
                    .disabled(readingSpeed >= range.upperBound)  // Greys out when at minimum
                    .opacity(readingSpeed >= range.upperBound ? 0.5 : 1.0)
                }
                .padding(.horizontal)

                Spacer().frame(height: 24)

                Text(
                    "Default eBook speaking pitch: \(readingPitch, specifier: "%.2f")x"
                )
                .foregroundColor(Color.black)  // Sets the text color to black
                .bold()
                .padding(.horizontal, 20)
                .padding(5)  // Adds padding around the text
                .background(Color.teal)
                .clipShape(Capsule())

                HStack(spacing: 12) {

                    SpeedButton(
                        icon: "minus.circle.fill",
                        step: -pitchStep,
                        range: pitchRange,
                        readingSpeed: $readingPitch
                    )
                    .disabled(readingPitch <= pitchRange.lowerBound)  // Greys out when at minimum
                    .opacity(readingPitch <= pitchRange.lowerBound ? 0.5 : 1.0)

                    Slider(
                        value: $readingPitch,
                        in: pitchRange,
                        step: pitchStep
                    )

                    SpeedButton(
                        icon: "plus.circle.fill",
                        step: pitchStep,
                        range: pitchRange,
                        readingSpeed: $readingPitch
                    )
                    .disabled(readingPitch >= pitchRange.upperBound)  // Greys out when at minimum
                    .opacity(readingPitch >= pitchRange.upperBound ? 0.5 : 1.0)
                }
                .padding(.horizontal)

                Spacer().frame(height: 24)

                Text(
                    "Default audiobook speed: \(playingSpeed, specifier: "%.2f")x"
                )
                .foregroundColor(Color.black)  // Sets the text color to black
                .bold()
                .padding(.horizontal, 20)
                .padding(5)  // Adds padding around the text
                .background(Color.teal)
                .clipShape(Capsule())

                HStack(spacing: 12) {
                    SpeedButton(
                        icon: "minus.circle.fill",
                        step: -playingStep,
                        range: playingRange,
                        readingSpeed: $playingSpeed
                    )
                    .disabled(playingSpeed <= playingRange.lowerBound)  // Greys out when at minimum
                    .opacity(
                        playingSpeed <= playingRange.lowerBound ? 0.5 : 1.0
                    )

                    Slider(
                        value: $playingSpeed,
                        in: playingRange,
                        step: playingStep
                    )

                    SpeedButton(
                        icon: "plus.circle.fill",
                        step: playingStep,
                        range: playingRange,
                        readingSpeed: $playingSpeed
                    )
                    .disabled(playingSpeed >= playingRange.upperBound)  // Greys out when at minimum
                    .opacity(
                        playingSpeed >= playingRange.upperBound ? 0.5 : 1.0
                    )
                }
                .padding(.horizontal)

                // Voice selection for all TTS books
                let voices = AVSpeechSynthesisVoice.speechVoices()
                VStack(alignment: .leading, spacing: 8) {
                    Text("Default Voice")
                        .foregroundColor(Color.black)
                        .bold()
                        .padding(.horizontal, 20)
                        .padding(5)
                        .background(Color.teal)
                        .clipShape(Capsule())
                    Picker("Voice", selection: $selectedVoiceIdentifier) {
                        ForEach(voices, id: \.identifier) { voice in
                            Text("\(voice.name) (\(voice.language))").tag(
                                voice.identifier
                            )
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(height: 120)

                    // Add the Preview Button
                    Button(action: {
                        previewManager.playSample(
                            identifier: selectedVoiceIdentifier
                        )
                    }) {
                        HStack {
                            Image(systemName: "play.circle.fill")
                            Text("Preview Selected Voice")
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.teal.opacity(0.2))
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)

                }
                .padding(.horizontal)
                .padding(.top, 24)

                Spacer()

            }
        }

    }
}
