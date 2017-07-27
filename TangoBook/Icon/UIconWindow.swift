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
    case Vertica
}

/**
 * Icon moving type
 */
public enum IconMovingType : Int, EnumEnumerable {
    case Exchange       // exchange A and B
    case Insert         // insert A before B
    case MoveIn          // move A into B
}

public class UIconWindow : UWindow{
   /**
    * Consts
    */
    public static let TAG = "UIconWindow"

    public let DRAW_PRIORITY = 100
    public let DRAG_ICON_PRIORITY = 11

    public let ICON_MARGIN = 10

    public let ICON_W = 57
    public let ICON_H = 50
    static let MARGIN_D = UMenuBar.MENU_BAR_H

    static let MOVING_TIME = 10
    static let SELECTED_ICON_BG_COLOR = UColor.makeColor(80, 255, 100, 100)


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

//     /**
//     * 状態を設定する
//     * 状態に移る時の前処理、後処理を実行できる
//     * @param state
//     */
//     public void setState(WindowState state) {
//         if (self.state == state) return;

//         // 状態変化時の処理
//         // 後処理
//         switch (self.state) {
//             case icon_moving:
//             {
//                 // ドラッグアイコンの描画オブジェクトをクリア
//                 UDrawManager.getInstance().removeWithPriority(DRAG_ICON_PRIORITY);
//             }
//             break;
//             case icon_selecting:
//             {
//                 isDragMove = false;
//                 // アイコンのチェック状態をクリア
//                 if (state == WindowState.none) {
//                     List<UIcon> icons = getIcons();
//                     for (UIcon icon : icons) {
//                         icon.isChecking = false;
//                         if (icon.isChecked) {
//                             icon.isChecked = false;
//                         }
//                     }
//                     UDrawManager.getInstance().removeWithPriority(DRAG_ICON_PRIORITY);
//                 }
//             }
//             break;
//         }

//         // 前処理
//         switch(state){
//             case none:
//                 // アクションバーを更新
//                 MainActivity.getInstance().setMenuType(MainActivity.MenuType.TangoEdit);
//                 break;
//             case icon_moving:
//             {
//                 List<UIcon> icons = mIconManager.getCheckedIcons();
//                 for (UIcon icon : icons) {
//                     UDrawManager.getInstance().addDrawable(icon);
//                 }
//             }
//                 break;
//             case icon_selecting:
//                 isDragMove = false;
//                 // ゴミ箱の中のアイコンを選択状態にしてもゴミ箱メニューは表示しない(TangoEdit2に切り替えない)
//                 if (getParentType() != TangoParentType.Trash) {
//                     MainActivity.getInstance().setMenuType(MainActivity.MenuType.TangoEdit2);
//                 }
//                 break;
//         }

//         self.state = state;
//     }

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
//         if parentType == TangoParentType.Home {
//             mIconManager!.addNewIcon(IconType.Trash, TangoParentType.Home, 0, AddPos.Top);
//         }
//
//         for item in items {
//             mIconManager!.addIcon(item, AddPos.Tail);
//         }
//
//         sortIcons(false)
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
         iconW = UDpi.toPixel(ICON_W)
         iconH = UDpi.toPixel(ICON_H)
     }

//     /**
//     * Create class instance
//     * It doesn't allow to create multi Home windows.
//     * @return
//     */
//     public static UIconWindow createInstance(UWindowCallbacks windowCallbacks,
//                                             UIconCallbacks iconCallbacks,
//                                             boolean isHome, WindowDir dir,
//                                             int width, int height, int bgColor)
//     {
//         UIconWindow instance = new UIconWindow(windowCallbacks,
//                 iconCallbacks, isHome, dir, width, height, bgColor);

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

//     /**
//     * 毎フレーム行う処理
//     * @return true:再描画を行う(まだ処理が終わっていない)
//     */
//     public DoActionRet doAction() {
//         DoActionRet ret = DoActionRet.None;
//         boolean allFinished;
//         List<UIcon> icons = getIcons();

//         // Windowの移動
//         if (isMoving) {
//             if (!autoMoving()) {
//                 isMoving = false;
//             }
//         }

//         // アイコンの移動
//         if (icons != null) {
//             if (state == WindowState.icon_moving) {
//                 allFinished = true;
//                 for (UIcon icon : icons) {
//                     if (icon.autoMoving()) {
//                         allFinished = false;
//                     }
//                 }
//                 if (allFinished) {
//                     endIconMoving();
//                 }
//                 ret = DoActionRet.Redraw;
//             }
//         }

//         return ret;
//     }

//     /**
//     * 描画処理
//     * UIconManagerに登録されたIconを描画する
//     * @param canvas
//     * @param paint
//     * @return trueなら描画継続
//     */
//     public void drawContent(Canvas canvas, Paint paint, PointF offset)
//     {
//         if (!isShow) return;

//         List<UIcon> icons = getIcons();
//         if (icons == null) return;

//         // 背景を描画
//         drawBG(canvas, paint);

//         // ウィンドウの座標とスクロールの座標を求める
//         PointF _offset = new PointF(pos.x - contentTop.x, pos.y - contentTop.y);
//         Rect windowRect = new Rect((int)contentTop.x, (int)contentTop.y, (int)contentTop.x + size.width, (int)contentTop.y + size.height);

//         // クリッピング領域を設定
//         canvas.save();
//         canvas.clipRect(rect);

