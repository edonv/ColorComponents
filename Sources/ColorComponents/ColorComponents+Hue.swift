//
//  ColorComponents+Hue.swift
//  ColorComponents
//
//  Created by Edon Valdman on 7/18/23.
//

import Foundation

#if canImport(SwiftUI)
import SwiftUI
#endif

// MARK: - Convenience Tuples

extension ColorComponents {
    public typealias HSL = (H: CGFloat, S: CGFloat, L: CGFloat)
    public typealias HSLA = (H: CGFloat, S: CGFloat, L: CGFloat, A: CGFloat)
    public typealias HSV = (H: CGFloat, S: CGFloat, V: CGFloat)
    public typealias HSVA = (H: CGFloat, S: CGFloat, V: CGFloat, A: CGFloat)
    public typealias HSB = HSV
    public typealias HSBA = HSVA
    
    private typealias LargeHueInfo = (
        H: CGFloat,
        Sv: CGFloat,
        Sl: CGFloat,
        L: CGFloat,
        V: CGFloat,
        A: CGFloat
    )
    
    private var fullHueInfo: LargeHueInfo {
        let R = 255 * CGFloat(red)
        let G = 255 * CGFloat(green)
        let B = 255 * CGFloat(blue)
        let A = 255 * CGFloat(alpha)
        
        // V
        let Xmax = max(max(R, G), B)
        // V - Chroma
        let Xmin = min(min(R, G), B)
        let Chroma = Xmax - Xmin
        let L = (Xmax + Xmin) / 2
        
        let H: CGFloat
        switch (Chroma, Xmax) {
        case (0, _):
            H = 0
        case (let C, let V) where V == R:
            H = 60 * ((G - B) / C).truncatingRemainder(dividingBy: 6)
        case (let C, let V) where V == G:
            H = 60 * ((B - R) / C) + 2
        case (let C, let V) where V == B:
            H = 60 * ((R - G) / C) + 4
        default:
            H = 0
        }
        
        return (
            H,
            Xmax == 0 ? 0 : (Chroma / Xmax),
            (L == 0 || L == 1) ? 0 : ((Xmax - L) / (min(L, 1 - L))),
            L,
            Xmax,
            A
        )
    }
}

// MARK: - HSL

extension ColorComponents {
    public convenience init(hue: CGFloat, saturation: CGFloat, lightness: CGFloat, alpha: CGFloat = 1.0) {
        let H = max(0, min(hue, 360))
        let S = max(0, min(saturation, 1))
        let L = max(0, min(lightness, 1))
        let A = max(0, min(alpha, 1))
        
        let Chroma = (1 - abs(2 * L - 1) * S)
        let Hprime = H / 60 // 60°
        let X = Chroma * (1 - abs(Hprime.truncatingRemainder(dividingBy: 2) - 1))
        
        let (R1, G1, B1): (CGFloat, CGFloat, CGFloat)
        switch Hprime {
        case 0..<1:
            (R1, G1, B1) = (Chroma, X, 0)
        case 1..<2:
            (R1, G1, B1) = (X, Chroma, 0)
        case 2..<3:
            (R1, G1, B1) = (0, Chroma, X)
        case 3..<4:
            (R1, G1, B1) = (0, X, Chroma)
        case 4..<5:
            (R1, G1, B1) = (X, 0, Chroma)
        case 5..<6:
            (R1, G1, B1) = (Chroma, 0, X)
        default:
            (R1, G1, B1) = (0, 0, 0)
        }
        
        let m = L - (Chroma / 2)
        self.init(red: UInt8((R1 + m) * 255),
                  green: UInt8((G1 + m) * 255),
                  blue: UInt8((B1 + m) * 255),
                  alpha: UInt8(A * 255))
    }
    
    @available(iOS 13, macOS 10.15, macCatalyst 13, tvOS 13, watchOS 6, *)
    public convenience init(hue: Angle, saturation: CGFloat, lightness: CGFloat, alpha: CGFloat = 1.0) {
        self.init(hue: hue.degrees, saturation: saturation, lightness: lightness, alpha: alpha)
    }
    
    public var hsl: HSL {
        let fullInfo = fullHueInfo
        return (fullInfo.H, fullInfo.Sl, fullInfo.L)
    }
    
    public var hsla: HSLA {
        let fullInfo = fullHueInfo
        return (fullInfo.H, fullInfo.Sl, fullInfo.L, fullInfo.A)
    }
}

// MARK: - HSV/HSB

extension ColorComponents {
    public convenience init(hue: CGFloat, saturation: CGFloat, value: CGFloat, alpha: CGFloat = 1.0) {
        let H = max(0, min(hue, 360))
        let S = max(0, min(saturation, 1))
        let V = max(0, min(value, 1))
        let A = max(0, min(alpha, 1))
        
        let Chroma = V * S
        let Hprime = H / 60 // 60°
        let X = Chroma * (1 - abs(Hprime.truncatingRemainder(dividingBy: 2) - 1))
        
        let (R1, G1, B1): (CGFloat, CGFloat, CGFloat)
        switch Hprime {
        case 0..<1:
            (R1, G1, B1) = (Chroma, X, 0)
        case 1..<2:
            (R1, G1, B1) = (X, Chroma, 0)
        case 2..<3:
            (R1, G1, B1) = (0, Chroma, X)
        case 3..<4:
            (R1, G1, B1) = (0, X, Chroma)
        case 4..<5:
            (R1, G1, B1) = (X, 0, Chroma)
        case 5..<6:
            (R1, G1, B1) = (Chroma, 0, X)
        default:
            (R1, G1, B1) = (0, 0, 0)
        }
        
        let m = V - Chroma
        self.init(red: UInt8((R1 + m) * 255),
                  green: UInt8((G1 + m) * 255),
                  blue: UInt8((B1 + m) * 255),
                  alpha: UInt8(A * 255))
    }
    
