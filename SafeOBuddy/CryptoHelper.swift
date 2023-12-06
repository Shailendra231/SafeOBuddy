//
//  CryptoHelper.swift
//  safeobuddyttlock
//
//  Created by Never Mind on 30/11/23.
//

import Foundation

class CryptoHelper {
    
    private static let key = "safe@GCKS@#^wji@";
    
    public static func encrypt(input:String)->String? {
        do{
            let encrypted: Array<UInt8> = try AES(key: key, iv: key ,padding: .pkcs7).encrypt(Array(input.utf8))
            return encrypted.toBase64()
        }catch{
            
        }
        return nil
    }
    
    public static func decrypt(input:String)->String?{
        do{
            let d = Data(base64Encoded: input)
            let decrypted = try AES(key: key, iv: key, padding: .pkcs5).decrypt(
                d!.bytes)
            return String(data: Data(decrypted), encoding: .utf8)
        }catch{
            
        }
        return nil
    }
}


