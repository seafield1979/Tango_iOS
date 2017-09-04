//
//  PageViewBackup.swift
//  TangoBook
//
//  Created by Shusuke Unno on 2017/07/24.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import UIKit

public class PageViewBackup : UPageView, UDialogCallbacks, UButtonCallbacks, UCheckBoxCallbacks, UListItemCallbacks {
    // MARK: Constants
    private let DRAW_PRIORITY = 1

    // layout
    private let TOP_Y : Int = 17
    private let MARGIN_H : Int = 17
    private let MARGIN_V : Int = 17
    private let BOX_WIDTH : Int = 23
    private let FONT_SIZE : Int = 17

    private let TEXT_COLOR = UIColor.black

    // button IDs
    private let ButtonIdOverWriteOK : Int = 100  // 上書き確認
    private let ButtonIdBackupOK : Int = 101      // バックアップOK

    /**
     * Member variables
     */
    private var mAutoBackupCheck : UCheckBox?
    private var mListView : ListViewBackup?
    private var mDialog : UDialogWindow?          // バックアップをするかどうかの確認ダイアログ
    private var mBackupItem : ListItemBackup?      // リストで選択したアイテム
    

    /**
     * Enums
     */
    /**
     * Constants
     */
    public static let TAG = "PageViewBackup"
    
    // button id
    private static let buttonId1 = 100
    
    private static let DRAW_PRIORITY = 100
    
    /**
     * Propaties
     */
    