//         // 選択中のアイコンに枠を表示する
//         if (mIconManager.getSelectedIcon() != null) {
//             UDraw.drawRoundRectFill(canvas, paint,
//                     new RectF(mIconManager.getSelectedIcon().getRectWithOffset
//                             (_offset, 5)), 10.0f, SELECTED_ICON_BG_COLOR, 0, 0);
//         }
//         for (UIcon icon : mIconManager.getIcons()) {
//             if (icon == dragedIcon) continue;
//             // 矩形範囲外なら描画しない
//             if (URect.intersect(windowRect, icon.getRect())) {
//                 icon.draw(canvas, paint, _offset);

//             } else {
//             }
//         }

//         if (UDebug.DRAW_ICON_BLOCK_RECT) {
//             mIconManager.getBlockManager().draw(canvas, paint, getToScreenPos());
//         }

//         // クリッピング解除
//         canvas.restore();
//     }


//     /**
//     * 描画オフセットを取得する
//     * @return
//     */
//     public PointF getDrawOffset() {
//         return null;
//     }

//     /**
//     * Windowのサイズを更新する
//     * Windowのサイズを更新する
//     * Windowのサイズを更新する
//     * サイズ変更に合わせて中のアイコンを再配置する
//     * @param width
//     * @param height
//     */
//     public void setSize(int width, int height) {
//         super.setSize(width, height);
//         // アイコンの整列
//         sortIcons(false);
//     }

//     /**
//     * アイコンを整列する
//     * Viewのサイズが確定した時点で呼び出す
//     */
//     public void sortIcons(boolean animate) {
//         List<UIcon> icons = getIcons();
//         UIcon selectedIcon = null;
//         if (icons == null) return;

//         int maxSize = 0;

//         int i=0;
//         if (dir == WindowDir.Vertical) {
//             int column = (clientSize.width - iconMargin) / (iconW + iconMargin);
//             if (column <= 0) {
//                 return;
//             }
//             int margin = (clientSize.width - iconW * column) / (column + 1);
//             for (UIcon icon : icons) {
//                 int x = margin + (i % column) * (iconW + margin);
//                 int y = margin + (i / column) * (iconH + margin);
//                 int height = y + (iconH + margin) * 2;
//                 if (height >= maxSize) {
//                     maxSize = height;
//                 }
//                 if (animate) {
//                     icon.startMoving( x, y, MOVING_TIME);
//                 } else {
//                     icon.setPos(x, y);
//                 }
//                 // 選択アイコンがあるかどうかチェック
//                 if (icon == mIconManager.getSelectedIcon()) {
//                     selectedIcon = icon;
//                 }

//                 i++;
//             }
//         } else {
//             int column = (clientSize.height - iconMargin) / (iconH + iconMargin);
//             if (column <= 0) {
//                 return;
//             }
//             int margin = (clientSize.height - iconH * column) / (column + 1);
//             for (UIcon icon : icons) {
//                 int x = margin + (i / column) * (iconW + margin);
//                 int y = margin + (i % column) * (iconH + margin);
//                 int width = x + (iconW + margin);
//                 if (width >= maxSize) {
//                     maxSize = width;
//                 }
//                 if (animate) {
//                     icon.startMoving(x, y, MOVING_TIME);
//                 } else {
//                     icon.setPos(x, y);
//                 }

//                 // 選択アイコンがあるかどうかチェック
//                 if (icon == mIconManager.getSelectedIcon()) {
//                     selectedIcon = icon;
//                 }
//                 i++;
//             }
//         }

//         if (!animate) {
//             IconsPosFixed();
//         }

//         if (state == WindowState.icon_selecting) {
//             if (isDropInBox) {
//                 nextState = WindowState.none;
//             } else {
//                 nextState = WindowState.icon_selecting;
//             }
//         } else {
//             nextState = WindowState.none;
//         }

//         setState(WindowState.icon_moving);

//         // メニューバーに重ならないように下にマージンを設ける
//         if (dir == WindowDir.Vertical) {
//             setContentSize(size.width, maxSize + MARGIN_D, true);
//             contentTop.y = mScrollBarV.updateContent(contentSize.height);
//         } else {
//             setContentSize(maxSize + MARGIN_D, size.height, true);
//             contentTop.x = mScrollBarH.updateContent(contentSize.width);
//         }

//         // 必要があれば選択アイコンをクリア
//         if (selectedIcon == null) {
//             mIconManager.setSelectedIcon(null);
//         }
//     }

//     /**
//     * アイコンの座標が確定
//     * アイコンの再配置完了時(アニメーションありの場合はそれが終わったタイミング)
//     */
//     private void IconsPosFixed() {
//         mIconManager.updateBlockRect();
//     }

//     /**
//     * 長押しされた時の処理
//     * @param vt
//     */
//     private boolean longPressed(ViewTouch vt) {
//         List<UIcon> icons = getIcons();
//         if (icons == null) return false;

//         // 長押しを離したときにClickイベントが発生しないようにする
//         vt.setTouching(false);

//         if (state == WindowState.none) {
//             // チェック中のアイコンが１つでも存在していたら他のアイコンを全部チェック可能状態に変更
//             boolean isChecking = false;
//             for (UIcon icon : icons) {
//                 if (icon.isChecking) {
//                     isChecking = true;
//                     break;
//                 }
//             }
//             if (isChecking) {
//                 changeIconChecked(icons, true);
//                 setState(WindowState.icon_selecting);

