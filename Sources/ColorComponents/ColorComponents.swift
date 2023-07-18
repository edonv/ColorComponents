//
//  ColorComponents.swift
//
//
//  Created by Edon Valdman on 9/28/22.
//

import Foundation
import SwiftUI

public class ColorComponents: Codable, RawRepresentable, Hashable {
    // MARK: - Primary Initializer
    
    /// Creates a color with RGB values (`0`-`255`).
    /// - Parameters:
    ///   - red: A red component value (`0`-`255`).
    ///   - green: A green component value (`0`-`255`).
    ///   - blue: A blue component value (`0`-`255`).
    ///   - alpha: An alpha value (`0`-`255`).
    public init(red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }
    
    // MARK: - Properties
    
    /// A red component value (`0`-`255`).
    public var red: UInt8
    /// A green component value (`0`-`255`).
    public var green: UInt8
    /// A blue component value (`0`-`255`).
    public var blue: UInt8
    /// An alpha value (`0`-`255`).
    public var alpha: UInt8
    
    // MARK: - alpha(_:)
    
    /// Returns a color with the provided alpha value.
    /// - Parameter alpha: A new alpha value.
    /// - Returns: A color with modified opacity.
    public func alpha(_ alpha: CGFloat) -> ColorComponents {
        let newColor = self
        newColor.alpha = UInt8(alpha / 255)
        return newColor
    }
    
    /// Initializes from a hex-formatted string.
    ///
    /// It must be in one of the following formats: `#000`, `#000000`, or `#00000000` (the last of which being `RGBA`). `#` is optional.
    /// - Parameter hexString: A hex-formatted string.
    public convenience init?(hexString: String) {
        var newString = hexString
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .uppercased()
            .replacingOccurrences(of: "#", with: "")
        
        guard [3, 6, 8].contains(newString.count) else { return nil }
        
        if newString.count == 3 {
            newString = newString.reduce(into: "") { partialResult, char in
                partialResult.append("\(char)\(char)")
            }
        }
        if newString.count == 6 {
            newString += "FF"
        }
        
        var rgbValue: UInt64 = 0
        Scanner(string: newString).scanHexInt64(&rgbValue)
        
        self.init(hexWithAlpha: Int(rgbValue))
    }
    
    /// A hex-formatted string without alpha (`#000000`).
    public var hexString: String {
        hexString(withAlpha: false)
    }
    
    /// A hex-formatted string with (`#00000000`) or without (`#000000`) alpha.
    /// - Parameter withAlpha: Whether or not to include the alpha value in the generated string.
    /// - Returns: A hex-formatted string.
    public func hexString(withAlpha: Bool) -> String {
        String(format: "#" + Array(repeating: "%02X", count: withAlpha ? 4 : 3).joined(),
               arguments: withAlpha ? [red, green, blue, alpha] : [red, green, blue])
    }
    
    /// Generates a hexadecimal integer representing the color components.
    /// - Parameter withAlpha: Whether or not to include the alpha value.
    /// - Returns: A hexadecimal integer representing the color components.
    public func hexInt(withAlpha: Bool = true) -> Int {
        let components = withAlpha ? self : self.alpha(0)
        
        return Int(components.hexString
            .replacingOccurrences(of: "0x", with: "")
            .replacingOccurrences(of: "#", with: ""),
                   radix: 16)!
    }
    
    // MARK: - Codable
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(hexInt(withAlpha: true))
    }
    
    required public convenience init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.init(hexWithAlpha: try container.decode(Int.self))
    }
    
    // MARK: - RawRepresentable
    
    public var rawValue: Int {
        hexInt(withAlpha: true)
    }
    
    required public convenience init?(rawValue: Int) {
        self.init(hexWithAlpha: rawValue)
    }
}

extension ColorComponents {
    // MARK: - Hexadecimal Integer Intializers
    
    /// Initializes from a hexadecimal integer that includes an alpha value.
    ///
    /// This can either be directly coded as hexadecimal literal `0xFFFFFFFF` or as a regular integer literal (less human-readable).
    /// - Parameter hexInt: A hexadecimal integer.
    public convenience init(hexWithAlpha hexInt: Int) {
        self.init(red:   UInt8((hexInt & 0xff000000) >> 24),
                  green: UInt8((hexInt & 0x00ff0000) >> 16),
                  blue:  UInt8((hexInt & 0x0000ff00) >> 8),
                  alpha: UInt8((hexInt & 0x000000ff) >> 0))
    }
    
