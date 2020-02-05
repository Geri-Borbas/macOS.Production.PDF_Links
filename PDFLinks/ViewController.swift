//
//  ViewController.swift
//  PDFLinks
//
//  Created by Geri Borbás on 2020. 02. 05..
//  Copyright © 2020. Geri Borbás. All rights reserved.
//

import Cocoa
import PDFKit


class ViewController: NSViewController
{

    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        processPDF()
    }

    func processPDF()
    {
        // Resolve Documents directory.
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        else { return }
        
        // Assemble file name.
        let pdfFileURL = documentsDirectory.appendingPathComponent("Subject").appendingPathExtension("pdf")
        let jsonFileURL = documentsDirectory.appendingPathComponent("Subject").appendingPathExtension("json")
     
        // Load.
        guard let pdfDocument = PDFDocument(url: pdfFileURL)
        else { return }

        // Parse PDF into JSON.
        PDFParser.parse(pdfUrl: pdfFileURL, into: jsonFileURL)
                
        // Write.
        pdfDocument.write(toFile: pdfFileURL.path)
    }
    
    func listAnnotations(page: PDFPage?)
    {
        // Checks.
        guard let page = page else { return }
        
        page.annotations.forEach
        {
            eachAnnotation in
            print(eachAnnotation)
        }
    }
    
    func addTestAnnotationToPage(page: PDFPage?)
    {
        // Checks.
        guard let page = page else { return }
        
        let squareAnnotation = PDFAnnotation(
            bounds: CGRect(x: 200, y: 100, width: 100, height: 100),
            forType: PDFAnnotationSubtype.square,
            withProperties: nil
        )
        squareAnnotation.color = NSColor.blue
        page.addAnnotation(squareAnnotation)
    }
}

