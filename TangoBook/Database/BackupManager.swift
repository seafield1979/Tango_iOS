//
//  BackupManager.swift
//  TangoBook
//
// * ファイルにバックアップを行うクラス
// * ファイルにバックアップと、バックアップファイルからの復元を行う
// *
// * バックアップファイルのフォーマット
// * [ヘッダー]
// *
// * [本体]
//
//  Created by Shusuke Unno on 2017/09/01.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import UIKit
import RealmSwift

/**
 * Created by shutaro on 2017/06/23.
 *
 * XmlManagerのスレッド処理完了時のコールバックメソッド
 */

public protocol XmlBackupCallbacks : class {
    
    /**
     * バックアップ処理完了
     * @return
     */
    func finishBackup( backupInfo : BackupFileInfo)
    
    /**
     * 復元処理完了
     */
}

/**
 * Created by shutaro on 2017/06/27.
 *
 * バイナリ形式のバックアップファイルから読み込んだデータを格納するクラス
 * あくまで読み込み時にしか使用しない
 */

public struct BackupLoadData {
    // backup file version
    public var version : Int = 0
    
    // Number of card
    public var cardNum : Int = 0
    
    // Number of book
    public var bookNum : Int = 0
    
    // last update date
    public var updateDate : Date?
    
    /**
     * Database
     */
    // card
    public var cards : [Card] = []
    
    // book
    public var books : [Book] = []
    
    // card&book location
    public var itemPoses : [Pos] = []
    
    // 学習単語帳履歴(1学習1履歴)
    public var bookHistories : [BHistory] = []
    
    // 学習カード(1回学習するたびに1つ)
    public var studiedCards : [StudiedC] = []
    
}


public class BackupManager {
    // MARK: Enums
    // スレッド処理モード
    public enum RunMode {
        case None
        case BackupAuto
        case BackupManual
    }
    
    public static var mRealm : Realm?
    
    // アプリ起動時にRealmオブジェクトを生成したタイミングで呼び出す
    public static func setRealm(_ realm : Realm) {
        mRealm = realm
    }

    // アプリからアクセスできるディレクトリ
    enum DirectoryType : String{
        case Document = "/Documents"        // ユーザーデータ用
        case Library = "/Library"           // ユーザーデータ以外
        case CachesDirectory = "/Library/Caches"   // キャッシュ
        
        // ディレクトリのパスを取得する
        public func toString() -> String {
            var searchDir : FileManager.SearchPathDirectory? = nil
            
            switch self {
            case .Document:
                searchDir = FileManager.SearchPathDirectory.documentDirectory
                break
            case .Library:
                searchDir = FileManager.SearchPathDirectory.documentDirectory
                break
            case .CachesDirectory:
                searchDir = FileManager.SearchPathDirectory.documentDirectory
                break
            }
            
            if searchDir == nil {
                return ""
            }
            return (NSSearchPathForDirectoriesInDomains( searchDir!, FileManager.SearchPathDomainMask.allDomainsMask, true ).first as String?)!
        }
    }
    
    // バックアップファイル読み込み時のエラー
    enum BackupError : Error {
        case None
        case FileIsNotTangoApp      // バックアップファイルが単語帳アプリのものではない
    }

    // MARK: Constants
    public static let TAG = "BackupManager"

    // 手動バックアップファイル名
    public static let ManualBackupFile = "tango_m%02d.bin"

    private static let BACKUP_FILE_TAG : UInt = 0x01212123      // binファイルが単語帳アプリのものであるという判定用

    private let WRITE_BUF_SIZE : Int = 1000 // 書き込みバッファー

    // MARK: Properties
    private weak var mCallbacks : XmlBackupCallbacks?  // バックアップ完了のコールバック
    private var mSaveSlot : Int = 0                  // マニュアルバックアップのスロット番号

    // バックアップ情報
    private var mBackupCardNum : Int = 0
    private var mBackupBookNum : Int = 0

    // 書き込み情報を一時的に溜め込むバッファー
    private var mBuf : ByteBuffer = ByteBuffer()

    /**
     * Get/Set
     */
    public func getBackpuCardNum() -> Int {
        return mBackupCardNum
    }
    public func getBackupBookNum() -> Int {
        return mBackupBookNum
    }

    /**
     * Constructor
     */
    // Singletonオブジェクト
    private static var singleton : BackupManager?

