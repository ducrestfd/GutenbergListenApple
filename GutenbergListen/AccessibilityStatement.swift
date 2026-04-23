//
//  AccessibilityStatement.swift
//  GutenbergListen
//
//  Created by ducrestfd on 3/6/26.
//

import SwiftUI

struct AccessibilityStatement: View {
    let myHTML = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta http-equiv="content-type" content="text/html; charset=utf-8"/>
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title></title>
            <meta name="generator" content="LibreOffice 25.8.4.2 (MacOSX)"/>
            <meta name="created" content="2026-02-05T10:14:38.880620000"/>
            <meta name="changed" content="2026-03-06T10:45:02.138525000"/>
            <style type="text/css">
                @page { size: 8.5in 11in; margin: 0.79in }
                p { margin-bottom: 0.1in; line-height: 115%; background: transparent }
                h2 { margin-top: 0.14in; margin-bottom: 0.08in; background: transparent; page-break-after: avoid }
                h2.western { font-family: "Liberation Serif", serif; font-weight: bold; font-size: 18pt }
                h2.cjk { font-family: "Noto Serif CJK SC"; font-size: 18pt; font-weight: bold }
                h2.ctl { font-family: "FreeSans"; font-weight: bold; font-size: 18pt }
                h3 { margin-top: 0.1in; margin-bottom: 0.08in; background: transparent; page-break-after: avoid }
                h3.western { font-family: "Liberation Serif", serif; font-weight: bold; font-size: 14pt }
                h3.cjk { font-family: "Noto Serif CJK SC"; font-size: 14pt; font-weight: bold }
                h3.ctl { font-family: "FreeSans"; font-weight: bold; font-size: 14pt }
            </style>
        </head>
        <body lang="en-US" link="#000080" vlink="#800000" dir="ltr"><h2 class="western" style="line-height: 114%; margin-top: 0in; margin-bottom: 0.1in">
        <font face="Google Sans, sans-serif">Accessibility Statement:
        Gutenberg Listen</font></h2>
        <h3 class="western" style="line-height: 114%; margin-top: 0in; margin-bottom: 0.1in">
        <font face="Google Sans, sans-serif">Our Commitment</font></h3>
        <p style="line-height: 114%"><font face="Google Sans Text, sans-serif"><b>Gutenberg
        Web Access</b> was built with the belief that the world’s greatest
        literature should be accessible to everyone, regardless of visual
        ability. We prioritize a &quot;function-first&quot; design that
        removes the visual noise of the modern web to provide a clean,
        reliable experience for the blind and low-vision community or anyone
        who uses a screen reader.</font></p>
        <h3 class="western" style="line-height: 114%; margin-top: 0in; margin-bottom: 0.1in">
        <font face="Google Sans, sans-serif">Key Accessibility Features</font></h3>
        <ul>
            <li><p style="line-height: 114%; border: none; padding: 0in"><font face="Google Sans Text, sans-serif"><b>VoiceOver
            Optimization:</b> Every element, button, and image in this app is
            labeled with descriptive accessibility traits. Navigation follows a
            logical, predictable flow intended for screen reader users.</font></p></li>
            <li><p style="line-height: 114%; border: none; padding: 0in"><font face="Google Sans Text, sans-serif"><b>Text-to-Speech
            (TTS) Integration:</b> For text-based eBooks, we utilize a
            specialized speech engine that allows for fine-grained control,
            including adjustable playback speed and skipping ahead by number of
            sentences.</font></p></li>
            <li><p style="line-height: 114%; border: none; padding: 0in"><font face="Google Sans Text, sans-serif"><b>High
            Contrast &amp; Large Text: </b>The interface utilizes high-contrast
            color ratios and supports <b>Dynamic Type</b>, allowing the app’s
            layout to scale gracefully with your system-wide font size settings.</font></p></li>
            <li><p style="line-height: 114%; border: none; padding: 0in"><font face="Google Sans Text, sans-serif"><b>Simplified
            Audio Controls: </b>Our audiobook player uses large, easy-to-target
            touch zones and standard media commands for a seamless listening
            experience.</font></p></li>
        </ul>
        <h3 class="western" style="line-height: 114%; margin-top: 0in; margin-bottom: 0.1in">
        <font face="Google Sans, sans-serif">Technical Standards</font></h3>
        <p style="line-height: 114%"><font face="Google Sans Text, sans-serif">We
        aim to follow the <b>Web Content Accessibility Guidelines (WCAG) 2.2</b>
        at the AA level as our baseline for mobile interface design. We
        regularly test the app using native iOS assistive technologies to
        ensure a &quot;no-barrier&quot; experience.</font></p>
        <h3 class="western" style="line-height: 114%; margin-top: 0in; margin-bottom: 0.1in">
        <font face="Google Sans, sans-serif">Feedback &amp; Support</font></h3>
        <p style="line-height: 114%"><font face="Google Sans Text, sans-serif">Accessibility
        is an ongoing journey. If you encounter a button that isn't labeled
        correctly, a menu that is difficult to navigate, or if you have
        suggestions for improvement, please contact us:</font></p>
        <ul>
            <li><p style="line-height: 114%; border: none; padding: 0in"><font face="Google Sans Text, sans-serif"><b>Email:</b>
            ducrestfd@gmail.com</font></p></li>
        </ul>
        <hr/>

        </body>
        </html>
        """
    
    var body: some View {
        HTMLView(htmlString: myHTML)
            //.frame(height: 300)
            .cornerRadius(10)
            .padding()
    }
}
