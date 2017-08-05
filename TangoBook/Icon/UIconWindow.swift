//
//  UIcon.swift
//  TangoBook
//      Windows for Icons
//      Window can include many icons
//  Created by Shusuke Unno on 2017/07/25.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import UIKit

/**
 * Window state
 * Window behavior is changed by state.
 */
public enum WindowState : Int, EnumEnumerable {
    case none
    case drag               // single icon draging
    case icon_moving        // icons moving (icons sort animation)
    case icon_selecting     // icons can be selected
}

/**
 * Type of icon window
 * Home is a window that shows desktop icons
 * Sub is a window that shows icons which in a box
 */
public enum WindowType : Int, EnumEnumerable {
    case Home
    case Sub
}

/**
 * Window directions
 * If screen width is longer than height, it is Horizontal
 * If screen height is longer than width, it is Vertical
 */
public enum WindowDir : Int, EnumEnumerable {
    case Horizontal
    case Vertical
}

/**
 * Icon moving type
 */
public enum IconMovingType : Int, EnumEnumerable {
    case Exchange       // exchange A and B
    case Insert         // insert A before B
    case MoveIn          // move A into B
}

/**
 * dragEndNormalInsert の戻り値
 */
public struct ReturnValueDragEnd {
    var dropedIcon : UIcon? = nil
    var movingType : IconMovingType = IconMovingType.MoveIn
    var isDroped : Bool = false
}

public class UIconWindow : UWindow{
   /**
    * Consts
    */
    public static let TAG = "UIconWindow"

    public let DRAW_PRIORITY = 100
    public let DRAG_ICON_PRIORITY = 11

    public let ICON_MARGIN = 10

    public static let ICON_W = 57
    public static let ICON_H = 50
    let MARGIN_D = UMenuBar.MENU_BAR_H

    let MOVING_TIME = 10
    let SELECTED_ICON_BG_COLOR = UColor.makeColor(80, 255, 100, 100)


    /**
    * Member veriables
    */
    var type = WindowType.Home
    public var mIconManager : UIconManager? = nil
    var basePos : CGPoint = CGPoint()
    var dir = WindowDir.Horizontal

    // 他のIconWindow
    // ドラッグで他のWindowにアイコンを移動するのに使用する
    var windows : UIconWindows? = nil

    // Windowの親のタイプ
    var parentType = TangoParentType.Home
    var parentId : Int = 0

    // ドラッグ中のアイコン
    var dragedIcon : UIcon? = nil

    var state = WindowState.none;
    var nextState = WindowState.none;

    var isDragMove : Bool = false
    var isDropInBox : Bool = false
    var isAppearance : Bool = true       // true:出現中 / false:退出中

    // DPI補正の計算結果を保持するヘンス
    var iconMargin : CGFloat = 0;               // アイコン間のマージン
    var iconW : CGFloat = 0, iconH : CGFloat = 0    // アイコンサイズ

    /**
    * Get/Set
    */
    public func getType() -> WindowType {
        return type
    }
    public func setType(_ type : WindowType) {
        self.type = type
    }

    public func getBasePos() -> CGPoint {
        return basePos
    }

    public func getIconManager() -> UIconManager?{
        return mIconManager
    }
    public func setIconManager(_ mIconManager : UIconManager?) {
        self.mIconManager = mIconManager
    }

    public func getIcons() -> List<UIcon>? {
        if mIconManager == nil {
            return nil
        }
        return mIconManager!.getIcons()
    }

    public func setWindows(_ windows : UIconWindows? ) {
        self.windows = windows
    }

    public func getWindows() -> UIconWindows? {
        return self.windows
    }

    public func setAnimating(_ animating : Bool) {
        isAnimating = animating
    }

    public func setDragedIcon(_ dragedIcon : UIcon?) {
        if dragedIcon == nil {
            if self.dragedIcon != nil {
                UDrawManager.getInstance().removeDrawable(self.dragedIcon!)
            }
        }
        else {
            _ = UDrawManager.getInstance().addWithNewPriority(obj: dragedIcon!, priority: DrawPriority.DragIcon.rawValue)
        }
        self.dragedIcon = dragedIcon
    }

    public override func setPos(_ x : CGFloat, _ y : CGFloat) {
        super.setPos(x,y)
        ULog.printMsg(UIconWindow.TAG, String(format:"x:%f y:%f",x, y))
    }

    public func setAppearance(_ appearance : Bool) {
        isAppearance = appearance
    }

    public func getParentType() -> TangoParentType {
        return parentType
    }
    public func getParentId() -> Int {
        return parentId
    }

    /**
    * 状態を設定する
    * 状態に移る時の前処理、後処理を実行できる
    * @param state
    */
    public func setState(_ state : WindowState) {
        if self.state == state {
            return
        }
        
        // 状態変化時の処理
        // 後処理
        switch self.state {
            case .icon_moving:
                // ドラッグアイコンの描画オブジェクトをクリア
                UDrawManager.getInstance().removeWithPriority( DRAG_ICON_PRIORITY )
            
            case .icon_selecting:
                isDragMove = false;
                // アイコンのチェック状態をクリア
                if state == WindowState.none {
                    let icons : List<UIcon>? = getIcons()
                    if let _icons = icons {
                        for icon in _icons {
                            icon!.isChecking = false
                            if icon!.isChecked {
                                icon!.isChecked = false
                            }
                        }
                    }
                    UDrawManager.getInstance().removeWithPriority( DRAG_ICON_PRIORITY )
                }
        default:
            break
        }

        // 前処理
        switch self.state{
            case .none:
                // アクションバーを更新
            // todo
//                MainActivity.getInstance().setMenuType(
//                    MainActivity.MenuType.TangoEdit)
                break
            case .icon_moving:
                let icons : List<UIcon> = mIconManager!.getCheckedIcons()
                for icon in icons {
                    icon?.addToDrawManager()
                }
            
            case .icon_selecting:
                isDragMove = false
                // ゴミ箱の中のアイコンを選択状態にしてもゴミ箱メニューは表示しない(TangoEdit2に切り替えない)
                if getParentType() != TangoParentType.Trash {
                    // todo
//                    MainActivity.getInstance().setMenuType(MainActivity.MenuType.TangoEdit2);
                }
        default:
            break
        }

        self.state = state
    }

