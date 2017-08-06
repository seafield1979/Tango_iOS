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

public enum EditBookDialogMode {
    case Create     // 新しくアイコンを作成する
    case Edit       // 既存のアイコンを編集する
}

/**
 単語カード編集ダイアログが終了した時に呼ばれるコールバック
 */
public protocol EditCardDialogCallbacks {
    // カード情報が更新された時に呼ばれる
    func submitEditCard(mode : EditCardDialogMode,
                        wordA : String?, wordB : String?, color : UIColor?)
    // 更新がキャンセルされた時に呼ばれる
    func cancelEditCard()
}

/**
 単語帳編集ダイアログが終了した時に呼ばれるコールバック
 */
public protocol EditBookDialogCallbacks {
    // 単語帳情報が更新された時に呼ばれる
    func submitEditBook(mode : EditBookDialogMode,
                        name : String?, comment : String?, color : UIColor?)
    // 更新がキャンセルされた時に呼ばれる
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
    func IconInfoCleanup(icon: UIcon?)
    
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
    private let DialogTextColor = UColor.makeColor(200,100,100)

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
    
    // Card追加用のモーダルViewControllerを表示
    private func addCardDialog() {
        // カード情報入力用のViewControllerをモーダルで表示
        let viewController = EditCardViewController(
            nibName: "EditCardViewController",
            bundle: nil)
        
        viewController.delegate = self
        viewController.mMode = .Create
        
        mTopView.parentVC!.present(viewController,
                                   animated: true,
                                   completion: nil)
    }
    
    // Book追加用のダイアログを表示
    private func addBookDialog() {
        // カード情報入力用のViewControllerをモーダルで表示
        let viewController = EditBookViewController(
            nibName: "EditBookViewController",
            bundle: nil)
        
        viewController.delegate = self
        viewController.mMode = .Create
        
        mTopView.parentVC!.present(viewController,
                                   animated: true,
                                   completion: nil)
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
        // カード情報入力用のViewControllerをモーダルで表示
        let viewController = EditCardViewController(
            nibName: "EditCardViewController",
            bundle: nil)
        
        viewController.delegate = self
        viewController.mMode = .Edit
        viewController.mCard = iconCard.card
        
        mTopView.parentVC!.present(viewController,
                                   animated: true,
                                   completion: nil)
    }
    
