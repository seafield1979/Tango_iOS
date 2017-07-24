//
//  UTextView.swift
//  UGui
//
//  Created by Shusuke Unno on 2017/07/08.
//  Copyright © 2017年 Shusuke Unno. All rights reserved.
//

import Foundation
import UIKit

/**
 * テキストを表示する
 */
public class UTextView : UDrawable {
    /**
     * Constracts
     */
    // BGを描画する際の上下左右のマージン
    static let MARGIN_H : Int = 10
    static let MARGIN_V : Int = 5
    
    static let DEFAULT_TEXT_SIZE : Int = 17
    static let DEFAULT_COLOR : UIColor = UIColor.black
    static let DEFAULT_BG_COLOR : UIColor = UIColor.white
    
    /**
     * Member variables
     */
    var text : String
    var alignment : UAlignment
    var mMargin : CGSize = CGSize()
    var textSize : Int = 0
    var bgColor : UIColor? = nil
    var multiLine : Bool = false      // 複数行表示する
    
    var isDrawBG : Bool = false
    var isOpened : Bool = false     // 全部表示状態
    
    /**
     * Get/Set
     */
    public func getText() -> String {
        return text
    }
    public func setText(text : String) {
        self.text = text;
        
        // サイズを更新
        let size : CGSize = getTextSize()
        if (isDrawBG) {
            setSize(size.width + mMargin.width * 2, size.height + mMargin.height * 2)
        } else {
            setSize(size.width, size.height)
        }
        updateRect()
    }
    
    public func setMargin(_ width : CGFloat, _ height : CGFloat) {
        mMargin.width = width
        mMargin.height = height
        updateSize()
    }
    
    /**
     * Constructor
     */
    public init(text : String, textSize : Int, priority : Int,
                          alignment : UAlignment,
                          multiLine : Bool, isDrawBG : Bool, marginH : Bool,
                          x : CGFloat, y : CGFloat,
                          width : CGFloat,
                          color : UIColor, bgColor : UIColor?)
    {
        self.text = text
        self.alignment = alignment
        self.multiLine = multiLine
        self.isDrawBG = isDrawBG
        self.textSize = textSize
        
        super.init( priority: priority, x: x, y: y, width: width, height: CGFloat(textSize))

        self.color = color
        self.bgColor = bgColor

        // テキストを描画した時のサイズを取得
        if (width == 0) {
            size = getTextSize()
        }
        mMargin = CGSize(width: UDpi.toPixel(UTextView.MARGIN_H),
                         height: UDpi.toPixel(UTextView.MARGIN_V))
        
        updateSize()
    }
    
    public static func createInstance(text: String, textSize : Int, priority : Int,
                                      alignment : UAlignment, 
                                      multiLine : Bool, isDrawBG : Bool,
                                      x: CGFloat, y: CGFloat,
                                      width : CGFloat,
                                      color : UIColor, bgColor : UIColor?) -> UTextView
    {
        let instance = UTextView(text: text,
                             textSize: textSize,
                             priority: priority,
                             alignment: alignment,
                             multiLine : multiLine,
                             isDrawBG : isDrawBG,
                             marginH: true,
                             x: x, y: y,
                             width: width,
                             color: color, bgColor: bgColor)
        
        return instance
    }
    
    // シンプルなTextViewを作成
    public static func createInstance(text : String, priority : Int,
                                      canvasW : Int, isDrawBG : Bool,
                                      x : CGFloat, y : CGFloat) -> UTextView
    {
        let instance = UTextView(text:text,
                                 textSize: UTextView.DEFAULT_TEXT_SIZE,
                                 priority:priority,
                                 alignment: UAlignment.None,
                                 multiLine: false,
                                 isDrawBG: isDrawBG,
                                 marginH: true,
                                 x:x, y:y,
                                 width: 0,
                                 color: DEFAULT_COLOR, bgColor: DEFAULT_BG_COLOR)
        return instance
    }
    
    /**
     * Methods
     */
    
    func updateSize() {
        var size : CGSize = getTextSize()
        if (isDrawBG) {
            size = addBGPadding(size)
        }
        setSize(size.width, size.height)
    }
    