     /**
     * Windowに表示するアイコンを設定する
     * どのアイコンを表示するかはどの親をもつアイコンを表示するかで指定する
     * @param parentType
     * @param parentId
     */
    public func setIcons( parentType: TangoParentType, parentId : Int) {

        self.parentType = parentType
        self.parentId = parentId

        // DBからホームに表示するアイコンをロード
        let items = TangoItemPosDao.selectItemsByParentType(
           parentType: parentType, parentId: parentId, changeable: true
        )
        // 今あるアイコンはクリアしておく
        mIconManager?.getIcons().removeAll()

        // ゴミ箱を配置
        if parentType == TangoParentType.Home {
           _ = mIconManager!.addNewIcon(type: IconType.Trash,
                                    parentType: TangoParentType.Home,
                                    parentId: 0, addPos: AddPos.Top)
        }

        if items != nil {
            for item in items! {
                _ = mIconManager!.addIcon(item, addPos: AddPos.Tail)
            }
        }

        sortIcons(animate: false)
    }

     /**
     * Constructor
     */
    init( parentView : TopView,
          windowCallbacks : UWindowCallbacks?,
          iconCallbacks : UIconCallbacks?,
          isHome : Bool, dir : WindowDir,
          width : CGFloat, height : CGFloat, bgColor : UIColor)
    {
        super.init(parentView: parentView, callbacks: nil,
                   priority: DRAW_PRIORITY, x: 0, y: 0, width: width, height: height, bgColor: bgColor, topBarH: 0, frameW: 0, frameH: 0)
         basePos = CGPoint()
         if isHome {
             type = WindowType.Home
         } else {
             type = WindowType.Sub
             addCloseIcon()
         }
         mIconManager = UIconManager.createInstance(parentWindow: self, iconCallbacks: iconCallbacks)
         self.windowCallbacks = windowCallbacks
         self.dir = dir
         iconMargin = UDpi.toPixel(ICON_MARGIN)
         iconW = UDpi.toPixel(UIconWindow.ICON_W)
         iconH = UDpi.toPixel(UIconWindow.ICON_H)
     }

     /**
     * Create class instance
     * It doesn't allow to create multi Home windows.
     * @return
     */
    // initを使用すればいいので、たぶんいらない
//     public static func createInstance(UWindowCallbacks windowCallbacks,
//                                             UIconCallbacks iconCallbacks,
//                                             boolean isHome, WindowDir dir,
//                                             int width, int height, int bgColor) -> UIconWindow
//     {
//         UIconWindow instance = new UIconWindow(windowCallbacks,
//                 iconCallbacks, isHome, dir, width, height, bgColor);
//
//         return instance;
//     }

     /**
     * Windowを生成する
     * インスタンス生成後に一度だけ呼ぶ
     */
     public func initialize() {
         if type == WindowType.Home {
            setIcons(parentType: TangoParentType.Home, parentId: 0)
         }
     }

    /*
     * 毎フレーム行う処理
     * @return true:再描画を行う(まだ処理が終わっていない)
     */
    public override func doAction() -> DoActionRet{
        var ret = DoActionRet.None
        var allFinished : Bool
        let icons : List<UIcon>? = getIcons()

        // Windowの移動
        if isMoving {
            if autoMoving() {
                ret = DoActionRet.Redraw
            } else {
                isMoving = false
            }
        }

        // アイコンの移動
        if icons != nil {
            if state == WindowState.icon_moving {
                allFinished = true
                for icon in icons! {
                    if icon!.autoMoving() {
                        allFinished = false
                    }
                }
                if allFinished {
                    endIconMoving()
                }
                ret = DoActionRet.Redraw
            }
        }

        return ret
    }

     /**
     * 描画処理
     * UIconManagerに登録されたIconを描画する
     * @param canvas
     * @param paint
     * @return trueなら描画継続
     */
    public override func drawContent( offset : CGPoint? )
    {
        if !isShow {
            return
        }

        let icons : List<UIcon>? = getIcons()
        if icons == nil {
            return
        }

        // 背景を描画
        drawBG()

        // ウィンドウの座標とスクロールの座標を求める
        let _offset = CGPoint(x: pos.x - contentTop.x,
                              y: pos.y - contentTop.y)
        let windowRect = CGRect(x: contentTop.x, y: contentTop.y,
                                width: size.width, height: size.height)

        // クリッピング領域を設定
        // 現在のクリッピング領域を保存
        UIGraphicsGetCurrentContext()!.saveGState()
        // クリッピングの矩形を設定
        UIGraphicsGetCurrentContext()!.clip(to: rect)
        
        // 選択中のアイコンに枠を表示する
        if mIconManager!.getSelectedIcon() != nil {
            UDraw.drawRoundRectFill(
                rect: mIconManager!.getSelectedIcon()!.getRectWithOffset(offset: _offset, frameWidth: UDpi.toPixel(2)),
                cornerR: UDpi.toPixel(10),
                color: SELECTED_ICON_BG_COLOR,
                strokeWidth: 0, strokeColor: nil)
        }
        for icon in mIconManager!.getIcons() {
            if icon === dragedIcon {
                continue
            }
            // 矩形範囲外なら描画しない
            if URect.intersect(rect1: windowRect, rect2: icon!.getRect()) {
                icon!.draw(_offset)
            } else {
            }
        }

        // todo
//        if UDebug.DRAW_ICON_BLOCK_RECT {
//            mIconManager!.getBlockManager()!.draw(getToScreenPos())
//        }

        // クリッピング解除
        UIGraphicsGetCurrentContext()!.restoreGState()
    }

     /**
     * 描画オフセットを取得する
     * @return
     */
     public override func getDrawOffset() -> CGPoint? {
         return nil
     }

