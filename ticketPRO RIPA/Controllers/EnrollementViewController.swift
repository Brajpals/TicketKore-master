//
//  EnrollementViewController.swift
//  ticketPRO RIPA
//
//  Created by Mamta yadav on 08/01/21.
//

import UIKit
import Foundation
import FirebaseAuth
import Firebase
import IQKeyboardManagerSwift
import SafariServices
import LocalAuthentication



class EnrollementViewController: UIViewController ,UITextViewDelegate, UITextFieldDelegate,LoginOTPViewModelDelegate, ActivityStoreDelegate
{
    
    @IBOutlet weak var phoneTxtDeleteBtn: UIButton!
    @IBOutlet weak var userIdDeleteBtn: UIButton!
    @IBOutlet weak var enrollTxtDeleteBtn: UIButton!
    @IBOutlet weak var passDeleteBtn: UIButton!
    
    @IBOutlet weak var enrollmentTxt: UITextField!
    @IBOutlet weak var phoneTxt: UITextField!
    // @IBOutlet weak var submit: UIButton!
    @IBOutlet weak var logoView: UIView!
    @IBOutlet var phoneView: UIView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var userIDView: UIView!
    @IBOutlet weak var userTxt: UITextField!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet weak var codeTxt: UITextField!
    @IBOutlet weak var enrollmentView: UIView!
    @IBOutlet weak var numberView: UIView!
    @IBOutlet weak var `switch`: UISwitch!
    @IBOutlet weak var switchView: UIView!
    
    @IBOutlet weak var signinBtn: UIButton!
    @IBOutlet weak var signinLblTxt: UILabel!
    @IBOutlet weak var enrollTopLbl: UILabel!
    @IBOutlet weak var enrollLbl: UILabel!
    
    @IBOutlet weak var privacyLbl: UILabel!
    @IBOutlet weak var ptivacyBtn: UIButton!
    
    @IBOutlet var submitbtn: UIButton!
    @IBOutlet var enrollView: UIView!
    @IBOutlet weak var versionLbl: UILabel!
    
    
    @IBOutlet weak var withView: UIView!
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var passTxt: UITextField!
    @IBOutlet weak var passSwitchView: UIView!
    @IBOutlet weak var passSwitch: UISwitch!
    
    
    var validation = Validation()
    var loginModel = LoginViewModel()
    var dashboardViewModel = DashboardViewModel()
    var isSignin:Bool?
    var loginType = ""
    var pram:[String:Any]?
    
    var UserdDefault = UserDefaults.standard
    let db = SqliteDbStore()
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        super.prepare(for: segue, sender: sender)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        enrollmentTxt.delegate = self
        phoneTxt.delegate = self
        userTxt.delegate = self
        isSignin = true
        
        userTxt.keyboardType = UIKeyboardType.numbersAndPunctuation
        
        phoneView.layer.cornerRadius = 5
        enrollView.layer.cornerRadius = 5
        submitbtn.layer.cornerRadius = 5
        
        versionLbl.text = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        
        enrollTxtDeleteBtn.isHidden = true
        phoneTxtDeleteBtn.isHidden = true
        userIdDeleteBtn.isHidden = true
        passDeleteBtn.isHidden = true
        
        showSignin()
        setPassSwitchColor()
 
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let login = UserDefaults.standard.integer(forKey: "isLoggedIn")
        if (login == 1){
            let story = UIStoryboard(name: "Main", bundle:nil)
            let vc = story.instantiateViewController(withIdentifier: "DashBoardViewController") as! DashBoardViewController
            let rootVC = UINavigationController(rootViewController: vc)
            UIApplication.shared.windows.first?.rootViewController = rootVC
            UIApplication.shared.windows.first?.makeKeyAndVisible()
 
            UIApplication.shared.registerForRemoteNotifications()
        }
        else{
            UIApplication.shared.unregisterForRemoteNotifications()
            if  UserDefaults.standard.bool(forKey: "BiometricSet") == true && AppConstants.bioLogin == "0"{
             authenticateUser()
          }
        }
        
