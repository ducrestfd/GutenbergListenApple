//
//  ContentView.swift
//  GutenbergListen
//
//  Created by ducrestfd on 12/31/25.
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

import SwiftData
import SwiftUI

struct SearchItem: Hashable {
    let id: Int
    let searchTerm: String
    let searchType: String
}

struct BrowseItem: Hashable {
    let id: Int
    let browseType: String
}

struct PlaceItem: Hashable {
    let id: Int
}

struct SelectedBook: Hashable {
    let id: Int
    let bookId: Int
    let title: String
}

struct SelectedSavedBook: Hashable {
    let id: Int
    let title: String
}

struct SelectedSection: Hashable {
    let id: Int
    let browseType: String
    let title: String
}

struct SelectedSubsection: Hashable {
    let id: Int
    let browseType: String
    let subsection: String

}

struct BrowseSection: Hashable, Equatable {
    let browseType: String
    let title: String
}

struct BookListing: Hashable, Equatable {
    let browseType: String
    let subsection: String
    let shelfNumber: String
}

struct Link: Identifiable, Sendable {
    let id: Int
    let section: String
    let href: String
    let label: String
}

struct LinkItem: Identifiable, Hashable {
    let id = UUID()
    let label: String
    let href: String
    let section: String?
}

enum BookDestination: Hashable, Equatable {
    case audio(id: Int, label: String)
    case digital(id: Int, label: String)
}

struct BookUseChoices: Identifiable, Hashable {
    let id = UUID()
    let item: LinkItem
}

struct AudioPlayListing: Identifiable, Hashable {
    let id = UUID()
    let item: LinkItem
}

struct AudioPlayerListening: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let item: LinkItem
}

struct TextToSpeechListening: Identifiable, Hashable {
    let id = UUID()
    let item: LinkItem
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext

    @State private var database: FileDataAccess?
    @State private var path = NavigationPath()


    var body: some View {

        NavigationStack(path: $path) {

            if database != nil {

                // Main View Content

                DetailView(count: 1, path: $path)
                    .navigationDestination(for: SearchItem.self) { item in
                        DirectResultsScreen(item: item, path: $path)
                    }
                    .navigationDestination(for: BrowseItem.self) { item in
                        Browse(item: item, path: $path)
                    }
                    .navigationDestination(for: String.self) { text in
                        if text == "About" { AboutView() }
                    }
                    .navigationDestination(for: PlaceItem.self) { item in
                        SavedBooksScreen(placeItem: item, path: $path)
                    }
                    .navigationDestination(for: BookDestination.self) {
                        destination in
                        switch destination {
                        case .audio(let bookId, let label):
                            ChosenAudioBook(
                                item: SelectedBook(
                                    id: 4,
                                    bookId: bookId,
                                    title: label
                                ),
                                path: $path
                            )
                        case .digital(let bookId, let label):
                            ChosenBook(
                                item: SelectedBook(
                                    id: 3,
                                    bookId: bookId,
                                    title: label
                                ),
                                path: $path
                            )
                        }
                    }
                    .navigationDestination(for: BrowseSection.self) { item in
                        BrowseSectionScreen(
                            item: SelectedSection(
                                id: 5,
                                browseType: item.browseType,
                                title: item.title
                            ),
                            path: $path
                        )
                    }
                    .navigationDestination(for: BookListing.self) { item in
                        BookListingScreen(
                            item: SelectedSubsection(
                                id: 6,
                                browseType: item.browseType,
                                subsection: item.subsection
                            ),
                            shelfNumber: item.shelfNumber,
                            path: $path
                        )
                    }
                    .navigationDestination(for: BookUseChoices.self) { item in
                        BookChoices(fileDataAccess: database!, selectedSavedBook: item.item, path: $path)
                    }
                    .navigationDestination(for: AudioPlayListing.self) { item in
                        AudioPlayListScreen(fileDataAccess: database!, item: item.item, path: $path)
                    }
                    .navigationDestination(for: AudioPlayerListening.self) {
                        item in
                        AudioPlayer(
                            fileDataAccess: database!,
                            title: item.title,
                            item: item.item,
                            path: $path
                        )
                    }
                    .navigationDestination(for: TextToSpeechListening.self) {
                        item in
                        TextToSpeech(
                            selectedSavedBook: item.item,
                            database: database!,
                            path: $path
                        )
                    }

            } else {
                ProgressView()
            }
        }
        .task {
            // Initialize once the context is guaranteed to be available
            if database == nil {
                database = FileDataAccess(modelContext: modelContext)
            }
        }
    }
}

