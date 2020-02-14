//
//  PageLinks.swift
//  PDFLinks
//
//  Created by Geri Borbás on 2020. 02. 11..
//  Copyright © 2020. Geri Borbás. All rights reserved.
//

import Foundation


struct PageLinks: Codable
{
    
    
    let links: [Link]
    let contents: String
}


extension PageLinks
{
    
    
    /// Parse any links from the root `Content` stream of the page.
    /// Note that if PDF file is altered, objects moved outside
    /// from the root `Content` stream won't be parsed.
    init?(from pageRef: CGPDFPage?)
    {
        // Get content.
        guard let contents = PageLinks.contents(from: pageRef)
        else { return nil }
        
        // Set (for debug).
        self.contents = contents
        
        // Parse links.
        guard let links = try? PageLinks.parseLinks(from: contents)
        else { return nil }
        
        // Set.
        self.links = links
    }
    
    static func contents(from pageRef: CGPDFPage?) -> String?
    {
        guard let pageRef = pageRef
        else { return nil }
        
        // Get content stream.
        var contentsDataString: String? = nil
        var streamRefOrNil: CGPDFStreamRef? = nil
        if
            let pageDictionaryRef = pageRef.dictionary,
            CGPDFDictionaryGetStream(pageDictionaryRef, "Contents".utf8CStringPointer, &streamRefOrNil),
            let streamRef = streamRefOrNil
        {
            // Get data.
            var streamDataFormat: CGPDFDataFormat = .raw
            if let streamData: CFData = CGPDFStreamCopyData(streamRef, &streamDataFormat)
            {
                switch streamDataFormat
                {
                    case .raw: contentsDataString = String(data: NSData(data: streamData as Data) as Data, encoding: String.Encoding.utf8)
                    case .jpegEncoded, .JPEG2000: print("JPEG data found in page `Contents`.")
                    @unknown default: print("Unknown data found in page `Contents`.")
                }
            }
        }
        
        return contentsDataString
    }
}


extension PageLinks
{
    
    
    static func parseLinks(from contents: String) throws -> [Link]
    {
        // Extract link texts with clipping rectangles.
        // See https://regex101.com/r/jS8XMl/16
        let pattern =
            """

            # Clipping Rectangle (x, y, width, height)
            (?<x>\\b[-0-9.]+\\b)\\s
            (?<y>\\b[-0-9.]+\\b)\\s
            (?<width>\\b[-0-9.]+\\b)\\s
            (?<height>\\b[-0-9.]+\\b)\\s
            re\\nW

            # Spacing
            (?:
                .   # Any character
                (?! # Except followed by
                    # Clipping Rectangle
                    (\\b[-\\d.]+\\b\\s){4}
                    re\\nW
                )
            )*? # 0 or more times

            # Link
            BT
                # Spacing
                (?:
                    .      # Any character
                    (?!ET) # Except followed by 'ET'
                )*?        # 0 or more times
            \\n
                # Link
                (?<link>
                    .[^\\n]*? # Any character except new-line 0 or more times
                    Link      # Containing 'Link'
                    .*?       # Any character 0 or more times
                )
                # Followed by 'TJ' or 'Tj' at the end of the line
                (?:TJ\\n|Tj\\n)
            ET

            """

        let regex = try NSRegularExpression(
            pattern: pattern,
            options: [
                .dotMatchesLineSeparators,
                .allowCommentsAndWhitespace
            ])
        
        // Match.
        let matches = regex.matches(in: contents, options: [], range: contents.entireRange)

        // Enumerate matches.
        var links: [Link] = []
        for (eachMatchIndex, eachMatch) in matches.enumerated()
        {
            // Get values from match.
            if
                let x = Double(contents.slice(with: eachMatch.range(withName: "x"))),
                let y = Double(contents.slice(with: eachMatch.range(withName: "y"))),
                let width = Double(contents.slice(with: eachMatch.range(withName: "width"))),
                let height = Double(contents.slice(with: eachMatch.range(withName: "height")))
            {
                // Create and collect link.
                links.append(
                    Link(
                        bounds: Link.Rectangle(
                            x: x,
                            y: y,
                            width: width,
                            height: height
                        ),
                        text: contents.slice(with: eachMatch.range(withName: "link"))
                    )
                )
            }
        }
        
        return links
    }
}
