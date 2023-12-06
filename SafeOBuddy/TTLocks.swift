//
//  TTLock.swift
//  safeobuddyttlock
//
//  Created by Never Mind on 01/12/23.
//

import Foundation
import CommonCrypto
import TTLock

struct TTLocks
{
    
    func loginTTLock(compliton: @escaping (_ message: String)->Void)
    {
        
        let parameter = [String:Any]()
        
        let parm = "?username=ttlock_shutterlockdemo&client_secret=0ef1c49b70c02ae6314bde603d4e9b05&password=e10adc3949ba59abbe56e057f20f883e&client_id=439063e312444f1f85050a52efcecd2e"
        
        Networking().callingPostAPI(url: "\(Domain.ttlockURL)\(parm)", parameter: parameter) { resultValue, message in
            
            switch message
            {
                
            case "error":
                
                compliton("\(message ?? "")")
                
            default:
                
                let jsonData = resultValue?.data(using: .utf8)
                let dictionary = try? JSONSerialization.jsonObject(with: jsonData!, options: .mutableLeaves)
                
                if let dataDict = dictionary as? [String : Any] {
                    
                    let token = dataDict["access_token"] as? String ?? ""
                    let uid = dataDict["uid"] as? Int ?? 0
                    
                    UserDefaults.standard.setValue(token, forKey: "TTLockToken")
                    UserDefaults.standard.setValue("\(uid)", forKey: "TTLockUid")
                    
                    compliton("success")
                }
            }
        }
    }
    
    
    
    func getLockDataAPI(lockID:String?, complition: @escaping (_ newMacID:String?, _ message: String)->Void)
    {
        
        let date = Int64(NSDate().timeIntervalSince1970 * 1000)
        
        let parameter = [String:Any]()
        
        let token = UserDefaults.standard.value(forKey: "TTLockToken") as? String ?? ""
        
        let parm = "&client_secret=0ef1c49b70c02ae6314bde603d4e9b05&date=\(date)&clientId=439063e312444f1f85050a52efcecd2e&accessToken\(token)&lockId\(lockID ?? "")"
           
        Networking().callingPostAPI(url: "\(Domain.ttlockSingleURL)\(parm)", parameter: parameter) { resultValue, message in
            
            switch message
            {
                
            case "error":
                
                complition("error","\(message ?? "")")
                
            default:
                
                let jsonData = resultValue?.data(using: .utf8)
                let dictionary = try? JSONSerialization.jsonObject(with: jsonData!, options: .mutableLeaves)
                
                if let singleData = dictionary as? [String: Any] {
                    
                    let lockList = singleData
                    
                    let lockId = lockList["lockId"] as? Int ?? 0
                    let lockData = lockList["lockData"] as? String ?? ""
                    let lockMac = lockList["lockMac"] as? String ?? ""
                    
                    self.updateLockDataAPI(lockData: lockData, MacId: lockMac, lockId: "\(lockId)") { message in
                        complition(nil,"Your LockData updated succesfully")
                    }
                }
            }
        }
    }
    
    
    func updateLockDataAPI(lockData:String, MacId:String, lockId:String, complition: @escaping (_ message: String)->Void) {
        
        var lockData = lockData.replaceTTLockData(string: "+", replacement: "%2B")
        lockData = lockData.replaceTTLockData(string: "==", replacement: "%%%%2CC")
        lockData = lockData.replaceTTLockData(string: "=", replacement: "######")
        
        let email = UserDefaults.standard.value(forKey: "user") as! String
        let token = UserDefaults.standard.value(forKey: "token") as! String
       
        let parms = "method=UpdateLockDatachild&lockData=\(lockData)&MacId=\(MacId)&LockID=\(lockId)&loginuserName=\(email)&contvals=\(email)&tkv=\(token)"
        
        let cipher:String = CryptoHelper.encrypt(input:parms)!;
        
        Networking().callingGetAPI(url: "\(Domain.encryptedBaseUrl)\(cipher)") { resultValue, message in

            switch message
            {

            case "error":
                
                complition("\(message ?? "")")
            default:
                
                complition("Your LockData updated succesfully")
            }
        }
    }
        
    func lockAction(action: TTControlAction, lockData:String?, complition: @escaping (_ message: String)->Void) {
        
        TTLock.controlLock(with: action, lockData: lockData, success: { lockTime, electricQuantity, uniqueId in
            
            complition("Devie is unlocked successfully.")
            
        }, failure: { errorCode, errorMsg in
            
            if errorMsg == "Bluetooth is off"
            {
                complition("Bluetooth is off.")
                
            } else if errorMsg == "Connecte bluetooth  timeout"
            {
                complition("Connect bluetooth timeout. Please trying again.")
                
            } else
            {
                complition("Please update your lock data.")
            }
        })
    }
}
