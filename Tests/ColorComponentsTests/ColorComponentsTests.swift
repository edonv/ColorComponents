import XCTest
@testable import ColorComponents

final class ColorComponentsTests: XCTestCase {
    func testHexStringInit() throws {
        let color = ColorComponents(red: 50, green: 255, blue: 50, alpha: 255)
        XCTAssertTrue(color == ColorComponents(hexString: color.hexString(withAlpha: false))!)
        XCTAssertTrue(color == ColorComponents(hexString: color.hexString(withAlpha: true))!)
    }
    
    func testHexInt() throws {
        let color1 = ColorComponents(hexString: "#323232FF")
        let color2 = ColorComponents(hexWithoutAlpha: 0x323232)
        print(color1)
        print(color2)
        
        XCTAssertTrue(color1 == color2)
    }
}
