//
//  DashBoardViewController.swift
//  ticketPRO RIPA
//


import UIKit
import CoreLocation
import LocalAuthentication


class DashBoardViewController: UIViewController,QuestionsDelegate,userSettingsDelegate{
    
    @IBOutlet var mainView: UIView!
    @IBOutlet var firstname: UILabel!
    @IBOutlet weak var mainViewBtn: UIView!
    @IBOutlet var newRipaBtn: UIButton!
    @IBOutlet var saveRipaButton: UIButton!
    @IBOutlet var lastRipaBtn: UIButton!
    @IBOutlet weak var autoNextBtn: UIButton!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var themeSwitch: UISwitch!
    @IBOutlet weak var editCount: UILabel!
    @IBOutlet weak var pendingCount: UILabel!
    @IBOutlet weak var approvedCount: UILabel!
    @IBOutlet weak var biometricView: UIView!
    @IBOutlet weak var biometricSwitch: UISwitch!
    @IBOutlet weak var templateBtn: UIButton!
    @IBOutlet var optionTypeLbl : UILabel!
    @IBOutlet var userInfoBtn: UIButton!
    
    //    @IBOutlet weak var pinTxt: UITextField!
    //    @IBOutlet weak var mainPinView: UIView!
    
    
    var isChecked: Bool = false
    var enrollmentId: String?
    var isSaveButtonAtQuizViewClicked: Bool = false
    var loginModel = LoginViewModel()
    var nextViewType:String?
    var questionsArray : [QuestionResult1]?
    
    let gpsLocation = GPSLocation()
    
    var openUnfinished:Bool?
    
    var isRipaSaved:Bool?
    var isLastRipaAvailable:Bool?
    let db = SqliteDbStore()
    var isTemplateAvailable:Bool?
    
    var personArray: [[String: Any]] = []
    
    var dashboardViewModel = DashboardViewModel()
    var touchIdViewController = TouchIDViewController()
    var UserdDefault = UserDefaults.standard
    
    var offlinesync = OfflineSyncViewController()
    
