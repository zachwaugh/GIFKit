//
//  GIFDecoderTests.swift
//  GIFKit
//
//  Created by Zach Waugh on 11/1/15.
//  Copyright © 2015 Zach Waugh. All rights reserved.
//

import XCTest
import Quick
import Nimble
@testable import GIFKit

class GIFDecoderSpec: QuickSpec {
    override func spec() {
        describe(".decode") {
            context("with invalid signature") {
                it("throws an invalid signature error") {
                    var errorThrown = false
                    
                    let bytes: [UInt8] = [0xC8, 0x00, 0xC8, 0x00, 0xA2, 0x00, 0x00]
                    let data = NSData(bytes: bytes, length: bytes.count)
                    let decoder = GIFDecoder(data: data)
                    do {
                        try decoder.decode()
                        fail("Decoding should have failed")
                    } catch {
                        errorThrown = true
                    }
                    
                    expect(errorThrown).toEventually(beTrue())
                }
            }
            
            context("with invalid version") {
                it("throws an invalid version error") {
                    var errorThrown = false
                    
                    let bytes: [UInt8] = [0x47, 0x49, 0x46, 0x00, 0xA2, 0x00, 0x00]
                    let data = NSData(bytes: bytes, length: bytes.count)
                    let decoder = GIFDecoder(data: data)
                    do {
                        try decoder.decode()
                        fail("Decoding should have failed")
                    } catch let error {
                        print("error: \(error)")
                        errorThrown = true
                    }
                    
                    expect(errorThrown).toEventually(beTrue())
                }
            }
            
            context("with valid gif") {
                it("returns a gif") {
                    let URL = NSBundle(forClass: self.dynamicType).URLForResource("red", withExtension: "gif")!
                    let data = NSData(contentsOfURL: URL)!
                    let decoder = GIFDecoder(data: data)
                    
                    do {
                        try decoder.decode()
                        expect(true)
                    } catch {
                        fail("Error shouldn't be thrown for valid gif!")
                    }
                }
            }
            
//            context("with animated gif") {
//                it("returns an animated gif") {
//                    let URL = NSBundle(forClass: self.dynamicType).URLForResource("mind-blown", withExtension: "gif")!
//                    let data = NSData(contentsOfURL: URL)!
//                    let decoder = GIFDecoder(data: data)
//                    
//                    do {
//                        try decoder.decode()
//                        expect(true)
//                    } catch {
//                        fail("Error shouldn't be thrown for valid gif!")
//                    }
//                }
//            }
        }
    }
}
