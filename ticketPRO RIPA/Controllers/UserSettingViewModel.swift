//
//  UserSettingViewModel.swift
//  ticketPRO RIPA
//
//  Created by Nitin Singh on 29/11/21.
//

import Foundation
import SwiftyJSON


protocol UserSettingModelDelegate: AnyObject {
    func getUserSettingData(settingData:UserSettingModel?)
    func updateUserSettingData(msg:String)
}

class UserSettingViewModel {
    
    var  userDelegate : UserSettingModelDelegate?

func getUserSettings () {
    var userId : String = ""
    if let uId = AppManager.getLastSavedLoginDetails()?.result?.userid{
        userId = uId
    }
    var custId : String = ""
    if let idUser = AppManager.getLastSavedLoginDetails()?.result?.custid{
        custId = idUser
    }
    let id = AppManager.getLastSavedLoginDetails()?.id
    let param:[String : Any] = ["userid":userId as Any,"custid":custId]
    let params:[String : Any] =  ["id":id!, "method":"ripaGetsupervisor", "params":param ,"jsonrpc": "2.0"]
     print(param)
    getSupervisorRipa(params: params)
}
   
func getSupervisorRipa(params: [String:Any]){
    AppUtility.showProgress(nil, title: nil)
    var URL:String?
    
     URL = AppConstants.Api.questions
     print(params)
    if Reachability.isConnectedToNetwork(){
        ApiManager.getrejectedApplicationWithUID(params: params, methodTyPe: .post, url: URL!, completion: { (success,message) in
            AppUtility.hideProgress(nil)
             if message == "Success"{
                
                if let json = try? JSON(data: success as! Data),let objectDictionary = json.dictionaryObject,let result = objectDictionary["result"] as? [String : Any],let object = UserSettingModel.formattedData(data: result)  {
                    print(json)
                    print(objectDictionary)
                    self.userDelegate?.getUserSettingData(settingData: object)
                }
              }
            else{
                if success as! String != "" {
                    AppUtility.showAlertWithProperty("Alert", messageString:success as! String )}
               else{
                    AppUtility.showAlertWithProperty("Alert", messageString:"Something went wrong" )}
            }
            
        })
        { (error, code, message) in
            AppUtility.hideProgress(nil)
            
            AppUtility.showAlertWithProperty("Alert", messageString: error!.localizedDescription)
            if let errorMessage = message {
                AppUtility.showAlertWithProperty("Alert", messageString: errorMessage)
            }
        }
    }
    
    else{
        print("Internet Connection not Available!")
        AppUtility.hideProgress(nil)
       // AppUtility.showAlertWithProperty("Alert", messageString: "Internet connection not available.")
         
    }
  }
    
  
    func sendRipaUpdateuser (office_assignment_id : String ,supervisorid : String,other_assignment_value : String ) {
        var userId : String = ""
        if let idUser = AppManager.getLastSavedLoginDetails()?.result?.userid{
            userId = idUser
        }
        var custId : String = ""
        if let idUser = AppManager.getLastSavedLoginDetails()?.result?.custid{
            custId = idUser
        }
        let id = AppManager.getLastSavedLoginDetails()?.id
        let param:[String : Any] = ["userid":userId as Any,"office_assignment_id":office_assignment_id,"supervisorid":supervisorid,"custid":custId,"other_assignment_value" : other_assignment_value]
        let params:[String : Any] =  ["id":id!, "method":"ripaUpdateuser", "params":param ,"jsonrpc": "2.0"]
         print(params)
        updateUserInformation(params: params)
 }
    

    func updateUserInformation(params: [String:Any]){
        AppUtility.showProgress(nil, title: nil)
        var URL:String?
        
         URL = AppConstants.Api.questions
        
        if Reachability.isConnectedToNetwork(){
            ApiManager.getrejectedApplicationWithUID(params: params, methodTyPe: .post, url: URL!, completion: { (success,message) in
                AppUtility.hideProgress(nil)
               
                if message.lowercased() == "success"{
                     if let json = try? JSON(data: success as! Data),let objectDictionary = json.dictionaryObject,let dict = objectDictionary["result"] as? NSDictionary,let msg = dict["message"] as? String{
                        print(objectDictionary)
                        self.userDelegate?.updateUserSettingData(msg: msg)
                    }
                  }
                else{
                    if success as! String != "" {
                        AppUtility.showAlertWithProperty("Alert", messageString:success as! String )}
                   else{
                        AppUtility.showAlertWithProperty("Alert", messageString:"Something went wrong" )}
                }
                
            })
            { (error, code, message) in
                AppUtility.hideProgress(nil)
                
                AppUtility.showAlertWithProperty("Alert", messageString: error!.localizedDescription)
                if let errorMessage = message {
                    AppUtility.showAlertWithProperty("Alert", messageString: errorMessage)
                }
            }
        }
        else{
            print("Internet Connection not Available!")
            AppUtility.hideProgress(nil)
            AppUtility.showAlertWithProperty("Alert", messageString: "Internet connection not available.")
        }
    }
    
    func sendGenderEthenicityInfo (ethnicity : String ,gender : String) {
        var userId : String = ""
        if let idUser = AppManager.getLastSavedLoginDetails()?.result?.userid{
            userId = idUser
        }
       
        let id = AppManager.getLastSavedLoginDetails()?.id
        let param:[String : Any] = ["userid":userId as Any,"ethnicity": ethnicity,"gender":gender]
        let params:[String : Any] =  ["id":id!, "method":"ripaUpdateEthnicityAndGender", "params":param ,"jsonrpc": "2.0"]
         print(params)
        updateGenderEthnicity(params: params)
 }
    
    func updateGenderEthnicity(params: [String:Any]){
        AppUtility.showProgress(nil, title: nil)
        var URL:String?
        
         URL = AppConstants.Api.questions
        
        if Reachability.isConnectedToNetwork(){
            ApiManager.saveGenderEthnicityToServer(params: params, methodTyPe: .post, url: URL!, completion: { (success,message) in
                AppUtility.hideProgress(nil)
               
                if message.lowercased() == "success"{
                     if let json = try? JSON(data: success as! Data),let objectDictionary = json.dictionaryObject,let dict = objectDictionary["result"] as? NSDictionary,let msg = dict["message"] as? String{
                        print(objectDictionary)
                        self.userDelegate?.updateUserSettingData(msg: msg)
                    }
                  }
                else{
                    if success as! String != "" {
                        AppUtility.showAlertWithProperty("Alert", messageString:success as! String )}
                   else{
                        AppUtility.showAlertWithProperty("Alert", messageString:"Something went wrong" )}
                }
                
            })
            { (error, code, message) in
                AppUtility.hideProgress(nil)
                
                AppUtility.showAlertWithProperty("Alert", messageString: error!.localizedDescription)
                if let errorMessage = message {
                    AppUtility.showAlertWithProperty("Alert", messageString: errorMessage)
                }
            }
        }
        else{
            print("Internet Connection not Available!")
            AppUtility.hideProgress(nil)
            AppUtility.showAlertWithProperty("Alert", messageString: "Internet connection not available.")
        }
    }
    

}
