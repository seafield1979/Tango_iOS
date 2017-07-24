//
//  UDraw.swift
//  UGui
//    UIViewへのプリミティブ描画関連の処理
//    プリミティブ描画は ラインや四角形、円等の基本図形のこと
//  Created by Shusuke Unno on 2017/07/07.
//  Copyright © 2017年 Shusuke Unno. All rights reserved.
//

import Foundation
import UIKit

// フォントのサイズ
public enum FontSize : Int {
    case S      // small
    case M      // medium
    case L      // large
}


class UDraw {
    
    // フォントのサイズ
    public static func getFontSize(_ size: FontSize) -> Int {
        var _size : Int
        switch (size) {
        case .S:
            _size = 10
        case .M:
            _size = 13
        case .L:
            fallthrough
        default:
            _size = 17
        }
        return Int(UDpi.toPixel(_size))
    }
    
    // 360度の角度をラジアン角に変換する用
    static let RADIAN : CGFloat = CGFloat.pi / 180.0
    
    // ラインを描画
    public static func drawLine(x1: CGFloat, y1: CGFloat, x2: CGFloat, y2: CGFloat, lineWidth : CGFloat, color :UIColor)
    {
        // UIBezierPath のインスタンス生成
        let path = UIBezierPath()
        
        // 起点
        path.move(to: CGPoint(x: x1, y: y1))
        // 終点
        path.addLine(to: CGPoint(x: x2, y: y2))
        
        // 線の太さ
        path.lineWidth = lineWidth
        // 線の色
        color.setStroke()
        // 描画
        path.stroke()
    }
    
    // 指定の点を繋ぐパスを描画
    public static func drawPath(_ points : [CGPoint], lineWidth: CGFloat, color: UIColor, closeLine : Bool )
    {
        // UIBezierPath のインスタンス生成
        let line = UIBezierPath()
        
        if points.count < 2 {
            return
        }
        
        for i in 0...points.count - 1 {
            let point = points[i]
            if i == 0 {
                // 起点
                line.move(to: point)
            } else {
                line.addLine(to: point)
            }
        }
        // 始点と終点を結ぶ
        if closeLine {
            line.close()
        }
        
        // 色の設定
        color.setStroke()
        // ライン幅
        line.lineWidth = lineWidth
        // 描画
        line.stroke()
    }
    
    // 指定の点を繋ぐパスを描画
    public static func drawPathFill(_ points : [CGPoint], color: UIColor )
    {
        // UIBezierPath のインスタンス生成
        let line = UIBezierPath()
        
        if points.count < 2 {
            return
        }
        
        for i in 0...points.count - 1 {
            let point = points[i]
            if i == 0 {
                // 起点
                line.move(to: point)
            } else {
                line.addLine(to: point)
            }
        }
        // 始点と終点を結ぶ
        line.close()
        
        // 色の設定
        color.setFill()
        
        // 描画
        line.fill()
    }
    
    // 矩形(ライン)を描画
    public static func drawRect(rect : CGRect, width: CGFloat, color: UIColor)
    {
        let path = UIBezierPath(rect: rect)
        // stroke 色の設定
        color.setStroke()
        // ライン幅
        path.lineWidth = width
        // 描画
        path.stroke()
    }
    
    // 矩形（角丸）
    public static func drawRoundRect(rect: CGRect, width: CGFloat, radius : CGFloat, color : UIColor)
    {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners:.allCorners, cornerRadii: CGSize(width:radius, height:radius))
        
