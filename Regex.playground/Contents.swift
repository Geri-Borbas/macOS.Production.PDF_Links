import UIKit
import Foundation


// MARK: - Extensions

extension String
{
    
    var entireRange: NSRange
    { NSRange(location: 0, length: self.utf16.count) }
    
    func substring(with range: NSRange) -> String
    {
        let rangeStartIndex = self.index(self.startIndex, offsetBy: range.location)
        let rangeEndIndex = self.index(rangeStartIndex, offsetBy: range.length)
        let indexRange = rangeStartIndex..<rangeEndIndex
        return String(self[indexRange])
    }
    
    func write(to fileName: String) throws
    {
        guard let documentsFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        try self.write(
            to: documentsFolder.appendingPathComponent(fileName),
            atomically: false,
            encoding: .utf8
        )
        print("`\(self.prefix(20))...` written to \(documentsFolder.appendingPathComponent(fileName)).")
    }
}


// MARK: - Strings

struct Constants
{
    
    
    static let originalHtmlFileName = "Original.html"
    static let replacedHtmlFileName = "Replaced.html"
    
    static let bodyTemplate = "%BODY%"
    
    static let htmlTemplate = """
    <html>
    <head>
    <style type="text/css">
    body { color: LightGray; }
    .match { color: black; background-color: PaleTurquoise; }
    .group { color: black; border-top: 1px solid black; border-right: 2px solid black; }
    .group._9 { background: #66afe3; }
    .group._8 { background-color: #66c0ec; }
    .group._7 { background-color: #66d2f6; }
    .group._6 { background-color: #66e1fd; }
    .group._5 { background-color: #66ebff; }
    .group._4 { background-color: #66f2e7; }
    .group._3 { background-color: #66e5c2; }
    .group._2 { background-color: #66daa6; }
    .group._1 { background: #66d28c; }
    </style>
    </head>
    <body>
    <pre>
    \(Constants.bodyTemplate)
    </pre>
    </body>
    </html>
    """
    
    // See https://developer.apple.com/documentation/foundation/nsregularexpression#1965591
    static let replacementTemplate =
        "<span class=\"group _1\">$1</span>" +
        "<span class=\"group _2\">$2</span>" +
        "<span class=\"group _3\">$3</span>" +
        "<span class=\"group _4\">$4</span>" +
        "<span class=\"group _5\">$5</span>" +
        "<span class=\"group _6\">$6</span>" +
        "<span class=\"group _7\">$7</span>" +
        "<span class=\"group _8\">$8</span>" +
        "<span class=\"group _9\">$9</span>"
}


// MARK: - Implementation

// Extract link texts with clipping rectangles.
let pattern =
    """

    # Clipping Rectangle
    (?<ClippingRectange>[0-9].[^\\n]+\\sre\\nW)

    (.+?)

    (BT.+?ET)

    """

let regex = try NSRegularExpression(
    pattern: pattern,
    options: [
        .dotMatchesLineSeparators,
        .allowCommentsAndWhitespace,
        .anchorsMatchLines
    ])

// PDF Contents.
let contents = "/Layer /MC0 BDC\nq\n0 841.89 595.276 -841.89 re\nW n\n1 0 1 0 k\n/GS0 gs\nq 1 0 0 1 201.8862 420.9449 cm\n0 0 m\n0 52.882 42.87 95.751 95.751 95.751 c\n148.633 95.751 191.503 52.882 191.503 0 c\n191.503 -52.882 148.633 -95.751 95.751 -95.751 c\n42.87 -95.751 0 -52.882 0 0 c\nfz\nQ\nEMC\n/Layer /MC1 BDC\nQ\nq\n0 841.89 595.276 -841.89 re\nW n\n0 0.35 0.85 0 k\n/GS0 gs\nq 1 0 0 1 201.8862 274.9611 cm\n0 0 m\n0 52.882 42.87 95.751 95.751 95.751 c\n148.633 95.751 191.503 52.882 191.503 0 c\n191.503 -52.883 148.633 -95.752 95.751 -95.752 c\n42.87 -95.752 0 -52.883 0 0 c\nf\nQ\nEMC\n/Layer /MC2 BDC\nQ\nq\n362.32 400.184 79.189 11.118 re\nW n\nq\n/GS1 gs\n0 TL/Fm0 Dojjjghjsjkayr426635y\nQ\nBT\n0 0 0 0 k\n/GS0 gs\n/TT0 1 Tf\n10.0006 0 0 10.0006 362.3203 402.9292 Tm\n(Link)Tj\n/TT1 1 Tf\n[( http://twitter)55.2 (.com/_eppz)]TJ\nET\nQ\nq\n73.38 560.682 328.535 116.633 re\nW n\nq\n/GS1 gs\n0 TL/Fm1 Do\nQ\nBT\n0 0 0 0 k\n/GS0 gs\n/TT0 1 Tf\n10.0006 0 0 10.0006 73.3799 668.9429 Tm\n(Link)Tj\n/TT1 1 Tf\n[( http://twitter)55.2 (.com/_eppz)]Tj\nET\nEMC\nQ"

// Match.
let matches = regex.matches(in: contents, options: [], range: contents.entireRange)

// Enumerate matches.
for (eachMatchIndex, eachMatch) in matches.enumerated()
{
    print("Match (\(eachMatchIndex))")
    
    // Enumerate groups.
    (0...eachMatch.numberOfRanges - 1).forEach
    {
        eachGroupIndex in
   
        let eachGroupRange = eachMatch.range(at: eachGroupIndex)
        if let eachRangeBounds = Range(eachGroupRange, in: contents)
        {
            print(
                String(
                    format: "Group %d %@: `%@`",
                    eachGroupIndex,
                    eachGroupRange.description,
                    String(contents.substring(with: eachRangeBounds).prefix(20))
                )
            )
        }
    }
}

// Replace matches.
let body = regex.stringByReplacingMatches(in: contents, options: [], range: contents.entireRange, withTemplate: Constants.replacementTemplate)

// Insert into template.
let originalHtml = Constants.htmlTemplate.replacingOccurrences(of: Constants.bodyTemplate, with: contents)
let replacedHtml = Constants.htmlTemplate.replacingOccurrences(of: Constants.bodyTemplate, with: body)

// Write.
try! originalHtml.write(to: Constants.originalHtmlFileName)
try! replacedHtml.write(to: Constants.replacedHtmlFileName)


    
