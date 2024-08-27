//
//  EditRipaViewModel.swift
//  ticketPRO RIPA
//
//  Created by Nitin Singh on 23/02/22.
//

import Foundation
import SwiftyJSON


class EditRipaViewModel {
    
    
    
    
    func getRipaDataForEdit(params: [String:Any]){
        AppUtility.showProgress(nil, title: nil)
        var URL:String?
       
         URL = AppConstants.Api.questions
        // print(params)
        if Reachability.isConnectedToNetwork(){
            ApiManager.getrejectedApplicationWithUID(params: params, methodTyPe: .post, url: URL!, completion: { (success,message) in
                AppUtility.hideProgress(nil)
                 if message == "Success"{
                    
                    if let json = try? JSON(data: success as! Data),let objectDictionary = json.dictionaryObject,let result = objectDictionary["result"] as? [String : Any],let object = UserSettingModel.formattedData(data: result)  {
                        print(object)
                       // self.userDelegate?.getUserSettingData(settingData: object)
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

