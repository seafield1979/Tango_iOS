//
//  PageViewBackup.swift
//  TangoBook
//
//  Created by Shusuke Unno on 2017/07/24.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import UIKit

public class PageViewDebugDB : UPageView, UButtonCallbacks, UListItemCallbacks {
    /**
     * Enums
     */
    /**
     * Constants
     */
    public static let TAG = "PageViewDebugDB"
    
    // button id
    private let buttonId1 = 100
    private let buttonIdConfirmOK = 101     // クリア確認ダイアログでOKボタンを押した
    
    private let DRAW_PRIORITY = 100
    private let MenuIdTop : CGFloat = 100
    private let MARGIN_H : CGFloat = 50
    private let MARGIN_V : CGFloat = 50

    
    /**
     * Enums
     */
    enum DebugMenu : String, EnumEnumerable {
        case ShowTangoCard = "ShowTangoCard"
        case ShowTangoBook = "ShowTangoBook"
        case ShowItemPos = "ShowItemPos"
        case ShowBackupFile = "ShowBackupFile"
        case GetNoParentItems = "GetNoParentItems"
        case RescureNoParentItems = "RescureNoParentItems"
        case BackupFile = "BackupFile"
        case ClearAll = "ClearAll"        // 全てのDBを空にする
        case Test1 = "Test1"
        case Test2 = "Tets2"
        case Test3 = "Test3"
    }
    

    
    /**
     * Member variables
     */
    private var mListView : UListView? = nil
    private var mDialog : UDialogWindow? = nil
    
    
    /**
     * そのページで表示される描画オブジェクトを初期化する
     */
    public override func initDrawables() {
        UDrawManager.getInstance().initialize()

        let mListView = UListView(
            topScene : mTopScene, windowCallbacks : nil,
            listItemCallbacks : self, priority : DRAW_PRIORITY,
            x : MARGIN_H, y : MARGIN_V,
            width : mTopScene.getWidth() - MARGIN_H * 2,
            height : mTopScene.getHeight() - MARGIN_V * 2, color : UIColor.white)
        
        mListView.addToDrawManager()

        for menu in DebugMenu.cases {
            let item = ListItemTest1(callbacks : self, text : menu.rawValue, x : 0, width : mListView.getSize().width, color : UIColor.white)
            mListView.add(item: item)
        }
    }
    
    /**
     * Drawableを表示するダイアログ表示テスト
     */
    private func showDrawableDialog() {
        if mDialog != nil {
            mDialog!.closeDialog()
        }
        mDialog = UDialogWindow.createInstance(
            topScene : mTopScene,
            buttonCallbacks : nil, dialogCallbacks : nil,
            buttonDir : UDialogWindow.ButtonDir.Horizontal,
            screenW : mTopScene.getWidth(), screenH : mTopScene.getHeight())
        mDialog!.addToDrawManager();

        let textView = UTextView.createInstance(
            text : "helloworld",
        priority : 0, isDrawBG : false, x : 0, y : 0)
        mDialog!.addDrawable(obj: textView)
        mDialog!.addCloseButton(text: "close")
    }
    
    private func showConfirmDialog() {
        if mDialog != nil {
            mDialog!.closeDialog()
        }
        mDialog = UDialogWindow.createInstance(
            topScene : mTopScene,
            buttonCallbacks : self, dialogCallbacks : nil,
            buttonDir : UDialogWindow.ButtonDir.Horizontal,
            screenW : mTopScene.getWidth(), screenH : mTopScene.getHeight())
        mDialog!.addToDrawManager();
        
        _ = mDialog!.addButton(id: buttonIdConfirmOK, text: "OK", textColor: UIColor.black, color: UIColor.white)
        mDialog!.addCloseButton(text: "close")
    }
    
    private func test1() {
        TangoItemPosDao.correctHomePos()
    }
    
    // テスト用の環境を作成する
    private func test2() {
        _ = TangoCardDao.deleteAll()
        _ = TangoBookDao.deleteAll()
        _ = TangoItemPosDao.deleteAll()
        
        TangoCardDao.addDummy()
        TangoCardDao.addDummy()
        TangoBookDao.addDummy()
    }
    
    // たくさんのカードと単語帳を追加する
    private func test3() {
        for _ in 0..<100 {
            TangoCardDao.addDummy()
        }
    }
    
    /**
     * Callbacks
     */

    /**
     * UListItemCallbacks
     */
    /**
     * 項目がクリックされた
     * @param item
     */
    public func ListItemClicked(item : UListItem ) {
        ULog.printMsg(PageViewDebugDB.TAG, "item clicked:" + item.getMIndex().description)

        switch DebugMenu.toEnum(item.getMIndex()) {
        case .ShowTangoCard:
            _ = TangoCardDao.showAll()
        
        case .ShowTangoBook:
            _ = TangoBookDao.showAll()
        
        case .ShowItemPos:
            _ = TangoItemPosDao.showAll()
        
        case .ShowBackupFile:
        // todo
//                _ = TangoBackupFileDao.selectAll()
            break
        case .ClearAll:
            showConfirmDialog()
            
        case .Test1:
            test1()
            
        case .Test2:
            test2()
            
        case .Test3:
            test3()
            
        default:
            break
        }
    }
    public func ListItemButtonClicked(item : UListItem, buttonId : Int) {

    }

    /**
     * Propaties
     */
    
    /**
     * Constructor
     */
    public override init( topScene : TopScene, title : String) {
        super.init( topScene: topScene, title: title)
    }
    
    /**
     * Methods
     */
    
    override func onShow() {
    }
    
    override func onHide() {
        super.onHide();
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
     * ソフトウェアキーの戻るボタンを押したときの処理
     * @return
     */
    public override func onBackKeyDown() -> Bool {
        return false
    }
    
    /**
     * Callbacks
     */
    /**
     * UButtonCallbacks
     */
    /**
     * ボタンがクリックされた時の処理
     * @param id  button id
     * @param pressedOn  押された状態かどうか(On/Off)
     * @return
     */
    public func UButtonClicked(id : Int, pressedOn : Bool) -> Bool
    {
        switch id {
        case buttonIdConfirmOK:
            _ = TangoCardDao.deleteAll()
            _ = TangoBookDao.deleteAll()
            _ = TangoItemPosDao.deleteAll()
            mDialog!.startClosing()

        default:
            break
        }
        return true
    }
    
}
