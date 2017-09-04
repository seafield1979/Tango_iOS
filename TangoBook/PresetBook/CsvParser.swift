//
//  CsvParser.swift
//  TangoBook
//
//  Csvファイルを解析してPresetBookに変換する
//
//  Created by Shusuke Unno on 2017/08/01.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import UIKit

/**
 * Created by shutaro on 2016/12/27.
 *
 * Csvを解析して単語帳やカードの情報を抜き出す
 *
 */

public class CsvParser {
    /**
     * Constants
     */
    public static let TAG = "CsvParser"


    /**
     * PresetBookを取得
     * csvファイルの１行目にBook名、コメントの順で格納されているのを取得する
     * @param context
     * @param csvId
     * @param onlyBook  Book情報のみ取得、Card情報は取得しない
     * @return
     */
    public static func getPresetBook(csvName : String, onlyBook : Bool) -> PresetBook?
    {
        let csvStr = UFileManager.getStringFromResourceFile(csvName)
        if csvStr != nil {
            let csvLines = splitCsv(csvStr!)
            var book : PresetBook? = nil
            var isFirst = true
            
            for line in csvLines {
                let words = splitCsvLine(line)

                if isFirst {
                    // 最初の行は単語帳データ
                    isFirst = false

                    if words.count >= 3 {
                        let color = UIColor.hexColor(words[2])
                        book = PresetBook( csvName : csvName, name : words[0], comment : words[1], color : color)
                    }
                    else if (words.count >= 2) {
                        book = PresetBook( csvName : csvName, name : words[0], comment : words[1], color : .black)
                    } else if (words.count >= 1) {
                        book = PresetBook(csvName : csvName, name : words[0], comment : "", color : .black)
                    }
                    if (onlyBook) {
                        break;
                    }
                }
                else {
                    var card : PresetCard

                    if (words.count >= 2) {
                        if (words.count >= 3) {
                            card = PresetCard(wordA : words[0], wordB : words[1], comment : words[2])
                        } else {
                            card = PresetCard(wordA : words[0], wordB : words[1], comment : nil)
                        }
                        book!.addCard(card)
                    }
                }
            }
            return book
        }
        return nil
    }

    
 
    /**
     * CSVファイルを１行ずつに分割する
     */
    static func splitCsv(_ str : String) -> [String] {
        // 改行で分割する
        let separated = str.components(separatedBy: "\n")
        
        return separated
    }

    /**
     * CSVファイルの１行をカンマで分割する
     * "~"で囲まれる文字の中のカンマは区切り文字として使用しない
     * @param str
     * @return
     */
    static func splitCsvLine(_ str : String) -> List<String> {
        let list : List<String> = List()
        var buf : String = ""
        var seekDQ = false      // ダブルクォートを見つけたフラグ
        let characters = str.characters.map { String($0) } // String -> [String]
        
        for ch in characters {       // １文字づつ処理する
            if seekDQ {
                if ch == "\"" {
                    seekDQ = false
                    list.append(decodeCsv(buf))
                    buf = ""
                }
                else {
                    buf.append(ch)
                }
            }
            else {
                // " を見つけたら次の"を見つけるまでカンマスキップモード
                if ch == "\"" {
                    seekDQ = true
                } else if (ch  == ",") {
                    if buf.characters.count > 0 {
                        list.append(decodeCsv(buf))
                        buf = ""
                    }
                } else {
                    buf.append(ch)
                }
            }
        }
        if buf.characters.count > 0 {
            // "\n" を改行に変換してからリストに追加する
            list.append( decodeCsv(buf))
        }
        
        return list
    }

    /**
     * CSV中のワードをデコードする
     * @param word
     * @return
     */
    private static func decodeCsv(_ word : String) -> String {
        // \nを改行に変換
        return word.replacingOccurrences(of: "\\n", with: "\n")
    }

    /**
     * カードのリストを取得する
     * @param csvName  csvファイル名
     * @return
     */
    // アプリのリソースにあるcsvファイルを読み込む
    static public func getPresetCardsFromResourceFile( csvName : String ) -> List<PresetCard>? {
        let text = UFileManager.getStringFromResourceFile(csvName)
        if text != nil {
            let cards = getPresetCards(text!)
            return cards
        }
        return nil
    }

    // ストレージのDocumentsフォルダにあるcsvファイルを読み込む
    static public func getPresetCardsFromStorageFile( csvName : String ) -> List<PresetCard>?
    {
        let text = UFileManager.getStringFromStorageFile(csvName)
        if text != nil {
            let cards = getPresetCards(text!)
            return cards
        }

        return nil
    }

    /**
     csvのテキストからPresetCardのリストを作成する
     - parameter str: csvファイルのテキスト
     - returns: PresetCardの単語カードリスト
     */
    static func getPresetCards(_ str : String) -> List<PresetCard> {
        // １行ずつに分解
        let lines = splitCsv(str)

        var isFirst = true
        var words : List<String>
        let cards : List<PresetCard> = List()

        for line in lines {
            if isFirst {
                // 最初の行は単語帳データ
                isFirst = false
            }
            else {
                words = splitCsvLine(line)
                if words.count >= 2 {
                    let wordA = (words.count >= 1) ? words[0] : ""
                    let wordB = (words.count >= 2) ? words[1] : ""
                    let comment = (words.count >= 3) ? words[2] : ""

                    let card = PresetCard(wordA: wordA, wordB: wordB, comment: comment)
                    cards.append(card)
                }
            }
        }
        return cards
    }
}