    public convenience init(hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat = 1.0) {
        self.init(hue: hue, saturation: saturation, value: brightness, alpha: alpha)
    }
    
    @available(iOS 13, macOS 10.15, macCatalyst 13, tvOS 13, watchOS 6, *)
    public convenience init(hue: Angle, saturation: CGFloat, value: CGFloat, alpha: CGFloat = 1.0) {
        self.init(hue: hue.degrees, saturation: saturation, value: value, alpha: alpha)
    }
    
    @available(iOS 13, macOS 10.15, macCatalyst 13, tvOS 13, watchOS 6, *)
    public convenience init(hue: Angle, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat = 1.0) {
        self.init(hue: hue.degrees, saturation: saturation, value: brightness, alpha: alpha)
    }
    
    public var hsv: HSV {
        let fullInfo = fullHueInfo
        return (fullInfo.H, fullInfo.Sv, fullInfo.V)
    }
    
    public var hsva: HSVA {
        let fullInfo = fullHueInfo
        return (fullInfo.H, fullInfo.Sv, fullInfo.V, fullInfo.A)
    }
    
    public var hsb: HSB { hsv }
    public var hsba: HSBA { hsva }
}

// MARK: - HSI

extension ColorComponents {
    public convenience init(hue: CGFloat?, saturation: CGFloat, intensity: CGFloat, alpha: CGFloat = 1.0) {
        let S = max(0, min(saturation, 1))
        let I = max(0, min(intensity, 1))
        let A = max(0, min(alpha, 1))
        
        let (R1, G1, B1): (CGFloat, CGFloat, CGFloat)
        if let hue {
            let H = max(0, min(hue, 360))

            let Hprime = H / 60 // 60°
            let Z = 1 - abs(Hprime.truncatingRemainder(dividingBy: 2) - 1)
            let Chroma = (2 * I * S) / (1 + Z)
            let X = Chroma * Z
            
            switch Hprime {
            case 0..<1:
                (R1, G1, B1) = (Chroma, X, 0)
            case 1..<2:
                (R1, G1, B1) = (X, Chroma, 0)
            case 2..<3:
                (R1, G1, B1) = (0, Chroma, X)
            case 3..<4:
                (R1, G1, B1) = (0, X, Chroma)
            case 4..<5:
                (R1, G1, B1) = (X, 0, Chroma)
            case 5..<6:
                (R1, G1, B1) = (Chroma, 0, X)
            default:
                (R1, G1, B1) = (0, 0, 0)
            }
        } else {
            (R1, G1, B1) = (0, 0, 0)
        }
        
        let m = I - (1 - S)
        self.init(red: UInt8((R1 + m) * 255),
                  green: UInt8((G1 + m) * 255),
                  blue: UInt8((B1 + m) * 255),
                  alpha: UInt8(A * 255))
    }
    
    @available(iOS 13, macOS 10.15, macCatalyst 13, tvOS 13, watchOS 6, *)
    public convenience init(hue: Angle?, saturation: CGFloat, intensity: CGFloat, alpha: CGFloat = 1.0) {
        self.init(hue: hue != nil ? hue!.degrees : nil, saturation: saturation, intensity: intensity, alpha: alpha)
    }
}

// MARK: - Luma, Chroma, Hue

extension ColorComponents {
    public convenience init(hue: CGFloat?, chroma: CGFloat, luma: CGFloat, alpha: CGFloat = 1.0) {
        let Chroma = max(0, min(chroma, 1))
        let Yprime = max(0, min(luma, 1))
        let A = max(0, min(alpha, 1))
        
        let (R1, G1, B1): (CGFloat, CGFloat, CGFloat)
        if let hue {
            // For this formula, H must be 0..<360
            let H = max(0, min(hue == 360 ? 0 : hue, 359))
            
            let Hprime = H / 60 // 60°
            let X = Chroma * (1 - abs(Hprime.truncatingRemainder(dividingBy: 2) - 1))
            
            switch Hprime {
            case 0..<1:
                (R1, G1, B1) = (Chroma, X, 0)
            case 1..<2:
                (R1, G1, B1) = (X, Chroma, 0)
            case 2..<3:
                (R1, G1, B1) = (0, Chroma, X)
            case 3..<4:
                (R1, G1, B1) = (0, X, Chroma)
            case 4..<5:
                (R1, G1, B1) = (X, 0, Chroma)
            case 5..<6:
                (R1, G1, B1) = (Chroma, 0, X)
            default:
                (R1, G1, B1) = (0, 0, 0)
            }
        } else {
            (R1, G1, B1) = (0, 0, 0)
        }
        
        let m = Yprime - (0.30 * R1 + 0.59 * G1 + 0.11 * B1)
        self.init(red: UInt8((R1 + m) * 255),
                  green: UInt8((G1 + m) * 255),
                  blue: UInt8((B1 + m) * 255),
                  alpha: UInt8(A * 255))
    }
    
    @available(iOS 13, macOS 10.15, macCatalyst 13, tvOS 13, watchOS 6, *)
    public convenience init(hue: Angle?, chroma: CGFloat, luma: CGFloat, alpha: CGFloat = 1.0) {
        self.init(hue: hue != nil ? hue!.degrees : nil, chroma: chroma, luma: luma, alpha: alpha)
    }
}
