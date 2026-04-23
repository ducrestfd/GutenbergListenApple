//
//  About.swift
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
import SwiftData

struct AboutView: View {
    
    let fullTextLicense =
    "Gutenberg Listen's raison d'être is to provide simple access to " +
    "the Project Gutenberg website of 70,000 plus books to blind " +
    "users or to anyone using a screen reader by providing a succinct " +
    "browsing experience (decluttered, to used the vernacular) to speed " +
    "navigation. Everyone is, of course, " +
    "welcome to use it.  It is provided without charge under the " +
    "agpl-3.0 license.\n\n" +
    "\t\tCopyright (C) 2026 Frank D. Ducrest\n\n" +
    "This program is free software: you can redistribute it and/or modify " +
    "it under the terms of the GNU Affero General Public License as published " +
    "by the Free Software Foundation, either version 3 of the License, or " +
    "any later version.\n\n" +
    "This program is distributed in the hope that it will be useful, " +
    "but WITHOUT ANY WARRANTY; without even the implied warranty of " +
    "MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the " +
    "GNU Affero General Public License for more details.\n\n" +
    "You should have received a copy of the GNU Affero General Public License " +
    "along with this program.  If not, see https://www.gnu.org/licenses/agpl-3.0.en.html"
    
    let trademarkDisclaimer =
    "Project Gutenberg is a registered trademark of the Project Gutenberg Literary Archive Foundation. " +
    "This app is not an offical Project Gutenberg application, nor is it affiliated with or endorsed by " +
    "the Foundation."
    
    let updates =
    "\nUpdates:\n\n" +
    "Renamed project Gutenberg Listen.\n" +
    "Improved VoiceOver strings.\n" +
    "Fixed lock screen stop.\n" +
    "Fixed auto-language detection failure.\n" +
    "Set policy and accessibility links to show in light and dark modes.\n" +
    "Added sleep timers to both audio and ebook listening.\n" +
    "Added voice selection to ebook listening.\n"
    
        
    let emailAddress = "ducrestfd@gmail.com"
    let mailtoUrl = "mailto:$emailAddress"
    let gnuAddress = "https://www.gnu.org/licenses/agpl-3.0.en.html"
    let fullGutenbergAbout = "To find out more about the Project Gutenberg,\nsee https://www.gutenberg.org/about/"
    let gutenbergAddress = "https://www.gutenberg.org/about/"
    let gitHubAddress = "https://github.com/ducrestfd/GutenbergListenApple/"
    let gitHubText = "Code for this project is available at https://github.com/ducrestfd/GutenbergListenApple"
    
    var license: AttributedString {
        var s = AttributedString(fullTextLicense)
        
        if let range = s.range(of: "https://www.gnu.org/licenses/agpl-3.0.en.html") {
            s[range].link = URL(string: "https://www.gnu.org/licenses/agpl-3.0.en.html")
            s[range].foregroundColor = .blue
            s[range].underlineStyle = .single
        }
        
        return s
    }
    
    var gutenbergInfo: AttributedString {
        var s = AttributedString("To find out more about Project Gutenberg, see Project Gutenberg About.")
        if let range = s.range(of: "Project Gutenberg About") {
            s[range].link = URL(string: "https://www.gutenberg.org/about/")
            s[range].foregroundColor = .blue
            s[range].underlineStyle = .single
        }
        return s
    }
    
    var githubInfo: AttributedString {
        var s = AttributedString("Code for this project is available at GitHub.")
        if let range = s.range(of: "GitHub") {
            s[range].link = URL(string: "https://github.com/ducrestfd/GutenbergListenApple/")
            s[range].foregroundColor = .blue
            s[range].underlineStyle = .single
        }
        return s
    }
    
    var emailInfo: AttributedString {
        var s = AttributedString("If you have any questions or suggestions, please email me at ducrestfd@gmail.com.")
        if let range = s.range(of: "ducrestfd@gmail.com") {
            s[range].link = URL(string: "mailto:ducrestfd@gmail.com")
            s[range].foregroundColor = .blue
            s[range].underlineStyle = .single
        }
        return s
    }
    
    var body: some View {
        ScrollView {
            VStack {
                
                Text("Gutenberg Listen!")
                    .bold()
                    .font(.title)
                
                Text("Release date 2026-04-23 version 2.5.2")
                    .font(.subheadline)
                    .italic()
                
                
                
                //Spacer(minLength: 24)
                
                Text("About")
                    .font(.largeTitle)
                    .padding()
                
                //Spacer(minLength: 18)
                
                Text(license)
                    .font(.body)
                    //.frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer(minLength: 12)
                
                Text(trademarkDisclaimer)
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer(minLength: 12)
                
                Text(gutenbergInfo)
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer(minLength: 12)
                
                Text("All books saved by this app are HTML/text/iTunes Audio files located on your device and are limited to use by this app. " +
                     "Links to the original files may be copied and shared for opening in your preferred app (such as " +
                     "Speechify, Firefox, etc.)")
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer(minLength: 12)
                
                Text(githubInfo)
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer(minLength: 12)
                
                Text(emailInfo)
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer(minLength: 12)
                
                Text(updates)
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
            }
        }
        
    }
}
