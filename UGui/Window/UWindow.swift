//
//  UWindow.swift
//  UGui
//  Viewの中に表示できるWindow
//  座標、サイズを持ち自由に配置が行える
//
//  Created by Shusuke Unno on 2017/07/08.
//  Copyright © 2017年 Shusuke Unno. All rights reserved.
//

import Foundation
import UIKit

/**
 * Enums
 */
public enum CloseIconPos {
    case LeftTop
    case RightTop
}

// スクロールバーの表示タイプ
public enum WindowSBShowType {
    case Hidden             // 非表示
    case Show               // 表示
    case Show2              // 表示(スクロール中のみ表示)
    case ShowAllways        // 常に表示
}

/**
 * UWindow呼び出し元に通知するためのコールバック
 */
public protocol UWindowCallbacks {
    func windowClose(window : UWindow)
}


public class UWindow : UDrawable, UButtonCallbacks {
    
    /**
     * Consts
     */
    public static let CloseButtonId : Int = 1000123
    
    static let SCROLL_BAR_W : Int = 17;
    static let TOP_BAR_COLOR = UColor.makeColor(100, 100, 200)
    static let FRAME_COLOR : UIColor? = nil
    private static let TOUCH_MARGIN : Int = 13
    private static let BG_RADIUS : Int = 7
    private static let BG_FRAME_W : Int = 1
    
    /**
     * Member Variables
     */
    var windowCallbacks : UWindowCallbacks? = nil
    var parentView : TopView? = nil
    var bgColor : UIColor? = nil
    var frameColor : UIColor? = nil
    
    var contentSize = CGSize()     // 領域全体のサイズ
    var clientSize = CGSize()      // ウィンドウの幅からスクロールバーのサイズを引いたサイズ
    var topBarH : CGFloat = 0      // ウィンドウ上部のバーの高さ
    var topBarColor : UIColor? = nil
    var frameSize = CGSize()       // ウィンドウのフレームのサイズ
    var contentTop = CGPoint()  // クライアント領域のうち画面に表示する領域の左上の座標
    var mScrollBarH : UScrollBar?
    var mScrollBarV : UScrollBar?
    var closeIcon : UButtonClose?            // 閉じるボタン
    var closeIconPos : CloseIconPos?     // 閉じるボタンの位置
    var  mSBType : WindowSBShowType
    
    /**
     * Get/Set
     */
    public func setPos(x : CGFloat, y : CGFloat, update : Bool) {
        pos.x = x
        pos.y = y
        if (update) {
            updateRect()
        }
    }
    public func getClientSize() -> CGSize {
        return size
    }
    public func getClientRect() -> CGRect {
        // スクロールバーをタッチしやすいように少し領域を広げる
        let touchMargin = UDpi.toPixel(UWindow.TOUCH_MARGIN)
        return CGRect(x: frameSize.width - touchMargin,
                      y: frameSize.height + topBarH - touchMargin,
                      width: clientSize.width + touchMargin * 2,
                      height: clientSize.height + touchMargin * 2)
    }
    
    public func getContentTop() -> CGPoint {
        return contentTop
    }
    
    public func setContentTop(contentTop : CGPoint) {
        self.contentTop = contentTop
    }
    
    public func setContentTop(x: CGFloat, y: CGFloat) {
        contentTop.x = x
        contentTop.y = y
    }
    
    public func setFrameColor(frameColor : UIColor?) {
        self.frameColor = frameColor
    }
    
    public func setTopBar(height : CGFloat, color : UIColor?) {
        topBarH = height
        topBarColor = color
    }
    
    public func setFrame(size : CGSize, color : UIColor?) {
        self.frameSize = size
        self.frameColor = color
    }
    
    public func getWindowCallbacks() -> UWindowCallbacks? {
        return windowCallbacks
    }
    
    // 座標系を変換する
    // 座標系は以下の３つある
    // 1.Screen座標系  画面上の左上原点
    // 2.Window座標系  ウィンドウ左上原点 + スクロールして表示されている左上が原点
    
