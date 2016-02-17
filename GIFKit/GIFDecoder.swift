//
//  GIFDecoder.swift
//  GIFKit
//
//  Created by Zach Waugh on 11/1/15.
//  Copyright © 2015 Zach Waugh. All rights reserved.
//

import Foundation

//        Legend:           <>    grammar word
//        ::=   defines symbol
//        *     zero or more occurrences
//        +     one or more occurrences
//        |     alternate element
//        []    optional element
//
//        The Grammar.
//
//        <GIF Data Stream> ::=     Header <Logical Screen> <Data>* Trailer
//
//        <Logical Screen> ::=      Logical Screen Descriptor [Global Color Table]
//
//        <Data> ::=                <Graphic Block>  |  <Special-Purpose Block>
//
//        <Graphic Block> ::=       [Graphic Control Extension] <Graphic-Rendering Block>
//
//        <Graphic-Rendering Block> ::=  <Table-Based Image>  |  Plain Text Extension
//
//        <Table-Based Image> ::=   Image Descriptor [Local Color Table] Image Data
//
//        <Special-Purpose Block> ::=    Application Extension  |  Comment Extension

typealias Byte = UInt8

struct Label {
    static let ExtensionIntroducer: Byte = 0x21
    
    // Extensions
    static let PlainTextExtension: Byte = 0x01
    static let GraphicControlExtension: Byte = 0xF9
    static let ApplicationExtension: Byte = 0xFF
    static let CommentExtension: Byte = 0xFE
    
    // Other Labels
    static let ImageDescriptor: Byte = 0x2C
    static let BlockTerminator: Byte = 0x00
    static let Trailer: Byte = 0x3B
}

struct Size {
    static let Header = 6
    static let ImageDescriptor = 9
    static let GraphicControlExtension = 6
}

enum DecodingError: ErrorType {
    case InvalidGIF
    case InvalidSignature
    case InvalidVersion
    case UnexpectedEndOfFile
}

class GIFDecoder {
    private var dataStream: DataStream
    private var logicalScreenDescriptor: LogicalScreenDescriptor?
    private var globalColorTable: ColorTable?
    
    init(data: NSData) {
        self.dataStream = DataStream(data: data)
    }
    
    func decode() throws -> GIF {
        do {
            try parseHeader()
            try parseLogicalScreenDescriptor()
            try parseData()
            
            return GIF(frames: [])
        } catch let error {
            throw error
        }
    }
    
    // MARK: - Parsing
    
    func parseHeader() throws {
        print("- Header: \(dataStream.position)")

        guard let data: NSData = dataStream.takeBytes(Size.Header) else {
            throw DecodingError.InvalidGIF
        }
        
        let header = Header(data: data)
        guard header.hasValidSignature() else {
            throw DecodingError.InvalidSignature
        }
        
        guard header.hasValidVersion() else {
            throw DecodingError.InvalidVersion
        }
        print("  -> \(header)")
    }
    
    func parseLogicalScreenDescriptor() throws {
        print("- LogicalScreenDescriptor: \(dataStream.position)")
        guard let data: NSData = dataStream.takeBytes(7) else {
            throw DecodingError.InvalidGIF
        }
        
        let logicalScreenDescriptor = LogicalScreenDescriptor(data: data)
        if logicalScreenDescriptor.hasGlobalColorTable {
            print("  -> has global color table of size: \(logicalScreenDescriptor.globalColorTableSize), bytes: \(logicalScreenDescriptor.globalColorTableBytes)")
            parseGlobalColorTable(logicalScreenDescriptor.globalColorTableBytes)
        }
        
        self.logicalScreenDescriptor = logicalScreenDescriptor
        print("  -> \(logicalScreenDescriptor)")
    }
    
    func parseGlobalColorTable(size: UInt8) {
        guard let data: NSData = dataStream.takeBytes(Int(size)) else {
            return
        }
        
        globalColorTable = ColorTable(data: data)
        print("- GlobalColorTable: \(globalColorTable)")
    }
    
    // MARK: - Data blocks
    