     /**
     * Windowのサイズを更新する
     * Windowのサイズを更新する
     * Windowのサイズを更新する
     * サイズ変更に合わせて中のアイコンを再配置する
     * @param width
     * @param height
     */
    public func setSize(width : CGFloat, height : CGFloat) {
        super.setSize(width, height)
    
        // アイコンの整列
        sortIcons(animate: false)
    }

    /**
     * アイコンを整列する
     * Viewのサイズが確定した時点で呼び出す
     */
    public func sortIcons(animate : Bool) {
        let icons : List<UIcon>? = getIcons()
        var selectedIcon : UIcon? = nil
        if icons == nil {
            return
        }

        var maxSize : CGFloat = 0

        var i : Int = 0
        if dir == WindowDir.Vertical {
            let column = Int((clientSize.width - iconMargin) / (iconW + iconMargin))
            if column <= 0 {
                return
            }
            let margin = (clientSize.width - iconW * CGFloat(column)) / CGFloat(column + 1)
            for icon in icons! {
                let x = margin + CGFloat(i % column) * (iconW + margin)
                let y = margin + CGFloat(i / column) * (iconH + margin)
                let height = y + (iconH + margin) * 2
                if height >= maxSize {
                    maxSize = height
                }
                if animate {
                    icon!.startMoving( dstX: x, dstY: y, frame: MOVING_TIME)
                } else {
                    icon!.setPos(x, y)
                }
                // 選択アイコンがあるかどうかチェック
                if icon === mIconManager!.getSelectedIcon() {
                    selectedIcon = icon
                }

                i += 1
            }
        } else {
            let column = Int((clientSize.height - iconMargin) / (iconH + iconMargin))
            if column <= 0 {
                return
            }
            let margin = (clientSize.height - iconH * CGFloat(column)) / CGFloat(column + 1)
            for icon in icons! {
                let x = margin + CGFloat(i / column) * (iconW + margin)
                let y = margin + CGFloat(i % column) * (iconH + margin)
                let width = x + (iconW + margin)
                if (width >= maxSize) {
                    maxSize = width
                }
                if animate {
                    icon!.startMoving(dstX: x, dstY: y, frame: MOVING_TIME)
                } else {
                    icon!.setPos(x, y)
                }

                // 選択アイコンがあるかどうかチェック
                if icon === mIconManager!.getSelectedIcon() {
                    selectedIcon = icon
                }
                i += 1
            }
        }

        if !animate {
            IconsPosFixed()
        }

        if (state == WindowState.icon_selecting) {
            if (isDropInBox) {
                nextState = WindowState.none;
            } else {
                nextState = WindowState.icon_selecting;
            }
        } else {
            nextState = WindowState.none;
        }

        setState(WindowState.icon_moving);

        // メニューバーに重ならないように下にマージンを設ける
        if dir == WindowDir.Vertical {
            setContentSize(width: size.width, height: maxSize + UDpi.toPixel(MARGIN_D), update: true)
            contentTop.y = mScrollBarV!.updateContent(contentSize: contentSize.height)
        } else {
            setContentSize(width: maxSize + UDpi.toPixel(MARGIN_D), height: size.height, update: true)
            contentTop.x = mScrollBarH!.updateContent(contentSize: contentSize.width)
        }

        // 必要があれば選択アイコンをクリア
        if selectedIcon == nil {
            mIconManager!.setSelectedIcon(selectedIcon: nil)
        }
    }

     /**
     * アイコンの座標が確定
     * アイコンの再配置完了時(アニメーションありの場合はそれが終わったタイミング)
     */
     private func IconsPosFixed() {
         mIconManager!.updateBlockRect()
     }

     /**
     * 長押しされた時の処理
     * @param vt
     */
    private func longPressed(vt : ViewTouch) -> Bool {
        let icons : List<UIcon>? = getIcons()
        if icons == nil {
            return false
        }

        // 長押しを離したときにClickイベントが発生しないようにする
        vt.isTouching = false

        if state == WindowState.none {
            // チェック中のアイコンが１つでも存在していたら他のアイコンを全部チェック可能状態に変更
            var isChecking = false
            for icon in icons! {
                if icon!.isChecking {
                    isChecking = true
                    break
                }
            }
            if isChecking {
                changeIconChecked(icons: icons!, isChecking: true)
                setState(WindowState.icon_selecting)

                // Vibrate
                // todo
//                MainActivity.getInstance().startVibration(100);
            }
        } else if (state == WindowState.icon_selecting) {
            // チェック中ならチェック可能状態を解除
            setState( WindowState.none)

            // Vibrate
            // todo
//            MainActivity.getInstance().startVibration(100);
        }
        return true
    }

     /**
     * アイコンをドラッグ開始
     * @param vt
     */
    private func dragStart( vt : ViewTouch ) -> Bool {
        let icons : List<UIcon>? = getIcons()
        if icons == nil {
            return false
        }

        var ret = false
        isDragMove = false

        let checkedIcons : List<UIcon> = mIconManager!.getCheckedIcons()
        if checkedIcons.count > 0 {
            setState(WindowState.icon_selecting)
        }

        if (state == WindowState.none) {
            // ドラッグ中のアイコンが１つでもあればドラッグ開始
            for icon in icons! {
                if icon!.isDraging {
                    setDragedIcon(icon!)
                    ret = true
                    isDragMove = true
                    print("isDragMove=true")
                    break
                }
            }

            if ret {
                setState(WindowState.drag)
                return true
            }
        } else if state == WindowState.icon_selecting {
            // チェックしたアイコンをまとめてドラッグ
            let offset = getToWinPos()

            // チェックされたアイコンが最前面に表示されるように描画優先度をあげる
            for icon in checkedIcons {
                icon!.isDraging = true
                _ = UDrawManager.getInstance().addWithNewPriority(obj: icon!, priority: DrawPriority.DragIcon.rawValue)
            }
            // チェックアイコンのどれかをタッチしていたらドラッグ開始
            for icon in checkedIcons {
                if icon!.getRect().contains(x: vt.touchX(offset: offset.x), y: vt.touchY(offset: offset.y))
                {
                    ret = true;
                    isDragMove = true;
                    print("isDragMove=true2")
                    break
                }
            }
        }
        return ret
    }

