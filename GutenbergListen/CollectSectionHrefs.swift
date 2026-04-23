//
//  CollectCategoryHrefs.swift
//  GutenbergListen
//
//  Created by ducrestfd on 1/3/26.
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

import Foundation
import SwiftSoup // Requires adding SwiftSoup via Swift Package Manager

func collectSectionHrefs(section: String, href: String, startingIndex: Int) async -> [LinkItem] {
    var results = [LinkItem]()
    
    var urlString = href
    if startingIndex > 1 {
        urlString = "\(href)&start_index=\(startingIndex)"
    }
    
    guard let url = URL(string: urlString) else { return results }
    
    do {
        // Fetch the document asynchronously
        var request = URLRequest(url: url)
        request.setValue("Mozilla/5.0 (compatible; SwiftScraper/1.0)", forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = 20.0
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        guard let html = String(data: data, encoding: .utf8) else {
            return results
        }
        
        // Parse the document using SwiftSoup
        let doc: Document = try SwiftSoup.parse(html, urlString)
        
        // Select each list item with class "booklink"
        let bookLists: Elements = try doc.select("li.booklink")
        
        for bookList in bookLists {
            guard let a1 = try bookList.select("a[href]").first() else { continue }
            
            // Try to get absolute URL, fallback to attribute
            var bookHref = try a1.absUrl("href")
            if bookHref.isEmpty {
                bookHref = try a1.attr("href")
            }
            bookHref = bookHref.trimmingCharacters(in: .whitespacesAndNewlines)
            
            let titleSpan = try bookList.select("span.title").first()?.text() ?? ""
            let subtitleSpan = try bookList.select("span.subtitle").first()?.text() ?? ""
            
            let title = "\(titleSpan.trimmingCharacters(in: .whitespacesAndNewlines))\n\t\t\(subtitleSpan.trimmingCharacters(in: .whitespacesAndNewlines))"
            
            results.append(LinkItem(label: title, href: bookHref, section: section))
        }
        
        return results
        
    } catch {
       //print(//"Error fetching or parsing: \(error)")
        return results
    }
}
