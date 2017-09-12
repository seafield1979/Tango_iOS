//
//  UColor.swift
//  TangoBook
//
//  Created by Shusuke Unno on 2017/07/19.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import Foundation
import UIKit

// YUVの構造体
public struct UYuv{
    var y : CGFloat
    var u : CGFloat
    var v : CGFloat
    
    var description : String {
        get {
            return String(format: "YUV:%f %f %f", y, u, v)
        }
    }
}

/**
 *　カスタマイズしたColorクラス
 */

public class UColor {
    public static let TAG = "UColor"
    public static let Orange : UIColor = makeColor(argb:0xFFFFA500)
    public static let Aqua : UIColor = makeColor(argb:0xFF00FFFF)
    public static let AquaMarine : UIColor = makeColor(argb:0xFF7FFFD4)
    public static let Beige : UIColor = makeColor(argb:0xFFF5F5DC)
    public static let Blue : UIColor = makeColor(argb:0xFF0000FF)
    public static let Brown : UIColor = makeColor(argb:0xFFA52A2A)
    public static let Chocolate  : UIColor = makeColor(argb:0xFFD2691E)
    public static let Coral  : UIColor = makeColor(argb:0xFFFF7F50)
    public static let Cyan  : UIColor = makeColor(argb:0xFF00FFFF)
    public static let DarkBlue  : UIColor = makeColor(argb:0xFF00008B)
    public static let Darkcyan  : UIColor = makeColor(argb:0xFF008B8B)
    public static let DarkGray  : UIColor = makeColor(argb:0xFFA9A9A9)
    public static let DarkGreen  : UIColor = makeColor(argb:0xFF006400)
    public static let DarkOrange  : UIColor = makeColor(argb:0xFFFF8C00)
    public static let DarkRed  : UIColor = makeColor(argb:0xFF8B0000)
    public static let DarkYellow  : UIColor = makeColor(argb:0xFFD7C32A)
    public static let DarkYellow2  : UIColor = makeColor(argb:0xFFD7C32A)
    public static let DarkViolet  : UIColor = makeColor(argb:0xFF9400D3)
    public static let DeepPink  : UIColor = makeColor(argb:0xFF1493)
    public static let Gold  : UIColor = makeColor(argb:0xFFFFD700)
    public static let Gray  : UIColor = makeColor(argb:0xFF808080)
    public static let Green  : UIColor = makeColor(argb:0xFF008000)
    public static let GreenYellow  : UIColor = makeColor(argb:0xFF746508)
    public static let HotPink  : UIColor = makeColor(argb:0xFFFF69B4)
    public static let Indigo  : UIColor = makeColor(argb:0xFF4B0082)
    public static let LightBlue  : UIColor = makeColor(argb:0xFFADD8E6)
    public static let LightCyan  : UIColor = makeColor(argb:0xFFE0FFFF)
    public static let LightGreen  : UIColor = makeColor(argb:0xFF90EE90)
    public static let LightGray  : UIColor = makeColor(argb:0xFFD3D3D3)
    public static let LightPink  : UIColor = makeColor(argb:0xFFFFB6C1)
    public static let LightRed  : UIColor = makeColor(argb:0xFFEE9090)
    public static let LightSalmon  : UIColor = makeColor(argb:0xFFFFA07A)
    public static let LightSkyBlue  : UIColor = makeColor(argb:0xFF87CEFA)
    public static let LightYellow  : UIColor = makeColor(argb:0xFFFFFFE0)
    public static let Lime  : UIColor = makeColor(argb:0xFF00FF00)
    public static let LimeGreen  : UIColor = makeColor(argb:0xFF32CD32)
    public static let Magenta  : UIColor = makeColor(argb:0xFFFF00FF)
    public static let Maroon  : UIColor = makeColor(argb:0xFF800000)
    public static let MidnightBlue  : UIColor = makeColor(argb:0xFF191970)
    public static let Navy  : UIColor = makeColor(argb:0xFF000080)
    public static let Olive  : UIColor = makeColor(argb:0xFF808000)
    public static let OrangeRed  : UIColor = makeColor(argb:0xFFFF4500)
    public static let Purple  : UIColor = makeColor(argb:0xFF800080)
    public static let Red  : UIColor = makeColor(argb:0xFFFF0000)
    public static let Salmon  : UIColor = makeColor(argb:0xFFFA8072)
    public static let SeaGreen  : UIColor = makeColor(argb:0xFF2E8B57)
    public static let SeaShell  : UIColor = makeColor(argb:0xFFFFF5EE)
    public static let Silver  : UIColor = makeColor(argb:0xFFC0C0C0)
    public static let SkyBlue  : UIColor = makeColor(argb:0xFF87CEEB)
    public static let Snow  : UIColor = makeColor(argb:0xFFFFFAFA)
    public static let Tomato  : UIColor = makeColor(argb:0xFFFF6347)
    public static let Violet  : UIColor = makeColor(argb:0xFFEE82EE)
    public static let Wheat  : UIColor = makeColor(argb:0xFFF5DEB3)
    public static let White  : UIColor = makeColor(argb:0xFFFFFFFF)
    public static let Yellow  : UIColor = makeColor(argb:0xFFFFFF00)
    public static let YellowGreen  : UIColor = makeColor(argb:0xFFACD32)
    
