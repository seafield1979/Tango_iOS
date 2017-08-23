//
//  UTextView.swift
//  UGui
//
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
    
    static let DEFAULT_TEXT_SIZE : Int = 17
    static let DEFAULT_COLOR : UIColor = UIColor.black
    static let DEFAULT_BG_COLOR : UIColor = UIColor.white
    
    /**
     * Member variables
     */
    private var labelNode : SKLabelNode?
    private var bgNode : SKShapeNode?
    
    var text : String
    var alignment : UAlignment
    var isMargin : Bool
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
                alignment : UAlignment, createNode: Bool,
                multiLine : Bool, isDrawBG : Bool, isMargin : Bool,
                x : CGFloat, y : CGFloat,
                width : CGFloat, color : UIColor, bgColor : UIColor?)
    {
        self.text = text
        self.alignment = alignment
        self.isMargin = isMargin
        self.multiLine = multiLine
        self.isDrawBG = isDrawBG
        self.textSize = textSize
        
        super.init( priority: priority, x: x, y: y, width: width, height: CGFloat(textSize))
        
        self.color = color
        self.bgColor = bgColor
        
        if createNode {
            initSKNode()
        }
        
        updateSize()
    }
    
    public static func createInstance(text: String, textSize : Int, priority : Int,
                                      alignment : UAlignment, createNode : Bool,
                                      multiLine : Bool, isDrawBG : Bool,
                                      x: CGFloat, y: CGFloat,
                                      width : CGFloat,
                                      color : UIColor, bgColor : UIColor?) -> UTextView
    {
        let instance = UTextView(text: text,
                                 textSize: textSize,
                                 priority: priority,
                                 alignment: alignment,
                                 createNode : createNode,
                                 multiLine : multiLine,
                                 isDrawBG : isDrawBG,
                                 isMargin: true,
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
                                 textSize: UTextView.DEFAULT_TEXT_SIZE,
                                 priority:priority,
                                 alignment: UAlignment.None, createNode : createNode,
                                 multiLine: false,
                                 isDrawBG: isDrawBG,
                                 isMargin: true,
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
        if text.contains("\n") {
            let result = SKNodeUtil.createMultiLineLabelNode(text: text, fontSize: CGFloat(textSize), color: color, alignment: .Left, pos: nil)
            self.labelNode = result.node
            size = result.size
        } else {
            self.labelNode = SKNodeUtil.createLabelNode(text: text, textSize: CGFloat(textSize), color: color, alignment: .Left, offset: nil)
            size = labelNode!.frame.size
        }
        
        if isMargin {
            mMargin = CGSize(width: UDpi.toPixel(UTextView.MARGIN_H),
                             height: UDpi.toPixel(UTextView.MARGIN_V))
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
    
    
    /**
     * 描画処理
     * @param canvas
     * @param paint
     * @param offset 独自の座標系を持つオブジェクトをスクリーン座標系に変換するためのオフセット値
     */
    public override func draw() {
    }
    
    /**
     * テキストのサイズを取得する（マルチライン対応）
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
            
            if self.rect.contains(point) {
                isOpened = !isOpened
                return true
            }
        }
        return false
    }
}