     /**
     * ドラッグ中の移動処理
     * @param vt
     * @return
     */
    private func dragMove( vt : ViewTouch) -> Bool {
        // ドラッグ中のアイコンを移動
        var isDone = false
        if !isDragMove {
            return false
        }

        if state == WindowState.drag {
            if dragedIcon == nil {
                return false
            }
            // ドラッグ中のアイコンを移動する
            dragedIcon!.move( vt.moveX, vt.moveY)
        } else if state == WindowState.icon_selecting {
            // チェックしたアイコンをまとめて移動する
            let icons : List<UIcon> = mIconManager!.getCheckedIcons()
            for icon in icons {
                icon!.move(vt.moveX, vt.moveY)
            }
        } else {
            return false
        }

        // 現在のドロップフラグをクリア
        mIconManager!.setDropedIcon(dropedIcon: nil)

        for window in windows!.getWindows()! {
            // ドラッグ中のアイコンが別のアイコンの上にあるかをチェック
            let dragPos = CGPoint( x: window!.toWinX(screenX: vt.x),
                                   y: window!.toWinY(screenY: vt.y))

            let manager : UIconManager? = window!.getIconManager()
            if manager == nil {
                continue
            }

            // ドラッグ先のアイコンと重なっているアイコンを取得する
            // 高速化のために幾つかのアイコンをセットにしたブロックと判定する処理(getOverLappedIcon()内)を使用する
            var dropIcon : UIcon?
            if state == WindowState.drag {
                let exceptIcons : List<UIcon> = List()
                exceptIcons.append(dragedIcon!)
                dropIcon = manager!.getOverlappedIcon(pos: dragPos, exceptIcons: exceptIcons)
            } else {
                let checkedIcons : List<UIcon> = mIconManager!.getCheckedIcons()
                dropIcon = manager!.getOverlappedIcon(pos: dragPos, exceptIcons: checkedIcons)
            }
            if dropIcon != nil {
                if state == WindowState.icon_selecting {
                    // 複数アイコンチェック中
                    let checkedIcons : List<UIcon> = mIconManager!.getCheckedIcons()
                    var allOk = true
                    for _dragIcon in checkedIcons {
                        if _dragIcon!.canDrop(dstIcon: dropIcon!, x: dragPos.x, y: dragPos.y) == false
                        {
                            allOk = false
                            break
                        }
                    }
                    if allOk {
                        mIconManager!.setDropedIcon(dropedIcon: dropIcon!)
                    }
                } else {
                    // シングル
                    isDone = true
                    if dragedIcon!.canDrop(dstIcon: dropIcon!, x: dragPos.x, y: dragPos.y)
                    {
                        mIconManager!.setDropedIcon(dropedIcon: dropIcon!)
                    }
                }
                break
            }
        }

        return isDone
    }

     /**
     * ドラッグ終了時の処理（通常時)
     * @param vt
     * @return trueならViewを再描画
     */
    private func dragEndNormal( vt : ViewTouch ) -> Bool{
        // 他のアイコンの上にドロップされたらドロップ処理を呼び出す
        if dragedIcon == nil {
            return false
        }

        mIconManager!.setDropedIcon(dropedIcon: nil)

        let srcIcons : List<UIcon>? = getIcons()
       
        for window in windows!.getWindows()! {
            // Windowの領域外ならスキップ
            if !(window!.rect.contains(x: vt.x, y: vt.y)){
                continue
            }

            // BookタイプのアイコンをサブWindowに移動できない
            // ただしサブWindowがゴミ箱の場合は除く
            if window === windows!.getSubWindow() {
                if dragedIcon!.type == IconType.Book &&
                        window!.getParentType() != TangoParentType.Trash
                {
                    continue
                }
            }

            let dstIcons : List<UIcon>? = window!.getIcons()

            if dstIcons == nil {
                continue
            }

            // スクリーン座標系からWindow座標系に変換
            let winX = window!.toWinX(screenX: vt.x)
            let winY = window!.toWinY(screenY: vt.y)

            // 全アイコンに対してドロップをチェックする
            let ret = checkDropNormal(dstIcons: dstIcons!, winX: winX, winY: winY)
            var isDroped = ret.isDroped

            // 移動あり
            if isDroped && ret.dropedIcon != nil {
                switch ret.movingType {
                    case .Insert:
                        // ドロップ先の位置に挿入
                        insertIcons(icon1: dragedIcon!, icon2: ret.dropedIcon!, animate:true)
                    
                    case .Exchange:
                        // ドロップ先のアイコンと場所交換
                        changeIcons(icon1: dragedIcon!, icon2: ret.dropedIcon!)
                default:
                    break
                }
            }

            // その他の場所にドロップされた場合
            if !isDroped && dstIcons != nil {
                var isMoved = false

                // 最後のアイコン以降の領域
                if dstIcons!.count > 0 {
                    let lastIcon : UIcon = dstIcons!.last()!
                    if (lastIcon.getY() <= winY &&
                            winY <= lastIcon.getBottom() &&
                            lastIcon.getRight() <= winX) ||
                            (lastIcon.getBottom() <= winY)
                    {
                        isMoved = true
                        isDroped = true
                    }
                } else {
                    isMoved = true
                    isDroped = true
                }

                if isMoved {
                    // 最後のアイコンの後の空きスペースにドロップされた場合
                    // ドラッグ中のアイコンをリストの最後に移動
                    srcIcons?.remove(obj: dragedIcon!)
                    dstIcons?.append(dragedIcon!)
                    // 親の付け替え
                    dragedIcon!.setParentWindow(window!)

                    // データベース更新
                    if self === window {
                        // debug
                        print( srcIcons!.description)
                        
                        TangoItemPosDao.saveIcons(icons: srcIcons!.toArray(),
                                                  parentType: parentType,
                                                  parentId: parentId)
                    } else {
                        let itemPos = dragedIcon!.getTangoItem()!.getItemPos()
                        itemPos!.parentType = window!.parentType.rawValue
                        itemPos!.parentId = window!.parentId

                        TangoItemPosDao.saveIcons(icons: srcIcons!.toArray(),
                                                  parentType: parentType,
                                                  parentId: parentId)
                        TangoItemPosDao.saveIcons(icons: dstIcons!.toArray(),
                                                  parentType: window!.parentType,
                                                  parentId: window!.parentId)
                    }
                }
            }

            // 再配置
            if self !== window {
                // 座標系変換(移動元Windowから移動先Window)
                if isDroped {
                    dragedIcon!.setPos(
                        win1ToWin2X(win1X: dragedIcon!.getPos().x,
                                    win1: self, win2: window!),
                        win1ToWin2Y(win1Y: dragedIcon!.getPos().y,
                                    win1: self, win2: window!))
                }
                window!.sortIcons(animate: true)
            }
            if (isDroped) {
                break
            }
        }
        self.sortIcons(animate: true)

        return true
    }

