//
//  PDFAnnotation+Extensions.swift
//  PDFLinks
//
//  Created by Geri Borbás on 2020. 02. 11..
//  Copyright © 2020. Geri Borbás. All rights reserved.
//

import Foundation
import PDFKit


extension PDFAnnotation
{
    
    
    func with(url: URL?) -> PDFAnnotation
    {
        self.url = url
        return self
    }
}
