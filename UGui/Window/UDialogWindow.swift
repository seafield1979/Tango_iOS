//
//  UDialogWindow.swift
//  UGui
//
//  Created by Shusuke Unno on 2017/07/08.
//  Copyright © 2017年 Shusuke Unno. All rights reserved.
//

import SpriteKit

/**
 * ダイアログ(画面の最前面に表示されるWindow)
 *
 * 使用方法
 *  UDialogWindow dialog = UDialogWindow(...);
 *  dialog.addButton(...)       ボタン追加
 *  dialog.addButton(...)       ボタン追加
 *      ...                     好きなだけボタン追加
 *  dialog.updateLayout(...)    レイアウト確定
 *
 */
public enum DialogType {
    case Normal     // 移動可能、下にあるWindowをタッチできる
    case Modal     // 移動不可、下にあるWindowをタッチできない
}

public enum DialogPosType {
    case Point      // 指定した座標に表示
    case Center     // 中央に表示
}

public protocol UDialogCallbacks {
    func dialogClosed(dialog : UDialogWindow)
}

public class UDialogWindow : UWindow {
    // ボタンの並ぶ方向
    public enum ButtonDir {
        case Horizontal     // 横に並ぶ
        case Vertical       // 縦に並ぶ
    }
    
    public enum AnimationType {
        case Opening        // ダイアログが開くときのアニメーション
        case Closing        // ダイアログが閉じる時のアニメーション
    }
    
    public static let CloseDialogId = 10000123
    
    static let MARGIN_H : Int = 17
    static let MARGIN_V : Int = 17
    static let ANIMATION_FRAME : Int = 100
    
    static let TEXT_MARGIN_V : Int = 10
    static let BUTTON_H : Int =  47
    static let BUTTON_MARGIN_H : Int = 17
    static let BUTTON_MARGIN_V : Int = 10
    
    //
    /**
     * Member variables
     */
    // SpriteKit
    private var dialogBgNode : SKShapeNode?      // モーダルダイアログの背景
    
    var basePos = CGPoint()       // Open/Close時の中心座標
    var type : DialogType
    var posType : DialogPosType
    var buttonDir : ButtonDir
    
    var textColor : UIColor
    var dialogColor : UIColor?
    
    var buttonCallbacks : UButtonCallbacks?
    var dialogCallbacks : UDialogCallbacks?
    var animationType : AnimationType = AnimationType.Opening
    var isAnimation = false
    
    var screenSize = CGSize()
    
    var isUpdate : Bool = true     // ボタンを追加するなどしてレイアウトが変更された
    
    // タイトル
    var title : String? = nil
    var mTitleView : UTextView? = nil
    
    // メッセージ(複数)
    var mTextViews : List<UTextView> = List()
    
    // ボタン(複数)
    var mButtons : List<UButton> = List()
    
    // Drawable(複数)
    var mDrawables : List<UDrawable> = List()
    
    // Dpi計算済み
    private var marginH, buttonMarginH, buttonMarginV, buttonH : CGFloat;
    
    /**
     * Get/Set
     */
    public func getTitle() -> String? {
        return title
    }
    
    public func setTitle(_ title : String) {
        self.title = title
    }
    
    private func updateBasePos() {
        //        if posType == DialogPosType.Point {
        //            basePos = CGPoint(x: pos.x + size.width / 2,
        //                              y: pos.y + size.height / 2)
        //        } else {
        //            basePos = CGPoint(x: screenSize.width / 2,
        //                              y: screenSize.height / 2)
        //        }
    }
    
    public func isClosing() -> Bool {
        return (animationType == AnimationType.Closing)
    }
    