    /**
    * ReturnValueDragEnd からドロップ判定部分の処理を抜き出し
    * @return タプルで返す
    */
    private func checkDropNormal(
       dstIcons : List<UIcon>, winX : CGFloat, winY : CGFloat)
       -> ReturnValueDragEnd
    {
        var ret = ReturnValueDragEnd()
        ret.movingType = IconMovingType.Insert
       
       if dstIcons.count <= 0 {
           return ret
       }

       for i in 0..<dstIcons.count {
           var dropIcon = dstIcons[i]
           if dropIcon === dragedIcon {
               continue
           }

            // ドラッグアイコンが画面外ならスキップ or break
            if dir == WindowDir.Vertical {
                if contentTop.y > dropIcon.getBottom() {
                    continue
                } else if contentTop.y + size.height < dropIcon.getY(){
                    // これ以降は画面外に表示されるアイコンなので処理を中止
                    break
                }
            } else {
                if contentTop.x > dropIcon.getRight() {
                    continue
                } else if contentTop.x + size.width < dropIcon.getX() {
                    break
                }
            }

            // ドロップ処理をチェックする
            if (dragedIcon!.canDrop(dstIcon: dropIcon, x: winX, y: winY)) {
                ret.dropedIcon = dropIcon
                switch dropIcon.getType() {
                    case .Card:
                        // ドラッグ位置のアイコンと場所を交換する
                        ret.movingType = IconMovingType.Exchange
                        ret.isDroped = true
                   
                    case .Book:
                        if dragedIcon!.getType() != IconType.Card {
                            ret.movingType = IconMovingType.Exchange
                            ret.isDroped = true
                            break
                        }
                        fallthrough
                    case .Trash:
                       // Containerの中に挿入する
                       moveIconIn(icon1: dragedIcon!, icon2: dropIcon)
                       ret.movingType = IconMovingType.MoveIn

                       for win in windows!.getWindows()! {
                           let manager : UIconManager? = win!.getIconManager()
                           if manager != nil {
                               manager!.updateBlockRect()
                           }
                       }
                       ret.isDroped = true
                }
                break
            } else {
                // アイコンのマージン部分にドロップされたかのチェック
                if dir == WindowDir.Vertical {
                    // 縦画面
                    if dropIcon.getX() - iconMargin * 2 <= winX &&
                            winX <= dropIcon.getRight() + iconMargin * 2 &&
                            dropIcon.getY() - iconMargin * 2  <= winY &&
                            winY <= dropIcon.getBottom() + iconMargin * 2
                    {
                        // ドラッグ位置（アイコンの左側)にアイコンを挿入する
                        ret.dropedIcon = dropIcon
                        ret.isDroped = true
                        break
                    } else if (dropIcon.getX() + (iconMargin + iconW) * 2 > size.width )
                    {
                        // 右端のアイコンは右側に挿入できる
                        if winX > dropIcon.getRight() &&
                                dropIcon.getY() <= winY &&
                                winY <= dropIcon.getY() + dropIcon.getSize().height
                        {
                            // 右側の場合は次のアイコンの次の位置に挿入
                            if i < dstIcons.count - 1 {
                                dropIcon = dstIcons[i+1]
                            }
                            ret.dropedIcon = dropIcon
                            ret.isDroped = true
                            break
                        }
                    }
                } else {
                    // 横画面
                    if dropIcon.getY() - iconMargin * 2 <= winY &&
                            winY <= dropIcon.getY() + iconMargin &&
                            dropIcon.getX() <= winX && winX <= dropIcon.getX() + dropIcon.getSize()
                            .width
                    {
                        ret.dropedIcon = dropIcon
                        ret.isDroped = true
                        break
                    } else if (dropIcon.getY() + (iconMargin + iconH) * 2 > size.height ) {
                        // 下端のアイコンは下側に挿入できる
                        if (winY > dropIcon.getBottom() &&
                                dropIcon.getX() <= winX &&
                                winX <= dropIcon.getX() + dropIcon.getSize().width )
                        {
                            // 右側の場合は次のアイコンの次の位置に挿入
                            if i < dstIcons.count - 1 {
                                dropIcon = dstIcons[i+1]
                            }
                            ret.dropedIcon = dropIcon
                            ret.isDroped = true
                            break
                        }
                    }
                }
            }
        }
        return ret
    }

