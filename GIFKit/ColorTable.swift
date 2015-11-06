//
//  ColorTable.swift
//  GIFKit
//
//  Created by Zach Waugh on 11/5/15.
//  Copyright © 2015 Zach Waugh. All rights reserved.
//

import Foundation

struct Color {
    let red: Byte
    let green: Byte
    let blue: Byte
}

struct ColorTable {
    let colors: [Color]
    
    init(data: NSData) {
        var bytes: [Byte] = Array(count: data.length, repeatedValue: 0)
        data.getBytes(&bytes, length: data.length)
        colors = 0.stride(to: bytes.count - 1, by: 3).map({ Color(red: bytes[$0], green: bytes[$0+1], blue: bytes[$0+2]) })
    }
}
