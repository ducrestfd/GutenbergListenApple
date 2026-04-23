//
//  BrowseSectionView.swift
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

struct BrowseSectionView: View {
    let item: SelectedSection
    let isLoading: Bool
    let sectionLinks: [LinkItem]
    @Binding var path: NavigationPath

    var body: some View {
        ZStack {
            VStack(spacing: 16) {

                VStack(spacing: 4) {
                    Text("Gutenberg Listen!")
                        .font(.system(size: 24, weight: .bold))

                    Text(item.title)
                        .font(.system(size: 16, weight: .bold))

                    Text(item.browseType)
                        .font(.system(size: 12, weight: .bold))
                }

                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(sectionLinks) { itemma in

                            Button {
                                path.append(
                                    BookListing(
                                        browseType: item.browseType,
                                        subsection: itemma.section
                                            ?? "Bad Section",
                                        shelfNumber: itemma.href.components(
                                            separatedBy: "/"
                                        ).last ?? ""
                                    )
                                )
                            } label: {
                                Text((itemma.section ?? "Bad Section"))
                                    .foregroundColor(Color.black)  // Sets the text color to black
                                    .bold()
                                    .padding(.horizontal, 20)
                                    .padding(5)  // Adds padding around the text
                                    .background(Color.teal)
                                    .clipShape(Capsule())
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.bottom, 16)
                }
                .frame(maxWidth: .infinity)
                //}
            }.toolbar {

                // TopBar Title -> Home Button
                ToolbarItem(placement: .title) {
                    Button("Home") {
                       //print(//"Going home... \(path.count)")
                        path = NavigationPath()  // Go home
                    }
                }
            }

        }
        .navigationBarHidden(false)

    }
}