//                 // Vibrate
//                 MainActivity.getInstance().startVibration(100);
//             }
//         } else if (state == WindowState.icon_selecting) {
//             // チェック中ならチェック可能状態を解除
//             setState(WindowState.none);

//             // Vibrate
//             MainActivity.getInstance().startVibration(100);
//         }
//         return true;
//     }

//     /**
//     * アイコンをドラッグ開始
//     * @param vt
//     */
//     private boolean dragStart(ViewTouch vt) {
//         List<UIcon> icons = getIcons();
//         if (icons == null) return false;

//         boolean ret = false;
//         isDragMove = false;

//         List<UIcon> checkedIcons = mIconManager.getCheckedIcons();
//         if (checkedIcons.size() > 0) {
//             setState(WindowState.icon_selecting);
//         }

//         if (state == WindowState.none) {
//             // ドラッグ中のアイコンが１つでもあればドラッグ開始
//             for (UIcon icon : icons) {
//                 if (icon.isDraging) {
//                     setDragedIcon(icon);
//                     ret = true;
//                     isDragMove = true;
//                     System.out.println("isDragMove=true");
//                     break;
//                 }
//             }

//             if (ret) {
//                 setState(WindowState.drag);
//                 return true;
//             }
//         } else if (state == WindowState.icon_selecting) {
//             // チェックしたアイコンをまとめてドラッグ
//             PointF offset = getToWinPos();

//             // チェックされたアイコンが最前面に表示されるように描画優先度をあげる
//             for (UIcon icon : checkedIcons) {
//                 icon.isDraging = true;
//                 UDrawManager.getInstance().addWithNewPriority(icon, DrawPriority.DragIcon.p());
//             }
//             // チェックアイコンのどれかをタッチしていたらドラッグ開始
//             for (UIcon icon : checkedIcons) {
//                 if (icon.getRect().contains((int) vt.touchX(offset.x), (int) vt.touchY(offset.y))) {
//                     ret = true;
//                     isDragMove = true;
//                     System.out.println("isDragMove=true2");
//                     break;
//                 }
//             }
//         }
//         return ret;
//     }

//     /**
//     * ドラッグ中の移動処理
//     * @param vt
//     * @return
//     */
//     private boolean dragMove(ViewTouch vt) {
//         // ドラッグ中のアイコンを移動
//         boolean isDone = false;
//         if (!isDragMove) return false;

//         if (state == WindowState.drag) {
//             if (dragedIcon == null) return false;
//             // ドラッグ中のアイコンを移動する
//             dragedIcon.move(vt.getMoveX(), vt.getMoveY());
//         } else if (state == WindowState.icon_selecting){
//             // チェックしたアイコンをまとめて移動する
//             List<UIcon> icons = mIconManager.getCheckedIcons();
//             if (icons != null) {
//                 for (UIcon icon : icons) {
//                     icon.move(vt.getMoveX(), vt.getMoveY());
//                 }
//             }
//         } else {
//             return false;
//         }

//         // 現在のドロップフラグをクリア
//         mIconManager.setDropedIcon(null);

//         for (UIconWindow window : windows.getWindows()) {
//             // ドラッグ中のアイコンが別のアイコンの上にあるかをチェック
//             Point dragPos = new Point((int) window.toWinX(vt.getX()), (int) window.toWinY(vt.getY()));

//             UIconManager manager = window.getIconManager();
//             if (manager == null) continue;

//             // ドラッグ先のアイコンと重なっているアイコンを取得する
//             // 高速化のために幾つかのアイコンをセットにしたブロックと判定する処理(getOverLappedIcon()内)を使用する
//             UIcon dropIcon;
//             if (state == WindowState.drag) {
//                 LinkedList<UIcon> exceptIcons = new LinkedList<>();
//                 exceptIcons.add(dragedIcon);
//                 dropIcon = manager.getOverlappedIcon(dragPos, exceptIcons);
//             } else {
//                 List<UIcon> checkedIcons = mIconManager.getCheckedIcons();
//                 dropIcon = manager.getOverlappedIcon(dragPos, checkedIcons);
//             }
//             if (dropIcon != null) {
//                 if (state == WindowState.icon_selecting) {
//                     // 複数アイコンチェック中
//                     List<UIcon> checkedIcons = mIconManager.getCheckedIcons();
//                     boolean allOk = true;
//                     for (UIcon _dragIcon : checkedIcons) {
//                         if (_dragIcon.canDrop(dropIcon, dragPos.x, dragPos.y) == false) {
//                             allOk = false;
//                             break;
//                         }
//                     }
//                     if (allOk) {
//                         mIconManager.setDropedIcon(dropIcon);
//                     }
//                 } else {
//                     // シングル
//                     isDone = true;
//                     if (dragedIcon.canDrop(dropIcon, dragPos.x, dragPos.y)) {
//                         mIconManager.setDropedIcon(dropIcon);
//                     }
//                 }
//                 break;
//             }
//         }

//         return isDone;
//     }

//     /**
//     * ドラッグ終了時の処理（通常時)
//     * @param vt
//     * @return trueならViewを再描画
//     */
//     private boolean dragEndNormal(ViewTouch vt) {

