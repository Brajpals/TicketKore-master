//
//  DashBoardViewController.swift
//  ticketPRO RIPA
//


import UIKit
import CoreLocation
import LocalAuthentication


class DashBoardViewController: UIViewController,QuestionsDelegate,userSettingsDelegate,offlineDelegate, SavedListModelDelegate{
    
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
    @IBOutlet weak var versionLbl: UILabel!
    
    @IBOutlet weak var updateHeightConstrait : NSLayoutConstraint!
    @IBOutlet weak var updateLbl: UILabel!
    @IBOutlet weak var updateView: UIView!
    var savedListViewModel = SavedListViewModel()
    
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
    var isLastRipaAvailable:Bool = false
    let db = SqliteDbStore()
    var isTemplateAvailable:Bool = false
    
    var personArray: [[String: Any]] = []
    
    var dashboardViewModel = DashboardViewModel()
    var touchIdViewController = TouchIDViewController()
    var UserdDefault = UserDefaults.standard
    
    var offlinesync = OfflineSyncViewController()
    
    var userSettingArray = UserSettingModel()
    
    @IBOutlet weak var newRipaWidthConstrait : NSLayoutConstraint!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.background(background: {
            self.dashboardViewModel.setCityParam()
            self.dashboardViewModel.getCountyList()
        }, completion:{
            // when background job finished, do something in main thread
            print("background job finished")
        })
        
       // UIApplication.shared.registerForRemoteNotifications()
        savedListViewModel.savedListModelDelegate = self
        AppConstants.autoNext = true
        newRipaBtn.isExclusiveTouch = true
        saveRipaButton.isExclusiveTouch = true
        lastRipaBtn.isExclusiveTouch = true
        
        DispatchQueue.main.async {
            self.loginModel.updateVesionApp()
        }

        biometricView.isHidden = true
        if ((UserDefaults.standard.bool(forKey: "BiometricSet") == true) || (UserDefaults.standard.bool(forKey: "Launched") == false)) && AppConstants.bioLogin == "0"{
            biometricView.isHidden = false
            authenticateUser(onSwitch: false)
        }
        
        autoNextBtn.setImage(UIImage(named: AppConstants.autoNext == true ? "checked" : "unchecked"), for: .normal)
        self.navigationController?.navigationBar.isHidden = true
        
        dashboardViewModel.questiondelegate = self
        
        let lastName =  AppManager.getLastSavedLoginDetails()!.result!.last_name
        let firstName =  AppManager.getLastSavedLoginDetails()!.result!.first_name
        let userName =  AppManager.getLastSavedLoginDetails()!.result!.username
        if userName.count > 0 {
            firstname.text = "\(userName)"
        }
        else {
            firstname.text = "\(lastName) \(firstName)"
            if lastName.count > 0 && firstName.count > 0 {
                firstname.text = "\(lastName) , \(firstName)"
            }
        }
        
        gpsLocation.delegate = self
        
        DispatchQueue.main.async {
            self.gpsLocation.getGPSLocation()
        }
        
        if let userId = AppManager.getLastSavedLoginDetails()?.result?.userid,let token = AppManager.getLastSavedLoginDetails()?.result?.access_token{
            print(userId)
            print(token)
        }
    
