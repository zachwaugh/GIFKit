import XCTest
import Quick
import Nimble
@testable import GIFKit

class LogicalScreenDescriptorSpec: QuickSpec {
    override func spec() {
        it("parses descriptor from data") {
            let bytes: [UInt8] = [0xC8, 0x00, 0xC8, 0x00, 0xA2, 0x00, 0x00]
            let data = NSData(bytes: bytes, length: bytes.count)
            
            let logicalScreenDescriptor = LogicalScreenDescriptor(data: data)
            expect(logicalScreenDescriptor.width) == 200
            expect(logicalScreenDescriptor.height) == 200
            expect(logicalScreenDescriptor.globalColorTableFlag) == true
            expect(logicalScreenDescriptor.colorResolution) == 2
            expect(logicalScreenDescriptor.sortFlag) == false
            expect(logicalScreenDescriptor.globalColorTableSize) == 2
            expect(logicalScreenDescriptor.globalColorTableBytes) == 24
            expect(logicalScreenDescriptor.backgroundColorIndex) == 0
            expect(logicalScreenDescriptor.pixelAspectRatio) == 0
        }
    }
}