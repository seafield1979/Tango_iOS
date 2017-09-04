//
//  UWindow.swift
//  UGui
//  Viewの中に表示できるWindow
//  座標、サイズを持ち自由に配置が行える
//
//  Created by Shusuke Unno on 2017/07/08.
//  Copyright © 2017年 Shusuke Unno. All rights reserved.
//

import SpriteKit

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
    static let FRAME_COLOR : UIColor? = .darkGray
    private static let TOUCH_MARGIN : Int = 13
    private static let BG_RADIUS : Int = 7
    private static let BG_FRAME_W : Int = 1
    private let FRAME_LINE_W = 2
    
    /**
     * Member Variables
     */
    // SpriteKit nodes
    var frameNode : SKShapeNode?
    var bgNode : SKShapeNode
    var cropNode : SKCropNode?
    var clientNode : SKNode           // スクロールする子ノードの親
    var animatingBgNode : SKShapeNode?  // アニメーション中のBG
    
    var windowCallbacks : UWindowCallbacks? = nil
    var topScene : TopScene
    var bgColor : UIColor? = nil
    var frameColor : UIColor? = nil
    var mCropping : Bool
    var mCornerRadius : CGFloat = 0
    
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
     * Constructor
     */
    /**
     * 外部からインスタンスを生成できないようにprivateでコンストラクタを定義する
     */
    convenience init(topScene : TopScene, callbacks: UWindowCallbacks?, priority : Int,
                     createNode: Bool, cropping: Bool,
                     x : CGFloat, y : CGFloat, width : CGFloat, height : CGFloat,
                     bgColor : UIColor?, cornerRadius : CGFloat)
    {
        self.init(topScene : topScene,
                  callbacks: callbacks!, priority: priority,
                  createNode : createNode, cropping: cropping,
                  x: x, y: y, width: width, height: height,
                  bgColor: bgColor, topBarH: 0, frameW: 0, frameH: 0,
                  cornerRadius : cornerRadius)
    }
    
    init(topScene: TopScene, callbacks: UWindowCallbacks?, priority : Int,
         createNode : Bool, cropping : Bool,
         x : CGFloat, y : CGFloat, width : CGFloat, height : CGFloat,
         bgColor : UIColor?, topBarH : CGFloat, frameW : CGFloat, frameH : CGFloat,
         cornerRadius : CGFloat)
    {
        self.windowCallbacks = callbacks
        self.topScene = topScene
        self.bgColor = bgColor
        self.mSBType = WindowSBShowType.Show2
        self.clientSize.width = width - frameW * 2
        self.clientSize.height = height - topBarH - frameH * 2
        self.topBarH = topBarH
        self.topBarColor = UWindow.TOP_BAR_COLOR
        self.frameSize = CGSize(width: frameW, height: frameH)
        self.frameColor = UWindow.FRAME_COLOR
        self.mCropping = cropping
        self.mCornerRadius = cornerRadius
        
        clientNode = SKNode()
        bgNode = SKShapeNode()
        
        super.init(priority: priority, x: x,y: y,width: width,height: height)
        
        if createNode {
            initSKNode()
        }
    }
    
    /**
     * SpriteKitノードを生成
     */
    public override func initSKNode() {
        parentNode.removeAllChildren()
        
        // parent
        parentNode.zPosition = CGFloat(drawPriority)
        parentNode.position = CGPoint(x:pos.x, y: pos.y)
        
        // frame
        if frameColor != nil && (frameSize.width > 0 || (topBarH + frameSize.height) > 0) {
            frameNode = SKShapeNode(rect: CGRect(x: 0, y: 0, width: size.width, height: size.height).convToSK(), cornerRadius: mCornerRadius)
            if bgColor != nil {
                frameNode!.fillColor = bgColor!
            }
            frameNode!.strokeColor = frameColor!
            frameNode!.lineWidth = UDpi.toPixel(FRAME_LINE_W)
            parentNode.addChild2(frameNode!)
        }
        
        // bg
        let radius = (frameNode == nil) ? mCornerRadius : 0
        bgNode = SKShapeNode(rect:
            CGRect(x: 0, y: 0,
                   width: clientSize.width, height: clientSize.height).convToSK(),
                             cornerRadius: radius)
        bgNode.position = CGPoint(x: frameSize.width,
                                  y: topBarH + frameSize.height)
        if bgColor != nil {
            bgNode.fillColor = bgColor!
        }
        bgNode.strokeColor = .clear
        parentNode.addChild2( bgNode )
        
        // crop
        if mCropping {
            let maskNode = SKShapeNode(rect: CGRect(x:0, y:0, width: clientSize.width, height: clientSize.height).convToSK())
            maskNode.fillColor = .black
            maskNode.strokeColor = .clear
            
            cropNode = SKCropNode()
            cropNode!.maskNode = maskNode
            cropNode!.position = bgNode.position
            parentNode.addChild(cropNode!)
        }
        
        // clientNode
        clientNode.position = CGPoint()
        clientNode.zPosition = 0.1
        
        if mCropping {
            cropNode!.addChild( clientNode )
        } else {
            bgNode.addChild( clientNode )
        }
        
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
                y: topBarH + frameSize.height,
                bgLength: clientSize.height,
                bgWidth: scrollBarW,
                pageLen: size.height - scrollBarW,
                contentLen: contentSize.height)
            parentNode.addChild( mScrollBarV!.parentNode )
            
            mScrollBarH = UScrollBar(
                type: ScrollBarType.Horizontal,
                showType: showType, parentPos: pos,
                x: frameSize.width,
                y: size.height - frameSize.height - scrollBarW,
                bgLength: clientSize.width,
                bgWidth: scrollBarW,
                pageLen: size.width - scrollBarW,
                contentLen: contentSize.width)
            parentNode.addChild( mScrollBarH!.parentNode )
        }
    }
    

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
    
    public func setFrameColor(_ color : UIColor?) {
        self.frameColor = color
        if color != nil {
            if self.bgColor != nil {
                self.frameNode!.fillColor = bgColor!
            }
            self.frameNode!.strokeColor = color!
        }
    }
    
    public func setFrameLineColor( _ color : UIColor? ) {
        self.frameColor = color
        if color != nil {
            self.frameNode!.strokeColor = color!
        }
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
        self.clientSize.width = size.width - frameSize.width * 2
        self.clientSize.height = size.height - topBarH - frameSize.height * 2
        
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
        parentNode.removeFromParent()
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
    override public func draw() {
        parentNode.isHidden = !isShow
        if !isShow {
            return
        }
        
        // Window内部
        let _pos : CGPoint = CGPoint(x: frameSize.width, y: frameSize.height + topBarH)
        
        drawContent(offset: _pos)
        
        // Window枠
        drawFrame()
    }
    
    /**
     * コンテンツを描画する
     * @param canvas
     * @param paint
     */
    public func drawContent(offset : CGPoint?) {
        // 抽象クラス　サブクラスでオーバーライドして使用する
        clientNode.position = CGPoint(x: -contentTop.x, y: -contentTop.y).convToSK()
    }
    
    /**
     * Windowの枠やバー、ボタンを描画する
     * @param canvas
     * @param paint
     */
    public func drawFrame() {
        // 閉じるボタン
        if closeIcon != nil {
            closeIcon!.draw()
        }
        
        // スクロールバー
        if (mScrollBarV != nil && mScrollBarV!.isShow()) {
            mScrollBarV!.draw()
        } else {
            
        }
        if (mScrollBarH != nil && mScrollBarH!.isShow()) {
            mScrollBarH!.draw()
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
            offset = pos
        }
//        offset!.x += pos.x
//        offset!.y += pos.y
        
        if closeIcon != nil && closeIcon!.isShow {
            if (closeIcon!.touchEvent(vt: vt, offset: offset)) {
                return true
            }
        }
        
        // スクロールバーのタッチ処理
        if mScrollBarV != nil && mScrollBarV!.isShow(){
            if ( mScrollBarV!.touchEvent(vt: vt, offset: offset)) {
                contentTop.y = CGFloat(mScrollBarV!.getTopPos())
                return true
            }
        }
        if mScrollBarH != nil && mScrollBarH!.isShow() {
            if  mScrollBarH!.touchEvent(vt: vt, offset: offset) {
                contentTop.x = CGFloat(mScrollBarH!.getTopPos())
                return true;
            }
        }
        
        // test
        // アイテムのタッチ処理
//        for item in mItems2 {
//            let offsetX = offset!.x - contentTop.x
//            let offsetY = offset!.y - contentTop.y
//            
//            if vt.isTouchUp {
//                if CGRect(x: item.pos.x + offsetX, y: item.pos.y + offsetY,
//                          width: item.size.width, height: item.size.height).contains(CGPoint(x: vt.touchX, y: vt.touchY))
//                {
//                    print("touch: \(item.name)")
//                    break
//                }
//            }
//        }
        
        return false
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
        if (rect.contains(point)) {
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
        bgNode.addChild( closeIcon!.parentNode )
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
        let margin = UDpi.toPixel(5)
        y = margin
        if (closeIconPos == CloseIconPos.LeftTop) {
            x = margin
        } else {
            x = size.width - closeIcon!.size.width - margin * 2
        }
        
        closeIcon?.setPos(x, y, convSKPos : true)
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
