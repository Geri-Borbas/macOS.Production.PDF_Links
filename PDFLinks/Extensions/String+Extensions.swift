//
//  String+Extensions.swift
//  PDFLinks
//
//  Created by Geri Borbás on 2020. 02. 11..
//  Copyright © 2020. Geri Borbás. All rights reserved.
//

import Foundation


extension String
{
     
    
    var entireRange: NSRange
    { NSRange(location: 0, length: self.utf16.count) }
    
    func slice(with range: NSRange) -> String
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
    
    var utf8CStringPointer: UnsafeMutablePointer<Int8>
    {
        let count = self.utf8.count + 1
        let bytes = UnsafeMutablePointer<Int8>.allocate(capacity: count)
        self.withCString
        {
            baseAddress in
            bytes.initialize(from: baseAddress, count: count)
        }
        return bytes
    }
}
