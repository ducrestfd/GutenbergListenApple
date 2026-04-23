//
//  AudioPlayer.swift
//  GutenbergListen
//
//  Created by ducrestfd on 1/2/26.
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
import Foundation
import SwiftData
import SwiftUI

struct AudioPlayer: View {
    let fileDataAccess: FileDataAccess
    let title: String
    let item: LinkItem
    @Binding var path: NavigationPath
    
    @StateObject var viewModel: AudioPlayerViewModel

    init(fileDataAccess: FileDataAccess, title: String, item: LinkItem, path: Binding<NavigationPath>) {
        self.fileDataAccess = fileDataAccess
        self.title = title
        self.item = item
        self._path = path
        _viewModel = StateObject(
            wrappedValue: AudioPlayerViewModel(fileDataAccess: fileDataAccess, title: title, href: item.href)
        )
    }

    var body: some View {
        VStack(spacing: 3) {

            VStack(spacing: 4) {

                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: "book.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50, height: 50)
                            .foregroundColor(.gray)
                            .accessibilityHidden(true)
                    )
                    .padding(.vertical, 2)

                Text("Now Playing")
                    .font(.headline)
                Text(item.label)
                    .padding(.vertical, 10)

                // Play/Pause Button
                Button(action: {
                    viewModel.playPause()
                }) {
                    Image(
                        systemName: viewModel.isPlaying
                            ? "pause.circle.fill" : "play.circle.fill"
                    )
                    .resizable()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.blue)
                    .accessibilityHidden(true)
                }
                .accessibilityLabel("Play pause toggle")
                .padding(.vertical, 30)
                
                Text("Time Remaining")
                
                HStack {
                    Button(action: {
                        viewModel.jumpBack(by: 60)
                    }) {
                        Image(systemName: "minus.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.blue)
                            .accessibilityHidden(true)
                    }
                    .accessibilityLabel("Jump backward 60 seconds")
                                     
                    Text(viewModel.formatTime(viewModel.timeRemaining))
                        .frame(height: 50)
                    
                    Button(action: {
                        viewModel.jumpAhead(by: 300)
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.blue)
                            .accessibilityHidden(true)
                    }
                    .accessibilityLabel("Jump forward 300 seconds")
                }

                Text("Playback Speed")
                    .frame(height: 50)

                HStack {
                    Button(action: {
                        viewModel.setSpeedSlower()
                    }) {
                        Image(systemName: "minus.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.blue)
                            .accessibilityHidden(true)
                    }
                    .accessibilityLabel("Decrease playback speed")

                    Text(String(format: "%.2f", viewModel.playbackRate))

                    Button(action: {
                        viewModel.setSpeedFaster()
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.blue)
                            .accessibilityHidden(true)
                    }
                    .accessibilityLabel("Increase playback speed")
                }

                VStack(spacing: 8) {
                    Text("Sleep Timer")
                        .font(.headline)
                    HStack(spacing: 12) {
                        Button("05 min") { viewModel.startSleepTimer(duration: 300) }
                        Button("10 min") { viewModel.startSleepTimer(duration: 600) }
                        Button("15 min") { viewModel.startSleepTimer(duration: 900) }
                        Button("30 min") { viewModel.startSleepTimer(duration: 1800) }
                        Button("60 min") { viewModel.startSleepTimer(duration: 3600) }
                        Button("Cancel") { viewModel.cancelSleepTimer() }
                    }
                    if let remaining = viewModel.sleepTimerRemaining, remaining > 0 {
                        Text("Timer: \(Int(remaining)/60):\(String(format: "%02d", Int(remaining)%60)) left")
                            .font(.subheadline)
                            .foregroundColor(.purple)
                    }
                }

                Spacer()

            }
            .padding()

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
}

class AudioPlayerViewModel: ObservableObject {
    let fileDataAccess: FileDataAccess
    let title: String
    let href: String

    var audioPlayer: AVAudioPlayer?
    @Published var isPlaying = false
    @Published var playbackRate: Float
    @Published var timeRemaining: TimeInterval = 0
    @Published var currentTime: TimeInterval = 0
    
    @Published var sleepTimerRemaining: TimeInterval? = nil
    private var sleepTimer: Timer? = nil
    
    private var timer: Timer?
    private var fdaFile: DownloadedFile?

    let maxSpeed: Float = 2.0
    let minSpeed: Float = 0.5

    init(fileDataAccess: FileDataAccess, title: String, href: String) {
        
       //print("************* AudioPlayerViewModel: title: \(title)")
        
        
        self.fileDataAccess = fileDataAccess
        self.title = title
        
        fdaFile = self.fileDataAccess.fetchFile(named: self.title)
        
        if fdaFile == nil {
            fdaFile = self.fileDataAccess.addFile(fileName: self.title)
        }

        
        let speed = fdaFile!.playingSpeed    //UserDefaults.standard.float(forKey: "defaultPlayingSpeed")
        self.playbackRate = speed < 0.5 || speed > 2.0 ? 1.00 : speed
        
        self.currentTime = fdaFile!.currentTime

        self.href = href.lastTwoComponents

        let docsURL = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0]
        let fileURL = docsURL.appendingPathComponent(self.href)
       //print("Attempting to load audio file from: \(fileURL.path)")
        let fileExists = FileManager.default.fileExists(atPath: fileURL.path)
       //print("File exists at path? \(fileExists)")
        do {
            self.audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
            self.audioPlayer?.enableRate = true
            self.audioPlayer?.rate = self.playbackRate
            self.audioPlayer?.currentTime = self.currentTime
            self.audioPlayer?.prepareToPlay()
            setupTimer()
        } catch {
           //print(
           //     "Couldn't load audio file \(self.href), \(fileURL.path): \(error)"
           // )
        }
    }

    func playPause() {
        guard let player = audioPlayer else { return }

        if player.isPlaying {
            player.pause()
            isPlaying = false
        } else {
            player.play()
            isPlaying = true
        }
    }

    func setSpeedFaster() {
        if playbackRate < maxSpeed {
            playbackRate = playbackRate + 0.1
            audioPlayer?.rate = playbackRate
            fdaFile!.playingSpeed = playbackRate
        }
        
    }

    func setSpeedSlower() {
        if playbackRate > minSpeed {
            playbackRate = playbackRate - 0.1
            audioPlayer?.rate = playbackRate
            fdaFile!.playingSpeed = playbackRate
        }
    }

    func jumpAhead(by seconds: TimeInterval) {
        audioPlayer?.currentTime += seconds
    }
    
    func jumpBack(by seconds: TimeInterval) {
        audioPlayer?.currentTime -= seconds
    }
    
    // Call this inside your init after the player is loaded
    func setupTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {
            [weak self] _ in
            self?.updateTime()
        }
    }

    func updateTime() {
        guard let player = audioPlayer else { return }
        // Calculation: Total duration minus current position
        timeRemaining = player.duration - player.currentTime
        fdaFile!.currentTime = player.currentTime
        
        if let _ = sleepTimerRemaining {
            objectWillChange.send()
        }
    }
    
    func startSleepTimer(duration: TimeInterval) {
        sleepTimerRemaining = duration
        sleepTimer?.invalidate()
        sleepTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.sleepTimerTick()
        }
    }

    func cancelSleepTimer() {
        sleepTimer?.invalidate()
        sleepTimer = nil
        sleepTimerRemaining = nil
    }

    private func sleepTimerTick() {
        guard let remaining = sleepTimerRemaining, remaining > 0 else {
            sleepTimer?.invalidate()
            sleepTimer = nil
            sleepTimerRemaining = nil
            self.audioPlayer?.pause()
            self.isPlaying = false
            return
        }
        sleepTimerRemaining = max(0, remaining - 1)
    }

    // Helper to format the seconds into 00:00
    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

extension String {
    var lastTwoComponents: String {
        let parts = self.components(separatedBy: "/")
        return parts.suffix(2).joined(separator: "/")
    }
}