        if let versn = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            versionLbl.text = "V\(versn)"
        }
    }
    
    @objc func appMovedToForeground() {
        loginModel.updateVesionApp()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        setGradientBackground()
        
       // AppManager.removeData()
        
        print("accesstoken " + (AppManager.getLastSavedLoginDetails()?.result?.access_token ?? ""))
        
        openUnfinished = false
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AppConstants.numberOfPerson = 0
        AppConstants.isAddPerson = false
        AppConstants.isTrafficData = false
        AppConstants.violation_type = ""
        AppConstants.travel_method = ""
        AppConstants.offenceCodes = ""
        AppConstants.isTemplate = ""
        DispatchQueue.main.async {
            if Reachability.isConnectedToNetwork(){
                let savedRipaList = self.db.getRipaTempMaster(tableName: "SELECT * FROM ripaTempMasterTable WHERE syncStatus is 0") ?? []
                if savedRipaList.count > 0 {
                    self.offlinesync.updateActvityOffline()
                }
                self.dashboardViewModel.getCount()
            }
         }
        
         if  let attribute = UserDefaults.standard.object(forKey: "physical_attribute") as? String,attribute == "9999" {
             UserDefaults.standard.set(true, forKey: "isTraini")
         }
      
        let ethinicity = AppManager.getLastSavedLoginDetails()?.result?.Ethnicity
        let gender = AppManager.getLastSavedLoginDetails()?.result?.Gender
        let isVisible = AppManager.getLastSavedLoginDetails()?.result?.is_visible
        UserDefaults.standard.set(isVisible, forKey: "isVisible")
    
        //if isVisible == 1 && ethinicity?.count == 0 {
        if ethinicity?.count == 0 {
            self.setGenderEthencity()
        }
        else {
            
            
            print("view will appear")
            self.view.snapshotView(afterScreenUpdates: true)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
            let dateInFormat = dateFormatter.string(from: NSDate() as Date)
            dateLbl.text = dateInFormat
            AppConstants.autoNext = true
            
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
        }
        
    }
    
    func setGenderEthencity() {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "GenderEthencityViewController") as! GenderEthencityViewController
        let navigationController = UINavigationController(rootViewController: nextViewController)
        UIApplication.shared.windows.first?.rootViewController = navigationController
        UIApplication.shared.windows.first?.makeKeyAndVisible()
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    
    @IBAction func action_RefreshDataButton(_ sender: Any) {
       // self.viewWillAppear(true)
        AppUtility.showProgress(nil, title: nil)
        self.dashboardViewModel.forListRefresh = true
        self.dashboardViewModel.setCityParam()
        self.dashboardViewModel.getCountyList()
        self.dashboardViewModel.getCount()
        self.setCount()
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
        
        setGradientBackground()
    }
    
    func setCount(){
        let userId =  "AND userid is " + (AppManager.getLastSavedLoginDetails()?.result?.userid)!
        let statusEditReq = "\"Edit Required\""
        let pendingReview = "\"Pending Review\""
      //  let approved = "\"Approved\""
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
            AppManager.removeData()
            AppUtility.writeToDocumentsFile(fileName: "EditRequired", value: "Edit Required From Dashboard.")
            openSaveRipa()
        }
    }
    
    @IBAction func pendingReviewApplication(_ sender: Any) {
        if pendingCount.text != "0"{
            filterFor = "Pending Review"
            AppManager.removeData()
            AppUtility.writeToDocumentsFile(fileName: "PendingReview", value: "Pending Review From Dashboard.")
            openSaveRipa()
        }
    }
    
    @IBAction func approvedApplication(_ sender: Any) {
        if approvedCount.text != "0"{
            filterFor = "Approved"
            AppManager.removeData()
            AppUtility.writeToDocumentsFile(fileName: "CreatedSaved", value: "Created Saved From Dashboard.")
            openSaveRipa()
        }
    }
    
    
    func openSaveRipa(){
        let fileCheck = AppUtility.readFromDocumentsFile(fileName: "PendingReview")
        print(fileCheck)
        nextViewType = "UseSaveRipa"
       
        checkAndGetQuest()
        dashboardViewModel.getTrafficPram()
    }
    
    @IBAction func btnPressed(_ sender: UIButton) {
         var isStart : Bool = false
        isStart = self.checkDate(stringDate: AppConstants.RipaActivedate)
        if AppConstants.RipaActivedate.count == 0 {
            AppManager.removeData()
            demo(tag:sender.tag)
        }
         else if !isStart && sender.tag != 2{
               let alert = UIAlertController(title: nil, message: "This application is not available until  \(AppConstants.RipaActivedate).", preferredStyle: UIAlertController.Style.alert)
               alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
                    
                  })
               )
               self.present(alert, animated: true, completion: nil)
           }
        else {
            AppManager.removeData()
            demo(tag:sender.tag)
        }
