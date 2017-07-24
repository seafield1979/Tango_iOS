//
//  UDialogWindow.swift
//  UGui
//
//  Created by Shusuke Unno on 2017/07/08.
//  Copyright © 2017年 Shusuke Unno. All rights reserved.
//

import Foundation
import UIKit


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
    case Mordal     // 移動不可、下にあるWindowをタッチできない
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
    static let MARGIN_V : Int = 5
    static let ANIMATION_FRAME : Int = 10
    
    static let TEXT_MARGIN_V : Int = 17
    static let BUTTON_H : Int =  47
    static let BUTTON_MARGIN_H : Int = 17
    static let BUTTON_MARGIN_V : Int = 10
    
    //
    /**
     * Member variables
     */
    var basePos = CGPoint()       // Open/Close時の中心座標
    var type : DialogType
    var posType : DialogPosType
    var buttonDir : ButtonDir
    
    var textColor : UIColor
    var dialogColor : UIColor?
    var dialogBGColor : UIColor?
    
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
        if posType == DialogPosType.Point {
            basePos = CGPoint(x: pos.x + size.width / 2,
                              y: pos.y + size.height / 2)
        } else {
            basePos = CGPoint(x: screenSize.width / 2,
                              y: screenSize.height / 2)
        }
    }
    
    public func isClosing() -> Bool {
        return (animationType == AnimationType.Closing)
    }
    
    /**
     * Constructor
     */
    public init(parentView: TopView, type : DialogType, buttonCallbacks : UButtonCallbacks?,
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
        
        super.init(parentView: parentView, callbacks: nil, priority: DrawPriority.Dialog.rawValue,
                   x: x, y: y,
                   width: screenW, height: screenH,
                   bgColor: dialogColor,
                   topBarH : 0, frameW : 0, frameH : 0)
        
        size = CGSize(width: screenW - marginH * 2,
                      height: screenH - marginH * 2)
        
        
        if isAnimation {
            updateBasePos()
            startAnimation( type: AnimationType.Opening )
        }
        if (type == DialogType.Mordal) {
            dialogBGColor = UColor.makeColor(160,0,0,0)
        }        
    }
    
    // 座標指定タイプ
    public static func createInstance(
        parentView : TopView,
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
            parentView: parentView,
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
        parentView : TopView, 
        type : DialogType, buttonCallbacks : UButtonCallbacks?,
        dialogCallbacks : UDialogCallbacks?,
        dir : ButtonDir,
        posType : DialogPosType,
        isAnimation : Bool,
        screenW : CGFloat, screenH : CGFloat,
        textColor : UIColor, dialogColor : UIColor?) -> UDialogWindow
    {
        
        let instance = UDialogWindow(
            parentView: parentView,
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
        parentView: TopView,
        buttonCallbacks : UButtonCallbacks?,
        dialogCallbacks : UDialogCallbacks?,
        buttonDir : ButtonDir,
        screenW : CGFloat, screenH : CGFloat) -> UDialogWindow
    {
        return createInstance( parentView: parentView,
                            type: DialogType.Mordal,
                              buttonCallbacks: buttonCallbacks,
                              dialogCallbacks: dialogCallbacks,
                              dir: buttonDir,
                              posType: DialogPosType.Center,
                              isAnimation: true,
                              screenW: screenW, screenH: screenH,
                              textColor: UIColor.black, dialogColor: UIColor.lightGray)
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
        if dialogCallbacks != nil {
            dialogCallbacks!.dialogClosed(dialog: self)
        }
    }
    
    /**
     * 閉じるアニメーション開始
     */
    public func startClosing() {
        updateBasePos()
        
        if isAnimation {
            startAnimation(type: AnimationType.Closing)
        } else {
            closeDialog()
        }
    }
    
    /**
     * TextViewを追加
     */
    public func addTextView(text : String, alignment : UAlignment,
                            multiLine : Bool, isDrawBG : Bool,
                            textSize : Int, textColor : UIColor,
                            bgColor : UIColor? ) -> UTextView
    {
        var x : CGFloat = 0.0
        switch(alignment) {
        case .CenterX:
            fallthrough
        case .Center:
            x = size.width / 2
        case .CenterY:
            fallthrough
        case .None:
            x = marginH
        default:
            break
        }
        let textView : UTextView =
            UTextView.createInstance(text: text,
                                     textSize: textSize,
                                     priority: 0,
                                     alignment: alignment,
                                     multiLine: multiLine,
                                     isDrawBG: isDrawBG,
                                     x: x, y: 0,
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
    public func addButton(id : Int, text : String,
                          textColor : UIColor, color : UIColor ) -> UButton
    {
        let button = UButtonText( callbacks: buttonCallbacks!,
                                  type: UButtonType.Press,
                                  id: id, priority: 0,
                                  text: text,
                                  x: 0, y: 0,
                                  width: 0, height: 0,
                                  textSize: UDraw.getFontSize(FontSize.M),
                                  textColor: textColor, color: color)
        mButtons.append(button)
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
            text: text,
            x: 0, y: 0,
            width: 0, height: 0,
            textSize: UDraw.getFontSize(FontSize.M),
            textColor: textColor, color: bgColor)
        
        mButtons.append(button)
        isUpdate = true
    }
    
    /**
     * アイコンボタンを追加
     */
    public func addImageButton(id : Int, imageName : ImageName?,
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
        // タイトル、メッセージ
        var y : CGFloat = UDpi.toPixel(UDialogWindow.TEXT_MARGIN_V)
        if title != nil && mTitleView == nil {
            mTitleView = UTextView.createInstance(
                text: title!,
                textSize: UDraw.getFontSize(FontSize.L),
                priority: 0,
                alignment: UAlignment.CenterX,
                multiLine: true, isDrawBG: true,
                x: size.width / 2, y: y,
                width: size.width, color: color!, bgColor: nil)
            
            y += mTitleView!.getHeight() + UDpi.toPixel( UDialogWindow.MARGIN_V )
        }
        
        // テキスト
        for textView in mTextViews {
            textView!.setY(y)
            textView!.updateRect();
            y += textView!.getHeight() + UDpi.toPixel( UDialogWindow.MARGIN_V )
        }
        
        // Drawables
        // ダイアログの中央に配置
        for obj in mDrawables {
            obj!.setX((size.width - obj!.getWidth()) / 2)
            obj!.setY(y)
            obj!.updateRect()
            y += obj!.getHeight() + 20
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
                buttonW = (size.width - ((CGFloat(num + 1) * buttonMarginH) + imagesWidth))
                    / CGFloat(num - imageNum)
            }
            var x : CGFloat = buttonMarginH
            var heightMax : CGFloat = 0
            var _height : CGFloat = 0
            for i in 0...(num-1) {
                let button : UButton = mButtons[i]
                if button is UButtonImage {
                    let _button = button as! UButtonImage
                    _button.setPos(x, y)
                    x += _button.getWidth() + buttonMarginH
                    _height = _button.getHeight()
                } else {
                    button.setPos(x, y)
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
                    _button.setPos((size.width - _button.getWidth()) / 2, y)
                    y += button!.getHeight() + buttonMarginV
                } else {
                    button!.setPos(buttonMarginH, y)
                    button!.setSize(size.width - buttonMarginH * 2, buttonH)
                    y += buttonH + buttonMarginV
                }
            }
        }
        size.height = y;
        
        // センタリング
        pos.x = (screenSize.width - size.width) / 2;
        pos.y = (screenSize.height - size.height) / 2;
        updateRect();
    }
    
    /**
     * 描画処理
     * @param canvas
     * @param paint
     * @param offset 独自の座標系を持つオブジェクトをスクリーン座標系に変換するためのオフセット値
     */
    override public func draw(_ offset: CGPoint?) {
        if (!isShow) {
            return
        }
        if (isUpdate) {
            isUpdate = false
            updateLayout()
        }
        
        // BG のブラインド
        if type == DialogType.Mordal {
            UDraw.drawRectFill( rect: CGRect(x:0, y:0,
                                             width: screenSize.width,
                                             height: screenSize.height),
                                color: dialogBGColor!,
                                strokeWidth: 0,
                                strokeColor: nil);
        }
        
        // Window内部
        var _pos = CGPoint(x: frameSize.width, y: frameSize.height + topBarH)
        if offset != nil {
            _pos.x += offset!.x
            _pos.y += offset!.y
        }
        drawContent(offset: _pos)
    }
    
    /**
     * コンテンツを描画する
     * @param canvas
     * @param paint
     */
    public func drawContent( offset : CGPoint ) {
        if isAnimating {
            // Open/Close animation
            var ratio : CGFloat = 0
            if animationType == AnimationType.Opening {
                ratio = sin(animeRatio * 90 * UDrawable.RAD)
            } else {
                ratio = cos(animeRatio * 90 * UDrawable.RAD)
            }
            
            var width, height, x, y : CGFloat
            var _rect : CGRect
            
            width = size.width * ratio
            height = size.height * ratio
            x = basePos.x - width / 2
            y = basePos.y - height / 2
            _rect = CGRect(x: x, y: y, width: width, height: height)
            
            drawBG(rect: _rect)
        } else {
            // BG
            drawBG(rect: rect!)
            let _offset : CGPoint = pos
            
            // Title
            if mTitleView != nil {
                mTitleView!.draw(_offset)
            }
            
            // TextViews
            for textView in mTextViews {
                textView!.draw(_offset)
            }
            
            // Drawables
            for obj in mDrawables {
                obj!.draw(_offset)
            }
            // Buttons
            for button in mButtons {
                button!.draw(_offset)
            }
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
                    startClosing()
                }
                return true
            }
        }
        // モーダルなら他のオブジェクトにタッチ処理を渡さない
        if (type == DialogType.Mordal) {
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
            if isAnimation {
                startClosing()
            } else {
                closeDialog()
            }
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
            if (isAnimation) {
                startClosing()
            } else {
                closeDialog()
            }
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
