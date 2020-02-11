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
    let content: String
}


extension PageLinks
{
    
    
    /// Parse any links from the root `Content` stream of the page.
    /// Note that if PDF file is altered, objects moved outside
    /// from the root `Content` stream won't be parsed.
    init?(from pageRef: CGPDFPage?)
    {
        // Get content.
        guard let content = PageLinks.content(from: pageRef)
        else { return nil }
        
        // Set (for debug).
        self.content = content
        
        // TODO: Parse (see playground).
        self.links = []
    }
    
    static func content(from pageRef: CGPDFPage?) -> String?
    {
        guard let pageRef = pageRef
        else { return nil }
        
        // Get content stream.
        var contentDataString: String? = nil
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
                    case .raw: contentDataString = String(data: NSData(data: streamData as Data) as Data, encoding: String.Encoding.utf8)
                    case .jpegEncoded, .JPEG2000: print("JPEG data found in page `Contents`.")
                    @unknown default: print("Unknown data found in page `Contents`.")
                }
            }
        }
        
        return contentDataString
    }
}