    /**
     * Constructor
     */
    public init(topScene: TopScene, type : DialogType, buttonCallbacks : UButtonCallbacks?,
                dialogCallbacks : UDialogCallbacks?,
                dir : ButtonDir,
                posType : DialogPosType,
                isAnimation : Bool,
                x : CGFloat, y : CGFloat,
                screenW : CGFloat, screenH : CGFloat,
                textColor : UIColor, dialogColor : UIColor?)
    {
        self.type = type
        self.posType = posType
        self.buttonDir = dir
        self.textColor = textColor
        self.dialogColor = dialogColor
        self.buttonCallbacks = buttonCallbacks
        self.dialogCallbacks = dialogCallbacks
        self.isAnimation = isAnimation
        marginH = UDpi.toPixel( UDialogWindow.MARGIN_H )
        buttonMarginH = UDpi.toPixel( UDialogWindow.BUTTON_MARGIN_H )
        buttonMarginV = UDpi.toPixel( UDialogWindow.BUTTON_MARGIN_V )
        buttonH = UDpi.toPixel( UDialogWindow.BUTTON_H )
        
        screenSize.width = screenW
        screenSize.height = screenH
        
        super.init(topScene: topScene, callbacks: nil, priority: DrawPriority.Dialog.rawValue,
                   createNode: false, cropping: false,
                   x: x, y: y,
                   width: screenW, height: screenH,
                   bgColor: dialogColor,
                   topBarH : 0, frameW : 0, frameH : 0,
                   cornerRadius: UDpi.toPixel(10))
        
        size = CGSize(width: screenW - marginH * 2,
                      height: screenH - marginH * 2)
        
        if (type == DialogType.Modal) {
            // 背景の暗幕を用意
            dialogBgNode = SKNodeUtil.createRectNode(
                rect: CGRect(x:0, y:0, width: self.topScene.size.width, height: self.topScene.size.height),
                    color: UColor.makeColor(160,0,0,0), pos: CGPoint(), cornerR: 0)
            dialogBgNode!.zPosition = CGFloat(DrawPriority.Dialog.rawValue) - 1.0
            topScene.addChild2(dialogBgNode!)
        }
    }
    
    // 座標指定タイプ
    public static func createInstance(
        topScene : TopScene,
        type : DialogType,
        buttonCallbacks : UButtonCallbacks?,
        dialogCallbacks : UDialogCallbacks?,
        dir : ButtonDir,
        posType : DialogPosType,
        isAnimation : Bool,
        x : CGFloat, y : CGFloat,
        screenW : CGFloat, screenH : CGFloat,
        textColor : UIColor, dialogColor : UIColor?) -> UDialogWindow
    {
        let instance : UDialogWindow = createInstance(
            topScene: topScene,
            type: type,
            buttonCallbacks: buttonCallbacks,
            dialogCallbacks: dialogCallbacks,
            dir: dir, posType: posType,
            isAnimation: isAnimation,
            screenW: screenW, screenH: screenH,
            textColor: textColor, dialogColor: dialogColor)
        instance.posType = DialogPosType.Point
        instance.pos.x = x
        instance.pos.y = y
        
        return instance
    }
    
    // 画面中央に表示するタイプ
    public static func createInstance(
        topScene : TopScene,
        type : DialogType, buttonCallbacks : UButtonCallbacks?,
        dialogCallbacks : UDialogCallbacks?,
        dir : ButtonDir,
        posType : DialogPosType,
        isAnimation : Bool,
        screenW : CGFloat, screenH : CGFloat,
        textColor : UIColor, dialogColor : UIColor?) -> UDialogWindow
    {
        
        let instance = UDialogWindow(
            topScene: topScene,
            type: type,
            buttonCallbacks: buttonCallbacks,
            dialogCallbacks: dialogCallbacks,
            dir: dir, posType: posType,
            isAnimation: isAnimation,
            x: 0, y: 0,
            screenW: screenW, screenH: screenH,
            textColor: textColor, dialogColor: dialogColor)
        
        return instance
    }
    
    // 最小限の引数で作成
    public static func createInstance(
        topScene: TopScene,
        buttonCallbacks : UButtonCallbacks?,
        dialogCallbacks : UDialogCallbacks?,
        buttonDir : ButtonDir,
        screenW : CGFloat, screenH : CGFloat) -> UDialogWindow
    {
        return createInstance( topScene: topScene,
                               type: DialogType.Modal,
                               buttonCallbacks: buttonCallbacks,
                               dialogCallbacks: dialogCallbacks,
                               dir: buttonDir,
                               posType: DialogPosType.Center,
                               isAnimation: true,
                               screenW: screenW, screenH: screenH,
                               textColor: UIColor.black, dialogColor: UIColor.white)
    }
    
    public func setDialogPos(x : CGFloat, y : CGFloat) {
        pos.x = x
        pos.y = y
    }
    
    public func setDialogPosCenter() {
        pos.x = (size.width - size.width) / 2
        pos.y = (size.height - size.height) / 2
    }
    
