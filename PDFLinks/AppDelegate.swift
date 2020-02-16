//
//  AppDelegate.swift
//  PDFLinks
//
//  Created by Geri Borbás on 2020. 02. 05..
//  Copyright © 2020. Geri Borbás. All rights reserved.
//

import Cocoa


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate
{
    
    
    @IBAction func helpClicked(_ sender: Any?)
    {
        if let url = URL(string: "https://github.com/eppz/macOS.Production.PDF_Links")
        { NSWorkspace.shared.open(url) }
    }
}

