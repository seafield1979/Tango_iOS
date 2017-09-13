//
//  UResourceManager.swift
//  UGui
//  アプリで使用する画像等のリソースを管理するクラス
//
//  Created by Shusuke Unno on 2017/07/11.
//  Copyright © 2017年 Shusuke Unno. All rights reserved.
//

import Foundation
import UIKit

/**
 * Created by shutaro on 2016/12/09.
 *
 * Bitmap画像やstrings以下の文字列等のリソースを管理する
 */
public class UResourceManager {
    /**
     * Constants
     */
    public static let TAG = "UResourceManager"
    
    /**
     * Member variables
     */
//    private Context mContext;
//    private View mView;
    
    // 通常画像のキャッシュ
    private static var imageCache : RefDictionary<String, UIImage> = RefDictionary()
    
    // 色を変えた画像のキャッシュ
    private static var colorImageCache : RefDictionary<String, UIImage> = RefDictionary()
    
    /**
     * Constructor
     */
    // Singletonオブジェクト
    private static var singleton : UResourceManager? = nil
    
    // Singletonオブジェクトを作成する
    public static func createInstance() -> UResourceManager {
        if singleton == nil {
            singleton = UResourceManager()
        }
        return singleton!
    }
    public static func getInstance() -> UResourceManager {
        return singleton!
    }
    
    private init() {
    }
    
//    public func setView(View view) {
//        singleton.mView = view;
//    }
    
    /**
     * Methods
     */
    public static func clear() {
        imageCache.clear()
        colorImageCache.clear()
    }
    
    /**
     * stringsのIDで文字列を取得する
     * @param strId
     */
    public static func getStringByName(_ name : String) -> String
    {
        // 言語設定を英語にしていても日本語の表示にしたいので、ローカライズファイルを使用しない
        return UResourceManager.stringTable[ name ] ?? ""
        
        // Localizable ファイルを使用する場合
//        return NSLocalizedString(name, comment: name)
    }   
    
    /**
     * Bitmapを取得
     * @param bmpId
     * @return Bitmapオブジェクト / もしBitmapがロードできなかったら null
     */
    public static func getImageByName(_ imageName: ImageName) -> UIImage?
    {
        let name : String = imageName.path()
        
        // キャッシュがあるならそちらを取得
        var image : UIImage? = imageCache[name]
        if image != nil {
            ULog.printMsg(TAG, "cache hit!! name:" + name)
            return image
        }
        
        // 未ロードならロードしてからオブジェクトを返す
        image = UIImage(named: name)
        if image != nil {
            imageCache[name] = image
            return image
        }
        return nil
    }
    
    public static func getImageWithColor(imageName : ImageName, color : UIColor?) -> UIImage?
    {
        let name : String = imageName.rawValue
        // キャッシュがあるならそちらを取得
        let key : String = name + color!.description

        var image : UIImage? = colorImageCache[key]
        if image != nil {
            // キャッシュを返す
            ULog.printMsg(TAG, "cache hit!! bmpId:" + name + " color:" + UColor.toString(color: color!))
            return image
        }
        
        // キャッシュがなかったのでImageを生成
        image = getImageByName(imageName)
        if color != nil {
            image = UUtil.convImageColor(image: image!, newColor: color!)
        }
        // キャッシュに追加
        colorImageCache[key] = image
        
        return image
    }
    
    
    
