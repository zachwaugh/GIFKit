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
    static let PlainTextExtension: Byte = 0x01
    static let ImageDescriptor: Byte = 0x2C
    static let GraphicControlExtension: Byte = 0xF9
    static let ApplicationExtension: Byte = 0xFF
    static let CommentExtension: Byte = 0xFE
    static let Trailer: Byte = 0x3B
}

struct Trailer {
    let byte: Byte
}

struct ImageDescriptor {
    
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
            throw DecodingError.InvalidSignature
        }
        
        guard header.hasValidVersion() else {
            throw DecodingError.InvalidVersion
        }
    }
    
    func parseLogicalScreenDescriptor() throws {
        guard let data = dataStream.seekBytes(7) else {
            throw DecodingError.InvalidGIF
        }
        
        let logicalScreenDescriptor = LogicalScreenDescriptor(data: data)
        if logicalScreenDescriptor.globalColorTableFlag {
            let size = 3 * pow(Double(2), Double(logicalScreenDescriptor.globalColorTableSize + 1))
            parseGlobalColorTable(UInt8(size))
        }
        
        self.logicalScreenDescriptor = logicalScreenDescriptor
    }
    
    func parseGlobalColorTable(size: UInt8) {
        guard let data = dataStream.seekBytes(Int(size)) else {
            return
        }
        
        globalColorTable = ColorTable(data: data)
        print("colors: \(globalColorTable!.colors)")
    }
    
    // MARK: - Data blocks
    
    func parseData() throws {
        guard let nextByte = dataStream.takeByte() else {
            print("[gif decoder] no more bytes!")
            throw DecodingError.InvalidGIF
        }
        
        if nextByte == Label.ExtensionIntroducer {
            try parseBlock()
        } else if nextByte == Label.Trailer {
            print("[gif decoder] found trailer, all done!")
        } else {
            print("[gif decoder] no block or trailer?")
        }
    }
    
    func parseBlock() throws {
        guard let byte = dataStream.takeByte() else {
            print("[gif decoder] no more bytes!")
            throw DecodingError.InvalidGIF
        }
        
        switch byte {
        case Label.GraphicControlExtension: parseGraphicControlExtension()
        case Label.ImageDescriptor: parseImageDescriptor()
        case Label.PlainTextExtension: parsePlainTextExtension()
        case Label.ApplicationExtension: parseApplicationExtension()
        case Label.CommentExtension: parseCommentExtension()
        default: print("-> unhandled block: \(byte)")
        }
        
        try parseData()
    }
    
    func parseGraphicBlock() {
        // parseGraphicControlExtensionIfPresent()
        // parseGraphicRenderingBlock()
    }
    
    func parseGraphicControlExtension() {
        print("-> GraphicControlExtension: \(dataStream.position)")
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
    
    func parseImageDescriptor() {
        print("-> ImageDescriptor: \(dataStream.position)")
    }
    
    func parsePlainTextExtension() {
        print("-> PlainTextExtension: \(dataStream.position)")
    }
    
    func parseSpecialPurposeBlock() {
        // parse application extension
        // parse comment extension
    }
    
    func parseApplicationExtension() {
        print("-> ApplicationExtension: \(dataStream.position)")
    }
    
    func parseCommentExtension() {
        print("-> CommentExtension: \(dataStream.position)")
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
