//
//  UButtonImage.swift
//  UGui
//
//  Created by Shusuke Unno on 2017/07/08.
//  Copyright © 2017年 Shusuke Unno. All rights reserved.
//

import SpriteKit

/**
 * 画像を表示するボタン
 * 画像の下にテキストを表示することも可能
 */


public class UButtonImage : UButton {
    /**
     * Consts
     */
    public let TEXT_MARGIN : Int = 4
    public let BG_MARGIN : Int = 4
    public static let FONT_SIZE : Int = 10
    private let BG_COLOR = UIColor.init(red: 1.0, green: 0.0, blue: 0, alpha: 0.5)
    
    /**
     * Member Variables
     */
    // SpriteKit Node
    var bgNode : SKShapeNode?        // タップ時に表示されるBG
    var titleNode : SKLabelNode?    // ボタンの下に表示されるテキスト
    var imageNode : SKSpriteNode   // ボタン用画像
    var textures : [SKTexture] = []
    var pressedTexture : SKTexture?
    var disabledTexture : SKTexture?
    
    var title : String? = nil             // 画像の下に表示するテキスト
    var titleSize : Int = 0
    var titleColor : UIColor = UIColor()
    var stateId : Int = 0          // 現在の状態
    var stateMax : Int = 0         // 状態の最大値 addState で増える
    
    private var mTextTitle : UTextView? = nil
    
    /**
     * Get/Set
     */
    public func setEnabled(enabled : Bool) {
        self.enabled = enabled
        if !enabled {
            if disabledTexture == nil && textures.count > 0 {
                disabledTexture = textures[0]
            }
        }
    }
    
    public func addImage(_ image : UIImage) {
        textures.append( SKTexture(image: image))
    }
    public func setPressedImage(_ image : UIImage) {
        pressedTexture = SKTexture(image: image)
    }
    
    // MARK: Initializer
    public init(callbacks : UButtonCallbacks?,
                id : Int , priority : Int,
                x : CGFloat, y : CGFloat,
                width : CGFloat, height : CGFloat,
                image : UIImage, pressedImage : UIImage? )
    {
        imageNode = SKSpriteNode()
        
        super.init(callbacks: callbacks, type: UButtonType.BGColor,
                   id: id, priority: priority,
                   x: x, y: y, width: width, height: height,
                   color: .clear)
        
        textures.append( SKTexture(image: image))
        
        if pressedImage != nil {
            pressedTexture = SKTexture(image: pressedImage!)
        } else {
            pressedColor = UColor.LightPink
        }
        stateId = 0
        stateMax = 1
        
        initSKNode()
    }
    
    public convenience init(callbacks : UButtonCallbacks?,
                            id : Int , priority : Int,
                            x : CGFloat, y : CGFloat,
                            width : CGFloat, height : CGFloat,
                            imageName : ImageName, pressedImageName : ImageName? )
    {
        var pressedImage : UIImage? = nil
        if pressedImageName != nil {
            pressedImage = UIImage(named: pressedImageName!.rawValue)
        }
        
        self.init(callbacks: callbacks, id: id, priority: priority, x: x, y: y, width: width, height: height, image: UIImage(named: imageName.rawValue)!, pressedImage: pressedImage)
    }
    
    // 画像ボタン
    public static func createButton(callbacks : UButtonCallbacks?,
                                    id : Int, priority : Int,
                                    x : CGFloat, y : CGFloat,
                                    width : CGFloat, height : CGFloat,
                                    imageName : ImageName,
                                    pressedImageName : ImageName?) -> UButtonImage
    {
        let button = UButtonImage(callbacks: callbacks, id: id, priority: priority,
                                  x: x, y: y, width: width, height: height,
                                  imageName: imageName,
                                  pressedImageName: pressedImageName)
        return button
    }
    
    /**
     * SpriteKitのノードの初期化
     */
    public override func initSKNode() {
        parentNode.position = pos
        
        if title != nil {
            titleNode = SKNodeUtil.createLabelNode(
                text: title!,
                fontSize: UDpi.toPixel(UButtonImage.FONT_SIZE), color: titleColor,
                alignment: .CenterX, pos: CGPoint(x: 0, y: UDpi.toPixel(0)))
            titleNode?.zPosition = 0.1
            parentNode.addChild2(titleNode!)
        }

        // タップ時に表示されるBG
        let bgMargin = UDpi.toPixel( BG_MARGIN )
        bgNode = SKNodeUtil.createRectNode(
            rect: CGRect(x: -bgMargin, y: -bgMargin,
                         width: size.width + bgMargin * 2,
                         height: size.height + bgMargin * 2),
            color: BG_COLOR, pos: CGPoint(), cornerR: 5.0)
        bgNode!.isHidden = true
        parentNode.addChild2(bgNode!)
        
        imageNode = SKSpriteNode(texture: textures[0])
        imageNode.size = size
        imageNode.zPosition = 0.1
        imageNode.anchorPoint = CGPoint(x:0, y:1.0)
        parentNode.addChild2(imageNode)
        
    }
    
