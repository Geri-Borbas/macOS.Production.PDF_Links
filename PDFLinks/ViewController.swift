//
//  ViewController.swift
//  PDFLinks
//
//  Created by Geri Borbás on 2020. 02. 05..
//  Copyright © 2020. Geri Borbás. All rights reserved.
//

import Cocoa
import PDFKit


class ViewController: NSViewController, DragViewDelegate
{

    
    // UI.
    @IBOutlet weak var statusLabel: NSTextField!
    
   
    func dragViewDidReceive(fileURLs: [URL])
    {
        if let firstPdfFileURL = fileURLs.first
        { processPDF(pdfFileURL: firstPdfFileURL) }
    }

    func processPDF(pdfFileURL: URL)
    {        
        // Resolve Documents directory.
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        else { return }
        
        // Assemble file names.
        let fileName = pdfFileURL.deletingPathExtension().lastPathComponent
        let outputPdfFileURL = documentsDirectory
            .appendingPathComponent(fileName.appending(" (with links)"))
            .appendingPathExtension(pdfFileURL.pathExtension)
        let logJsonFileURL = documentsDirectory
            .appendingPathComponent(fileName.appending(" (log)"))
            .appendingPathExtension("json")
        
        // Parse links.
        guard let links = DocumentLinks(from: pdfFileURL)
        else { return }
        
        // Write log.
        links.write(to: logJsonFileURL)
        
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
        pdfDocument.write(toFile: outputPdfFileURL.path)
        
        // Pop up folder.
        NSWorkspace.shared.activateFileViewerSelecting([outputPdfFileURL, logJsonFileURL])
    }
}