    // Screen座標系 -> Window座標系
    public func toWinX(screenX : CGFloat) -> CGFloat {
        return screenX + contentTop.x - pos.x
    }
    
    public func toWinY(screenY : CGFloat) -> CGFloat {
        return screenY + contentTop.y - pos.y
    }
    
    public func getToWinPos() -> CGPoint {
        return CGPoint(x: contentTop.x - pos.x, y: contentTop.y - pos.y)
    }
    
    // Windows座標系 -> Screen座標系
    public func toScreenX(winX : CGFloat) -> CGFloat {
        return winX - contentTop.x + pos.x
    }
    
    public func toScreenY(winY : CGFloat) -> CGFloat {
        return winY - contentTop.y + pos.y
    }
    
    public func getToScreenPos() -> CGPoint {
        return CGPoint(x: -contentTop.x + pos.x,
                       y: -contentTop.y + pos.y)
    }
    
    // Window1の座標系から Window2の座標系に変換
    public func win1ToWin2X(win1X : CGFloat, win1 : UWindow, win2 : UWindow) -> CGFloat
    {
        return win1X + win1.pos.x - win1.contentTop.x - win2.pos.x + win2.contentTop.x
    }
    
    public func win1ToWin2Y(win1Y : CGFloat, win1 : UWindow, win2 : UWindow) -> CGFloat {
        return win1Y + win1.pos.y - win1.contentTop.y - win2.pos.y + win2.contentTop.y
    }
    
    public func getWin1ToWin2( win1 : UWindow, win2 : UWindow) -> CGPoint {
        return CGPoint(
            x: win1.pos.x - win1.contentTop.x - win2.pos.x + win2.contentTop.x,
            y: win1.pos.y - win1.contentTop.y - win2.pos.y + win2.contentTop.y
        )
    }
    
    /**
     * Constructor
     */
    /**
     * 外部からインスタンスを生成できないようにprivateでコンストラクタを定義する
     */
    convenience init(parentView : TopView, callbacks: UWindowCallbacks?, priority : Int,
         x : CGFloat, y : CGFloat, width : CGFloat, height : CGFloat,
         bgColor : UIColor?)
    {
        self.init(parentView : parentView,
                  callbacks: callbacks!, priority: priority,
             x: x, y: y, width: width, height: height,
             bgColor: bgColor, topBarH: 0, frameW: 0, frameH: 0)
    }
    
    init(parentView: TopView, callbacks: UWindowCallbacks?, priority : Int,
         x : CGFloat, y : CGFloat, width : CGFloat, height : CGFloat,
         bgColor : UIColor?, topBarH : CGFloat, frameW : CGFloat, frameH : CGFloat)
    {
        self.windowCallbacks = callbacks
        self.parentView = parentView
        self.bgColor = bgColor
        self.mSBType = WindowSBShowType.Show2
        self.clientSize.width = width - frameW * 2
        self.clientSize.height = height - topBarH - frameH * 2
        self.topBarH = topBarH
        self.topBarColor = UWindow.TOP_BAR_COLOR
        self.frameSize = CGSize(width: frameW, height: frameH)
        self.frameColor = UWindow.FRAME_COLOR
        
        super.init(priority: priority, x: x,y: y,width: width,height: height)
        
        updateRect()
        
        // ScrollBar
        var showType = ScrollBarShowType.Show
        switch(mSBType) {
        case .Show:               // 表示
            showType = ScrollBarShowType.Show
            
        case .Show2:              // 表示(スクロール中のみ表示)
            showType = ScrollBarShowType.Show2
            
        case .ShowAllways:        // 常に表示
            showType = ScrollBarShowType.ShowAllways
        default:
            break
        }
        
        if (mSBType != WindowSBShowType.Hidden) {
            let scrollBarW = UDpi.toPixel(UWindow.SCROLL_BAR_W)
        
            mScrollBarV = UScrollBar(
                type: ScrollBarType.Vertical,
                showType: showType, parentPos: pos,
                x: size.width - frameSize.width - scrollBarW,
                y: frameSize.height + topBarH,
                bgLength: clientSize.height,
                bgWidth: scrollBarW,
                pageLen: height - scrollBarW,
                contentLen: contentSize.height)
            
            mScrollBarH = UScrollBar(
                type: ScrollBarType.Horizontal,
                showType: showType, parentPos: pos,
                x: frameSize.width,
                y: size.height - frameSize.height - scrollBarW,
                bgLength: clientSize.width,
                bgWidth: scrollBarW,
                pageLen: width - scrollBarW,
                contentLen: contentSize.width)
        }
    }
    