    private func editBookDialog( iconBook : IconBook ) {
        // 単語帳情報入力用のViewControllerをモーダルで表示
        let viewController = EditBookViewController(
            nibName: "EditBookViewController",
            bundle: nil)
        
        viewController.delegate = self
        viewController.mMode = .Edit
        viewController.mBook = iconBook.book
        
        mTopView.parentVC!.present(viewController,
                                   animated: true,
                                   completion: nil)
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
            // メインウィンドウに追加
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
    private func addBookIcon() -> IconBook? {
        let iconManager = mIconWinManager!.getMainWindow()!.getIconManager()
        let iconBook = iconManager!.addNewIcon(type: IconType.Book,
                                parentType: TangoParentType.Home,
                                parentId: 0, addPos: AddPos.Tail) as! IconBook
        mIconWinManager!.getMainWindow()!.sortIcons(animate: true)

        mTopView.invalidate()
        
        return iconBook
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
                mIconInfoDlg = IconInfoDialogCard.createInstance(
                    parentView : mTopView, iconInfoDialogCallbacks : self, windowCallbacks : self,
                    icon : icon, x : x, y : y)
                // newフラグをクリア
                icon.setNewFlag(newFlag: false)
            
            case .Book:
                IconInfoOpenIcon(icon: icon)
                // newフラグをクリア
                icon.setNewFlag(newFlag: false)
            
            case .Trash:
                IconInfoOpenIcon(icon: icon)
                
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
    
    // MARK: EditCardDialogCallbacks
    /**
     *
     */
    public func submitEditCard(mode : EditCardDialogMode,
                               wordA : String?, wordB : String?, color : UIColor?) {
         if mode == EditCardDialogMode.Create {
             // 新規作成

            let iconCard : IconCard = addCardIcon()
            
            // 戻り値を取得
            let updateCard = iconCard.card
            updateCard.wordA = wordA
            updateCard.wordB = wordB
            if color != nil {
                updateCard.color = Int(color!.intColor())
            }

            iconCard.updateTitle()
            if color != nil {
                iconCard.setColor(color!)
            }
            iconCard.updateIconImage()
            // DB更新
            TangoCardDao.updateOne(card: updateCard)
        } else {
            // 更新
            let card = editingIcon!.getTangoItem() as! TangoCard
            card.wordA = wordA
            card.wordB = wordB
            
            let oldColor = UInt32(card.color)
            if color != nil {
                card.color = Int(color!.intColor())
            }
            
            // アイコンの画像を更新する
            let cardIcon = editingIcon as! IconCard
            if color!.intColor() != oldColor {
                cardIcon.setColor(color!)
                cardIcon.updateIconImage()
            }

            editingIcon!.updateTitle()
            // DB更新
            TangoCardDao.updateOne(card: card)
        }
        mTopView.invalidate();
    }
    
    public func cancelEditCard() {
    
    }
    
    
    // MARK: EditBookDialogCallbacks
    public func submitEditBook(mode : EditBookDialogMode,
                               name : String?, comment : String?, color : UIColor?)
    {
        if mode == EditBookDialogMode.Create {
            // 新たにアイコンを追加する
            let iconManager = mIconWinManager!.getMainWindow()!.getIconManager()
            let bookIcon = iconManager!.addNewIcon(
                type: IconType.Book,
                parentType: TangoParentType.Home,
                parentId: 0,
                addPos: AddPos.Tail) as! IconBook
            
            let book = bookIcon.book

            // 戻り値を取得
            book!.name = name
            book!.comment = comment
            if color != nil {
                book!.color = Int(color!.intColor())
            }
            bookIcon.updateTitle()

            if color!.intColor() != UInt32(book!.color) {
                bookIcon.setColor(color!)
                bookIcon.updateIconImage()
            }

            // DB更新
            TangoBookDao.updateOne(book: book!)
        } else {
            // 既存のアイコンを更新する

            let bookIcon = editingIcon!
            let book = editingIcon!.getTangoItem() as! TangoBook

            book.name = name
            book.comment = comment
            if color != nil {
                book.setColor(color: Int(color!.intColor()))
                // アイコンの画像を更新する
                bookIcon.setColor(color!)
                bookIcon.updateIconImage()
            }

            bookIcon.updateTitle();
            // DB更新
            TangoBookDao.updateOne(book: book)
        }

        // アイコン整列
        mIconWinManager!.getMainWindow()!.sortIcons(animate: false);
        mTopView.invalidate()
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
        switch icon.getType() {
        case .Card:
            editingIcon = icon
            if icon is IconCard {
                editCardDialog(iconCard: editingIcon as! IconCard)
                mIconInfoDlg!.closeWindow()
                mIconInfoDlg = nil
            }
        default:
            break
        }
    }
    
    /**
     * アイコンをコピー
     */
    public func IconInfoCopyIcon( icon : UIcon) {
        self.copyIcon(icon: icon)
        mIconInfoDlg!.closeWindow()
        mIconInfoDlg = nil
    }
    
    /**
     * アイコンをゴミ箱に移動
     */
    public func IconInfoThrowIcon(icon : UIcon) {
        moveIconToTrash(icon: icon)
    }
    
    /**
     * アイコンを開く
     */
    public func IconInfoOpenIcon(icon : UIcon) {
        if mIconWinManager!.getSubWindow().isShow == false ||
                icon !== mIconWinManager!.getSubWindow().getParentIcon()
        {
            openIcon(icon: icon)
        }

        // アイコン情報ダイアログが表示されていたら閉じる
        if mIconInfoDlg != nil {
            mIconInfoDlg!.closeWindow()
            mIconInfoDlg = nil
        }
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
    
    public func IconInfoCleanup(icon : UIcon?) {
         if icon == nil || icon!.getType() == IconType.Trash {
             if mDialog != nil {
                 mDialog!.closeDialog()
                 mDialog = nil
             }
             // Daoデバッグ用のダイアログを表示
             mDialog = UDialogWindow.createInstance(
                parentView : mTopView,
                type : .Mordal,
                buttonCallbacks : self, dialogCallbacks : self,
                dir : UDialogWindow.ButtonDir.Vertical,
                posType : .Center,
                isAnimation : true,
                screenW : mTopView.getWidth(), screenH : mTopView.getHeight(),
                textColor : DialogTextColor, dialogColor : UIColor.white)
             mDialog!.addToDrawManager();

             // 確認のダイアログを表示する
             mDialog!.setTitle(UResourceManager.getStringByName("confirm_cleanup_trash"))

             // ボタンを追加
             _ = mDialog!.addButton(id : CleanupDialogButtonOK, text : "OK",
                                textColor : UIColor.black, color : UColor.LightGreen)
             mDialog!.addCloseButton(text: UResourceManager.getStringByName("cancel"))
         }
    }
    
    /**
     * ゴミ箱内のアイコンを元に戻す
     * @param icon
     */
    public func IconInfoReturnIcon(icon : UIcon) {
        icon.getParentWindow()!.moveIconIntoHome(icon: icon,
                                                mainWindow: mIconWinManager!.getMainWindow())
        if mIconInfoDlg != nil {
            mIconInfoDlg!.closeWindow()
            mIconInfoDlg = nil
        }
    }
    
    /**
     * ゴミ箱内のアイコンを１件削除する
     * @param icon
     */
    public func IconInfoDeleteIcon(icon : UIcon) {
        icon.getParentWindow()!.removeIcon(icon: icon)

        if mIconInfoDlg != nil {
            mIconInfoDlg!.closeWindow()
            mIconInfoDlg = nil
        }

        mTopView.invalidate();
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
        switch actionId {
        case .Close:
            _ = mIconWinManager!.hideWindow(
                window: mIconWinManager!.getSubWindow(),
                animation: true)
           
        case .Edit:
            editingIcon = icon;
            if icon is IconBook {
                editBookDialog(iconBook: editingIcon as! IconBook)
            }
            
        case .Copy:
            // コピー確認ダイアログを表示する
            if mDialog != nil {
                mDialog!.closeDialog()
                mDialog = nil
            }
            // Daoデバッグ用のダイアログを表示
            mDialog = UDialogWindow.createInstance(
                    parentView : mTopView,
                    type : .Mordal,
                    buttonCallbacks : self, dialogCallbacks : self,
                    dir : .Horizontal,
                    posType : .Center,
                    isAnimation : true,
                    screenW : mTopView.getWidth(), screenH : mTopView.getHeight(),
                    textColor : DialogTextColor,
                    dialogColor : UColor.White)
            mDialog!.addToDrawManager();

            // 確認のダイアログを表示する
            if icon!.getTitle() != nil {
                let text = String(format:UResourceManager.getStringByName("confirm_copy_book"), icon!.getTitle()!)
                mDialog!.setTitle(text)
            }

            // ボタンを追加
            _ = mDialog!.addButton(id: ButtonIdCopyOK,
                               text: "OK", textColor: UIColor.black,
                              color: UColor.LightGreen);
            mDialog!.addCloseButton(text: UResourceManager.getStringByName("cancel"))

            // 捨てるアイコンを保持
            mCopyIcon = icon
            
        case .Delete:
            // 確認のダイアログを表示する
            if mDialog != nil {
                mDialog!.closeDialog()
                mDialog = nil
            }
            // Daoデバッグ用のダイアログを表示
            mDialog = UDialogWindow.createInstance(
                parentView : mTopView,
                type : .Mordal,
                buttonCallbacks : self, dialogCallbacks : self,
                dir : .Horizontal,
                posType : .Center,
                isAnimation : true,
                screenW : mTopView.getWidth(), screenH : mTopView.getHeight(),
                textColor : DialogTextColor, dialogColor : UIColor.white)
            mDialog!.addToDrawManager()

            // 確認のダイアログを表示する
            if icon!.getTitle() != nil {
                mDialog!.setTitle(String(format: UResourceManager.getStringByName("confirm_moveto_trash"), icon!.getTitle()!))
            }

            // ボタンを追加
            _ = mDialog!.addButton(id: TrashDialogButtonOK, text: "OK",
                               textColor: UIColor.black, color: UColor.LightGreen);
            mDialog!.addCloseButton(text: UResourceManager.getStringByName("cancel"))

            // 捨てるアイコンを保持
            mThrowIcon = icon
            
        case .Export:
            // 確認のダイアログを表示する
            if (mDialog != nil) {
                mDialog!.closeDialog();
                mDialog = nil;
            }

            mDialog = UDialogWindow.createInstance(
                parentView : mTopView, type : .Mordal,
                buttonCallbacks : self, dialogCallbacks : self,
                dir : .Horizontal,
                posType : .Center,
                isAnimation : true,
                screenW : mTopView.getWidth(), screenH : mTopView.getHeight(),
                textColor : DialogTextColor, dialogColor : UIColor.white)
            mDialog!.addToDrawManager();

            // 確認のダイアログを表示する
            mDialog!.setTitle(UResourceManager.getStringByName("confirm_export_csv"))

            // ボタンを追加
            _ = mDialog!.addButton(id: ExportDialogButtonOK, text: "OK",
                               textColor: UIColor.black, color: UColor.LightGreen)
            mDialog!.addCloseButton(text: UResourceManager.getStringByName("cancel"))

            // アイコンを保持
            if icon is IconBook {
                mExportIcon = icon as! IconBook
            }
            
        case .Cleanup:
            // ゴミ箱を空にする
            IconInfoCleanup(icon: nil)
            break
        }
    }
}

