//
//  Header.swift
//  GIFKit
//
//  Created by Zach Waugh on 11/5/15.
//  Copyright © 2015 Zach Waugh. All rights reserved.
//

import Foundation

struct Header {
    private let dataStream: DataStream
    
    init(data: NSData) {
        dataStream = DataStream(data: data)
    }
    
    var signature: String? {
        if let bytes = dataStream.peekBytesWithRange(NSRange(location: 0, length: 3)), string = bytes.string {
            return string
        }
        
        return nil
    }
    
    func hasValidSignature() -> Bool {
        if let signature = signature where isValidSignature(signature) {
            return true
        }
        
        print("[gif decoder] invalid or missing signature: \(signature)")
        
        return false
    }
    
    func isValidSignature(signature: String) -> Bool {
        return signature == "GIF"
    }
    
    var version: String? {
        if let bytes = dataStream.peekBytesWithRange(NSRange(location: 3, length: 3)), string = bytes.string {
            return string
        }
        
        return nil
    }
    
    func hasValidVersion() -> Bool {
        if let version = version where isValidVersion(version) {
            return true
        }
        
        print("[gif decoder] invalid or missing version: \(version)")
        return false
    }
    
    func isValidVersion(version: String) -> Bool {
        return version == "87a" || version == "89a"
    }
}