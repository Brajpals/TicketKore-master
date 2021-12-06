//
//  OTPVerificationViewController.swift
//  ticketPRO RIPA
//
//  Created by Mamta yadav on 08/01/21.
//

import UIKit
import OTPFieldView
import FirebaseAuth



class OTPVerificationViewController: UIViewController,ActivityStoreDelegate {
 
    
    
    @IBOutlet var phoneNumber: UILabel!
    @IBOutlet var timelbl: UILabel!
    @IBOutlet var resendbtn: UIButton!
    @IBOutlet var mainView: UIView!
    @IBOutlet var verifyotpBtn: UIButton!
    @IBOutlet var otoHeader: UILabel!
    @IBOutlet var otpView: UIView!
    @IBOutlet weak var OTPView: OTPFieldView!
    @IBOutlet weak var topLbl: UILabel!
    @IBOutlet weak var bottomLbl: UILabel!
    
    var loginModel = LoginViewModel()
    var counter = 25
    var enteredOTP:String?
    var enrolmentID:String?
    var phoneNum:String?
    var enrollmentId: String?
    var phoneNO : String?
    var verificationMethod : String?
    var emailLogin:Bool?
    var pram:[String:Any]?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupOtpView()
        self.definesPresentationContext = true
       //  phoneNumber.text = phoneNum
        let formatted = phoneNO!.toPhoneNumber()
         phoneNumber.text = "+1 " + formatted
        emailLogin = false
        if phoneNO!.hasSpecialCharactersforMail(){
            phoneNumber.text = phoneNum
            topLbl.text = "We have sent a verification code to the registered email id."
            bottomLbl.text = "Please enter the otp sent to email id."
            emailLogin = true
        }
        self.navigationController?.isNavigationBarHidden = true
         resendbtn.isHidden = true
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
        verifyotpBtn.disablebutton()
     }
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    if AppConstants.theme == "1"{
        overrideUserInterfaceStyle = .dark
        }
    else{
       overrideUserInterfaceStyle = .light
        AppConstants.theme = "0"
     }
        }
    
    
    override func viewDidAppear(_ animated: Bool) {
        setGradientBackground()
        //disableButton()
        verifyotpBtn.layer.cornerRadius = 5
        
     }
    
    func setGradientBackground() {
//        self.mainView.backgroundlayer()
//        self.submitbtn.testGradientButton()
    }
    
    
    func disableButton() {
        changeDefaultButtonBackground(Button: verifyotpBtn)
        verifyotpBtn.disablebutton()
    }
    
    
    func setupOtpView(){
        // otoHeader.clipsToBounds = true
        // otoHeader.layer.cornerRadius = 10
        // otoHeader.layer.borderWidth = 0
        // verifyotpBtn.testGradientButton()
        self.OTPView.delegate = self
        self.mainView.backgroundColor = UIColor.white
        otpView.clipsToBounds = true
        otpView.layer.cornerRadius = 20
        otpView.layer.borderWidth = 0
        otpView.layer.borderColor = UIColor.clear.cgColor
        self.OTPView.fieldsCount = 6
        self.OTPView.fieldBorderWidth = 2
        self.OTPView.defaultBorderColor = UIColor.white
        self.OTPView.filledBorderColor = UIColor.systemOrange
        
        self.OTPView.defaultBackgroundColor = #colorLiteral(red: 0.8655695319, green: 0.6162135601, blue: 0, alpha: 1)
        self.OTPView.cursorColor = UIColor.black
        self.OTPView.displayType = .underlinedBottom
        self.OTPView.fieldSize = 40
        self.OTPView.separatorSpace = 8
        self.OTPView.shouldAllowIntermediateEditing = false
        self.OTPView.initializeUI()
     }
    
    
    @IBAction func close(_ sender: UIButton) {
          self.presentingViewController?.dismiss(animated: true, completion:nil)
  }
    
    
    
    @objc func updateCounter() {
         if counter >= 0 {
             timelbl.text =  String(counter) + "s"
             if counter == 0{
                timelbl.isHidden = true
                resendbtn.isHidden = false
            }
             else{
                resendbtn.isHidden = true
                timelbl.isHidden = false
             }
            counter -= 1
          }
    }
    
    
 
 
    @IBAction func verifyOtp(_ sender: Any) {
        submitOTP()
         }
    
    
    @IBAction func resendOTP(_ sender: Any) {
        if emailLogin == false{
        AppUtility.showProgress(title: nil)
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNum!, uiDelegate: nil)
        { (verificationID, error) in
            AppUtility.hideProgress()
            if let error = error {
                AppUtility.showAlertWithProperty("Alert", messageString: error.localizedDescription)
                return
            }
            UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
            self.resendAlert()
           }
        }
        else{
            loginModel.getOtpWith(params: pram!, loginType: "email")
             resendAlert()
        }
     }
    
    
    func resendAlert(){
        AppUtility.showAlertWithProperty("Alert", messageString: "OTP sent to your mobile number/email id")
         self.counter = 25
        self.updateCounter()
    }
    
    
    func submitOTP(){
        AppUtility.showProgress(title: nil)
        
         let verificationID = UserDefaults.standard.string(forKey: "authVerificationID")
        if enteredOTP?.count != 6{
            AppUtility.showAlertWithProperty("Alert", messageString: "Incorrect OTP")
            AppUtility.hideProgress()
            return
        }
        
        if emailLogin == false{
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID!,
            verificationCode: enteredOTP!)
        
        Auth.auth().signIn(with: credential) { (authResult, error) in
           
          if let error = error {
            AppUtility.hideProgress()
            let authError = error as NSError
            if ( authError.code == AuthErrorCode.secondFactorRequired.rawValue) {
             } else {
                if authError.code == 17044 {
                    AppUtility.showAlertWithProperty("Incorrect OTP", messageString: "Incorrect code entered.")
                }
                else{
                AppUtility.showAlertWithProperty("Alert", messageString: (error.localizedDescription))
                }
               return
            }
             return
          }
            self.callActivityStoreApi()
          }
        }
        else{
            AppUtility.hideProgress()
            loginModel.ActivityStoreDelegate = self
            loginModel.checkEmailOtp(otp: enteredOTP!)
            
//            let otp:String = String((AppManager.getLastSavedLoginDetails()?.result!.otp)!)
//            if  otp == enteredOTP{
//                callActivityStoreApi()
//            }
//            else{
//                AppUtility.showAlertWithProperty("Incorrect OTP", messageString: "Incorrect code entered.")
//             }
        }
    }
    
    
    func callActivityStoreApi(){
        print("login Success")
        AppUtility.showProgress(title: nil)
        self.loginModel.ActivityStoreDelegate = self
        self.loginModel.setActivityPram()
    }
    
    
    func proceedToDashboard() {
        AppManager.login()
        UIApplication.shared.registerForRemoteNotifications()
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "UserSettingsViewController") as! UserSettingsViewController
        let navigationController = UINavigationController(rootViewController: nextViewController)
        UIApplication.shared.windows.first?.rootViewController = navigationController
        UIApplication.shared.windows.first?.makeKeyAndVisible()
  
    }
 }



extension OTPVerificationViewController: OTPFieldViewDelegate {
    func hasEnteredAllOTP(hasEnteredAll hasEntered: Bool) -> Bool {
        print("Has entered all OTP? \(hasEntered)")
         verifyotpBtn.isEnabled = hasEntered
        if hasEntered == false{
              disableButton()
          }else {
              self.verifyotpBtn.orangeGradientButton()
          }
           return false
    }
    
    func shouldBecomeFirstResponderForOTP(otpTextFieldIndex index: Int) -> Bool {
        return true
    }
    
    func enteredOTP(otp otpString: String) {
        print("OTPString: \(otpString)")
        enteredOTP = otpString
        changeDefaultButtonBackground(Button: verifyotpBtn)
     }
    
    func changeDefaultButtonBackground (Button: UIButton) {
         //Button.layer.sublayers?.remove(at: 0)
         if let layer = Button.layer.sublayers? .first {
            print ("Button.layer.sublayers:", Button.layer.sublayers as Any)
             layer.removeFromSuperlayer ()
         }
     }
    
 }
