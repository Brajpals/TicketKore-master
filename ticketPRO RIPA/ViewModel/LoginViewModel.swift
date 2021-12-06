
import UIKit
import SwiftyJSON



protocol LoginOTPViewModelDelegate: class {
    func proceedToOTP(isValidLogin: Int, message:String)
}

protocol ActivityStoreDelegate: class {
    func proceedToDashboard()
}



class LoginViewModel {
    weak var OTPdelegate: LoginOTPViewModelDelegate?
    weak var ActivityStoreDelegate: ActivityStoreDelegate?
    
    var validation = Validation()
    
    var custId = AppManager.getLastSavedLoginDetails()?.result?.custid
    var userId = AppManager.getLastSavedLoginDetails()?.result?.userid
    var countyId = AppManager.getLastSavedLoginDetails()?.result?.county_id
    //  let accessToken = AppManager.getLastSavedLoginDetails()?.result?.access_token
    var id = AppManager.getLastSavedLoginDetails()?.id
    var appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    //Bundle.main.infoDictionary?["CFBundleVersion"] as? String
    var enrollment_id = AppManager.getLastSavedLoginDetails()?.result?.enrollment_id
    var ripa_enrollment_id = AppManager.getLastSavedLoginDetails()?.result?.ripa_enrollment_id
    var ripa_enrollment_activity_id = AppManager.getLastSavedLoginDetails()?.result?.ripa_enrollment_activity_id
    
    
 
}




extension LoginViewModel {
    
    func getLoginDetails(){
          custId = AppManager.getLastSavedLoginDetails()?.result?.custid
          userId = AppManager.getLastSavedLoginDetails()?.result?.userid
          countyId = AppManager.getLastSavedLoginDetails()?.result?.county_id
        //  let accessToken = AppManager.getLastSavedLoginDetails()?.result?.access_token
          id = AppManager.getLastSavedLoginDetails()?.id
          appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        //Bundle.main.infoDictionary?["CFBundleVersion"] as? String
          enrollment_id = AppManager.getLastSavedLoginDetails()?.result?.enrollment_id
          ripa_enrollment_id = AppManager.getLastSavedLoginDetails()?.result?.ripa_enrollment_id
          ripa_enrollment_activity_id = AppManager.getLastSavedLoginDetails()?.result?.ripa_enrollment_activity_id
    }
    
    
 
     func checkId(id:String) -> Bool {
        if id == "" {
            // AppUtility.showAlertWithProperty("Alert", messageString: "Please enter your id.")
            return false
        }
        else if id.count < 8{
            return false
        }
        else if !validation.validatEnrollmentId(enrollment: id)
        {
            //AppUtility.showAlertWithProperty("Alert", messageString: "Please enter valid id.")
            return false
        }
        return true
    }
    
    
    func checkNumber(number:String) -> Bool {
         if !validation.validPhoneNumber(phoneNumber: number)
        {
            // AppUtility.showAlertWithProperty("Alert", messageString: "Please enter valid number.")
            return false
        }
        return true
    }
    
    func checkEmail(email:String) -> Bool {
        if !validation.validateEmailId(emailID: email)
        {
            return false
        }
        return true
    }
    
    
    func checkUserId(id:String) -> Bool {
        if id == "" {
            // AppUtility.showAlertWithProperty("Alert", messageString: "Please enter your id.")
            return false
        }
        else if id.count < 3{
            print(id.count)
            return false
        }
        else if id.count > 8{
            print(id.count)
            return false
        }
        return true
    }
    
    
    
    
    func setLoginParam(enrollment_id : String , phone:String, password:String ) ->  [String:Any] {
        AppConstants.getDeviceToken()
        print(AppConstants.deviceToken)
        let param:[String : Any] = ["enrollment_id":enrollment_id , "fcm_token": AppConstants.deviceToken, "phone":phone, "devicetype":"ios", "devicetoken":"", "custId" : "","password": password]
        let params:[String : Any] = ["id":"82F85DB43CBF6", "method":"ripaLogin" , "params": param, "jsonrpc": "2.0"]
        return params
    }
    
    
    
    func setActivityPram(){
        getLoginDetails()
        let userId = AppManager.getLastSavedLoginDetails()?.result?.userid
        let countyId = AppManager.getLastSavedLoginDetails()?.result?.county_id
        let enrollment_id = AppManager.getLastSavedLoginDetails()?.result?.enrollment_id
        let ripa_enrollment_id = AppManager.getLastSavedLoginDetails()?.result?.ripa_enrollment_id
        let ripa_enrollment_activity_id = AppManager.getLastSavedLoginDetails()?.result?.ripa_enrollment_activity_id
        print(userId)
        let param:[String : Any] = ["userId": userId ?? "", "appversion": appVersion ?? "" ,"plateform":"ios", "county_id":countyId ?? "" ,"access_token": AppManager.getLastSavedLoginDetails()?.result?.access_token ?? "","ripa_enrollment_id":ripa_enrollment_id ?? "", "enrollment_id":enrollment_id ?? "", "custid":custId ?? "", "ripa_enrollment_activity_id": ripa_enrollment_activity_id ?? "" , "loginvia": AppConstants.loginVia]
        let params:[String : Any] = ["id":id ?? "", "method":"ripaActivityStore", "params":param,"jsonrpc": "2.0"]
        checkActivityStore(params: params)
    }
    
    
    
    
    