//         // 他のアイコンの上にドロップされたらドロップ処理を呼び出す
//         if (dragedIcon == null) return false;

//         mIconManager.setDropedIcon(null);

//         List<UIcon> srcIcons = getIcons();
//         for (UIconWindow window : windows.getWindows()) {
//             // Windowの領域外ならスキップ
//             if (!(window.rect.contains((int)vt.getX(),(int)vt.getY()))){
//                 continue;
//             }

//             // BookタイプのアイコンをサブWindowに移動できない
//             // ただしサブWindowがゴミ箱の場合は除く
//             if (window == windows.getSubWindow()) {
//                 if (dragedIcon.type == IconType.Book &&
//                         window.getParentType() != TangoParentType.Trash)
//                 {
//                     continue;
//                 }
//             }

//             List<UIcon> dstIcons = window.getIcons();

//             if (dstIcons == null) continue;

//             // スクリーン座標系からWindow座標系に変換
//             float winX = window.toWinX(vt.getX());
//             float winY = window.toWinY(vt.getY());

//             // 全アイコンに対してドロップをチェックする
//             ReturnValueDragEnd ret = checkDropNormal(dstIcons, winX, winY);
//             boolean isDroped = ret.isDroped;

//             // 移動あり
//             if (isDroped && ret.dropedIcon != null) {
//                 switch(ret.movingType) {
//                     case Insert:
//                         // ドロップ先の位置に挿入
//                         insertIcons(dragedIcon, ret.dropedIcon, true);
//                         break;
//                     case Exchange:
//                         // ドロップ先のアイコンと場所交換
//                         changeIcons(dragedIcon, ret.dropedIcon);
//                         break;
//                 }
//             }

//             // その他の場所にドロップされた場合
//             if (!isDroped && dstIcons != null ) {
//                 boolean isMoved = false;

//                 // 最後のアイコン以降の領域
//                 if (dstIcons.size() > 0) {
//                     UIcon lastIcon = dstIcons.get(dstIcons.size() - 1);
//                     if ((lastIcon.getY() <= winY &&
//                             winY <= lastIcon.getBottom() &&
//                             lastIcon.getRight() <= winX) ||
//                             (lastIcon.getBottom() <= winY))
//                     {
//                         isMoved = true;
//                         isDroped = true;
//                     }
//                 } else {
//                     isMoved = true;
//                     isDroped = true;
//                 }

//                 if (isMoved) {


//                     // 最後のアイコンの後の空きスペースにドロップされた場合
//                     // ドラッグ中のアイコンをリストの最後に移動
//                     srcIcons.remove(dragedIcon);
//                     dstIcons.add(dragedIcon);
//                     // 親の付け替え
//                     dragedIcon.setParentWindow(window);

//                     // データベース更新
//                     if (self == window) {
//                         RealmManager.getItemPosDao().saveIcons(srcIcons,
//                                 parentType, parentId);
//                     } else {
//                         TangoItemPos itemPos = dragedIcon.getTangoItem().getItemPos();
//                         itemPos.setParentType(window.parentType.ordinal());
//                         itemPos.setParentId(window.parentId);

//                         RealmManager.getItemPosDao().saveIcons(srcIcons,
//                                 parentType, parentId);
//                         RealmManager.getItemPosDao().saveIcons(dstIcons,
//                                 window.parentType, window.parentId);
//                     }
//                 }
//             }

//             // 再配置
//             if (self != window) {
//                 // 座標系変換(移動元Windowから移動先Window)
//                 if (isDroped) {
//                     dragedIcon.setPos(win1ToWin2X(dragedIcon.getPos().x, self, window), win1ToWin2Y(dragedIcon.getPos().y, self, window));
//                 }
//                 window.sortIcons(true);
//             }
//             if (isDroped) break;
//         }
//         self.sortIcons(true);

//         return true;
//     }

//     /**
//     * dragEndNormalInsert の戻り値
//     */
//     public class ReturnValueDragEnd {
//         UIcon dropedIcon;
//         IconMovingType movingType;
//         boolean isDroped;
//     }

//     /**
//     * ReturnValueDragEnd からドロップ判定部分の処理を抜き出し
//     * @return
//     */
//     private ReturnValueDragEnd checkDropNormal(
//             List<UIcon>dstIcons, float winX, float winY)
//     {
//         ReturnValueDragEnd ret = new ReturnValueDragEnd();
//         ret.movingType = IconMovingType.Insert;

//         for (int i=0; i<dstIcons.size(); i++) {
//             UIcon dropIcon = dstIcons.get(i);
//             if (dropIcon == dragedIcon) continue;

//             // ドラッグアイコンが画面外ならスキップ or break
//             if (dir == WindowDir.Vertical) {
//                 if (contentTop.y > dropIcon.getBottom()) {
//                     continue;
//                 } else if (contentTop.y + size.height < dropIcon.getY()){
//                     // これ以降は画面外に表示されるアイコンなので処理を中止
//                     break;
//                 }
//             } else {
//                 if (contentTop.x > dropIcon.getRight()) {
//                     continue;
//                 } else if (contentTop.x + size.width < dropIcon.getX()){
//                     break;
//                 }
//             }

