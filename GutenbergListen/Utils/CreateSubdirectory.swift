//
//  CreateSubdirectory.swift
//  GutenbergListen
//
//  Created by ducrestfd on 1/10/26.
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

import Foundation

func createFolderInFilesApp(folderName: String) {
    let fileManager = FileManager.default
    
    // 1. Get the URL for the app's Documents directory
    guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
        return
    }
    
    // 2. Define your new subdirectory name
    let folderURL = documentsURL.appendingPathComponent(folderName)
    
    do {
        // 3. Create the directory
        // withIntermediateDirectories: true ensures parent folders are made if they don't exist
        try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
       //print(//"Success: Folder is now visible in the Files app.")
    } catch {
       //print(//"Error creating directory: \(error.localizedDescription)")
    }
}