    // Singletonオブジェクトを作成する
    public static func getInstance() -> BackupManager {
        if singleton == nil {
            singleton = BackupManager()
        }
        return singleton!
    }

    // MARK: Initializer
    private init() {
        
    }

    // MARK: Methods
    /**
     * オートバックアップをスレッドで実行
     * @param callbacks
     * @param context
     */
//    public static func startBackupAuto( callbacks : XmlBackupCallbacks) {
//        XmlManager runable = new XmlManager(context)
//        runable.mCallbacks = callbacks;
//        runable.mRunMode = XmlManager.RunMode.BackupAuto;
//        Thread thread = new Thread(runable);
//        thread.start();
//    }

    public static func getManualBackupURL(slot : Int) -> URL{
        let dir = DirectoryType.Document.toString()
        let filePath = dir + "/" + String(format: ManualBackupFile, slot)
        return URL(fileURLWithPath: filePath)
    }

    public static func getAutoBackupURL() -> URL {
        let dir = DirectoryType.Document.toString()
        let filePath = dir + "/" + String(format: ManualBackupFile, BackupFileDao.AUTO_BACKUP_ID)
        return URL(fileURLWithPath: filePath)
    }

    /**
     * バックアップファイルの情報を取得
     * @return XMLファイル情報（ファイルパス、カード数、単語帳数、更新日）
     *          null: 失敗
     */
    public static func getManualBackupInfo(slot : Int) -> String{
        let url : URL = getManualBackupURL(slot: slot)

        return getBackupInfo(url: url)
    }
    public static func getAutoBackupInfo() -> String {
        let url : URL = getAutoBackupURL()

        return getBackupInfo(url: url)
    }

    /**
     * バックアップの情報を取得する
     * @param file バックアップファイルから情報を取得
     * @return バックアップファイルの情報 (null:エラー)
     */
    public static func getBackupInfo(url : URL) -> String {
        var backupInfo : BackupFileInfo? = nil
        let readSize : Int = 4 + 4 + 4 + 4 + 7

        do {
            let binaryData = try Data(contentsOf: url, options: [])

            // 先頭から指定サイズのデータを読み込み
            let topData : Data
            if binaryData.count < readSize {
                topData = binaryData
            } else {
                topData = binaryData.subdata(in: 0..<readSize)
            }
        
            let byteBuf = ByteBuffer(data: topData)
        
            // header
            let tagId : UInt = byteBuf.getUInt()
            if tagId != BACKUP_FILE_TAG {
                throw BackupError.FileIsNotTangoApp
            }
            
            _ = byteBuf.getUInt()     // シーク用に必要 (version)
            let cardNum = byteBuf.getInt()
            let bookNum = byteBuf.getInt()
            let createdDate : Date = byteBuf.getDate()
            
            backupInfo = BackupFileInfo(
                backupDate: createdDate, bookNum: bookNum, cardNum: cardNum)

        } catch BackupError.FileIsNotTangoApp {
            
        } catch is Error {
            
        }
        return  getBackupInfoString( backupInfo : backupInfo )
    }

    /**
     * バックアップの情報を取得する
     * BackupFileInfoからバックアップ情報を取得
     * @param backupInfo
     * @return
     */
    public static func getBackupInfoString( backupInfo : BackupFileInfo?) -> String {
        if backupInfo == nil {
            return ""
        }
        let str =  String(format: "%@\n%@: %d\n%@: %d" ,
                          UUtil.convDateFormat( date: backupInfo!.getBackupDate(),
                                                mode: ConvDateMode.DateTime)!,
                          UResourceManager.getStringByName("card_count"),
                          backupInfo!.getCardNum(),
                          UResourceManager.getStringByName("book_count"),
                          backupInfo!.getBookNum())
        
        return str
    }

    /**
     * バックアップの情報を取得する
     * @param slot バックアップファイルのスロット番号
     * @return
     */
    public static func getBackupInfo(slot : Int) -> String {

        var backupFile : BackupFile? = nil
        backupFile = BackupFileDao.selectById(id: slot)
        
        let str = String(format: "%s\n%s: %d\n%s: %d\n" ,
               UUtil.convDateFormat( date: backupFile!.getDateTime(),
                                     mode: ConvDateMode.DateTime)!,
               UResourceManager.getStringByName("card_count"),
               backupFile!.getCardNum(),
               UResourceManager.getStringByName("book_count"),
               backupFile!.getBookNum())

        return str
    }