//             // ドロップ処理をチェックする
//             if (dragedIcon.canDrop(dropIcon, winX, winY)) {
//                 ret.dropedIcon = dropIcon;
//                 switch (dropIcon.getType()) {
//                     case Card:
//                         // ドラッグ位置のアイコンと場所を交換する
//                         ret.movingType = IconMovingType.Exchange;
//                         ret.isDroped = true;
//                         break;
//                     case Book:
//                         if (dragedIcon.getType() != IconType.Card) {
//                             ret.movingType = IconMovingType.Exchange;
//                             ret.isDroped = true;
//                             break;
//                         }
//                     case Trash:
//                         // Containerの中に挿入する
//                         moveIconIn(dragedIcon, dropIcon);
//                         ret.movingType = IconMovingType.MoveIn;

//                         for (UIconWindow win : windows.getWindows()) {
//                             UIconManager manager = win.getIconManager();
//                             if (manager != null) {
//                                 manager.updateBlockRect();
//                             }
//                         }
//                         ret.isDroped = true;
//                         break;
//                 }
//                 break;
//             } else {
//                 // アイコンのマージン部分にドロップされたかのチェック
//                 if (dir == WindowDir.Vertical) {
//                     // 縦画面
//                     if (dropIcon.getX() - iconMargin * 2 <= winX &&
//                             winX <= dropIcon.getRight() + iconMargin * 2 &&
//                             dropIcon.getY() - iconMargin * 2  <= winY &&
//                             winY <= dropIcon.getBottom() + iconMargin * 2 )
//                     {
//                         // ドラッグ位置（アイコンの左側)にアイコンを挿入する
//                         ret.dropedIcon = dropIcon;
//                         ret.isDroped = true;
//                         break;
//                     } else if (dropIcon.getX() + (iconMargin + iconW) * 2 > size.width ) {
//                         // 右端のアイコンは右側に挿入できる
//                         if (winX > dropIcon.getRight() &&
//                                 dropIcon.getY() <= winY &&
//                                 winY <= dropIcon.getY() + dropIcon.getSize().height )
//                         {
//                             // 右側の場合は次のアイコンの次の位置に挿入
//                             if (i < dstIcons.size() - 1) {
//                                 dropIcon = dstIcons.get(i+1);
//                             }
//                             ret.dropedIcon = dropIcon;
//                             ret.isDroped = true;
//                             break;
//                         }
//                     }
//                 } else {
//                     // 横画面
//                     if (dropIcon.getY() - iconMargin * 2 <= winY &&
//                             winY <= dropIcon.getY() + iconMargin &&
//                             dropIcon.getX() <= winX && winX <= dropIcon.getX() + dropIcon.getSize()
//                             .width )
//                     {
//                         ret.dropedIcon = dropIcon;
//                         ret.isDroped = true;
//                         break;
//                     } else if (dropIcon.getY() + (iconMargin + iconH) * 2 > size.height ) {
//                         // 下端のアイコンは下側に挿入できる
//                         if (winY > dropIcon.getBottom() &&
//                                 dropIcon.getX() <= winX &&
//                                 winX <= dropIcon.getX() + dropIcon.getSize().width )
//                         {
//                             // 右側の場合は次のアイコンの次の位置に挿入
//                             if (i < dstIcons.size() - 1) {
//                                 dropIcon = dstIcons.get(i+1);
//                             }
//                             ret.dropedIcon = dropIcon;
//                             ret.isDroped = true;
//                             break;
//                         }
//                     }
//                 }
//             }
//         }
//         return ret;
//     }

//     /**
//     * ドラッグ終了時の処理（アイコン選択時)
//     * @param vt
//     * @return trueならViewを再描画
//     */
//     private boolean dragEndChecked(ViewTouch vt) {
//         // ドロップ処理
//         // 他のアイコンの上にドロップされたらドロップ処理を呼び出す
//         boolean isDroped = false, isMoved = false;

//         mIconManager.setDropedIcon(null);

//         List<UIcon> srcIcons = getIcons();
//         List<UIcon> checkedIcons = mIconManager.getCheckedIcons();

//         for (UIconWindow window : windows.getWindows()) {
//             // Windowの領域外ならスキップ
//             if (!(window.rect.contains((int)vt.getX(),(int)vt.getY()))){
//                 continue;
//             }

//             List<UIcon> dstIcons = window.getIcons();
//             if (dstIcons == null) continue;

//             // スクリーン座標系からWindow座標系に変換
//             float winX = window.toWinX(vt.getX());
//             float winY = window.toWinY(vt.getY());


//             isDroped = checkDropChecked(checkedIcons, dstIcons, winX, winY);

//             // その他の場所にドロップされた場合
//             if (!isDroped && dstIcons != null ) {
//                 isMoved = false;
//                 if (dstIcons.size() > 0) {
//                     UIcon lastIcon = dstIcons.get(dstIcons.size() - 1);
//                     if ((lastIcon.getY() <= winY &&
//                             winY <= lastIcon.getBottom() &&
//                             lastIcon.getRight() <= winX) ||
//                             (lastIcon.getBottom() <= winY))
//                     {
//                         isMoved = true;
//                         isDroped = true;
//                     }
//                 } else {
//                     isMoved = true;
//                 }

//                 if (isMoved) {
//                     // 最後のアイコンの後の空きスペースにドロップされた場合
//                     // ドラッグ中のアイコンをリストの最後に移動
//                     srcIcons.removeAll(checkedIcons);
//                     dstIcons.addAll(checkedIcons);
//                     // 親の付け替え
//                     for (UIcon icon : checkedIcons) {
//                         icon.setParentWindow(window);
//                     }
//                     isDropInBox = true;