    /**
     * ドラッグ終了時の処理（アイコン選択時)
     * @param vt
     * @return trueならViewを再描画
     */
    private func dragEndChecked(vt : ViewTouch) -> Bool{
         // ドロップ処理
         // 他のアイコンの上にドロップされたらドロップ処理を呼び出す
         var isDroped = false, isMoved = false;

         mIconManager!.setDropedIcon(dropedIcon: nil)

        let srcIcons : List<UIcon> = getIcons()!
        let checkedIcons : List<UIcon> = mIconManager!.getCheckedIcons()

         for window in windows!.getWindows()! {
             // Windowの領域外ならスキップ
            if !(window!.rect.contains(x: vt.x, y: vt.y)){
                 continue
             }

            let dstIcons : List<UIcon>? = window!.getIcons()
            if dstIcons == nil {
                continue
            }

            // スクリーン座標系からWindow座標系に変換
            let winX = window!.toWinX(screenX: vt.x)
            let winY = window!.toWinY(screenY: vt.y)


            isDroped = checkDropChecked(checkedIcons: checkedIcons,
                                        dstIcons: dstIcons!,
                                        x: winX, y: winY)

            // その他の場所にドロップされた場合
            if !isDroped && dstIcons != nil {
                isMoved = false
                if dstIcons!.count > 0 {
                    let lastIcon : UIcon = dstIcons![dstIcons!.count - 1]
                    if (lastIcon.getY() <= winY &&
                            winY <= lastIcon.getBottom() &&
                            lastIcon.getRight() <= winX) ||
                            (lastIcon.getBottom() <= winY)
                    {
                        isMoved = true
                        isDroped = true
                    }
                } else {
                    isMoved = true
                }

                if isMoved {
                    // 最後のアイコンの後の空きスペースにドロップされた場合
                    // ドラッグ中のアイコンをリストの最後に移動
                    srcIcons.remove( objs: checkedIcons.toArray() )
                    dstIcons?.append( objs: checkedIcons.toArray() )
                    // 親の付け替え
                    for icon in checkedIcons {
                        icon!.setParentWindow(window!)
                    }
                    isDropInBox = true

                    // DB更新処理
                    if self === window {
                        TangoItemPosDao.saveIcons( icons: srcIcons.toArray(),
                                                   parentType: parentType,
                                                   parentId: parentId)
                    } else {
                        // ItemPos を更新
                        let dstParentType = window!.parentType.rawValue
                        let dstParentId = window!.parentId

                        for icon in checkedIcons {
                            let itemPos : TangoItemPos = icon!.getTangoItem()!.getItemPos()!
                            itemPos.parentType = dstParentType
                            itemPos.parentId = dstParentId
                        }
                        // 更新したItemPosを DBに反映する
                        TangoItemPosDao.saveIcons( icons: srcIcons.toArray(),
                                                   parentType: parentType,
                                                   parentId: parentId)
                        TangoItemPosDao.saveIcons( icons: dstIcons!.toArray(),
                                                   parentType: window!.parentType,
                                                   parentId: window!.parentId)
                    }
                }
            }
            // 再配置
            if isDroped && srcIcons != dstIcons {
                // 座標系変換(移動元Windowから移動先Window)
                for icon in checkedIcons {
                    icon!.setPos( win1ToWin2X( win1X: icon!.getX(), win1: self, win2: window!),
                                  win1ToWin2Y( win1Y: icon!.getY(), win1: self, win2: window!))
                }
                window!.sortIcons(animate: true)
            }
            if isDroped {
                break
            }
        }
        if isDragMove {
            print("sort!")
            self.sortIcons(animate: true)
            return true
        }
        return false
    }

    /**
    * dragEndCheckedのドロップ処理
    */
    private func checkDropChecked(
       checkedIcons : List<UIcon>, dstIcons : List<UIcon>,
       x : CGFloat, y : CGFloat) -> Bool
    {
        var dropedIcon : UIcon? = nil

        // ドロップ先に挿入するアイコンのリスト
        let icons : List<UIcon> = List()

        if dstIcons.count == 0 {
            // サブウィンドウにチェックしたアイコンをまとめて移動する
            let dropIcon : UIcon? = windows!.getSubWindow().getParentIcon()
            
            for _dragIcon in checkedIcons {
                // カードだけiconsに追加する
                if _dragIcon is IconCard {
                    icons.append(_dragIcon!)
                }
            }
            if icons.count > 0 {
                dropedIcon = dropIcon
            }
        } else {
            for dropIcon in dstIcons {
                if dropIcon!.getType() == IconType.Card {
                    continue
                }

                // ドロップ可能なアイコンだけiconsに追加する
                for _dragIcon in checkedIcons {
                    if _dragIcon!.canDropIn(dstIcon: dropIcon!, x: x, y: y) {
                        icons.append(_dragIcon!)
                    }
                }
                if icons.count > 0 {
                    dropedIcon = dropIcon!
                    break
                }
            }
        }

        if dropedIcon != nil {
            moveIconsIntoBox(checkedIcons: icons, dropedIcon: dropedIcon!)

            // BlockRect更新
            for win in windows!.getWindows()! {
                let manager = win!.getIconManager()
                if manager != nil {
                    manager!.updateBlockRect()
                }
            }
            return true
         }
         return false
    }