    /**
     * Methods
     */
    /**
     * ボタンの下に表示するタイトルを設定する
     * @param title
     * @param titleSize
     * @param titleColor
     */
    public func setTitle(title: String, size : Int, color : UIColor) {
        self.title = title
        self.titleSize = size
        self.titleColor = color
    }
    
    /**
     * 状態を追加する
     * @param imageId 追加した状態の場合に表示する画像
     */
    public func addState(imageName : ImageName) {
        textures.append( SKTexture(imageNamed: imageName.rawValue) )
        stateMax += 1
    }
    public func addState(image : UIImage) {
        textures.append( SKTexture(image: image))
        stateMax += 1
    }
    
    /**
     * テキストを追加する
     */
    public func addTitle(title : String, fontSize: CGFloat, alignment: UAlignment,
                         x : CGFloat, y : CGFloat,
                         color : UIColor, bgColor : UIColor?)
    {
        if titleNode != nil {
            titleNode?.removeFromParent()
        }
        
        titleNode = SKNodeUtil.createLabelNode(
            text: title,
            fontSize: fontSize, color: color,
            alignment: alignment, pos: CGPoint(x: x, y: y))
        titleNode?.zPosition = 0.2
        parentNode.addChild2(titleNode!)
    }
    
    /**
     * 次の状態にすすむ
     */
    public func setNextState() -> Int {
        if (stateMax >= 2) {
            stateId = (stateId + 1) % stateMax
        }
        return stateId
    }
    
    public func setState(state : Int) {
        if (stateMax > state) {
            stateId = state;
        }
    }
    
    private func getNextStateId() -> Int {
        if (stateMax >= 2) {
            return (stateId + 1) % stateMax
        }
        return 0
    }
    
    /**
     * UDrawable
     */
    /**
     * 描画処理
     * @param canvas
     * @param paint
     * @param offset 独自の座標系を持つオブジェクトをスクリーン座標系に変換するためのオフセット値
     */
    public override func draw() {
        var _texture : SKTexture? = nil
        
        // 表示するテクスチャは状態によって変わる
        if !enabled {
            _texture = disabledTexture
        } else {
            _texture = textures[stateId]
        }
        
        if isPressed {
            if pressedTexture != nil {
                _texture = pressedTexture
            } else {
                // BGの矩形を配置
                bgNode!.isHidden = false
            }
        } else {
            bgNode!.isHidden = true
        }
        imageNode.texture = _texture
    }
}

