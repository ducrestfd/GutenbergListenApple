//
//  BookListingScreen.swift
//  GutenbergListen
//
//  Created by ducrestfd on 1/13/26.
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

struct BookListingScreen: View {

    let item: SelectedSubsection
    let shelfNumber: String
    let initialStartingIndex: Int = 1
    @Binding var path: NavigationPath
    
    @StateObject private var viewModel = DirectResultsViewModel()
    
    // Local State
    @State private var isLoading = true
    @State private var error: String? = nil
    @State private var bookLinks: [LinkItem] = []
    
    var body: some View {
        
        BookListingView(
            viewModel: viewModel,
            browseType: item.browseType,
            subSection: item.subsection,
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
        

        
        var url: String = ""
        if (item.browseType.contains("Popularity")) {
            url = "https://www.gutenberg.org/ebooks/bookshelf/" + shelfNumber + "?sort_order=" + "downloads"
        } else if (item.browseType.contains("ReleaseDate")) {
            url = "https://www.gutenberg.org/ebooks/bookshelf/" + shelfNumber + "?sort_order=" + "release_date"
        } else if (item.browseType.contains("Author")) {
            url = "https://www.gutenberg.org/ebooks/bookshelf/" + shelfNumber + "?sort_order=" + "author"
        } else {
            url = "https://www.gutenberg.org/ebooks/bookshelf/" + shelfNumber + "?sort_order=" + "title"
        }
        
       //print(//"Fetching results for: \(url)")
        
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

