//
//  BookListItem.swift
//  GutenbergListen
//
//  Created by ducrestfd on 1/13/26.
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

// Subview for the list item to handle individual state (isCheckingUrl)
struct BookListItem: View {
    let item: LinkItem
    @Binding var path: NavigationPath

    @State private var isCheckingUrl = false

    var body: some View {
        HStack {
            Button(action: {
                handleBookClick()
            }) {
                Text(item.label)
                    .multilineTextAlignment(.leading)
                    .lineLimit(4)
                    .foregroundColor(Color.black)
            }
            .buttonStyle(.borderedProminent)
            .tint(.teal)  // Keeps the list row clickable behavior clean
            .padding(.vertical, 2)
            .padding(.horizontal, 24)
        }
    }

    private func handleBookClick() {
        if isCheckingUrl { return }
        isCheckingUrl = true

        Task {
            // Logic derived from the Compose 'onClick' handler
            let bookId = item.href.components(separatedBy: "/").last ?? ""
            let m4bFileUrl =
                "https://www.gutenberg.org/files/\(bookId)/m4b/\(bookId)-01.m4b"
            // Check if m4b exists
            let m4bFilePresent = await urlExists(m4bFileUrl)

            
            await MainActor.run {
                if m4bFilePresent {
                    path.append(BookDestination.audio(id: Int(bookId) ?? 0, label: item.label))
                } else {
                    path.append(BookDestination.digital(id: Int(bookId) ?? 0, label: item.label))
                }

                isCheckingUrl = false
            }
            
        }
    }

    // Helper function to check URL existence (HEAD request)
    private func urlExists(_ urlString: String) async -> Bool {
        guard let url = URL(string: urlString) else { return false }
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        request.timeoutInterval = 10.0

        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse {
                // 200 OK means file exists
                return httpResponse.statusCode == 200
            }
            return false
        } catch {
            return false
        }
    }
}