    /// Initializes from a hexadecimal integer that does not include an alpha value.
    ///
    /// This can either be directly coded as hexadecimal literal `0xFFFFFF` or as a regular integer literal (less human-readable).
    /// - Parameter hexInt: A hexadecimal integer.
    public convenience init(hexWithoutAlpha hexInt: Int) {
        self.init(red:   UInt8((hexInt & 0xff0000) >> 16),
                  green: UInt8((hexInt & 0x00ff00) >> 8),
                  blue:  UInt8((hexInt & 0x0000ff) >> 0),
                  alpha: 255)
    }
    
    // MARK: - CGColor
    
    /// Initializes from a `CGColor`.
    /// - Parameter cgColor: A `CGColor`.
    public convenience init?(cgColor: CGColor) {
        guard let components = cgColor.components else { return nil }
        let red, green, blue, alpha: Float
        
        if components.count == 2 {
            red = Float(components[0])
            green = Float(components[0])
            blue = Float(components[0])
            alpha = Float(components[1])
        } else {
            red = Float(components[0])
            green = Float(components[1])
            blue = Float(components[2])
            alpha = Float(components[3])
        }
        
        self.init(red: UInt8(red * 255),
                  green: UInt8(green * 255),
                  blue: UInt8(blue * 255),
                  alpha: UInt8(alpha * 255))
    }
    
    /// Creates a `CGColor` from the color components.
    public var cgColor: CGColor {
        #if !os(macOS)
        if #available(iOS 13.0, tvOS 13.0, watchOS 6.0, *) {
            return CGColor(red: CGFloat(red / 255),
                           green: CGFloat(green / 255),
                           blue: CGFloat(blue / 255),
                           alpha: CGFloat(alpha / 255))
        } else {
            return uiColor.cgColor
        }
        #else
        return CGColor(red: CGFloat(red / 255),
                       green: CGFloat(green / 255),
                       blue: CGFloat(blue / 255),
                       alpha: CGFloat(alpha / 255))
        #endif
    }
}

extension ColorComponents {
    // MARK: - UIColor
    
    #if canImport(UIKit)
    /// Initializes from a `UIColor`.
    /// - Parameter uiColor: A `UIColor`.
    public convenience init?(uiColor: UIColor?) {
        guard let uiColor = uiColor else { return nil }
        self.init(cgColor: uiColor.cgColor)
    }
    
    /// Creates a `UIColor` from the color components.
    public var uiColor: UIColor {
        UIColor(
            red: CGFloat(red / 255),
            green: CGFloat(green / 255),
            blue: CGFloat(blue / 255),
            alpha: CGFloat(alpha / 255)
        )
    }
    #endif
    
    // MARK: - NSColor
    
    #if canImport(AppKit)
    /// Initializes from an `NSColor`.
    /// - Parameter nsColor: An `NSColor`.
    public convenience init?(nsColor: NSColor?) {
        guard let nsColor = nsColor else { return nil }
        self.init(cgColor: nsColor.cgColor)
    }
    
    /// Creates a `UIColor` from the color components.
    public var nsColor: NSColor {
        NSColor(
            srgbRed: CGFloat(red / 255),
            green: CGFloat(green / 255),
            blue: CGFloat(blue / 255),
            alpha: CGFloat(alpha / 255)
        )
    }
    #endif
    
    // MARK: - SwiftUI Color
    
    /// Initializes from a SwiftUI `Color`.
    /// - Parameter color: A SwiftUI `Color`.
    @available(iOS 14, macOS 11, tvOS 14, watchOS 7, *)
    public convenience init?(color: Color?) {
        guard let cgColor = color?.cgColor else { return nil }
        self.init(cgColor: cgColor)
    }
    
    /// Creates a SwiftUI `Color` from the color components.
    @available(iOS 13, macOS 10.15, macCatalyst 13, tvOS 13, watchOS 6, *)
    public var color: Color {
        Color(.sRGB,
              red: Double(red / 255),
              green: Double(green / 255),
              blue: Double(blue / 255),
              opacity: Double(alpha / 255)
        )
    }
    
    /// Creates a SwiftUI `Color` from the color components in the provided color space.
    /// - Parameter colorSpace: A RGB color space in which to create the `Color`.
    /// - Returns: A SwiftUI `Color`.
    @available(iOS 13, macOS 10.15, macCatalyst 13, tvOS 13, watchOS 6, *)
    public func color(inSpace colorSpace: Color.RGBColorSpace = .sRGB) -> Color {
        Color(colorSpace,
              red: Double(red / 255),
              green: Double(green / 255),
              blue: Double(blue / 255),
              opacity: Double(alpha / 255)
        )
    }
}

// MARK: - CustomStringConvertible

extension ColorComponents: CustomStringConvertible {
    public var description: String {
        "ColorComponents(red: \(red), blue: \(blue), green: \(green), alpha: \(alpha))"
    }
}
