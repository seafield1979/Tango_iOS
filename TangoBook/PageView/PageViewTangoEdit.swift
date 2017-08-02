//
//  PageViewBackup.swift
//  TangoBook
//    単語帳作成ページ
//  Created by Shusuke Unno on 2017/07/24.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import UIKit



public enum EditCardDialogMode {
    case Create     // 新しくアイコンを作成する
    case Edit       // 既存のアイコンを編集する
}

/**
 単語カード編集ダイアログが終了した時に呼ばれるコールバック
 */
public protocol EditCardDialogCallbacks {
    func submitEditCard()
    func cancelEditCard()
}

/**
 単語帳編集ダイアログが終了した時に呼ばれるコールバック
 */
public protocol EditBookDialogCallbacks {
    func submitEditBook()
    func cancelEditBook()
}

/**
 * IconInfoDialogのコールバック
 */
public protocol IconInfoDialogCallbacks {
    /**
     * ダイアログで表示しているアイコンの内容を編集
     * @param icon
     */
    func IconInfoEditIcon( icon: UIcon )
    
    /**
     * アイコンをコピー
     * @param icon
     */
    func IconInfoCopyIcon(icon: UIcon)
    
    /**
     * アイコンをゴミ箱に移動
     * @param icon
     */
    func IconInfoThrowIcon(icon: UIcon)
    
    /**
     * アイコンを開く
     * @param icon
     */
    func IconInfoOpenIcon(icon: UIcon)
    
    /**
     * Book の学習開始
     * @param icon
     */
    func IconInfoStudy(icon: UIcon)
    
    /**
     * コンテナタイプのアイコン以下をクリーンアップ(全削除)する
     * @param icon
     */
    func IconInfoCleanup(icon: UIcon)
    
    /**
     * ゴミ箱内のアイコンを元に戻す
     * @param icon
     */
    func IconInfoReturnIcon(icon: UIcon)
    
    /**
     * ゴミ箱内のアイコンを削除する
     * @param icon
     */
    func IconInfoDeleteIcon(icon: UIcon)
}

