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
        let logFileURL = documentsDirectory.appendingPathComponent("Subject").appendingPathExtension("json")
        
        // Parse links.
        guard let links = DocumentLinks(from: pdfFileURL)
        else { return }
        
        // Write log.
        links.write(to: logFileURL)
        
        // Load PDF.
        guard let pdfDocument = PDFDocument(url: pdfFileURL)
        else { return }
        
        // Add annotations if any.
        for (eachPageIndex, eachPageLinks) in links.pageLinks.enumerated()
        {
            if let eachPage = pdfDocument.page(at: eachPageIndex)
            {
                eachPageLinks.links.forEach
                { eachLink in eachPage.addAnnotation(eachLink.annotation) }
            }
        }
        
        // Write.
        pdfDocument.write(toFile: pdfFileURL.path)
    }
}

