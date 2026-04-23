//
//  DownloadCompletedReceiver.swift
//  GutenbergListen
//
//  Created by ducrestfd on 1/3/26.
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


struct DirectResultsView: View {
    // ViewModel is observed to manage pagination state (currentIndex)
    @ObservedObject var viewModel: DirectResultsViewModel

    // Data passed from the parent function/view
    let searchType: String
    let searchTerm: String
    let bookLinks: [LinkItem]
    let isLoading: Bool
    let error: String?
    @Binding var path: NavigationPath

    var body: some View {
        // Equivalent to Scaffold with TopAppBar
        NavigationView {
            // Equivalent to Column(modifier = Modifier.fillMaxSize()...)
            VStack(spacing: 0) {
                // Header Content
                VStack(spacing: 4) {
                    Text("Gutenberg Listen!" + "\(path.count)")
                        .font(.system(size: 18, weight: .bold))

                    Text(
                        "sorted by \(searchType.removingPercentEncoding ?? searchType)"
                    )
                    .font(.system(size: 12, weight: .bold))
                }
                .padding(.top, 16)

                Spacer().frame(height: 16)

                // Main Content Area
                if isLoading {
                    Spacer()
                    ProgressView()
                    Spacer()
                } else if let error = error {
                    Spacer()
                    Text("Error: \(error)")
                    Spacer()
                } else {
                    // Equivalent to LazyColumn
                    List {
                        ForEach(bookLinks) { item in
                            BookListItem(
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
                    // Add bottom padding to content (Compose had contentPadding = PaddingValues(bottom = 48.dp))
                    .safeAreaInset(edge: .bottom) {
                        Color.clear.frame(height: 12)
                    }
                    
                }

            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: BookDestination.self) { destination in
                switch destination {
                case .audio(let bookId, let label):
                    ChosenAudioBook(item: SelectedBook(id: 4, bookId: bookId, title: label), path: $path)
                case .digital(let bookId, let label):
                    ChosenBook(item: SelectedBook(id: 3, bookId: bookId, title: label), path: $path)
                }
            }
        }
        .navigationBarHidden(false)
        .toolbar {

            // NavigationIcon -> Previous Button (only when currentIndex > 1)
            if viewModel.currentIndex > 1 {
                ToolbarItem(placement: .automatic) {  //.navigationBarLeading) {
                    Button(action: {
                        let newIndex = max(1, viewModel.currentIndex - 25)
                        viewModel.updateCurrentIndex(newIndex: newIndex)
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.backward")
                            Text("Previous")
                        }
                    }
                }
            }

            // TopBar Title -> Home Button
            ToolbarItem(placement: .automatic) { //.title) {
                Button("Home") {
                    path = NavigationPath()  // Go home
                }
            }

            ToolbarItem(placement: .automatic) { //.navigationBarTrailing) {
                Button(action: {
                    viewModel.updateCurrentIndex(
                        newIndex: viewModel.currentIndex + 25
                    )
                }) {
                    HStack(spacing: 4) {
                        Text("Next")
                        Image(systemName: "arrow.forward")  // Icons.AutoMirrored.Filled.ArrowForward
                    }
                }
                .disabled(isLoading)
            }
        }

    }
}

