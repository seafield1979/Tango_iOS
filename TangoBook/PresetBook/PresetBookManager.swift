//
//  PresetBookManager.swift
//  TangoBook
//     プリセット単語帳を保持するクラス
//  Created by Shusuke Unno on 2017/07/31.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import UIKit


/**
 * Created by shutaro on 2016/12/18.
 *
 * プリセットの単語帳を管理する
 */
public class PresetBookManager {
     /**
      * Constants
      */
     public static let TAG = "PresetBookManager"

    private static let presetCsvs : [String] = [
         "week.csv",
         "month.csv",
         "animal.csv",
         "fruit.csv",
         "vegetable.csv",
         "questions.csv",
         "greetings.csv",
         "fish.csv",
         "flower.csv",
         "insect.csv"
     ]

    /**
     * Member variables
     */
    private var mBooks : List<PresetBook> = List()
    
    /**
     * Get/Set
     */
    public func getBooks() -> List<PresetBook>{
        return mBooks
    }

    /**
     * Constructor
     */
    // Singletonオブジェクト
    private static var singleton : PresetBookManager? = nil

    // Singletonオブジェクトを作成する
    public static func createInstance() -> PresetBookManager {
        singleton = PresetBookManager()
        return singleton!
    }
     public static func getInstance() -> PresetBookManager {
        if singleton == nil {
            singleton = createInstance()
        }
        return singleton!
    }

     private init() {
     }


     /**
      * Methods
      */
     /**
      * 一覧に表示するためのプリセット単語帳リストを作成する
      */
     public func makeBookList() {
         // csvからプリセット単語帳とカード情報を読み込んで mBooksに追加する
         for csvName in PresetBookManager.presetCsvs {
            let book : PresetBook = CsvParser.getPresetBook(csvName: csvName, onlyBook: true)!
             mBooks.append(book)
         }
         for book in mBooks {
             book!.log()
         }
     }

     /**
      * Methods
      */
     /**
      * 一覧に表示するためのcsv単語帳リストを作成する
      */
    public func getCsvBookList() -> List<PresetBook>? {
        // 指定のフォルダにあるcsvファイルを読み込み
        
        let books : List<PresetBook> = List()
        let files = UFileManager.getFileListInDocuments()

        if files.count <= 0 {
            return nil
        }

        for file in files {
            if file.hasSuffix(".csv") {
                let book = CsvParser.getPresetBook( csvName: file, onlyBook: true)
                if book != nil {
                    books.append(book!)
                }
            }
        }

        // デバッグ
        for book in books {
            book!.log()
        }
        return books
    }




     /**
      * プリセット単語帳のリソースIDで単語帳を追加
      * @param csvId  R.rawにあるリソース番号
      * @return
      */
    public func addBookToDB(csvName : String) -> Bool {
        let book : PresetBook? = CsvParser.getPresetBook( csvName: csvName, onlyBook: true)
        if book == nil {
            return false
        }
        _ = addBookToDB( presetBook: book!)
        return true
    }

     /**
      * データベースにプリセット単語帳のデータを登録
      * @return 作成したBook
      */
    public func addBookToDB( presetBook : PresetBook) -> TangoBook {
        // まずは単語帳を作成
        let book = TangoBook.createBook()
        book.setName(name: presetBook.mName)
        book.setComment(comment: presetBook.mComment)
        book.setColor(color: Int(presetBook.mColor!.intColor()))
        TangoBookDao.addOne(book: book, addPos: -1)

        // 単語帳以下にカードを追加
        TangoCardDao.addPresetCards(parentId: book.getId(), cards: presetBook.getCards())

        return book
    }

    /**
     * アプリ起動時にデフォルトで用意される単語帳を追加する
     */
    public func addDefaultBooks() {
        _ = addBookToDB(csvName: "animal.csv")
        _ = addBookToDB(csvName: "fruit.csv")
        _ = addBookToDB(csvName: "week.csv")
        _ = addBookToDB(csvName: "month.csv")
        _ = addBookToDB(csvName: "fish.csv")
        _ = addBookToDB(csvName: "greetings.csv")
        _ = addBookToDB(csvName: "vegetable.csv")
    }

     /**
      * Csvファイルにエクスポートする
      * @return エクスポートファイルのパス
      */
    public func exportToCsvFile( book : TangoBook, cards : [TangoCard]) -> String?
    {
        let path : String? = NSSearchPathForDirectoriesInDomains( FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true ).first as String?
        
        if path == nil {
            return nil
        }
        
        let filePath = path! + "/" + book.getName()! + ".csv"
        
        var writeText = ""
        
        // 1行目はbooke名
        var bookText : String = encodeCsv(book.getName()) ?? ""
        
         if book.getComment() == nil || book.getComment()!.characters.count == 0 {
             bookText.append(", ")
         } else {
             bookText.append("," + (encodeCsv(book.getComment()) ?? ""))
         }
         // 色情報
         bookText.append("," + UColor.toColorString(color: UInt32(book.getColor())))

        writeText.append(bookText + "\n")
        
        // 2行目以降はcardの英語、日本語
        for card in cards {
            if card.wordA != nil {
                writeText.append(encodeCsv(card.wordA!)!)
            }
            writeText.append(",")

            if card.wordB != nil {
                writeText.append(encodeCsv(card.wordB!)!)
            }
            writeText.append(",")

            if card.comment != nil {
                writeText.append(encodeCsv(card.comment!)!)
            }
            writeText.append("\n")
        }
        return filePath
    }

     /**
      * CSVの文字列をエスケープする
      * CSV文字列中にカンマ(,)があったら文字列を""で囲む
      * 改行を\nに変換する
      * @param word
      * @return
      */
    private func encodeCsv(_ word : String?) -> String? {
        if word == nil {
            return nil
        }
        let output = word!.replacingOccurrences(of: "\n", with: "\\n")

        if (output.contains(",")) {
            return "\"" + output + "\""
        }
        return output
    }
}

