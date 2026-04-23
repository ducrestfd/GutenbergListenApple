//
//  SavedBookView.swift
//  GutenbergListen
//
//  Created by ducrestfd on 1/19/26.
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


import SwiftUI

struct SavedBooksView: View {
    @Binding var fileLinks: [LinkItem]
    @Binding var path: NavigationPath
    
    var orderedFileLinks: [LinkItem] {
        fileLinks.sorted { a, b in
            a.label.localizedCaseInsensitiveCompare(b.label) == .orderedAscending
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header Content
            VStack(spacing: 4) {

                Text("Gutenberg Listen!")
                    .bold()

                Spacer(minLength: 24)
                
                Text("\(orderedFileLinks.count) Saved Books")
                    .bold()

                List {
                    ForEach(orderedFileLinks) { item in
                        SavedBookItem(
                            item: item,
                            path: $path
                        )
                        .listRowSeparator(.hidden)  // Cleaner look similar to Compose default
                        .listRowInsets(
                            EdgeInsets(
                                top: 2,
                                leading: 16,
                                bottom: 2,
                                trailing: 16
                            )
                        )
                    }
                }
                .listStyle(.plain)
                .safeAreaInset(edge: .bottom) {
                    Color.clear.frame(height: 12)
                }
               
            }
        }
        .navigationBarHidden(false)
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