     /**
     * タッチ処理
     * @param vt
     * @return trueならViewを再描画
     */
    public override func touchEvent( vt : ViewTouch, offset : CGPoint?) -> Bool {
        if !isShow {
            return false
        }
        if state == WindowState.icon_moving {
            return false
        }

        var offset = offset
        if offset == nil {
            offset = CGPoint()
        }
        if super.touchEvent(vt: vt, offset: offset) {
            return true
        }

        // 範囲外なら抜ける
        if !rect.contains(x: vt.touchX, y: vt.touchY) {
            return false
        }

        var done = false

        // 配下のアイコンのタッチ処理
        let icons : List<UIcon>? = getIcons()
        if icons != nil {
            for icon in icons! {
                if icon!.touchEvent(vt: vt, offset: getToWinPos()) {
                    done = true
                    break
                }
            }
        }

        switch vt.type {
            case .Click:
                if state == WindowState.icon_selecting {
                    // 選択されたアイコンがなくなったら選択状態を解除
                    let checkedIcons : List<UIcon> = mIconManager!.getCheckedIcons()
                    if checkedIcons.count <= 0 {
                        setState(WindowState.none)
                        done = true
                    }
                } else {
                    // MainWindowの何もないところをクリックしたらSubWindowを閉じる
                    if !done && self.type == WindowType.Home {
                        if windows!.getSubWindow().isShow {
                            if windows!.getSubWindow().windowCallbacks != nil {
                                windows!.getSubWindow().windowCallbacks!.windowClose(window: windows!.getSubWindow())
                            }
                        }
                    }
                }
            
            case .LongPress:
                _ = longPressed(vt: vt)
                done = true
            
            case .Moving:
                if vt.isMoveStart {
                    if dragStart(vt: vt) {
                        done = true
                    }
                }
                if dragMove(vt: vt) {
                    done = true
                }
            
            case .MoveEnd:
                switch state {
                    case .none:
                        fallthrough
                    case .drag:
                        if dragEndNormal(vt: vt) {
                            done = true
                        }
                    
                    case .icon_selecting:
                        // アイコン選択中は
                        if dragEndChecked(vt: vt) {
                            done = true
                        }
                default:
                    break
                }
            
            case .MoveCancel:
                sortIcons(animate: false)
                setDragedIcon(nil)
        default:
            break
        }

        if !done {
            // 画面のスクロール処理
            if scrollView(vt: vt) {
                done = true
            }

            if super.touchEvent2(vt: vt, offset: offset) {
                return true
            }
        }

        return done
    }

     /**
     * アイコンの移動が完了
     */
     private func endIconMoving() {
         setState(nextState)
         mIconManager!.updateBlockRect()
         if nextState == WindowState.none {
            changeIconCheckedAll( isChecking: false)
         }
         setDragedIcon(nil)
     }

     /**
     * ２つのアイコンの位置を交換する
     * @param icon1 １つめのアイコン
     * @param icon2 ２つめのアイコン
     */
    private func changeIcons(icon1 : UIcon, icon2 : UIcon)
    {
        // アイコンの位置を交換
        // 並び順も重要！
        let window1 : UIconWindow = icon1.parentWindow!
        let window2 : UIconWindow = icon2.parentWindow!
        let icons1 : List<UIcon> = window1.getIcons()!
        let icons2 : List<UIcon> = window2.getIcons()!

        let index = icons2.indexOf(obj: icon2)
        let index2 = icons1.indexOf(obj: icon1)
        if index == -1 || index2 == -1 {
            return
        }

        icons1.remove(obj: icon1)
        icons2.insert(icon1, atIndex: index)
        icons2.remove(obj: icon2)
        icons1.insert(icon2, atIndex: index2)

        // データベース更新
        TangoItemPosDao.changePos(item1: icon1.getTangoItem()!,
                                  item2: icon2.getTangoItem()!)

        // 再配置
        if icons1 !== icons2 {
            // 親の付け替え
            icon1.setParentWindow(window2)
            icon2.setParentWindow(window1)

            // ドロップアイコンの座標系を変換

            // アイコン2 UWindow -> アイコン1 UWindow
            icon2.setPos(icon2.getX() + (window2.pos.x - window1.pos.x),
                    icon2.getY() + (window2.pos.y - window1.pos.y));
            window2.sortIcons(animate: true)

        }

        window1.sortIcons(animate: true)
    }

     /**
     * アイコンを挿入する
     * @param icon1  挿入元のアイコン
     * @param icon2  挿入先のアイコン
     * @param animate
     */
    private func insertIcons( icon1 : UIcon, icon2 : UIcon, animate : Bool)
    {
        // アイコンの位置を交換
        // 並び順も重要！
        let window1 : UIconWindow = icon1.parentWindow!
        let window2 : UIconWindow = icon2.parentWindow!
        let icons1 : List<UIcon> = window1.getIcons()!
        let icons2 : List<UIcon> = window2.getIcons()!
        
        let index1 = icons2.indexOf(obj: icon2)
        let index2 = icons1.indexOf(obj: icon1)
        if index1 == -1 || index2 == -1 {
            return
        }
        
        // 挿入元と先の位置関係で追加と削除の順番が前後する
        if index1 < index2 {
            icons2.insert(icon1, atIndex: index2+1)
            icons1.remove(obj: icon1)
        } else {
            icons1.remove(obj: icon1)
            icons2.insert(icon1, atIndex: index2+1)
        }

        // 再配置
        if icons1 !== icons2 {
            // 親の付け替え
            icon1.setParentWindow(window2)
            icon2.setParentWindow(window1)

            // ドロップアイコンの座標系を変換
            dragedIcon?.setPos(icon1.getX() + window2.pos.x - window1.pos.x,
                    icon1.getY() + window2.pos.y - window1.pos.y)
            window2.sortIcons(animate: animate)

            // データベース更新
            // 挿入位置以降の全てのposを更新
            if index1 < icons1.count {
                TangoItemPosDao.updatePoses(
                    icons: icons1.toArray(),
                    startPos: icons1[index1].getTangoItem()!.getPos())
            }
            if index1 < icons2.count {
                TangoItemPosDao.updatePoses(
                    icons: icons2.toArray(),
                    startPos:icons2[index2].getTangoItem()!.getPos())
            }
        } else {
            // データベース更新
            // 挿入位置でずれた先頭以降のposを更新
            let startPos = (index1 < index2) ? index1 : index2
            TangoItemPosDao.updatePoses(icons: icons1.toArray(), startPos: startPos)
        }

        window1.sortIcons(animate: animate)
    }

