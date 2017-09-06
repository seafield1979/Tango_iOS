//
//  UButtonText.swift
//  UGui
//
//  Created by Shusuke Unno on 2017/07/08.
//  Copyright © 2017年 Shusuke Unno. All rights reserved.
//


import SpriteKit

/**
 * テキストを表示するボタン
 */
public class UButtonText : UButton {
    // MARK: Constants
    public static let TAG = "UButtonText"
    
    private static let MARGIN_V : Int = 10
    private static let CHECKED_W : Int = 23
    
    static let DEFAULT_TEXT_COLOR = UIColor.black
    static let PULL_DOWN_COLOR = UColor.DarkGray
    
    
    // MARK: Properties
    // SpriteKitのノード
    private var labelNode : SKLabelNode?
    private var bgNode : SKShapeNode?
    private var bg2Node : SKShapeNode?
    private var imageNode : SKSpriteNode?
    private var pullNode : SKShapeNode?
    
    private var mText : String
    private var mTextColor : UIColor
    private var mFontSize : CGFloat = 0
    private var mImage : UIImage?
    private var mImageAlignment : UAlignment = UAlignment.Left     // 画像の表示位置
    private var mImageOffset : CGPoint? = CGPoint()
    private var mImageSize : CGSize? = CGSize()
    private var mBasePos : CGPoint = CGPoint()
    
    // MARK: Initializer
    init(callbacks : UButtonCallbacks?, type : UButtonType, id : Int,
         priority : Int, text : String, createNode : Bool,
         x : CGFloat, y : CGFloat, width : CGFloat, height : CGFloat,
         fontSize : CGFloat, textColor : UIColor?, bgColor : UIColor?)
    {
        self.mText = text
        self.mTextColor = textColor!
        self.mFontSize = fontSize
        
        super.init(callbacks: callbacks, type: type, id: id, priority: priority,
                   x: x, y: y, width: width, height: height, color: bgColor)
        
        if createNode {
            initSKNode()
        }
    }
    
    /**
     * SpriteKitのノードを作成する
     */
    public override func initSKNode() {
        // ノードを作成
        // parent
        self.parentNode.zPosition = CGFloat(drawPriority)
        self.parentNode.position = pos
        
        // BG
        let bgH = (type == .BGColor) ? size.height : (size.height - UDpi.toPixel(UButton.PRESS_Y))
        
        self.bgNode = SKShapeNode(rect: CGRect(x:0, y:0, width: size.width, height: bgH).convToSK(),
                                  cornerRadius: 10.0)
        self.bgNode!.fillColor = color
        self.bgNode!.strokeColor = .clear
        self.bgNode!.zPosition = 0.1
        self.parentNode.addChild2(bgNode!)
        
        // Label
        mBasePos = CGPoint(x: size.width / 2, y: bgH / 2)

        let result = SKNodeUtil.createLabelNode(text: mText, fontSize: mFontSize, color: mTextColor, alignment: .Center, pos: mBasePos)
        self.labelNode = result.node
        self.bgNode!.addChild2(self.labelNode!)
        
        if size.height == 0 {
            let size = UDraw.getTextSize(text: mText, fontSize: mFontSize)
            setSize(size.width, size.height + UDpi.toPixel( UButtonText.MARGIN_V) * 2)
        }
        
        // BG2(影の部分)
        if type != .BGColor {
            let _h = UDpi.toPixel( UButton.PRESS_Y + 25)
            self.bg2Node = SKShapeNode(rect: CGRect(x:0, y:bgH - UDpi.toPixel(25), width: size.width, height: _h).convToSK(),
                                       cornerRadius: 10.0)
            self.bg2Node!.fillColor = pressedColor
            self.bg2Node!.strokeColor = .clear
            self.parentNode.addChild2(self.bg2Node!)
        }
        // 画像
        if mImage != nil {
            let texture = SKTexture(cgImage: mImage!.cgImage!)
            imageNode = SKSpriteNode(texture: texture)
            imageNode!.size = mImageSize!
            calcImageOffset(alignment: mImageAlignment, convSKPos: false)
            bgNode!.addChild2(imageNode!)
        }
        
    }

    // MARK: Accessor
    public func getmText() -> String{
        return mText
    }
    
    public func setText(text : String?) {
        self.mText = text ?? ""
        if labelNode != nil {
            labelNode!.text = text
        }
    }
    
    public func setTextColor(textColor : UIColor) {
        self.mTextColor = textColor
        if labelNode != nil {
            labelNode!.fontColor = textColor
        }
    }
    
    public func setImage(imageName : ImageName, imageSize : CGSize, initNode: Bool) {
        mImage = UIImage(named: imageName.rawValue)
        mImageSize = imageSize

        if initNode {
            let texture = SKTexture( image: mImage!)
            imageNode = SKSpriteNode(texture: texture)
            if imageNode != nil {
                imageNode!.size = imageSize
                bgNode!.addChild( imageNode! )
                
                calcImageOffset(alignment: mImageAlignment, convSKPos: true)
            }
        }
    }
    