    // ローカライズしない場合の文字列データ（辞書型)
    static var stringTable: [String: String] = [
        "app_name" : "カラフル単語帳",
        "hello_blank_fragment" : "Hello blank fragment",
        "error" : "エラー",
        "return1" : "戻る",
        "action" : "アクション",
        "close" : "閉じる",
        "clear" : "クリア",
        "confirm" : "確認",
        "date_format" : "yyyy/MM/dd",
        "date_format2" : "yyyy年MM月dd日",
        "datetime_format" : "yyyy/MM/dd HH:mm",
        "datetime_format2" : "yyyy年MM月dd日 HH:mm",
        "time_area_1" : "今日(〜２４時間)",
        "time_area_2" : "昨日(〜４８時間)",
        "time_area_3" : "今週(〜１週間)",
        "time_area_4" : "今月(〜１ヶ月)",
        "time_area_5" : "１ヶ月以上前",
        "app_title" : "カラフル単語帳",
        "word_a" : "英語",
        "word_b" : "日本語",
        "hint_ab" : "ヒント 英 > 日",
        "hint_ba" : "ヒント 日 > 英",
        "comment" : "コメント",
        "book_name" : "単語帳の名前",
        "book_color" : "単語帳の色",
        "card_color" : "カードの色",
        "book_name2" : "単語帳名",
        "where_card" : "場所",
        "in_box" : "の中",
        "word_a_top" : "英",
        "word_b_top" : "日",
        "name" : "名前",
        "card" : "カード",
        "book" : "単語帳",
        "card_count" : "カード数",
        "book_count" : "単語帳数",
        "study_history" : "学習履歴",
        "all_count" : "ぜんぶ",
        "box_count_unit" : "冊",
        "card_count_unit" : "枚",
        
        // options
        "option" : "オプション",
        "study_mode_1" : "１つづつ",
        "study_mode_2" : "まとめて",
        "study_mode_3" : "４択",
        "study_mode_4" : "単語入力",
        "study_type_1" : "英語 ➡︎ 日本語",
        "study_type_2" : "日本語 ➡︎ 英語",
        "study_order_1" : "単語帳の並び順",
        "study_order_2" : "ランダム",
        "study_filter_1" : "すべて",
        "study_filter_2" : "覚えていないカード",
        
        "know" : "知ってる",
        "dont_know" : "知らない",
        "count_not_learned" : "未収得",
        "item_count" : "アイテム数",
        "title_edit" : "単語帳を作る",
        "title_study" : "学習する",
        "title_study2" : "学習する単語帳を選択してください",
        "title_studying" : "単語帳学習",
        "title_studying_slide" : "単語帳学習 スライド",
        "title_studying_select" : "単語帳学習 ４択",
        "title_studying_input_correct" : "単語帳学習 正解入力",
        "title_study_select" : "学習する",
        "title_preset_book" : "プリセット単語帳",
        "title_csv_book" : "CSV単語帳を選択",
        "title_search_card" : "カードを探す",
        "title_history" : "学習の記録",
        "title_settings" : "設定",
        "title_options" : "オプション",
        "title_help" : "ヘルプ",
        "search_card" : "カードを探す",
        "search_card_name" : "検索カード名",
        "title_backup" : "環境をバックアップ",
        "title_restore" : "環境を復元",
        "title_debug" : "Debug",
        "title_debug_db" : "Debug Database",
        
        // 単語帳編集
        "open" : "開く",
        "edit" : "編集",
        "delete" : "削除",
        "study" : "学習する",
        "clean_up" : "空にする",
        "copy" : "コピー",
        "trash" : "ゴミ箱",
        "home" : "ホーム",
        "favorite" : "お気に入り",
        "learned" : "覚えた",
        "return_to_home" : "元に戻す",
        "studied_date" : "学習日時",
        "last_studied_date" : "最終学習日時",
        "last" : "最終学習日時",
        "start" : "開始",
        "ok" : "OK",
        "cancel" : "キャンセル",
        "history_book" : "学習記録",
        "study_mode" : "出題モード",
        "study_type" : "出題方法",
        "study_type_exp" : "出題方法を設定します",
        "skip" : "スキップ",
        
        "study_order" : "出題順",
        "study_order_exp" : "カードの出題順番を設定します",
        "order_normal" : "通常",
        "order_random" : "ランダム",
        
        "study_filter" : "絞り込み",
        "study_filter_exp" : "出題するカードの絞り込み方法を設定します",
        "all" : "すべて",
        "not_learned" : "未収得",
        "finish" : "終了",
        "cards_remain" : "あと%d枚",
        "clear_history" : "履歴をクリアする",
        "confirm_exit" : "学習を終了しますか？",
        "confirm_copy_book" : "%@(単語帳)をコピーしますか？",
        "confirm_moveto_trash" : "ゴミ箱に捨てますか？",
        "confirm_cleanup_trash" : "ゴミ箱を空にしますか？",
        "confirm_clear_history" : "学習記録をクリアしますか？",
        "study_list_is_empty1" : "学習履歴がありません",
        "confirm_export_csv" : "単語帳をcsvファイルに出力しますか？\n出力したファイルから単語帳を復元できます。",
        "no_study_history" : "学習履歴がありません",
        
        "retry1" : "すべて\nリトライ",
        "retry2" : "NGのみ\nリトライ",
        "title_result" : "学習結果",
        "title_result2" : "%@の学習結果",
        
        "menu" : "メニュー",
        "backup" : "バックアップ",
        "backup_auto" : "自動バックアップ",
        "backup_and_restore" : "バックアップと復元",
        "location" : "場所",
        "backup_complete" : "バックアップが完了しました",
        "backup_failed" : "バックアップに失敗しました",
        "confirm_overwrite" : "バックアップが存在します。\n上書きしてもよろしいですか？",
        "filename" : "ファイル名",
        "backup_path_title1" : "手動バックアップ",
        "backup_path_title2" : "自動バックアップ",
        "datetime" : "日時",
        "restore" : "復元",
        "restore_from_file" : "指定ファイルから復元",
        "confirm_backup" : "バックアップしますか？\nバックアップを行うと、以前の\n状態に戻せるようになります。",
        "succeed_restore" : "復元に成功しました",
        "failed_restore" : "復元に失敗しました",
        "failed_backup" : "バックアップに失敗しました",
        "finish_backup" : "バックアップが完了しました",
        "failed_export" : "CSVファイルへの出力に失敗しました",
        "failed_import" : "CSVファイルの読み込みに失敗しました",
        "finish_export" : "への書き込みが完了しました",
        "backup_not_found" : "バックアップファイルが見つかりませんでした。",
        "confirm_restore" : "バックアップから復元しますか？\n復元を行うと現在の単語帳は\n消去されます。",
        "confirm_restore2" : "本当にバックアップから\n復元しますか？",
        "confirm_cleanup" : "バックアップを空にしてもよろしいですか？",
        "no_backup" : "バックアップはありません",
        "finish_restore" : "復元が完了しました",
        "confirm_add_book" : "%@を追加しますか？",
        "confirm_add_book2" : "%@を追加しました",
        "auto_backup" : "起動時に自動でバックアップする",
        
        "license" : "ライセンス",
        "contact_us" : "お問い合わせ",
        "contact_message" : "ご要望、不具合の報告等は\nこちらからお願いします\n",
        "send_mail" : "メールを送る",
        
        "preset_title2" : "Addボタン(＋)をタップして\nアプリ内蔵の単語帳を追加します",
        "csv_title2" : "指定のフォルダ(/sdcard/Documents/)\nにあるCSVファイルから単語帳を追加します。",
        
        // メニュー menu
        "add_item" : "追加",
        "add_card" : "単語カード",
        "add_book" : "単語帳",
        "add_dummy_card" : "ダミー単語カード",
        "add_dummy_book" : "ダミー単語帳",
        "add_preset" : "プリセット単語帳",
        "add_csv" : "CSVから追加",
        "export" : "csv出力",
        "sort" : "ソート",
        "sort_word_asc" : "英語(A → Z)",
        "sort_word_desc" : "英語(Z → A)",
        "sort_time_asc" : "作成日(古い → 新しい)",
        "sort_time_desc" : "作成日(新しい → 古い)",
        "sort_none" : "ソート(元の並び)",
        "sort_word_asc_2" : "ソート(A → Z)",
        "sort_word_desc_2" : "ソート(Z → A)",
        "sort_time_asc_2" : "ソート 作成日時(古い → 新しい)",
        "sort_time_desc_2" : "ソート 作成日時(新しい → 古い)",
        "sort_studied_time_asc" : "ソート 学習日時(古い → 新し い)",
        "sort_studied_time_desc" : "ソート 学習日時(新しい → 古い)",
        "disp_list" : "項目表示方法",
        "list_type1" : "リスト",
        "list_type_grid" : "グリッド",
        "empty" : "空",
        "debug" : "デバッグ",
        "debug1" : "デバッグ1",
        "debug2" : "デバッグ2",
        "debug3" : "デバッグ3",
        "debug4" : "デバッグ4",
        "debug5" : "デバッグ5",
        "debug6" : "デバッグ6",
        "help" : "ヘルプ",
        "disp_menu_name" : "メニュー名を表示",
        "disp_menu_help" : "メニューの説明を表示",
        "edit_page_word_type" : "カードの名前",
        "disp_card_name_wordA" : "カード名の表示(英語)",
        "disp_card_name_wordB" : "カード名の表示(日本語)",
        "select_csv_file" : "CSVファイルを選択",
        
        // error message
        "not_exit_study_card" : "学習できるカードがありません",
        
        // menu item help
        "help_add_item" : "カードや",
        
        // mail to
        "contact_mail_title" : "アプリに関するお問い合わせ【カラフル単語帳】",
        "contact_mail_body" : "アプリに対するご要望や不具合等の内容をお書きください\n\n\nアプリ名:カラフル単語帳\n",
        
        
        // help
        // title
        "help_title_basic" : "基本",
        "help_title_basic1" : "本アプリについて",
        "help_title_basic2" : "使用方法",
        
        "help_title_edit" : "単語帳の作成",
        "help_title_edit0" : "単語帳の作成について",
        "help_title_edit1" : "単語帳の作成",
        "help_title_edit2" : "カードの作成",
        "help_title_edit3" : "カード、単語帳の編集",
        "help_title_edit4" : "カードの移動",
        "help_title_edit5" : "カードをまとめて移動",
        "help_title_edit6" : "カード、単語帳の削除",
        "help_title_edit7" : "プリセット単語帳を追加",
        "help_title_edit8" : "csv単語帳を追加",
        
        "help_title_study" : "学習（単語を覚える）",
        "help_title_study1" : "学習の流れ",
        "help_title_study2" : "学習モード1（１つづつスライド）",
        "help_title_study3" : "学習モード2（まとめてスライド）",
        "help_title_study4" : "学習モード3（４択）",
        "help_title_study5" : "学習モード4（正解を入力）",
        
        "help_title_backup" : "バックアップ（保存と復元）",
        "help_title_backup1" : "バックアップについて",
        "help_title_backup2" : "環境をバックアップ",
        "help_title_backup3" : "バックアップから復元",
        "help_title_backup4" : "単語帳をバックアップ",
        
        // オプションページ
        "title_options2" : "アプリの各種オプションを設定します",
        "title_option_edit" : "単語帳編集",
        "option_color_book" : "単語帳のデフォルト色",
        "option_color_card" : "カードのデフォルト色",
        "default_book_color_message" : "新しく作成した単語帳の色です。お好みの色を選択してください。",
        "default_card_color_message" : "新しく作成したカードの色です。お好みの色を選択してください。",
        
        "option_card_title" : "単語カードの表示",
        "option_default_name_card" : "カードのデフォルト名",
        "option_default_name_book" : "単語帳のデフォルト名",
        "title_option_study" : "学習",
        "option_add_ng_card" : "NGカードを自動追加",
        "option_add_ng_card_msg" : "学習終了時にNGだったカードを自動でNG単語帳に追加するかどうか選んでください",
        "option_mode3_1" : "４択モードの不正解カード抽出範囲",
        "option_mode3_2" : "すべてのカード",
        "option_mode3_3" : "学習中の単語帳のカード",
        "option_mode4_1" : "正解入力学習モードの文字並び順",
        "option_mode4_2" : "正解入力学習モードの文字並び順を選んでください",
        "option_mode4_22" : "正解入力用の文字の並び順を選んでください",
        "option_mode4_3" : "アルファベット順",
        "option_mode4_4" : "ランダム",
        "default_name_book" : "単語帳のデフォルト名",
        "default_name_book2" : "新しく作成した単語帳の名前",
        "default_name_card2" : "新しく作成したカードの名前",
        "option_add_ng_card1" : "追加する",
        "option_add_ng_card2" : "追加しない",
        "card_name_title" : "カードアイコンに表示する名前を\n英語か日本語から選んでください"
    ]

}
