//
//  PDFParser.swift
//  PDFParser
//
//  Created by Geri Borbás on 2020. 02. 05.
//  Copyright © 2020. Geri Borbás. All rights reserved.
//

import Foundation
import PDFKit


class PDFParser
{

    
    /// Undocumented enumeration case stands for `Object` type (sourced from an expection thrown).
    static let CGPDFObjectTypeObject: CGPDFObjectType = CGPDFObjectType(rawValue: 77696)!
           
    
    static func parse(url: URL, into jsonURL: URL)
    {
        // Document.
        guard
            let document = CGPDFDocument(url as CFURL),
            let catalog = document.catalog,
            let info = document.info
        else { return print("Cannot open PDF.") }
        
        // Parse.
        let pdf = [
            "Catalog" : PDFParser.value(from: catalog),
            "Info" : PDFParser.value(from: info)
        ]
        
        // Write JSON.
        do
        {
            let data = try JSONSerialization.data(withJSONObject: pdf, options: .prettyPrinted)
            try data.write(to: jsonURL, options: [])
        }
        catch
        { print(error) }
    }
    
    static func value(from object: CGPDFObjectRef) -> NSObject
    {
        switch (CGPDFObjectGetType(object))
        {
            case .null:
                
                return NSNull()
            
            case .boolean:

                var valueRef: CGPDFBoolean = 0
                if CGPDFObjectGetValue(object, .boolean, &valueRef)
                { return NSNumber(value: valueRef) }
            
            case .integer:
            
                var valueRef: CGPDFInteger = 0
                if CGPDFObjectGetValue(object, .integer, &valueRef)
                { return NSNumber(value: valueRef) }
                
            case .real:
            
                var valueRef: CGPDFReal = 0.0
                if CGPDFObjectGetValue(object, .real, &valueRef)
                { return NSNumber(value: Double(valueRef as CGFloat)) }
            
            case .name:
                
                var objectRefOrNil: UnsafePointer<Int8>? = nil
                if
                    CGPDFObjectGetValue(object, .name, &objectRefOrNil),
                    let objectRef = objectRefOrNil,
                    let string = NSString(cString: objectRef, encoding: String.Encoding.isoLatin1.rawValue)
                { return string }
            
            case .string:
                    
                var objectRefOrNil: UnsafePointer<Int8>? = nil
                if
                    CGPDFObjectGetValue(object, .string, &objectRefOrNil),
                    let objectRef = objectRefOrNil,
                    let string = CGPDFStringCopyTextString(OpaquePointer(objectRef))
                { return string }
            
            case .array:
                
                var arrayRefOrNil: CGPDFArrayRef? = nil
                if
                    CGPDFObjectGetValue(object, .array, &arrayRefOrNil),
                    let arrayRef = arrayRefOrNil
                {
                    let array: NSMutableArray = NSMutableArray()
                    
                    for index in 0 ..< CGPDFArrayGetCount(arrayRef)
                    {
                        var eachObjectRef: CGPDFObjectRef? = nil
                        if
                            CGPDFArrayGetObject(arrayRef, index, &eachObjectRef),
                            let eachObject = eachObjectRef
                        {
                            let eachValue = PDFParser.value(from: eachObject)
                            array.add(eachValue)
                        }
                    }
                    
                    return array
                }
            
            case .stream:
            
                var streamRefOrNil: CGPDFStreamRef? = nil
                if
                    CGPDFObjectGetValue(object, .stream, &streamRefOrNil),
                    let streamRef = streamRefOrNil
                {
                    var format = CGPDFDataFormat.raw
                    if
                        let streamData: CFData = CGPDFStreamCopyData(streamRef, &format),
                        let streamDataString = NSString(data: NSData(data: streamData as Data) as Data, encoding: String.Encoding.utf8.rawValue)
                    { return streamDataString }
                }
                
            case .dictionary:
                    
                var dictionaryRefOrNil: CGPDFDictionaryRef? = nil
                if
                    CGPDFObjectGetValue(object, .dictionary, &dictionaryRefOrNil),
                    let dictionaryRef = dictionaryRefOrNil
                {
                    var dictionary: NSMutableDictionary = NSMutableDictionary()
                    Self.collectObjects(from: dictionaryRef, into: &dictionary)
                    return dictionary
                }
            
            case CGPDFObjectTypeObject:
            
                var dictionary: NSMutableDictionary = NSMutableDictionary()
                Self.collectObjects(from: object, into: &dictionary)
                return dictionary
                        
            @unknown default:
                
                return NSNull()
        }
        
        // No known case.
        return NSNull()
    }
    
    static func collectObjects(from dictionaryRef: CGPDFDictionaryRef, into dictionaryPointer: UnsafeMutableRawPointer?)
    {
        CGPDFDictionaryApplyFunction(
            dictionaryRef,
            {
                (eachKeyPointer, eachObject, eachContextOrNil: UnsafeMutableRawPointer?) -> Void in

                // Unwrap dictionary.
                guard let dictionary = eachContextOrNil?.assumingMemoryBound(to: NSMutableDictionary.self).pointee
                else { return }
                
                // Key.
                guard let eachKey = String(cString: UnsafePointer<CChar>(eachKeyPointer), encoding: .isoLatin1)
                else { return }

                // Value.
                let eachValue = (eachKey == "Parent")
                    ? NSString("<PARENT_NOT_SERIALIZED>")
                    : PDFParser.value(from: eachObject)
                
                // Set.
                dictionary.setObject(
                    eachValue,
                    forKey: eachKey as NSString
                )
            },
            dictionaryPointer
        )
    }
}
