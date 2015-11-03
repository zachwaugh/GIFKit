//
//  GIFDecoder.swift
//  GIFKit
//
//  Created by Zach Waugh on 11/1/15.
//  Copyright © 2015 Zach Waugh. All rights reserved.
//

import Foundation

typealias Byte = UInt8

enum Label: Byte {
    case ExtensionIntroducer = 0x21
    case ApplicationExtension = 0xFF
    case CommentExtension = 0xFE
    case GraphicControlExtension = 0xF9
    case Trailer = 0x3B
}

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

struct Trailer {
    let byte: Byte
}

struct ImageDescriptor {
    
}

struct ColorTable {
    
}

struct LogicalScreenDescriptor {
    let width: UInt16
    let height: UInt16
    let packedFields: Byte
    let backgroundColorIndex: UInt8
    let pixelAspectRatio: UInt8
    
    init(data: NSData) {
        var dataStream = DataStream(data: data)
        
        width = dataStream.takeUInt16()
        height = dataStream.takeUInt16()
        packedFields = dataStream.takeByte()
        backgroundColorIndex = dataStream.takeUInt8()
        pixelAspectRatio = dataStream.takeUInt8()
    }
    
    var globalColorTableFlag: Bool {
        return (packedFields & 0b10000000) != 0
    }
    
    var colorResolution: UInt8 {
        return (packedFields & 0b01110000) >> 4
    }
    
    var sortFlag: Bool {
        return (packedFields & 0b00001000) != 0
    }
    
    var globalColorTableSize: UInt8 {
        return packedFields & 0b00000111
    }
}

enum DecodingError: ErrorType {
    case InvalidGIF
    case InvalidSignature(signature: String?)
    case InvalidVersion(version: String?)
}

struct DataStream {
    let data: NSData
    private var position: Int = 0
    
    init(data: NSData) {
        self.data = data
    }
    
    mutating func takeBool() -> Bool {
        var value: Bool = false
        let length = sizeof(Bool)
        data.getBytes(&value, range: NSRange(location: position, length: length))
        position += length
        
        return value
    }
    
    mutating func takeByte() -> Byte {
        return takeUInt8()
    }
    
    mutating func takeUInt8() -> UInt8 {
        var value: UInt8 = 0
        let length = sizeof(UInt8)
        data.getBytes(&value, range: NSRange(location: position, length: length))
        position += length
            
        return value
    }
    
    mutating func takeUInt16() -> UInt16 {
        var value: UInt16 = 0
        let length = sizeof(UInt16)
        data.getBytes(&value, range: NSRange(location: position, length: length))
        position += length
        
        return value
    }
    
    // MARK: - Low-level Data
    
    func peekBytes(length: Int) -> NSData? {
        return peekBytesWithRange(NSRange(location: position, length: length))
    }
    
    func peekBytesWithRange(range: NSRange) -> NSData? {
        guard range.location + range.length <= data.length else {
            print("[gif decoder] invalid range! \(range), bytes: \(data.length)")
            
            return nil
        }
        
        return data.subdataWithRange(range)
    }
    
    mutating func seekBytes(length: Int) -> NSData? {
        guard let bytes = peekBytes(length) else {
            print("[gif decoder] invalid number of bytes!")
            return nil
        }
        
        position += length
        return bytes
    }
}

class GIFDecoder {
    private var dataStream: DataStream
    
    init(data: NSData) {
        self.dataStream = DataStream(data: data)
    }
    
    func decode() throws -> GIF {
        do {
            try parseHeader()
            try parseLogicalScreenDescriptor()
            try parseData()
            try parseTrailer()
            
            return GIF()
        } catch let error {
            throw error
        }

    }
    
    // MARK: - Parsing
    
    func parseHeader() throws {
        guard let data = dataStream.seekBytes(6) else {
            throw DecodingError.InvalidGIF
        }
        
        let header = Header(data: data)
        guard header.hasValidSignature() else {
            throw DecodingError.InvalidSignature(signature: header.signature)
        }
        
        guard header.hasValidVersion() else {
            throw DecodingError.InvalidVersion(version: header.version)
        }
    }
    
    func parseLogicalScreenDescriptor() throws {
        guard let data = dataStream.seekBytes(7) else {
            throw DecodingError.InvalidGIF
        }
        
        let logicalScreenDescriptor = LogicalScreenDescriptor(data: data)
        print("[gif:decoder] logicalScreenDescriptor: \(logicalScreenDescriptor)")
    }
    
    func parseData() throws {
        
    }
    
    func parseTrailer() throws {
        
    }
}

extension NSData {
    var string: String? {
        return String(data: self, encoding: NSUTF8StringEncoding)
    }
}
