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
            
            return GIF()
        } catch let error {
            throw error
        }
    }
    
    // MARK: - Parsing
    
    func parseHeader() throws {
        guard let data = dataStream.takeBytes(Size.Header) else {
            throw DecodingError.InvalidGIF
        }
        
        let header = Header(data: data)
        guard header.hasValidSignature() else {
            throw DecodingError.InvalidSignature
        }
        
        guard header.hasValidVersion() else {
            throw DecodingError.InvalidVersion
        }
    }
    
    func parseLogicalScreenDescriptor() throws {
        guard let data = dataStream.takeBytes(7) else {
            throw DecodingError.InvalidGIF
        }
        
        let logicalScreenDescriptor = LogicalScreenDescriptor(data: data)
        if logicalScreenDescriptor.hasGlobalColorTable {
            parseGlobalColorTable(logicalScreenDescriptor.globalColorTableBytes)
        }
        
        self.logicalScreenDescriptor = logicalScreenDescriptor
    }
    
    func parseGlobalColorTable(size: UInt8) {
        guard let data = dataStream.takeBytes(Int(size)) else {
            return
        }
        
        globalColorTable = ColorTable(data: data)
    }
    
    // MARK: - Data blocks
    
    func parseData() throws {
        guard let byte = dataStream.takeByte() else {
            print("[gif decoder] no more bytes!")
            throw DecodingError.InvalidGIF
        }
        
        print("- Data")
        
        switch byte {
        case Label.ExtensionIntroducer:
            print(" -> found extension introducer: \(byte)")
            try parseExtension()
        case Label.ImageDescriptor:
            print(" -> found image descriptor: \(byte)")
            try parseImageDescriptor()
        case Label.Trailer:
            try parseTrailer()
        default:
            print(" -> no block or trailer?: \(byte)")
            throw DecodingError.InvalidGIF
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
        
        try parseData()
    }
    
    func parseDataSubBlocks() {
        guard let byte = dataStream.takeByte() else {
            print("[gif decoder] no more bytes!")
            return
        }
        
        print("- DataSubBlocks, size: \(byte)")
        if byte != Label.BlockTerminator {
            dataStream.takeBytes(Int(byte))
            parseDataSubBlocks()
        } else {
            print(" -> found terminator")
        }
    }
    
    func parseGraphicControlExtension() {
        print("- GraphicControlExtension: \(dataStream.position)")
        let bytes = dataStream.takeBytes(Size.GraphicControlExtension)
        print("  -> \(bytes)")
    }
    
    func parseTableBasedImage() throws {
        let _ = dataStream.takeByte()
        try parseImageData()
    }
    
    func parseImageData() throws {
        parseDataSubBlocks()
        try parseData()
    }
    
    func parseImageDescriptor() throws {
        print("- ImageDescriptor: \(dataStream.position)")
        let bytes = dataStream.takeBytes(Size.ImageDescriptor)
        print(" -> bytes: \(bytes)")
        
        try parseTableBasedImage()
    }
    
    func parsePlainTextExtension() {
        print("- PlainTextExtension: \(dataStream.position)")
    }
    
    func parseApplicationExtension() {
        print("- ApplicationExtension: \(dataStream.position)")
        let bytes = dataStream.takeBytes(12)
        print(" -> \(bytes)")
        parseDataSubBlocks()
    }
    
    func parseCommentExtension() {
        print("- CommentExtension: \(dataStream.position)")
    }
    
    // MARK: - Trailer
    
    func parseTrailer() throws {
        guard dataStream.atEndOfStream else {
            print(" -> found trailer but not at end of stream!")
            throw DecodingError.InvalidGIF
        }
    }
}

extension NSData {
    var string: String? {
        return String(data: self, encoding: NSUTF8StringEncoding)
    }
}
