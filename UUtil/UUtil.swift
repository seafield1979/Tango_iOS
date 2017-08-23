//
//  UUtil.swift
//  UGui
//      便利関数
//  Created by Shusuke Unno on 2017/07/08.
//  Copyright © 2017年 Shusuke Unno. All rights reserved.
//

import Foundation
import UIKit

public enum ConvDateMode {
    case Date
    case DateTime
}

public class UUtil {
    public static let RAD : CGFloat = 3.1415 / 180.0
    
    public static var _naviBarHeight : CGFloat = 0
    
    // 初期化処理
    // NavigationController生成時に１回呼び出す
    public static func initialize(navigationC: UINavigationController) {
        // ナビゲーションバーの高さを計算する
        _naviBarHeight = navigationC.navigationBar.frame.size.height
    }
    
    // ステータスバーの高さ
    public static func statusBarHeight() -> CGFloat {
        return  UIApplication.shared.statusBarFrame.size.height
    }
    
    // ナビゲーションバーの高さ
    public static func navigationBarHeight() -> CGFloat {
        return _naviBarHeight
    }
    
    //スクリーンの幅
    public static func screenWidth() -> CGFloat {
        return UIScreen.main.bounds.size.width
    }
    
    //スクリーンの高さ
    public static func screenHeight() -> CGFloat {
        return UIScreen.main.bounds.size.height
    }

    // ステータスバーとナビゲーションバーの高さを引いたスクリーンの高さ
    public static func topViewHeight() -> CGFloat {
        return UUtil.screenHeight() - UUtil.navigationBarHeight() - UUtil.statusBarHeight()
    }
    

    /**
     * sinテーブルの0->90度の 0.0~1.0 の値を取得する
     *
     * @param ratio  0.0 ~ 1.0
     * @return 0.0 ~ 1.0
     */
    public static func toAccel(ratio : CGFloat) -> CGFloat {
        return sin(ratio * 90.0 * UUtil.RAD)
    }
    
    /**
     * 1.0 - cosテーブルの0->90度 の0.0~1.0の値を取得する
     * @param ratio
     * @return
     */
    public static func toDecel(ratio : CGFloat) -> CGFloat {
        return 1.0 - cos(ratio * 90.0 * UUtil.RAD);
    }
    
    /**
     * Bitmapをグレースケール（灰色）に変換する
     * @param bmp
     * @return
     */
    public static func convToGrayImage(image : UIImage) -> UIImage {
    // グレースケール変換
//    int height = bmp.getHeight();
//    int width  = bmp.getWidth();
//    int size   = height * width;
//    int pix[]  = new int[size];
//    int pos = 0;
//    bmp.getPixels(pix, 0, width, 0, 0, width, height);
//    for (int y = 0; y < height; y++) {
//    for (int x = 0; x < width; x++) {
//    int pixel = pix[pos];
//    int red   = (pixel & 0x00ff0000) >> 16;
//    int green = (pixel & 0x0000ff00) >> 8;
//    int blue  = (pixel & 0x000000ff);
//    int alpha = (pixel & 0xff000000) >> 24;
//    int gray  = (red + green + blue) / 3;
//    pix[pos] = Color.argb(alpha, gray, gray, gray);
//    pos++;
//    }
//    }
//    Bitmap newBmp = Bitmap.createBitmap(pix, 0, width, width, height,
//    Bitmap.Config.ARGB_8888);
//    
//    return newBmp;
        return image
    }
    
    /**
     * 単色Bitmap画像の色を変更する
     * 元の画像はグレースケール限定
     */
    public static func convImageColor(image : UIImage, newColor : UIColor) -> UIImage {
        // グレースケール変換
        var pix = image.pixelData()
        let _newPixColor = newColor.toPixelColor()
        let width : Int = Int(image.size.width)
        let height : Int = Int(image.size.height)
        let size : Int = width * height
        var pos : Int = 0
        var colorConvTbl : [PixelData?] = Array(repeating: nil, count: 256)
        
        for _ in 0 ..< size {
            let pixel : PixelData = pix![pos]
            
            // 白はそのまま
            if pixel.isWhite() {
                pix![pos] = pixel
            } else {
                // 輝度(明るさ)を元に新しい色を求める。すでに同じ輝度で計算していたら結果をテーブルから取得する
                let _y = Int(UColor.colorToY(pixel: pixel))
                if pixel.a != 0 && colorConvTbl[_y] == nil {
                    colorConvTbl[_y] =
                        UColor.colorWithY(pixel: _newPixColor, y: CGFloat(_y))
                }
                // アルファは元々の値を使用する
                if pixel.a != 0 && colorConvTbl[_y] != nil {
                    pix![pos].r = colorConvTbl[_y]!.r
                    pix![pos].g = colorConvTbl[_y]!.g
                    pix![pos].b = colorConvTbl[_y]!.b
                }
            }
            pos += 1
        }
        
        let newImage = UIImage.imageFromBitmap(pixels: pix!, width: width, height: height)
        
        return newImage!
    }
    
    /**
     * 日付(Date)のフォーマット変換
     * @param date
     * @return
     */
    public static func convDateFormat(date : Date, mode : ConvDateMode) -> String {
//        if (date == null) return null;
//    
//        final DateFormat df;
//        
//        if (mode == ConvDateMode.Date) {
//        df = new SimpleDateFormat(UResourceManager.getStringById(R
//        .string.date_format2));
//        } else {
//        df = new SimpleDateFormat(UResourceManager.getStringById(R
//        .string.datetime_format2));
//        }
//        return df.format(date);
        return ""
    }
    
    /**
     * 表示するためのテキストに変換（改行なし、最大文字数制限）
     * @param text
     * @return
     */
    public static func convString(text : String?, cutNewLine : Bool, maxLines : Int, maxLength : Int) -> String?
    {
        if text == nil {
            return nil
        }
        // 改行を除去
        var _text = text!
        
        if (cutNewLine) {
            _text = _text.replacingOccurrences(of: "\n", with: "")
        }
        
        // 最大行数
        if (maxLines > 0) {
            // 行分解
            
            let lines = _text.components(separatedBy: "\n")
            if lines.count > maxLines {
                var strBuf : String = ""
                var isFirst = true
                for line : String in lines {
                    if isFirst {
                        isFirst = false
                    } else {
                        strBuf.append("\n")
                    }
                    strBuf.append(line);
                }
                _text = strBuf
            }
        }
        
        // 最大文字数制限
        if maxLength > 0 && _text.characters.count > maxLength {
            return _text.substring(to: _text.index(_text.startIndex, offsetBy: maxLength - 1))
        }
        return _text
    }
    
    // 外部ストレージのDocumentsフォルダのパスを取得する
    public static func getDocumentDirPath() -> String {
        let dir = NSSearchPathForDirectoriesInDomains( FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true ).first
        if dir != nil {
            return dir!
        }
        return ""
    }
    
    /**
     *
     * @param pathType
     * @return
     */
//    public static File getPath(Context mContext, FilePathType pathType) {
//    }
}