public class PageViewTangoEdit : UPageView, UMenuItemCallbacks,
             UIconCallbacks, UWindowCallbacks, UButtonCallbacks,
             EditCardDialogCallbacks, EditBookDialogCallbacks, IconInfoDialogCallbacks,
             UDialogCallbacks, UIconWindowSubCallbacks
{
    
    enum WindowType : Int, EnumEnumerable {
        case Icon1
        case Icon2
        case MenuBar
        case Log
    }
    
    /**
     * Constants
     */
    public static let TAG = "TopView"

    private let MARGIN_H : CGFloat = 50

    /**
     * Member varialbes
     */
    // Windows
    private var mWindows : [UWindow?] = Array(repeating: nil, count: WindowType.count)
    // UIconWindow
    private var mIconWinManager : UIconWindows? = nil

    // MessageWindow
    private var mLogWin : ULogWindow? = nil

    // Dialog
//    private var debugDialogs : DebugDialogs
    private var mDialog : UDialogWindow? = nil

    // メニューバー
    private var mMenuBar : MenuBarTangoEdit? = nil

    private var mIconInfoDlg : IconInfoDialog? = nil

    // Fragmentで内容を編集中のアイコン
    private var editingIcon : UIcon? = nil

    // ゴミ箱に捨てるアイコン
    private var mThrowIcon : UIcon? = nil

    // CSV出力アイコン
    private var mExportIcon : IconBook? = nil

    // コピーアイコン
    private var mCopyIcon : UIcon? = nil
    
    /**
    * Get/Set
    */

    /**
     * Constructor
     */
    public override init(parentView : TopView, title : String) {
        super.init(parentView: parentView, title: title)
    }
    
    /**
    * Methods
    */

    /**
    * UPageView
    */
    public override func onShow() {

    }
    public override func onHide() {
        super.onHide()
    }

    override func initDrawables() {
        let width = mTopView.getWidth()
        let height = mTopView.getHeight()

         // 描画オブジェクトクリア
         UDrawManager.getInstance().initialize()

         // DebugDialogs
//         debugDialogs = DebugDialogs(mTopView)

         // UIconWindow
        var size1 : CGSize, size2 : CGSize
        var winDir : WindowDir
        size1 = CGSize(width: width, height: height)
        size2 = CGSize(width: width, height: height)

        if width <= height {
            winDir = WindowDir.Vertical
        } else {
            winDir = WindowDir.Horizontal
        }

        // Main
        let mainWindow : UIconWindow = UIconWindow(
            parentView: mTopView, windowCallbacks: self,
            iconCallbacks: self,
            isHome : true,
            dir: winDir, width: size1.width,
            height: size1.height, bgColor: UIColor.white)
        
        mainWindow.addToDrawManager()
        mWindows[WindowType.Icon1.rawValue] = mainWindow

        // Sub
        let subWindow = UIconWindowSub(
            parentView: mTopView,
            windowCallbacks : self,
            iconCallbacks :self,
            iconWindowSubCallbacks : self,
            isHome: false, dir: winDir, width: size2.width, height: size2.height,
            bgColor: UIColor.lightGray)
        
        subWindow.addToDrawManager()
        subWindow.isShow = false
        mWindows[WindowType.Icon2.rawValue] = subWindow

        mIconWinManager = UIconWindows.createInstance(
            mainWindow: mainWindow,
            subWindow: subWindow,
            screenW: width, screenH: height)
        mainWindow.setWindows(mIconWinManager!)
        subWindow.setWindows(mIconWinManager!)

        // アイコンの登録はMainとSubのWindowを作成後に行う必要がある
        mainWindow.initialize()
        subWindow.initialize()

        // UMenuBar
        mMenuBar = MenuBarTangoEdit.createInstance(
            parentView: mTopView, callbackClass: self,
            parentW: width, parentH: height, bgColor: nil)
        mWindows[WindowType.MenuBar.rawValue] = mMenuBar!

        // ULogWindow
//        if (mLogWin == nil) {
//            mLogWin = ULogWindow.createInstance( parentView: mTopView,
//                                                 type: LogWindowType.Fix,
//                                                 x: 0, y: 0,
//                                                 width: width, height: height)
//            mWindows[WindowType.Log.rawValue] = mLogWin!
//            ULog.setLogWindow(mLogWin!)
//        }
    }
    
    
    /**
    * アクションIDを処理する
    */
    public enum TangoEditActionId : Int, EnumEnumerable {
        case action_move_to_trash
        case action_sort_word_asc
        case action_sort_word_desc
        case action_sort_time_asc
        case action_sort_time_desc
        case action_card_name_a
        case action_card_name_b
        case action_search_card
        case action_settings
    }
    public func setActionId(id : TangoEditActionId) {
        switch id {
            case .action_move_to_trash:
                if mDialog != nil {
                    return
                }
                // ゴミ箱に移動するかの確認ダイアログを表示する
                mDialog = UDialogWindow.createInstance(
                    parentView: mTopView,
                    type: DialogType.Mordal,
                    buttonCallbacks: self, dialogCallbacks: self,
                    dir: UDialogWindow.ButtonDir.Horizontal,
                    posType: DialogPosType.Center,
                    isAnimation: true,
                    screenW: mTopView.getWidth(), screenH: mTopView.getHeight(),
                        textColor: UIColor.black, dialogColor: UIColor.lightGray)
                mDialog!.addToDrawManager()
                mDialog!.setTitle(
                UResourceManager.getStringByName("confirm_moveto_trash"))
                _ = mDialog!.addButton(
                    id: ButtonIdMoveIconsToTrash,
                    text: "OK",
                    textColor: UIColor.black, color: UIColor.white)
                _ = mDialog!.addCloseButton(
                    text: UResourceManager.getStringByName("cancel"))
                mTopView.invalidate()
        
            case .action_sort_word_asc:
                let window = getCurrentWindow()
                window.mIconManager!.sortWithMode(mode: UIconManager.SortMode.TitleAsc)
                window.sortIcons(animate: true)
                mTopView.invalidate()
        
            case .action_sort_word_desc:
                let window = getCurrentWindow()
                window.mIconManager!.sortWithMode(mode: UIconManager.SortMode
                        .TitleDesc)
                window.sortIcons(animate: true);
                mTopView.invalidate();
            
            case .action_sort_time_asc:
                let window = getCurrentWindow();
                window.mIconManager!.sortWithMode(mode: UIconManager.SortMode
                        .CreateDateAsc);
                window.sortIcons(animate: true);
                mTopView.invalidate();
            
            case .action_sort_time_desc:
                let window = getCurrentWindow();
                window.mIconManager!.sortWithMode(mode: UIconManager.SortMode
                        .CreateDateDesc);
                window.sortIcons(animate: true);
                mTopView.invalidate();
            
            case .action_card_name_a:
                // カードアイコンの名前を英語で表示
                MySharedPref.writeBool(key: MySharedPref.EditCardNameKey, value: false)
                mIconWinManager!.resetCardTitle()
                mTopView.invalidate()
            
            case .action_card_name_b:
                // カードアイコンの名前を日本語で表示
                MySharedPref.writeBool(key: MySharedPref.EditCardNameKey, value: true)
                mIconWinManager!.resetCardTitle()
                mTopView.invalidate()
            
            case .action_search_card:
                _ = PageViewManagerMain.getInstance().stackPage(
                    pageId: PageIdMain.SearchCard.rawValue)
            
            case .action_settings:
                PageViewManagerMain.getInstance().startOptionPage(
                    mode: PageViewOptions.Mode.Edit)
                mTopView.invalidate()
         }
    }
    
     /**
      * Androidのバックキーが押された時の処理
      * @return
      */
    public override func onBackKeyDown() -> Bool {
        // 各種ダイアログ
        if mDialog != nil {
            mDialog!.startClosing()
            return true
        }
        // アイコンダイアログが開いていたら閉じる
        if mIconInfoDlg != nil {
            mIconInfoDlg!.closeWindow()
            mIconInfoDlg = nil
            return true
        }

        // メニューが開いていたら閉じる
        if mMenuBar!.onBackKeyDown() {
            return true
        }

        // サブウィンドウが表示されていたら閉じる
        let subWindow : UIconWindow = mIconWinManager!.getSubWindow()
        if subWindow.isShow {
            if mIconWinManager!.hideWindow(window: subWindow, animation: true) {
                return true
            }
        }

        return false
    }
    
    /**
    * Add icon
    */
    
    // Card追加用のダイアログを表示
    private func addCardDialog() {
        // todo 
        // フラグメントの代わりにViewControllerを使用する
//        let dialogFragment = EditCardDialogFragment.createInstance(self)
//        dialogFragment.show(((AppCompatActivity)mContext).getSupportFragmentManager(),
//                 "fragment_dialog");
    }
    
    // Book追加用のダイアログを表示
    private func addBookDialog() {
        // todo
//        let dialogFragment = EditBookDialogFragment.createInstance(self);
//
//        dialogFragment.show(((AppCompatActivity)mContext).getSupportFragmentManager(),
//                "fragment_dialog");
    }
    
     // ダミーのCardを追加
     private func addDummyCard() {
         _ = addCardIcon()
         mTopView.invalidate()
     }
    
     // ダミーのBookを追加
     private func addDummyBook() {
         _ = addBookIcon()
     }
    
     // プリセットの単語帳を追加する
     private func addPresetBook() {
         _ = PageViewManagerMain.getInstance().stackPage(pageId: PageIdMain.PresetBook.rawValue)
     }

     // Csvファイルから単語帳を追加する
     private func addCsvBook() {
         _ = PageViewManagerMain.getInstance().stackPage(pageId: PageIdMain.CsvBook.rawValue)
     }
    
    /**
     * Edit icon
     */
    private func editCardDialog( iconCard : IconCard) {
        // todo
//        let dialogFragment =
//             EditCardDialogFragment.createInstance(self, (TangoCard)iconCard.getTangoItem());
//
//        dialogFragment.show(((AppCompatActivity)mContext).getSupportFragmentManager(),
//             "fragment_dialog");
    }
    
    private func editBookDialog( iconBook : IconBook ) {
        // todo
//        let dialogFragment =
//                 EditBookDialogFragment.createInstance(self, (TangoBook)iconBook.getTangoItem());
//
//        dialogFragment.show(((AppCompatActivity)mContext).getSupportFragmentManager(),
//                 "fragment_dialog");
    }
    
    /**
    * Copy icon
    */
    private func copyIcon( icon : UIcon ) {
        let iconManager = icon.getParentWindow()!.getIconManager()

        // コピー先のカードアイコンを作成
        let newIcon : UIcon? = iconManager!.copyIcon(copySrc: icon, addPos: AddPos.SrcNext)
        if newIcon == nil {
            return
        }

        // 単語帳なら配下のカードをコピーする
        if icon.getType() == IconType.Book {
            let srcBook = icon as! IconBook
            let dstBook = newIcon as! IconBook
            
            let cards : [TangoCard]? = srcBook.getItems()
            if let _cards = cards {
                for card in _cards {
                    // DBに位置情報を追加
                    // Card
                    let newCard : TangoItem = TangoCardDao.copyOne(card: card)
                    // ItemPos
                    _ = TangoItemPosDao.addOne(item: newCard,
                                           parentType: TangoParentType.Book,
                                           // command failed due to signal segmentation fault 11  のエラーが出る
//                                           parentId: dstBook.getTangoItem().getId(),
                                            parentId: dstBook.book!.id,
                                           addPos: -1)
                }
            }
        }
        icon.getParentWindow()!.sortIcons(animate: true)
    }
    
    // card
    private func addCardIcon() -> IconCard {
        var iconManager : UIconManager
        var window : UIconWindow
        var cardIcon : IconCard
    
        // Bookのサブウィンドウが開いていたらそちらに追加する
        window = mIconWinManager!.getSubWindow()
        if window.isShow && window.getParentType() == TangoParentType.Book {
            // サブウィンドウに追加
            iconManager = window.getIconManager()!
            cardIcon = iconManager.addNewIcon(type:IconType.Card,
                                              parentType: TangoParentType.Book,
                                              parentId: window.getParentId(),
                                              addPos: AddPos.Tail) as! IconCard
             // 親の単語帳アイコンのアイコンリストにも追加

        } else {
            window = mIconWinManager!.getMainWindow()!
            iconManager = window.getIconManager()!
            cardIcon = iconManager.addNewIcon(type: IconType.Card,
                                              parentType:TangoParentType.Home,
                                              parentId:0,
                                              addPos: AddPos.Tail) as! IconCard
        }
        window.sortIcons(animate: true)

        return cardIcon
    }
    
    // book
    private func addBookIcon() {
        let iconManager = mIconWinManager!.getMainWindow()!.getIconManager()
        _ = iconManager!.addNewIcon(type: IconType.Book,
                                parentType: TangoParentType.Home,
                                parentId: 0, addPos: AddPos.Tail)
        mIconWinManager!.getMainWindow()!.sortIcons(animate: true)

        mTopView.invalidate()
    }
    
    /**
    * アイコンをゴミ箱に移動する
    * @param icon
    */
    private func moveIconToTrash(icon : UIcon) {
        mIconWinManager!.getMainWindow()!.moveIconIntoTrash(icon: icon)
        if mIconInfoDlg != nil {
             mIconInfoDlg!.closeWindow()
             mIconInfoDlg = nil
        }
        mTopView.invalidate()
    }
    
    /**
    * UMenuItemCallbacks
    */
    /**
    * メニューアイテムをタップした時のコールバック
    */
    public func menuItemClicked(itemId id : Int, stateId : Int) {
         let itemId = MenuBarTangoEdit.MenuItemId.toEnum(id)

         switch itemId {
         case .AddTop:
            break
         case .AddCard:
             addCardDialog()
        
         case .AddBook:
             addBookDialog()
        
         case .AddDummyCard:
             addDummyCard()
        
         case .AddDummyBook:
             addDummyBook()
        
         case .AddPresetBook:
             addPresetBook()

         case .AddCsvBook:
             addCsvBook()
         }
         ULog.printMsg(PageViewTangoEdit.TAG, "menu item clicked " + id.description)
    }
    
    public func menuItemCallback2() {
        ULog.printMsg(PageViewTangoEdit.TAG, "menu item moved")
    }
    
    /**
    * UIconCallbacks
    */
    /**
    * IconWindow上のアイコンがクリックされた
    * アイコンの種類に合わせたダイアログを表示する
    * @param icon
    */
    public func iconClicked( icon: UIcon) {
        ULog.printMsg( PageViewTangoEdit.TAG, "iconClicked")
        if mIconInfoDlg != nil {
            if icon === mIconInfoDlg!.getmIcon() {
                if icon.getType() == IconType.Card {
                    // カードなら編集
                    IconInfoEditIcon(icon: icon)
                    return
                }
            }
            else {
                mIconInfoDlg!.closeWindow()
                mIconInfoDlg = nil
            }
        }
        let winPos : CGPoint = icon.getParentWindow()!.getPos()
        let x = winPos.x + icon.getX()
        let y = winPos.y + icon.getY() + UDpi.toPixel(UIconWindow.ICON_H)  // ちょい下

        // ゴミ箱のWindow内なら別のダイアログを表示
        if icon.getParentWindow()!.getParentType() == TangoParentType.Trash {
            mIconInfoDlg = IconInfoDialogInTrash.createInstance(
                parentView: mTopView,
                iconInfoDialogCallbacks: self,
                windowCallbacks: self,
                icon: icon,
                x: x, y: y)
        } else {
            switch icon.getType() {
            case .Card:
                _ = IconInfoDialogCard.createInstance(
                    parentView : mTopView, iconInfoDialogCallbacks : self, windowCallbacks : self,
                    icon : icon, x : x, y : y)
                // newフラグをクリア
                icon.setNewFlag(newFlag: false)
            
            case .Book:
                IconInfoOpenIcon(icon: icon);
                // newフラグをクリア
                icon.setNewFlag(newFlag: false)
            
            case .Trash:
                IconInfoOpenIcon(icon: icon);
                
            }
        }
        mTopView.invalidate();
    }
    
    public func longClickIcon(icon : UIcon) {
        ULog.printMsg(PageViewTangoEdit.TAG, "longClickIcon")
    }
    
    public func iconDroped(icon : UIcon) {
        ULog.printMsg(PageViewTangoEdit.TAG, "iconDroped")
    }
    
    /**
    * カレントIconWindowを取得する
    * サブが開いていたらサブを、開いていなかったらメインを返す
    * @return
    */
    private func getCurrentWindow() -> UIconWindow {
        if mIconWinManager!.getSubWindow().isShow {
            return mIconWinManager!.getSubWindow()
        }
        return mIconWinManager!.getMainWindow()!
    }
    
    /**
    * アイコンを開く
    * サブウィンドウに中のアイコンリストを表示
    * @param icon
    */
    public func openIcon( icon : UIcon) {
        // 配下のアイコンをSubWindowに表示する
        switch icon.getType() {
        case .Book:
            let subWindow : UIconWindowSub = mIconWinManager!.getSubWindow()
            subWindow.setIcons(
                parentType: TangoParentType.Book,
                parentId: icon.getTangoItem()!.getId())
            subWindow.setParentIcon(icon: icon)

            // SubWindowを画面外から移動させる
            mIconWinManager!.showWindow(window: subWindow, animation: true)
            mTopView.invalidate()
        
        case .Trash:
            let window : UIconWindow = mIconWinManager!.getSubWindow()
            window.setIcons(
                parentType: TangoParentType.Trash,
                parentId: 0)
            mIconWinManager!.getSubWindow().setParentIcon(icon: icon)

            // SubWindowを画面外から移動させる
            mIconWinManager!.showWindow(window: window, animation: true)
            mTopView.invalidate()
        default:
            break
        }
    }
    
    /**
    * UWindowCallbacks
    */
    public func windowClose(window : UWindow) {
        // Windowを閉じる
        for _window in mIconWinManager!.getWindows()! {
            if window === _window {
                _ = mIconWinManager!.hideWindow(window: _window!, animation: true)
                break
            }
        }
        if mIconInfoDlg === window {
            mIconInfoDlg!.closeWindow()
            mIconInfoDlg = nil
        }
    }
    
    /**
    * UButtonCallbacks
    */
    public func UButtonClicked(id : Int, pressedOn : Bool) -> Bool{
        switch (id) {
        case CleanupDialogButtonOK:
            // ゴミ箱を空にする
            _ = TangoItemPosDao.deleteItemsInTrash()
            mIconWinManager!.getSubWindow().getIcons()!.removeAll()

            mDialog!.closeDialog()
            mIconWinManager!.getSubWindow().sortIcons(animate: false)
            return true;
        case TrashDialogButtonOK:
            // 単語帳をゴミ箱に捨てる
            moveIconToTrash(icon: mThrowIcon!)
            let subWindow : UIconWindowSub = mIconWinManager!.getSubWindow()
            if subWindow.isShow {
                if subWindow.getWindowCallbacks() != nil {
                    subWindow.getWindowCallbacks()!.windowClose(window: subWindow)
                }
            }
            mDialog!.closeDialog()
            return true

        case ButtonIdMoveIconsToTrash:
            // チェックしたアイコンをゴミ箱に移動する
            let trashIcon : UIcon = mIconWinManager!.getMainWindow()!.getIconManager()!.getTrashIcon()!
            for window in mIconWinManager!.getWindows()! {
                let icons : List<UIcon> = window!.getIconManager()!.getCheckedIcons()
                if icons.count > 0 {
                    window!.moveIconsIntoBox(checkedIcons: icons, dropedIcon: trashIcon)
                    window!.sortIcons(animate: true)
                }
            }

            if(mDialog != nil) {
                mDialog!.startClosing()
            }
            return true
        case ButtonIdCopyOK:
            // 単語帳のコピーを作成する
            copyIcon(icon: mCopyIcon!)
            if mDialog != nil {
                mDialog!.closeDialog()
                mDialog = nil
            }

        case ExportDialogButtonOK:
            // CSVファイルに出力する
            let cards : [TangoCard] = mExportIcon!.getItems()!
            let path = PresetBookManager.getInstance()
                    .exportToCsvFile(book: mExportIcon!.book!, cards: cards)

            var message : String
            if path == nil {
                // 失敗
                message = UResourceManager.getStringByName("failed_backup")
            } else {
                // 成功
                message = path! + "\n" + UResourceManager.getStringByName("finish_export")
            }

            if mDialog != nil {
                mDialog!.closeDialog()
            }
            mDialog = UDialogWindow.createInstance(
                parentView : mTopView,
                type : DialogType.Mordal,
                buttonCallbacks : self, dialogCallbacks : self, dir : UDialogWindow.ButtonDir.Horizontal,
                posType : DialogPosType.Center,
                isAnimation : true,
                screenW : mTopView.getWidth(), screenH : mTopView.getHeight(),
                textColor : UIColor.black, dialogColor : UIColor.lightGray)
            
            mDialog!.addToDrawManager();
            mDialog!.setTitle(message);
            _ = mDialog!.addButton(id : ExportFinishedDialogButtonOk, text : "OK", textColor : UIColor.black, color : UIColor.white)
        
        case ExportFinishedDialogButtonOk:
            if mDialog != nil {
                mDialog!.closeDialog()
                mDialog = nil
            }
            
        case UDialogWindow.CloseDialogId:
            mDialog!.closeDialog()
            
        default:
            break
        }
        return false
    }
    
    /**
    * EditCardDialogCallbacks
    */
    public func submitEditCard() {
//         let mode = MySharedPref.readInt(EditCardDialogFragment.KEY_MODE,
//                                         defaultValue: EditCardDialogMode.Create.rawValue)
//         if (mode == EditCardDialogMode.Create.rawValue) {
//             // 新規作成
//
//             IconCard iconCard = addCardIcon();
//             if (iconCard == nil) {
//                 return;
//             }
//             TangoCard card = (TangoCard)iconCard.getTangoItem();
//
//             // 戻り値を取得
//             card.setWordA(args.getString(EditCardDialogFragment.KEY_WORD_A, ""));
//             card.setWordB(args.getString(EditCardDialogFragment.KEY_WORD_B, ""));
// //            card.setComment(args.getString(EditCardDialogFragment.KEY_COMMENT, ""));
//             card.setColor(args.getInt(EditBookDialogFragment.KEY_COLOR, 0));
//
//             iconCard.updateTitle();
//             iconCard.setColor(card.getColor());
//             iconCard.updateIconImage();
//             // DB更新
//             TangoCardDao().updateOne(card);
//         } else {
//             // 更新
//             TangoCard card = (TangoCard)editingIcon.getTangoItem();
//             card.setWordA(args.getString(EditCardDialogFragment.KEY_WORD_A, ""));
//             card.setWordB(args.getString(EditCardDialogFragment.KEY_WORD_B, ""));
// //            card.setComment(args.getString(EditCardDialogFragment.KEY_COMMENT, ""));
//             int color = card.getColor();
//             card.setColor(args.getInt(EditCardDialogFragment.KEY_COLOR, 0));
//
//             // アイコンの画像を更新する
//             IconCard cardIcon = (IconCard)editingIcon;
//             if (color != card.getColor()) {
//                 cardIcon.setColor(card.getColor());
//                 cardIcon.updateIconImage();
//             }
//
//             editingIcon.updateTitle();
//             // DB更新
//             TangoCardDao().updateOne(card);
//         }
//
//         mTopView.invalidate();
    }
    
    public func cancelEditCard() {
    
    }
    
    
    /**
     * EditBookDialogCallbacks
     */
    public func submitEditBook() {
    //         if (args == nil) return;
    
    //         int mode = args.getInt(EditCardDialogFragment.KEY_MODE, EditCardDialogMode.Create.ordinal
    //                 ());
    //         if (mode == EditCardDialogMode.Create.rawValue) {
    //             // 新たにアイコンを追加する
    //             UIconManager iconManager = mIconWinManager!.getMainWindow().getIconManager();
    //             IconBook bookIcon = (IconBook) (iconManager.addNewIcon(
    //                     IconType.Book, TangoParentType.Home, 0, AddPos.Tail));
    //             if (bookIcon == nil) {
    //                 return;
    //             }
    //             TangoBook book = (TangoBook) bookIcon.getTangoItem();
    
    //             // 戻り値を取得
    //             book.setName(args.getString(EditBookDialogFragment.KEY_NAME, ""));
    //             book.setComment(args.getString(EditBookDialogFragment.KEY_COMMENT, ""));
    //             book.setColor(args.getInt(EditBookDialogFragment.KEY_COLOR, 0));
    //             bookIcon.updateTitle();
    
    //             bookIcon.setColor(book.getColor());
    //             bookIcon.updateIconImage();
    
    //             // DB更新
    //             TangoBookDao().updateOne(book);
    //         } else {
    //             // 既存のアイコンを更新する
    
    //             IconBook bookIcon = (IconBook)editingIcon;
    //             TangoBook book = (TangoBook)bookIcon.getTangoItem();
    
    //             book.setName(args.getString(EditBookDialogFragment.KEY_NAME, ""));
    // //            book.setComment(args.getString(EditCardDialogFragment.KEY_COMMENT, ""));
    //             int color = book.getColor();
    //             book.setColor(args.getInt(EditBookDialogFragment.KEY_COLOR, 0));
    
    //             // アイコンの画像を更新する
    //             if (color != book.getColor()) {
    //                 bookIcon.setColor(book.getColor());
    //                 bookIcon.updateIconImage();
    //             }
    
    //             editingIcon.updateTitle();
    //             // DB更新
    //             TangoBookDao().updateOne(book);
    //         }
    
    //         // アイコン整列
    //         mIconWinManager!.getMainWindow().sortIcons(animate: false);
    //         mTopView.invalidate();
    }
    
    public func cancelEditBook() {

    }
    
    /**
     * IconInfoDialogCallbacks
     */
    /**
     * ダイアログで表示しているアイコンの内容を編集
     * @param icon
     */
    public func IconInfoEditIcon( icon : UIcon) {
    //         switch (icon.getType()) {
    //             case Card: {
    //                 editingIcon = icon;
    //                 if (icon instanceof IconCard) {
    //                     editCardDialog((IconCard)editingIcon);
    //                     mIconInfoDlg.closeWindow();
    //                     mIconInfoDlg = nil;
    //                 }
    //             }
    //             break;
    //             case Book: {
    //                 editingIcon = icon;
    //                 if (icon instanceof IconBook) {
    //                     editBookDialog((IconBook)editingIcon);
    //                     mIconInfoDlg.closeWindow();
    //                     mIconInfoDlg = nil;
    //                 }
    //             }
    //             break;
    //         }
    }
    
    /**
     * アイコンをコピー
     */
    public func IconInfoCopyIcon( icon : UIcon) {
    //         self.copyIcon(icon);
    //         mIconInfoDlg.closeWindow();
    //         mIconInfoDlg = nil;
    }
    
    /**
     * アイコンをゴミ箱に移動
     */
    public func IconInfoThrowIcon(icon : UIcon) {
    //         if (icon != nil) {
    //             moveIconToTrash(icon);
    //         }
    }
    
    /**
     * アイコンを開く
     */
    public func IconInfoOpenIcon(icon : UIcon) {
    //         if (mIconWinManager!.getSubWindow().isShow() == false ||
    //                 icon != mIconWinManager!.getSubWindow().getParentIcon())
    //         {
    //             openIcon(icon);
    //         }
    
    //         if (mIconInfoDlg != nil) {
    //             mIconInfoDlg.closeWindow();
    //             mIconInfoDlg = nil;
    //         }
    }
    
    /**
     * 学習開始
     */
    public func IconInfoStudy(icon : UIcon) {
        // 編集ページでは学習開始は行えない
    }
    
    /**
     * アイコン配下をクリーンアップする
     */
    public let CleanupDialogButtonOK = 101
    public let TrashDialogButtonOK = 102
    public let ExportDialogButtonOK = 103
    public let ExportFinishedDialogButtonOk = 104
    public let ButtonIdMoveIconsToTrash = 105
    public let ButtonIdCopyOK = 106
    
    public func IconInfoCleanup(icon : UIcon) {
    //         if (icon == nil || icon.getType() == IconType.Trash) {
    //             if (mDialog != nil) {
    //                 mDialog.closeDialog();
    //                 mDialog = nil;
    //             }
    //             // Daoデバッグ用のダイアログを表示
    //             mDialog = UDialogWindow.createInstance(UDialogWindow.DialogType.Mordal,
    //                     self, self,
    //                     UDialogWindow.ButtonDir.Vertical, UDialogWindow.DialogPosType.Center,
    //                     true,
    //                     mTopView.getWidth(), mTopView.getHeight(),
    //                     Color.rgb(200,100,100), Color.WHITE);
    //             mDialog.addToDrawManager();
    
    //             // 確認のダイアログを表示する
    //             mDialog.setTitle(UResourceManager.getStringById(R.string.confirm_cleanup_trash));
    
    //             // ボタンを追加
    //             mDialog.addButton(CleanupDialogButtonOK, "OK", Color.BLACK,
    //                     UColor.LightGreen);
    //             mDialog.addCloseButton(UResourceManager.getStringById(R.string.cancel));
    //         }
    }
    
    /**
     * ゴミ箱内のアイコンを元に戻す
     * @param icon
     */
    public func IconInfoReturnIcon(icon : UIcon) {
    //         icon.getParentWindow().moveIconIntoHome(icon, mIconWinManager!.getMainWindow());
    
    //         mIconInfoDlg.closeWindow();
    //         mIconInfoDlg = nil;
    }
    
    /**
     * ゴミ箱内のアイコンを１件削除する
     * @param icon
     */
    public func IconInfoDeleteIcon(icon : UIcon) {
    //         icon.getParentWindow().removeIcon(icon);
    
    //         mIconInfoDlg.closeWindow();
    //         mIconInfoDlg = nil;
    
    //         mTopView.invalidate();
    }
    
    /**
    * UDialogCallbacks
    */
    public func dialogClosed( dialog : UDialogWindow) {
        if dialog === mDialog {
            mDialog = nil
        }
    }
    
    /**
     * UIconWindowSubCallbacks
     */
    public func IconWindowSubAction( actionId : SubWindowActionId, icon : UIcon?) {
    //         switch (id) {
    //             case Close:
    //                 mIconWinManager!.hideWindow(mIconWinManager!.getSubWindow(), true);
    //                 break;
    //             case Edit:
    //                 editingIcon = icon;
    //                 if (icon instanceof IconBook) {
    //                     editBookDialog((IconBook)editingIcon);
    //                 }
    //                 break;
    //             case Copy:
    //                 // コピー確認ダイアログを表示する
    //                 if (mDialog != nil) {
    //                     mDialog.closeDialog();
    //                     mDialog = nil;
    //                 }
    //                 // Daoデバッグ用のダイアログを表示
    //                 mDialog = UDialogWindow.createInstance(UDialogWindow.DialogType.Mordal,
    //                         self, self,
    //                         UDialogWindow.ButtonDir.Horizontal, UDialogWindow.DialogPosType.Center,
    //                         true,
    //                         mTopView.getWidth(), mTopView.getHeight(),
    //                         Color.rgb(200,100,100), Color.WHITE);
    //                 mDialog.addToDrawManager();
    
    //                 // 確認のダイアログを表示する
    //                 String text = String.format(UResourceManager.getStringById(R.string.confirm_copy_book), icon.getTitle());
    //                 mDialog.setTitle(String.format(text, icon.getTitle()));
    
    //                 // ボタンを追加
    //                 mDialog.addButton(ButtonIdCopyOK, "OK", Color.BLACK,
    //                         UColor.LightGreen);
    //                 mDialog.addCloseButton(UResourceManager.getStringById(R.string.cancel));
    
    //                 // 捨てるアイコンを保持
    //                 mCopyIcon = icon;
    //                 break;
    //             case Delete: {
    //                 // 確認のダイアログを表示する
    //                 if (mDialog != nil) {
    //                     mDialog.closeDialog();
    //                     mDialog = nil;
    //                 }
    //                 // Daoデバッグ用のダイアログを表示
    //                 mDialog = UDialogWindow.createInstance(UDialogWindow.DialogType.Mordal,
    //                         self, self,
    //                         UDialogWindow.ButtonDir.Horizontal, UDialogWindow.DialogPosType.Center,
    //                         true,
    //                         mTopView.getWidth(), mTopView.getHeight(),
    //                         Color.rgb(200,100,100), Color.WHITE);
    //                 mDialog.addToDrawManager();
    
    //                 // 確認のダイアログを表示する
    //                 mDialog.setTitle(String.format(UResourceManager.getStringById(R.string.confirm_moveto_trash), icon.getTitle()));
    
    //                 // ボタンを追加
    //                 mDialog.addButton(TrashDialogButtonOK, "OK", Color.BLACK,
    //                         UColor.LightGreen);
    //                 mDialog.addCloseButton(UResourceManager.getStringById(R.string.cancel));
    
    //                 // 捨てるアイコンを保持
    //                 mThrowIcon = icon;
    //             }
    //                 break;
    //             case Export:
    //             {
    //                 // 確認のダイアログを表示する
    //                 if (mDialog != nil) {
    //                     mDialog.closeDialog();
    //                     mDialog = nil;
    //                 }
    
    //                 mDialog = UDialogWindow.createInstance(UDialogWindow.DialogType.Mordal,
    //                         self, self,
    //                         UDialogWindow.ButtonDir.Horizontal, UDialogWindow.DialogPosType.Center,
    //                         true,
    //                         mTopView.getWidth(), mTopView.getHeight(),
    //                         Color.rgb(200,100,100), Color.WHITE);
    //                 mDialog.addToDrawManager();
    
    //                 // 確認のダイアログを表示する
    //                 mDialog.setTitle(UResourceManager.getStringById(R.string.confirm_export_csv));
    
    //                 // ボタンを追加
    //                 mDialog.addButton(ExportDialogButtonOK, "OK", Color.BLACK,
    //                         UColor.LightGreen);
    //                 mDialog.addCloseButton(UResourceManager.getStringById(R.string.cancel));
    
    //                 // アイコンを保持
    //                 if (icon.getType() == IconType.Book) {
    //                     mExportIcon = (IconBook)icon;
    //                 }
    //             }
    //                 break;
    //             case Cleanup:
    //                 // ゴミ箱を空にする
    //                 IconInfoCleanup(nil);
    //                 break;
    //         }
    //     }
    }
}

