//
//  LogicalScreenDescriptor.swift
//  GIFKit
//
//  Created by Zach Waugh on 11/5/15.
//  Copyright © 2015 Zach Waugh. All rights reserved.
//

import Foundation

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