//                     // DB更新処理
//                     if (self == window) {
//                         RealmManager.getItemPosDao().saveIcons(srcIcons,
//                                 parentType, parentId);
//                     } else {
//                         // ItemPos を更新
//                         int dstParentType = window.parentType.ordinal();
//                         int dstParentId = window.parentId;

//                         for (UIcon icon : checkedIcons) {
//                             TangoItemPos itemPos = icon.getTangoItem().getItemPos();
//                             itemPos.setParentType(dstParentType);
//                             itemPos.setParentId(dstParentId);
//                         }
//                         // 更新したItemPosを DBに反映する
//                         RealmManager.getItemPosDao().saveIcons(srcIcons,
//                                 parentType, parentId);
//                         RealmManager.getItemPosDao().saveIcons(dstIcons,
//                                 window.parentType, window.parentId);
//                     }
//                 }
//             }
//             // 再配置
//             if (isDroped && srcIcons != dstIcons) {
//                 // 座標系変換(移動元Windowから移動先Window)
//                 for (UIcon icon : checkedIcons) {
//                     icon.setPos(win1ToWin2X(icon.getX(), self, window), win1ToWin2Y(icon.getY(), self, window));
//                 }
//                 window.sortIcons(true);
//             }
//             if (isDroped) break;
//         }
//         if ( isDragMove) {
//             System.out.println("sort!");
//             self.sortIcons(true);
//             return true;
//         }
//         return false;
//     }

//     /**
//     * dragEndCheckedのドロップ処理
//     */
//     private boolean checkDropChecked(
//             List<UIcon>checkedIcons, List<UIcon>dstIcons, float x, float y)
//     {
//         UIcon dropedIcon = null;

//         // ドロップ先に挿入するアイコンのリスト
//         LinkedList<UIcon> icons = new LinkedList<>();

//         for (UIcon dropIcon : dstIcons) {
//             if (dropIcon.getType() == IconType.Card) {
//                 continue;
//             }

//             for (UIcon _dragIcon : checkedIcons) {
//                 if (_dragIcon.canDropIn(dropIcon, x, y)) {
//                     icons.add(_dragIcon);
//                 }
//             }
//             if (icons.size() > 0) {
//                 dropedIcon = dropIcon;
//                 break;
//             }
//         }

//         if (dropedIcon != null) {
//             moveIconsIntoBox(icons, dropedIcon);

//             // BlockRect更新
//             for (UIconWindow win : windows.getWindows()) {
//                 UIconManager manager = win.getIconManager();
//                 if (manager != null) {
//                     manager.updateBlockRect();
//                 }
//             }
//             return true;
//         }
//         return false;
//     }

//     /**
//     * タッチ処理
//     * @param vt
//     * @return trueならViewを再描画
//     */
//     public boolean touchEvent(ViewTouch vt, PointF offset) {
//         if (!isShow) return false;
//         if (state == WindowState.icon_moving) return false;

//         if (offset == null) {
//             offset = new PointF();
//         }
//         if (super.touchEvent(vt, offset)) {
//             return true;
//         }

//         // 範囲外なら抜ける
//         if (!rect.contains((int)vt.touchX(), (int)vt.touchY())) {
//             return false;
//         }

//         boolean done = false;

//         // 配下のアイコンのタッチ処理
//         List<UIcon> icons = getIcons();
//         if (icons != null) {
//             for (UIcon icon : icons) {
//                 if (icon.touchEvent(vt, getToWinPos())) {
//                     done = true;
//                     break;
//                 }
//             }
//         }

//         switch (vt.type) {
//             case Click:
//                 if (state == WindowState.icon_selecting) {
//                     // 選択されたアイコンがなくなったら選択状態を解除
//                     List<UIcon> checkedIcons = mIconManager.getCheckedIcons();
//                     if (checkedIcons.size() <= 0) {
//                         setState(WindowState.none);
//                         done = true;
//                     }
//                 } else {
//                     // MainWindowの何もないところをクリックしたらSubWindowを閉じる
//                     if (!done && self.type == WindowType.Home) {
//                         if (windows.getSubWindow().isShow()) {
//                             if (windows.getSubWindow().windowCallbacks != null) {
//                                 windows.getSubWindow().windowCallbacks.windowClose(windows.getSubWindow());
//                             }
//                         }
//                     }
//                 }
//                 break;
//             case LongPress:
//                 longPressed(vt);
//                 done = true;
//                 break;
//             case Moving:
//                 if (vt.isMoveStart()) {
//                     if (dragStart(vt)) {
//                         done = true;
//                     }
//                 }
//                 if (dragMove(vt)) {
//                     done = true;
//                 }
//                 break;
//             case MoveEnd:
//                 switch(state) {
//                     case none:
//                     case drag:
//                         if (dragEndNormal(vt)) {
//                             done = true;
//                         }
//                         break;
//                     case icon_selecting:
//                         // アイコン選択中は
//                         if (dragEndChecked(vt)) {
//                             done = true;
//                         }
//                         break;
//                 }
//                 break;
//             case MoveCancel:
//                 sortIcons(false);
//                 setDragedIcon(null);
//                 break;
//         }

