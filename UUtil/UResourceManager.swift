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
        return NSLocalizedString(name, comment: name)
    }
    
    /**
     * Bitmapを取得
     * @param bmpId
     * @return Bitmapオブジェクト / もしBitmapがロードできなかったら null
     */
    public static func getImageByName(_ imageName: ImageName) -> UIImage?
    {
        let name : String = imageName.rawValue
        
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
}