    /**
     * Methods
     */
    
    /**
     * Windowのサイズを更新する
     * サイズ変更に合わせて中のアイコンを再配置する
     * @param width
     * @param height
     */
    public func setSize(width : CGFloat, height : CGFloat, update : Bool) {
        super.setSize(width, height)
        
        if update {
            updateWindow()
        }
        
        // 閉じるボタン
        updateCloseIconPos();
    }
    
    public func setContentSize(width : CGFloat, height : CGFloat, update : Bool) {
        contentSize.width = width
        contentSize.height = height
        
        if (update) {
            updateWindow()
        }
    }
    
    public func updateWindow() {
        // clientSize
        if (clientSize.width < contentSize.width &&
            mSBType != WindowSBShowType.Show2)
        {
            clientSize.height = size.height - mScrollBarH!.getBgWidth()
        }
        if (clientSize.height < contentSize.height &&
            mSBType != WindowSBShowType.Show2)
        {
            clientSize.width = size.width - mScrollBarV!.getBgWidth()
        }
        
        // スクロールバー
        if mScrollBarV != nil {
            mScrollBarV!.setPageLen(pageLen: clientSize.height)
            mScrollBarV!.updateSize()
            contentTop.y = CGFloat(mScrollBarV!.updateContent(contentSize: contentSize.height))
        }
        if (mScrollBarH != nil) {
            mScrollBarH!.setPageLen(pageLen: clientSize.width)
            mScrollBarH!.updateSize()
            contentTop.x = CGFloat(mScrollBarH!.updateContent(contentSize: contentSize.width))
        }
    }
    
    
    /**
     * Windowを閉じるときの処理
     */
    public func closeWindow() {
        // 描画オブジェクトから削除する
        if (drawList != nil) {
            UDrawManager.getInstance().removeDrawable(self)
        }
    }
    
    /**
     * 毎フレーム行う処理
     *
     * @return true:描画を行う
     */
    public override func doAction() -> DoActionRet {
        // 抽象メソッド
        return DoActionRet.None
    }
    
    /**
     * 描画
     * @param canvas
     * @param paint
     * @param offset 独自の座標系を持つオブジェクトをスクリーン座標系に変換するためのオフセット値
     */
    override public func draw(_ offset : CGPoint?) {
        if (!isShow) {
            return
        }
        
        // BG
        if bgColor != nil {
            if offset != nil {
                drawBG(offset: offset!)
            } else {
                drawBG()
            }
        }
        
        // Window内部
        var _pos : CGPoint = CGPoint(x: frameSize.width, y: frameSize.height + topBarH)
        if offset != nil {
            _pos.x += offset!.x
            _pos.y += offset!.y
        }
        drawContent(offset: _pos)
        
        // Window枠
        drawFrame(offset: offset!)
    }
    
    /**
     * コンテンツを描画する
     * @param canvas
     * @param paint
     */
    public func drawContent(offset : CGPoint?) {
        // 抽象クラス　サブクラスでオーバーライドして使用する
    }
    
    /**
     * Windowの背景を描画する
     * @param canvas
     * @param paint
     * @param rect
     */
    public func drawBG(rect : CGRect) {
        let frameWidth = (frameColor == nil) ? 0 : UDpi.toPixel(UWindow.BG_FRAME_W)
        
        UDraw.drawRoundRectFill( rect: rect,
                                 cornerR: UDpi.toPixel(UWindow.BG_RADIUS),
                                 color: bgColor!,
                                 strokeWidth: frameWidth, strokeColor: frameColor)
    }
    
