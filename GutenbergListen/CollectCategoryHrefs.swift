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
import SwiftSoup

func collectCategoryHrefs() async -> [LinkItem] {
    
    var results: [LinkItem] = []
    let urlString = "https://www.gutenberg.org/ebooks/categories"
    guard let url = URL(string: urlString) else {
        return results
    }

    do {
        var request = URLRequest(url: url)
        request.timeoutInterval = 20 // seconds
        request.setValue("Mozilla/5.0 (compatible; SwiftScraper/1.0)", forHTTPHeaderField: "User-Agent")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        guard let html = String(data: data, encoding: .utf8) else {
            return results
        }

        // Parse with SwiftSoup
        let doc: Document = try SwiftSoup.parse(html, urlString)

        // Select each "book-list" division which groups categories under a section
        for bookList in try doc.select("div.book-list").array() {

            // Get the section title from the H2 tag
            guard let h2 = try bookList.select("h2").first() else { continue }
            let section = (try? h2.text().trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)) ?? ""

            // Find the unordered list (ul) containing the category links
            guard let ul = try bookList.select("ul").first() else { continue }

            // Iterate over each anchor tag (a) with an href attribute within the ul
            for a in try ul.select("a[href]").array() {
                let text = (try? a.text().trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)) ?? ""

                // absUrl fallback to attr("href") if empty, then trim
                let abs = try a.absUrl("href")
                let rel = try a.attr("href")
                let href = (abs.isEmpty ? rel : abs).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)

                //print("category: \(section), label: \(text), url: \(href)")
                
                if !text.isEmpty && !href.isEmpty {
                    results.append(LinkItem(label: section, href: href, section: text))
                }
            }
        }

        return results
    } catch {
        // Mirror Kotlin behavior: return whatever was accumulated (likely empty)
        return results
    }
}

