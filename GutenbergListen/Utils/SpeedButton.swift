//
//  SpeedButton.swift
//  GutenbergListen
//
//  Created by ducrestfd on 1/22/26.
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

import SwiftUI

struct SpeedButton: View {
    let icon: String
    let step: Double
    let range: ClosedRange<Double>
    @Binding var readingSpeed: Double
    
    @State private var timer: Timer? = nil
    
    var body: some View {
        Image(systemName: icon)
            .font(.title2)
            .foregroundColor(.blue)
            .onLongPressGesture(minimumDuration: 0.5, pressing: { isPressing in
                if isPressing {
                    startTimer()
                } else {
                    stopTimer()
                }
            }, perform: {}) // Perform is empty because the timer handles the work
            .onTapGesture {
                adjustSpeed() // Still handle single taps
            }
    }

    func startTimer() {
        stopTimer() // Safety check: Kill any existing timer first
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            adjustSpeed()
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    func adjustSpeed() {
        let newValue = readingSpeed + step
        let clampedValue = min(max(range.lowerBound, newValue), range.upperBound)
        
        // Only vibrate if the value actually changed
        if clampedValue != readingSpeed {
            readingSpeed = clampedValue
            
            // Trigger a light haptic "tap"
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        } else {
            // Optional: Trigger a "error/limit" haptic if they hit the max/min
            let errorGenerator = UINotificationFeedbackGenerator()
            errorGenerator.notificationOccurred(.warning)
        }
    }
}
