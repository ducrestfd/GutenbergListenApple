//
//  BrowseSectionScreen.swift
//  GutenbergListen
//
//  Created by ducrestfd on 1/12/26.
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
import SwiftSoup

struct BrowseSectionScreen: View {
    let item: SelectedSection
    @Binding var path: NavigationPath
   
    @State private var isLoading = true
    @State private var error: String? = nil
    @State private var sectionLinks: [LinkItem] = []
    
    var body: some View {
        BrowseSectionView(item: item, isLoading: isLoading, sectionLinks: sectionLinks, path: $path)
            .task {
                await fetchAndFilterLinks(subSection: item.title)
            }
            
    }
    
    
    private func fetchAndFilterLinks(subSection: String) async {
        isLoading = true
        defer { isLoading = false }
        
        let allLinks = await collectCategoryHrefs()
          
        sectionLinks = allLinks
            .filter { $0.label == subSection }
            .sorted { $0.label < $1.label }
        
        for binkie in sectionLinks {
           //print(//"last gasp:  \(subSection) \(subSection.count) - \(binkie.label) \(binkie.label.count), \(binkie.section ?? "")")
        }
            
        isLoading = false
    }
    
}


