
import UIKit
import ObjectMapper
import Firebase
import FirebaseMessaging


class AppManager {
    
    class func saveLoginDetails() {
        if let loginDetails = DataManager.shared.loginDetails {
            UserDefaults.standard.setValue(loginDetails.toJSON(), forKey: "loginDetails")
        }
    }
    
    class func getLastSavedLoginDetails() -> LoginDetailsOTP? {
        if let loginDic = UserDefaults.standard.value(forKey: "loginDetails") as? [String:Any],let loginDetails = Mapper<LoginDetailsOTP>().map(JSON: loginDic) {
            DataManager.shared.loginDetails = loginDetails
            return loginDetails
        }
        return nil
    }
    class func saveVersionDetail() {
        if let loginDetails = DataManager.shared.versionUpdate {
            UserDefaults.standard.setValue(loginDetails.toJSON(), forKey: "versionUpdate")
        }
    }
    class func login() {
        UserDefaults.standard.setValue(1, forKey: "isLoggedIn")
    }
    
    
    class func logout() {
        
      //  DataManager.shared.loginDetails = nil
        AppConstants.bioLogin = "1"
        let defaults = UserDefaults.standard
      //  UserDefaults.standard.set(false , forKey: "BiometricSet")
      //  let db = SqliteDbStore()
      //  db.openDatabase()
     //    defaults.removeObject(forKey: "loginDetails")
        defaults.removeObject(forKey: "isLoggedIn")
        defaults.removeObject(forKey: "SavedRipa")
        defaults.removeObject(forKey: "DefaultCity")
         defaults.synchronize()
        
        UIApplication.shared.unregisterForRemoteNotifications()
     }
    
    
    class func removeData() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "SavedRipa")
        defaults.synchronize()
        AppConstants.notes = ""
        AppConstants.date = ""
        AppConstants.duration = ""
        AppConstants.time = ""
        AppConstants.address = ""
        AppConstants.city = ""
        AppConstants.isSchoolSelected = ""
        AppConstants.trafficId = ""
        
        AppConstants.call_number = ""
        AppConstants.onscene_time = ""
        AppConstants.clear_time_of_the_Offrcer = ""
        AppConstants.overall_call_clear_time = ""
        AppConstants.call_type = ""
        AppConstants.unitId = ""
        AppConstants.zone = ""
         
    }
    
    
}