    /**
     * マニュアルファイルに保存する
     * @param slot  backupのスロット
     * @return
     */
//    public func saveManualBackup( url : url ) -> BackupFileInfo? {
//        return saveToFile(url : url)
//    }
    
    public func saveAutoBackup() -> BackupFileInfo? {
        let url : URL = BackupManager.getAutoBackupURL()

        let backup : BackupFileInfo? = saveToFile(url: url)

        // データベース更新(BackupFile)
        _ = BackupFileDao.updateOne( id: BackupFileDao.AUTO_BACKUP_ID,
                                 bookNum: backup!.getBookNum(),
                                 cardNum: backup!.getCardNum())

        return backup
    }

    /**
     * 指定したファイルにデータベースの情報を保存する
     * @param file 保存ファイル
     * @return バックアップ情報のBean
     */
    public func saveToFile( url : URL ) -> BackupFileInfo? {
        var backupData = BackupData()

        // データベースから保存情報をかき集める
        // TangoCard
        backupData.cards = TangoCardDao.selectAll()

        ULog.printMsg(BackupManager.TAG, "point1")

        // TangoBook
        backupData.books = TangoBookDao.selectAll()

        ULog.printMsg(BackupManager.TAG, "point2")

        // ItemPos
        backupData.itemPoses = TangoItemPosDao.selectAll()

        ULog.printMsg(BackupManager.TAG, "point3")

        // TangoBookHistory
        backupData.bookHistories = TangoBookHistoryDao.selectAll(reverse: false)

        ULog.printMsg(BackupManager.TAG, "point4")

        // TangoStudiedCard
        backupData.studiedCards = TangoStudiedCardDao.selectAll()

        ULog.printMsg(BackupManager.TAG, "point6")

        // カード数
        backupData.cardNum = backupData.cards!.count
        BackupManager.singleton!.mBackupCardNum = backupData.cardNum

        // 単語帳数
        backupData.bookNum = backupData.books!.count
        BackupManager.singleton!.mBackupBookNum = backupData.bookNum

        // 最終更新日時
        backupData.updateDate = Date()

        // ファイルに書き込む
        var backupInfo : BackupFileInfo? = nil
        
//            path = UUtil.getPath(getInstance().mContext, FilePathType.ExternalDocument);
//            if (path.exists() == false) {
//                // フォルダがなかったら作成する
//                if (path.mkdir() == false) {
//                    throw new Exception("Couldn't create external document directory.");
//                }
//            }
        backupInfo = writeToFile(url: url, backupData: backupData)


        ULog.printMsg(BackupManager.TAG, "point7")
        return backupInfo
    }

