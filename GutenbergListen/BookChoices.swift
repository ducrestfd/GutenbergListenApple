//
//  BookChoices.swift
//  GutenbergListen
//
//  Created by ducrestfd on 1/2/26.
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

import SafariServices
import SwiftUI
import UIKit
import WebKit

struct WebView: UIViewRepresentable {
    let fileURL: URL

    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        do {
            // 1. Read the text file into a string
            let textContent = try String(contentsOf: fileURL, encoding: .utf8)

            // 2. Load it as HTML (wrapping it in <pre> preserves formatting)
            let htmlString =
                "<html><body><pre>\(textContent)</pre></body></html>"
            uiView.loadHTMLString(htmlString, baseURL: nil)
        } catch {
           //print(//"Error reading file: \(error)")
        }
    }
}

struct BookChoices: View {
    let fileDataAccess: FileDataAccess
    let selectedSavedBook: LinkItem
    @Binding var path: NavigationPath
    
    @State private var showShareSheet = false
    @State private var showSafari = false
    @State private var showWebView = false
    @State private var didNavigate = false
    @State private var showDeleteConfirmation = false
    
    var body: some View {

        ScrollView {
            // Header Content
            VStack(spacing: 4) {

                if selectedSavedBook.label.contains("(text)") {

                    Text("Gutenberg Listen!")
                        .font(.system(size: 20, weight: .bold))
                    Text(
                        selectedSavedBook.label.replacingOccurrences(
                            of: "_",
                            with: " "
                        ).replacingOccurrences(of: ".txt", with: "")
                    )
                    .font(.system(size: 14, weight: .bold))
                    
                    Spacer(minLength: 18)
                    
                    let fileURL = FileManager.default.urls(
                        for: .documentDirectory,
                        in: .userDomainMask
                    )[0].appendingPathComponent(
                        selectedSavedBook.label.replacingOccurrences(
                            of: " (text)",
                            with: ""
                        )
                    )
                    
                    HStack {
                        
                        Spacer()
                        
                        Button(action: {
                            path.append(
                                TextToSpeechListening(item: selectedSavedBook)
                            )
                        }) {
                            Text("Listen")
                        }
                        .foregroundColor(Color.black)  // Sets the text color to black
                        .bold()
                        .padding(.horizontal, 20)
                        .padding(5)  // Adds padding around the text
                        .background(Color.teal)
                        .clipShape(Capsule())
                        
                        Button(action: {
                            showWebView = true
                        }) {
                            Text("Text")
                        }
                        .foregroundColor(Color.black)
                        .bold()
                        .padding(.horizontal, 20)
                        .padding(5)
                        .background(Color.teal)
                        .clipShape(Capsule())
                        .sheet(isPresented: $showWebView) {
                            WebViewContainer(fileURL: fileURL)
                        }
                        
                        Spacer()
                        
                    }
                    
                    Spacer(minLength: 18)
                    
                    ShareLink(item: selectedSavedBook.href) {
                        Label(
                            "Share or Save File",
                            systemImage: "square.and.arrow.up"
                        )
                    }
                    .foregroundColor(Color.black)  // Sets the text color to black
                    .bold()
                    .padding(.horizontal, 20)
                    .padding(5)  // Adds padding around the text
                    .background(Color.teal)
                    .clipShape(Capsule())
                    
                    Spacer(minLength: 48)
                    
                    
                    Button("Delete") {
                        showDeleteConfirmation = true
                        fileDataAccess.deleteFileRecordByName(selectedSavedBook.label)
                    }
                    .foregroundColor(Color.black)
                    .bold()
                    .padding(.horizontal, 20)
                    .padding(5)
                    .background(Color.red)
                    .clipShape(Capsule())
                    .alert("Are you sure you want to delete \(selectedSavedBook.label)?", isPresented: $showDeleteConfirmation) {
                        Button("Delete", role: .destructive) {
                            
                            do {
                                let fileManager = FileManager.default
                                
                                if !(selectedSavedBook.href.isEmpty) {
                                    try fileManager.removeItem(
                                        at: URL(string: selectedSavedBook.href)!
                                    )
                                   //print(//"File deleted successfully!")
                                    path.removeLast(2)
                                }
                            } catch {
                               //print(//"Error deleting file: \(error)")
                            }
                        }
                    }
                    
                }

            }
        }
        .onAppear {
            if selectedSavedBook.label.contains("(audio)") && !didNavigate {
                path.append(AudioPlayListing(item: selectedSavedBook))
                didNavigate = true
            }
        }
        .toolbar {
            
            // TopBar Title -> Home Button
            ToolbarItem(placement: .principal) {
                Button("Home") {
                    path = NavigationPath()  // Go home
                }
            }
        }
    }
    
    
}


struct WebViewContainer: View {
    let fileURL: URL
    
    @Environment(\.dismiss) var dismiss // This handles the "back" action

    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    dismiss() // This closes the current screen
                }) {
                    Label("", systemImage: "arrow.left")
                        .foregroundColor(.black)
                }
                .padding()
                Spacer()
            }
            
            WebView(fileURL: fileURL)
        }
    }
}
