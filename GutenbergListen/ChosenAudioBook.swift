//
//  ChosenAudioBook.swift
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
internal import System
import UIKit
import os

private let audioLog = Logger(
    subsystem: "com.yourcompany.GutenbergListen",
    category: "ChosenAudioBook"
)

struct ChosenAudioBook: View {
    let item: SelectedBook
    @Binding var path: NavigationPath
    let onAddAudioLocation: ((String) -> Void)?

    init(
        item: SelectedBook,
        path: Binding<NavigationPath>,
        onAddAudioLocation: ((String) -> Void)? = nil
    ) {
        self.item = item
        self._path = path
        self.onAddAudioLocation = onAddAudioLocation
    }

    // Title/author parsing similar to ChosenBook
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
    @State private var showDownloadComplete = false

    // Download state
    @State private var isDownloading = false
    @State private var downloadError: String?

    @State private var disableDownloadButton = false

    // Links: example OGG first chapter and a generic audio page
    private var m4bURLString: String {
        // Common Gutenberg pattern: /files/<id>/ogg/<id>-01.ogg
        "https://www.gutenberg.org/files/\(item.bookId)/m4b/\(item.bookId)-01.m4b"
    }
    private var audioPageURLString: String {
        "https://www.gutenberg.org/ebooks/\(item.bookId)"
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {

                if isDownloading {
                    ProgressView("Downloading...")
                        .padding()
                }

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

                Text("Audio Book: \(justTitle)")
                    .font(.title3)

                Text("by \(justAuthor)")
                    .italic()
                    .font(.subheadline)

                if let downloadError {
                    Text("Download failed: \(downloadError)")
                        .foregroundStyle(.red)
                }

                HStack {

                    Button(action: {
                        downloadAndShare(
                            urlString: m4bURLString,
                            title: justTitle
                        )
                    }) {
                        Label(
                            "Download Audio File",
                            systemImage: "arrow.down.circle"
                        )
                    }
                    .buttonStyle(CustomDownloadStyle())
                    .disabled(disableDownloadButton)

                }

                Divider()

                Text("Share")
                    .italic()
                    .font(.subheadline)

                let tempM4bURLString = getUrlStringWithoutFilename(
                    url: m4bURLString
                )
                let encodedM4bUrlString =
                    tempM4bURLString.addingPercentEncoding(
                        withAllowedCharacters: .urlQueryAllowed
                    ) ?? ""
                // Use the String directly for the 'item' to fix the Copy issue
                let shareableM4bURLString =
                    "\(justTitle)\n\(encodedM4bUrlString)"

                ShareLink(
                    item: shareableM4bURLString,  // Changed from URL to String
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

    func getUrlStringWithoutFilename(url: String) -> String {
        if let lastSlashIndex = url.lastIndex(of: "/") {
            // This takes everything from the start up to (but not including) the slash
            return String(url[..<lastSlashIndex])

        } else {
            return "No slash found"
        }
    }

    func replaceDigits(in filename: String, with newString: String) -> String {
        // Regex looks for: "-" then two digits then ".m4b" at the end ($)
        let regex = /-\d{2}\.m4b$/

        // Replace the matched portion
        return filename.replacing(regex, with: "-\(newString).m4b")
    }

    // yes its very primative
    func downloadAndShare(urlString: String, title: String) {
        let fileManager = FileManager.default

        var fileNumberString = "0"
        var fileNumber = 0

        var secureURLString = urlString.replacingOccurrences(
            of: "http://",
            with: "https://"
        )

        guard
            var url = URL(
                string: secureURLString.addingPercentEncoding(
                    withAllowedCharacters: .urlQueryAllowed
                ) ?? ""
            )
        else { return }

       //print(//"url: \(url.absoluteString)")

        // Run this on a background thread to avoid freezing the UI
        DispatchQueue.global(qos: .userInitiated).async {
            do {

                isDownloading = true
                // Primitive data pull - sometimes bypasses strict URLSession ATS checks

                repeat {

                    let data = try Data(contentsOf: url)

                    var fname = sanitizeFileName(title)
                    guard
                        let documentsURL = fileManager.urls(
                            for: .documentDirectory,
                            in: .userDomainMask
                        ).first
                    else {
                        return
                    }

                    createFolderInFilesApp(folderName: fname)

                    var actualURL = documentsURL.appendingPathComponent(fname)
                    fileNumber += 1
                    if fileNumber < 10 {
                        fileNumberString = "0\(fileNumber)"
                    } else {
                        fileNumberString = "\(fileNumber)"
                    }
                    fname = "\(fname)-\(fileNumberString).m4b"
                    actualURL = actualURL.appendingPathComponent(fname)

                   //print(//"actualURL: \(actualURL.path)")

                    try data.write(to: actualURL)

                   //print(//"✅ SUCCESS: Primitive download worked to actual URL!")

                    var tempFileNumberString = "0"
                    let tempFileNumber = fileNumber + 1
                    if tempFileNumber < 10 {
                        tempFileNumberString = "0\(tempFileNumber)"
                    } else {
                        tempFileNumberString = "\(tempFileNumber)"
                    }

                    let newURLString = replaceDigits(
                        in: urlString,
                        with: tempFileNumberString
                    )

                    secureURLString = newURLString.replacingOccurrences(
                        of: "http://",
                        with: "https://"
                    )

                    url =
                        URL(
                            string: secureURLString.addingPercentEncoding(
                                withAllowedCharacters: .urlQueryAllowed
                            ) ?? ""
                        ) ?? URL(filePath: "")!
                } while true

            } catch {

                isDownloading = false

                // Notify the user on the main thread
                DispatchQueue.main.async {
                    self.showDownloadComplete = true  // Example: set @State to trigger UI
                }
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