    public override func doAction() -> DoActionRet{
        var ret : DoActionRet = DoActionRet.None
        var _ret : DoActionRet = DoActionRet.None
        
        // Drawables
        for obj in mDrawables {
            _ret = obj!.doAction()
            switch(_ret) {
            case .Done:
                return _ret
            case .Redraw:
                ret = _ret
            default:
                break
            }
        }
        
        // Buttons
        for button in mButtons {
            _ret = button!.doAction()
            switch(_ret) {
            case .Done:
                return _ret
            case .Redraw:
                ret = _ret
            default:
                break
            }
        }
        
        return ret
    }
    
    /**
     * ボタンを全削除
     */
    public func clearButtons() {
        mButtons.removeAll()
    }
    
    /**
     * ダイアログを閉じる
     */
    public func closeDialog() {
        isShow = false
        self.removeFromDrawManager()
        self.parentNode.removeFromParent()
        
        if dialogBgNode != nil {
            dialogBgNode?.removeFromParent()
        }
        
        if dialogCallbacks != nil {
            dialogCallbacks!.dialogClosed(dialog: self)
        }
    }
    
    /**
     * TextViewを追加
     */
    public func addTextView(text : String, alignment : UAlignment,
                            multiLine : Bool, isDrawBG : Bool,
                            fontSize : CGFloat, textColor : UIColor,
                            bgColor : UIColor? ) -> UTextView
    {
        let textView : UTextView =
            UTextView.createInstance(text: text,
                                     fontSize: fontSize,
                                     priority: 0,
                                     alignment: alignment,
                                     createNode: false,
                                     multiLine: multiLine,
                                     isDrawBG: isDrawBG,
                                     x: 0, y: 0,
                                     width: size.width - marginH * 2,
                                     color: textColor, bgColor: bgColor)
        mTextViews.append(textView)
        isUpdate = true
        return textView
    }
    
    /**
     * ボタンを追加
     * ボタンを追加した時点では座標は設定しない
     * @param text
     * @param color
     */
    public func addButton(id : Int, text : String, fontSize: CGFloat,
                          textColor : UIColor, color : UIColor ) -> UButton
    {
        let button = UButtonText( callbacks: buttonCallbacks!,
                                  type: UButtonType.Press,
                                  id: id, priority: 0,
                                  text: text, createNode: false,
                                  x: 0, y: 0,
                                  width: 0, height: 0,
                                  fontSize: fontSize,
                                  textColor: textColor, bgColor: color)
        mButtons.append(button)
        
        // SpriteKit
        clientNode.addChild( button.parentNode )
        
        isUpdate = true
        return button
    }
    
    /**
     * ダイアログを閉じるボタンを追加する
     * @param text
     */
    public func addCloseButton(text : String) {
        addCloseButton(text: text, textColor: UIColor.white, bgColor: UColor.Salmon)
    }
    
    public func addCloseButton(text : String, textColor : UIColor, bgColor : UIColor?) {
        
        var bgColor = bgColor
        if bgColor == nil {
            bgColor = UColor.makeColor(200,100,100)
        }
        
        let button = UButtonText(
            callbacks: self, type: UButtonType.Press,
            id: UDialogWindow.CloseDialogId, priority: 0,
            text: text, createNode: false,
            x: 0, y: 0,
            width: 0, height: 0,
            fontSize: UDraw.getFontSize(FontSize.M),
            textColor: textColor, bgColor: bgColor)
        
        mButtons.append(button)
        
        clientNode.addChild(button.parentNode)
        
        isUpdate = true
    }
    
    /**
     * アイコンボタンを追加
     */
    public func addImageButton(id : Int, imageName : ImageName,
                               pressedImageName : ImageName?,
                               width : CGFloat, height: CGFloat)
    {
        let button : UButtonImage =
            UButtonImage.createButton(
                callbacks: buttonCallbacks,
                id: id,
                priority:0,
                x:0, y: 0,
                width: width, height: height,
                imageName: imageName,
                pressedImageName: pressedImageName)
        
        mButtons.append(button)
        isUpdate = true
    }
    
    /**
     * 描画オブジェクトを追加する
     * 描画オブジェクトの配置はボタンより先
     * @param obj
     */
    public func addDrawable(obj : UDrawable) {
        mDrawables.append(obj)
    }
    
