//
//  PageViewBackup.swift
//  TangoBook
//
//  Created by Shusuke Unno on 2017/07/24.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import UIKit

public class PageViewBackup : UPageView, UDialogCallbacks, UButtonCallbacks, UCheckBoxCallbacks, UListItemCallbacks, XmlBackupCallbacks {
    // MARK: Constants
    private let DRAW_PRIORITY = 1

    // layout
    private let TOP_Y : Int = 17
    private let MARGIN_H : Int = 17
    private let MARGIN_V : Int = 17
    private let BOX_WIDTH : Int = 23
    private let TEXT_SIZE : Int = 17

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
            fontSize : UDpi.toPixel(TEXT_SIZE), fontColor : TEXT_COLOR)
        
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
        
        mListView!.setFrameColor( .black )
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
//        let width : CGFloat = mTopScene.getWidth()
//
//        // リストの種類を判定
//        if !(item is ListItemBackup) {
//            return
//        }
//
//        var backupItem = item as? ListItemBackup
//
//        BackupFile backup = backupItem.getBackup();
//        if (backup == null) return;
//
//        String title;
//        int buttonId;
//
//        if (backup.isEnabled() == false) {
//            // バックアップ確認
//            title = mContext.getString(R.string.confirm_backup);
//            buttonId = ButtonIdBackupOK;
//        } else {
//            // バックアップファイルがあったら上書き確認
//            title = mContext.getString(R.string.confirm_overwrite);
//            buttonId = ButtonIdOverWriteOK;
//        }
//
//        mBackupItem = backupItem;
//        // Dialog
//        mDialog = UDialogWindow.createInstance(self, self,
//                UDialogWindow.ButtonDir.Horizontal, width, mTopScene.getHeight());
//        mDialog.addToDrawManager();
//        mDialog.setTitle(title);
//        mDialog.addButton(buttonId, "OK", Color.BLACK, Color.WHITE);
//        mDialog.addCloseButton(UResourceManager.getStringById(R.string.cancel));
    }
    

    /**
     * バックアップ処理
     * xmlファイル作成と、データベースにバックアップ情報を保存
     * @param backupItem
     * @param backup
     */
    private func doBackup( backupItem : ListItemBackup, backup : BackupFile) -> Bool {
//        mBackupItem = backupItem;
//
//        // バックアップファイルがなければそのまま保存
//        BackupFileInfo backupInfo = BackupManager.getInstance().saveManualBackup(backup.getId());
//        String newText = BackupManager.getInstance().getBackupInfo(backupInfo);
//        if (newText == null) {
//            return false;
//        }
//        backupItem.setText(newText);
//
//        // データベース更新(BackupFile)
//        RealmManager.getBackupFileDao().updateOne(backup.getId(), backupInfo.getFilePath(), backupInfo.getBookNum(), backupInfo.getCardNum());

        return true
    }

    /**
     * バックアップ完了時ダイアログを表示
     * @param success バックアップ成功したかどうか
     */
    private func showDoneDialog(success : Bool) {
//        if (mDialog != null) {
//            mDialog.closeDialog();
//        }
//
//        String text;
//        if (success) {
//            text = UResourceManager.getStringById(R.string.backup_complete);
////            + "\n\n" +
////                    BackupManager.getInstance().getBackupInfo(backupInfo);
//        } else {
//            text = UResourceManager.getStringById(R.string.backup_failed);
//        }
//
//        mDialog = UDialogWindow.createInstance(self, self,
//                UDialogWindow.ButtonDir.Horizontal, mTopScene.getWidth(), mTopScene.getHeight());
//        mDialog.addToDrawManager();
//        mDialog.setTitle(text);
//        mDialog.addCloseButton("OK", Color.BLACK, Color.WHITE);
    }

    public func ListItemButtonClicked(item : UListItem, buttonId : Int) {

    }

    /**
     * UButtonCallbacks
     */
    public func UButtonClicked( id : Int, pressedOn : Bool) -> Bool{
//        switch id {
//        case ButtonIdBackupOK:
//            fallthrough
//        case ButtonIdOverWriteOK:
//            boolean ret = doBackup(mBackupItem, mBackupItem.getBackup());
//            showDoneDialog(ret);
//        
//            break;
//        }
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

    /**
     * XmlBackupCallbacks
     */
    /**
     * スレッドで実行していたバックアップ完了
     * @param backupInfo
     */
    public func finishBackup( backupInfo : BackupFileInfo) {
//        let newText = BackupManager.getInstance().getBackupInfo(backupInfo)
//        if (newText == null) {
//            showDoneDialog(false);
//            return;
//        }
//        mBackupItem.setText(newText);
//        BackupFile backup = mBackupItem.getBackup();
//
//        // データベース更新(BackupFile)
//        RealmManager.getBackupFileDao().updateOne(backup.getId(),
//                backupInfo.getFilePath(), backupInfo.getBookNum(),
//                backupInfo.getCardNum());
//
//        showDoneDialog(true);
    }
}
