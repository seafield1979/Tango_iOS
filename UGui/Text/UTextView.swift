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
    var alignment : UAlignment
    var mMargin : CGSize = CGSize()
    var fontSize : CGFloat = 0
    var bgColor : UIColor? = nil
    var multiLine : Bool = false      // 複数行表示する
    
    var isDrawBG : Bool = false
    var isOpened : Bool = false     // 全部表示状態
    
    // MARK: Accessor
    public func getText() -> String {
        return text
    }
    public func setText(_ text : String) {
        self.text = text;
        
        // サイズを更新
        let size : CGSize = getTextSize()
        if (isDrawBG) {
            setSize(size.width + mMargin.width * 2, size.height + mMargin.height * 2)
        } else {
            setSize(size.width, size.height)
        }
        labelNode!.text = text
        
        updateRect()
    }
    
    public func setFont(_ font : String) {
        labelNode!.fontName = font
    }
    
    public func setMargin(_ width : CGFloat, _ height : CGFloat) {
        mMargin.width = width
        mMargin.height = height
        updateSize()
    }
    
    // MARK: Initializer
    public init(text : String, fontSize : CGFloat, priority : Int,
                alignment : UAlignment, createNode: Bool,
                multiLine : Bool, isDrawBG : Bool, margin : CGFloat,
                x : CGFloat, y : CGFloat,
                width : CGFloat, color : UIColor, bgColor : UIColor?)
    {
        self.text = text
        self.alignment = alignment
        self.mMargin = CGSize(width: margin, height: margin)
        self.multiLine = multiLine
        self.isDrawBG = isDrawBG
        self.fontSize = fontSize
        
        super.init( priority: priority, x: x, y: y, width: width, height: fontSize)
        
        self.color = color
        self.bgColor = bgColor
        
        if createNode {
            initSKNode()
        }
        
        updateSize()
    }
    
    public static func createInstance(text: String, fontSize : CGFloat, priority : Int,
                                      alignment : UAlignment, createNode : Bool,
                                      multiLine : Bool, isDrawBG : Bool,
                                      x: CGFloat, y: CGFloat,
                                      width : CGFloat,
                                      color : UIColor, bgColor : UIColor?) -> UTextView
    {
        let instance = UTextView(text: text,
                                 fontSize: fontSize,
                                 priority: priority,
                                 alignment: alignment,
                                 createNode : createNode,
                                 multiLine : multiLine,
                                 isDrawBG : isDrawBG,
                                 margin: UDpi.toPixel(MARGIN_H),
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
                                 multiLine: false,
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
        // ノードを作成
        // parent
        self.parentNode.zPosition = CGFloat( drawPriority )
        self.parentNode.position = pos
        
        // Label
        let result = SKNodeUtil.createLabelNode(text: text, fontSize: fontSize, color: color, alignment: .Left, pos: nil)
        self.labelNode = result.node

        // もとの指定したサイズに収まるように補正
        if size.width > 0 && result.size.width > size.width {
            self.labelNode?.adjustLabelFontSizeToFitWidth(width: size.width)
        } else {
            size = result.size
        }
        
        if mMargin.width > 0 || mMargin.height > 0 {
            labelNode!.position = CGPoint(x: mMargin.width,
                                    y: mMargin.height )
            size = CGSize(width: size.width + mMargin.width * 2,
                          height: size.height + mMargin.height * 2)
        }
        
        self.labelNode!.zPosition = 0.1

        parentNode.addChild2(self.labelNode!)
        
        // BG
        if isDrawBG {
            let radius = UDpi.toPixel(10)
            self.bgNode = SKShapeNode(rect: CGRect(x:0, y:0, width: size.width, height: size.height).convToSK(),
                cornerRadius: radius)
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
            alignPos = CGPoint(x: -size.width / 2, y: 0)
        case .CenterY:
            alignPos = CGPoint(x: 0, y: -size.height / 2)
        case .Center:
            alignPos = CGPoint(x: -size.width / 2, y: -size.height / 2)
        case .Right:
            alignPos = CGPoint(x: -size.width, y: 0)
        case .Right_CenterY:
            alignPos = CGPoint(x: -size.width, y: -size.height / 2)
        case .Bottom:
            alignPos = CGPoint(x: 0, y: -size.height)
        case .CenterX_Bottom:
            alignPos = CGPoint(x: -size.width  / 2, y: -size.height)
        case .Right_Bottom:
            alignPos = CGPoint(x: -size.width, y: -size.height)
        }
        parentNode.position = CGPoint(x: parentNode.position.x + alignPos.x,
                                      y: parentNode.position.y + alignPos.y)
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

