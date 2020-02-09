import UIKit
import Foundation


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
}

extension NSTextCheckingResult.CheckingType: Hashable
{
    
    
    public func hash(into hasher: inout Hasher)
    { hasher.combine(self.rawValue) }
}


// Extract link texts with clipping rectangles.
let pattern =
    """

    # Clipping Rectangle
    (([0-9].+)(?=(\\s)re(\\n)
    W))
    
    """

let regex = try NSRegularExpression(
    pattern: pattern,
    options: [
        // .dotMatchesLineSeparators,
        .allowCommentsAndWhitespace,
        .anchorsMatchLines
    ])

// PDF Contents.
let contents = "/Layer /MC0 BDC\nq\n0 841.89 595.276 -841.89 re\nW n\n1 0 1 0 k\n/GS0 gs\nq 1 0 0 1 201.8862 420.9449 cm\n0 0 m\n0 52.882 42.87 95.751 95.751 95.751 c\n148.633 95.751 191.503 52.882 191.503 0 c\n191.503 -52.882 148.633 -95.751 95.751 -95.751 c\n42.87 -95.751 0 -52.882 0 0 c\nfz\nQ\nEMC\n/Layer /MC1 BDC\nQ\nq\n0 841.89 595.276 -841.89 re\nW n\n0 0.35 0.85 0 k\n/GS0 gs\nq 1 0 0 1 201.8862 274.9611 cm\n0 0 m\n0 52.882 42.87 95.751 95.751 95.751 c\n148.633 95.751 191.503 52.882 191.503 0 c\n191.503 -52.883 148.633 -95.752 95.751 -95.752 c\n42.87 -95.752 0 -52.883 0 0 c\nf\nQ\nEMC\n/Layer /MC2 BDC\nQ\nq\n362.32 400.184 79.189 11.118 re\nW n\nq\n/GS1 gs\n0 TL/Fm0 Dojjjghjsjkayr426635y\nQ\nBT\n0 0 0 0 k\n/GS0 gs\n/TT0 1 Tf\n10.0006 0 0 10.0006 362.3203 402.9292 Tm\n(Link)Tj\n/TT1 1 Tf\n[( http://twitter)55.2 (.com/_eppz)]TJ\nET\nQ\nq\n73.38 560.682 328.535 116.633 re\nW n\nq\n/GS1 gs\n0 TL/Fm1 Do\nQ\nBT\n0 0 0 0 k\n/GS0 gs\n/TT0 1 Tf\n10.0006 0 0 10.0006 73.3799 668.9429 Tm\n(Link)Tj\n/TT1 1 Tf\n[( http://twitter)55.2 (.com/_eppz)]Tj\nET\nEMC\nQ"

let bodyTemplate = "%BODY%"

let htmlTemplate = """
<html>
<head>
<style type="text/css">
body { color: LightGray; }
.match { color: black; background-color: PaleTurquoise; }
</style>
</head>
<body>
<pre>
\(bodyTemplate)
</pre>
</body>
</html>
"""

// See https://developer.apple.com/documentation/foundation/nsregularexpression#1965591
let replacementTemplate = "<span class=\"match\">$0</span>"

// Match.
let matches = regex.matches(in: contents, options: [], range: contents.entireRange)

// Enumerate.
matches.forEach
{
    (eachMatch: NSTextCheckingResult) in
    if let eachRange = Range(eachMatch.range, in: contents)
    {
        print(
            String(
                format: "%@: `%@`",
                eachMatch.range.description,
                contents.substring(with: eachMatch.range)
            )
        )
    }
}

// Replace matches.
let body = regex.stringByReplacingMatches(in: contents, options: [], range: contents.entireRange, withTemplate: replacementTemplate)

// Insert into template.
let html = htmlTemplate.replacingOccurrences(of: bodyTemplate, with: body)

// Write.
try! write(html, to: "contents.html")

func write(_ string: String, to fileName: String) throws
{
    guard let documentsFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
    // print(documentsFolder)
    try string.write(
        to: documentsFolder.appendingPathComponent(fileName),
        atomically: false,
        encoding: .utf8
    )
}