        let yourAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "BlackWhite") ,NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 17)]
        
        let yourAttributes2 = [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.2343381047, green: 0.5642583966, blue: 0.8001195788, alpha: 1) ,NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 17)] as [NSAttributedString.Key : Any]
        
        let attributedString = NSMutableAttributedString(string: "By signing in, I agree to",attributes: yourAttributes)
        let attributedString1 = NSMutableAttributedString(string: " Privacy Policy ",attributes: yourAttributes2)
        
        attributedString.append(attributedString1)
        
        privacyLbl.attributedText = attributedString
        
        if self.traitCollection.userInterfaceStyle == .dark {
            AppConstants.theme = "1"
        }
        else{
            AppConstants.theme = "0"
        }
        
        if ((UserdDefault.value(forKey:"theme") as? String) != nil){
            AppConstants.theme = UserdDefault.value(forKey:"theme") as? String ?? ""
        }
        
        if AppConstants.theme == "1"{
            overrideUserInterfaceStyle = .dark
        }
        else{
            if AppConstants.theme != "0"{
                overrideUserInterfaceStyle = .light
                AppConstants.theme = "0"
            }
        }
    }
    
    
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        UIApplication.shared.open(URL)
        return false
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        setGradientBackground()
        loginModel.updateVesionApp()
        
    }
    
    
    func setGradientBackground() {
        //self.mainView.backgroundlayer()
        self.submitbtn.orangeGradientButton()
    }
    
    
    
    
    @IBAction func openPrivacyLink(_ sender: Any) {
        let url = URL(string: "https://tpripa.ticketproweb.com/assets/privacypolicy.html")
        let vc = SFSafariViewController(url: url!)
        present(vc, animated: true, completion: nil)
    }
    
    
    
    @IBAction func actionSwitchTap(_ sender: UISwitch!) {
        if (sender.isOn == true){
            userIDView.isHidden = true
            userIdDeleteBtn.isHidden = true
            numberView.isHidden = false
            userTxt.text = ""
            phoneTxt.becomeFirstResponder()
        }
        else{
            userIDView.isHidden = false
            numberView.isHidden = true
            userIdDeleteBtn.isHidden = true
            userTxt.becomeFirstResponder()
            phoneTxt.text = ""
        }
    }
    
    
    @IBAction func actionPassSwitch(_ sender: UISwitch!) {
        passTxt.text = ""
        if (sender.isOn == true){
            passwordView.isHidden = true
        }
        else{
            passwordView.isHidden = false
            setPassSwitchColor()
        }
    }
    
    
    
    func setPassSwitchColor(){
        passSwitch.tintColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
        passSwitch.layer.cornerRadius = passSwitch.frame.height / 2.0
        passSwitch.backgroundColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
        passSwitch.clipsToBounds = true
    }
    
  
    
    
    //  var code = "+91"
    var code = "+1"
    
    func proceedToOTP(isValidLogin: Int, message: String) {
        print(loginType)
        if (passSwitch.isOn && loginType != "email") || (isSignin != true && loginType != "email") {
         var number = phoneTxt.text!
        if loginType == "rmsid"{
            number = (AppManager.getLastSavedLoginDetails()?.result?.phone)!
        }
        print(number)
        AppUtility.showProgress(title: nil)
        PhoneAuthProvider.provider().verifyPhoneNumber(code + number, uiDelegate: nil)
        { (verificationID, error) in
            AppUtility.hideProgress()
            if let error = error {
                print(error.localizedDescription)
                AppUtility.showAlertWithProperty("Alert", messageString: error.localizedDescription)
                return
            }
            UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
             self.openOTPView(numbOrEmail:number)
          }
         }
        else{
            if loginType == "email" && (passSwitch.isOn || isSignin == false){
               self.openOTPView(numbOrEmail:phoneTxt.text!)
            }
            else{
                callActivityStoreApi()
            }
        }
      }
    
    
    func callActivityStoreApi(){
        print("login Success")
        AppUtility.showProgress(title: nil)
        self.loginModel.ActivityStoreDelegate = self
        self.loginModel.setActivityPram()
    }
    
    
    func openOTPView(numbOrEmail:String){
        let otpView = self.storyboard?.instantiateViewController(withIdentifier: "OTPViewController") as! OTPVerificationViewController
        otpView.enrollmentId = self.enrollmentTxt.text!
        if loginType == "email"{
            otpView.phoneNum = numbOrEmail
        }
        else{
            otpView.phoneNum = self.code + " " + numbOrEmail
        }
        otpView.phoneNO = numbOrEmail
        otpView.pram = pram
        otpView.modalPresentationStyle = .overCurrentContext
        otpView.modalTransitionStyle = .crossDissolve
        self.present(otpView, animated: true, completion: nil)
    }
    
    
    func proceedToDashboard(){
        AppManager.login()
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "DashBoardViewController") as! DashBoardViewController
        let navigationController = UINavigationController(rootViewController: nextViewController)
        UIApplication.shared.windows.first?.rootViewController = navigationController
        UIApplication.shared.windows.first?.makeKeyAndVisible()
        UIApplication.shared.registerForRemoteNotifications()
     }
    
    
  
    
    // MARK: - Button Click
    var isEmail:Bool?
    @IBAction func submitClick(_ sender: UIButton) {
        isEmail = false
        loginModel.OTPdelegate = self
        let isCorrectId = loginModel.checkId(id: enrollmentTxt.text!)
        let isCorrectUserId = loginModel.checkUserId(id: userTxt.text!)
        var isCorrectPhone = loginModel.checkNumber(number: phoneTxt.text!)
        let isCorrectPass = loginModel.checkId(id: passTxt.text!)
        var isCorrectEmail = false
        
        if phoneTxt.text!.hasSpecialCharactersforMail(){
            isEmail = true
            isCorrectEmail = loginModel.checkEmail(email: phoneTxt.text!)
        }
        
        
        
        if isCorrectId == true{
            isCorrectPhone = loginModel.checkNumber(number: phoneTxt.text!)
        }
        if isCorrectId == true && (isCorrectPhone == true || isCorrectEmail == true) && isSignin == false{
             pram  = loginModel.setLoginParam(enrollment_id: enrollmentTxt.text!, phone: phoneTxt.text!, password: "")
            loginType = "phone"
            if isCorrectEmail == true{
                loginType = "email"
            }
            AppConstants.loginVia = phoneTxt.text!
            loginModel.getOtpWith(params: pram!, loginType: "login")
        }
        else if (isCorrectPhone == true || isCorrectEmail == true) && isSignin == true{
              pram  = loginModel.setLoginParam(enrollment_id: "", phone: phoneTxt.text!, password: "")
             if passSwitch.isOn == false{
                pram = loginModel.setLoginParam(enrollment_id: "", phone: phoneTxt.text!, password: passTxt.text!)
                if isCorrectPass == false{
                    if passTxt.text == ""{
                        AppUtility.showAlertWithProperty("Alert", messageString: "Please enter password.")
                        return
                    }
                  }
            }
            loginType = "phone"
            if isCorrectEmail == true{
                loginType = "email"
            }
            AppConstants.loginVia = phoneTxt.text!
            loginModel.getOtpWith(params: pram!, loginType: "login")
        }
        else if isCorrectUserId == true && isSignin == true{
             pram  = loginModel.setLoginParam(enrollment_id: "", phone: userTxt.text!, password: "")
            if passSwitch.isOn == false{
                pram  = loginModel.setLoginParam(enrollment_id: "", phone: userTxt.text!, password: passTxt.text!)
                if isCorrectPass == false{
                    if passTxt.text == ""{
                        AppUtility.showAlertWithProperty("Alert", messageString: "Please enter password.")
                        return
                    }
                 }
            }
            loginType = "rmsid"
            AppConstants.loginVia = userTxt.text!
            loginModel.getOtpWith(params: pram!, loginType: "login")
            
        }
        else{
            if enrollmentTxt.text == "" && isSignin! != true{
                AppUtility.showAlertWithProperty("Alert", messageString: "Please enter Enrollment id.")
            }
            else if phoneTxt.text == "" && isSignin! != true{
                AppUtility.showAlertWithProperty("Alert", messageString: "Please enter Phone Number.")
            }
            
            else if userTxt.text == "" && isSignin! == true && `switch`.isOn == false{
                AppUtility.showAlertWithProperty("Alert", messageString: "Please enter User Id.")
            }
            
            else if ((userTxt.text?.isEmpty) == nil && isSignin! == true  && `switch`.isOn == false){
                AppUtility.showAlertWithProperty("Alert", messageString: "Please enter User Id.")
            }
            
            else if (userTxt.text!.count < 3 || userTxt.text!.count > 8) && isSignin! == true && `switch`.isOn == false {
                if (userTxt.text!.count < 3 || userTxt.text!.count > 8){
                    AppUtility.showAlertWithProperty("Alert", messageString: "User ID length should be 3 to 8 characters.")
                }
               else{
                    AppUtility.showAlertWithProperty("Alert", messageString: "Please enter valid user ID")
                 }
            }
            else if phoneTxt.text == "" && (`switch`.isOn == true || isSignin! != true){
                AppUtility.showAlertWithProperty("Alert", messageString: "Please enter Phone Number.")
            }
            
            else if (isCorrectPhone == false || isCorrectEmail == false) && (`switch`.isOn == true || isSignin! != true){
                if isEmail == true{
                    AppUtility.showAlertWithProperty("Alert", messageString: "Please enter valid e-mail address")
                }else{
                AppUtility.showAlertWithProperty("Alert", messageString: "Please enter valid number")
                }
            }
            
            else if isCorrectId == false  && isSignin! == false{
                AppUtility.showAlertWithProperty("Alert", messageString: "Please enter valid enrollment id.")
            }
            else if isCorrectUserId == false && isSignin! != false{
                AppUtility.showAlertWithProperty("Alert", messageString: "Please enter valid user id.")
            }
        }
    }
    
    
    
    @IBAction func actionSignin(_ sender: Any) {
        isSignin = !isSignin!
        phoneTxt.text = ""
        
        if isSignin!{
            showSignin()
        }
        else{
            enrollTopLbl.text = "Enroll Now"
            enrollLbl.text = "Enter enrollment info below and submit"
            signinBtn.setTitle("Sign In", for: .normal)
            signinLblTxt.text = "Already Enrolled?"
            enrollmentView.isHidden = false
            numberView.isHidden = false
            userIDView.isHidden = true
            switchView.isHidden = true
            withView.isHidden = true
            passwordView.isHidden = true
            passSwitchView.isHidden = true
            userIdDeleteBtn.isHidden = true
            phoneTxt.text = ""
            userTxt.text = ""
            passTxt.text = ""
            enrollmentTxt.becomeFirstResponder()
        }
    }
    
    
    
    func showSignin() {
        enrollTopLbl.text = "Sign In"
        enrollLbl.text = "Please Sign In to access your account"
        signinBtn.setTitle("Enroll Now", for: .normal)
        signinLblTxt.text = "Not enrolled yet?"
        enrollmentView.isHidden = true
        enrollmentTxt.text = ""
        userIDView.isHidden = false
        userIdDeleteBtn.isHidden = true
        switchView.isHidden = false
        withView.isHidden = false
        passwordView.isHidden = false
        passSwitchView.isHidden = false
        `switch`.isOn = false
        passSwitch.isOn = false
        numberView.isHidden = true
        `switch`.tintColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
        `switch`.layer.cornerRadius = `switch`.frame.height / 2.0
        `switch`.backgroundColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
        `switch`.clipsToBounds = true
        userTxt.becomeFirstResponder()
    }
    
    
    @IBAction func enrollmentDeleteAction(_ sender: Any) {
        enrollmentTxt.text = ""
        enrollTxtDeleteBtn.isHidden = true
    }
    
    @IBAction func phoneTxtDeleteAction(_ sender: Any) {
        phoneTxt.text = ""
        phoneTxtDeleteBtn.isHidden = true
    }
    
    @IBAction func userIdDeleteAction(_ sender: Any) {
        userTxt.text = ""
        userIdDeleteBtn.isHidden = true
    }
    
    @IBAction func passDltAction(_ sender: Any) {
        passTxt.text = ""
        passDeleteBtn.isHidden = true
    }
    
    
    
    @IBAction func contactUsAction(_ sender: Any) {
        let url = URL(string: "https://tpripa.ticketproweb.com/?type=mobile")
        let vc = SFSafariViewController(url: url!)
        present(vc, animated: true, completion: nil)
    }
    
    
    // MARK: - TextField Action
    
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool
    {
        enrollmentTxt.text = enrollmentTxt.text?.uppercased()
        
        if enrollmentTxt.text!.isEmpty == false {
            enrollTxtDeleteBtn.isHidden = false
        }
        else{
            enrollTxtDeleteBtn.isHidden = true
        }
        if passTxt.text!.isEmpty == false {
            passDeleteBtn.isHidden = false
        }
        else{
            passDeleteBtn.isHidden = true
        }
        if  phoneTxt.text!.isEmpty == false {
            phoneTxtDeleteBtn.isHidden = false
        }
        else
        {
            phoneTxtDeleteBtn.isHidden = true
        }
        if  userTxt.text!.isEmpty == false
        {
            userIdDeleteBtn.isHidden = false
        }
        else
        {
            userIdDeleteBtn.isHidden = true
        }
        var maxLength = 10
        var maxLenghtUser = 8
        var minLength = 4
        if(textField == enrollmentTxt)
        {
            maxLength = 8
        }
        else
        {
             maxLength = 25
        }
        
        let currentString: NSString = (textField.text!.uppercased()) as NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
        
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    
    
    
    func clearCrashData(){
        if let crashDict = (UserDefaults.standard.object(forKey: "CrashedDict") as? [String : Any]){
            if (crashDict["Key"] as! String) != ""{
                let key = crashDict["Key"] as! String
                let db = SqliteDbStore()
                db.openDatabase()
                db.deleteAllfrom(table: "ripaTempMasterTable WHERE key = \(key)")
                db.deleteAllfrom(table: "saveRipaPersonTable WHERE key = \(key)")
                db.deleteAllfrom(table: "useSaveRipaOptionsTable WHERE key = \(key)")
                UserDefaults.standard.removeObject(forKey: "CrashedDict")
                UserDefaults.standard.synchronize()
            }
        }
    }
    
    
    
    
    func authenticateUser() {
        UserDefaults.standard.set(true , forKey: "Launched")
        let context = LAContext()
        var error: NSError?
        var type = "Face Id"
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            
            if #available(iOS 11.0, *) {
                if (context.biometryType == LABiometryType.faceID) {
                    type = "FaceId"
                    print("FaceId support")
                    //dashbord.proceedToDashboard()
                } else if (context.biometryType == LABiometryType.touchID) {
                    type = "TouchId"
                    print("TouchId support")
                } else {
                    print("No Biometric support")
                }
            } else {
                // Fallback on earlier versions
            }
            let reason = "Enter passcode to identify yourself!"
            
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) {
                [unowned self] success, authenticationError in
                
                DispatchQueue.main.async {
                    if success{
                        proceedToDashboard()
                        AppConstants.bioLogin = "1"
                       }
                    else {
                        print("wewer")
                        //authenticateUser()
                     }
                }
            }
        } else {
            let reason:String = "Enter phone passcode to login.";
 
            if (error?.code == -8 && UserDefaults.standard.bool(forKey: "BiometricSet") == true) || (error?.code == -6 && UserDefaults.standard.bool(forKey: "BiometricSet") == true){
               // biometricSwitch.isOn = true
                context.evaluatePolicy(LAPolicy.deviceOwnerAuthentication,
                                       localizedReason: reason,
                                       reply: { [self] (success, error) in
                                        DispatchQueue.main.async {
                                        if success {
                                            proceedToDashboard()
                                            AppConstants.bioLogin = "1"
                                         }
                                        else{
                                            print("wewer")
                                         }
                                        }
                })
            }
            else if UserDefaults.standard.bool(forKey: "BiometricSet") == true{
                print("wewer")
            }
        }
    }
    
    
    
    
}