    public func setImage(image : UIImage, imageSize : CGSize, initNode: Bool) {
        mImage = image
        mImageSize = imageSize
        
        if initNode {
            let texture = SKTexture(cgImage: image.cgImage!)
            imageNode = SKSpriteNode(texture: texture)
            imageNode!.size = imageSize
            
            calcImageOffset(alignment: mImageAlignment, convSKPos: true)
            bgNode!.addChild(imageNode!)
        }
    }
    
    public override func setColor(_ color : UIColor) {
        super.setColor(color)
        if bgNode != nil {
            bgNode!.fillColor = color
        }
    }
    
    // 画像の表示座標を計算する
    private func calcImageOffset( alignment : UAlignment, convSKPos : Bool) {
        var baseX : CGFloat = 0, baseY : CGFloat = 0
        
        switch mImageAlignment {
        case .None:
            fallthrough
        case .Left:
            baseX = 0
            baseY = bgNode!.frame.size.height / 2
            break
        case .CenterX:
            baseX = bgNode!.frame.size.width / 2
            baseY = 0
        case .CenterY:
            baseX = 0
            baseY = bgNode!.frame.size.height / 2
        case .Center:
            baseX = bgNode!.frame.size.width / 2
            baseY = bgNode!.frame.size.height / 2
            break
        case .Right:
            baseX = bgNode!.frame.size.width - imageNode!.size.width
            baseY = 0
        case .Right_CenterY:
            baseX = bgNode!.frame.size.width - imageNode!.size.width
            baseY = bgNode!.frame.size.height / 2
        case .Bottom:
            baseX = 0
            baseY = bgNode!.frame.size.height
        case .CenterX_Bottom:
            baseX = bgNode!.frame.size.width / 2
            baseY = bgNode!.frame.size.height
        case .Right_Bottom:
            baseX = bgNode!.frame.size.width - imageNode!.size.width
            baseY = bgNode!.frame.size.height
        }
        
        if mImageOffset != nil {
            baseX += mImageOffset!.x
            baseY += mImageOffset!.y
        }
        
        imageNode!.position = CGPoint(x: baseX, y: baseY)
        if convSKPos {
            imageNode!.position.toSK()
        }
    }
    
    public func setImageAlignment(_ alignment : UAlignment) {
        mImageAlignment = alignment
    }
    
    public func setTextOffset(x : CGFloat, y : CGFloat) {
        if labelNode != nil {
            labelNode!.position = CGPoint(x: mBasePos.x + x, y: mBasePos.y + y).convToSK()
        }
    }
    
    public func setImageOffset(x : CGFloat, y : CGFloat) {
        mImageOffset = CGPoint(x: x, y: y)
        if imageNode != nil {
            calcImageOffset(alignment: .Center, convSKPos: true)
        }
    }
    
    // MARK: Methods
    public func setChecked(_ checked : Bool, initNode : Bool) {
        super.setChecked(checked)
        
        // ボタンの左側にチェックアイコンを表示
        if checked {
            if imageNode == nil {
                setImage(imageName: ImageName.checked2,
                         imageSize: CGSize(width: UDpi.toPixel(UButtonText.CHECKED_W), height: UDpi.toPixel(UButtonText.CHECKED_W)),
                         initNode : initNode)
                self.setImageAlignment( .CenterY )
                self.setImageOffset( x: UDpi.toPixel(30), y: size.height / 2)
            }
        } else {
            if imageNode != nil {
                imageNode!.removeFromParent()
            }
        }
    }
    
    /**
     * このボタンを押すと選択項目が表示されるプルダウンアイコンを設定する
     * parameter pullDown: trueでプルダウンアイコンを表示
     */
    public override func setPullDownIcon(_ pullDown : Bool) {
        if pullNode == nil {
            pullNode = SKNodeUtil.createTriangleNode(
                length: UDpi.toPixel(10),
                angle: 180,
                color: UButtonText.PULL_DOWN_COLOR)
            pullNode!.position = CGPoint(x: size.width - UDpi.toPixel(15), y: SKUtil.convY(fromView: size.height / 2))
            bgNode!.addChild(pullNode!)
        }
    }
    
    
    /**
     * 描画処理
     * @param canvas
     * @param paint
     * @param offset 独自の座標系を持つオブジェクトをスクリーン座標系に変換するためのオフセット値
     */
    public override func draw() {
        // 色
        // 押されていたら明るくする
        var _color = color
        var _pos = CGPoint(x: 0, y: 0)
        var _height = size.height
        
        if type == UButtonType.BGColor {
            // 押したら色が変わるボタン
            if !enabled {
                _color = disabledColor
            }
            else if isPressed {
                _color = pressedColor
            }
        }
        else {
            // 押したら凹むボタン
            if !enabled {
                _color = disabledColor
                if let n = bg2Node {
                    n.fillColor = disabledColor2
                }
            }
            if isPressed || pressedOn {
                _pos.y += UDpi.toPixel( UButton.PRESS_Y)
            }
            _height -= UDpi.toPixel(UButton.PRESS_Y)
            
        }
        if let n = bgNode {
            n.position = CGPoint(x: 0, y: SKUtil.convY(fromView: _pos.y))
            n.fillColor = _color
        }
    }
}
