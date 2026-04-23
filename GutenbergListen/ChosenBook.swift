//
//  ChosenBook.swift
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
import UIKit
import os

private let log = Logger(
    subsystem: "com.yourcompany.GutenbergListen",
    category: "ChosenBook"
)

struct ChosenBook: View {
    let item: SelectedBook
    @Binding var path: NavigationPath
    
    // Derived title and author parsing from item.title
    private var justTitle: String {
        let title =
        item.title.split(separator: "\n").first.map(String.init)
        ?? item.title
        return title
    }
    
    private var justAuthor: String {
        if let tabIndex = item.title.lastIndex(of: "\t") {
            return String(item.title[item.title.index(after: tabIndex)...])
        }
        return "-no author-"
    }
    
    // Sharing state
    @State private var showShareSheet = false
    @State private var shareItems: [Any] = []
    
    // Download state
    @State private var isDownloading = false
    @State private var downloadError: String?
    @State private var showDownloadComplete = false
    
    @State private var disableDownloadButton = false
    
    private var htmlURLString: String {
        "https://www.gutenberg.org/cache/epub/\(item.bookId)/pg\(item.bookId)-images.html"
    }

    private var textURLString: String {
        //"https://www.gutenberg.org/ebooks/\(item.id).txt.utf-8"
        "https://www.gutenberg.org/cache/epub/\(item.bookId)/pg\(item.bookId).txt"
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("Gutenberg Listen!")
                    .bold()
                
                Divider()
                
                HStack(spacing: 16) {
                    
                    Button("Saved Books") {
                        path.append(PlaceItem(id: 7))
                    }
                    .foregroundColor(.black)
                    .bold()
                    .padding(.horizontal, 20)
                    .padding(.vertical, 5)
                    .background(Color.teal)
                    .clipShape(Capsule())
                }
                
                Divider()
                
                Text("eBook: \(justTitle)")
                    .font(.title3)
                
                Text("by \(justAuthor)")
                    .italic()
                    .font(.subheadline)
                
                if let downloadError {
                    Text("Download failed: \(downloadError)")
                        .foregroundStyle(.red)
                }
                
                Button(action: {
                    downloadAndShare(urlString: textURLString, title: justTitle)
                }) {
                    Label(
                        "Download Text File",
                        systemImage: "arrow.down.circle"
                    )
                }
                .buttonStyle(CustomDownloadStyle())
                .disabled(disableDownloadButton)
                
                Divider()
                
                Text("Share")
                    .italic()
                    .font(.subheadline)
                
                HStack(spacing: 16) {
                    
                    let encodedHtmlUrlString =
                    htmlURLString.addingPercentEncoding(
                        withAllowedCharacters: .urlQueryAllowed
                    ) ?? ""
                    // Use the String directly for the 'item' to fix the Copy issue
                    let shareableHtmlURLString =
                    "\(justTitle)\n\(encodedHtmlUrlString)"
                    
                    ShareLink(
                        item: shareableHtmlURLString,  // Changed from URL to String
                        subject: Text(justTitle),
                        message: Text(""),
                        preview: SharePreview(
                            justTitle,
                            image: Image(systemName: "book.closed.fill")
                        )
                    ) {
                        Label("HTML", systemImage: "square.and.arrow.up")
                    }
                    .foregroundColor(.black)
                    .bold()
                    .padding(.horizontal, 20)
                    .padding(.vertical, 5)
                    .background(Color.teal)
                    .clipShape(Capsule())
                    
                    let encodedTextUrlString =
                    textURLString.addingPercentEncoding(
                        withAllowedCharacters: .urlQueryAllowed
                    ) ?? ""
                    // Use the String directly for the 'item' to fix the Copy issue
                    let shareableTextURLString =
                    "\(justTitle)\n\(encodedTextUrlString)"
                    
                    ShareLink(
                        item: shareableTextURLString,  // Changed from URL to String
                        subject: Text(justTitle),
                        message: Text(""),
                        preview: SharePreview(
                            justTitle,
                            image: Image(systemName: "book.closed.fill")
                        )
                    ) {
                        Label("Text", systemImage: "square.and.arrow.up")
                    }
                    .foregroundColor(.black)
                    .bold()
                    .padding(.horizontal, 20)
                    .padding(.vertical, 5)
                    .background(Color.teal)
                    .clipShape(Capsule())
                    
                }
            }
            .padding(.horizontal)
        }
        .sheet(isPresented: $showShareSheet) {
            ActivityViewController(items: shareItems)
        }
        .toolbar {
            // TopBar Title -> Home Button
            ToolbarItem(placement: .title) {
                Button("Home") {
                   //print(//"Going home... \(path.count)")
                    path = NavigationPath()  // Go home
                }
            }
        }
        .navigationBarHidden(false)
        .alert("Download Complete", isPresented: $showDownloadComplete) {
            Button("OK", role: .cancel) {
                disableDownloadButton = true
            }
        }
    }
    
    // 1. Create a simple Delegate to handle the "Unsafe" connection
    class SecurityDelegate: NSObject, URLSessionTaskDelegate {
        func urlSession(
            _ session: URLSession,
            task: URLSessionTask,
            didReceive challenge: URLAuthenticationChallenge,
            completionHandler:
            @escaping (URLSession.AuthChallengeDisposition, URLCredential?)
            -> Void
        ) {
            // This tells the app: "If the site is gutenberg.org, just let the data through."
            completionHandler(
                .useCredential,
                URLCredential(trust: challenge.protectionSpace.serverTrust!)
            )
        }
    }
    
    // yes its very primative
    func downloadAndShare(urlString: String, title: String) {
        let fileManager = FileManager.default
        
        let secureURLString = urlString.replacingOccurrences(
            of: "http://",
            with: "https://"
        )
        
        guard
            let url = URL(
                string: secureURLString.addingPercentEncoding(
                    withAllowedCharacters: .urlQueryAllowed
                ) ?? ""
            )
        else { return }
        
       //print(//"url: \(url.absoluteString)")
        
        // Run this on a background thread to avoid freezing the UI
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                // Primitive data pull - sometimes bypasses strict URLSession ATS checks
                let data = try Data(contentsOf: url)
                
               //print(//"presanitizing: \(title)")
                let fname = sanitizeFileName(title) + ".txt"
                guard
                    let documentsURL = fileManager.urls(
                        for: .documentDirectory,
                        in: .userDomainMask
                    ).first
                else {
                    return
                }
                let actualURL = documentsURL.appendingPathComponent(fname)
               //print(//"fname: \(fname): actualURL: \(actualURL.path)")
                try data.write(to: actualURL)
               //print(//"✅ SUCCESS: Primitive download worked to actual URL!")
                
                DispatchQueue.main.async {
                    self.shareItems = [actualURL]
                    //self.showShareSheet = true
                    self.showDownloadComplete = true
                }
                
            } catch {
                //print("❌ ALL METHODS FAILED: \(error.localizedDescription)")
                //print("Note: If on Simulator, this is likely a persistent ATS configuration issue.")
            }
        }
    }
    
    struct ActivityViewController: UIViewControllerRepresentable {
        let items: [Any]
        func makeUIViewController(context: Context) -> UIActivityViewController
        {
            UIActivityViewController(
                activityItems: items,
                applicationActivities: nil
            )
        }
        
        func updateUIViewController(
            _ uiViewController: UIActivityViewController,
            context: Context
        ) {}
    }
    
}
