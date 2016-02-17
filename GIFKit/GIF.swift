//
//  GIF.swift
//  GIFKit
//
//  Created by Zach Waugh on 11/1/15.
//  Copyright © 2015 Zach Waugh. All rights reserved.
//

import Foundation

struct GIFFrame {
    let delay: CGFloat
    let data: NSData
}

struct GIF {
    let frames: [GIFFrame]
    
    var isAnimated: Bool {
        return frames.count > 1
    }
}
