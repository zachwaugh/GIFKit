import Quick
import Nimble
@testable import GIFKit

class ColorTableSpec: QuickSpec {
    override func spec() {
        it("parses color table from data") {
            let bytes: [UInt8] = [0xFF, 0xF0, 0x0F, 0x00, 0xCC, 0xFF]
            let data = NSData(bytes: bytes, length: bytes.count)
            
            let colorTable = ColorTable(data: data)
            expect(colorTable.colors.count) == 2
            
            let color = colorTable.colors[0]
            expect(color.red) == 255
            expect(color.green) == 240
            expect(color.blue) == 15
            
            let color2 = colorTable.colors[1]
            expect(color2.red) == 0
            expect(color2.green) == 204
            expect(color2.blue) == 255
        }
    }
}
