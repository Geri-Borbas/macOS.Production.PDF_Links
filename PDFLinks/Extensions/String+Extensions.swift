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