//public class UButtonImage : UButton {
//    /**
//     * Consts
//     */
//    public static let TEXT_MARGIN : Int = 4
//    
//    private static let FONT_SIZE : Int = 10
//    
//    /**
//     * Member Variables
//     */
//    var images : List<UIImage> = List()    // 画像
//    var pressedImage : UIImage? = nil      // タッチ時の画像
//    var disabledImage : UIImage? = nil     // disable時の画像
//    var title : String? = nil             // 画像の下に表示するテキスト
//    var titleSize : Int = 0
//    var titleColor : UIColor = UIColor()
//    var stateId : Int = 0          // 現在の状態
//    var stateMax : Int = 0         // 状態の最大値 addState で増える
//    
//    private var mTextTitle : UTextView? = nil
//    
//    /**
//     * Get/Set
//     */
//    public func setEnabled(enabled : Bool) {
//        self.enabled = enabled
//        if (!enabled) {
//            if (disabledImage == nil && images.count > 0) {
//                disabledImage = UUtil.convToGrayImage(image: images[0])
//            }
//        }
//    }
//    
//    public func setImage(_ image : UIImage?) {
//        if (image != nil) {
//            self.images.append(image!)
//        }
//    }
//    public func setPressedImage(_ image : UIImage?) {
//        if (image != nil) {
//            pressedImage = image
//        }
//    }
//    
//    /**
//     * Constructor
//     */
//    public init(callbacks : UButtonCallbacks?,
//                             id : Int , priority : Int,
//                             x : CGFloat, y : CGFloat,
//                             width : CGFloat, height : CGFloat,
//                             imageName : ImageName?, pressedImageName : ImageName? )
//    {
//        super.init(callbacks: callbacks, type: UButtonType.BGColor,
//                   id: id, priority: priority,
//                   x: x, y: y, width: width, height: height,
//                   color: UColor.Blue)
//        
//        if imageName != nil {
//            images.append(UResourceManager.getImageByName(imageName!)!)
//        }
//        
//        if pressedImage != nil {
//            self.pressedImage = UResourceManager.getImageByName(pressedImageName!)
//        } else {
//            pressedColor = UColor.LightPink;
//        }
//        stateId = 0;
//        stateMax = 1;
//    }
//    
//    // 画像ボタン
//    public static func createButton(callbacks : UButtonCallbacks?,
//                                    id : Int, priority : Int,
//                                    x : CGFloat, y : CGFloat,
//                                    width : CGFloat, height : CGFloat,
//                                    imageName : ImageName?,
//                                    pressedImageName : ImageName?) -> UButtonImage
//    {
//        let button = UButtonImage(callbacks: callbacks, id: id, priority: priority,
//                                  x: x, y: y, width: width, height: height,
//                                  imageName: imageName,
//                                  pressedImageName: pressedImageName)
//        return button
//    }
//    
//    // 画像ボタン
//    public static func createButton(callbacks : UButtonCallbacks?,
//                                    id : Int, priority : Int,
//                                    x : CGFloat, y : CGFloat,
//                                    width : CGFloat, height : CGFloat,
//                                    image : UIImage?, pressedImage : UIImage?) -> UButtonImage
//    {
//        let button = UButtonImage(callbacks: callbacks,
//                                  id: id, priority: priority,
//                                  x:x, y:y,
//                                  width: width, height: height,
//                                  imageName: nil, pressedImageName: nil)
//        button.setImage(image)
//        button.setPressedImage(pressedImage)
//        return button
//    }
//    
//    /**
//     * Methods
//     */
//    /**
//     * ボタンの下に表示するタイトルを設定する
//     * @param title
//     * @param titleSize
//     * @param titleColor
//     */
//    public func setTitle(title: String, size : Int, color : UIColor) {
//        self.title = title
//        self.titleSize = size
//        self.titleColor = color
//    }
//    
//    /**
//     * 状態を追加する
//     * @param imageId 追加した状態の場合に表示する画像
//     */
//    public func addState(imageName : ImageName) {
//        images.append(UResourceManager.getImageByName(imageName)!)
//        stateMax += 1
//    }
//    public func addState(image : UIImage) {
//        images.append(image)
//        stateMax += 1
//    }
//    
//    /**
//     * テキストを追加する
//     */
//    public func addTitle(title : String, alignment: UAlignment,
//                         x : CGFloat, y : CGFloat,
//                         color : UIColor, bgColor : UIColor?)
//    {
//        mTextTitle = UTextView.createInstance(text: title,
//                                              fontSize:Int(UDpi.toPixel(UButtonImage.FONT_SIZE)),
//                                              priority: 0, alignment: alignment,
//                                              multiLine:false, isDrawBG: true,
//                                              x:x, y:y,
//                                              width:0,
//                                              color: color, bgColor: bgColor)
//        mTextTitle?.setMargin(10, 10)
//    }
//    
//    /**
//     * 次の状態にすすむ
//     */
//    public func setNextState() -> Int {
//        if (stateMax >= 2) {
//            stateId = (stateId + 1) % stateMax
//        }
//        return stateId
//    }
//    
//    public func setState(state : Int) {
//        if (stateMax > state) {
//            stateId = state;
//        }
//    }
//    
//    private func getNextStateId() -> Int {
//        if (stateMax >= 2) {
//            return (stateId + 1) % stateMax
//        }
//        return 0
//    }
//    
//    /**
//     * UDrawable
//     */
//    /**
//     * 描画処理
//     * @param canvas
//     * @param paint
//     * @param offset 独自の座標系を持つオブジェクトをスクリーン座標系に変換するためのオフセット値
//     */
//    public override func draw(_ offset : CGPoint?) {
//        var _image : UIImage? = nil
//        
//        var _pos = CGPoint(x: pos.x, y: pos.y)
//        if (offset != nil) {
//            _pos.x += offset!.x
//            _pos.y += offset!.y
//        }
//        
//        if !enabled {
//            _image = disabledImage
//        } else {
//            _image = images[stateId]
//        }
//        let _rect = CGRect(x:_pos.x, y:_pos.y,
//                           width: size.width,
//                           height: size.height)
//        if (isPressed) {
//            if pressedImage != nil {
//                _image = pressedImage
//            } else {
//                // BGの矩形を配置
//                let margin = UDpi.toPixel(5)
//                UDraw.drawRoundRectFill( rect: CGRect(x:_rect.x - margin,
//                                                y: _rect.y - margin,
//                                                width: _rect.width + margin * 2,
//                                                height: _rect.height + margin * 2),
//                                         cornerR: margin, color: pressedColor,
//                                         strokeWidth: 0, strokeColor: nil)
//            }
//        }
//        
//        // 領域の幅に合わせて伸縮
//        UDraw.drawImage(image: _image!, rect: _rect)
//        
//        if UDebug.drawRectLine {
//            self.drawRectLine(offset: offset, color: UIColor.yellow)
//        }
//        
//        // 下にテキストを表示
//        if title != nil {
//            UDraw.drawText(text: title!, alignment: UAlignment.CenterX,
//                           fontSize: titleSize,
//                           x:_rect.centerX(),
//                           y:_rect.bottom + UDpi.toPixel(UButtonImage.TEXT_MARGIN),
//                           color: titleColor)
//        }
//    }
//}
