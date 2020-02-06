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
           
    /// Shorthand for type strings.
    static let namesForTypes: [CGPDFObjectType:String] =
    [
        .null : "Null",
        .boolean : "Boolean",
        .integer : "Integer",
        .real : "Real",
        .name : "Name",
        .string : "String",
        .array : "Array",
        .dictionary : "Dictionary",
        .stream : "Stream",
        CGPDFObjectTypeObject : "Object",
    ]
    
    struct Message
    {
        static let couldNotSerializeData = "<COULD_NOT_SERIALIZE_DATA>"
    }
    
    /// Parse a PDF file into a JSON file.
    static func parse(pdfUrl: URL, into jsonURL: URL)
    {
        do
        {
            let pdf = PDFParser.parse(pdfUrl: pdfUrl)
            let data = try JSONSerialization.data(withJSONObject: pdf, options: .prettyPrinted)
            try data.write(to: jsonURL, options: [])
        }
        catch
        { print(error) }
    }
    
    /// Parse a PDF file into a JSON file.
    static func parse(pdfUrl: URL) -> [String:Any?]
    {
        // Document.
        guard
            let document = CGPDFDocument(pdfUrl as CFURL),
            let catalog = document.catalog,
            let info = document.info
            else
        {
            print("Cannot open PDF.")
            return [:]
        }
        
        // Parse.
        return [
            "Catalog" : PDFParser.value(from: catalog),
            "Info" : PDFParser.value(from: info)
        ]
    }
    
    static func value(from object: CGPDFObjectRef) -> Any?
    {
        switch (CGPDFObjectGetType(object))
        {
            case .null:
                
                return nil
            
            case .boolean:

                var valueRef: CGPDFBoolean = 0
                if CGPDFObjectGetValue(object, .boolean, &valueRef)
                { return Bool(valueRef == 0x01) }
            
            case .integer:
            
                var valueRef: CGPDFInteger = 0
                if CGPDFObjectGetValue(object, .integer, &valueRef)
                { return valueRef as Int }
                
            case .real:
            
                var valueRef: CGPDFReal = 0.0
                if CGPDFObjectGetValue(object, .real, &valueRef)
                { return Double(valueRef) }
            
            case .name:
                
                var objectRefOrNil: UnsafePointer<Int8>? = nil
                if
                    CGPDFObjectGetValue(object, .name, &objectRefOrNil),
                    let objectRef = objectRefOrNil,
                    let string = String(cString: objectRef, encoding: String.Encoding.isoLatin1)
                { return string }
            
            case .string:
                    
                var objectRefOrNil: UnsafePointer<Int8>? = nil
                if
                    CGPDFObjectGetValue(object, .string, &objectRefOrNil),
                    let objectRef = objectRefOrNil,
                    let stringRef = CGPDFStringCopyTextString(OpaquePointer(objectRef))
                { return stringRef as String }
            
            case .array:
                
                var arrayRefOrNil: CGPDFArrayRef? = nil
                if
                    CGPDFObjectGetValue(object, .array, &arrayRefOrNil),
                    let arrayRef = arrayRefOrNil
                {
                    var array: [Any] = []
                    for index in 0 ..< CGPDFArrayGetCount(arrayRef)
                    {
                        var eachObjectRef: CGPDFObjectRef? = nil
                        if
                            CGPDFArrayGetObject(arrayRef, index, &eachObjectRef),
                            let eachObject = eachObjectRef,
                            let eachValue = PDFParser.value(from: eachObject)
                        { array.append(eachValue) }
                    }
                    return array
                }
            
            case .stream:
                
                var streamRefOrNil: CGPDFStreamRef? = nil
                if
                    CGPDFObjectGetValue(object, .stream, &streamRefOrNil),
                    let streamRef = streamRefOrNil,
                    let streamDictionaryRef = CGPDFStreamGetDictionary(streamRef)
                {
                    // Get stream dictionary.
                    var streamNSMutableDictionary = NSMutableDictionary()
                    Self.collectObjects(from: streamDictionaryRef, into: &streamNSMutableDictionary)
                    var streamDictionary = streamNSMutableDictionary as! [String: Any?]
                    
                    // Get data.
                    var dataString: String?
                    var streamDataFormat: CGPDFDataFormat = .raw
                    if let streamData: CFData = CGPDFStreamCopyData(streamRef, &streamDataFormat)
                    {
                        switch streamDataFormat
                        {
                            case .raw: dataString = String(data: NSData(data: streamData as Data) as Data, encoding: String.Encoding.utf8)
                            case .jpegEncoded, .JPEG2000: dataString = NSData(data: streamData as Data).base64EncodedString()
                        }
                    }
                    
                    // Add to dictionary.
                    streamDictionary["Data"] = dataString
                    
                    return streamDictionary
                }
                
            case .dictionary:
                    
                var dictionaryRefOrNil: CGPDFDictionaryRef? = nil
                if
                    CGPDFObjectGetValue(object, .dictionary, &dictionaryRefOrNil),
                    let dictionaryRef = dictionaryRefOrNil
                {
                    var dictionary = NSMutableDictionary()
                    Self.collectObjects(from: dictionaryRef, into: &dictionary)
                    return dictionary as! [String: Any?]
                }
            
            case CGPDFObjectTypeObject:
            
                var dictionary = NSMutableDictionary()
                Self.collectObjects(from: object, into: &dictionary)
                return dictionary as! [String: Any?]
                        
            @unknown default:
                
                return nil
        }
        
        // No known case.
        return nil
    }
    
    static func collectObjects(from dictionaryRef: CGPDFDictionaryRef, into dictionaryPointer: UnsafeMutableRawPointer?)
    {
        
        CGPDFDictionaryApplyFunction(
            dictionaryRef,
            {
                (eachKeyPointer, eachObject, eachContextOrNil: UnsafeMutableRawPointer?) -> Void in

                // Unwrap dictionary.
                guard let dictionary = eachContextOrNil?.assumingMemoryBound(to: NSMutableDictionary.self).pointee
                else { return print("Could not unwrap dictionary.") }
                
                // Unwrap key.
                guard let eachKey = String(cString: UnsafePointer<CChar>(eachKeyPointer), encoding: .isoLatin1)
                else { return print("Could not unwrap key.") }
                
                // Type.
                guard let eachTypeName = PDFParser.namesForTypes[CGPDFObjectGetType(eachObject)]
                else { return print("Could not unwrap type.") }
                
                // Assemble.
                let eachDictionaryKey = "\(eachKey)<\(eachTypeName)>" as NSString

                // Skip parent.
                guard eachKey != "Parent"
                else
                {
                    dictionary.setObject("<PARENT_NOT_SERIALIZED>", forKey: eachDictionaryKey)
                    return
                }
                    
                // Parse value.
                guard let eachValue = PDFParser.value(from: eachObject)
                else
                {
                    dictionary.setObject("<COULD_NOT_PARSE_VALUE>, \(CGPDFObjectGetType(eachObject).rawValue)", forKey: eachDictionaryKey)
                    fatalError("😭")
                    // return
                }
                
                // Set.
                dictionary.setObject(eachValue, forKey: eachDictionaryKey)
            },
            dictionaryPointer
        )
    }
}
