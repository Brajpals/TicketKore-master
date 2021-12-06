

import Foundation
import AlamofireObjectMapper
import Alamofire
import SwiftyJSON
import ObjectMapper


public enum ServerErrorCodes: Int{
    case notFound = 404
    case validationError = 422
    case internalServerError = 500
    
}


public enum ServerErrorMessages: String{
    case notFound = "Not Found"
    case validationError = "Validation Error"
    case internalServerError = "Internal Server Error"
}


public enum ServerError: Error{
    case systemError(Error)
    case customError(String)
    
    public var details:(code:Int ,message:String){
        switch self {
        
        case .customError(let errorMsg):
            switch errorMsg {
            case "Not Found":
                return (ServerErrorCodes.notFound.rawValue,ServerErrorMessages.notFound.rawValue)
            case "Validation Error":
                return (ServerErrorCodes.validationError.rawValue,ServerErrorMessages.validationError.rawValue)
            case "Internal Server Error":
                return (ServerErrorCodes.internalServerError.rawValue,ServerErrorMessages.internalServerError.rawValue)
            default:
                return (ServerErrorCodes.internalServerError.rawValue,ServerErrorMessages.internalServerError.rawValue)
            }
            
        case .systemError(let errorCode):
            return (errorCode._code,errorCode.localizedDescription)
        }
    }
}



public struct ApiManager{
    
    static let sharedInstance = ApiManager()
    static let db = SqliteDbStore()
    
    
    