    /**
     * レイアウトを更新
     * ボタンの数によってレイアウトは自動で変わる
     */
    func updateLayout() {
        // ダイアログのアイテムは clientNode 以下に配置する
        clientNode.removeAllChildren()
        
        // タイトル、メッセージ
        var y : CGFloat = UDpi.toPixel(UDialogWindow.TEXT_MARGIN_V)
        if title != nil && mTitleView == nil {
            mTitleView = UTextView.createInstance(
                text: title!,
                fontSize: UDraw.getFontSize(FontSize.L),
                priority: 0,
                alignment: UAlignment.CenterX,
                createNode : true,
                multiLine: true, isDrawBG: false,
                x: size.width / 2, y: y,
                width: size.width - marginH * 2, color: .black, bgColor: nil)
            
            y += mTitleView!.getHeight() + UDpi.toPixel( UDialogWindow.MARGIN_V * 2)
        }
        
        // テキスト
        for textView in mTextViews {
            textView!.setPos( size.width / 2, y, convSKPos: false)
            y += textView!.getHeight() + UDpi.toPixel( UDialogWindow.MARGIN_V * 2 )
        }
        
        // Drawables
        for obj in mDrawables {
            obj!.setPos( (size.width - obj!.size.width) / 2, y, convSKPos: false)
            y += obj!.getHeight() + UDpi.toPixel( UDialogWindow.MARGIN_V )
        }
        
        // ボタン
        if buttonDir == ButtonDir.Horizontal {
            // ボタンを横に並べる
            // 画像ボタンのサイズはそのままにする
            // 固定サイズの画像ボタンと可変サイズのボタンが混ざっていても正しく配置させるためにいろいろ計算
            let num = mButtons.count
            var imageNum : Int = 0
            var imagesWidth : CGFloat = 0
            for button in mButtons {
                if button is UButtonImage {
                    let _button = button as! UButtonImage
                    imageNum += 1
                    imagesWidth += _button.getWidth()
                }
            }
            var buttonW : CGFloat = 0
            if num > imageNum {
                buttonW = (size.width - ((CGFloat(num + 1) * buttonMarginH) +
                    imagesWidth)) / CGFloat(num - imageNum)
            }
            var x : CGFloat = buttonMarginH
            var heightMax : CGFloat = 0
            var _height : CGFloat = 0
            for i in 0..<num {
                let button : UButton = mButtons[i]
                if button is UButtonImage {
                    let _button = button as! UButtonImage
                    _button.setPos(x, y, convSKPos: false)
                    x += _button.getWidth() + buttonMarginH
                    _height = _button.getHeight()
                    
                } else {
                    button.setPos(x, y, convSKPos: false)
                    button.setSize(buttonW, buttonH)
                    x += buttonW + buttonMarginH
                    _height = buttonH
                }
                
                if _height > heightMax {
                    heightMax = _height
                }
            }
            y += heightMax + buttonMarginH;
        }
        else {
            // ボタンを縦に並べる
            for button in mButtons {
                if button! is UButtonImage {
                    let _button = button! as! UButtonImage
                    
                    _button.setPos((size.width - _button.getWidth()) / 2, y, convSKPos: false)
                    y += button!.getHeight() + buttonMarginV
                } else {
                    button!.setPos(buttonMarginH, y, convSKPos: false)
                    button!.setSize(size.width - buttonMarginH * 2, buttonH)
                    y += buttonH + buttonMarginV
                }
            }
        }
        
        // ダイアログのサイズが決まったのでUWindowのノードを作成
        let margin = UDpi.toPixel(UDialogWindow.MARGIN_H)
        self.size = CGSize(width: screenSize.width - margin * 2, height: y)
        self.pos = CGPoint(x: margin, y: (screenSize.height - size.height) / 2)
        
        updateWindow()
        super.initSKNode()
        
        // SpriteKit のノードを生成
        if mTitleView != nil {
            clientNode.addChild2( mTitleView!.parentNode )
        }
        
        // テキスト
        // ダイアログに追加時にはレイアウトが決まっていなかったため、ここでノードを作成する
        for textView in mTextViews {
            textView!.initSKNode()
            clientNode.addChild2( textView!.parentNode )
        }
        
        // Drawables 
        for obj in mDrawables {
            obj!.initSKNode()
            clientNode.addChild2( obj!.parentNode )
        }
        
        // ボタン
        for button in mButtons {
            button!.initSKNode()
            clientNode.addChild2( button!.parentNode )
        }
        
        size.height = y;
    }
    