    public func drawBG() {
        self.drawBG(rect: rect!)
    }
    
    public func drawBG( offset : CGPoint) {
        self.drawBG(rect: CGRect(x: offset.x + rect!.left,
                                 y: offset.y + rect!.top,
                                 width: rect!.width,
                                 height: rect!.height))
    }
    
    /**
     * Windowの枠やバー、ボタンを描画する
     * @param canvas
     * @param paint
     */
    public func drawFrame(offset: CGPoint?) {
        var _pos : CGPoint = CGPoint(x: pos.x, y: pos.y)
        if offset != nil {
            _pos.x += offset!.x
            _pos.y += offset!.y
        }
        // Frame
        if (frameSize.width > 0 && frameColor != nil) {
            // 左右
            UDraw.drawRectFill( rect: CGRect(x: _pos.x, y: _pos.y,
                                       width: frameSize.width, height: size.height),
                                color: frameColor!,
                                strokeWidth: 0, strokeColor: nil)
            UDraw.drawRectFill( rect: CGRect(x: _pos.x + size.width - frameSize.width,
                                             y: _pos.y,
                                             width: size.width,
                                             height: size.height),
                                color:frameColor!,
                                strokeWidth: 0, strokeColor: nil)
        }
        
        if (frameSize.height > 0 && frameColor != nil) {
            // 上下
            UDraw.drawRectFill( rect: CGRect(x: _pos.x, y: _pos.y,
                                             width: size.width,
                                             height: frameSize.height),
                                color: frameColor!,
                                strokeWidth: 0, strokeColor: nil)
            UDraw.drawRectFill( rect: CGRect(x: _pos.x, y: _pos.y + size.height - frameSize.height,
                                             width: size.width,
                                             height: size.height),
                                color:frameColor!,
                                strokeWidth: 0, strokeColor: nil);
        }
        
        // TopBar
        if (topBarH > 0 && topBarColor != nil) {
            UDraw.drawRectFill( rect: CGRect(x: _pos.x, y: _pos.y + frameSize.height,
                                             width: size.width - frameSize.width,
                                             height: frameSize.height + topBarH),
                                color: topBarColor!,
                                strokeWidth: 0,
                                strokeColor: nil)
        }
        
        // Close Button
        if (closeIcon != nil && closeIcon!.isShow) {
            closeIcon!.draw(_pos);
        }
        
        // スクロールバー
        if (mScrollBarV != nil && mScrollBarV!.isShow()) {
            
            mScrollBarV!.draw(offset: offset)
        }
        if (mScrollBarH != nil && mScrollBarH!.isShow()) {
            mScrollBarH!.draw(offset: offset)
        }
    }
    
    public override func autoMoving() -> Bool {
        // Windowはサイズ変更時にclientSizeも変更する必要がある
        if (!isMoving) {
            return false
        }
        
        let ret : Bool = super.autoMoving()
        
        clientSize = size
        
        if (mScrollBarH != nil) {
            mScrollBarH?.setBgLength(bgLength: clientSize.width)
        }
        if (mScrollBarV != nil) {
            mScrollBarV?.setBgLength(bgLength: clientSize.height)
        }
        updateWindow();
        
        return ret;
    }
    
    
    /**
     * Viewをスクロールする処理
     * Viewの空きスペースをドラッグすると表示領域をスクロールすることができる
     * @param vt
     * @return
     */
    func scrollView(vt : ViewTouch) -> Bool {
        if (vt.type != TouchType.Moving) {
            return false
        }
        
        // タッチの移動とスクロール方向は逆
        let moveX = vt.moveX * (-1)
        let moveY = vt.moveY * (-1)
        
        // 横
        if (size.width < contentSize.width) {
            contentTop.x += moveX
            if (contentTop.x < 0) {
                contentTop.x = 0
            } else if (contentTop.x + size.width > contentSize.width) {
                contentTop.x = contentSize.width - size.width
            }
        }
        
        // 縦
        if (size.height < contentSize.height) {
            contentTop.y += moveY
            if (contentTop.y < 0) {
                contentTop.y = 0
            } else if (contentTop.y + size.height > contentSize.height) {
                contentTop.y = contentSize.height - size.height
            }
        }
        // スクロールバーの表示を更新
        mScrollBarV!.updateScroll(pos: contentTop.y)
        
        return true;
    }
    