    public static let OKButton : UIColor = LightGreen
    
    /**
     * UInt32 の 色から R,G,Bを個別で取得する
     */
    // Rを 0~255 で取得する
    public static func red(_ color : UInt32) -> UInt32 {
        return (color >> 16) & 0xff
    }
    
    // Gを 0~255 で取得する
    public static func green(_ color : UInt32) -> UInt32 {
        return (color >> 8) & 0xff
    }
    
    // Bを 0~255 で取得する
    public static func blue(_ color : UInt32) -> UInt32 {
        return color & 0xff
    }
    
    // rgbをそれぞれ 0~255 で指定して UIColorを生成する
    public static func makeColor(_ ri: UInt32, _ gi: UInt32, _ bi: UInt32) -> UIColor
    {
        return UColor.makeColor( 255, ri, gi, bi )
    }
    
    public static func makeColor(r: CGFloat, g: CGFloat, b: CGFloat) -> UIColor
    {
        return UIColor.init( red: r, green: g, blue: b, alpha: 1.0)
    }
    
    public static func makeColor( _ ai: UInt32, _ ri: UInt32, _ gi: UInt32, _ bi: UInt32) -> UIColor
    {
        return UIColor(red: CGFloat(ri) / 255.0, green: CGFloat(gi) / 255.0, blue: CGFloat(bi) / 255.0, alpha: CGFloat(ai) / 255.0)
    }
    
    // rgbをそれぞれ 0.0 ~ 255.0 で指定して UIColor を生成する
    public static func makeColor2(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat) -> UIColor {
        return UIColor(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: 1.0)
    }
    
