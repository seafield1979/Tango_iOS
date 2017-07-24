//
//  MyUserDefault.swift
//  UGui
//
//  Created by Shusuke Unno on 2017/07/12.
//  Copyright © 2017年 Shusuke Unno. All rights reserved.
//

import Foundation

/**
 * Created by shutaro on 2017/06/14.
 * メニューのヘルプ表示
 */

public enum MenuHelpMode : Int {
    case None       // 非表示
    case Name       // メニュー名を表示
    case Help        // メニューヘルプを表示
}


public class MySharedPref {
    /**
     * Constants
     */
    public static let TAG = "MySharedPref"
    
    // 画面のズーム
    public static let ScaleKey = "ScreenScale"
    
    // 初期化フラグ(初回起動時に１回だけ処理を行うために使用)
    public static let InitializeKey = "InitializeFlag";
    
    // option key
    // 単語編集ページのカードの名前表示 (false:英語 / true:日本語)
    public static let EditCardNameKey = "EditCardName"
    
    // 出題方法
    public static let StudyModeKey = "StudyMode"
    
    // 出題方法(英:日)
    public static let StudyTypeKey = "StudyType"
    
    // 出題順
    public static let StudyOrderKey = "StudyOrder"
    
    // 出題絞り込み
    public static let StudyFilterKey = "StudyFilter"
    
    // 自動バックアップ
    public static let AutoBackup = "AutoBackup"
    
    // 編集ページ
    // メニューヘルプ(0:非表示 / 1:メニュー名を表示 / 2:メニューヘルプを表示)
    public static let MenuHelpModeKey = "MenuHelpMode"
    
    // 学習する単語帳編集ページ
    public static let StudyBookSortKey = "StudyBookSort"
    
    /*
     　オプション
     */
    // デフォルトのカード色
    public static let DefaultColorCardKey = "DefaultColorCard"
    
    // デフォルトの単語帳色
    public static let DefaultColorBookKey = "DefaultColorBook"
    
    // デフォルトのカード名
    public static let DefaultCardWordAKey = "DefaultCardWordA"
    public static let DefaultCardWordBKey = "DefaultCardWordB"
    
    // デフォルトの単語帳名
    public static let DefaultNameBookKey = "DefaultNameBook"
    
    // ４択モードで正解以外のカードをどの範囲から取得するか
    public static let StudyMode3OptionKey = "StudyMode3Select"
    
    // 単語入力モードの文字並び (false:アルファベット順 / true:ランダム)
    public static let StudyMode4OptionKey = "StudyMode4Seq"
    
    
    /**
     * Static varialbes
     */
    private static var singleton : MySharedPref? = nil
    
    /**
     * Member variables
     */
    private var userDefaults : UserDefaults? = nil
    
    // 設定値参照用
    private var mMenuHelpMode : MenuHelpMode = .None
    
    /**
     * Get/Set
     */
//    public static func getMenuHelpMode() -> MenuHelpMode {
//        let instance : MySharedPref = getInstance()
//        return instance.mMenuHelpMode
//    }
    
//    public static func setMenuHelpMode(mode : MenuHelpMode) {
//        let instance : MySharedPref = getInstance()
//        
//        if instance.mMenuHelpMode != mode {
//            instance.mMenuHelpMode = mode
//            getInstance().writeInt(MySharedPref.MenuHelpModeKey, mode.ordinal());
//        }
//    }
//    
    /**
     * Constructor
     * Singleton
     */
    private init() {
        userDefaults = UserDefaults.standard
    }
    
    /**
     * 初期化処理
     * アプリ開始時に１回だけコールする
     * @param context
     */
    public static func initialize() {
        if singleton == nil {
            singleton = MySharedPref()
            
//            singleton.mMenuHelpMode = MenuHelpMode.toEnum(readInt(MenuHelpModeKey));
        }
    }
    public static func getInstance() -> MySharedPref {
        if singleton == nil {
            MySharedPref.initialize()
        }
        return singleton!
    }
    
    /**
     * Methods
     */
//    public static func getCardName() -> Bool? {
//        return readBoolean(key: EditCardNameKey)
//    }
//    public static func getStudyMode() -> StudyMode? {
//    return StudyMode.toEnum(readInt(StudyModeKey));
//    }
//    public static StudyType getStudyType() {
//    return StudyType.toEnum(readInt(StudyTypeKey));
//    }
//    public static StudyOrder getStudyOrder() {
//    return StudyOrder.toEnum(readInt(StudyOrderKey));
//    }
//    public static StudyFilter getStudyFilter() {
//    return StudyFilter.toEnum(readInt(StudyFilterKey));
//    }
    
    /**
     * Delete
     */
    public static func delete(key : String) {
        MySharedPref.getInstance().userDefaults?.removeObject(forKey: key)
    }
    
    /**
     * Write系
     */
    // String
    public static func writeString(key : String, value : String) {
        MySharedPref.getInstance().userDefaults?.set(value, forKey: key)
    }
    // int
    public static func writeInt(key : String, value : Int) {
        MySharedPref.getInstance().userDefaults?.set(value, forKey: key)
    }
    
    // boolean
    public static func writeBoolean(key : String, value: Bool) {
        MySharedPref.getInstance().userDefaults?.set(value, forKey: key)
    }
    
    /**
     * Read系
     */
    // String
    public static func readString(key : String) -> String? {
        return (MySharedPref.getInstance().userDefaults?.string(forKey:key))
    }
    public static func readString(key : String, defaultValue : String) -> String? {
        let str = MySharedPref.getInstance().userDefaults?.string(forKey: key)
        if str == nil {
            return defaultValue
        }
        return str
    }
    
    
    // int
    public static func readInt(key : String) -> Int? {
        return MySharedPref.getInstance().userDefaults?.integer(forKey: key)
    }
    public static func readInt(key : String, defaultValue : Int) -> Int? {
        let value = MySharedPref.getInstance().userDefaults?.integer(forKey: key)
        if value == nil {
            return defaultValue
        }
        return value
    }
    
    // boolean
    public static func readBoolean(key : String) -> Bool? {
        return MySharedPref.getInstance().userDefaults?.bool(forKey: key)
    }
    
    public static func readBoolean(key : String, defaultValue : Bool) -> Bool? {
        let value = MySharedPref.getInstance().userDefaults?.bool(forKey: key)
        if value == nil {
            return defaultValue
        }
        return value
    }
    
    /**
     * Shared Preferences の全てのデータを出力する
     */
    public static func showAllData() {
        let dic = MySharedPref.getInstance().userDefaults?.dictionaryRepresentation

        ULog.printMsg(TAG, dic.debugDescription)
    }
    
    /**
     * 全てのデータを削除
     */
    public static func clearAllData() {
        let dic : [String : Any] = (MySharedPref.getInstance().userDefaults?.dictionaryRepresentation())!
        
        for key in dic.keys {
            MySharedPref.getInstance().userDefaults?.removeObject(forKey: key)
        }
    }
}
