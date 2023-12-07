//
//  RandomDataGenerator.swift
//  safeobuddyttlock
//
//  Created by Never Mind on 30/11/23.
//

import Foundation
import TTLock


public class Safeobuddy
{
    
    // Mac ID function declere here
    public static func intializeSafeobuddy(complition: @escaping (_ message: String)->Void)
    {
        /// Please give access of BLE to user
        
        TTLock.isPrintLog = true
        
        TTLock.setupBluetooth({ state in
            print(String(format: "##############  TTLock is working, bluetooth state: %ld  ##############"))
        })
    }
    
    
    public static func authUser(email: String, password: String, appversion: String, complition: @escaping (_ resultValue: [String:Any], _ errorMessage: String) -> Void)
    {
        
        UserDefaults.standard.setValue(email, forKey:"user")
        
        let parmater = "method=LoginValidation1&uid=\(email)&pwd=\(password)&version=\(appversion)"
        
        guard let cipher = CryptoHelper.encrypt(input: parmater) else { return }
        
        let baseUrlString = "\(Domain.encryptedBaseUrl)\(cipher)"
        
        Networking().callingGetAPI(url: baseUrlString) { resultValue, message in
            
            switch message
            {
            case "error":
                
                complition([String : Any]()  , message ?? "")
                
            default:
                
                guard let decrypt = CryptoHelper.decrypt(input: resultValue ?? "") else {return}
              
                let jsonData = decrypt.data(using: .utf8)
                
                guard let value = jsonData, value.count != 0, value.isEmpty != true else {   complition([String : Any]()  , "Data is nil"); return }

                let dictionary = try? JSONSerialization.jsonObject(with: jsonData!, options: .mutableLeaves)
                
                if let dataDict = dictionary as? [String : Any] {
                    
                    
                    if let valueDic = dataDict["loginvalidation"] as? [[String : Any]] {
                        
                        TTLocks().loginTTLock { message in
                            print(message)
                        }
                        
                        let loginData = valueDic.first
                        
                        let date = Date()
                        let dateTemp = date.timeIntervalSince1970 + 120000.0
                        
                        UserDefaults.standard.setValue(dateTemp, forKey: "session")
                        UserDefaults.standard.setValue(loginData?["token"] as? String, forKey: "token")
                        UserDefaults.standard.setValue(loginData?["uid"] as? String, forKey: "uid")
                        
                        complition(loginData! , "suceess")
                    }
                }
            }
        }
    }
    
    
    
