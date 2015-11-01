//
//  GIF.swift
//  GIFKit
//
//  Created by Zach Waugh on 11/1/15.
//  Copyright © 2015 Zach Waugh. All rights reserved.
//

import Foundation

struct GIF {
    
}

class GIFDecoder {
    private var data: NSData?
    private var position: Int = 0
    
    init(URL: NSURL) {
        data = NSData(contentsOfURL: URL)
    }
    
    func decode() -> GIF? {
        guard let data = data where isValidGIF() else {
            print("[gif decoder] invalid gif file!")
            return nil
        }
        
        return nil
    }
    
    var signature: String? {
        if let bytes = peekBytesWithRange(NSRange(location: 0, length: 3)), string = String(data: bytes, encoding: NSUTF8StringEncoding) {
            return string
        }
        
        return nil
    }
    
    var version: String? {
        if let bytes = peekBytesWithRange(NSRange(location: 3, length: 3)), string = String(data: bytes, encoding: NSUTF8StringEncoding) {
            return string
        }
        
        return nil
    }
    
    func isValidVersion() {
        
    }
    
    func isValidGIF() -> Bool {
        if let signature = signature, version = version where signature == "GIF" && version == "87a" {
            return true
        } else {
            return false
        }
    }
    
    func peekBytes(length: Int) -> NSData? {
        return peekBytesWithRange(NSRange(location: position, length: length))
    }
    
    func peekBytesWithRange(range: NSRange) -> NSData? {
        guard let data = data where range.location + range.length < data.length else {
            return nil
        }
        
        return data.subdataWithRange(range)
    }
    
    func seekBytes(length: Int) -> NSData? {
        guard let bytes = peekBytes(length) else {
            print("[gif decoder] invalid number of bytes!")
            return nil
        }
        
        position += length
        return bytes
    }
}