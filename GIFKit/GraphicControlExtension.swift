//
//  GraphicControlExtension.swift
//  GIFKit
//
//  Created by Zach Waugh on 11/15/15.
//  Copyright © 2015 Zach Waugh. All rights reserved.
//

import Foundation

struct GraphicControlExtension: CustomStringConvertible {
    let packedFields: Byte
    let delayTime: UInt16
    let transparentColorIndex: Byte
    
    var disposalMethod: UInt8 {
        return packedFields & 0b00011100
    }
    
    var userInputFlag: Bool {
        return (packedFields & 0b00000010) != 0
    }
    
    var transparentColorFlag: Bool {
        return (packedFields & 0b01000000) != 0
    }
    
    init(data: NSData) {
        var dataStream = DataStream(data: data)
        
        packedFields = dataStream.takeByte()!
        delayTime = dataStream.takeUInt16()!
        transparentColorIndex = dataStream.takeByte()!
    }
    
    var description: String {
        return "<GraphicControlExtension delayTime: \(delayTime), transparentColorIndex: \(transparentColorIndex), packedField: \(packedFields)>"
    }
}