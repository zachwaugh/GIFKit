//
//  ApplicationExtension.swift
//  GIFKit
//
//  Created by Zach Waugh on 11/12/15.
//  Copyright © 2015 Zach Waugh. All rights reserved.
//

import Foundation

struct ApplicationExtension: CustomStringConvertible {
    let identifier: String
    let authenticationCode: [Byte]
    
    init(bytes: [Byte]) {
        identifier = String(bytes: bytes[0..<8], encoding: NSUTF8StringEncoding)!
        authenticationCode = Array(bytes[8..<11])
    }
    
    var description: String {
        return "<ApplicationExtension identifier: \(identifier), authentication code: \(authenticationCode)>"
    }
}