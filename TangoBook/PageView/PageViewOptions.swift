//
//  PageViewBackup.swift
//  TangoBook
//
//  Created by Shusuke Unno on 2017/07/24.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import UIKit
/**
 *  DialogFragmentのコールバック
 */
protocol OptionColorDialogCallbacks {
    func submitOptionColor()
    func cancelOptionColor()
}

/**
 *  DialogFragmentのコールバック
 */
protocol DefaultNameDialogCallbacks {
    func submitDefaultName()
    func cancelDefaultName()
}

public class PageViewOptions : UPageView, UButtonCallbacks, UDialogCallbacks, OptionColorDialogCallbacks, DefaultNameDialogCallbacks, UListItemCallbacks {
    
    // MARK: Enums
    // モード(リストに表示する項目が変わる)
    public enum Mode {
        case All        // 全オプションを表示
        case Edit       // 単語帳編集系の項目を表示
        case Study      // 学習系の項目を表示
    }
    
    // MARK: Constants
    private let DRAW_PRIORITY = 1

    // layout
    private let MARGIN_H = 10
    private let MARGIN_V_S = 10
    private let TEXT_SIZE = 17

    // button ids
    private let ButtonIdReturn = 100
    private let ButtonIdCardWordA = 101       // カードに表示する名前(A->英語)
    private let ButtonIdCardWordB = 102       // カードに表示する名前(B->日本語)
    private let ButtonIdSelectFromAll = 103   // ４択学習モードで不正解のカードをカード全体から取得
    private let ButtonIdSelectFromOne = 104   // ４択学習もーどで不正解のカードを同じ単語帳から取得
    private let ButtonIdStudySorted = 105     // 正解入力学習モードの文字並びをA-Zでソート
    private let ButtonIdStudyRandom = 106     // 正解入力学習モードの文字並びをランダムに表示


    /**
     * Constants
     */
    public static let TAG = "PageViewOptions"
    
    // MARK: Properties

    private var mMode : Mode
    private var mTitleText : UTextView?
    private var mListView : UListView?
    private var mDialog : UDialogWindow?

    // MARK: Initializer
    public init( topScene : TopScene, title : String) {
        mMode = Mode.All
        super.init( topScene: topScene, pageId: PageIdMain.Options.rawValue, title: title)
    }

    // MARK: Accessor
    public func setMode( mode: Mode) {
        mMode = mode
    }

    // MARK: Methods
    override func onShow() {
    }
    
    override func onHide() {
        super.onHide()
    }
    
    /**
     * 描画処理
     * サブクラスのdrawでこのメソッドを最初に呼び出す
     * @param canvas
     * @param paint
     * @return
     */
    override func draw() -> Bool {
        if isFirst {
            isFirst = false
            initDrawables()
        }
        return false
    }
    
    /**
     * タッチ処理
     * @param vt
     * @return
     */
    public func touchEvent(vt : ViewTouch) -> Bool {
        
        return false
    }
    
    /**
     * そのページで表示される描画オブジェクトを初期化する
     */
    public override func initDrawables() {
        UDrawManager.getInstance().initialize()

        let width : CGFloat = mTopScene.getWidth()
        let height : CGFloat = mTopScene.getHeight()

        var x : CGFloat = UDpi.toPixel(MARGIN_H)
        var y : CGFloat = UDpi.toPixel(MARGIN_V_S)

        // Title
        mTitleText = UTextView.createInstance(
            text : UResourceManager.getStringByName("title_options2"),
            fontSize : UDpi.toPixel(TEXT_SIZE), priority : DRAW_PRIORITY,
            alignment : UAlignment.CenterX, createNode : true,
            multiLine : false, isDrawBG : false,
            x : width/2, y : y, width : width, color : .black, bgColor : nil)
        
        mTitleText!.addToDrawManager()
        y += mTitleText!.getSize().height + UDpi.toPixel(MARGIN_V_S)

        // ListView
        let listViewH = height - (UDpi.toPixel(MARGIN_V_S) * 3 + mTitleText!.getSize().height)
        mListView = UListView(
            topScene : mTopScene, windowCallbacks : nil, listItemCallbacks : self,
            priority : DRAW_PRIORITY, x : x, y : y,
            width : width - UDpi.toPixel(MARGIN_H) * 2, height : listViewH, bgColor : nil )
        
        mListView!.setFrameColor( UIColor.lightGray )
        mListView!.addToDrawManager()

        // アイテムを追加
        for option in OptionItems.getItems(mode: mMode)! {
            let info = option.getItemInfo()
            let item = ListItemOption(
                listItemCallbacks : self, itemType : option,
                title : getItemTitle(option: option), isTitle : info.isTitle,
                color : info.color, bgColor : info.bgColor,
                x : 0, width : mListView!.getWidth())
            
            mListView!.add(item: item)
        }

        // スクロールバー等のサイズを更新
        mListView!.updateWindow()
    }

