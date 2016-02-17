import Quick
import Nimble
@testable import GIFKit

class DataStreamSpec: QuickSpec {
    override func spec() {
        describe(".takeByte") {
            var dataStream: DataStream!
            
            beforeEach {
                let bytes: [UInt8] = [0xDE, 0xAD, 0xBE, 0xEF]
                let data = NSData(bytes: bytes, length: bytes.count)
                
                dataStream = DataStream(data: data)
                expect(dataStream.position) == 0
                
            }
            
            context("when there are more bytes available") {
                it("returns the next byte from the current position") {
                    let byte = dataStream.takeByte()!
                    expect(byte) == 0xDE
                }
                
                it("advances the current position") {
                    let _ = dataStream.takeByte()
                    expect(dataStream.position) == 1
                }
            }
            
            context("when there are no more bytes available") {
                it("returns nil") {
                    dataStream.position = 4
                    let byte = dataStream.takeByte()
                    expect(byte).to(beNil())
                }
            }
        }
    }
}