    var userSettingArray = UserSettingModel()
    
    
    @objc func appMovedToForeground() {
        loginModel.updateVesionApp()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.registerForRemoteNotifications()
      //  self.optionTypeLbl.text = userOption
        AppConstants.autoNext = true
        newRipaBtn.isExclusiveTouch = true
        saveRipaButton.isExclusiveTouch = true
        lastRipaBtn.isExclusiveTouch = true
        loginModel.updateVesionApp()
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector:#selector(appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        DispatchQueue.background(background: {
            self.offlinesync.updateActvityOffline()
        }, completion:{
            print("background job finished")
        })
        
        biometricView.isHidden = true
        if ((UserDefaults.standard.bool(forKey: "BiometricSet") == true) || (UserDefaults.standard.bool(forKey: "Launched") == false)) && AppConstants.bioLogin == "0"{
            biometricView.isHidden = false
            authenticateUser(onSwitch: false)
        }
        
        autoNextBtn.setImage(UIImage(named: AppConstants.autoNext == true ? "checked" : "unchecked"), for: .normal)
        self.navigationController?.navigationBar.isHidden = true
        
        DispatchQueue.background(background: {
            self.dashboardViewModel.setCityParam()
            self.dashboardViewModel.getCountyList()
        }, completion:{
            // when background job finished, do something in main thread
            print("background job finished")
        })
        
        dashboardViewModel.questiondelegate = self
        
        firstname.text = AppManager.getLastSavedLoginDetails()!.result!.first_name
        
        gpsLocation.delegate = self
        gpsLocation.getGPSLocation()
        
        if let userId = AppManager.getLastSavedLoginDetails()?.result?.userid,let token = AppManager.getLastSavedLoginDetails()?.result?.access_token{
            print(userId)
            print(token)
        }
    
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        setGradientBackground()
        
        AppManager.removeData()
        
        print("accesstoken " + (AppManager.getLastSavedLoginDetails()?.result?.access_token ?? ""))
        
        openUnfinished = false
        
    }
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if  let userOption = UserDefaults.standard.object(forKey: "userOption") as? String {
            self.optionTypeLbl.text = userOption
        }
        
        dashboardViewModel.getCount()
        
        AppManager.removeData()
        print("view will appear")
        self.view.snapshotView(afterScreenUpdates: true)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
        let dateInFormat = dateFormatter.string(from: NSDate() as Date)
        dateLbl.text = dateInFormat
        AppConstants.autoNext = true
        //loginModel.updateVesionApp()
        
        db.openDatabase()
 
        checkData()
       
        if UserdDefault.value(forKey:"theme") as? String != nil{
            AppConstants.theme = UserdDefault.value(forKey:"theme") as? String ?? ""
        }
        
        
        if AppConstants.theme == "1"{
            overrideUserInterfaceStyle = .dark
        }
        else{
            overrideUserInterfaceStyle = .light
            AppConstants.theme = "0"
        }
        
        if self.traitCollection.userInterfaceStyle == .dark {
            themeSwitch.isOn = true
            AppConstants.theme = "1"
        } else {
            themeSwitch.isOn = false
            AppConstants.theme = "0"
        }
        
        if UserDefaults.standard.bool(forKey: "BiometricSet") != true{
            biometricSwitch.isOn = false
        }
        setCount()
    }
    
    func sendSettingInfo(data : UserSettingModel){
        self.userSettingArray = data
    }
    
    func changeDefaultButtonBackground (Button: UIButton) {
        
        if let layer = Button.layer.sublayers? .first {
            if Button.layer.sublayers!.count>1{
                layer.removeFromSuperlayer ()
            }
        }
    }
    
    
    func checkData(){
        
        let userId =  "AND userid is " + (AppManager.getLastSavedLoginDetails()?.result?.userid)!
        let countForLastRipa = Int(db.checkEmptyTable(insertTableString: "ripaTempMasterTable WHERE syncStatus is 1 \(userId) order by declarationDate DESC"))
        if countForLastRipa! > 0 {
            isLastRipaAvailable = true
        }
        else{
            isLastRipaAvailable = false
        }
        
        
        let countForTemplate = Int(db.checkEmptyTable(insertTableString: "ripaTempMasterTable WHERE key is 0 \(userId)"))
        if countForTemplate! > 0 {
            isTemplateAvailable = true
        }
        else{
            isTemplateAvailable = false
        }
    }
    
    func setCount(){
        let userId =  "AND userid is " + (AppManager.getLastSavedLoginDetails()?.result?.userid)!
        let statusEditReq = "\"Edit Required\""
        let pendingReview = "\"Pending Review\""
        let approved = "\"Approved\""
        var created = "\"Created\""
        var saved = "\"Saved\""
        
        editCount.text =  db.checkEmptyTable(insertTableString: "ripaTempMasterTable WHERE status is \(statusEditReq) AND mainStatus is NOT 1 \(userId)")
        pendingCount.text =  db.checkEmptyTable(insertTableString: "ripaTempMasterTable WHERE status is \(pendingReview) AND mainStatus is NOT 1 \(userId)")
      //  approvedCount.text =  db.checkEmptyTable(insertTableString: "ripaTempMasterTable WHERE status is \(approved) AND mainStatus is NOT 1 \(userId)")
        
        created =  db.checkEmptyTable(insertTableString: "ripaTempMasterTable WHERE status is \(created) AND mainStatus is NOT 1 \(userId)")
        saved =  db.checkEmptyTable(insertTableString: "ripaTempMasterTable WHERE status is \(saved) AND mainStatus is NOT 1 \(userId)")
        
        let crCount : Int = Int(created)!
        var svCount : Int = Int(saved)!
        svCount = crCount + svCount
        
        approvedCount.text = "\(svCount)"
        
    }
    
    @IBAction func actionChangeUserInfo(_ sender: Any) {

        let vc2 = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "UserSettingsViewController") as! UserSettingsViewController
        vc2.flag = 1
        vc2.delegate = self
        self.navigationController?.pushViewController(vc2, animated: true)
    }
    
    
    @IBAction func actionSwitch(_ sender: Any) {
        if themeSwitch.isOn{
            overrideUserInterfaceStyle = .dark
            AppConstants.theme = "1"
            UserdDefault.set("1", forKey: "theme")
        }
        else{
            overrideUserInterfaceStyle = .light
            AppConstants.theme = "0"
            UserdDefault.set("0", forKey: "theme")
        }
        UserdDefault.synchronize()
    }
    
    
    @IBAction func actionBiometricSwitch(_ sender: Any) {
        authenticateUser(onSwitch: true)
    }
    
    
    
    var filterFor = ""
    
    @IBAction func editRequiredApplication(_ sender: Any) {
        if editCount.text != "0"{
            filterFor = "Edit Required"
            openSaveRipa()
        }
    }
    
    @IBAction func pendingReviewApplication(_ sender: Any) {
        if pendingCount.text != "0"{
            filterFor = "Pending Review"
            openSaveRipa()
        }
    }
    
    @IBAction func approvedApplication(_ sender: Any) {
        if approvedCount.text != "0"{
            filterFor = "Approved"
            openSaveRipa()
        }
    }
    
    func openSaveRipa(){
        nextViewType = "UseSaveRipa"
        checkAndGetQuest()
        dashboardViewModel.getTrafficPram()
    }
    
    @IBAction func btnPressed(_ sender: UIButton) {
         demo(tag:sender.tag)
     }
    
    
    func demo(tag:Int){
         dashboardViewModel.questiondelegate = self
        if  tag == 1{
            print(tag)
            nextViewType = "StartNewRipa"
            dashboardViewModel.getNewRipa()
            dashboardViewModel.setKey()
            AppConstants.citation = ""
            AppConstants.applicationtime = "0"
        }
        else if tag == 2{
            print(tag)
            filterFor = ""
            openSaveRipa()
        }
        else if tag == 3{
            if isLastRipaAvailable! {
                print(tag)
               // isTemplateAvailable = false
                nextViewType = "UseLastRipa"
                AppConstants.status = "LastRipa"
                self.performSegue(withIdentifier: "ShowRipaView", sender: self)
                checkData()
            }
        }
        else if tag == 4{
            if isTemplateAvailable! {
               // isLastRipaAvailable = false
                print(tag)
                nextViewType = "Template"
                AppConstants.status = "Template"
                self.performSegue(withIdentifier: "ShowRipaView", sender: self)
                checkData()
            }
        }
    }
    
    
    
    
    func  checkAndGetQuest(){
        dashboardViewModel.questiondelegate = self
        db.createTable(insertTableString: db.createSaveRipaPersonTable)
        let count = Int(db.checkEmptyTable(insertTableString: "QuestionTable"))
        if count! > 0 {isRipaSaved = true}else{isRipaSaved = false}
        if isRipaSaved == false {
            dashboardViewModel.getNewRipa()
        }
        else{
            //self.performSegue(withIdentifier: "ShowSavedList", sender: self)
        }
    }
    
    
    func proceedToNextScreen(questionArray:[QuestionResult1]) {
        questionsArray = questionArray
        if nextViewType == "StartNewRipa"{
            self.performSegue(withIdentifier: "ShowRipaView", sender: self)
        }
        else{
            // self.performSegue(withIdentifier: "ShowSavedList", sender: self)
        }
    }
    
    
    func proceedToSavedListScreen(){
        self.performSegue(withIdentifier: "ShowSavedList", sender: self)
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        let segueID = segue.identifier
        if(segueID! == "ShowRipaView"){
            let vc = segue.destination as! NewRipaViewController
            vc.userSettingArray = self.userSettingArray
            if nextViewType == "UseLastRipa" && isLastRipaAvailable == true{
                setLastRipaData(forData: "LastRipa")
                vc.personArray = self.personArray
                vc.viewType = "UseLastRipa"
            }
            else if nextViewType == "Template" && isTemplateAvailable == true{
                setLastRipaData(forData: "Template")
                vc.personArray = self.personArray
                vc.viewType = "Template"
            }
            else{
                if questionsArray != nil{
                    vc.questionArray = questionsArray!}
                AppConstants.status = ""
                vc.viewType = nextViewType ?? ""
                vc.saveRipaStatus = ""
                vc.personArray = self.personArray
                vc.isCrashedRipa = false
                if openUnfinished!{
                    vc.isCrashedRipa = true
                    vc.viewType = "UseSaveRipa"
                }
            }
            AppConstants.trafficId = ""
        }
        if(segueID! == "ShowSavedList"){
            let vc = segue.destination as! SavedListViewController
            vc.filterFor = self.filterFor
            
        }
        
    }
    
    
    
    func setGradientBackground() {
       
        self.newRipaBtn.orangeGradientButton()
        
        db.openDatabase()
      
        if isLastRipaAvailable!{
            changeDefaultButtonBackground(Button: saveRipaButton)
            lastRipaBtn.backgroundColor = #colorLiteral(red: 0.1937961819, green: 0.5636972401, blue: 0.8575945208, alpha: 1)
            lastRipaBtn.setTitle("Use Last RIPA", for: .normal)
        }
        else{
            lastRipaBtn.disablebutton()
        }
        
        if isTemplateAvailable!{
            changeDefaultButtonBackground(Button: templateBtn)
            templateBtn.backgroundColor = #colorLiteral(red: 0.1937961819, green: 0.5636972401, blue: 0.8575945208, alpha: 1)
            templateBtn.setTitle("Use Template", for: .normal)
        }
        else{
            templateBtn.disablebutton()
        }
    }
    
    
    
    func setLastRipaData(forData:String){
        let userId =  "AND userid is " + (AppManager.getLastSavedLoginDetails()?.result?.userid)!
        var master=[RipaTempMaster]()
        if forData == "Template"{
            master = db.getRipaTempMaster(tableName: "SELECT * FROM ripaTempMasterTable WHERE key is 0 \(userId)")!
           
        }else{
            master = db.getRipaTempMaster(tableName: "SELECT * FROM ripaTempMasterTable WHERE syncStatus is 1 \(userId) order by declarationDate DESC")!
            AppConstants.duration = master[0].stopDuration
            AppConstants.time = master[0].stopTime
            dashboardViewModel.getDatefromStopTime(date: master[0].stopDate)
         }
        
         personArray = dashboardViewModel.getUseSavedRipa(key: master[0].key)
         dashboardViewModel.setKey()
        
        AppConstants.city =  master[0].city
        AppConstants.address =  master[0].location
        AppConstants.notes = master[0].note
      
        if forData == "Template"{
        AppConstants.duration = ""
        AppConstants.time = ""
        AppConstants.date = ""
         }
    }
    
    
    func setStatusCount(countArray: [CountResult]) {
        var crCount : Int = 0
      //  var svCount : Int = 0
        for status in countArray{
            if status.statusCode == "PR"{
                pendingCount.text = status.total
            }
            if status.statusCode == "CR"{
                crCount = crCount + Int(status.total)!
            }
            if status.statusCode == "SR"{
                crCount = crCount + Int(status.total)!
            }
//            if status.statusCode == "A "{
//                approvedCount.text = status.total
//            }
            if status.statusCode == "ER"{
                editCount.text = status.total
            }
        }
        
        approvedCount.text = "\(crCount)"
        
    }
    
    
    @IBAction func checkBoxClicked(_ sender: Any) {
        // isChecked = !isChecked
        AppConstants.autoNext = !AppConstants.autoNext!
        autoNextBtn.setImage(UIImage(named: AppConstants.autoNext == true ? "checked" : "unchecked"), for: .normal)
     }
    
    
    
    
    @IBAction func logout(_ sender: Any) {
        logout()
    }
    
    
    
    func logout(){
        UserDefaults.standard.set("", forKey: "userOption")
        UserDefaults.standard.set("", forKey: "supervisorId")
        let alert = UIAlertController(title: nil, message: "Are you sure want to logout?", preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Logout", style: UIAlertAction.Style.default, handler: { action in
            AppManager.logout()
            
           
            let story = UIStoryboard(name: "Main", bundle:nil)
            let vc = story.instantiateViewController(withIdentifier: "EnrollementViewController") as! EnrollementViewController
            UIApplication.shared.windows.first?.rootViewController = vc
            UIApplication.shared.windows.first?.makeKeyAndVisible()
        }         )
        )
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    
    
    func authenticateUser(onSwitch:Bool){
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
                        let boolValue = true
                        UserDefaults.standard.set(boolValue , forKey: "BiometricSet")
                        biometricView.isHidden = true
                        //  biometricSwitch.isOn = true
                        
                        if onSwitch == true && biometricSwitch.isOn != true{
                            UserDefaults.standard.set(false , forKey: "BiometricSet")
                        }
                        else if onSwitch == false{
                            biometricSwitch.isOn = true
                        }
                    }
                    else {
                        if UserDefaults.standard.bool(forKey: "BiometricSet") == true{
                            if onSwitch == false{
                                showAuthAlert()
                                biometricView.isHidden = false
                            }
                            biometricSwitch.isOn = true
                        }
                        else{
                            print("not")
                            let boolValue = false
                            UserDefaults.standard.set(boolValue , forKey: "BiometricSet")
                            biometricSwitch.isOn = false
                            biometricView.isHidden = true
                        }
                    }
                }
            }
        } else {
            let reason:String = "Enter phone passcode to login.";
            if (error?.code == -7){
                biometricView.isHidden = true
            }
            
            if ((error?.code == -8 || error?.code == -7) && UserDefaults.standard.bool(forKey: "BiometricSet") == true) || (error?.code == -6 && UserDefaults.standard.bool(forKey: "BiometricSet") == true){
                // biometricSwitch.isOn = true
                context.evaluatePolicy(LAPolicy.deviceOwnerAuthentication,
                                       localizedReason: reason,
                                       reply: { [self] (success, error) in
                    DispatchQueue.main.async {
                        if success {
                            biometricView.isHidden = true
                        }
                        else{
                            showAuthAlert()
                            biometricView.isHidden = false
                        }
                    }
                })
            }
            // else if UserDefaults.standard.bool(forKey: "BiometricSet") == true{
            if onSwitch == true {
                goToAuthSettingAlert(type:type, switchOn: biometricSwitch.isOn)
                biometricSwitch.isOn = true
            }
            //    }
        }
    }
    
    
    
    
    
    func showAuthAlert(){
        let alertController = UIAlertController.init(title: "Please Authenticate", message: "Ripa Stop is is protected from unauthorized access. Please unlock Ripa Stop to continue.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { [self] action in
            authenticateUser(onSwitch: false)
            
        })
        )
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    
    func goToAuthSettingAlert(type:String, switchOn:Bool){
        let alertController = UIAlertController(title: "\(type) not available", message: "Please go to app settings and turn on \(type).", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:{ [self] action in
            let context = LAContext()
            let reason:String = "Enter phone passcode to login.";
            context.evaluatePolicy(LAPolicy.deviceOwnerAuthentication,
                                   localizedReason: reason,
                                   reply: { [self] (success, error) in
                DispatchQueue.main.async {
                    if success {
                        biometricView.isHidden = true
                        UserDefaults.standard.set(switchOn , forKey: "BiometricSet")
                        biometricSwitch.isOn = switchOn
                    }
                    else{
                        showAuthAlert()
                        biometricView.isHidden = false
                    }
                }
            })
        })
        )
        
        let okAction = UIAlertAction(title: "Settings", style: UIAlertAction.Style.default){
            UIAlertAction in
            NSLog("OK Pressed")
            if switchOn == true{
                self.biometricSwitch.isOn = false
            }
            self.biometricView.isHidden = true
            self.dismiss(animated: true, completion: { [self] in
                
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        print("Settings opened: \(success)") // Prints true
                    })
                }
            })
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    
}


extension DashBoardViewController:GPSLocationDelegate{
    
    
    func fetchedLocationDetails(location: CLLocation, countryCode: String, city: String, street: String, intersection: String, county: String) {
        print(location,countryCode,city)
        AppConstants.lati = String(location.coordinate.latitude)
        AppConstants.longi = String(location.coordinate.longitude)
    }
    
    func failedFetchingLocationDetails(error: Error) {
        print(error)
    }
    
    
    
}
