//
//  AudioPlayListView.swift
//  GutenbergListen
//
//  Created by ducrestfd on 1/23/26.
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

struct AudioPlayListView: View {
    let fileDataAccess: FileDataAccess
    let item: LinkItem
    @Binding var fileLinks: [LinkItem]
    @Binding var path: NavigationPath
    
    @State private var showDeleteConfirmation = false
    
    var orderedFileLinks: [LinkItem] {
        fileLinks.sorted { a, b in
            let aLabel = a.label
            let bLabel = b.label
            let comparison = aLabel.localizedCaseInsensitiveCompare(bLabel)
            return comparison == .orderedAscending
        }
    }
    
    var headerView: some View {
        VStack(spacing: 0) {
            Text("Gutenberg Listen!")
                .font(.system(size: 24, weight: .bold))
                
            
            Text("Files for")
                .font(.system(size: 14, weight: .bold))
            Text(item.label)
                .padding(.bottom, 18)
            
        }
        
    }
    
    @ViewBuilder
    func deleteButton() -> some View {
        Button("Delete") {
            showDeleteConfirmation = true
        }
        .foregroundColor(.black)
        .bold()
        .padding(.horizontal, 20)
        .padding(5)
        .background(Color.red)
        .clipShape(Capsule())
        .alert("Are you sure you want to delete \(item.label)?", isPresented: $showDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                let fileName = item.label.hasSuffix(" (audio)") ? String(item.label.dropLast(" (audio)".count)) : item.label
                fileDataAccess.deleteFileAndRecordByName(for: fileName)
               //print(//"trying to delete \(fileName)")
                if path.count >= 2 {
                    path.removeLast(2)
                } else {
                    path = NavigationPath()
                }
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
                
            headerView
            
                List {
                    ForEach(orderedFileLinks) { item in
                        AudioPlayListItem(
                            item: item,
                            path: $path
                        )
                        .listRowSeparator(.hidden)  // Cleaner look similar to Compose default
                        .listRowInsets(
                            EdgeInsets(
                                top: 2,
                                leading: 16,
                                bottom: 2,
                                trailing: 16
                            )
                        )
                    }
                }
                .listStyle(.plain)
                .safeAreaInset(edge: .bottom) {
                    Color.clear.frame(height: 12)
                }
                .environment(\.defaultMinListRowHeight, 0)
                
            deleteButton()
            
            Spacer()
            
            
        }
        .navigationBarBackButtonHidden(true)
           .toolbar {
               ToolbarItem(placement: .navigationBarLeading) {
                   Button(action: {
                       if path.count >= 2 {
                           path.removeLast(2)
                       } else {
                           path = NavigationPath()
                       }
                   }) {
                       Label("Back 2", systemImage: "arrow.left")
                   }
               }
           }
        .toolbar {

            // TopBar Title -> Home Button
            ToolbarItem(placement: .principal) {
                Button("Home") {
                   //print(//"Going back... \(path.count)")
                    path = NavigationPath()  // Go home
                }
            }
        }
        
    }
}

