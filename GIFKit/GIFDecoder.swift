//
//  GIFDecoder.swift
//  GIFKit
//
//  Created by Zach Waugh on 11/1/15.
//  Copyright © 2015 Zach Waugh. All rights reserved.
//

import Foundation

typealias Byte = UInt8

struct Label {
    static let ExtensionIntroducer: Byte = 0x21
    static let ApplicationExtension: Byte = 0xFF
    static let CommentExtension: Byte = 0xFE
    static let GraphicControlExtension: Byte = 0xF9
    static let Trailer: Byte = 0x3B
}

struct Trailer {
    let byte: Byte
}

struct ImageDescriptor {
    
}

enum DecodingError: ErrorType {
    case InvalidGIF
    case InvalidSignature(signature: String?)
    case InvalidVersion(version: String?)
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
    
    // MARK: - Data blocks
    
    func parseData() throws {
        
    }
    
    func parseGraphicBlock() {
        // parseGraphicControlExtensionIfPresent()
        // parseGraphicRenderingBlock()
    }
    
    func parseGraphicControlExtensionIfPresent() {
        
    }
    
    func parseGraphicRenderingBlock() {
        // parseTableBasedImage()
        // parsePlainTextExtension()
    }
    
    func parseTableBasedImage() {
        // parseImageDescriptor()
        // parseLocalColorTable()
        // parseImageData()
    }
    
    func parsePlainTextExtension() {
        
    }
    
    func parseSpecialPurposeBlock() {
        // parse application extension
        // parse comment extension
    }
    
    // MARK: - Trailer
    
    func parseTrailer() throws {
        
    }
}

extension NSData {
    var string: String? {
        return String(data: self, encoding: NSUTF8StringEncoding)
    }
}