//        AppManager.removeData()
//        demo(tag:sender.tag)
        
     }
    
    
    func demo(tag:Int){
         dashboardViewModel.questiondelegate = self
        AppConstants.numberOfPerson = 0
        if  tag == 1{
            print(tag)
          //AppUtility.writeToDocumentsFile(fileName: "StartNewRipa", value: "Start New Ripa From Dashboard.")
            nextViewType = "StartNewRipa"
            dashboardViewModel.getNewRipa()
            dashboardViewModel.setKey()
            AppConstants.citation = ""
            AppConstants.reason_for_stop = ""
            AppConstants.applicationtime = "0"
            AppConstants.street = ""
            AppConstants.block = ""
            AppConstants.firstIntersection = ""
            AppConstants.secondIntersection = ""
            AppConstants.highway = ""
            AppConstants.closestHighway = ""
            AppConstants.LocTypeDescription = ""
        }
        else if tag == 2{
            print(tag)
            filterFor = ""
         //AppUtility.writeToDocumentsFile(fileName: "MyRipa", value: "My Ripa From Dashboard.")
            openSaveRipa()
        }
        else if tag == 3{
            if isLastRipaAvailable {
                print(tag)
                nextViewType = "UseLastRipa"
                AppConstants.status = "LastRipa"
             // AppUtility.writeToDocumentsFile(fileName: "UseLastRipa", value: "User Last Ripa From Dashboard.")
                self.performSegue(withIdentifier: "ShowRipaView", sender: self)
                checkData()
            }
        }
        else if tag == 4{
            if isTemplateAvailable {
                nextViewType = "Template"
                AppConstants.street = ""
                AppConstants.block = ""
                AppConstants.firstIntersection = ""
                AppConstants.secondIntersection = ""
                AppConstants.highway = ""
                AppConstants.closestHighway = ""
                AppConstants.LocTypeDescription = ""
                AppConstants.status = "Template"
             
                if let activityId = UserDefaults.standard.object(forKey: "templateId") as? String{
                    savedListViewModel.getApprovedOrPendingPram(activityId:activityId)
                }
                //"templateId"
               // self.performSegue(withIdentifier: "ShowRipaView", sender: self)
                checkData()
            }
        }
    }
    
    func proceedToPreviewScreen(previewPram: [RipaPerson], forTemplate: Bool? , locationOptionArray : [Questionoptions1]) {
        personArray = savedListViewModel.createPersonDict(personarray:previewPram, locArr: locationOptionArray)
        AppConstants.numberOfPerson = 0
         let arr = personArray
        print(arr)
        //self.setConstants ()
           let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "NewRipaViewController") as! NewRipaViewController
        vc.viewType = "UseSaveRipa"
        vc.saveRipaStatus = "Saved"
         vc.screenType = "UseLastRipa"
         vc.isPendingEdit = true
        vc.ripaTypeStr = "Edit"
        AppConstants.isTemplate = "temp"
        vc.locArray = locationOptionArray
        vc.isEditRequired = false
        vc.personArray = personArray
        AppConstants.numberOfPerson = personArray.count
            // vc.savedRipaList = savedRipaList
           self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func proceedToRejectedView(applicationData: RejectedApplication?) {
        
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
       
       // self.newRipaBtn.orangeGradientButton()
        
        db.openDatabase()
      
        if isLastRipaAvailable{
            changeDefaultButtonBackground(Button: saveRipaButton)
            lastRipaBtn.backgroundColor = UIColor(red: 52.0 / 255.0, green: 144.0 / 255.0, blue: 202.0 / 255.0, alpha: 1.0)
            lastRipaBtn.setTitle("Use Last RIPA", for: .normal)
        }
        else{
           // lastRipaBtn.disablebutton()
            lastRipaBtn.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        }
        
        if isTemplateAvailable{
            changeDefaultButtonBackground(Button: templateBtn)
            templateBtn.backgroundColor = UIColor(red: 52.0 / 255.0, green: 144.0 / 255.0, blue: 202.0 / 255.0, alpha: 1.0)
            templateBtn.setTitle("Use Template", for: .normal)
        }
        else{
           // templateBtn.disablebutton()
            templateBtn.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
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
        print(master[0].key)
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
    
    func syncOfflineDataCompleted() {
        //self.dashboardViewModel.getCount()
        self.logout()
    }
    
    @IBAction func logout(_ sender: Any) {
        db.openDatabase()
        let savedRipaList = db.getRipaTempMaster(tableName: "SELECT * FROM ripaTempMasterTable WHERE syncStatus is 0") ?? []
        if savedRipaList.count > 0 {
            DispatchQueue.main.async {
                if Reachability.isConnectedToNetwork(){
                    self.offlinesync.delegate = self
                    self.offlinesync.updateActvityOffline()
                }
                else {
                    AppUtility.showAlertWithProperty("", messageString: "Internet Connection not Available!")
                }
            }
        }
        else{
            self.logout()
        }
    }
    
    
    func logout(){
        let alert = UIAlertController(title: nil, message: "Logging out will require you to login the app next time you restart the app. Continue?", preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Logout", style: UIAlertAction.Style.default, handler: { action in
            AppManager.logout()
            UserDefaults.standard.set("", forKey: "userOption")
            UserDefaults.standard.set("", forKey: "supervisorId")
            UserDefaults.standard.set("", forKey: "physical_attribute")
            self.db.openDatabase()
            self.db.deleteAllfrom(table: "ripaTempMasterTable")
           
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
                        self.biometricView.isHidden = true
                        //  biometricSwitch.isOn = true
                        
                        if onSwitch == true && self.biometricSwitch.isOn != true{
                            UserDefaults.standard.set(false , forKey: "BiometricSet")
                        }
                        else if onSwitch == false{
                            self.biometricSwitch.isOn = true
                        }
                    }
                    else {
                        if UserDefaults.standard.bool(forKey: "BiometricSet") == true{
                            if onSwitch == false{
                                self.showAuthAlert()
                                self.biometricView.isHidden = false
                            }
                            self.biometricSwitch.isOn = true
                        }
                        else{
                            print("not")
                            let boolValue = false
                            UserDefaults.standard.set(boolValue , forKey: "BiometricSet")
                            self.biometricSwitch.isOn = false
                            self.biometricView.isHidden = true
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
                            self.biometricView.isHidden = true
                        }
                        else{
                            self.showAuthAlert()
                            self.biometricView.isHidden = false
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
            self.biometricSwitch.isOn = false
          /*  let context = LAContext()
            let reason:String = "Enter phone passcode to login.";
            context.evaluatePolicy(LAPolicy.deviceOwnerAuthentication,
                                   localizedReason: reason,
                                   reply: { [self] (success, error) in
                DispatchQueue.main.async {
                    if success {
                        self.biometricView.isHidden = true
                        UserDefaults.standard.set(switchOn , forKey: "BiometricSet")
                        self.biometricSwitch.isOn = switchOn
                    }
                    else{
                        self.showAuthAlert()
                        self.biometricView.isHidden = false
                    }
                }
            }) */
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
    
    func checkDate(stringDate : String) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if let date = dateFormatter.date(from: stringDate) {
            if date.isInThePast {
                print("Date is past")
                return true
            } else if date.isInToday {
                print("Date is today")
                return true
            } else {
                print("Date is future")
                return false
            }
        }
        return false
    }
    
}


extension DashBoardViewController:GPSLocationDelegate{
    
    
    func fetchedLocationDetails(location: CLLocation, countryCode: String, city: String, street: String, intersection: String, county: String) {
        print(location,countryCode,city)
        let latflt =  Float(String(location.coordinate.latitude))
        let longflt =  Float(String(location.coordinate.longitude))
        AppConstants.lati = String(format: "%.3f", latflt!)
        AppConstants.longi = String(format: "%.3f", longflt!)
         UserDefaults.standard.set(String(format: "%.3f", latflt!), forKey: "latitude")
         UserDefaults.standard.set(String(format: "%.3f", longflt!), forKey: "longitude")
        UserDefaults.standard.set(String(location.coordinate.latitude), forKey: "latitude")
        UserDefaults.standard.set(String(location.coordinate.longitude), forKey: "longitude")
    }
    
    func failedFetchingLocationDetails(error: Error) {
        print(error)
    }
    
}

extension Date {
    static var noon: Date { Date().noon }
    var noon: Date { Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)! }
    var isInToday: Bool { Calendar.current.isDateInToday(self) }
    var isInThePast: Bool { noon < .noon }
    var isInTheFuture: Bool { noon > .noon }
}
