//
//  SavedBooksScreen.swift
//  GutenbergListen
//
//  Created by ducrestfd on 1/19/26.
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

struct SavedBooksScreen: View {
    let placeItem: PlaceItem
    @Binding var path: NavigationPath
    
    
    // Local State
    @State private var isLoading = true
    @State private var error: String? = nil
    @State var fileLinks: [LinkItem] = []
    
    var body: some View {
        SavedBooksView(fileLinks: $fileLinks, path: $path)
        .task() {
            fileLinks.removeAll()
            await fetchSavedFileList()
        }
    }
    
    private func fetchSavedFileList() async {
        isLoading = true
        error = nil
        
        // 1. Get the URL for the Documents directory
        let fileManager = FileManager.default
        
        guard
            let documentsURL = fileManager.urls(
                for: .documentDirectory,
                in: .userDomainMask
            ).first
        else {
           //print(//"Could not find the Documents directory.")
            return
        }
        
       //print(//documentsURL.path)
        
        do {
            // 2. Fetch the contents of the directory
            // includingPropertiesForKeys: nil means we just want basic file info
            // options: .skipsHiddenFiles is usually preferred for user-facing lists
            let fileURLs = try fileManager.contentsOfDirectory(
                at: documentsURL,
                includingPropertiesForKeys: nil,
                options: .skipsHiddenFiles
            )
            
            // 3. Print or process the file names
            if fileURLs.isEmpty {
               //print(//"The directory is empty.")
            } else {
               //print(//"Files in Documents:")
                for file in fileURLs {
                   //print(//"\t\(file.lastPathComponent)")
                    if checkIfDirectory(
                        url: file,
                        documentsURL: documentsURL,
                        fileManager: fileManager
                    ) {
                        fileLinks.append(
                            LinkItem(
                                label: file.lastPathComponent + " (audio)",
                                href: file.absoluteString,
                                section: ""))
                    } else {
                        fileLinks.append(
                            LinkItem(
                                label: file.lastPathComponent + " (text)",
                                href: file.absoluteString,
                                section: ""))
                    }
                }
            }
        } catch {
           //print(//
           //     "Error while enumerating files: \(error.localizedDescription)"
           // )
        }
        
    }
    
    private func checkIfDirectory(url: URL, documentsURL: URL, fileManager: FileManager) -> Bool {
        do {
            
            // Fetch the resource values for the isDirectory key
            let values = try url.resourceValues(forKeys: [.isDirectoryKey])
            
            if let isDirectory = values.isDirectory {
                if isDirectory {
                    return true
                } else {
                    return false
                }
            } else {
                return false
            }
        } catch {
           //print(//"Error accessing file metadata: \(error.localizedDescription)")
            return false
        }
    }
}