//         if (!done) {
//             // 画面のスクロール処理
//             if (scrollView(vt)){
//                 done = true;
//             }

//             if (super.touchEvent2(vt, offset)) {
//                 return true;
//             }
//         }

//         return done;
//     }

//     /**
//     * アイコンの移動が完了
//     */
//     private void endIconMoving() {
//         setState(nextState);
//         mIconManager.updateBlockRect();
//         if (nextState == WindowState.none) {
//             changeIconCheckedAll(false);
//         }
//         setDragedIcon(null);
//     }

//     /**
//     * ２つのアイコンの位置を交換する
//     * @param icon1
//     * @param icon2
//     */
//     private void changeIcons(UIcon icon1, UIcon icon2 )
//     {
//         // アイコンの位置を交換
//         // 並び順も重要！
//         UIconWindow window1 = icon1.parentWindow;
//         UIconWindow window2 = icon2.parentWindow;
//         List<UIcon> icons1 = window1.getIcons();
//         List<UIcon> icons2 = window2.getIcons();

//         int index = icons2.indexOf(icon2);
//         int index2 = icons1.indexOf(icon1);
//         if (index == -1 || index2 == -1) return;


//         icons1.remove(icon1);
//         icons2.add(index, icon1);
//         icons2.remove(icon2);
//         icons1.add(index2, icon2);

//         // データベース更新
//         RealmManager.getItemPosDao().changePos(icon1.getTangoItem(), icon2.getTangoItem());

//         // 再配置
//         if (icons1 != icons2) {
//             // 親の付け替え
//             icon1.setParentWindow(window2);
//             icon2.setParentWindow(window1);

//             // ドロップアイコンの座標系を変換

//             // アイコン2 UWindow -> アイコン1 UWindow
//             icon2.setPos(icon2.getX() + (window2.pos.x - window1.pos.x),
//                     icon2.getY() + (window2.pos.y - window1.pos.y));
//             window2.sortIcons(true);

//         }

//         window1.sortIcons(true);
//     }

//     /**
//     * アイコンを挿入する
//     * @param icon1  挿入元のアイコン
//     * @param icon2  挿入先のアイコン
//     * @param animate
//     */
//     private void insertIcons(UIcon icon1, UIcon icon2, boolean animate)
//     {
//         UIconWindow window1 = icon1.parentWindow;
//         UIconWindow window2 = icon2.parentWindow;
//         List<UIcon> icons1 = window1.getIcons();
//         List<UIcon> icons2 = window2.getIcons();

//         int index1 = icons1.indexOf(icon1);
//         int index2 = icons2.indexOf(icon2);

//         if (index1 == -1 || index2 == -1) return;

//         // 挿入元と先の位置関係で追加と削除の順番が前後する
//         if (index1 < index2) {
//             icons2.add(index2+1, icon1);
//             icons1.remove(icon1);
//         } else {
//             icons1.remove(icon1);
//             icons2.add(index2+1, icon1);
//         }

//         // 再配置
//         if (icons1 != icons2) {
//             // 親の付け替え
//             icon1.setParentWindow(window2);
//             icon2.setParentWindow(window1);

//             // ドロップアイコンの座標系を変換
//             dragedIcon.setPos(icon1.getX() + window2.pos.x - window1.pos.x,
//                     icon1.getY() + window2.pos.y - window1.pos.y);
//             window2.sortIcons(animate);

//             // データベース更新
//             // 挿入位置以降の全てのposを更新
//             if (index1 < icons1.size()) {
//                 RealmManager.getItemPosDao().updatePoses(icons1, icons1.get(index1).getTangoItem()
//                         .getPos());
//             }
//             if (index1 < icons2.size()) {
//                 RealmManager.getItemPosDao().updatePoses(icons2, icons2.get(index2).getTangoItem()
//                         .getPos());
//             }
//         } else {
//             // データベース更新
//             // 挿入位置でずれた先頭以降のposを更新
//             int startPos = (index1 < index2) ? index1 : index2;
//             RealmManager.getItemPosDao().updatePoses(icons1, startPos);
//         }

//         window1.sortIcons(animate);
//     }

//     /**
//     * アイコンを移動する
//     * アイコンを別のボックスタイプのアイコンにドロップした時に使用する
//     * @param icon1 ドロップ元のIcon(Card/Book)
//     * @param icon2 ドロップ先のIcon(Book/Trash)
//     */
//     private void moveIconIn(UIcon icon1, UIcon icon2)
//     {
//         if (icon1 == null || icon2 == null) return;

//         // Cardの中には挿入できない
//         if (!(icon2 instanceof IconContainer)) {
//             return;
//         }

//         IconContainer container = (IconContainer)icon2;

//         UIconWindow window1 = icon1.parentWindow;
//         UIconWindow window2 = container.getSubWindow();
//         List<UIcon> icons = window1.getIcons();

//         icons.remove(icon1);

//         if (icon2 == windows.getSubWindow().getParentIcon() && window2.isShow()) {
//             List<UIcon> win2Icons = window2.getIcons();
//             win2Icons.add(icon1);

//             window2.sortIcons(false);
//             icon1.setParentWindow(window2);
//         }
//         // データベース更新
//         // 位置情報(TangoItemPos)を書き換える
//         int itemId = 0;
//         if (container.getParentType() == TangoParentType.Book) {
//             itemId = container.getTangoItem().getId();
//         }
//         RealmManager.getItemPosDao().moveItem(icon1.getTangoItem(),
//                 container.getParentType().ordinal(),
//                 itemId);

