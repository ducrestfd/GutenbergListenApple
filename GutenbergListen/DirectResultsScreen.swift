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

struct DirectResultsScreen: View {
    let item: SearchItem
    @Binding var path: NavigationPath
    
    // ViewModel integration
    // We use @StateObject here to own the ViewModel lifecycle for this screen
    @StateObject private var viewModel = DirectResultsViewModel()
    
    // Local State
    @State private var isLoading = true
    @State private var error: String? = nil
    @State private var bookLinks: [LinkItem] = []
    
    var body: some View {
        // Pass state and callbacks to the UI View (DirectResultsView)
        // constructed in the previous step.
        
        DirectResultsView(
            viewModel: viewModel,
            searchType: item.searchType,
            searchTerm: item.searchTerm,
            bookLinks: bookLinks,
            isLoading: isLoading,
            error: error,
            path: $path
        )
        .task(id: viewModel.currentIndex) {
            await fetchResults()
        }
    }
    
    // Logic from the LaunchedEffect block
    private func fetchResults() async {
        isLoading = true
        error = nil
        
        // 1. Construct URL
        let encodedTerm = item.searchTerm.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        var url = ""
        
        if item.searchType == "downloads" {
            url = "https://www.gutenberg.org/ebooks/search/?query=\(encodedTerm)&sort_order=downloads"
        } else if item.searchType == "release_date" {
            url = "https://www.gutenberg.org/ebooks/search/?query=\(encodedTerm)&sort_order=release_date"
        } else {
            // Default to title
            url = "https://www.gutenberg.org/ebooks/search/?query=\(encodedTerm)&sort_order=title"
        }
        
        // 2. Fetch Data
        // collectSectionHrefs is the function defined in the earlier step
        let results = await collectSectionHrefs(
            section: "",
            href: url,
            startingIndex: viewModel.currentIndex
        )
        
        // 3. Update State (MainActor is handled automatically by .task for @State vars, 
        // but explicit dispatch is safe if collectSectionHrefs isn't isolated)
        bookLinks = results
        
        // Note: In the Kotlin code, if an exception occurs inside collectSectionHrefs,
        // it returns an empty list, which matches the behavior here if we assume
        // the swift version swallows errors or returns empty on failure.
        
        isLoading = false
    }
}