    /**
     * Constructor
     */
    public init( topScene : TopScene, title : String) {
        super.init( topScene: topScene, pageId: PageIdMain.BackupDB.rawValue, title: title)
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
     * そのページで表示される描画オブジェクトを初期化する
     */
//    override public func initDrawables() {
//        // 描画オブジェクトクリア
//        UDrawManager.getInstance().initialize()
//        
//        // ここにページで表示するオブジェクト生成処理を記述
//        let width = self.mTopScene.getWidth()
//        
//        let button = UButtonText(
//            callbacks: self, type: UButtonType.Press,
//            id: PageViewBackup.buttonId1, priority: PageViewBackup.DRAW_PRIORITY,
//            text: "test", createNode: true, x: 50, y: 100,
//            width: width - 100, height: 100,
//            fontSize: UDpi.toPixel(20), textColor: UIColor.white, bgColor: .blue)
//        button.addToDrawManager()
//        
//    }
    /**
     * そのページで表示される描画オブジェクトを初期化する
     */
    public override func initDrawables() {
        let width = mTopScene.getWidth()
        let height = mTopScene.getHeight()

        let x = UDpi.toPixel(MARGIN_H)
        var y = UDpi.toPixel(TOP_Y)

        UDrawManager.getInstance().initialize()

        // 自動バックアップ CheckBox
        mAutoBackupCheck = UCheckBox(
            callbacks : self, drawPriority : DRAW_PRIORITY, x : x, y : y,
            boxWidth : UDpi.toPixel(BOX_WIDTH),
            text : UResourceManager.getStringByName("auto_backup"),
            fontSize : UDpi.toPixel(FONT_SIZE), fontColor : TEXT_COLOR)
        
        mAutoBackupCheck!.addToDrawManager()

        if MySharedPref.readBool(MySharedPref.AutoBackup) {
            mAutoBackupCheck!.isChecked = true
        }
        y += mAutoBackupCheck!.getHeight() + UDpi.toPixel(MARGIN_V)

        // ListView
        let listViewH = height - (UDpi.toPixel(MARGIN_H) * 3 + mAutoBackupCheck!.getHeight())
        
        mListView = ListViewBackup(
            topScene : mTopScene, listItemCallbacks : self,
            type : ListViewBackup.ListViewType.Backup, priority : DRAW_PRIORITY,
            x : x, y : y, width : width-UDpi.toPixel(MARGIN_H)*2, height : listViewH,
            bgColor : nil)
        
        mListView!.setFrameColor( .gray )
        mListView!.addToDrawManager()
    }
    
    /**
     * ソフトウェアキーの戻るボタンを押したときの処理
     * @return
     */
    public override func onBackKeyDown() -> Bool {
        return false
    }
    
   
    // MARK: Callbacks

    /**
     * UCheckBoxCallbacks
     */
    /**
     * チェックされた時のイベント
     */
    public func UCheckBoxChanged( checked : Bool ) {
        MySharedPref.writeBool(key: MySharedPref.AutoBackup, value: checked)
    }

    /**
     * UListItemCallbacks
     */
    /**
     * 項目がクリックされた
     * @param item
     */
    public func ListItemClicked( item : UListItem) {
        let width : CGFloat = mTopScene.getWidth()

        // リストの種類を判定
        if !(item is ListItemBackup) {
            return
        }

        let backupItem = item as? ListItemBackup

        let backup : BackupFile? = backupItem!.getBackup()
        if backup == nil {
            return
        }
        
        var title : String
        var buttonId : Int

        if backup!.isEnabled() == false {
            // バックアップ確認
            title = UResourceManager.getStringByName("confirm_backup")
            buttonId = ButtonIdBackupOK
        } else {
            // バックアップファイルがあったら上書き確認
            title = UResourceManager.getStringByName("confirm_overwrite")
            buttonId = ButtonIdOverWriteOK
        }

        mBackupItem = backupItem
        // Dialog
        mDialog = UDialogWindow.createInstance(
            topScene : mTopScene, buttonCallbacks : self, dialogCallbacks : self,
            buttonDir : UDialogWindow.ButtonDir.Horizontal,
            screenW : width, screenH : mTopScene.getHeight())
        mDialog!.setTitle(title)
        _ = mDialog!.addButton(id : buttonId, text : "OK", fontSize : UDpi.toPixel(FONT_SIZE), textColor : UIColor.black, color : UIColor.white)
        mDialog!.addCloseButton( text: UResourceManager.getStringByName("cancel") )
        
        mDialog!.addToDrawManager()
    }
    

    /**
     * バックアップ処理
     * xmlファイル作成と、データベースにバックアップ情報を保存
     * @param backupItem
     * @param backup
     */
    private func doBackup( backupItem : ListItemBackup, backup : BackupFile) -> Bool {
        mBackupItem = backupItem

        let url : URL = BackupManager.getManualBackupURL(slot: backup.getId())
        
        let backupInfo : BackupFileInfo = BackupManager.getInstance().saveToFile(url: url)!
        let newText : String? = BackupManager.getBackupInfo( url: url)
        if newText == nil {
            return false
        }
        backupItem.setText(text: newText)
        backupItem.initSKNode()

        // データベース更新(BackupFile)
        _ = BackupFileDao.updateOne( id : backup.getId(), bookNum : backupInfo.getBookNum(), cardNum : backupInfo.getCardNum())
        
        return true
    }

    /**
     * バックアップ完了時ダイアログを表示
     * @param success バックアップ成功したかどうか
     */
    private func showDoneDialog(success : Bool) {
        if mDialog != nil {
            mDialog!.closeDialog()
        }

        var text : String
        text = UResourceManager.getStringByName( success ? "backup_complete" : "backup_failed" )
        
        mDialog = UDialogWindow.createInstance(
            topScene : mTopScene, buttonCallbacks : self, dialogCallbacks : self,
            buttonDir : UDialogWindow.ButtonDir.Horizontal,
            screenW : mTopScene.getWidth(), screenH : mTopScene.getHeight())
        
        mDialog!.setTitle(text)
        mDialog!.addCloseButton(text: "OK", textColor: UIColor.black, bgColor: UIColor.white)
        
        mDialog!.addToDrawManager()
    }

    public func ListItemButtonClicked(item : UListItem, buttonId : Int) {
        // ListItemにボタンはないので不要
    }

    /**
     * UButtonCallbacks
     */
    public func UButtonClicked( id : Int, pressedOn : Bool) -> Bool{
        switch id {
        case ButtonIdBackupOK:
            fallthrough
        case ButtonIdOverWriteOK:
            let ret = doBackup(backupItem: mBackupItem!, backup: mBackupItem!.getBackup()!)
            showDoneDialog(success: ret)
            break
        default:
            break
        }
        return false
    }

    /**
     * UDialogCallbacks
     */
    public func dialogClosed( dialog : UDialogWindow) {
        if mDialog === dialog {
            mDialog = nil
        }
    }
}