//         window1.sortIcons(true);
//         if (window1 != window2) {
//             window2.sortIcons(true);
//         }
//     }

//     /**
//     * アイコンをゴミ箱の中に移動
//     * @param icon
//     */
//     public void moveIconIntoTrash(UIcon icon) {
//         moveIconIn(icon, mIconManager.getTrashIcon());
//     }

//     /**
//     * アイコンをホームに移動する
//     * @param icon
//     * @param mainWindow
//     */
//     public void moveIconIntoHome(UIcon icon, UIconWindow mainWindow) {
//         if (icon == null) return;

//         UIconWindow window1 = icon.parentWindow;
//         UIconWindow window2 = mainWindow;
//         List<UIcon> icons1 = window1.getIcons();
//         List<UIcon> icons2 = window2.getIcons();

//         icons1.remove(icon);
//         icons2.add(icon);

//         if (window2 != null && window2.isShow()) {
//             window2.sortIcons(false);
//             icon.setParentWindow(window2);
//         }
//         // データベース更新
//         RealmManager.getItemPosDao().moveItemToHome(icon.getTangoItem());

//         sortIcons(false);
//     }

//     /**
//     * チェックされた複数のアイコンをBook/Trashの中に移動する
//     * @param dropedIcon
//     */
//     public void moveIconsIntoBox(List<UIcon>checkedIcons, UIcon dropedIcon) {

//         if (!(dropedIcon instanceof IconContainer)) {
//             return;
//         }
//         IconContainer _dropedIcon = (IconContainer)dropedIcon;

//         // チェックされたアイコンのリストを作成
//         if (checkedIcons.size() <= 0) return;

//         // 最初のチェックアイコン
//         UIcon dragIcon = checkedIcons.get(0);

//         UIconWindow window1 = dragIcon.parentWindow;
//         UIconWindow window2 = _dropedIcon.getSubWindow();
//         List<UIcon> icons = window1.getIcons();

//         icons.removeAll(checkedIcons);

//         window2.sortIcons(false);
//         for (UIcon icon : checkedIcons) {
//             icon.isChecking = false;
//             icon.setParentWindow(window2);
//         }
//         // DB更新
//         LinkedList<TangoItem> items = new LinkedList<>();
//         for (UIcon icon : checkedIcons) {
//             items.add(icon.getTangoItem());

//         }

//         int itemId = 0;
//         if (_dropedIcon.getType() != IconType.Trash) {
//             itemId = _dropedIcon.getTangoItem().getId();
//         }
//         RealmManager.getItemPosDao().moveItems(items, _dropedIcon.getParentType().ordinal(),
//                 itemId);

//         // 箱の中に入れた後のアイコン整列後にチェックを解除したいのでフラグを持っておく
//         isDropInBox = true;
//     }

//     /**
//     * アイコンを完全に削除する
//     * @param icon
//     * @return
//     */
//     public void removeIcon(UIcon icon) {

//         mIconManager.removeIcon(icon);
//         sortIcons(true);

//         // DB更新
//         RealmManager.getItemPosDao().deleteItemInTrash(icon.getTangoItem());
//     }


//     /**
//     * アイコンの選択状態を変更する
//     * ただしゴミ箱アイコンは除く
//     * @param icons
//     * @param isChecking  false:チェック状態を解除 / true:チェック可能状態にする
//     */
//     private void changeIconChecked(List<UIcon> icons, boolean isChecking) {
//         if (icons == null) return;

//         for (UIcon icon : icons) {
//             if (icon instanceof IconTrash) {
//                 continue;
//             }
//             icon.isChecking = isChecking;
//             if (!isChecking) {
//                 icon.isChecked = false;
//             }
//         }
//     }

//     /**
//     * 全てのウィンドウのアイコンの選択状態を変更する
//     * @param isChecking
//     */
//     private void changeIconCheckedAll(boolean isChecking) {
//         for (UIconWindow window : windows.getWindows()) {
//             List<UIcon> icons = window.getIcons();
//             changeIconChecked(icons, isChecking);
//         }
//     }

//     /**
//     * 以下Drawableインターフェースのメソッド
//     */
//     /**
//     * アニメーション処理
//     * onDrawからの描画処理で呼ばれる
//     * @return true:アニメーション中
//     */
//     public boolean animate() {
//         boolean allFinished = true;

//         List<UIcon> icons = getIcons();
//         if (isAnimating) {
//             if (icons != null) {
//                 allFinished = true;
//                 for (UIcon icon : icons) {
//                     if (icon.animate()) {
//                         allFinished = false;
//                     }
//                 }
//                 if (allFinished) {
//                     isAnimating = false;
//                 }
//             }
//         }
//         return !allFinished;
//     }

//     /**
//     * 移動が完了した時の処理
//     */
//     public void endMoving() {
//         super.endMoving();

//         if (isAppearance) {

//         } else {
//             isShow = false;
//         }
//         mScrollBarH.setShow(true);
//         mScrollBarV.setShow(true);
//     }


//     public void startMoving() {
//         super.startMoving();

//         mScrollBarH.setShow(false);
//         mScrollBarV.setShow(false);
//     }


//     /**
//     * UButtonCallbacks
//     */

// }
}
