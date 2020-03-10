//
//  Options.swift
//  PDF Links
//
//  Created by Geri Borbás on 2020. 03. 10..
//  Copyright © 2020. Geri Borbás. All rights reserved.
//

import Foundation


struct Options: Codable
{
    
    
    let append: [Append]
    
    
    struct Append: Codable
    {
        
        
        let suffix: String
        let toLinksPrefixed: String
    }
}


extension String
{
    
    
    func applying(options: Options?) -> String
    {
        // Checks.
        guard let options = options
        else { return self }
        
        // Mutable copy.
        var applied = self
        
        // Apply each append.
        options.append.forEach
        {
            eachAppend in
            
            if self.hasPrefix(eachAppend.toLinksPrefixed)
            { applied.append(eachAppend.suffix) }
        }
        
        // Return.
        return applied
    }
}
