//
//  UIImage+ex.swift
//  TangoBook
//    UIImageの拡張
//  Created by Shusuke Unno on 2017/07/27.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import UIKit

// 画像の１画素の情報
public struct PixelData {
    var a: UInt8 = 0    // alpha
    var r: UInt8 = 0    // red
    var g: UInt8 = 0    // green
    var b: UInt8 = 0    // blue
    
    // 32bit整数の形式に変換
    func intColor() -> Int {
        return Int(a<<24) | Int(r<<16) | Int(g<<8) | Int(b)
    }
    
    // 白かどうかの判定
    func isWhite() -> Bool {
        if r == 255 && g == 255 && b == 255 {
            return true
        }
        return false
    }
}


extension UIImage {
    func getWidth() -> CGFloat {
        return self.size.width
    }
    
    func getHeight() -> CGFloat {
        return self.size.height
    }
    
    /**
     UIImageからARGBの画素配列を取得する
     */
    func pixelData() -> [PixelData]? {
        let size = self.size
        let dataSize = size.width * size.height * 4
        var pixelData = [UInt8](repeating: 0, count: Int(dataSize))
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: &pixelData,
                                width: Int(size.width),
                                height: Int(size.height),
                                bitsPerComponent: 8,
                                bytesPerRow: 4 * Int(size.width),
                                space: colorSpace,
                                bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue)
        guard let cgImage = self.cgImage else { return nil }
        context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        var pixels : [PixelData] = []
        
        var i = 0
        for _ in 0..<Int(size.height) {
            for _ in 0..<Int(size.width) {
                pixels.append(PixelData( a:pixelData[i+0], r:pixelData[i+1], g:pixelData[i+2], b:pixelData[i+3]))
                i += 4
            }
        }
        return pixels
    }
    
    /**
     ARGBの画素配列からUIImageを生成する
     */
    static func imageFromBitmap(pixels: [PixelData], width: Int, height: Int) -> UIImage?
    {
        assert(width > 0)
        assert(height > 0)
        
        let pixelDataSize = MemoryLayout<PixelData>.size
        
        assert(pixelDataSize == 4)
        assert(pixels.count == Int(width * height))
        
        let data: Data = pixels.withUnsafeBufferPointer {
            return Data(buffer: $0)
        }
        
        let cfdata = NSData(data: data) as CFData
        let provider: CGDataProvider! = CGDataProvider(data: cfdata)
        if provider == nil {
            print("CGDataProvider is not supposed to be nil")
            return nil
        }
        let cgimage: CGImage! = CGImage(
            width: width,
            height: height,
            bitsPerComponent: 8,
            bitsPerPixel: 32,
            bytesPerRow: width * pixelDataSize,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue),
            provider: provider,
            decode: nil,
            shouldInterpolate: true,
            intent: .defaultIntent
        )
        if cgimage == nil {
            print("CGImage is not supposed to be nil")
            return nil
        }
        return UIImage(cgImage: cgimage)
    }
}
