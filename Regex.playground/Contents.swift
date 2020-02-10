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
    .group._9, .group._19 { background: #66afe3; }
    .group._8, .group._18 { background: #66c0ec; }
    .group._7, .group._17 { background: #66d2f6; }
    .group._6, .group._16 { background: #66e1fd; }
    .group._5, .group._15 { background: #66ebff; }
    .group._4, .group._14 { background: #66f2e7; }
    .group._3, .group._13 { background: #66e5c2; }
    .group._2, .group._12 { background: #66daa6; }
    .group._1, .group._11 { background: #66d28c; }
    .group._10 { background: LightGray; }
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
        "<span class=\"group _9\">$9</span>" +
        "<span class=\"group _10\">$10</span>" +
        "<span class=\"group _11\">$11</span>" +
        "<span class=\"group _12\">$12</span>" +
        "<span class=\"group _13\">$13</span>" +
        "<span class=\"group _14\">$14</span>" +
        "<span class=\"group _15\">$15</span>" +
        "<span class=\"group _16\">$16</span>" +
        "<span class=\"group _17\">$17</span>" +
        "<span class=\"group _18\">$18</span>"
}


// MARK: - Implementation

// Extract link texts with clipping rectangles.
let pattern_readable =
    """

    # Clipping Rectangle (x, y, width, height)
    (?<x>\\b[-0-9\\.]+\\b)(\\s)
    (?<y>\\b[-0-9\\.]+\\b)(\\s)
    (?<width>\\b[-0-9\\.]+\\b)(\\s)
    (?<height>\\b[-0-9\\.]+\\b)(\\s)
    (re\\nW)

    (.*?)

    # Link Text (text)
    (BT)
    (.*?)
    (Link)
    (.*?\\n)
    (?<text>.[^\\n]*?)(TJ\\n|Tj\\n)
    (ET)

    """

let pattern = "(\\b[-0-9\\.]+\\b)(\\s)(\\b[-0-9\\.]+\\b)(\\s)(\\b[-0-9\\.]+\\b)(\\s)(\\b[-0-9\\.]+\\b)(\\s)(re\\nW)(.*?)(BT)(.*?)(Link)(.*?\\n)(.[^\\n]*?)(TJ\\n|Tj\\n)(ET)"

let regex = try NSRegularExpression(
    pattern: pattern_readable,
    options: [
        .dotMatchesLineSeparators,
        .allowCommentsAndWhitespace
    ])

// PDF Contents.
let contents = "/Layer /MC0 BDC\nq\n0 841.89 595.276 -841.89 re\nW n\n1 0 1 0 k\n/GS0 gs\nq 1 0 0 1 201.8862 420.9449 cm\n0 0 m\n0 52.882 42.87 95.751 95.751 95.751 c\n148.633 95.751 191.503 52.882 191.503 0 c\n191.503 -52.882 148.633 -95.751 95.751 -95.751 c\n42.87 -95.751 0 -52.882 0 0 c\nfz\nQ\nEMC\n/Layer /MC1 BDC\nQ\nq\n0 841.89 595.276 -841.89 re\nW n\n0 0.35 0.85 0 k\n/GS0 gs\nq 1 0 0 1 201.8862 274.9611 cm\n0 0 m\n0 52.882 42.87 95.751 95.751 95.751 c\n148.633 95.751 191.503 52.882 191.503 0 c\n191.503 -52.883 148.633 -95.752 95.751 -95.752 c\n42.87 -95.752 0 -52.883 0 0 c\nf\nQ\nEMC\n/Layer /MC2 BDC\nQ\nq\n362.32 400.184 79.189 11.118 re\nW n\nq\n/GS1 gs\n0 TL/Fm0 Dojjjghjsjkayr426635y\nQ\nBT\n0 0 0 0 k\n/GS0 gs\n/TT0 1 Tf\n10.0006 0 0 10.0006 362.3203 402.9292 Tm\n(Link)Tj\n/TT1 1 Tf\n[( http://twitter)55.2 (.com/_eppz)]TJ\nET\nQ\nq\n73.38 560.682 328.535 116.633 re\nW n\nq\n/GS1 gs\n0 TL/Fm1 Do\nQ\nBT\n0 0 0 0 k\n/GS0 gs\n/TT0 1 Tf\n10.0006 0 0 10.0006 73.3799 668.9429 Tm\n(Link)Tj\n/TT1 1 Tf\n[( http://twitter)55.2 (.com/_eppz)]Tj\nET\nEMC\nQ"

// Match.
let matches = regex.matches(in: contents, options: [], range: contents.entireRange)

// Enumerate matches.
for (eachMatchIndex, eachMatch) in matches.enumerated()
{
    print("Match (\(eachMatchIndex))")
    
    // Log groups.
    (0...eachMatch.numberOfRanges - 1).forEach
    {
        eachGroupIndex in
        logGroupRange(eachMatch.range(at: eachGroupIndex), as: "\(eachGroupIndex)", in: contents)
    }
    
    // Log named groups.
    logGroupRange(eachMatch.range(withName: "x"), as: "x", in: contents)
    logGroupRange(eachMatch.range(withName: "y"), as: "y", in: contents)
    logGroupRange(eachMatch.range(withName: "width"), as: "width", in: contents)
    logGroupRange(eachMatch.range(withName: "height"), as: "height", in: contents)
    logGroupRange(eachMatch.range(withName: "text"), as: "text", in: contents)
}

func logGroupRange(_ eachGroupRange: NSRange, as name: String, in string: String)
{
    if let eachRangeBounds = Range(eachGroupRange, in: string)
    {
        print(
            String(
                format: "Group %@ %@: `%@`",
                name,
                eachGroupRange.description,
                String(string.substring(with: eachRangeBounds).prefix(40))
            )
        )
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


    
