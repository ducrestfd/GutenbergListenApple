//
//  Browse.swift
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

import SwiftUI

struct Browse: View {
    let item: BrowseItem
    @Binding var path: NavigationPath

    var body: some View {

        ZStack {
            ScrollView {
                VStack(spacing: 16) {
                    
                    Text("Gutenberg Listen!")
                        .font(.system(size: 24, weight: .bold))
                    
                    Text("\(item.browseType)")
                        .font(.title3)
                    
                    // Category Buttons
                    VStack(spacing: 8) {
                        categoryButton(title: "Arts & Culture")
                        categoryButton(title: "Education & Reference")
                        categoryButton(title: "Health & Medicine")
                        categoryButton(title: "History")
                        categoryButton(title: "Lifestyle & Hobbies")
                        categoryButton(title: "Literature")
                        categoryButton(title: "Religion & Philosophy")
                        categoryButton(title: "Science & Technology")
                        categoryButton(title: "Social Sciences & Society")
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
            }
        }
        .navigationBarHidden(false) // Usually hidden if you are providing your own "Home" button
    }
    
    // Helper to create consistent category buttons
    @ViewBuilder
    private func categoryButton(title: String) -> some View {
        Button {
            path.append(BrowseSection(browseType: item.browseType, title: title))
        } label: {
            Text(title)
                .foregroundColor(Color.black) // Sets the text color to black
                .bold()
                .padding(.horizontal, 20)
                .padding(5) // Adds padding around the text
                .background(Color.teal)
                .clipShape(Capsule())
        }
    }
}