    // argb 32bit(r:8bit g:8bit b:8bit a:8bit)の色から UIColor を作成する
    public static func makeColor(argb: UInt32) -> UIColor {
        let a : CGFloat = 1.0 //CGFloat((argb >> 24) & 0xff) / 255.0
        let r = CGFloat((argb >> 16) & 0xff) / 255.0
        let g = CGFloat((argb >> 8) & 0xff) / 255.0
        let b = CGFloat(argb & 0xff) / 255.0
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
    
    // alphaと RGBのUIColorから UIColorを作成する
    public static func makeColor(a: CGFloat, rgb: UIColor) -> UIColor {
        var R : CGFloat = 0.0,G : CGFloat = 0.0,B : CGFloat = 0.0,A : CGFloat = 0.0
        rgb.getRed( &R, green: &G, blue: &B, alpha: &A)
        return UIColor.init(red:R, green:G, blue:B, alpha:a)
    }
    
    
    /**
     * ランダムな色を取得
     * @return
     */
    public static func getRandomColor() -> Int {
        let r = arc4random() % 256
        let g = arc4random() % 256
        let b = arc4random() % 256
//        return Int((0xff << 24) | (r << 16) | (g << 8) | (b))
        return Int((r << 16) | (g << 8) | (b))
    }
    
    /**
     * 文字列に変換する
     * @param color 変換元の色
     * @return 変換後の文字列 (#xxxxxx形式)
     */
    public static func toColorString(color : UInt32) -> String {
        return String(format: "#%06x", color)
    }
    
    /**
     * RGB -> YUV に変換
     */
    public static func RGBtoYUV(_ rgb : UIColor) -> UYuv {
        var R : CGFloat = 0.0, G : CGFloat = 0.0, B : CGFloat = 0.0 ,A : CGFloat = 0.0
        rgb.getRed( &R, green: &G, blue: &B, alpha: &A)
        
        var Y  = CGFloat(0.257 * R + 0.504 * G + 0.098 * B + (16.0 / 256.0))
        var Cb = CGFloat(-0.148 * R - 0.291 * G + 0.439 * B + (128 / 256.0))
        var Cr = CGFloat(0.439 * R - 0.368 * G - 0.071 * B + (128 / 256.0))
        
        if (Y > 1.0) {
            Y = 1.0
        }
        if (Cb > 1.0) {
            Cb = 1.0
        }
        if (Cr > 1.0) {
            Cr = 1.0
        }
        
        return UYuv(y: Y, u: Cb, v: Cr)
    }
    
    // 色が 0~255
    public static func RGBtoYUV(_ pixel : PixelData) -> UYuv {
        var Y  = CGFloat(0.257 * CGFloat(pixel.r) + 0.504 * CGFloat(pixel.g) + 0.098 * CGFloat(pixel.b) + (16.0 / 256.0))
        var Cb = CGFloat(-0.148 * CGFloat(pixel.r) - 0.291 * CGFloat(pixel.g) + 0.439 * CGFloat(pixel.b) + (128 / 256.0))
        var Cr = CGFloat(0.439 * CGFloat(pixel.r) - 0.368 * CGFloat(pixel.g) - 0.071 * CGFloat(pixel.b) + (128 / 256.0))
        
        if (Y > 255) {
            Y = 255
        }
        if (Cb > 255) {
            Cb = 255
        }
        if (Cr > 255) {
            Cr = 255
        }
        
        return UYuv(y: Y, u: Cb, v: Cr)
    }

    
    // 輝度(Y)を指定して色を変更する
    public static func colorWithY(rgb : UIColor, y : CGFloat) -> UIColor {
        var R : CGFloat = 0.0, G : CGFloat = 0.0, B : CGFloat = 0.0 ,A : CGFloat = 0.0
        rgb.getRed(&R, green:&G, blue:&B, alpha:&A)
        
        var Cb = CGFloat(-0.148 * R - 0.291 * G + 0.439 * B + 128)
        var Cr = CGFloat(0.439 * R - 0.368 * G - 0.071 * B + 128)
        
        if (Cb > 1.0) {
            Cb = 1.0
        }
        if (Cr > 1.0) {
            Cr = 1.0
        }
        
        return YUVtoRGB(y:y, u:Cb, v:Cr , a:A)
    }
    public static func colorWithY(pixel : PixelData, y : CGFloat) -> PixelData {
        var Cb = CGFloat(-0.148 * CGFloat(pixel.r) - 0.291 * CGFloat(pixel.g) + 0.439 * CGFloat(pixel.b) + 128)
        var Cr = CGFloat(0.439 * CGFloat(pixel.r) - 0.368 * CGFloat(pixel.g) - 0.071 * CGFloat(pixel.b) + 128)
        
        if (Cb > 255) {
            Cb = 255
        }
        if (Cr > 255) {
            Cr = 255
        }
        
        return YUVtoRGB2(y:y, u:Cb, v:Cr, a: CGFloat(pixel.a))
    }
    
    public static func colorToY(rgb : UInt32) -> UInt32 {
        let R = CGFloat(UColor.red(rgb))
        let G = CGFloat(UColor.green(rgb))
        let B = CGFloat(UColor.blue(rgb))
        
        return UInt32(0.257 * R + 0.504 * G + 0.098 * B + 16)
    }
    
    public static func colorToY(pixel : PixelData) -> UInt32 {
        let R = CGFloat(pixel.r)
        let G = CGFloat(pixel.g)
        let B = CGFloat(pixel.b)
        
        return UInt32(0.257 * R + 0.504 * G + 0.098 * B + 16)
    }
    
    /**
     * YUV -> RGB
     */
    public static func YUVtoRGB(yuv : UYuv, alpha: CGFloat) -> UIColor {
        return YUVtoRGB(y: yuv.y, u: yuv.u, v:yuv.v, a:alpha)
    }
    
    // 色が 0.0~1.0
    public static func YUVtoRGB(y: CGFloat, u: CGFloat, v: CGFloat, a: CGFloat) -> UIColor {
        var R = CGFloat(1.164 * (y - (16.0 / 256.0))
            + 1.596 * (v-(128.0 / 256.0)))
        var G = CGFloat(1.164 * (y-(16.0 / 256.0))
            - 0.391 * (u-(128.0 / 256.0))
            - 0.813 * (v-(128.0 / 256.0)))
        var B = CGFloat(1.164 * (y-(16.0 / 256.0))
            + 2.018 * (u-(128.0 / 256.0)))
        
        if (R > 1.0){ R = 1.0 }
        if (R < 0){ R = 0 }
        if (G > 1.0){ G = 1.0 }
        if (G < 0){ G = 0 }
        if (B > 1.0){ B = 1.0 }
        if (B < 0){ B = 0 }
        
        return UIColor(red: R, green:G, blue:B, alpha: a)
    }
    
    /**
     YUVの色をRGBの色に変換
     - parameter y: 輝度  0~255
     - parameter u: 色差Cr  0~255
     - parameter v: 色差Cb  0~255
     - returns: PixelData
     */
    public static func YUVtoRGB2(y: CGFloat, u: CGFloat, v: CGFloat, a: CGFloat) -> PixelData {
        var R = 1.164 * (y - 16.0)
            + 1.596 * (v - 128.0)
        var G = 1.164 * (y - 16.0)
            - 0.391 * (u - 128.0)
            - 0.813 * (v - 128.0)
        var B = 1.164 * (y - 16.0)
            + 2.018 * (u - 128.0)
        
        if (R > 255){ R = 255 }
        if (R < 0){ R = 0 }
        if (G > 255){ G = 255 }
        if (G < 0){ G = 0 }
        if (B > 255){ B = 255 }
        if (B < 0){ B = 0 }
        
        return PixelData(a: UInt8(a), r: UInt8(R), g: UInt8(G), b: UInt8(B))
    }
    
    
    /**
     * 現在の色(RGB)で輝度のみ変更する
     * @param argb
     * @param brightness 輝度 0:暗い ~ 1.0:明るい
     * @return
     */
    public static func setBrightness(argb : UIColor, brightness : CGFloat) -> UIColor
    {
        ULog.printMsg(TAG, "ARGB:" + argb.description)
        
        var R : CGFloat = 0.0, G : CGFloat = 0.0, B : CGFloat = 0.0 ,A : CGFloat = 0.0
        argb.getRed(&R, green:&G, blue:&B, alpha:&A)
        let yuv1 : UYuv = UColor.RGBtoYUV(argb)
        
        ULog.printMsg(TAG, "YUV:" + yuv1.description)
        
        // 新しい色  元の色のアルファを維持する
        let yuv2 = UYuv(y: brightness, u:yuv1.u, v:yuv1.v )
        let _argb : UIColor = YUVtoRGB(yuv:yuv2, alpha: A)
        
        ULog.printMsg(TAG, "RGB2:" + _argb.debugDescription)
        
        return _argb
    }
    
    /**
     * RGBの輝度を上げる
     * @param argb
     * @param addY  輝度 100% = 1.0 / 50% = 0.5
     * @return
     */
    public static func addBrightness(argb : UIColor, addY : CGFloat) -> UIColor {
        //ULog.printMsg(TAG, String(format: "RGB:%06x", argb))
        
        var yuv = UColor.RGBtoYUV(argb)
        
        var R : CGFloat = 0.0, G : CGFloat = 0.0, B : CGFloat = 0.0 ,A : CGFloat = 0.0
        argb.getRed(&R, green: &G, blue: &B, alpha: &A)
        //ULog.printMsg(TAG, String(format: "YUV:%06x", yuv))
        
        yuv.y += addY
        if (yuv.y > 1.0) {
            yuv.y = 1.0
        }
        else if (yuv.y < 0) {
            yuv.y = 0
        }
        
        // 新しい色  元の色のアルファを維持する
        return YUVtoRGB(yuv: yuv, alpha: A)
    }
    
    /**
     * 2つの色を指定の割合で合成する
     * @param color1
     * @param color2
     * @param ratio  合成比率 0.0 : color1=100%, colo2=0%
     *                      1.0 : color1=0%, color2=100%
     * @return
     */
    public static func mixRGBColor(color1 : UIColor, color2 : UIColor, ratio : CGFloat) -> UIColor
    {
        
        var r1 : CGFloat = 0.0, g1 : CGFloat = 0.0, b1 : CGFloat = 0.0 ,a1 : CGFloat = 0.0
        var r2 : CGFloat = 0.0, g2 : CGFloat = 0.0, b2 : CGFloat = 0.0 ,a2 : CGFloat = 0.0
        
        color1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        color2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        
        var a = a1 * (1.0 - ratio) + a2 * ratio
        if (a > 1.0) { a = 1.0 }
        var r = r1 * (1.0 - ratio) + r2 * ratio
        if (r > 1.0) { r = 1.0 }
        var g = g1 * (1.0 - ratio) + g2 * ratio
        if (g > 1.0) {g = 1.0}
        var b = b1 * (1.0 - ratio) + b2 * ratio
        if (b > 1.0) { b = 1.0 }
        
        return UIColor(red:r, green:g, blue:b, alpha:a)
    }
    
    /**
     * colorを文字列(0xaarrggbb)に変換する
     * @param color
     * @return
     */
    public static func toString(color : UIColor) -> String {
        var R : CGFloat = 0.0, G : CGFloat = 0.0, B : CGFloat = 0.0 ,A : CGFloat = 0.0
        
        color.getRed(&R, green:&G, blue:&B, alpha:&A)
        
        return String(format: "0x%02x%02x%02x%02x", A*255,R*255,G*255,B*255)
    }
}