    static func getUserDetail(params: [String:Any], loginType: String , methodTyPe:HTTPMethod,url:String, completion: @escaping(_ success: Bool) -> Void, failure: @escaping (_ error: Error?,_ errorCode: Int?, _ message: String?) -> Void) {
        
        let headers = ["Content-Type" : "application/json"] as [String : String]
        let manager = Alamofire.SessionManager.default
        manager.session.configuration.timeoutIntervalForRequest = 120
        
        Alamofire.request(url, method: methodTyPe, parameters: params, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { (response) in
            switch response.result {
            case .success:
                if let responseValue = response.result.value {
                    let json = JSON(responseValue)
                    if let objectDictionary = json.dictionaryObject,
                       let object = Mapper<LoginDetailsOTP>().map(JSON: objectDictionary) {
                        DataManager.shared.loginDetails = object
                        AppManager.saveLoginDetails()
                        completion(true)
                    }
                    else {
                        completion(false)
                    }
                } else {
                    completion(false)
                }
                break
            case .failure(let error):
                failure(error,response.response?.statusCode,getErrorMessage(response: response, false))
                
                if error.localizedDescription.contains("JSON"){
                    AppUtility.showAlertWithProperty("Alert", messageString: "Server Error. Please try again later")
                }
                
                AppUtility.showAlertWithProperty("Alert", messageString: error.localizedDescription)
                AppUtility.hideProgress()
            }
        }
    }
    
    
    
    
    static func checkActivityStore(params: [String:Any] , methodTyPe:HTTPMethod,url:String, completion: @escaping(_ object: String, _ message: String) -> Void, failure: @escaping (_ error: Error?,_ errorCode: Int?, _ message: String?) -> Void) {
        
        let headers = ["Content-Type" : "application/json"] as [String : String]
        
        Alamofire.request(url, method: methodTyPe, parameters: params, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { (response) in
            switch response.result {
            case .success:
                
                if let responseValue = response.result.value {
                    let jsonString = String(data: response.data!, encoding: .utf8)!
                    
                    let json = JSON(responseValue)
                    // let custid = json["result"]["custid"].string
                    if let serviceError = json["result"]["serviceError"].string {
                        completion(serviceError, "Fail")
                    }
                    else if let error = json["result"]["invalidToken"].string {
                        completion(error, "Fail")
                    }
                    else{
                        
                        AppManager.getLastSavedLoginDetails()?.result?.ripa_enrollment_activity_id = json["result"]["ripa_enrollment_activity_id"].string ?? ""
                        completion(jsonString, "Success")
                    }
                    
                } else {
                    completion("", "Fail")
                }
                break
            case .failure(let error):
                failure(error,response.response?.statusCode,getErrorMessage(response: response, false))
                if error.localizedDescription.contains("JSON"){
                    AppUtility.showAlertWithProperty("Alert", messageString: "Server Error. Please try again later")
                }
                else{
                    AppUtility.showAlertWithProperty("Alert", messageString: error.localizedDescription)
                }
                AppUtility.hideProgress()
            // completion("", "Fail")
            
            }
        }
    }
    
    
    
    static func verifyEmailOtp(params: [String:Any] , methodTyPe:HTTPMethod,url:String, completion: @escaping(_ object: Any, _ message: String) -> Void, failure: @escaping (_ error: Error?,_ errorCode: Int?, _ message: String?) -> Void) {
        
        let headers = ["Content-Type" : "application/json"] as [String : String]
        
        Alamofire.request(url, method: methodTyPe, parameters: params, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { (response) in
            switch response.result {
            case .success:
                
                if let responseValue = response.result.value {
                    //  let jsonString = String(data: response.data!, encoding: .utf8)!
                     let json = JSON(responseValue)
                    completion(response.data!, "Success")
                   
                } else {
                    completion(response.data!, "Fail")
                }
                break
            case .failure(let error):
                failure(error,response.response?.statusCode,getErrorMessage(response: response, false))
               // AppUtility.showAlertWithProperty("Alert", messageString: error.localizedDescription)
                AppUtility.hideProgress()
                completion("", "Fail")
            }
        }
    }
    
    
    
    
    static func updateIOSVersion(params: [String:Any], methodTyPe:HTTPMethod,url:String, completion: @escaping(_ success: Bool) -> Void, failure: @escaping (_ error: Error?,_ errorCode: Int?, _ message: String?) -> Void) {
        
        let headers = ["Content-Type" : "application/json"] as [String : String]
        let manager = Alamofire.SessionManager.default
        manager.session.configuration.timeoutIntervalForRequest = 120
        
        Alamofire.request(url, method: methodTyPe, parameters: params, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { (response) in
            switch response.result {
            case .success:
                if let responseValue = response.result.value {
                    let json = JSON(responseValue)
                    if let objectDictionary = json.dictionaryObject,
                       let object = Mapper<versionUpdate>().map(JSON: objectDictionary) {
                        DataManager.shared.versionUpdate = object
                        AppManager.saveVersionDetail()
                        completion(true)
                    }
                    else {
                         completion(false)
                    }
                } else {
                    completion(false)
                }
                break
            case .failure(let error):
                failure(error,response.response?.statusCode,getErrorMessage(response: response, false))
                
                if error.localizedDescription.contains("JSON"){
                    AppUtility.showAlertWithProperty("Alert", messageString: "Server Error. Please try again later")
                }
                
                AppUtility.showAlertWithProperty("Alert", messageString: error.localizedDescription)
                AppUtility.hideProgress()
            }
        }
    }
    
    
    
    
    
    static func getCount(params: [String:Any] , methodTyPe:HTTPMethod,url:String, completion: @escaping(_ object: Any, _ message: String) -> Void, failure: @escaping (_ error: Error?,_ errorCode: Int?, _ message: String?) -> Void) {
        
        let headers = ["Content-Type" : "application/json"] as [String : String]
        
        Alamofire.request(url, method: methodTyPe, parameters: params, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { (response) in
            switch response.result {
            case .success:
                
                if let responseValue = response.result.value {
                    //  let jsonString = String(data: response.data!, encoding: .utf8)!
                    
                    let json = JSON(responseValue)
                    completion(response.data!, "Success")
                    //                     if let serviceError = json["result"][0]["serviceError"].string {
                    //                        completion(serviceError, "Fail")
                    //                      }
                    //                    else{
                    //                        completion(response.data!, "Success")
                    //                    }
                } else {
                    completion("", "Fail")
                }
                break
            case .failure(let error):
                failure(error,response.response?.statusCode,getErrorMessage(response: response, false))
                AppUtility.showAlertWithProperty("Alert", messageString: error.localizedDescription)
                AppUtility.hideProgress()
                completion("", "Fail")
            }
        }
    }
    
    
    
    // TO GET FEATURES LIST
    static func getFeaturesList( methodTyPe:HTTPMethod,url:String, completion: @escaping(_ object: Any, _ message: String) -> Void, failure: @escaping (_ error: Error?,_ errorCode: Int?, _ message: String?) -> Void) {
        let param:[String : Any] =  ["custid" : AppManager.getLastSavedLoginDetails()?.result?.custid ?? "1"]
        let params:[String : Any] =  ["id":"82F85DB43CBF6", "method": "ripaFeatures", "params": param,"jsonrpc": "2.0"]
        let url = AppConstants.BaseURL.URL + "/ripa"
   
        let headers = ["Content-Type" : "application/json"] as [String : String]
        
        Alamofire.request(url, method: methodTyPe, parameters: params, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { (response) in
            switch response.result {
            case .success:
                
                if let responseValue = response.result.value {
                    //  let jsonString = String(data: response.data!, encoding: .utf8)!
                     let json = JSON(responseValue)
                    completion(response.data!, "Success")
                   
                } else {
                    completion("", "Fail")
                }
                break
            case .failure(let error):
                failure(error,response.response?.statusCode,getErrorMessage(response: response, false))
               // AppUtility.showAlertWithProperty("Alert", messageString: error.localizedDescription)
                AppUtility.hideProgress()
                completion("", "Fail")
            }
        }
    }
    
    
    
    
    // TO GET COUNTY LIST
    static func getCountyList( methodTyPe:HTTPMethod,url:String, completion: @escaping(_ object: Any, _ message: String) -> Void, failure: @escaping (_ error: Error?,_ errorCode: Int?, _ message: String?) -> Void) {
        
          let params:[String : Any] =  ["id":"82F85DB43CBF6", "method": "getCounties","jsonrpc": "2.0"]
        let url = AppConstants.BaseURL.URL
        let headers = ["Content-Type" : "application/json"] as [String : String]
        
        Alamofire.request(url, method: methodTyPe, parameters: params, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { (response) in
            switch response.result {
            case .success:
                
                if let responseValue = response.result.value {
                    //  let jsonString = String(data: response.data!, encoding: .utf8)!
                     let json = JSON(responseValue)
                    completion(response.data!, "Success")
                   
                } else {
                    completion("", "Fail")
                }
                break
            case .failure(let error):
                failure(error,response.response?.statusCode,getErrorMessage(response: response, false))
               // AppUtility.showAlertWithProperty("Alert", messageString: error.localizedDescription)
                AppUtility.hideProgress()
                completion("", "Fail")
            }
        }
    }
    
    
    
    // TO DELETE RIPA APPLICATION
    static func deleteRipa(params: [String:Any] , methodTyPe:HTTPMethod,url:String, completion: @escaping(_ object: Any, _ message: String) -> Void, failure: @escaping (_ error: Error?,_ errorCode: Int?, _ message: String?) -> Void) {
        
        let headers = ["Content-Type" : "application/json"] as [String : String]
        
        Alamofire.request(url, method: methodTyPe, parameters: params, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { (response) in
            switch response.result {
            case .success:
                
                if let responseValue = response.result.value {
                    //  let jsonString = String(data: response.data!, encoding: .utf8)!
                     let json = JSON(responseValue)
                    completion(response.data!, "Success")
                   
                } else {
                    completion("", "Fail")
                }
                break
            case .failure(let error):
                failure(error,response.response?.statusCode,getErrorMessage(response: response, false))
               // AppUtility.showAlertWithProperty("Alert", messageString: error.localizedDescription)
                AppUtility.hideProgress()
                completion("", "Fail")
            }
        }
    }
    
    
    
    
    static func getRipaQuestions(params: [String:Any] , methodTyPe:HTTPMethod,url:String, completion: @escaping(_ object: String, _ message: String) -> Void, failure: @escaping (_ error: Error?,_ errorCode: Int?, _ message: String?) -> Void) {
        
        let headers = ["Content-Type" : "application/json"] as [String : String]
        
        let manager = Alamofire.SessionManager.default
        manager.session.configuration.timeoutIntervalForRequest = 1
        manager.request(url, method: methodTyPe, parameters: params, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { (response) in
            switch response.result {
            case .success:
                
                if let responseValue = response.result.value {
                    let jsonString = String(data: response.data!, encoding: .utf8)!
                    
                    let json = JSON(responseValue)
                    if let objectDictionary = json.dictionaryObject,
                       let object = Mapper<NewRipaQuestionsModel>().map(JSON: objectDictionary) {
                        DataManager.shared.newRipaQuestion = object
                        
                        completion(jsonString, "Success")
                    }
                    
                } else {
                    completion("", "Fail")
                }
                break
            case .failure(let error):
                failure(error,response.response?.statusCode,getErrorMessage(response: response, false))
                AppUtility.showAlertWithProperty("Alert", messageString: error.localizedDescription)
                AppUtility.hideProgress()
                completion("", "Fail")
            }
        }
    }
    
    
    
    
    static func getRipaData(params: [String:Any], method: String , methodTyPe:HTTPMethod, url:String, completion: @escaping(_ object: String, _ message: String) -> Void, failure: @escaping (_ error: Error?,_ errorCode: Int?, _ message: String?) -> Void) {
        
        db.openDatabase()
        
        let headers = ["Content-Type" : "application/json"] as [String : String]
        
        Alamofire.request(url, method: methodTyPe, parameters: params, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { (response) in
            switch response.result {
            case .success:
                let jsonString = String(data: response.data!, encoding: .utf8)!
                
                if method == "Cities"{
                    db.insertData(jsonString: jsonString, tableName: "cityTable")
                }
                
                else if method == "Location"{
                    db.insertData(jsonString: jsonString, tableName: "locationTable")
                }
                
                else if method == "Violations"{
                    db.insertData(jsonString: jsonString, tableName: "violationTable")
                }
                
                else if method == "School"{
                    db.insertData(jsonString: jsonString, tableName: "schoolTable")
                }
                else if method == "Education"{
                    db.insertData(jsonString: jsonString, tableName: "educationCodeTable")
                }
                
                if response.result.value != nil {
                    
                    completion(jsonString, "true")
                } else {
                    completion(jsonString, "false")
                }
                break
            case .failure(let error):
                failure(error,response.response?.statusCode,getErrorMessage(response: response, false))
                AppUtility.showAlertWithProperty("Alert", messageString: error.localizedDescription)
                AppUtility.hideProgress()
                completion("", "false")
            }
        }
    }
    
    
    
    static func updateRipa(params: [String:Any] , methodTyPe:HTTPMethod,url:String, completion: @escaping(_ object: Any, _ message: String) -> Void, failure: @escaping (_ error: Error?,_ errorCode: Int?, _ message: String?) -> Void) {
        
        let headers = ["Content-Type" : "application/json"] as [String : String]
        
        Alamofire.request(url, method: methodTyPe, parameters: params, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { (response) in
            switch response.result {
            case .success:
                
                if let responseValue = response.result.value {
                    //  let jsonString = String(data: response.data!, encoding: .utf8)!
                    
                    //                    let json = JSON(responseValue)
                    //                     if let serviceError = json["result"][0]["serviceError"].string {
                    //                        completion(serviceError, "Fail")
                    //                      }
                    //                    else{
                    completion(response.data!, "Success")
                    //      }
                } else {
                    completion("", "Fail")
                }
                break
            case .failure(let error):
                failure(error,response.response?.statusCode,getErrorMessage(response: response, false))
                AppUtility.showAlertWithProperty("Alert", messageString: error.localizedDescription)
                AppUtility.hideProgress()
                completion("", "Fail")
            }
        }
    }
    
    
    
    
    static func updateEditedRipa(params: [String:Any] , methodTyPe:HTTPMethod,url:String, completion: @escaping(_ object: Any, _ message: String) -> Void, failure: @escaping (_ error: Error?,_ errorCode: Int?, _ message: String?) -> Void) {
        
        let headers = ["Content-Type" : "application/json"] as [String : String]
        
        Alamofire.request(url, method: methodTyPe, parameters: params, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { (response) in
            switch response.result {
            case .success:
                
                if let responseValue = response.result.value {
                    //  let jsonString = String(data: response.data!, encoding: .utf8)!
                    
                    let json = JSON(responseValue)
                    let serviceError = json["result"]["serviceError"].stringValue
                    if serviceError != ""{
                        completion(serviceError, "Fail")
                    }
                    else{
                        let result = json["result"]["result"].stringValue
                        completion("", "Success")
                    }
                } else {
                    completion("Something Went Wrong", "Fail")
                }
                break
            case .failure(let error):
                failure(error,response.response?.statusCode,getErrorMessage(response: response, false))
                AppUtility.showAlertWithProperty("Alert", messageString: error.localizedDescription)
                AppUtility.hideProgress()
                completion("", "Fail")
            }
        }
    }
    
    
    
    
    static func getAllRipaWith_CE_ER(params: [String:Any] , methodTyPe:HTTPMethod,url:String, completion: @escaping(_ object: Any, _ message: String) -> Void, failure: @escaping (_ error: Error?,_ errorCode: Int?, _ message: String?) -> Void) {
        
        let headers = ["Content-Type" : "application/json"] as [String : String]
        
        Alamofire.request(url, method: methodTyPe, parameters: params, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { (response) in
            switch response.result {
            case .success:
                
                if let responseValue = response.result.value {
                    
                    let json = JSON(responseValue)
                    if let serviceError = json["result"][0]["serviceError"].string {
                        completion(serviceError, "Fail")
                    }
                    else{
                        completion(response.data!, "Success")
                    }
                } else {
                    completion("", "Fail")
                }
                break
            case .failure(let error):
                failure(error,response.response?.statusCode,getErrorMessage(response: response, false))
                AppUtility.showAlertWithProperty("Alert", messageString: error.localizedDescription)
                AppUtility.hideProgress()
                completion("", "Fail")
            }
        }
    }
    
    
    
    
    static func getrejectedApplicationWithUID(params: [String:Any] , methodTyPe:HTTPMethod,url:String, completion: @escaping(_ object: Any, _ message: String) -> Void, failure: @escaping (_ error: Error?,_ errorCode: Int?, _ message: String?) -> Void) {
        
        let headers = ["Content-Type" : "application/json"] as [String : String]
        
        Alamofire.request(url, method: methodTyPe, parameters: params, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { (response) in
            switch response.result {
            case .success:
                
                if let responseValue = response.result.value {
                    
                    let json = JSON(responseValue)
                    if let serviceError = json["result"][0]["serviceError"].string {
                        completion(serviceError, "Fail")
                    }
                    else{
                        completion(response.data!, "Success")
                    }
                } else {
                    completion("", "Fail")
                }
                break
            case .failure(let error):
                failure(error,response.response?.statusCode,getErrorMessage(response: response, false))
                // AppUtility.showAlertWithProperty("Alert", messageString: error.localizedDescription)
                AppUtility.hideProgress()
            // completion("", "Fail")
            }
        }
    }
    
    
    
    static func getScrubWords(params: [String:Any] , methodTyPe:HTTPMethod,url:String, completion: @escaping(_ object: Any, _ message: String) -> Void, failure: @escaping (_ error: Error?,_ errorCode: Int?, _ message: String?) -> Void) {
        
        let headers = ["Content-Type" : "application/json"] as [String : String]
        
        Alamofire.request(url, method: methodTyPe, parameters: params, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { (response) in
            switch response.result {
            case .success:
                
                if let responseValue = response.result.value {
                    
                    let json = JSON(responseValue)
                    if let serviceError = json["result"][0]["serviceError"].string {
                        completion(serviceError, "Fail")
                     }
                    else{
                        completion(response.data!, "Success")
                    }
                } else {
                    completion("", "Fail")
                }
                break
            case .failure(let error):
                failure(error,response.response?.statusCode,getErrorMessage(response: response, false))
                AppUtility.showAlertWithProperty("Alert", messageString: error.localizedDescription)
                AppUtility.hideProgress()
                completion("", "Fail")
            }
        }
    }
    
    
    
    
    static func getSkeletonData(params: [String:Any] , methodTyPe:HTTPMethod,url:String, completion: @escaping(_ object: Any, _ message: String) -> Void, failure: @escaping (_ error: Error?,_ errorCode: Int?, _ message: String?) -> Void) {
        
        let headers = ["Content-Type" : "application/json"] as [String : String]
        
        Alamofire.request(url, method: methodTyPe, parameters: params, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { (response) in
            switch response.result {
            case .success:
                
                if let responseValue = response.result.value {
                    let jsonString = String(data: response.data!, encoding: .utf8)!
                    
                    let json = JSON(responseValue)
                    //                   // let custid = json["result"]["custid"].string
                    //                    if let serviceError = json["result"][0]["serviceError"].string {
                    //                        completion(serviceError, "Fail")
                    //                      }
                    //                    else if let error = json["result"][0]["invalidToken"].string {
                    //                        completion(error, "Fail")
                    //                      }
                    //                    else{
                    completion(response.data!, "Success")
                    //    }
                    
                } else {
                    completion("", "Fail")
                }
                break
            case .failure(let error):
                failure(error,response.response?.statusCode,getErrorMessage(response: response, false))
                AppUtility.showAlertWithProperty("Alert", messageString: error.localizedDescription)
                AppUtility.hideProgress()
                completion("", "Fail")
                
            }
        }
    }
    
    
    
    
    static func getErrorMessage(response: DataResponse<Any>?,_ shouldRedirect: Bool = true) -> String? {
        var errorMessage: String?
        if response?.response?.statusCode == 401 && shouldRedirect {
        } else if let data = response?.data {
            let responsJSON = JSON(data)
            print(responsJSON)
            if let message = responsJSON["detail"].string {
                errorMessage = message
            } else if let message = responsJSON["error_description"].string {
                errorMessage = message
            } else {
                var error = ""
                if let dictionary = responsJSON.dictionaryObject {
                    for key in dictionary.keys {
                        if let messageArray = dictionary[key] as? [String], messageArray.count > 0 {
                            error += messageArray[0]+"\n"
                        } else if let message = dictionary[key] as? String {
                            error += message+"\n"
                        } else if let innerDic = dictionary[key] as? [String:Any] {
                            for key in innerDic.keys {
                                if let messageArray = innerDic[key] as? [String], messageArray.count > 0 {
                                    error += messageArray[0]+"\n"
                                } else if let message = innerDic[key] as? String {
                                    error += message+"\n"
                                }
                            }
                        }
                    }
                }
                if error != "" {
                    errorMessage = error
                }
            }
        }
        
        return errorMessage
    }
    
}