struct DetailView: View {
    let count: Int
    @Binding var path: NavigationPath

    @State var searchTerm: String = ""
    
    
    var privacyPolicy: AttributedString {
        var s = AttributedString("Privacy Policy")
        if let range = s.range(of: "Privacy Policy") {
            s[range].link = URL(string: "https://drive.google.com/file/d/1bizzJ9malXDVkVlWjndG1lx05mp6baRF/view?usp=sharing")
            s[range].foregroundColor = .blue
            s[range].underlineStyle = .single
        }
        return s
    }
    
    var accessibilityStatement: AttributedString {
        var s = AttributedString("Accessibility Statement")
        if let range = s.range(of: "Accessibility Statement") {
            s[range].link = URL(string: "https://drive.google.com/file/d/1fUVOKEIMzbfzs_iZR2zcEMevjd5dnkvv/view?usp=sharing")
            s[range].foregroundColor = .blue
            s[range].underlineStyle = .single
        }
        return s
    }
    
    
    
    var body: some View {
        ScrollView {
            VStack {

                Spacer()

                Text("Gutenberg Listen!")
                    .font(.title)

                Spacer(minLength: 24)

                NavigationLink(value: PlaceItem(id: 7)) {
                    Text("Saved Books")
                        .foregroundColor(Color.black)  // Sets the text color to black
                        .bold()
                        .padding(.horizontal, 20)
                        .padding(5)  // Adds padding around the text
                        .background(Color.teal)
                        .clipShape(Capsule())
                }
                .padding(.horizontal)

                Spacer(minLength: 24)

                TextField("Search Term", text: $searchTerm)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal, 20)
                    .background(Color.indigo.opacity(0.2))  // Adds a background color
                    .border(Color.blue, width: 2)

                NavigationLink(
                    value: SearchItem(
                        id: 1,
                        searchTerm: searchTerm,
                        searchType: "Default Order"
                    )
                ) {
                    Text("Search")
                        .foregroundColor(Color.black)  // Sets the text color to black
                        .bold()
                        .padding(.horizontal, 20)
                        .padding(5)  // Adds padding around the text
                        .background(Color.teal)
                        .clipShape(Capsule())
                }
                .padding(.horizontal)

                NavigationLink(
                    value: SearchItem(
                        id: 1,
                        searchTerm: searchTerm,
                        searchType: "Sorted by Title"
                    )
                ) {
                    Text("Search & Sort by Title")
                        .foregroundColor(Color.black)  // Sets the text color to black
                        .bold()
                        .padding(.horizontal, 20)
                        .padding(5)  // Adds padding around the text
                        .background(Color.teal)
                        .clipShape(Capsule())
                }
                .padding(.horizontal)

                NavigationLink(
                    value: SearchItem(
                        id: 1,
                        searchTerm: searchTerm,
                        searchType: "Sorted by Release Date"
                    )
                ) {
                    Text("Search & Sort by Release Date")
                        .foregroundColor(Color.black)  // Sets the text color to black
                        .bold()
                        .padding(.horizontal, 20)
                        .padding(5)  // Adds padding around the text
                        .background(Color.teal)
                        .clipShape(Capsule())
                }
                .padding(.horizontal)

                Spacer(minLength: 24)

                NavigationLink(
                    value: BrowseItem(id: 2, browseType: "Browse by Popularity")
                ) {
                    Text("Browse by Popularity")
                        .foregroundColor(Color.black)  // Sets the text color to black
                        .bold()
                        .padding(.horizontal, 20)
                        .padding(5)  // Adds padding around the text
                        .background(Color.teal)
                        .clipShape(Capsule())
                }
                .padding(.horizontal)

                NavigationLink(
                    value: BrowseItem(id: 2, browseType: "Browse by Title")
                ) {
                    Text("Browse by Title")
                        .foregroundColor(Color.black)  // Sets the text color to black
                        .bold()
                        .padding(.horizontal, 20)
                        .padding(5)  // Adds padding around the text
                        .background(Color.teal)
                        .clipShape(Capsule())
                }
                .padding(.horizontal)

                NavigationLink(
                    value: BrowseItem(id: 2, browseType: "Browse by Author")
                ) {
                    Text("Browse by Author")
                        .foregroundColor(Color.black)  // Sets the text color to black
                        .bold()
                        .padding(.horizontal, 20)
                        .padding(5)  // Adds padding around the text
                        .background(Color.teal)
                        .clipShape(Capsule())
                }
                .padding(.horizontal)

                NavigationLink(
                    value: BrowseItem(
                        id: 2,
                        browseType: "Browse by ReleaseDate"
                    )
                ) {
                    Text("Browse by Release Date")
                        .foregroundColor(Color.black)  // Sets the text color to black
                        .bold()
                        .padding(.horizontal, 20)
                        .padding(5)  // Adds padding around the text
                        .background(Color.teal)
                        .clipShape(Capsule())
                }
                .padding(.horizontal)

                Spacer(minLength: 24)

                NavigationLink(destination: AboutView()) {
                    Text("About")
                        .foregroundColor(Color.black)  // Sets the text color to black
                        .bold()
                        .padding(.horizontal, 20)
                        .padding(5)  // Adds padding around the text
                        .background(Color.teal)
                        .clipShape(Capsule())
                }
                .padding(.horizontal)
                
                /*
                Text(privacyPolicy)
                    .foregroundColor(Color.black)  // Sets the text color to black
                    .bold()
                    .italic()
                    .padding(.horizontal, 20)
                    .padding(5)  // Adds padding around the text

                Text(accessibilityStatement)
                    .foregroundColor(Color.black)  // Sets the text color to black
                    .bold()
                    .italic()
                    .padding(.horizontal, 20)
                    .padding(5)  // Adds padding around the text
                */
                
                Spacer(minLength: 24)
                
                 
                HStack {
                    NavigationLink(destination: PrivacyPolicy()) {
                        Text("Privacy Policy")
                            .foregroundColor(Color.blue)  // Sets the text color to black
                            .bold()
                            .italic()
                            .underline()
                            //.padding(.horizontal, 20)
                            .padding(5)  // Adds padding around the text
                        /*
                            .foregroundColor(Color.black)  // Sets the text color to black
                            .bold()
                            .padding(.horizontal, 20)
                            .padding(5)  // Adds padding around the text
                            .background(Color.teal)
                            .clipShape(Capsule())
                         */
                    }
                    //.padding(.horizontal)
                    
                    NavigationLink(destination: AccessibilityStatement()) {
                        Text("Accessibility Statement")
                            .foregroundColor(Color.blue)  // Sets the text color to black
                            .bold()
                            .italic()
                            .underline()
                            //.padding(.horizontal, 20)
                            .padding(5)  // Adds padding around the text
                        /*
                        
                            .foregroundColor(Color.black)  // Sets the text color to black
                            .bold()
                            .padding(.horizontal, 20)
                            .padding(5)  // Adds padding around the text
                            .background(Color.teal)
                            .clipShape(Capsule())
                         */
                    }
                    //.padding(.horizontal)
                }
                
                Spacer(minLength: 24)
                
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: Settings()) {
                        //Image(systemName: "gearshape")
                        Label("Default Settings", systemImage: "gearshape")
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)

    }

}
