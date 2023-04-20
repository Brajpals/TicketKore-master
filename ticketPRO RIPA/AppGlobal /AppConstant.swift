
import UIKit
import Firebase
import FirebaseMessaging


class MyGlobalTimer: NSObject {
    var time = 0
    
    static let sharedTimer = MyGlobalTimer()
    var internalTimer: Timer?

    func startTimer(){
        if AppConstants.ripaTimeDuration == "Y"{
         self.internalTimer = Timer.scheduledTimer(timeInterval: 1.0 /*seconds*/, target: self, selector: #selector(fireTimerAction), userInfo: nil, repeats: true)
        }
    }

    func stopTimer(){
         time = 0
        self.internalTimer?.invalidate()
    }

    @objc func fireTimerAction(sender: AnyObject?){
         time += 1
        if time == 60{
            stopTimer()
        }
    }
    
 }


struct AppConstants {
 
    static var autoNext:Bool?
    
    struct BaseURL {
         static let URL = "https://tpwebservicesdev.ticketproweb.com/public/index.php/service"
     }
 
 //Prod//'https://tpwebservices.ticketproweb.com/public/index.php/service'
 //Dev//https://tpwebservicesdev.ticketproweb.com/public/index.php/service
 //Stage//http://tpwebservicestage.ticketproweb.com/public/index.php/service
 //https://tpwebservicesdev.ticketproweb.com/public/index.php/service/genericv1
    
    struct Api {
            static let otpRequest = BaseURL.URL + "/ripav1"
            static let loginRequest = BaseURL.URL + "/user/verifyotpv1"
            static let activity_store = BaseURL.URL + "/ripav1"
            static let violations = BaseURL.URL + "/ripav1"
            static let questions = BaseURL.URL + "/ripav1"
            static let updateRipa = BaseURL.URL + "/ripav1"
            static let updateVersion = BaseURL.URL + "/ripav1"
     }
    
    static var theme:String=""
    static var notes:String=""
    static var date:String=""
    static var duration:String=""
    static var time:String=""
    static var lati:String=""
    static var longi:String=""
    static var address:String=""
    static var city:String=""
    static var isSchoolSelected:String=""
    static var schoolName:String=""
    static var isStudent:String="0"
    static var loginVia:String=""
    static var key:String=""
    static var trafficId:String=""
    static var status:String=""
    static var activityID:String=""
    static var activityStatusId:String=""
    static var bioLogin = ""
    static var citation = ""
    static var deviceid = ""
    static var applicationtime = ""
    
    static var ripaTimeDuration = ""
    static var ripaCounty = ""
    static var ripaGPS = ""
    
    static var call_number = ""
    static var onscene_time = ""
    static var clear_time_of_the_Offrcer = ""
    static var overall_call_clear_time = ""
    static var call_type = ""
    static var unitId = ""
    static var zone = ""
    static var activity_id = ""
    
    static func getDeviceToken() {
        Messaging.messaging().token { token, error in
          if let error = error {
            print("Error fetching FCM registration token: \(error)")
          } else if let token = token {
            print("FCM registration token: \(token)")
            AppConstants.deviceToken = token
            print("TOKTOKEN"+(token))
          }
        }
       
    }
    
      static var deviceToken = ""
}