    /**
     * テキストを囲むボタン部分のマージンを追加する
     * @param size
     * @return マージンを追加した Size
     */
    func addBGPadding(_ size : CGSize) -> CGSize{
        var size = size
        size.width += mMargin.width * 2
        size.height += mMargin.height * 2
        return size
    }
    
    
    /**
     * 描画処理
     * @param canvas
     * @param paint
     * @param offset 独自の座標系を持つオブジェクトをスクリーン座標系に変換するためのオフセット値
     */
    public override func draw(_ offset : CGPoint?) {
        var _pos = CGPoint(x:pos.x, y:pos.y)
        if (offset != nil) {
            _pos.x += offset!.x
            _pos.y += offset!.y
        }
        let _linePos = CGPoint(x:_pos.x, y:_pos.y)
        
        var _alignment : UAlignment = alignment
        
        if (isDrawBG) {
            var bgPos = CGPoint(x:_pos.x, y:_pos.y)
            switch (alignment) {
            case .CenterX:
                bgPos.x -= size.width / 2
                _pos.y += mMargin.height
            case .CenterY:
                _pos.x += mMargin.height
                bgPos.y -= size.height / 2
            case .Center:
                bgPos.x -= size.width / 2
                bgPos.y -= size.height / 2
            case .None:
                _pos.x += mMargin.width
                _pos.y += mMargin.height
            case .Right:
                bgPos.x -= size.width
                _pos.x -= mMargin.width
                _pos.y += mMargin.height
            case .Right_CenterY:
                bgPos.x -= size.width
                _pos.x -= mMargin.width
                bgPos.y -= size.height / 2
            default:
                break
            }
            
            if (!multiLine) {
                if (alignment == UAlignment.CenterX ||
                    alignment == UAlignment.None ||
                    alignment == UAlignment.Right)
                {
                    _pos.y += CGFloat(textSize) / 2.0
                }
            }
            
            // Background
            if (isDrawBG && bgColor != nil) {
                drawBG(bgPos)
            }
            
            // BGの中央にテキストを表示したいため、aligmentを書き換える
            if (!multiLine) {
                switch (alignment) {
                case .CenterX:
                    _alignment = UAlignment.Center
                    
                case .None:
                    _alignment = UAlignment.CenterY
                    
                case .Right:
                    _alignment = UAlignment.Right_CenterY
                default:
                    break
                }
            }
        }
//        if (multiLine) {
            UDraw.drawText( text: text, alignment: _alignment, textSize: textSize,
                            x: _pos.x, y: _pos.y, color: color!)
//        } else {
//            UDraw.drawTextOneLine( text, _alignment, textSize,
//                                  _pos.x, _pos.y,
//                                  color);
//        }
        
        // x,yにラインを表示 for Debug
        if (UDebug.drawTextBaseLine) {
            UDraw.drawCheck(x: _linePos.x,y: _linePos.y,color: UIColor.red)
        }
    }
    
    /**
     * 背景色を描画する
     * @parameter pos : 描画位置
     */
    func drawBG(_ pos : CGPoint) {
        UDraw.drawRoundRectFill(rect: CGRect(x: pos.x, y:pos.y,
                                width: size.width,
                                height: size.height),
                                cornerR: UDpi.toPixel(7), color: bgColor!,
                                strokeWidth: 0, strokeColor: nil)
    }
    
    /**
     * テキストのサイズを取得する（マルチライン対応）
     * @param canvasW
     * @return
     */
    public func getTextSize() -> CGSize {
        return UDraw.getTextSize(text: text, textSize: textSize)
    }
    
    /**
     * 矩形を取得
     * @return
     */
    public override func getRect() -> CGRect {
        return CGRect(x:pos.x, y:pos.y, width: size.width, height: size.height)
    }
    
    /**
     * タッチ処理
     * @param vt
     * @return
     */
    public func touchEvent(vt : ViewTouch) -> Bool {
        return self.touchEvent(vt: vt, offset: nil)
    }
    
    public override func touchEvent(vt : ViewTouch, offset : CGPoint?) -> Bool {
        if (vt.type == TouchType.Touch) {
            
            var offset = offset // メソッドに仮引数はletなのでvarで再定義
            if (offset == nil) {
                offset = CGPoint()
            }
            let point = CGPoint(x: vt.touchX(offset: offset!.x), y: vt.touchY(offset: offset!.y))
            
            if self.rect!.contains(point) {
                isOpened = !isOpened
                return true
            }
        }
        return false
    }
}
