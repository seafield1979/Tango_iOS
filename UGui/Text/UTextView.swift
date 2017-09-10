//
//  UTextView.swift
//  UGui
//      テキストを表示するオブジェクト
//      アライメントや背景を指定することができる
//  Created by Shusuke Unno on 2017/07/08.
//  Copyright © 2017年 Shusuke Unno. All rights reserved.
//

import SpriteKit

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
    
    static let DEFAULT_FONT_SIZE : Int = 17
    static let DEFAULT_COLOR : UIColor = UIColor.black
    static let DEFAULT_BG_COLOR : UIColor = UIColor.white
    
    /**
     * Member variables
     */
    private var labelNode : SKLabelNode?
    private var bgNode : SKShapeNode?
    
    var text : String
    var mTextSize : CGSize = CGSize()
    var alignment : UAlignment
    var mMargin : CGSize = CGSize()
    var fontSize : CGFloat = 0
    var bgColor : UIColor? = nil
    var mMaxWidth : CGFloat = 0        // 最大の幅、これより大きい場合は範囲に収まるようにスケーリングする
    
    var isFitToSize : Bool = false   // sizeにフィットするようにテキストのスケールを調整
    var isDrawBG : Bool = false
    var isOpened : Bool = false     // 全部表示状態
    
    // MARK: Accessor
    public func getText() -> String {
        return text
    }
    
    /**
     * テキストを更新
     * 新しいテキストならSpriteKitのノードを更新する
     */
    public func setText(_ text : String) {
        if self.text == text {
            return
        }
        self.text = text

        initSKNode()
        parentNode.position.toSK()
    }
    
    public func setFont(_ font : String) {
        labelNode!.fontName = font
    }
    
    public func setMargin(_ width : CGFloat, _ height : CGFloat) {
        mMargin.width = width
        mMargin.height = height
        
        initSKNode()
        parentNode.position.toSK()
    }
    
    // MARK: Initializer
    public init(text : String, fontSize : CGFloat, priority : Int,
                alignment : UAlignment, createNode: Bool,
                isFit : Bool, isDrawBG : Bool, margin : CGFloat,
                x : CGFloat, y : CGFloat,
                width : CGFloat, color : UIColor, bgColor : UIColor?)
    {
        self.text = text
        self.alignment = alignment
        self.mMargin = CGSize(width: margin, height: margin)
        self.isFitToSize = isFit
        self.isDrawBG = isDrawBG
        self.fontSize = fontSize
        self.mMaxWidth = width
        
        super.init( priority: priority, x: x, y: y, width: width, height: fontSize)
        
        self.color = color
        self.bgColor = bgColor
        
        if createNode {
            initSKNode()
        }
    }
    
    public static func createInstance(text: String, fontSize : CGFloat, priority : Int,
                                      alignment : UAlignment, createNode : Bool,
                                      isFit : Bool, isDrawBG : Bool,
                                      x: CGFloat, y: CGFloat,
                                      width : CGFloat,
                                      color : UIColor, bgColor : UIColor?) -> UTextView
    {
        let instance = UTextView(text: text,
                                 fontSize: fontSize,
                                 priority: priority,
                                 alignment: alignment,
                                 createNode : createNode,
                                 isFit : isFit,
                                 isDrawBG : isDrawBG,
                                 margin: isDrawBG ? UDpi.toPixel(MARGIN_H) : 0,
                                 x: x, y: y,
                                 width: width,
                                 color: color, bgColor: bgColor)
        
        return instance
    }
    
    // シンプルなTextViewを作成
    public static func createInstance(text : String, priority : Int, createNode : Bool,
                                      isDrawBG : Bool,
                                      x : CGFloat, y : CGFloat) -> UTextView
    {
        let instance = UTextView(text:text,
                                 fontSize: UDpi.toPixel(UTextView.DEFAULT_FONT_SIZE),
                                 priority:priority,
                                 alignment: UAlignment.None, createNode : createNode,
                                 isFit: false,
                                 isDrawBG: isDrawBG,
                                 margin: UDpi.toPixel(MARGIN_H),
                                 x:x, y:y,
                                 width: 0,
                                 color: DEFAULT_COLOR, bgColor: DEFAULT_BG_COLOR)
        return instance
    }
    
    /**
     * SpriteKitのノードを作成する
     */
    public override func initSKNode() {
        if let n = labelNode {
            n.removeFromParent()
        }
        if let n = bgNode {
            n.removeFromParent()
        }

        // ノードを作成
        // parent
        self.parentNode.zPosition = CGFloat( drawPriority )
        self.parentNode.position = pos
        
        // Label
        let result = SKNodeUtil.createLabelNode(text: text, fontSize: fontSize, color: color, alignment: .Left, pos: nil)
        self.labelNode = result.node
        
        // 最大幅に収まるように補正
        if isFitToSize && mMaxWidth > 0 && result.size.width > mMaxWidth {
            self.labelNode?.adjustLabelFontSizeToFitWidth(width: mMaxWidth)
            mTextSize = CGSize(width : mMaxWidth, height: result.size.height)
        } else {
            mTextSize = result.size
        }
        size.height = result.size.height
        
        if mMargin.width > 0 || mMargin.height > 0 {
            labelNode!.position = CGPoint(x: mMargin.width,
                                    y: mMargin.height )
            mTextSize = CGSize(width: mTextSize.width + mMargin.width * 2,
                          height: mTextSize.height + mMargin.height * 2)
            size = mTextSize
        }
        
        self.labelNode!.zPosition = 0.1

        parentNode.addChild2(self.labelNode!)
        
        // BG
        if isDrawBG {
            self.bgNode = SKShapeNode(rect: CGRect(x:0, y:0, width: size.width, height: size.height).convToSK(),
                cornerRadius: UDpi.toPixel(10))
            self.bgNode!.isAntialiased = true
            
            if bgColor != nil {
                self.bgNode!.fillColor = bgColor!
            }
            self.bgNode!.strokeColor = .clear
            parentNode.addChild2(self.bgNode!)
        }
        
        // alignment
        var alignPos : CGPoint
        switch alignment {
        case .None:
            fallthrough
        case .Left:
            alignPos = CGPoint(x: 0, y: 0)
        case .CenterX:
            alignPos = CGPoint(x: -mTextSize.width / 2, y: 0)
        case .CenterY:
            alignPos = CGPoint(x: 0, y: -mTextSize.height / 2)
        case .Center:
            alignPos = CGPoint(x: -mTextSize.width / 2, y: -mTextSize.height / 2)
        case .Right:
            alignPos = CGPoint(x: -mTextSize.width, y: 0)
        case .Right_CenterY:
            alignPos = CGPoint(x: -mTextSize.width, y: -mTextSize.height / 2)
        case .Bottom:
            alignPos = CGPoint(x: 0, y: -mTextSize.height)
        case .CenterX_Bottom:
            alignPos = CGPoint(x: -mTextSize.width  / 2, y: -mTextSize.height)
        case .Right_Bottom:
            alignPos = CGPoint(x: -mTextSize.width, y: -mTextSize.height)
        }
        parentNode.position = CGPoint(x: pos.x + alignPos.x,
                                      y: pos.y + alignPos.y)
    }
    
    /**
     * Methods
     */
    
//    func updateSize() {
//        var size : CGSize = getTextSize()
//        if (isDrawBG) {
//            size = addBGPadding(size)
//        }
//        setSize(size.width, size.height)
//    }
    
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
    
    // MARK: UDrawable
    /**
     * 描画処理
     * @param canvas
     * @param paint
     * @param offset 独自の座標系を持つオブジェクトをスクリーン座標系に変換するためのオフセット値
     */
    public override func draw() {
    }
    
    public override func doAction() -> DoActionRet {
        return .None
    }
    
    /**
     * テキストのサイズを取得する（マルチライン対応）
     * @return
     */
    public func getTextSize() -> CGSize {
        return UDraw.getTextSize(text: text, fontSize: fontSize)
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
            
            if self.rect.contains(point) {
                isOpened = !isOpened
                return true
            }
        }
        return false
    }
}