    func getOtpWith(params: [String:Any],loginType:String) {
        AppUtility.showProgress(nil, title: "Checking...")
        var URL:String?
        getLoginDetails()
        URL = AppConstants.Api.otpRequest
        
        ApiManager.getUserDetail(params: params, loginType: loginType, methodTyPe: .post, url: URL!, completion: { [self] (success) in
            AppUtility.hideProgress(nil)
            if success == true{
                let data =  DataManager.shared.loginDetails
                let result = data?.result
                // result?.serviceError != nil
                if result?.serviceError != "" {
                    AppUtility.showAlertWithProperty("Alert", messageString: (result?.serviceError)!)
                }
                else{
                    ripa_enrollment_id = (result?.ripa_enrollment_id)!
                    enrollment_id = (result?.enrollment_id)!
                    custId = (result?.custid)!
                    UserDefaults.standard.set(result?.county_id, forKey: "defaultCountyId")
                    UserDefaults.standard.synchronize()
                    
                    self.OTPdelegate?.proceedToOTP(isValidLogin: 1 , message:"Success")
                }
            }
            else { AppUtility.showAlertWithProperty("Alert", messageString: "Something Went Wrong")}
        })
        { (error, code, message) in
            AppUtility.hideProgress(nil)
            if let errorMessage = message {
                AppUtility.showAlertWithProperty("Alert", messageString: errorMessage)
            }
        }
    }
    
    
    
    func checkEmailOtp(otp:String) {
        getLoginDetails()
        let param:[String : Any] = ["access_token":AppManager.getLastSavedLoginDetails()?.result?.access_token ?? "", "userid":userId!, "otp":otp]
        let params:[String : Any] = ["id":"82F85DB43CBF6", "method":"ripaEmailOtpVerification", "params": param, "jsonrpc": "2.0"]
        
        AppUtility.showProgress(nil, title: "Checking...")
        let URL:String = AppConstants.Api.otpRequest
        
        ApiManager.verifyEmailOtp(params: params, methodTyPe: .post, url: URL, completion: { json,successmsg   in
            AppUtility.hideProgress(nil)
            if successmsg == "Success"{
                if let json = try? JSON(data: json as! Data) {
                    let errorMsg = json["result"]["serviceError"].stringValue
                    if  errorMsg == ""{
                        self.ActivityStoreDelegate?.proceedToDashboard()
                    }
                    else{
                        let code = json["result"]["status"].intValue
                        DashboardViewModel.showAlertWithProperty("Alert", messageString: errorMsg, code:code )
                    }
                }
            }
        })
        { (error, code, message) in
            AppUtility.hideProgress(nil)
            
        }
        
    }
    
    
    
    
    func checkActivityStore(params: [String:Any]){
        let URL = AppConstants.Api.activity_store
        ApiManager.checkActivityStore(params: params, methodTyPe: .post, url: URL, completion: { [self] (success,message) in
            AppUtility.hideProgress(nil)
            if message == "Success"{
                self.ActivityStoreDelegate?.proceedToDashboard()
            }
            if message == "Fail"{
                AppUtility.showAlertWithProperty("Alert", messageString: success)
            }
        })
        { (error, code, message) in
            if let errorMessage = message {
                AppUtility.showAlertWithProperty("Alert", messageString: errorMessage)
            }
        }
    }
    
    
    
    
    func updateVesionApp() {
        let param:[String : Any] = ["access_token": ""]
        let params:[String : Any] = ["id": "82F85DB43CBF6", "method":"ripaPlatformVersions", "params":param,"jsonrpc": "2.0"]
        updateVesion(params: params)
    }
    
    
    func updateVesion(params: [String:Any]) {
        // AppUtility.showProgress(nil, title: "Checking...")
        var URL:String?
        
        URL = AppConstants.Api.updateVersion
        
        ApiManager.updateIOSVersion(params: params, methodTyPe: .post, url: URL!, completion: {  (success) in
            // AppUtility.hideProgress(nil)
            if success == true{
                let data =  DataManager.shared.versionUpdate
                let result = data?.result
                
                print(result!.ios_verion!)
                let version = Double(result!.ios_verion!)
                let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
                var versionnew : Double = 1.0
                if let versin =  (appVersion as NSString?)?.doubleValue{
                    versionnew = versin
                }
                if version ?? 1.0 > versionnew{
                    let refreshAlert = UIAlertController.init(title: "Update Available", message: "A new version of ticketPRO RIPA STOP is available. If you have access to the App Store, select the Update Now button below. Otherwise, contact your IT Administrator to get the update.", preferredStyle: .alert)
                    refreshAlert.addAction(UIAlertAction(title: "Update Now", style: .default, handler: { (action: UIAlertAction!) in
                        if let url = NSURL(string:"https://apps.apple.com/in/app/ripa-stop/id1567247543") {
                            UIApplication.shared.open(url as URL)
                        }
                    }))
                    DispatchQueue.main.async{
                        UIApplication.topViewController()?.present(refreshAlert, animated: true, completion: nil)
                    }
                }
            }
            else {// AppUtility.showAlertWithProperty("Alert", messageString: "Something Went Wrong")
            }
        })
        
        { (error, code, message) in
            AppUtility.hideProgress(nil)
            if let errorMessage = message {
                //  AppUtility.showAlertWithProperty("Alert", messageString: errorMessage)
            }
        }
    }
    
}