    // Mac ID function declere here
    public static func updateLockData(macID:String?, complition: @escaping (_ message: String)->Void)
    {
        TTLocks().getLockDataAPI(lockID: macID) { newMacID, message in
            
            switch newMacID
            {
            case "error":
                complition("\(message)")
            default:
                complition("Your LockData updated succesfully")
            }
        }
    }
    
    
    // BLE function declere here
    public static func openLock(lockData:String?, complition: @escaping (_ message:String)->Void)
    {
        
        guard validateSession(date: Date().timeIntervalSince1970) else {complition("Your session is expired."); return}
        
        if let data = lockData, data.isEmpty == true, data.count == 0 {complition("LockData is empty. Please update it"); return}
        
        TTLocks().lockAction(action: .actionUnlock, lockData: lockData) { message in
            complition(message)
        }
    }
    
    
    public static func closeLock(lockData:String?, complition: @escaping (_ message:String)->Void)
    {
        
        guard validateSession(date: Date().timeIntervalSince1970) else {complition("Your session is expired."); return}
        
        if let data = lockData, data.isEmpty == true, data.count == 0 {complition("LockData is empty. Please update it") ; return}
        
        TTLocks().lockAction(action: .actionLock, lockData: lockData) { message in
            
            complition(message)
        }
        
    }
    
    
    public static func getDeviceList(complition: @escaping (_ resultValue: [[String:Any]], _ errorMessage: String) -> Void)
    {
        
        guard validateSession(date: Date().timeIntervalSince1970) else {complition([[String : Any]](), "Your session is expired."); return}
        
        let user = UserDefaults.standard.value(forKey: "user") as? String ?? ""
        let token = UserDefaults.standard.value(forKey: "token") as? String ?? ""
        let uid = UserDefaults.standard.value(forKey: "uid") as? String ?? ""
        
        let parmater = "method=GetV3lockdetail&cid=\(uid)&contvals=\(user)&tkv=\(token)&cat=1"
        
        guard let cipher = CryptoHelper.encrypt(input: parmater) else { return }
        
        let baseUrlString = "\(Domain.encryptedBaseUrl)\(cipher)"
        
        print(parmater,baseUrlString)
        
        Networking().callingGetAPI(url: baseUrlString) { resultValue, message in
            
            switch message
            {
            case "error":
                
                complition([[String : Any]](), message ?? "")
                
            default:
                
                guard let decrypt = CryptoHelper.decrypt(input: resultValue ?? "") else {return}
                
                let jsonData = decrypt.data(using: .utf8)
                
                guard let value = jsonData, value.count != 0, value.isEmpty != true else { complition([[String : Any]]()  , "Data is nil"); return }
                
                let dictionary = try? JSONSerialization.jsonObject(with: jsonData!, options: .mutableLeaves)
                
                if let dataDict = dictionary as? [String : Any] {
                    
                    if let valueDic = dataDict["newusercreation"] as? [[String : Any]] {
                        complition(valueDic , "suceess")
                    }
                }
            }
        }
    }
    
    
    public static func getDeviceRecord(deviceName: String, deviceID: String, complition: @escaping (_ resultValue: [[String:Any]], _ errorMessage: String) -> Void)
    {
        
        guard validateSession(date: Date().timeIntervalSince1970) else {complition([[String : Any]](), "Your session is expired."); return}
        
        let date = Date()
        let formatter = DateFormatter()
        
        // Create a calendar
        let calendar = Calendar.current
        
        formatter.dateFormat = "MM/dd/yyyy"
        
        // Add one month to the current date
        let month = Calendar.current.date(byAdding: .month, value: -1, to: date)!
        
        let fromDate = formatter.string(from: month)
        let toDate = formatter.string(from: date)
        
        let uid = UserDefaults.standard.value(forKey: "uid") as! String
        
        let parameter = [String:Any]()
            
        
        let parm = "?method=GetVehicle_Lock_Summary&FromDate=\(fromDate)&ToDate=\(toDate)&VehicleNumber=\(deviceName)&DeviceId=\(deviceID)&contactid=\(uid)&val1=&val2="

        
        Networking().callingPostAPI(url: "\(Domain.baseUrl)\(parm)", parameter: parameter) { resultValue, message in
            
            switch message
            {
                
            case "error":
                
                complition([[String : Any]]()  , message ?? "")
                
            default:
                
                let jsonData = resultValue?.data(using: .utf8)
                
                guard let value = jsonData, value.count != 0, value.isEmpty != true else { complition([[String : Any]]()  , "Data is nil"); return }
                
                let dictionary = try? JSONSerialization.jsonObject(with: jsonData!, options: .mutableLeaves)
                
                if let data = dictionary as? [String: Any] {
                    
                    if let jsonData = data["GetCOmmandSent"] as? [[String : Any]]
                    {
                        complition(jsonData, "suceess")
                    }
                }
            }
        }
    }
    
    
    
    public static func getFilterDeviceRecord(deviceName: String, deviceID: String, fromDate: String, todayDate: String,  complition: @escaping (_ resultValue: [[String:Any]], _ errorMessage: String) -> Void)
    {
        guard validateSession(date: Date().timeIntervalSince1970) else {complition([[String : Any]](), "Your session is expired."); return}
        
        let uid = UserDefaults.standard.value(forKey: "uid") as! String
        
        let parameter = [String:Any]()
                
        let parm = "?method=GetVehicle_Lock_Summary&FromDate=\(fromDate)&ToDate=\(todayDate)&VehicleNumber=\(deviceName)&DeviceId=\(deviceID)&contactid=\(uid)&val1=&val2="
        
        Networking().callingPostAPI(url: "\(Domain.baseUrl)\(parm)", parameter: parameter) { resultValue, message in
            
            switch message
            {
                
            case "error":
                
                complition([[String : Any]]()  , message ?? "")
                
            default:
                
                let jsonData = resultValue?.data(using: .utf8)
                
                guard let value = jsonData, value.count != 0, value.isEmpty != true else { complition([[String : Any]]()  , "Data is nil"); return }
                
                let dictionary = try? JSONSerialization.jsonObject(with: jsonData!, options: .mutableLeaves)
                
                if let data = dictionary as? [String: Any] {
                    
                    if let jsonData = data["GetCOmmandSent"] as? [[String : Any]]
                    {
                        complition(jsonData, "suceess")
                    }
                }
            }
        }
    }
    
    
    
    
    // Will be implemented later
    /*
     public static func getGpsData()
     {
     
     }
     */
    
    
    private static func validateSession(date:Double) -> Bool
    {
        
        if date < UserDefaults.standard.value(forKey: "session") as? Double ?? 0.0
        {
            return true
        } else
        {
            return false
        }
    }
}
