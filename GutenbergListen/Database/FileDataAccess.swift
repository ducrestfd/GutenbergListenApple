//
//  FileDataAccess.swift
//  GutenbergListen
//
//  Created by ducrestfd on 1/29/26.
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
import SwiftData
import UIKit
import SwiftUI
import Combine

class FileDataAccess: ObservableObject {
    let objectWillChange = ObservableObjectPublisher()
    
    let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    var files: [DownloadedFile] {
        let descriptor = FetchDescriptor<DownloadedFile>(sortBy: [SortDescriptor(\DownloadedFile.fileName, order: .reverse)])
        do {
            return try modelContext.fetch(descriptor)
        } catch {
           //print(//"Failed to fetch files: \(error)")
            return []
        }
    }
    
    // CREATE: Adding a new file record
    func addFile(fileName: String) -> DownloadedFile {
        let newFile = DownloadedFile(fileName: fileName)
        self.modelContext.insert(newFile)
        // self.objectWillChange.send()
        return newFile
    }
    
    // UPDATE: Modifying an existing record
    func updateUsage(
        for file: DownloadedFile,
        location: Int,
        readingSpeed: Float,
        readingPitch: Float,
        playingSpeed: Float
    ) {
        file.location = location
        file.readingSpeed = readingSpeed
        file.readingPitch = readingPitch
        file.playingSpeed = playingSpeed
    }
    
    // UPDATE: Modifying an existing record
    func updateUsage(
        fileName: String,
        location: Int,
        readingSpeed: Float,
        readingPitch: Float,
        playingSpeed: Float,
        currentTime: TimeInterval
    ) {
        // 1. Create the search criteria
        let predicate = #Predicate<DownloadedFile> { file in
            file.fileName == fileName
        }
        
        // 2. Fetch the specific record
        let descriptor = FetchDescriptor<DownloadedFile>(predicate: predicate)
        
        do {
            // 3. Get the first match (since names are unique)
            if let fileToUpdate = try self.modelContext.fetch(descriptor).first {
                // 4. Update the property directly
   
                fileToUpdate.location = location
                fileToUpdate.readingSpeed = readingSpeed
                fileToUpdate.readingPitch = readingPitch
                fileToUpdate.playingSpeed = playingSpeed
                fileToUpdate.currentTime = currentTime
                
                // SwiftData will auto-save this change shortly!
               //print(//"Successfully updated usage for \(fileName)")
            } else {
               //print(//"No record found with name: \(fileName)")
            }
        } catch {
           //print(//"Fetch failed: \(error)")
        }
    }
    
    func fetchFile(named name: String) -> DownloadedFile? {
        // 1. Define the search criteria
        let predicate = #Predicate<DownloadedFile> { file in
            file.fileName == name
        }
        
        // 2. Create the descriptor (limit to 1 for efficiency)
        var descriptor = FetchDescriptor<DownloadedFile>(predicate: predicate)
        descriptor.fetchLimit = 1
        
        // 3. Execute the fetch
        do {
            let matches = try self.modelContext.fetch(descriptor)
            return matches.first
        } catch {
           //print(//"Error fetching file: \(error)")
            return nil
        }
    }
    
    func clearHistory() {
        // Delete all records from the database
        try? self.modelContext.delete(model: DownloadedFile.self)
    }
    
    func deleteFileRecordByName(_ name: String) {
        // 1. Create a Predicate to find the specific file
        let predicate = #Predicate<DownloadedFile> { file in
            file.fileName == name
        }
        
        // 2. Create a FetchDescriptor with that predicate
        let descriptor = FetchDescriptor<DownloadedFile>(predicate: predicate)
        
        // 3. Perform the fetch and delete the results
        do {
            let matches = try self.modelContext.fetch(descriptor)
            for file in matches {
                self.modelContext.delete(file)
            }
            // Save the changes
            try self.modelContext.save()
        } catch {
           //print(//"Failed to delete file record: \(error)")
        }
    }
    
    func deleteFileAndRecordByName(for fileName: String) {
        // 1. Delete the physical file from the disk
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = docs.appendingPathComponent(fileName)
        
       //print(//"********************* fileURL to delete: \(fileURL.path)")
        
        try? FileManager.default.removeItem(at: fileURL)
        
        // 2. Delete the record from SwiftData
        deleteFileRecordByName(fileName)
    }
    
    
    func generateUniqueName(for baseName: String) -> String {
        let fileManager = FileManager.default
        let docs = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        var uniqueName = baseName
        var counter = 1
        
        // Check if file exists; if so, increment the name
        while fileManager.fileExists(atPath: docs.appendingPathComponent(uniqueName).path) {
            let nameWithoutExtension = (baseName as NSString).deletingPathExtension
            let fileExtension = (baseName as NSString).pathExtension
            uniqueName = "\(nameWithoutExtension)-\(counter).\(fileExtension)"
            counter += 1
        }
        
        return uniqueName
    }
}

