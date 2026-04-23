//
//  DownloadedFile.swift
//  GutenbergListen
//
//  Created by ducrestfd on 1/29/26.
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

import Foundation
import SwiftData

@Model
final class DownloadedFile {
    @Attribute(.unique) var fileName: String
    var location: Int
    var readingSpeed: Float
    var readingPitch: Float
    var playingSpeed: Float
    var currentTime: TimeInterval
    var selectedVoiceIdentifier: String?
    
    init(fileName: String) {
        self.fileName = fileName
        self.location = 0
        // Use fallback constant if UserDefaults returns zero (never set)
        let speedDefault = UserDefaults.standard.float(forKey: "defaultReadingSpeed")
        self.readingSpeed = speedDefault != 0 ? speedDefault : 0.5
        let pitchDefault = UserDefaults.standard.float(forKey: "defaultReadingPitch")
        self.readingPitch = pitchDefault != 0 ? pitchDefault : 1.25
        let playDefault = UserDefaults.standard.float(forKey: "defaultPlayingSpeed")
        self.playingSpeed = playDefault != 0 ? playDefault : 1.0
        self.currentTime = 0
        self.selectedVoiceIdentifier = nil
    }
}