    func parseData() throws {
        while let byte = dataStream.takeByte() {
            let value = String(format: "0x%02x", byte)
            print("- Data loop: \(value), \(dataStream.position)")
            
            switch byte {
            case Label.ExtensionIntroducer:
                print("  -> found extension introducer: \(value)")
                try parseExtension()
            case Label.ImageDescriptor:
                print("  -> found image descriptor: \(value)")
                try parseImageDescriptor()
            case Label.Trailer:
                print("  -> found trailer \(value)")
                try parseTrailer()
            default:
                print("  -> no block or trailer?: \(value)")
                throw DecodingError.InvalidGIF
            }
        }
    }
    
    func parseExtension() throws {
        guard let byte = dataStream.takeByte() else {
            print("[gif decoder] no more bytes!")
            throw DecodingError.InvalidGIF
        }
        
        switch byte {
        case Label.GraphicControlExtension: parseGraphicControlExtension()
        case Label.PlainTextExtension: parsePlainTextExtension()
        case Label.ApplicationExtension: parseApplicationExtension()
        case Label.CommentExtension: parseCommentExtension()
        default: print("-> unhandled block: \(byte)")
        }
    }
    
    func parseDataSubBlocks() -> [[Byte]] {
        print("- DataSubBlocks: \(dataStream.position)")
        
        var blocks: [[Byte]] = []
        
        while let byte = dataStream.takeByte() {
            if byte != Label.BlockTerminator {
                let block: [Byte] = dataStream.takeBytes(Int(byte))!
                blocks.append(block)
            } else {
                print("  -> found terminator: \(dataStream.position)")
                break
            }
        }
        
        return blocks
    }
    
    func parseGraphicControlExtension() {
        print("- GraphicControlExtension: \(dataStream.position)")
        let size = dataStream.takeByte()!
        let graphicControlExtension = GraphicControlExtension(data: dataStream.takeBytes(Int(size))!)
        dataStream.takeByte()! // skip terminator
        
        print("  -> \(graphicControlExtension)")
    }
    
    func parseImageDescriptor() throws {
        print("- ImageDescriptor: \(dataStream.position)")
        let bytes: [Byte] = dataStream.takeBytes(Size.ImageDescriptor)!
        let imageDescriptor = ImageDescriptor(data: NSData(bytes: bytes, length: bytes.count))
        print(" -> \(imageDescriptor)")
        
        try parseTableBasedImage()
    }
    
    func parseTableBasedImage() throws {
        print("- TableBasedImageData: \(dataStream.position)")
        
        let minimumCodeSize = dataStream.takeByte()!
        print("  -> LZW Minimum Code size: \(minimumCodeSize)")
        
        let imageBytes = parseDataSubBlocks().flatMap({ $0 })
        print("  -> image data bytes: (\(imageBytes.count)) - \(imageBytes)")
    }
    
    func parseApplicationExtension() {
        print("- ApplicationExtension: \(dataStream.position)")
        if let blockSize = dataStream.takeByte(), bytes: [Byte] = dataStream.takeBytes(Int(blockSize)) {
            let applicationExtension = ApplicationExtension(bytes: bytes)
            print(" -> \(applicationExtension)")
        }
        let bytes = parseDataSubBlocks().flatMap({ $0 }).count
        print("  -> sub-blocks: \(bytes) bytes")
    }
    
    func parsePlainTextExtension() {
        print("- PlainTextExtension: \(dataStream.position)")
    }
    
    func parseCommentExtension() {
        print("- CommentExtension: \(dataStream.position)")
    }
    
    // MARK: - Trailer
    
    func parseTrailer() throws {
        guard dataStream.atEndOfStream else {
            print(" -> found trailer but not at end of stream!")
            throw DecodingError.UnexpectedEndOfFile
        }
    }
}

struct LZWDecompressor {
    let data: NSData
    var codeSize: Int
    
    func decompress() {
        var bytes = [Byte](count: data.length, repeatedValue: 0)
        data.getBytes(&bytes, length: data.length)
        
        for byte in bytes {
            let bits = byte & 0b1110000
            let nextBits = byte & 0b00011100
            let more = byte & 0b00000011 << 0
        }
    }
}

extension NSData {
    var string: String? {
        return String(data: self, encoding: NSUTF8StringEncoding)
    }
}
