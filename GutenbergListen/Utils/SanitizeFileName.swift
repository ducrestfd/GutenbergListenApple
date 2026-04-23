//
//  SanitizeFileName.swift
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

func sanitizeFileName(_ s: String) -> String {
    let invalid = CharacterSet(charactersIn: "/\\?%*|\"<>:.").union(.newlines)
    return s.components(separatedBy: invalid).joined().replacingOccurrences(of: " ", with: "_")
}
