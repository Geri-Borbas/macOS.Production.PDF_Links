//
//  Link.swift
//  PDFLinks
//
//  Created by Geri Borbás on 2020. 02. 11..
//  Copyright © 2020. Geri Borbás. All rights reserved.
//

import Foundation
import PDFKit


struct Link: Codable
{
    
    
    let bounds: Rectangle
    let text: String
    
    
    struct Rectangle: Codable
    {
        
        
        let x: Double
        let y: Double
        let width: Double
        let height: Double
    }
}


extension Link
{
    
    
    var url: URL? { URL(string: "http://eppz.eu") }
    
    var annotation: PDFAnnotation
    {
        PDFAnnotation(
            bounds: CGRect(x: bounds.x, y: bounds.y, width: bounds.width, height: bounds.height),
            forType: PDFAnnotationSubtype.link,
            withProperties: nil
        ).with(url: url)
    }
}

