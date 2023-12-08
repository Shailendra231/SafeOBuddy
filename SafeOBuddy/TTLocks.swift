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
        
        
        Networking().callingPostAPI(url: "\(Domain.ttlockURL)\(parm)", parameter: parameter) { respponse, message, statusCode  in
            
            switch message
            {
                
            case "error":
                
                compliton("\(message)")
                
            default:
                
                let jsonData = respponse.data(using: .utf8)
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
    
    
    
    func getLockDataAPI(lockID:String?, complition: @escaping (_ respponse: String, _ message: String, _ statusCode: String)->Void)
    {
        
        let date = Int64(NSDate().timeIntervalSince1970 * 1000)
        
        let parameter = [String:Any]()
        
        let token = UserDefaults.standard.value(forKey: "TTLockToken") as? String ?? ""
        
        let parm = "?client_secret=0ef1c49b70c02ae6314bde603d4e9b05&date=\(date)&clientId=439063e312444f1f85050a52efcecd2e&accessToken=\(token)&lockId=\(lockID ?? "")"
        
        Networking().callingPostAPI(url: "\(Domain.ttlockSingleURL)\(parm)", parameter: parameter) { respponse, message, statusCode in
            
            
            switch statusCode
            
            {
            case "404":
                
                complition("", "Invalid URL", "404")
                
            case "100":
                
                complition("", "Server error", "100")
                
            default:
                
                let jsonData = respponse.data(using: .utf8)
                let dictionary = try? JSONSerialization.jsonObject(with: jsonData!, options: .mutableLeaves)
                
                if let singleData = dictionary as? [String: Any] {
                    
                    let lockList = singleData
                    
                    if singleData["errmsg"] as? String ?? "" == "Permission Denied."
                    {
                        complition("", "Server error", "100")
                        
                    } else
                    {
                        let lockId = lockList["lockId"] as? Int ?? 0
                        let lockData = lockList["lockData"] as? String ?? ""
                        let lockMac = lockList["lockMac"] as? String ?? ""
                        
                        self.updateLockDataAPI(lockData: lockData, MacId: lockMac, lockId: "\(lockId)") { respponse, message, statusCode in
                            
                            switch statusCode
                            
                            {
                            case "404":
                                complition(respponse,"Invalid URL", "404")
                            case "100":
                                complition(respponse, "Server error", "100")
                            default:
                                complition(respponse, "Your LockData updated succesfully.", "106")
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    func updateLockDataAPI(lockData:String, MacId:String, lockId:String, complition: @escaping (_ respponse: String, _ message: String, _ statusCode: String)->Void) {
        
        var lockData = lockData.replaceTTLockData(string: "+", replacement: "%2B")
        lockData = lockData.replaceTTLockData(string: "==", replacement: "%%%%2CC")
        lockData = lockData.replaceTTLockData(string: "=", replacement: "######")
        
        let email = UserDefaults.standard.value(forKey: "user") as! String
        let token = UserDefaults.standard.value(forKey: "token") as! String
        
        let parms = "method=UpdateLockDatachild&lockData=\(lockData)&MacId=\(MacId)&LockID=\(lockId)&loginuserName=\(email)&contvals=\(email)&tkv=\(token)"
        
        let cipher:String = CryptoHelper.encrypt(input:parms)!;
        
        Networking().callingGetAPI(url: "\(Domain.encryptedBaseUrl)\(cipher)") { respponse, message, statusCode in
            
            
            switch statusCode
            
            {
            case "404":
                complition(respponse ?? "","Invalid URL", "404")
            case "100":
                complition(respponse ?? "", "Server error", "100")
            default:
                complition(respponse ?? "", "Your LockData updated successfully.", "106")
            }
        }
    }
    
    func lockAction(action: TTControlAction, lockData:String?, deviceCode:String, deviceName:String, complition: @escaping (_ respponse: String, _ message: String, _ statusCode: String)->Void) {
        
        TTLock.controlLock(with: action, lockData: lockData, success: { lockTime, electricQuantity, uniqueId in
            
            
            if action == .actionLock
            {
                self.uploadLockUnlockRecord(deviceCode: "\(deviceCode)", deviceName: "\(deviceName)", action: "Lock") { message in
                    complition("Devie is locked successfully.", "success", "106")
                }
                
            } else
            {
                self.uploadLockUnlockRecord(deviceCode: "\(deviceCode)", deviceName: "\(deviceName)", action: "Unlock") { message in
                    complition("Devie is unlocked successfully.", "success", "106")
                }
            }
            
            
        }, failure: { errorCode, errorMsg in
            
            if errorMsg == "Bluetooth is off"
            {
                complition("", "Bluetooth is off.", "109")
                
            } else if errorMsg == "Connecte bluetooth  timeout"
            {
                complition("", "Connect bluetooth timeout. Please trying again.", "100")
                
            } else
            {
                complition("", "Your lock data is expired. Please update your lock data.", "108")
            }
        })
    }
    
    
    func uploadLockUnlockRecord(deviceCode:String, deviceName:String, action:String, complition: @escaping (_ message: Bool)->Void) {
        
        let user = UserDefaults.standard.value(forKey: "user") as? String ?? ""
        let uid = UserDefaults.standard.value(forKey: "uid") as? String ?? ""
        
        let parameter = [String:Any]()
        
        let parm = "?method=SaveLockStatus_Web&Createdby=\(uid)&LockID=\(deviceCode)&LoginUserName=\(user)&Status=\(action)&type=1&LockName=&type1=TTLock"
        
        Networking().callingPostAPI(url: "\(Domain.baseUrl)\(parm)", parameter: parameter) { respponse, message, statusCode in
            
            switch statusCode
            
            {
            case "404":
                complition(false)
            case "100":
                complition(false)
            default:
                complition(true)
            }
        }
    }
    
}

