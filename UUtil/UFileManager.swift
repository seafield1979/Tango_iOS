//
//  UFileManager.swift
//  TangoBook
//    ファイル書き込み、読み込み関連の処理を行うクラス
//  Created by Shusuke Unno on 2017/08/02.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import UIKit

public class UFileManager {
    
    /**
     アプリのリソースファイルからテキストを取得する
     - parameter fileName: リソースファイル名
     - returns: ファイルから読み込んだ文字列
     */
    static func getStringFromResourceFile(_ fileName : String) -> String! {
        // プロジェクトに登録されたファイルのURLを取得
        let url = Bundle.main.url(forResource: fileName, withExtension: nil)
        
        if url != nil {
            do {
                // テキストファイルを取得
                let text = try String.init(contentsOf: url!, encoding: .utf8)
                return text
            } catch {
                print("error")
            }
        }
        return nil
    }
    
    // ストレージのDocumentsフォルダからテキストを取得する
    static func getStringFromStorageFile(_ fileName : String) -> String? {
        // Documentsフォルダを読み込む
        if let dir = NSSearchPathForDirectoriesInDomains( FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true ).first as String?
        {
            let path_file_name = dir + "/" + fileName
            
            do {
                
                let text = try NSString( contentsOfFile: path_file_name, encoding: String.Encoding.utf8.rawValue )
                return String(text)
            } catch {
                //エラー処理
            }
        }
        return nil
    }

    
    // Documentsディレクトリ内のファイルを一覧表示
    static func getFileListInDocuments() -> [String] {
        
        var fileList = [String]()
        
        let dir = NSSearchPathForDirectoriesInDomains( FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true ).first as String?
        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: dir!)
            
            for path in files {
                var isDir : ObjCBool = false
                FileManager.default.fileExists(atPath: dir! + "/" + path, isDirectory: &isDir)
                
                if isDir.boolValue {
                    // フォルダ
                } else {
                    // ファイル
                    fileList.append(path)
                }
                let result = FileManager.default.fileExists(atPath: dir! + "/" + path)
                print(result)
            }
            
        }
        catch {
            print("error in getFileListInDocuments")
        }
        return fileList
    }
    
    
    // Documents以下のファイルにテキストを書き込む
    static func writeToFile(file filePath : String, writeText : String) {
        let file_name = filePath
        let text = writeText //保存する内容
        
        // Documentsフォルダを読み込む
        if let dir = NSSearchPathForDirectoriesInDomains( FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true ).first as String?
        {
            print(dir + "/" + filePath)
            let filePath = dir + "/" + file_name
            
            do {
                // ファイルに書き込む
                try text.write( toFile: filePath, atomically: false, encoding: String.Encoding.utf8 )
                
            } catch {
                //エラー処理
            }
        }
    }
}