    /**
     * DrawManagerの描画リストに追加する
     */
    public override func addToDrawManager() {
        // レイアウト更新処理を寄生する
        updateLayout()
        
        super.addToDrawManager()
    }

    /**
     * 描画処理
     * @param canvas
     * @param paint
     * @param offset 独自の座標系を持つオブジェクトをスクリーン座標系に変換するためのオフセット値
     */
    override public func draw() {
        if (!isShow) {
            return
        }
        // Window内部
        let _pos = CGPoint(x: frameSize.width, y: frameSize.height + topBarH)
        drawContent(offset: _pos)
    }
    
    /**
     * コンテンツを描画する
     * @param canvas
     * @param paint
     */
    public func drawContent( offset : CGPoint ) {
        if animatingBgNode != nil {
            animatingBgNode!.removeFromParent()
            animatingBgNode = nil
        }
        
        // Title
        if mTitleView != nil {
            mTitleView!.draw()
        }
        
        // TextViews
        for textView in mTextViews {
            textView!.draw()
        }
        
        // Drawables 
        for obj in mDrawables {
            obj!.draw()
        }
        
        // Buttons
        for button in mButtons {
            button!.draw()
        }
    }
    
    public func getDialogRect() -> CGRect {
        return CGRect(x:pos.x, y:pos.y,
                      width: pos.x + size.width,
                      height: pos.y + size.height)
    }
    
    /**
     * タッチ処理
     * @param vt
     * @return
     */
    override public func touchEvent(vt : ViewTouch, offset : CGPoint?) -> Bool {
        let offset = pos
        
        var isRedraw : Bool = false
        
        if (super.touchEvent(vt: vt, offset: offset)) {
            return true
        }
        
        // タッチアップ処理(Button)
        for button in mButtons {
            if button!.touchUpEvent(vt: vt) {
                isRedraw = true
            }
        }
        // タッチアップ処理(Drawable)
        for obj in mDrawables {
            if obj!.touchUpEvent(vt: vt) {
                isRedraw = true
            }
        }
        
        // タッチ処理(Button)
        for button in mButtons {
            if button!.touchEvent(vt: vt, offset: offset) {
                return true
            }
        }
        
        // タッチ処理(Drawable)
        for obj in mDrawables {
            if obj!.touchEvent(vt: vt, offset: offset) {
                return true
            }
        }
        
        // 範囲外をタッチしたら閉じる
        if type == DialogType.Normal {
            if vt.type == TouchType.Touch {
                let point = CGPoint(x: vt.touchX, y: vt.touchY)
                if getDialogRect().contains(point) == false {
                    closeDialog()
                }
                return true
            }
        }
        // モーダルなら他のオブジェクトにタッチ処理を渡さない
        if (type == DialogType.Modal) {
            if (vt.type == TouchType.Touch ||
                vt.type == TouchType.LongPress ||
                vt.type == TouchType.Click ||
                vt.type == TouchType.LongClick )
            {
                return true;
            }
        }
        
        if (super.touchEvent2(vt:vt, offset:offset)) {
            return true;
        }
        
        return isRedraw;
    }
    
    public func startAnimation(type : AnimationType) {
        animationType = type
        startAnimation(frameMax: UDialogWindow.ANIMATION_FRAME )
    }
    
    public override func endAnimation() {
        if animationType == AnimationType.Closing {
            closeDialog()
        }
    }
    
    /**
     * ソフトウェアキーの戻るボタンを押したときの処理
     * @return
     */
    public func onBackKeyDown() -> Bool {
        if isShow {
            if isClosing() {
                return true
            }
            closeDialog()
            return true
        }
        return false
    }
    
    /**
     * UButtonCallbacks
     */
    public override func UButtonClicked(id : Int, pressedOn : Bool) -> Bool {
        switch(id) {
        case UDialogWindow.CloseButtonId:
            fallthrough
        case UDialogWindow.CloseDialogId:
            closeDialog()
            return true
        default:
            break
        }
        if super.UButtonClicked(id: id, pressedOn: pressedOn) {
            return true
        }
        return false
    }
}