        // stroke 色の設定
        color.setStroke()
        // ライン幅
        path.lineWidth = width
        // 描画
        path.stroke()
    }
    
    // 矩形(塗りつぶし)
    public static func drawRectFill(rect: CGRect, color: UIColor)
    {
        let path = UIBezierPath(rect: rect)
        
        // 塗りつぶしの色を設定
        color.setFill()
        
        // 塗りつぶし
        path.fill()
    }
    
    // 矩形(塗りつぶし＆枠)
    public static func drawRectFill(rect: CGRect, color: UIColor, strokeWidth: CGFloat, strokeColor: UIColor?)
    {
        let path = UIBezierPath(rect: rect)
        
        // 枠の色
        if strokeColor != nil {
            strokeColor!.setStroke()
        }
        
        // 塗りつぶしの色を設定
        color.setFill()
        
        // 塗りつぶし
        path.fill()
        
        // 枠描画
        if strokeColor != nil {
            path.stroke()
        }
    }
    
    /**
     角丸四角形(塗りつぶし＆角丸)
     - parameter rect: 塗りつぶし矩形座標
     - parameter cornerR: 角の半径
     - parameter color: 塗りつぶしの色
     - parameter strokeWidth: 枠の太さ
     - parameter strokeColor: 枠の色
     */
    public static func drawRoundRectFill(rect: CGRect, cornerR: CGFloat, color: UIColor, strokeWidth: CGFloat, strokeColor: UIColor?)
    {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners:.allCorners, cornerRadii: CGSize(width:cornerR, height:cornerR))
        // 塗りつぶし色
        color.setFill()
        
        // 枠の色
        if strokeColor != nil {
            strokeColor!.setStroke()
        }
        
        // 塗りつぶし
        path.fill()
        
        // 枠
        if strokeColor != nil {
            path.stroke()
        }
    }
    
    //  円描画(線)
    public static func drawCircle(x: CGFloat, y: CGFloat, radius: CGFloat, lineWidth: CGFloat, color: UIColor )
    {
        let path = UIBezierPath(ovalIn: CGRect(x: x, y: y, width: radius * 2, height: radius * 2))
        
        // stroke 色の設定
        color.setStroke()
        
        // ライン幅
        path.lineWidth = lineWidth
        
        // 描画
        path.stroke()
    }
    
    // 円描画(線、中心座標を指定)
    public static func drawCircle(center: CGPoint, radius: CGFloat, lineWidth: CGFloat, color: UIColor )
    {
        drawCircle(x: center.x - radius, y: center.y - radius, radius: radius, lineWidth: lineWidth, color: color)
    }
    
    // 円描画(塗りつぶし)
    public static func drawCircleFill(x: CGFloat, y: CGFloat, radius: CGFloat, color: UIColor)
    {
        let path = UIBezierPath(ovalIn: CGRect(x: x, y: y, width: radius * 2, height: radius * 2))
        
        // 塗りつぶし色の設定
        color.setFill()
        // 内側の塗りつぶし
        path.fill()
    }
    
    // 円描画（塗りつぶし、中心座標を指定）
    public static func drawCircleFill(center: CGPoint, radius: CGFloat, color: UIColor)
    {
        drawCircleFill(x: center.x - radius, y: center.y - radius, radius: radius, color: color)
    }
    
    // 座標確認用の＋を描画
    public static func drawCheck(x: CGFloat, y: CGFloat, color : UIColor)
    {
        let width : CGFloat = 30.0
        drawLine(x1: x - width / 2, y1: y, x2: x + width / 2, y2: y, lineWidth: 3, color: color)
        drawLine(x1: x, y1: y - width / 2, x2: x, y2: y + width / 2, lineWidth: 3, color: color)
    }
    
    //三角形描画(線)
    public static func drawTriangle(center: CGPoint, radius: CGFloat, rotation: CGFloat, lineWidth: CGFloat, color: UIColor)
    {
        drawTriangleCore(center: center, radius: radius, rotation: rotation, color: color, fill: false)
    }
    
    // 三角形描画(塗りつぶし)
    // 基本は▲、これを回転できる
    public static func drawTriangleFill(center: CGPoint, radius: CGFloat, rotation: CGFloat, color: UIColor)
    {
        drawTriangleCore(center: center, radius: radius, rotation: rotation, color: color, fill: true)
    }
    
    public static func drawTriangleCore(center: CGPoint, radius: CGFloat, rotation: CGFloat, color: UIColor, fill : Bool)
    {
        // 三角形 -------------------------------------
        // 三角形の中心から 90度,210度,330度の点を結ぶ
        // UIBezierPath のインスタンス生成
        let path = UIBezierPath();
        // 起点
        path.move(to: CGPoint(x: center.x + radius * cos((90 + rotation) * RADIAN),
                              y: center.y - radius * sin((90 + rotation) * RADIAN)));
        
        // 帰着点
        // スクリーン座標系と三角関数の座標系はyの方向が逆なのでマイナス
        path.addLine(to: CGPoint(x: center.x + radius * cos((210 + rotation) * RADIAN),
                                 y: center.y - radius * sin((210 + rotation) * RADIAN)));
        path.addLine(to: CGPoint(x: center.x + radius * cos((330 + rotation) * RADIAN),
                                 y: center.y - radius * sin((330 + rotation) * RADIAN)));
        // ラインを結ぶ
        path.close()
        
        if fill {
            // 塗りつぶし
            // 色を設定
            color.setFill()
            
            path.fill()
        } else {
            // 線を描画
            // 色の設定
            color.setStroke()
            // ライン幅
            path.lineWidth = 4
            // 描画
            path.stroke();
        }
    }
    
    // テキストを描画する
    // アライメントは自前で計算している
    public static func drawText(text: String,alignment: UAlignment, textSize: Int, x: CGFloat, y: CGFloat, color: UIColor )
    {
        // 文字描画時に反映される影の指定
//        let shadow = NSShadow()
//        shadow.shadowOffset = CGSize(width:2, height:2)
//        shadow.shadowColor = UIColor.white
//        shadow.shadowBlurRadius = 0
        
        // 文字描画に使用するフォントの指定
        let font = UIFont.boldSystemFont(ofSize:CGFloat(textSize))
        
        // パラグラフ関連の情報の指定
        let style = NSMutableParagraphStyle()
        style.alignment = NSTextAlignment.left
        style.lineBreakMode = NSLineBreakMode.byClipping
        
        let textFontAttributes = [
            NSFontAttributeName: font,
            NSParagraphStyleAttributeName: style,
//            NSShadowAttributeName: shadow,
            NSForegroundColorAttributeName: color,
            NSBackgroundColorAttributeName: UIColor.clear
            ] as [String : Any]
        
        let size = text.size(attributes: [NSFontAttributeName : font])
        
        // アライメント
        var _x : CGFloat
        var _y : CGFloat
        switch alignment {
        case .None:
            _x = x
            _y = y
        case .CenterX:
            _x = x - size.width / 2
            _y = y
        case .CenterY:
            _x = x
            _y = y - size.height / 2
        case .Center:
            _x = x - size.width / 2
            _y = y - size.height / 2
        case .Left:
            _x = x
            _y = y
        case .Right:
            _x = x - size.width
            _y = y
        case .Right_CenterY:
            _x = x - size.width
            _y = y - size.height / 2
        }
        
        text.draw(in: CGRect(x:_x,
                             y:_y, width: size.width,
                             height:size.height),
                  withAttributes: textFontAttributes)
    }
    
    
    // テキストの描画サイズを取得する
    public static func getTextSize(text: String, textSize: Int) -> CGSize
    {
        // 文字描画に使用するフォントの指定
        let font = UIFont.boldSystemFont(ofSize:CGFloat(textSize))
        
        return text.size(attributes: [NSFontAttributeName : font])
    }
    
    // UIImage描画
    // 画像をそのままのサイズで描画
    public static func drawImage(image: UIImage, x: CGFloat, y: CGFloat)
    {
        //    image.draw(at: CGPoint(x:x, y:y))
        image.draw(at: CGPoint(x:x, y:y), blendMode: CGBlendMode.sourceAtop, alpha: 0.5)
    }
    
    // UIImage描画
    // 描画座標とサイズを指定
    public static func drawImage(image: UIImage,
                                 x:CGFloat, y:CGFloat, width:CGFloat, height: CGFloat)
    {
        image.draw(in: CGRect(x:x, y:y, width:width, height:height))
    }
    
    // UIImage描画
    // 描画座標とサイズを CGRectで指定
    public static func drawImage(image: UIImage, rect: CGRect)
    {
        image.draw(in: rect)
    }
    
    // アルファを指定して描画
    public static func drawImageWithBlend(image : UIImage, rect: CGRect, alpha : CGFloat)
    {
        image.draw(in: rect, blendMode: CGBlendMode.sourceAtop, alpha: alpha)
    }
    
    // 元画像を切り抜いて描画
    public static func drawImageWithCrop(image: UIImage,
                                         srcRect: CGRect,
                                         dstRect: CGRect)
    {
        // 切り抜いた画像を作成
        let image2 = UDraw.cropImage(image: image, cropRect: srcRect)
        
        // 切り抜いた画像を描画
        image2.draw(in: dstRect)
    }
    
    // 一部分を切り抜いた画像を取得
    public static func cropImage(image: UIImage, cropRect : CGRect) -> UIImage
    {
        let srcRect = CGRect(x:0,y:0,width: image.size.width, height:image.size.height)
        
        // 切り抜き領域が元画像をはみ出していたら修正
        var _cropRect = cropRect
        if cropRect.origin.x + cropRect.size.width > srcRect.size.width {
            _cropRect.size.width = srcRect.size.width - cropRect.origin.x
        }
        if cropRect.origin.y + cropRect.size.height > srcRect.size.height {
            _cropRect.size.height = srcRect.size.height - cropRect.origin.y
        }
        
        // resizeImage にリサイズ済みの画像を生成する
        UIGraphicsBeginImageContext(srcRect.size);
        image.draw(in: CGRect(x:0, y:0, width:image.size.width, height:image.size.height))
        let resizedImage : UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        
        // 切り抜き処理
        let cgImage : CGImage = resizedImage!.cgImage!
        let cropedRef   = cgImage.cropping(to: _cropRect)
        let cropedImage = UIImage.init(cgImage: cropedRef!)
        
        UIGraphicsEndImageContext()
        
        return cropedImage
    }
}