    /**
     * アイテムに表示するテキストを取得する
     * @param option
     * @return
     */
    private func getItemTitle( option : OptionItems) -> String {
        var title : String

        switch option {
            case .CardTitle:
                let cardTitleE = MySharedPref.readBool(MySharedPref.EditCardNameKey, defaultValue: false)
                let str = UResourceManager.getStringByName(cardTitleE! ?
                        "word_b" : "word_a")
                return UResourceManager.getStringByName(option.getItemInfo().title) + " : " + str
            
            case .DefaultNameBook:
                title = option.getItemInfo().title;
                break
            case .DefaultNameCard:
                title = option.getItemInfo().title;
                break
            case .StudyMode3:
                title = option.getItemInfo().title;
                break

            case .StudyMode4:
                title = option.getItemInfo().title
                break

            default:
                title = option.getItemInfo().title
                break
        }
        return UResourceManager.getStringByName(title)
    }

    private func closeDialog() {
        if mDialog != nil {
            mDialog!.closeDialog()
            mDialog = nil
        }
    }

    /**
     * カードのタイトル表示設定のダイアログを表示する
     */
    private func showCardTitleDialog() {
        mDialog = UDialogWindow.createInstance(
            topScene : mTopScene, type : DialogType.Modal,
            buttonCallbacks : self, dialogCallbacks : self,
            dir : UDialogWindow.ButtonDir.Vertical,
            posType : DialogPosType.Center, isAnimation : true,
            screenW : mTopScene.getWidth(), screenH : mTopScene.getHeight(),
            textColor : UIColor.black, dialogColor : UIColor.lightGray)

        mDialog!.setTitle(UResourceManager.getStringByName("card_name_title"));
        let button1 = mDialog!.addButton(
            id : ButtonIdCardWordA, text : UResourceManager.getStringByName("word_a"),
            fontSize : UDpi.toPixel(TEXT_SIZE), textColor : UIColor.black, color : UIColor.white)
        
        let button2 = mDialog!.addButton(id : ButtonIdCardWordB, text : UResourceManager.getStringByName("word_b"), fontSize : UDpi.toPixel(TEXT_SIZE), textColor : UIColor.black, color : UColor.White)

        if (MySharedPref.readBool(MySharedPref.EditCardNameKey)) {
            button2.setChecked(true)
        } else {
            button1.setChecked(true)
        }

        mDialog!.addCloseButton(text: UResourceManager.getStringByName("cancel"))
        
        mDialog!.addToDrawManager()
    }

    /**
     * 学習モード3の不正解カードをどこから選択するかのダイアログを表示
     */
    private func showStudyMode3OptionDialog() {
        mDialog = UDialogWindow.createInstance(
            topScene : mTopScene, type : DialogType.Modal,
            buttonCallbacks : self, dialogCallbacks : self,
            dir : UDialogWindow.ButtonDir.Vertical, posType : DialogPosType.Center,
            isAnimation : true, screenW : mTopScene.getWidth(),
            screenH : mTopScene.getHeight(), textColor : UIColor.black,
            dialogColor : UIColor.lightGray)
        
        mDialog!.addToDrawManager();
        mDialog!.setTitle(UResourceManager.getStringByName("option_mode3_1"))

        // buttons
        let button1 = mDialog!.addButton(
            id : ButtonIdSelectFromAll,
            text : UResourceManager.getStringByName("option_mode3_2"),
            fontSize : UDpi.toPixel(TEXT_SIZE), textColor : UIColor.black,
            color : UIColor.white)

        let button2 = mDialog!.addButton(
            id : ButtonIdSelectFromOne,
            text : UResourceManager.getStringByName("option_mode3_3"),
            fontSize : UDpi.toPixel(TEXT_SIZE), textColor : UIColor.black,
            color : UIColor.white)
        
        if (MySharedPref.readBool(MySharedPref.StudyMode3OptionKey)) {
            button1.setChecked(true)
        } else {
            button2.setChecked(true)
        }

        mDialog!.addCloseButton(text: UResourceManager.getStringByName("cancel"))
    }

    /**
     * 学習モード４の単語の並び設定のダイアログを表示
     */
    private func showStudyMode4OptionDialog() {
        mDialog = UDialogWindow.createInstance(topScene : mTopScene, type : DialogType.Modal, buttonCallbacks : self, dialogCallbacks : self, dir : UDialogWindow.ButtonDir.Vertical, posType : DialogPosType.Center, isAnimation : true, screenW : mTopScene.getWidth(), screenH : mTopScene.getHeight(), textColor : UIColor.black, dialogColor : UIColor.lightGray)
        mDialog!.addToDrawManager();
        mDialog!.setTitle(UResourceManager.getStringByName("option_mode4_2"))

        // buttons
        let button1 = mDialog!.addButton(id : ButtonIdStudySorted, text : UResourceManager.getStringByName("option_mode4_3"), fontSize : UDpi.toPixel(TEXT_SIZE), textColor : UIColor.black, color : UColor.White)
        let button2 = mDialog!.addButton(id : ButtonIdStudyRandom, text : UResourceManager.getStringByName("option_mode4_4"), fontSize : UDpi.toPixel(TEXT_SIZE), textColor : UIColor.black, color : UColor.White)
        
        if (MySharedPref.readBool(MySharedPref.StudyMode4OptionKey)) {
            button2.setChecked(true)
        } else {
            button1.setChecked(true)
        }

        mDialog!.addCloseButton(text: UResourceManager.getStringByName("cancel"))
    }