     /**
     * アイコンを移動する
     * アイコンを別のボックスタイプのアイコンにドロップした時に使用する
     * @param icon1 ドロップ元のIcon(Card/Book)
     * @param icon2 ドロップ先のIcon(Book/Trash)
     */
    private func moveIconIn(icon1 : UIcon?, icon2 : UIcon?)
    {
        if icon1 == nil || icon2 == nil {
            return
        }

        // Cardの中には挿入できない
        if !(icon2 is IconContainer) {
            return
        }

        let container : IconContainer = icon2 as! IconContainer

        let window1 : UIconWindow = icon1!.parentWindow!
        let window2 : UIconWindow = container.getSubWindow()!
        let icons : List<UIcon> = window1.getIcons()!

        icons.remove(obj: icon1!)

        if icon2 === windows!.getSubWindow().getParentIcon() &&
            window2.isShow
        {
            let win2Icons : List<UIcon> = window2.getIcons()!
            win2Icons.append(icon1!)

            window2.sortIcons(animate: false)
            icon1!.setParentWindow(window2)
        }
        // データベース更新
        // 位置情報(TangoItemPos)を書き換える
        var itemId = 0
        if container.getParentType() == TangoParentType.Book {
            itemId = container.getTangoItem()!.getId()
        }
        _ = TangoItemPosDao.moveItem( item: icon1!.getTangoItem()!,
                                  parentType: container.getParentType().rawValue,
                                  parentId: itemId)

        window1.sortIcons(animate: true)
        if window1 !== window2 {
            window2.sortIcons(animate: true)
        }
    }

    /**
     * アイコンをゴミ箱の中に移動
     * @param icon
     */
    public func moveIconIntoTrash(icon : UIcon) {
        moveIconIn(icon1: icon, icon2: mIconManager!.getTrashIcon())
    }

     /**
     * アイコンをホームに移動する
     * @param icon
     * @param mainWindow
     */
    public func moveIconIntoHome( icon : UIcon?, mainWindow : UIconWindow?)
    {
        if icon == nil {
            return
        }

        let window1 : UIconWindow = icon!.parentWindow!
        let window2 : UIconWindow? = mainWindow
        let icons1 : List<UIcon> = window1.getIcons()!
        let icons2 : List<UIcon> = window2!.getIcons()!

        icons1.remove(obj: icon!)
        icons2.append(icon!)

        if window2 != nil && window2!.isShow {
            window2!.sortIcons(animate: false)
            icon!.setParentWindow(window2!)
        }
        // データベース更新
        _ = TangoItemPosDao.moveItemToHome( item: icon!.getTangoItem()!)

        sortIcons(animate: false)
    }

     /**
     * チェックされた複数のアイコンをBook/Trashの中に移動する
     * @param dropedIcon
     */
    public func moveIconsIntoBox(checkedIcons : List<UIcon>, dropedIcon : UIcon)
    {
        if !(dropedIcon is IconContainer) {
            return
        }
        let _dropedIcon = dropedIcon as! IconContainer

        // チェックされたアイコンのリストを作成
        if checkedIcons.count <= 0 {
            return
        }

        // 最初のチェックアイコン
        let dragIcon : UIcon = checkedIcons[0]

        let window1 : UIconWindow = dragIcon.parentWindow!
        let window2 : UIconWindow = _dropedIcon.getSubWindow()!
        let icons : List<UIcon> = window1.getIcons()!
        let icons2 : List<UIcon> = window2.getIcons()!

        // 移動元のアイテムを削除
        icons.remove(objs: checkedIcons.toArray())
        
        // 移動先にアイテムを追加
        icons2.append(objs: checkedIcons.toArray())
        
        for icon in checkedIcons {
            icon!.isChecking = false
            icon!.setParentWindow(window2)
        }
        // DB更新
        let items : List<TangoItem> = List()
        for icon in checkedIcons {
            items.append(icon!.getTangoItem()!)

        }

        var itemId : Int = 0
        if _dropedIcon.getType() != IconType.Trash {
            itemId = _dropedIcon.getTangoItem()!.getId()
        }
        _ = TangoItemPosDao.moveItems(items: items.toArray(),
                                    parentType: _dropedIcon.getParentType().rawValue,
                                    parentId: itemId)

        window2.sortIcons(animate: true)
        
        // 箱の中に入れた後のアイコン整列後にチェックを解除したいのでフラグを持っておく
        isDropInBox = true
    }

     /**
     * アイコンを完全に削除する
     * @param icon
     * @return
     */
    public func removeIcon( icon : UIcon) {
        mIconManager!.removeIcon(icon)
        sortIcons(animate: true)

        // DB更新
        _ = TangoItemPosDao.deleteItemInTrash(icon.getTangoItem()!)
    }


     /**
     * アイコンの選択状態を変更する
     * ただしゴミ箱アイコンは除く
     * @param icons
     * @param isChecking  false:チェック状態を解除 / true:チェック可能状態にする
     */
    private func changeIconChecked(icons : List<UIcon>?, isChecking : Bool) {
        if icons == nil {
            return
        }

        for icon in icons! {
            if icon is IconTrash {
                continue
            }
            icon!.isChecking = isChecking
            if !isChecking {
                icon!.isChecked = false
            }
        }
    }

     /**
     * 全てのウィンドウのアイコンの選択状態を変更する
     * @param isChecking
     */
    private func changeIconCheckedAll(isChecking : Bool) {
        for window in windows!.getWindows()! {
            let icons : List<UIcon>? = window!.getIcons()
            changeIconChecked(icons: icons, isChecking: isChecking)
        }
    }

    /**
    * 以下Drawableインターフェースのメソッド
    */
    /**
    * アニメーション処理
    * onDrawからの描画処理で呼ばれる
    * @return true:アニメーション中
    */
    public override func animate() -> Bool {
        var allFinished = true

        let icons : List<UIcon>? = getIcons()
        if isAnimating {
            if icons != nil {
                allFinished = true
                for icon in icons! {
                    if icon!.animate() {
                        allFinished = false
                    }
                }
                if allFinished {
                    isAnimating = false
                }
            }
        }
        return !allFinished
    }

    /**
    * 移動が完了した時の処理
    */
    public override func endMoving() {
        super.endMoving()

        if isAppearance {

        } else {
            isShow = false
        }
        mScrollBarH!.setShow(true)
        mScrollBarV!.setShow(true)
    }


    public override func startMoving() {
        super.startMoving()

        mScrollBarH!.setShow(false)
        mScrollBarV!.setShow(false)
    }
}
