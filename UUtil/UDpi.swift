//
//  UDpi.swift
//  UGui
//
//  Created by Shusuke Unno on 2017/07/11.
//  Copyright © 2017年 Shusuke Unno. All rights reserved.
//

import Foundation
import UIKit

/**
 * Created by shutaro on 2017/06/22.
 *
 * 端末ごとのDPI(Dot per Inchi)を計算するクラス
 * 端末毎に1pixあたりのサイズ(DPI)が異なるので、全ての端末で同じピクセルで
 * 描画を行うと、高解像度端末では小さく、程解像度では大きく表示されてしまう。
 * この表示のズレを補正するために、描画前に補正値をかけてあげる。
 */

public class UDpi {
    /**
     * Enums
     */
    public enum Scale : Int, EnumEnumerable{
        case None
        case S50
        case S67
        case S75
        case S80
        case S90
        case S100
        case S110
        case S125
        case S150
        case S175
        case S200
        case S250
        case S300
        
        static let mapper: [Scale: CGFloat] = [
            .S50 : 0.5,
            .S67 : 0.67,
            .S75 : 0.75,
            .S80 : 0.80,
            .S90 : 0.90,
            .S100 : 1.00,
            .S110 : 1.10,
            .S125 : 1.25,
            .S150 : 1.50,
            .S175 : 1.75,
            .S200 : 2.00,
            .S250 : 2.50,
            .S300 : 3.00
        ]

        // floatのスケールを返す
        func getScale() -> CGFloat {
            return Scale.mapper[self]!
        }
        // 次の列挙値に変更
        mutating func next() {
            if self.rawValue < Scale.count - 1 {
                self = Scale.cases[self.rawValue + 1]
            }
        }
        // 前の列挙値に変更
        mutating func prev() {
            if self.rawValue > 0 {
                self = Scale.cases[self.rawValue - 1]
            }
        }

        // スケールアップ
        mutating func scaleUp() -> Scale {
            if self.rawValue < Scale.count - 1 {
                self = Scale.cases[self.rawValue + 1]
            }
            return self
        }
        
        // スケールダウン
        mutating func scaleDown() -> Scale {
            if self.rawValue > 0 {
                self = Scale.cases[self.rawValue - 1]
            }
            return self
        }
    }
    
    
    /**
     * Constants
     */
    public static let BASE_DPI : CGFloat = 326.0       // ベースのdpiは Android開発時にベースとなった160dpi
    
    /**
     * Variables
     */
    // dpi補正値
    // プログラムないの座標にこの補正値をかけて求めた座標に描画を行う
    public static var dpiToPixel : CGFloat = 0.0
    public static var dpiToPixelBase : CGFloat = 0.0
    public static var mScale : Scale = .S100       // スケール種類
    
    /**
     * Methods
     */
    public static func initialize() {
        // リソースから取得する (要 Context)
        let dpi : CGFloat = 326.0
        
        dpiToPixelBase = dpi / BASE_DPI    // 例: 480 / 160 = 3.0
        
        // スケールが設定されていたら読み込む
        let scaleInt = MySharedPref.readInt(key: MySharedPref.ScaleKey);
        if scaleInt != nil && scaleInt! != 0 {
            mScale = Scale.cases[scaleInt!]
        } else {
            mScale = Scale.S100;
        }
        dpiToPixel = dpiToPixelBase * mScale.getScale();
    }
    
    /**
     * スケールを変更
     * @param scale
     */
    public static func setScale(scale : Scale) {
        if scale != mScale {
            mScale = scale
            
            // DPI補正値を再計算
            dpiToPixel = dpiToPixelBase * mScale.getScale()
            // 保存
            MySharedPref.writeInt(key: MySharedPref.ScaleKey, value: scale.rawValue)
        }
    }
    
    public static func scaleUp() {
        setScale(scale: mScale.scaleUp())
    }
    
    public static func scaleDown() {
        setScale(scale: mScale.scaleDown())
    }
    
    public static func getScaleText() -> String {
        return String(format: "Zoom %3d", Int(mScale.getScale() * 100)) + "%";
    }
    
    /**
     * DPI座標をピクセル座標に変換する。どの端末でも同じ大きさに見えるように補正をかける。
     * また、ズーム補正もかける
     * @param dpi
     * @return
     */
    public static func toPixel(_ dpi : Int) -> CGFloat {
        return CGFloat(dpi) * dpiToPixel
    }
}
