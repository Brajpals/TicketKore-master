//
//  TouchIDViewController.swift
//  ticketPRO RIPA
//
//  Created by Nitin on 7/6/21.
//

import UIKit
import LocalAuthentication
class TouchIDViewController: UIViewController, UITextFieldDelegate {
    var isChecked: Bool = false
    var enrollmentId: String?
    var isSaveButtonAtQuizViewClicked: Bool = false
    var loginModel = LoginViewModel()
    var nextViewType:String?
    var questionsArray : [QuestionResult1]?
    var dashbord = OTPVerificationViewController()
    let gpsLocation = GPSLocation()
    weak var questiondelegate: QuestionsDelegate?
    var openUnfinished:Bool?
    var dashbordModel = DashboardViewModel()
    var isRipaSaved:Bool?
    var isLastRipaAvailable:Bool?
    let db = SqliteDbStore()
    
    var personArray: [[String: Any]] = []
    
    var dashboardViewModel = DashboardViewModel()
    var UserdDefault = UserDefaults.standard
    
    @IBOutlet weak var enterPin: UITextField!
    
    @IBOutlet weak var ReEnterPin: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
//        enterPin.delegate = self
//        ReEnterPin.delegate = self
        // Do any additional setup after loading the view.
    }
    // MARK: - Touch id Autentication

    @IBAction func submitAction(_ sender: Any) {
        
       if enterPin.text == "" || ReEnterPin.text == "" {
            let alert = UIAlertController(title: "Alert!", message: "Please Enter Your 4 Digit Pin", preferredStyle: .alert)

        
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))

            self.present(alert, animated: true)
            
            return
           }
        else if isValidpin(testStr: enterPin.text!) == false{
            let alert = UIAlertController(title: "Alert", message: "only 4 digit allow", preferredStyle: .alert)

        
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))

            self.present(alert, animated: true)
        }
       else if enterPin.text == ReEnterPin.text
        {
            let boolValue = true
            UserDefaults.standard.set(boolValue , forKey: "yesLogin")
            UserDefaults.standard.set(enterPin.text , forKey: "savedPin")
        
        
        if UserDefaults.standard.bool(forKey: "changePin") == false
        {
            authenticateUser()
        }
        
    else
        {
            
            let boolValue = false

            UserDefaults.standard.set(boolValue , forKey: "changePin")
            self.dismiss(animated: true, completion: {
//                let vc = self.storyboard?.instantiateViewController(withIdentifier: "PasscodeAndTouchViewController")
//                self.present(vc!, animated: true, completion: nil)
                        })
        }
        
        }
        
        else
        {
            let alert = UIAlertController(title: "Alert", message: "pin not match", preferredStyle: .alert)

        
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))

            self.present(alert, animated: true)
        }
        
    }
    
    
    
    
    func authenticateUser() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            
             if #available(iOS 11.0, *) {
                if (context.biometryType == LABiometryType.faceID) {
                   // localizedReason = "Unlock using Face ID"
                    print("FaceId support")
                    //dashbord.proceedToDashboard()
                } else if (context.biometryType == LABiometryType.touchID) {
                   // localizedReason = "Unlock using Touch ID"
                    print("TouchId support")
                } else {
                    print("No Biometric support")
                }
            } else {
                // Fallback on earlier versions
            }
            let reason = "Set Your Touch Id For Identify yourself!"
                      
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
                [unowned self] success, authenticationError in

                DispatchQueue.main.async {
                    if success {
                        print("yes")
 
                     }
          else {
                  print("not")
         
                    }
                }
            }
        } else {
            let alertController = UIAlertController(title: "Touch Id/Face Id not available", message: "Your device is not configured for Touch ID/Face Id.", preferredStyle: .alert)

                // Create the actions
            let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
                    UIAlertAction in
                    NSLog("OK Pressed")
                self.dismiss(animated: true, completion: { [self] in
                  //  dashbord.proceedToDashboard()
                            })
                }
              
                // Add the actions
                alertController.addAction(okAction)
              
            UIApplication.topViewController()?.present(alertController, animated: true, completion: nil)
             // self.present(alertController, animated: true, completion: nil)
         }
    }
    
    
    
    
    
    
    
    func isValidpin(testStr:String) -> Bool {

      

              let phoneRegex = "^[0-9]{4}$";
              let valid = NSPredicate(format: "SELF MATCHES %@", phoneRegex).evaluate(with: testStr)
              return valid
          


    }
    // MARK: - Navigation
}