    /**
     * タッチイベント処理、子クラスのタッチイベント処理より先に呼び出す
     * @param vt
     * @return true:再描画
     */
    public override func touchEvent(vt : ViewTouch, offset : CGPoint?) -> Bool {
        
        var offset = offset
        if offset == nil {
            offset = CGPoint(x: offset!.x, y: offset!.y)
        }
        offset!.x += pos.x
        offset!.y += pos.y
        
        if closeIcon != nil && closeIcon!.isShow {
            if (closeIcon!.touchEvent(vt: vt, offset: offset)) {
                return true
            }
        }
        
        // スクロールバーのタッチ処理
        if mScrollBarV != nil && mScrollBarV!.isShow(){
            if ( mScrollBarV!.touchEvent(vt: vt, offset: offset!)) {
                contentTop.y = CGFloat(mScrollBarV!.getTopPos())
                return true
            }
        }
        if mScrollBarH != nil && mScrollBarH!.isShow() {
            if  mScrollBarH!.touchEvent(vt: vt, offset: offset!) {
                contentTop.x = CGFloat(mScrollBarH!.getTopPos())
                return true;
            }
        }
        return false;
    }
    
    /**
     * 子クラスのタッチ処理の後に呼び出すタッチイベント
     * @param vt
     * @param offset
     * @return
     */
    public func touchEvent2(vt : ViewTouch, offset : CGPoint?) -> Bool {
        // 配下にタッチイベントを送らないようにウィンドウ内がタッチされたらtureを返す
        var offset = offset
        if offset == nil {
            offset = CGPoint()
        }
        
        let point = CGPoint(x: vt.touchX(offset: offset!.x),
                            y: vt.touchY(offset: offset!.y))
        if (rect!.contains(point)) {
            return true;
        }
        return false;
    }
    
    /**
     * アイコンタイプの閉じるボタンを追加する
     */
    func addCloseIcon() {
        self.addCloseIcon(pos: CloseIconPos.LeftTop);
    }
    func addCloseIcon(pos : CloseIconPos) {
        if (closeIcon != nil) {
            return
        }
        
        closeIconPos = pos
        
        closeIcon = UButtonClose(callbacks: self,
                                 type: UButtonType.Press,
                                 id: UWindow.CloseButtonId,
                                 priority: 0,
                                 x: 0, y: 0,
                                     color: UColor.makeColor(255,0,0))
        updateCloseIconPos()
    }
    
    /**
     * 閉じるボタンの座標を更新
     * ※Windowが移動したり、サイズが変わった時に呼び出される
     */
    func updateCloseIconPos() {
        if closeIcon == nil {
            return
        }
        
        var x, y : CGFloat
        let MARGIN : Int = 4
        y = UDpi.toPixel(MARGIN)
        if (closeIconPos == CloseIconPos.LeftTop) {
            x = UDpi.toPixel(UButtonClose.BUTTON_W + MARGIN);
        } else {
            x = size.width - UDpi.toPixel(UButtonClose.BUTTON_W + MARGIN);
        }
        
        closeIcon?.setPos(x, y)
    }
    
    /**
     * 移動が完了した時の処理
     */
    public override func endMoving() {
        super.endMoving()
    }
    
    /**
     * UButtonCallbacks
     */
    
    public func UButtonClicked(id : Int, pressedOn : Bool) -> Bool {
        switch (id) {
        case UWindow.CloseButtonId:
            // 閉じるボタンを押したら自身のWindowを閉じてから呼び出し元の閉じる処理を呼び出す
            if (windowCallbacks != nil) {
                windowCallbacks!.windowClose(window: self)
            } else {
                closeWindow()
            }
            return true
        default:
            break
        }
        return false
    }
}
