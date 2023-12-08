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
    
    public static func intializeSafeobuddy(complition: @escaping (_ message: String)->Void)
    {
        // Please give access of BLE to user
        TTLock.setupBluetooth({ state in
            print(String(format: "##############  SafeOBuddy lock is working, bluetooth state: %ld  ##############"))
        })
    }
    
    
    public static func authUser(email: String, password: String, complition: @escaping (_ response: [String:Any], _ message: String, _ statusCode: String) -> Void)
    {
        
        UserDefaults.standard.setValue(email, forKey:"user")
        
        let parmater = "method=LoginValidation1&uid=\(email)&pwd=\(password)&version=3.7"
        
        guard let cipher = CryptoHelper.encrypt(input: parmater) else { return }
        
        let baseUrlString = "\(Domain.encryptedBaseUrl)\(cipher)"
        
        
        Networking().callingGetAPI(url: baseUrlString) { respponse, message, statusCode in
            
            
            switch statusCode
            
            {
            case "404":
                
                complition([String : Any](), "Invalid URL", "404")
                
            case "100":
                
                complition([String : Any](), "Server error", "100")
                
            default:
                
                guard let decrypt = CryptoHelper.decrypt(input: respponse ?? "") else {return}
                
                let jsonData = decrypt.data(using: .utf8)
                
                guard let value = jsonData, value.count != 0, value.isEmpty != true else { complition([String : Any](), "No data found", "103"); return }
                
                let dictionary = try? JSONSerialization.jsonObject(with: jsonData!, options: .mutableLeaves)
                
                if let dataDict = dictionary as? [String : Any] {
                    
                    let tempSuccess = dataDict["success"] as? String
                    
                    guard let messageCode = tempSuccess, messageCode == "1" else { complition([String : Any](), "\(dataDict["message"] as? String ?? "")", "104");  return}
                    
                    if let valueDic = dataDict["loginvalidation"] as? [[String : Any]] {
                        
                        TTLocks().loginTTLock { _ in }
                        
                        let loginData = valueDic.first
                        
                        let date = Date()
                        let dateTemp = date.timeIntervalSince1970 + 120000.0
                        
                        UserDefaults.standard.setValue(dateTemp, forKey: "session")
                        UserDefaults.standard.setValue(loginData?["token"] as? String, forKey: "token")
                        UserDefaults.standard.setValue(loginData?["uid"] as? String, forKey: "uid")
                        
                        complition(loginData!, "success", "106")
                    }
                }
                
            }
        }
    }
    
    
    // Mac ID function declere here
    public static func updateLockData(DeviceCode:String?, complition: @escaping (_ respponse: String, _ message: String, _ statusCode: String)->Void)
    {
        guard validate() else {complition("", "Access Denied: Unauthorized User", "107"); return}
        
        TTLocks().getLockDataAPI(lockID: DeviceCode) { response, message, statusCode in
            
            switch statusCode
            
            {
            case "404":
                complition(response, "Invalid URL", "104")
            case "100":
                complition(response, "Server error", "100")
            default:
                complition(response, "Your LockData updated succesfully.", "106")
            }
        }
    }
    
    
    public static func getDeviceList(complition: @escaping (_ respponse: [[String:Any]], _ message: String, _ statusCode: String) -> Void)
    {
        
        guard validate() else {complition([[String : Any]](), "Access Denied: Unauthorized User", "107"); return}
        
        let user = UserDefaults.standard.value(forKey: "user") as? String ?? ""
        let token = UserDefaults.standard.value(forKey: "token") as? String ?? ""
        let uid = UserDefaults.standard.value(forKey: "uid") as? String ?? ""
        
        let parmater = "method=GetV3lockdetail&cid=\(uid)&contvals=\(user)&tkv=\(token)&cat=1"
        
        guard let cipher = CryptoHelper.encrypt(input: parmater) else { return }
        
        let baseUrlString = "\(Domain.encryptedBaseUrl)\(cipher)"
        
        Networking().callingGetAPI(url: baseUrlString) { respponse, message, statusCode in
            
            switch statusCode
            
            {
            case "404":
                complition([[String : Any]](), "Invalid URL", "404")
            case "100":
                complition([[String : Any]](), "Server error", "100")
            default:
                
                guard let decrypt = CryptoHelper.decrypt(input: respponse ?? "") else {return}
                
                let jsonData = decrypt.data(using: .utf8)
                
                guard let value = jsonData, value.count != 0, value.isEmpty != true else { complition([[String : Any]](), "No data found", "104"); return }
                
                let dictionary = try? JSONSerialization.jsonObject(with: jsonData!, options: .mutableLeaves)
                
                if let dataDict = dictionary as? [String : Any] {
                    
                    let tempSuccess = dataDict["success"] as? String
                    
                    guard let messageCode = tempSuccess, messageCode == "1" else { complition([[String : Any]](), "\(dataDict["message"] as? String ?? "")", "104");  return}
                    
                    if let valueDic = dataDict["newusercreation"] as? [[String : Any]] {
                        
                        complition(valueDic, "success", "106")
                    }
                }
            }
        }
    }
   
    
    public static func getDeviceRecord(deviceName: String, deviceID: String, complition: @escaping (_ respponse: [[String:Any]], _ message: String, _ statusCode: String) -> Void)
    {
        
        guard validate() else {complition([[String : Any]](), "Access Denied: Unauthorized User", "107"); return}
        
        let date = Date()
        let formatter = DateFormatter()
        
        formatter.dateFormat = "MM/dd/yyyy"
        
        // Add one month to the current date
        let month = Calendar.current.date(byAdding: .month, value: -1, to: date)!
        
        let fromDate = formatter.string(from: month)
        let toDate = formatter.string(from: date)
        
        let uid = UserDefaults.standard.value(forKey: "uid") as! String
        
        let parameter = [String:Any]()
        
        let parm = "?method=GetVehicle_Lock_Summary&FromDate=\(fromDate)&ToDate=\(toDate)&VehicleNumber=\(deviceName)&DeviceId=\(deviceID)&contactid=\(uid)&val1=&val2="
        
        Networking().callingPostAPI(url: "\(Domain.baseUrl)\(parm)", parameter: parameter) { response, message, statusCode in
            
            switch statusCode
            
            {
            case "404":
                complition([[String:Any]](), "Invalid URL", "404")
            case "100":
                complition([[String:Any]](), "Server error", "100")
            default:
                
                let jsonData = response.data(using: .utf8)
                
                guard let value = jsonData, value.count != 0, value.isEmpty != true else { complition([[String : Any]](), "No data found", "103"); return }
                
                let dictionary = try? JSONSerialization.jsonObject(with: jsonData!, options: .mutableLeaves)
                
                if let data = dictionary as? [String: Any] {
                    
                    let tempSuccess = data["success"] as? String
                    
                    guard let messageCode = tempSuccess, messageCode == "1" else { complition([[String : Any]](), "\(data["message"] as? String ?? "")", "104");  return}
                    
                    if let jsonData = data["GetCOmmandSent"] as? [[String : Any]]
                    {
                        complition(jsonData, "success", "106")
                    }
                }
            }
        }
    }
    
    public static func getFilterDeviceRecord(deviceName: String, deviceID: String, fromDate: String, todayDate: String,  complition: @escaping (_ respponse: [[String:Any]], _ message: String, _ statusCode: String) -> Void)
    {
        
        guard validate() else {complition([[String : Any]](), "Access Denied: Unauthorized User", "107"); return}
        
        let uid = UserDefaults.standard.value(forKey: "uid") as! String
        
        let parameter = [String:Any]()
        
        let parm = "?method=GetVehicle_Lock_Summary&FromDate=\(fromDate)&ToDate=\(todayDate)&VehicleNumber=\(deviceName)&DeviceId=\(deviceID)&contactid=\(uid)&val1=&val2="
        
        Networking().callingPostAPI(url: "\(Domain.baseUrl)\(parm)", parameter: parameter) { response, message, statusCode in
            
            switch statusCode
            
            {
            case "404":
                complition([[String:Any]](), "Invalid URL", "404")
            case "100":
                complition([[String:Any]](), "Server error", "100")
            default:
                
                let jsonData = response.data(using: .utf8)
                
                guard let value = jsonData, value.count != 0, value.isEmpty != true else { complition([[String : Any]](), "No data found", "103"); return }
                
                let dictionary = try? JSONSerialization.jsonObject(with: jsonData!, options: .mutableLeaves)
                
                if let data = dictionary as? [String: Any] {
                    
                    let tempSuccess = data["success"] as? String
                    
                    guard let messageCode = tempSuccess, messageCode == "1" else { complition([[String : Any]](), "\(data["message"] as? String ?? "")", "104");  return}
                    
                    if let jsonData = data["GetCOmmandSent"] as? [[String : Any]]
                    {
                        complition(jsonData, "106", "success")
                    }
                }
            }
        }
    }
 
    
    // BLE function declere here
    public static func openLock(lockData:String?, deviceCode: String, deviceName: String, complition: @escaping (_ respponse: String, _ message: String, _ statusCode: String)->Void)
    {
        
        guard validate() else {complition("", "Access Denied: Unauthorized User", "104"); return}

        if let data = lockData, data.isEmpty == true, data.count == 0 {complition("", "LockData is empty.", ""); return}
        
        TTLocks().lockAction(action: .actionUnlock, lockData: lockData, deviceCode: deviceCode, deviceName: deviceName) { respponse, message, statusCode in
            
            switch statusCode
            
            {
            case "100":
                complition("","\(message)", "\(statusCode)")
            case "108":
                complition("","\(message)", "\(statusCode)")
            case "109":
                complition("","\(message)", "\(statusCode)")
            case "106":
                complition("","\(message)", "\(statusCode)")
            default:
                print("")
            }
        }
    }
    
    
    public static func closeLock(lockData:String?, deviceCode: String, deviceName: String, complition: @escaping (_ respponse: String, _ message: String, _ statusCode: String)->Void)
    {
        
        
        guard validate() else {complition("", "107", "Access Denied: Unauthorized User"); return}

        if let data = lockData, data.isEmpty == true, data.count == 0 {complition("", "LockData is empty.", ""); return}
        
        TTLocks().lockAction(action: .actionLock, lockData: lockData, deviceCode: deviceCode, deviceName: deviceName) { respponse, message, statusCode in
            
            switch statusCode
            
            {
            case "100":
                complition("","\(message)", "\(statusCode)")
            case "108":
                complition("","\(message)", "\(statusCode)")
            case "109":
                complition("","\(message)", "\(statusCode)")
            case "106":
                complition("","\(message)", "\(statusCode)")
            default:
                print("")
            }
        }
    }
    
    
    public static func logOutUser(complition: @escaping (_ message: String) -> Void)
    {
        
        UserDefaults.standard.removeObject(forKey: "uid")
        UserDefaults.standard.removeObject(forKey: "user")
        UserDefaults.standard.removeObject(forKey: "token")
        UserDefaults.standard.removeObject(forKey: "TTLockToken")
        UserDefaults.standard.removeObject(forKey: "TTLockUid")
        
        complition("User has been logged out.")
    }
    
    
    private static func validate() -> Bool
    {
        
        let contactID = UserDefaults.standard.value(forKey: "uid") as? String ?? ""
        
        if contactID.isEmpty == true || contactID.count == 0
            
        {
            return false
        } else
        {
            return false
        }
    }
    
    
    
    // Will be implemented later
    /*
     public static func getGpsData()
     {
     
     }
     
     // Authorization 2.0
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
     */
    
    
    
}
