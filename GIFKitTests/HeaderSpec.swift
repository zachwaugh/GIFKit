import Quick
import Nimble
@testable import GIFKit

class HeaderSpec: QuickSpec {
    override func spec() {
        describe(".hasValidSignature()") {
            context("when there is valid signature") {
                it("returns true") {
                    let data = "GIF89a".dataUsingEncoding(NSUTF8StringEncoding)!
                    let header = Header(data: data)
                    expect(header.hasValidSignature()) == true
                }
            }

            context("when there is an invalid signature") {
                it("returns false") {
                    let data = "PNG89a".dataUsingEncoding(NSUTF8StringEncoding)!
                    let header = Header(data: data)
                    expect(header.hasValidSignature()) == false
                }
            }
        }

        describe(".hasValidVersion()") {
            context("when version is valid") {
                it("returns true") {
                    var data = "GIF87a".dataUsingEncoding(NSUTF8StringEncoding)!
                    var header = Header(data: data)
                    expect(header.hasValidVersion()) == true

                    data = "GIF89a".dataUsingEncoding(NSUTF8StringEncoding)!
                    header = Header(data: data)
                    expect(header.hasValidVersion()) == true
                }
            }

            context("when version is invalid") {
                it("returns false") {
                    let data = "GIF89b".dataUsingEncoding(NSUTF8StringEncoding)!
                    let header = Header(data: data)
                    expect(header.hasValidVersion()) == false
                }
            }
        }
    }
}