    /**
     * バックアップファイルに書き込む
     * @param backupData
     * @return
     */
    private func writeToFile(url : URL, backupData : BackupData) -> BackupFileInfo? {
        // 書き込み用のファイルを開く
        var backupInfo : BackupFileInfo? = nil
        
        if let output = OutputStream(url: url, append: false) {
            output.open()
            mBuf.clear()

            // tag id
            mBuf.putUInt(BackupManager.BACKUP_FILE_TAG)

            // version
            mBuf.putInt(backupData.version)

            // Number of card
            mBuf.putInt(backupData.cardNum)

            // Number of book
            mBuf.putInt(backupData.bookNum)

            // last update date
            mBuf.putDate( backupData.updateDate )

            backupInfo = BackupFileInfo( backupDate: backupData.updateDate!,
                                         bookNum: backupData.bookNum, cardNum: backupData.cardNum)

            output.write(mBuf.array(), maxLength: mBuf.array().count)

            /**
             * Database
             */
            //---------------
            // card
            //---------------
            ULog.printMsg(BackupManager.TAG, "point61")
            mBuf.clear()
            
            // num
            mBuf.putInt(backupData.cardNum)
            
            output.write(mBuf.array(), maxLength: mBuf.array().count)
            mBuf.clear()
                
            // data
            let saveCard = SaveCard(buf: mBuf)
            for card in backupData.cards! {
                saveCard.writeData( output: output, card: card )
            }
                
            //---------------
            // book
            //---------------
            ULog.printMsg(BackupManager.TAG, "point62")
            mBuf.clear()
            let saveBook = SaveBook(buf: mBuf)
                
            // num
            mBuf.putInt(backupData.bookNum)
            output.write(mBuf.array(), maxLength: mBuf.array().count)
        
            // data
            for book in backupData.books! {
                saveBook.writeData( output: output, book: book)
            }

            //---------------
            // card&book position
            //---------------
            ULog.printMsg(BackupManager.TAG, "point63")
            mBuf.clear()
            
            // num
            mBuf.putInt( backupData.itemPoses!.count )
            output.write( mBuf.array(), maxLength: mBuf.array().count)
            
            // data
            let savePos = SaveItemPos(buf: mBuf)
            for pos in backupData.itemPoses! {
                savePos.writeData(output: output, itemPos: pos)
            }

            //---------------
            // 学習した単語帳履歴(1学習1履歴)
            //---------------
            ULog.printMsg(BackupManager.TAG, "point64")
            mBuf.clear()
            // num
            mBuf.putInt(backupData.bookHistories!.count)
            output.write(mBuf.array(), maxLength: mBuf.array().count)
            
            // data
            let saveBookHistory = SaveBookHistory(buf: mBuf)
            for history in backupData.bookHistories! {
                saveBookHistory.writeData(output: output, history: history)
            }

            //---------------
            // 学習カード(1枚学習するたびに1つ)
            //---------------
            ULog.printMsg(BackupManager.TAG, "point65")
            mBuf.clear()
            // num
            mBuf.putInt( backupData.studiedCards!.count )
            output.write(mBuf.array(), maxLength: mBuf.array().count)
            
            // data
            let saveStudiedCard = SaveStudiedCard(buf: mBuf)
            for card in backupData.studiedCards! {
                saveStudiedCard.writeData( output: output, card: card)
            }

            output.close()
        }
        return backupInfo
    }

    /**
     * バックアップファイルから情報を読み込む
     * @return file バックアプファイル (null:エラー)
     */
    private func readFromFile(url: URL) -> BackupLoadData? {
        var backup = BackupLoadData()
        
        // ByteBufferにファイルのデータを全て読み込む
        var data : Data? = nil
        do {
            data = try Data(contentsOf: url, options: [])
        } catch {
            print("error file read")
            return nil
        }
        mBuf = ByteBuffer(data: data!)
        
        // header
        let tagId : UInt = mBuf.getUInt()
        if tagId != BackupManager.BACKUP_FILE_TAG {
            print("error FileIsNotTangoApp")
            return nil
        }

        backup.version = mBuf.getInt()
        backup.cardNum = mBuf.getInt()
        backup.bookNum = mBuf.getInt()
        backup.updateDate = mBuf.getDate()

        // card
        let cardNum = mBuf.getInt()
        
        let saveCard = SaveCard(buf: mBuf)
        for _ in 0 ..< cardNum {
            let card = saveCard.readData()
            if let _card = card {
                backup.cards.append( _card )
            }
        }
        ULog.printMsg(BackupManager.TAG, "cardNum: \(cardNum)")

        // book
        let bookNum = mBuf.getInt()
        let saveBook = SaveBook(buf: mBuf)
        for _ in 0 ..< bookNum {
            let book = saveBook.readData()
            if let _book = book {
                backup.books.append( _book )
            }
        }
        ULog.printMsg(BackupManager.TAG, "bookNum: \(bookNum)")

        // position
        let posNum = mBuf.getInt()
        let saveItemPos = SaveItemPos(buf: mBuf)
        for _ in 0 ..< posNum {
            let pos = saveItemPos.readData()
            if let _pos = pos {
                backup.itemPoses.append( _pos )
            }
        }
        ULog.printMsg(BackupManager.TAG, "posNum: \(posNum)")

        //　book history
        let bookHistoriesNum = mBuf.getInt()
        let saveBookHistory = SaveBookHistory(buf: mBuf)
        for _ in 0 ..< bookHistoriesNum {
            let history = saveBookHistory.readData()
            if let _history = history {
                backup.bookHistories.append( _history )
            }
        }
        ULog.printMsg(BackupManager.TAG, "bookHistoriesNum: \(bookHistoriesNum)")

        // studied card
        let studiedCardNum = mBuf.getInt()
        let saveStudiedCard = SaveStudiedCard(buf: mBuf)
        for _ in 0 ..< studiedCardNum {
            let card = saveStudiedCard.readData()
            if let _card = card {
                backup.studiedCards.append( _card )
            }
        }
        ULog.printMsg(BackupManager.TAG, "studiedCardNum: \(studiedCardNum)")
        
        return backup;
    }