    // MARK: Callbacks
    /**
     * UButtonCallbacks
     */
    public func UButtonClicked( id : Int, pressedOn : Bool) -> Bool{
        switch id {
        case ButtonIdReturn:
            _ = PageViewManagerMain.getInstance().popPage()
            break;
        case ButtonIdCardWordA:
            fallthrough
        case ButtonIdCardWordB:
            let flag = (id == self.ButtonIdCardWordA) ? false : true
            MySharedPref.writeBool(key: MySharedPref.EditCardNameKey, value: flag)

            // アイテムのテキストを更新
            let item = mListView!.get(index: OptionItems.CardTitle.rawValue) as! ListItemOption
            item.setTitle( getItemTitle(option: OptionItems.CardTitle))
            if mDialog != nil {
                mDialog!.closeDialog()
                mDialog = nil
            }
        
        case ButtonIdSelectFromAll:
            fallthrough
        case ButtonIdSelectFromOne:
            let flag = (id == ButtonIdSelectFromAll) ? true : false
            MySharedPref.writeBool(key: MySharedPref.StudyMode3OptionKey, value: flag)

            // アイテムのテキストを更新
            let item = mListView!.get(index: OptionItems.StudyMode3
                    .rawValue) as! ListItemOption
            item.setTitle( getItemTitle(option: OptionItems.StudyMode3) )

            if mDialog != nil {
                mDialog!.closeDialog()
                mDialog = nil
            }
        
        case ButtonIdStudySorted:
            fallthrough
        case ButtonIdStudyRandom:
            let flag = (id == ButtonIdStudyRandom) ? true : false
            MySharedPref.writeBool( key: MySharedPref.StudyMode4OptionKey, value: flag)

            // アイテムのテキストを更新
            let item = mListView!.get( index: OptionItems.StudyMode4.rawValue ) as! ListItemOption
            item.setTitle( getItemTitle(option: OptionItems.StudyMode4) )

            if (mDialog != nil) {
                mDialog!.closeDialog()
                mDialog = nil
            }
        default:
            break
        }
        return false
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
     * UListItemCallbacks
     */
    /**
     * 項目がクリックされた
     * @param item
     */
    public func ListItemClicked( item : UListItem) {
        let itemId = OptionItems.toEnum(item.getIndex())
        
        switch itemId {
        case .ColorBook:
            fallthrough
        case .ColorCard:
//            OptionColorFragment.ColorMode mode = (itemId == OptionItems.ColorBook) ?  OptionColorFragment.ColorMode.Book : OptionColorFragment.ColorMode.Card;
//            OptionColorFragment dialogFragment = OptionColorFragment.createInstance(self, mode);
//            dialogFragment.show(((AppCompatActivity)mContext).getSupportFragmentManager(),
//                    "fragment_dialog");
        
            break
        case .CardTitle:
            if (mDialog != nil) {
                mDialog!.closeDialog()
                mDialog = nil
            }
            showCardTitleDialog()
        
            break
        case .DefaultNameBook:
//            dialogFragment = DefaultBookNameFragment.createInstance(self)
//            dialogFragment.show(((AppCompatActivity)mContext).getSupportFragmentManager(),
//                    "fragment_dialog");
            break
        case .DefaultNameCard:
//            DefaultCardNameFragment dialogFragment = DefaultCardNameFragment.createInstance
//                    (self);
//            dialogFragment.show(((AppCompatActivity)mContext).getSupportFragmentManager(),
//                    "fragment_dialog");
            break
        case .StudyMode3:
            if mDialog != nil {
                mDialog!.closeDialog()
                mDialog = nil
            }
            showStudyMode3OptionDialog()
            break
        case .StudyMode4:
            if mDialog != nil {
                mDialog!.closeDialog()
                mDialog = nil
            }
            showStudyMode4OptionDialog()
            break
        default:
            break
        }
    }
    
    public func ListItemButtonClicked( item : UListItem, buttonId : Int) {

    }

    /**
     * OptionColorDialogCallbacks
     */
    public func submitOptionColor() {
        
    }
    
    public func cancelOptionColor() {

    }

    /**
     * DefaultNameDialogCallbacks
     */
    public func submitDefaultName() {
//        int fragment_type = 0;
//        if (args != nil) {
//            fragment_type = args.getInt(DefaultBookNameFragment.KEY_FRAGMENT_TYPE);
//        }
//
//        // アイテムのテキストを更新
//        OptionItems option = (fragment_type == DefaultBookNameFragment.FragmentType) ?
//                OptionItems.DefaultNameBook : OptionItems.DefaultNameCard;
//
//        ListItemOption item = (ListItemOption) mListView.get(option.ordinal());
//        if (item != nil) {
//            item.setTitle(getItemTitle(option));
//            mTopScene.invalidate();
//        }
    }
    
    public func cancelDefaultName() {
    }

    /**
     * ソフトウェアキーの戻るボタンを押したときの処理
     * @return
     */
    public override func onBackKeyDown() -> Bool {
        return false
    }    
}