    /**
     * 指定したファイルから情報を取得し、システム(Realmデータベース)に保存する
     * @param file  復元元のバックアップファイル
     * @return
     */
    public func loadBackup(url : URL) -> Bool {

        var backupData : BackupLoadData? = nil
        backupData = readFromFile(url: url)
        if backupData == nil {
            return false
        }
        
        // データベースを削除
        _ = TangoCardDao.deleteAll()
        _ = TangoBookDao.deleteAll()
        _ = TangoItemPosDao.deleteAll()
        _ = TangoBookHistoryDao.deleteAll()
        _ = TangoStudiedCardDao.deleteAll()

        // データベースにxmlファイルから読み込んだデータを追加
        // トランザクションを毎回張ると遅いため１回だけ張る
        try! BackupManager.mRealm!.write() {
            TangoCardDao.addBackupCards( cards: backupData!.cards, transaction: false )
            TangoBookDao.addBackupBooks( books: backupData!.books, transaction: false)
            TangoItemPosDao.addBackupPos( poses: backupData!.itemPoses, transaction: false)
            TangoBookHistoryDao.addBackupBook( histories: backupData!.bookHistories, transaction: false)
            TangoStudiedCardDao.addBackupCard( studiedCards: backupData!.studiedCards, transaction: false)
        }
        return true
    }
//
//    /**
//     * xmlファイルを削除する
//     * @param slot
//     */
//    public static boolean removeManualXml(int slot) {
//        File file = getManualBackupFile(slot);
//        if (file == null) {return false;}
//
//        return removeXml(file);
//    }
//    public static boolean removeAutoXml() {
//        File file = getAutoBackupFile();
//        if (file == null) {return false;}
//
//        return removeXml(file);
//    }
//
//    public static boolean removeXml(File file) {
//        return file.delete();
//    }
//
//
//    /**
//     * Static Methods
//     */
//    /**
//     * Date型のデータをバイナリ形式で書き込む
//     * @param buf      書き込み先のバッファー
//     * @param date     書き込む日付情報
//     */
//    public static void writeDate(ByteBuffer buf, Date date) throws IOException {
//        if (date == null) {
//            // 全て0で書き込み
//            buf.put(new byte[7], 0, 7);
//        } else {
//            Calendar calendar = Calendar.getInstance();
//            calendar.setTime(date);
//            buf.putShort((short)calendar.get(Calendar.YEAR));
//            buf.put((byte)calendar.get(Calendar.MONTH));
//            buf.put((byte)calendar.get(Calendar.DAY_OF_MONTH));
//            buf.put((byte)calendar.get(Calendar.HOUR));
//            buf.put((byte)calendar.get(Calendar.MINUTE));
//            buf.put((byte)calendar.get(Calendar.SECOND));
//        }
//    }
//
//    /**
//     * バイナリ形式のDateデータを読み込む
//     */
//    public static Date readDate(ByteBuffer buf) throws IOException {
//        Calendar calendar = Calendar.getInstance();
//        calendar.set(Calendar.YEAR, buf.getShort());
//        calendar.set(Calendar.MONTH, buf.get());
//        calendar.set(Calendar.DAY_OF_MONTH, buf.get());
//        calendar.set(Calendar.HOUR, buf.get());
//        calendar.set(Calendar.MINUTE, buf.get());
//        calendar.set(Calendar.SECOND, buf.get());
//
//        return calendar.getTime();
//    }
//
//    /**
//     * 文字列を書き込む
//     * @param str
//     * @throws IOException
//     */
//    public static void writeString(ByteBuffer buf, String str) throws IOException {
//        if (str == null || str.length() == 0) {
//            buf.putInt(0);
//        } else {
//            byte[] bytes = str.getBytes();
//            buf.putInt(bytes.length);
//            buf.put(bytes);
//        }
//    }
//
//    /**
//     * 文字列を読み込む
//     * @return 読み込んだ文字列
//     */
//    public String readString(ByteBuffer buf) throws IOException {
//        int strLen = buf.getInt();
//        byte[] bytes = new byte[strLen];
//        buf.get(bytes, 0, strLen);
//        return new String(bytes);
//    }
}

