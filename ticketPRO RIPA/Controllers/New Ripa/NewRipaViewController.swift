//
//  NewRipaViewController.swift
//  ticketPRO RIPA
//
//  Created by Nitin Singh on 17/02/21.
//

import UIKit
import ObjectMapper
import SwiftyJSON
import EzPopup
import IQKeyboardManagerSwift
import Foundation
import CoreLocation
import SwiftCSVExport
import CoreLocation
import Toaster


class NewRipaViewController: UIViewController,PopupViewControllerDelegate,AddOptionDelegate,LocationDelegate, UITextFieldDelegate, UITextViewDelegate,ViolationTypeDelegate, GoToQuestion, AddDescriptionDelegate, PreviewModelDelegate, PendingQuestionDelegate,SelectOptionsPopupDelegate, ViolationPopupDelegate, NoteDelegate, SaveDelegate, UIGestureRecognizerDelegate, violDelegate,userSettingsDelegate,CLLocationManagerDelegate, LoginOTPViewModelDelegate,newRipaModelDelegate {

    
    var userSettingArray = UserSettingModel()
    var loginModel = LoginViewModel()
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var countLbl: UILabel!
    @IBOutlet weak var Back: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nextQuestBtn: UIButton!
    @IBOutlet weak var prevQuestBtn: UIButton!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var resetBtn: UIButton!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var autoNextBtn: UIButton!
    @IBOutlet weak var questionLbl: UILabel!
    @IBOutlet weak var groupLbl: UILabel!
    @IBOutlet weak var addOptionBtn: UIButton!
    @IBOutlet weak var groupView: UIView!
    @IBOutlet weak var notes: UIButton!
    @IBOutlet weak var descriptionBtn: UIButton!
    @IBOutlet weak var nextView: UIView!
    @IBOutlet weak var prevView: UIView!
    @IBOutlet weak var nemeViewHeight: NSLayoutConstraint!
    @IBOutlet weak var nameView: UIView!
    
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var timeTxtField: UITextField!
    @IBOutlet weak var durationTxtField: UITextField!
    @IBOutlet weak var personNumber: UILabel!
    @IBOutlet weak var dateTimeView: UIView!
    @IBOutlet weak var dateTimeViewHeight: NSLayoutConstraint!
    @IBOutlet weak var countyHeightConstrait: NSLayoutConstraint!
    @IBOutlet weak var grpViewHeightConstrait : NSLayoutConstraint!
    @IBOutlet weak var submitBtn: UIButton!
    
    @IBOutlet weak var requiredImgView: UIImageView!
    @IBOutlet weak var userImgView: UIImageView!
    @IBOutlet weak var dropImgView: UIImageView!
    
    @IBOutlet weak var topPrevBtn: UIButton!
    @IBOutlet weak var topNextBtn: UIButton!
    
    @IBOutlet weak var topPrevView: UIView!
    @IBOutlet weak var topNextView: UIView!
    @IBOutlet weak var saveToServerBtn: UIButton!
    @IBOutlet weak var countyLbl: UITextField!
    @IBOutlet weak var countyView: UIView!
    @IBOutlet weak var countyBtn: UIButton!
    @IBOutlet weak var addPersonBtn: UIButton!
    
    
    let defaults = UserDefaults.standard
    let gpsLocation = GPSLocation()
    
    var viewType=""
    var hiddenSections = Set<Int>()
    var questionArray : [QuestionResult1]?
    var optionsArray : [Questionoptions1]?
    var isCrashedRipa : Bool?
    var savedRipaList:RipaTempMaster?
    
    //    var cityQues:QuestionResult1?
    //    var locationQues:QuestionResult1?
    //    var schoolQues:QuestionResult1?
    var violationArray : [ViolationsResult]?
    var selectedVioArray = [ViolationsResult]()
    var educationCodeSectionArray : [EducationCodeSection]?
    var educationCodeSubSectionArray : [EducationCodeSubsection]?
    var cascadeDict:[String:Any]?
    var cascadeArray: [[String: Any]] = []
    var personDict:[String:Any]?
    var violationDict:[String:Any]?
    
    var cascadeQuestionArray : [QuestionResult1]?
    var locArray = [Questionoptions1]()
    var ripaActivity: Ripaactivity?
    
    var previewViewModel = PreviewViewModel()
    
    var cascadeQuestionType:String?
    var indexPath:Int?
    var is_k12:Bool?
    var age:Int = 0
    
    var questionType:String?
    let enterTextPopup = EnterTextPopupViewController.instantiate()
    let enterDescription = EnterDescriptionPopupViewController.instantiate()
    let selectOptionPopup = SelectOptionsPopup.instantiateOption()
    let violationPopup = ViolationPopup.instantiateOption()
    let pendingQuestionPopup = PendingQuestionsPopup.instantiateQuestion()
    
    var checkCommon:Bool?
    var checkEditable:Bool?
    var isTextInput:Bool?
    var showAddBtn:Bool?
    var questNumber:Int?
    var orderId:String?
    var answer:String=""
    var inputTypeCode:String = ""
    let db = SqliteDbStore()
    var countyList = [CountyResult]()
    
    var tempautoNext = false
    
    var ischangeQuestion = false
    
    var timer = Timer()
    
    var lat = ""
    var long = ""
    
    var cityID=""
    var questionId=""
    var vioQuestionId=""
    
    var cityName=""
    var streetName=""
    var intersectionName=""
    var saveRipaStatus:String?
    
    var lgbtBtnDisable:Bool?
    
    var personcount = 0
    var crashDict:[String:Any] = [:]
    var newRipaViewModel = NewRipaViewModel()
    
    var  selectedOptionsArray=[[Questionoptions1]]()
    var  selectedLocationOption : QuestionResult1?
    var  personArray: [[String: Any]] = []
    
    var currentQuestNumb:String?{

        String(questNumber!+1) + "/" + String(questionArray!.count)
    }
    
    var startDate = ""
    
    let datePicker = UIDatePicker()
    let timePicker = UIDatePicker()
    
    var textAdded:Bool = false
    var isListRipaEditable:Bool = false
    var isEdit:Bool = false
    var isEditRequired:Bool = false
    var isGpsEnable:Bool = false
    var isGpsCityMatched:Bool = true
    var isKeyboard:Bool = true
   
    
    @IBOutlet var optionTypeLbl : UILabel!
    
    var street : String = ""
    var intersectionStreet : String = ""
    var blockStr : String = ""
    var completeAddressStr : String = ""
    var descriptionStr : String = ""
    var ripaTypeStr : String = ""
    var descriptionStrFirst : String = ""
    var checkGenderSelection : Bool = false
    weak var selectedIndexDelegate : GoToQuestion?
    
    var screenType : String = ""
    var isPendingEdit:Bool = false
    var isCreatedSaved:Bool = false
    private var locationManager = CLLocationManager()
    var locTypeIndex : Int = 0
    var locTypeRow : Int = 0
    var isSubmit : Bool = false
    var showAlertForSave : Bool = false
    var isClearViolations : Bool = false
    var selectdViolationByDropDown = [Questionoptions1]()
    var isOffenceCode = true
   
    override func viewDidLoad() {
        super.viewDidLoad()
       
        self.determineMyCurrentLocation()
        self.previewViewModel.saveDelegate = self
        self.loginModel.OTPdelegate = self
        self.addPersonBtn.isHidden = true
        let mainString = AppConstants.address
        self.getCityId()
        
        if viewType == "UseLastRipa"{
           AppConstants.duration = ""
        }
       
        if mainString.count > 2 {
            let components = mainString.components(separatedBy: "BLOCK")
            if components.count > 1 {
                blockStr = components[0]
                let stretArr = components[1].components(separatedBy: "/")
                if stretArr.count>1 {
                    street = stretArr[0]
                    intersectionStreet = stretArr[1]
                }
                else {
                    street = stretArr[0]
                }
            }
            else{
                let components = mainString.components(separatedBy: "BLK")
                var stretArr = NSArray()
                if components.count > 1 {
                    blockStr = components[0]
                    stretArr = components[1].components(separatedBy: "/") as NSArray
                }
                else {
                    stretArr = mainString.components(separatedBy: "/") as NSArray
                }
                 
                if stretArr.count>1 {
                    street = stretArr[0] as! String
                    intersectionStreet = stretArr[1] as! String
                }
                else {
                    street = stretArr[0] as! String
                }
            }
        }
        
        trackApplicationTime()
        questNumber = 0
        tableView.delegate = self
        tableView.dataSource = self
        
        resetBtn.isHidden = true
        addOptionBtn.isHidden = true
        
        checkCommon = false
        checkEditable = false
        
        print(viewType)
        if (viewType != "UseSaveRipa" && viewType != "UseLastRipa" && viewType != "Template"){
            AppManager.removeData()
        }
        if  viewType == "StartNewRipa"{
            self.previewViewModel.getDefaultCityByCustId()
        }
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        startDate = previewViewModel.getCurrentTime()
        
        if AppConstants.isTemplate == "temp" {
            tick()
        }
        
        submitBtn.isHidden = true
        
        self.saveBtn.orangeGradientButton()
        self.nextView.orangeGradientButton()
     
        newRipaViewModel.setFeature()
        getCounty()
        resetArray()
        
        if saveRipaStatus == "Created" {
            locTypeIndex = AppConstants.LocTypeIndex
        }
        
        if (viewType == "UseSaveRipa" && saveRipaStatus != "Created") || (viewType == "UseLastRipa" || viewType == "Template"){
            var i = 0
            let personDict = personArray[0]
            let selectionOptionArr = (personDict["SelectedOption"] as! [[Questionoptions1]])
            if selectionOptionArr.count > 2 ,selectionOptionArr[2].count > 2 {
                let ageStr = selectionOptionArr[2][2].option_value
                let decimalCharacters = CharacterSet.decimalDigits
                let decimalRange = ageStr.rangeOfCharacter(from: decimalCharacters)
                if decimalRange != nil {
                    print("Age found")
                    self.age = Int(ageStr)!
                }
            }
            
            for _ in personArray{
                editForPerson(personIndex: i, personArray: personArray)
                personcount = i
                createPersonDict(checkEditHidden: false)
                i += 1
            }
            if personArray.count > 1{
                checkCommon = true
                checkEditable = true
            }
            if isPendingEdit{
                saveToServerBtn.isHidden = true
            }
            if viewType == "UseSaveRipa" && saveRipaStatus == "Saved"{
                submitBtn.setTitle("UPDATE", for: .normal)
            }
            if saveRipaStatus == "Saved" {
                submitBtn.setTitle("SUBMIT", for: .normal)
            }
            self.isEdit = true
            editForPerson(personIndex: personArray.count-1, personArray: personArray)
            personNumber.text = "P" + "" + String(personArray.count)
            print(viewType)
            if viewType == "UseLastRipa" || viewType == "Template"{
                newRipaViewModel.clearPersonData()
                self.age = 0
            }
            checkAndAddViolations()
        }
        else{
            self.isEdit = false
            if viewType == "UseLastRipa" || viewType == "Template"{
                optionsArray?[1].questionoptions?.first?.option_value = ""
            }
        
            if  saveRipaStatus == "Created"{
                let trafficeViolTupple = newRipaViewModel.splitViolatons(code: savedRipaList!.offenceCode, violation: savedRipaList!.violation)
                offenceArr = trafficeViolTupple.0!
                violArr = trafficeViolTupple.1!
                
                if savedRipaList!.violationID.count > 0 {
                    newRipaViewModel.delegate = self
                    newRipaViewModel.getViolationsRipaParam(violationId: savedRipaList!.violationID)
                }
            }
            
            personNumber.text = "P1"
            let value = defaults.object(forKey: "OptionValue")
            if value != nil{
                let assignmentQuest = newRipaViewModel.getQuestionUsingQuestionCode(question_code: 23)
                assignmentQuest.questionoptions!.first(where: { $0.option_value == value as! String })?.isSelected = true
            }
        }
        
        let lastName =  AppManager.getLastSavedLoginDetails()!.result!.last_name
        let firstName =  AppManager.getLastSavedLoginDetails()!.result!.first_name
        userNameLbl.text = "\(lastName) \(firstName)"
        if lastName.count > 0 && firstName.count > 0 {
            userNameLbl.text = "\(lastName) , \(firstName)"
        }
        
        autoNextBtn.setImage(UIImage(named: AppConstants.autoNext == true ? "checked" : "unchecked"), for: .normal)
        
        tableView.register(UINib(nibName: "SingleChoiceCell", bundle: nil), forCellReuseIdentifier: "SingleChoiceCell")
        tableView.register(UINib(nibName: "MultilineCell", bundle: nil), forCellReuseIdentifier: "MultilineCell")
        tableView.register(UINib(nibName: "SingleLineCell", bundle: nil), forCellReuseIdentifier: "SingleLineCell")
        tableView.register(UINib(nibName: "CLCell", bundle: nil), forCellReuseIdentifier: "clcell")
        tableView.register(UINib(nibName: "ViolationCell", bundle: nil), forCellReuseIdentifier: "ViolationCell")
        tableView.register(UINib(nibName: "ViolationTextCell", bundle: nil), forCellReuseIdentifier: "ViolationTextCell")
        tableView.register(UINib(nibName: "ViolationCell2", bundle: nil), forCellReuseIdentifier: "ViolationCell2")
        tableView.register(UINib(nibName: "EducationCodeCell", bundle: nil), forCellReuseIdentifier: "EducationCodeCell")
        tableView.register(UINib(nibName: "togglCell", bundle: nil), forCellReuseIdentifier: "togglCell")
        tableView.register(UINib(nibName: "PerceivedGenderCell", bundle: nil), forCellReuseIdentifier: "PerceivedGenderCell")
        tableView.register(UINib(nibName: "RadioTextCell", bundle: nil), forCellReuseIdentifier: "RadioTextCell")
        
        
        if #available(iOS 15.0, *) {
            self.tableView.sectionHeaderTopPadding = 0.0
        }
        
        self.tableView.sectionHeaderHeight = UITableView.automaticDimension;
        self.tableView.estimatedSectionHeaderHeight = 55;
        
        self.tableView.estimatedRowHeight = 100.0
        self.tableView.rowHeight = UITableView.automaticDimension
        is_k12 = false
        AppConstants.isStudent = "0"
        
        loadData()
        
        showDatePicker()
        showTimePicker()
        durationTxtField.delegate = self
        durationTxtField.tag = 10
        durationTxtField.addTarget(self, action: #selector(textIsChanging), for: UIControl.Event.editingChanged)

        if AppConstants.duration.contains("-") {
            AppConstants.duration = AppConstants.duration.replacingOccurrences(of: "-", with: "")
        }
        durationTxtField.text = AppConstants.duration
        dateTextField.text = AppConstants.date
        timeTxtField.text = AppConstants.time
        if self.isEdit == false {
            let userId =  "AND userid is " + (AppManager.getLastSavedLoginDetails()?.result?.userid)!
            var savedAllRipaList = [RipaTempMaster]()
            savedAllRipaList = self.db.getRipaTempMaster(tableName: "SELECT * FROM ripaTempMasterTable WHERE mainStatus is NOT 1 \(userId) order by stopDate DESC") ?? []
            let filtSaveArr = savedAllRipaList.filter { data in
                data.stopDate == AppConstants.date && data.stopTime == AppConstants.time
            }
            print(filtSaveArr)
            if filtSaveArr.count > 0 {
                self.showAlertMessage(titleStr: "", messageStr: "Another RIPA activity already exists with the same stop date, time and user.\n\nPlease validate and change the stop date and time in order to procees.")
            }
        }
        
        
        durationTxtField.keyboardType = UIKeyboardType.numberPad
        
        if AppConstants.duration == ""{
            durationTxtField.becomeFirstResponder()
        }
        
        disableNextButton(View: nextView)
        // disableButton(Button: prevQuestBtn)
        
        let userDefaults = UserDefaults.standard
        let isNil = "0"
        userDefaults.set(isNil, forKey: "isOffline")
     
        if (viewType == "UseSaveRipa") &&  AppConstants.LocTypeIndex == 6 {
            let finalDate = String(format: "%@ %@", AppConstants.date,AppConstants.time)
            let saveRipaCheck = finalDate.convertTimerForEvent(eventtDate: finalDate, gpsActivateTime: AppConstants.gpsActiveTime)
            if saveRipaCheck == true {
                self.showAlertForGpsFunctionality()
            }
        }
        
    }
    
    func proceedToAddViolationReasonStopTypeOfStop() {
        print(AppConstants.violation_type,AppConstants.travel_method,AppConstants.offenceCodes)
        if AppConstants.offenceCodes.count > 1 && AppConstants.violation_type.count > 0 {
            trafficVoilArray()
        }
    }
    
    func proceedToOTP(isValidLogin: Int, message: String) {
        
    }
    
    func showPopupForCustId() {
        
    }
    
    func showAlertForGpsFunctionality() {
        let alert = UIAlertController(title: "", message: "You have selected the GPS coordinates as the location type. The RIPA activity was created some time ago and the current GPS location may differ from the original location of the stop. You can continue with your selection or cancel and select another location type option", preferredStyle: .alert)
            
             let ok = UIAlertAction(title: "YES", style: .default, handler: { action in
                 if let latString = UserDefaults.standard.string(forKey: "latitude"),let longString = UserDefaults.standard.string(forKey: "longitude") {
                     AppConstants.lati = latString
                     AppConstants.longi = longString
                     self.tableView.reloadData()
                 }
                 self.gpsLocation.delegate = self
                 self.gpsLocation.getGPSLocation()
             })
             let cancel = UIAlertAction(title: "NO", style: .default, handler: { action in
                
             })
             alert.addAction(cancel)
             alert.addAction(ok)
             DispatchQueue.main.async(execute: {
                self.present(alert, animated: true)
        })
    }
    
  func getDefaultCityFromServer(data:[DefaultCityModel]){
      if !data.isEmpty,let city = data[0].city_name {
          AppConstants.city = city
          self.cityID = data[0].city_id ?? ""
          self.tableView.reloadData()
      }
  }
    
    func animateTable(tblVW: UITableView) {
    
            let cells = self.tableView.visibleCells
            let tableHeight: CGFloat = self.tableView.bounds.size.height

            for i in cells {
                let cell: UITableViewCell = i as UITableViewCell
                cell.transform = CGAffineTransform(translationX: 0, y: tableHeight)
            }

            var index = 0

            for a in cells {
                let cell: UITableViewCell = a as UITableViewCell
                UIView.animate(withDuration: 0, delay: 0.0 * Double(index), options: .allowAnimatedContent, animations: {
                    cell.transform = CGAffineTransform(translationX: 0, y: 0);
                }, completion: nil)
                index += 1
            }
        }


    override func viewDidLayoutSubviews() {
            animateTable(tblVW: self.tableView)
    }
    
    func scrollToBottom(_ animated: Bool = true) {
            let numberOfSections = self.tableView.numberOfSections
            if numberOfSections > 0 {
                let numberOfRows = self.tableView.numberOfRows(inSection: numberOfSections - 1)
                if numberOfRows > 0 {
                    let indexPath = IndexPath(row: numberOfRows - 1, section: (numberOfSections - 1))
                    self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: animated)
                }
            }
        }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.submitBtn.isUserInteractionEnabled = true
        if questionArray![questNumber!].question_code == "17" && self.descriptionStr.count < 1{
            self.descriptionBtn.isHidden = false
            questionArray![questNumber!].isDescription_Required = "1"
            let index = questionArray![questNumber!].questionoptions!.count - 1
            self.descriptionStr = (questionArray![questNumber!].questionoptions![index] ).option_value
            print((questionArray![questNumber!].questionoptions![index] ).option_value)
        }
        
        if AppConstants.theme == "1"{
            overrideUserInterfaceStyle = .dark
        }
        else{
            overrideUserInterfaceStyle = .light
            AppConstants.theme = "0"
        }
        
        if  let userOption = UserDefaults.standard.object(forKey: "userOption") as? String {
            self.optionTypeLbl.text = userOption
        }
        
        if  let attribute = UserDefaults.standard.object(forKey: "physical_attribute") as? String,attribute == "9999" {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                let istraini = UserDefaults.standard.bool(forKey: "isTraini")
                if  istraini &&  (self.viewType != "UseSaveRipa") {
                    self.checkTrainingAssignment()
                }
            }
        }
        if self.isListRipaEditable {
            self.isListRipaEditable = false
            self.performSegue(withIdentifier: "ShowPreview", sender: self)
        }
        
        self.countyBtn.isUserInteractionEnabled = true
        self.isGpsEnable = false
        if questionArray![questNumber!].question_code == "5" && self.locTypeIndex == 6{
           // self.isGeoLocation(check: true)
            self.countyBtn.isUserInteractionEnabled = false
            self.isGpsEnable = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
    
        if screenType == "EditPending" {
            trackApplicationTime()
            createPersonDict(checkEditHidden: true)
            screenType = ""
            self.performSegue(withIdentifier: "ShowPreview", sender: self)
        }
        
        let check = checkRequired()
        nextEnabled = true
        if check.0 == true{
            enableNextButton(View: nextView)
        }
    }
    
    func checkTrainingAssignment() {
        let alert = UIAlertController(title: "", message: "Assignment is set to Training/Testing. This activity will not be processed. Continue?", preferredStyle: .alert)
            
             let ok = UIAlertAction(title: "YES", style: .default, handler: { action in
                 UserDefaults.standard.set(false, forKey: "isTraini")
             })
             let cancel = UIAlertAction(title: "NO", style: .default, handler: { action in
                 self.sendUserSettingController()
             })
             alert.addAction(cancel)
             alert.addAction(ok)
             DispatchQueue.main.async(execute: {
                self.present(alert, animated: true)
        })
    }
    
    
    func sendUserSettingController() {
        let vc2 = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "UserSettingsViewController") as! UserSettingsViewController
        vc2.flag = 1
        vc2.delegate = self
        self.navigationController?.pushViewController(vc2, animated: true)
       
    }
    
    func sendSettingInfo(data : UserSettingModel){
        self.userSettingArray = data
    }
    
    @IBAction func actionChangeUserInfo(_ sender: Any) {
        self.sendUserSettingController()
    }
    
    
    func getCounty(){
        db.openDatabase()
        countyList = db.getCounty() ?? []
        for county in countyList{
            if county.countyID == AppManager.getLastSavedLoginDetails()?.result?.county_id{
                countyLbl.text = county.countyName + " COUNTY"
            }
        }
    }
    
    
    func checkAndAddViolations(){
        let violationsQuest = newRipaViewModel.getCascadeQuestionUsingQuestionCode(questionCode: "C5")
        if violationsQuest.questionoptions!.count > 0{
            
            for options in violationsQuest.questionoptions!{
                let opt = options.copy()
                selectedViolationArray2.append(opt as! Questionoptions1)
                violationDict = ["ViolationFor":"Traffic", "optionID": "" ,"ViolationList": selectedViolationArray2]
            }
        }
    }
    
    
    var offenceArr = [[String]]()
    var violArr = [String]()
    var violIndex = 0
    var selectedViolationArray2 = [Questionoptions1]()
    
    func trafficVoilArray(){
        let vioArray = self.filterViolationWithOffenceCode()
        if violIndex <= offenceArr.count - 1{
            for offCode in offenceArr[violIndex]{
                let offCode = offCode.lowercased()
                if offCode == "" || offCode == "null" || offCode.contains("null") {
                    _ = violArr[violIndex]
                  //  showAlertWithProperty("", messageString: "Offence code is not available for \(violation). \n (CODE NOT FOUND) will be used.")
                    return
                }
                else if vioArray.count > 0 {
                    DispatchQueue.background(delay: 0.5, completion:{ [self] in
                        openViolationPopup(index:violIndex, popupFor: "Violation")
                    })
                    return
                }
            }
        }
    }
    
    
    func openViolationPopup(index:Int, popupFor : String){
        guard let selectViolationPopup = violationPopup else { return }
        selectViolationPopup.violationPopupDelegate = self
        var arrayCount = 1
        
        if popupFor != "Consent"{
            var offenceArr1 = [String]()
            let vioArray = self.filterViolationWithOffenceCode()
            for str in offenceArr[index]{
                let formattedString = str.replacingOccurrences(of: " ", with: "")
                offenceArr1.append(formattedString)
            }
            offenceArr[index] = offenceArr1
          //  let filteredViolations = vioArray.filter({offenceArr[index].contains($0.offense_code) })
            selectViolationPopup.violationArray = vioArray
            arrayCount = vioArray.count
            
        }
        else{
            selectViolationPopup.concentQuestion = questionArray![questNumber!]
            arrayCount = 6
        }
        selectViolationPopup.popupFor = popupFor
        
        let popupVC = PopupViewController(contentController: selectViolationPopup, popupWidth: UIScreen.main.bounds.size.width-30, popupHeight: CGFloat(60 * arrayCount) + 150)
        popupVC.cornerRadius = 5
        popupVC.delegate = self
        present(popupVC, animated: true, completion: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "optionViolNotif"), object: nil)
    }
    
    func filterViolationWithOffenceCode() -> [ViolationsResult] {
            var violArray = [ViolationsResult]()
            let offenceArr = AppConstants.offenceCodes.components(separatedBy: ",")
            var MainViolationArray = newRipaViewModel.getViolations()
            
             if AppConstants.violation_type == "1" {
                 MainViolationArray = MainViolationArray.filter {
                    $0.violationGroup == "VC" || $0.violationGroup == "AA"
                }
            }
            else if AppConstants.violation_type == "2" {
                MainViolationArray = MainViolationArray.filter {
                    $0.violationGroup != "VC"
                }
            }
        
        for obj in offenceArr {
            let vioObj = MainViolationArray.filter({$0.offense_code == obj})
            if vioObj.count > 0 {
                violArray.append(vioObj[0])
            }
        }
        
        return violArray
    }
    
    func selectedOptionFromViolationPopup(optionArray: [Questionoptions1]){
        selectedViolationArray2.removeAll()
        selectdViolationByDropDown.removeAll()
        selectedViolationArray2.append(contentsOf: optionArray)
        selectdViolationByDropDown.append(contentsOf: optionArray)
        violationDict = ["ViolationFor":"Traffic", "optionID": "" ,"ViolationList": optionArray]
        violIndex += 1
        trafficVoilArray()
        
    }
    
    
    func showAlertWithProperty(_ title: String, messageString: String) -> Void {
        let alertController = UIAlertController.init(title: title, message: messageString, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { [self] action in
            
            violationArray = newRipaViewModel.getViolations()
            
            for options in violationArray!{
                if options.offense_code == "99999"{
                    let option = newRipaViewModel.createObj( mainQuestId: "", ripaID: "", optionValue: options.violationDisplay, physical_attribute:"", description: options.offense_code, isSelected: true, mainQuestOrder: "", isNewAdded: false, mainId: vioQuestionId)
                    selectedViolationArray2.append(option)
                }
            }
          
            violIndex += 1
            trafficVoilArray()
        })
        )
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    func addSwipeGesture(){
        let swipeleft = UISwipeGestureRecognizer(target: self, action: #selector(swipeleft(sender:)))
        swipeleft.direction = .left
        view.addGestureRecognizer(swipeleft)
        
        let swiperight = UISwipeGestureRecognizer(target: self, action: #selector(swiperight(sender:)))
        swiperight.direction = .right
        view.addGestureRecognizer(swiperight)
    }
    
    
    func removeSwipeGesture(){
        if let gestures = view.gestureRecognizers {
            for gesture in gestures {
                if let recognizer = gesture as? UISwipeGestureRecognizer {
                    view.removeGestureRecognizer(recognizer)
                }
            }
        }
    }
    
    
    func disableNextButton(View: UIView) {
        if let layer = View.layer.sublayers? .first {
            if View.layer.sublayers!.count>1{
                layer.removeFromSuperlayer ()
               // topNextView.layer.sublayers?.first!.removeFromSuperlayer()
            }
            nextView.disablebutton()
           // topNextView.disablebutton()
        }
        removeSwipeGesture()
         nextQuestBtn.isUserInteractionEnabled = false
       //  topNextBtn.isUserInteractionEnabled = false
        nextEnabled = false
        
        var isStreet : Bool = false
        if questionArray![questNumber!].question_code == "5"{
            if AppConstants.city.count > 0 && street.count > 0 {
                isStreet = true
            }
//            var quest = newRipaViewModel.getCascadeQuestionUsingQuestionCode(questionCode: "C6") //city
//            quest = newRipaViewModel.getCascadeQuestionUsingQuestionCode(questionCode: "C7") //street
//            if quest.questionoptions!.count < 1{
//                isStreet = false
//            }
//            else {
//                isStreet = true
//            }
        }
        
        let checkQNumbr : Int = questNumber ?? 0
        
        print(AppConstants.address)
       // print(checkQNumbr)
        print(isStreet)
        if AppConstants.address.count > 2 && checkQNumbr == 0 && isStreet == true{
            nextEnabled = true
            enableNextButton(View: nextView)
        }
        
        if questionArray![questNumber!].question_code == "5" && self.durationTxtField.text?.count ?? 0 > 0 {
            nextEnabled = true
            enableNextButton(View: nextView)
        }
        
    }
    
    
    func enableNextButton(View: UIView) {
        if questionArray![questNumber!].question_code == "5" && self.checkLocationType() {
            if let layer = View.layer.sublayers? .first {
                if View.layer.sublayers!.count>1{
                    layer.removeFromSuperlayer ()
                   // topNextView.layer.sublayers?.first!.removeFromSuperlayer()
                }
                nextView.orangeGradientButton()
                nextEnabled = true
            }
              nextQuestBtn.isUserInteractionEnabled = true
        }
        else if questionArray![questNumber!].question_code != "5" {
            if let layer = View.layer.sublayers? .first {
                if View.layer.sublayers!.count>1{
                    layer.removeFromSuperlayer ()
                   // topNextView.layer.sublayers?.first!.removeFromSuperlayer()
                }
                nextView.orangeGradientButton()
                nextEnabled = true
            }
              nextQuestBtn.isUserInteractionEnabled = true
        }
    }
    
    func checkLocationType() -> Bool {
        if locTypeIndex == 0 {
            return false
        }
        else if locTypeIndex == 1 && AppConstants.street.count == 0 {
            return false
        }
        else if locTypeIndex == 1 && AppConstants.block.count == 0 {
            return false
        }
        else if locTypeIndex == 2 && AppConstants.firstIntersection.count == 0 {
            return false
        }
        else if locTypeIndex == 2 && AppConstants.secondIntersection.count == 0 {
            return false
        }
        else if locTypeIndex == 3 && AppConstants.highway.count == 0 {
            return false
        }
        else if locTypeIndex == 3 && AppConstants.closestHighway.count == 0 {
            return false
        }
        else if locTypeIndex == 4 && AppConstants.LocTypeDescription.count == 0 {
            return false
        }
        return true
    }
    
    
    
    func checkRequired()->(Bool,String){
        self.descriptionBtn.isHidden = true
        if questionArray![questNumber!].question_code == "25"{
            for options in optionsArray!{
                let quest = newRipaViewModel.getCascadeQuestionUsingQuestionCode(questionCode: options.question_code_for_cascading_id)
                if quest.is_required == "1" && options.isSelected == false && !(quest.id == "62" || quest.id == "68"){
                    return (false,"Please Select City")
                }
            }
            return (true,"Please Select City")
        }
        else if questionArray![questNumber!].question_code == "14"{
            let index = questionArray![questNumber!].questionoptions!.count - 1
            let text = (questionArray![questNumber!].questionoptions![index] ).option_value
            if text.count == 0  {
                return (false,"No Description Found")
            }
        }
        
        if questionArray![questNumber!].question_code == "T5"{
            for options in optionsArray!{
                if options.question_code_for_cascading_id.count  > 0 {
                    let quest = newRipaViewModel.getCascadeQuestionUsingQuestionCode(questionCode: options.question_code_for_cascading_id)
                    if quest.is_required == "1" && options.isSelected == true,options.inputTypeCode == "A "{
                        return (true,"Please Select Type of Stop")
                    }
                }
            }
            return (false,"Please Select Type of Stop")
        }
        
        if questionArray![questNumber!].question_code == "5"{
            if AppConstants.date == "" || AppConstants.time == "" || AppConstants.duration == "" {
                return (false,"Durartion Required")
            }
            if AppConstants.LocTypeIndex == 4 {
                self.descriptionBtn.isHidden = false
            }
            var quest = newRipaViewModel.getCascadeQuestionUsingQuestionCode(questionCode: "C6")
            if quest.questionoptions!.count < 1{
                return (false,"Please Select City")
            }
            quest = newRipaViewModel.getCascadeQuestionUsingQuestionCode(questionCode: "C7")
            if quest.questionoptions!.count < 1{
                return (false,"Please Select Street")
            }
            
            quest = newRipaViewModel.getCascadeQuestionUsingQuestionCode(questionCode: "C10")
            if quest.questionoptions?.count ?? 0 > 0 , (quest.questionoptions![0] ).isSelected == true{
                quest = newRipaViewModel.getCascadeQuestionUsingQuestionCode(questionCode: "C9")
                if quest.questionoptions!.count < 1 && optionsArray![2].isSelected == true{
                    return (false,"Please Select School")
                }
            }
            else {
                return (true,"")
            }
            return (true,"")
        }
        
        //FOR SL
        if questionArray![questNumber!].question_code == "11" {
            if questionArray![questNumber!].questionoptions!.count > 0 {
                if questionArray![questNumber!].questionoptions![0].isSelected == true{
                    return (true,"")
                } else{ return (false,"")}
            }
            else{ return (false,"")}
        }
        
        // This If Condition For Basis For Search Description
        if questionArray![questNumber!].question_code == "17"{
                let selectItem = optionsArray?.filter({
                    $0.isSelected == true
                })
              let atribute4 = selectItem?.filter({
                  $0.physical_attribute == "4"
              })
            
              if selectItem?.count ?? 0 > 2 && self.descriptionStr.count == 0{
                   questionArray![questNumber!].isDescription_Required = "1"
                   descriptionBtn.isHidden = false
                   return (false,"No Description Found")
               }
              else if atribute4?.count ?? 0 > 0 && selectItem?.count ?? 0 < 2 {
                 descriptionBtn.isHidden = true
                 questionArray![questNumber!].isDescription_Required = "0"
                 return  (true,"")
               }
             else if atribute4?.count ?? 0 > 0 && selectItem?.count ?? 0 > 1 {
                 descriptionBtn.isHidden = false
                 questionArray![questNumber!].isDescription_Required = "1"
               return  (true,"")
              }
               else if atribute4?.count ?? 0 > 0 {
                   descriptionBtn.isHidden = true
                   questionArray![questNumber!].isDescription_Required = "0"
                   return  (true,"")
               }
              else if self.descriptionStr.count == 0{
                  descriptionBtn.isHidden = false
                  questionArray![questNumber!].isDescription_Required = "1"
                  return (false,"No Description Found")
              }
            else {
                descriptionBtn.isHidden = true
                if questionArray![questNumber!].question_code == "17" && viewType != "StartNewRipa"{
                    descriptionBtn.isHidden = false
                }
                questionArray![questNumber!].isDescription_Required = "0"
                return  (true,"")
            }
          }
        
        
        if questionArray![questNumber!].is_required == "1" && questionArray![questNumber!].isDescription_Required == "0"{
            var valSelected = false
            //  var descriptionSelected = false
            if questionArray![questNumber!].questionTypeCode == "SL" || questionArray![questNumber!].questionTypeCode == "ML"{
                if questionArray![questNumber!].questionoptions!.count < 1 || answer == ""{
                    return (false,"")
                }
                else{
                    return (true,"")
                }
            }
            
            for option in questionArray![questNumber!].questionoptions! {
                if option.isSelected == true{
                    valSelected = true
                }
            }
            return(valSelected,"")
            
        }
        
        else if questionArray![questNumber!].is_required == "1" && questionArray![questNumber!].isDescription_Required == "1"{
            var valSelected = false
            var descriptionSelected = false
            for option in questionArray![questNumber!].questionoptions! {
                if option.isSelected == true && option.tag != "Description"{
                    valSelected = true
                }
                
                else if option.tag == "Description" && option.isSelected == true{
                    descriptionSelected = true
                }
                
                if questionArray![questNumber!].question_code == "14"{
                    if (option.physical_attribute == "1" || option.physical_attribute == "2")  && option.isSelected == true{
                        var violQuest:QuestionResult1?
                        var typeQuest:QuestionResult1?
                        if option.physical_attribute == "1"{
                            violQuest = newRipaViewModel.getCascadeQuestionUsingQuestionCode(questionCode: "C5")
                            typeQuest = newRipaViewModel.getCascadeQuestionUsingQuestionCode(questionCode: "C1")
                            if typeQuest!.questionoptions![1].isSelected == false{
                                valSelected = false
                            }
                            if violQuest!.questionoptions!.count < 1{
                                valSelected = false
                            }
                        }
                        else{
                            typeQuest = newRipaViewModel.getCascadeQuestionUsingQuestionCode(questionCode: "C3")
                            if typeQuest!.questionoptions?.count ?? 0 > 1 ,typeQuest!.questionoptions?[1].isSelected == false{
                                valSelected = false
                            }
                        }
                        
                    }
                    
                }
            }
            
            if valSelected == true && descriptionSelected == true{
                return  (true,"")
            }
            else{
                if valSelected == false{
                    return (false,"")
                }
                else {
                    return (false,"No Description Found")
                }
            }
            
        }
        
        
        return (true,"")
    }
    
    
    func checkMandatorySelection()-> String{
        //AppConstants.autoNext = false
        let check = checkRequired()
        nextEnabled = true
        if check.0 == true{
            enableNextButton(View: nextView)
        }
        else{
            if check.1 == "No Description Found"{
                enableNextButton(View: nextView)
                nextEnabled = false
            }
            else{
                disableNextButton(View: nextView)

            }
        }
        
        if questionArray![questNumber!].question_code == "17"{
            let selectItem = optionsArray?.filter({
                $0.isSelected == true
            })
            if selectItem?.count ?? 0 < 2 && self.descriptionStr.count > 0{
                disableNextButton(View: nextView)
            }
            
        }
       
        if questionArray![questNumber!].question_code == "T5"{
            disableNextButton(View: nextView)
            let selectItem = (optionsArray![0].questionoptions)?.filter({
                $0.isSelected == true
            })
            if selectItem?.count ?? 0 > 0 {
                enableNextButton(View: nextView)
            }
        }
        
        if self.durationTxtField.text?.count == 0 {
            disableNextButton(View: nextView)
        }
     
        self.descriptionBtn.isHidden = true
        if questionArray![questNumber!].question_code == "17" ||  questionArray![questNumber!].question_code == "14"{
            self.descriptionBtn.isHidden = false
        }
        
        // This If Condition For Basis For Search Description
        if questionArray![questNumber!].question_code == "17"{
                let selectItem = optionsArray?.filter({
                    $0.isSelected == true
                })
              
               let atribute4 = selectItem?.filter({
                   $0.physical_attribute == "4"
               })
               if selectItem?.count ?? 0 > 2 && self.descriptionStr.count == 0{
                   descriptionBtn.isHidden = false
               }
               else if atribute4?.count ?? 0 > 0 && selectItem?.count ?? 0 < 2{
                   self.descriptionStr = ""
                   let index = questionArray![questNumber!].questionoptions!.count - 1
                   (questionArray![questNumber!].questionoptions![index] ).option_value = ""
                   (questionArray![questNumber!].questionoptions![index] ).isSelected = false
                   descriptionBtn.isHidden = true
               }
              else if self.descriptionStr.count == 0{
                  let index = questionArray![questNumber!].questionoptions!.count - 1
                  (questionArray![questNumber!].questionoptions![index] ).option_value = ""
                  (questionArray![questNumber!].questionoptions![index] ).isSelected = false
                  descriptionBtn.isHidden = false
              }
            else {
               // self.descriptionStr = ""
                descriptionBtn.isHidden = true
            }
            if selectItem?.count == 0 {
                self.descriptionStr = ""
                disableNextButton(View: nextView)
            }
          }
        
       
        if questionArray![questNumber!].question_code == "17"{
            
            for i in (0..<optionsArray!.count)
            {
                let items = optionsArray![i]
                let check = items.isSelected
                let attr = items.physical_attribute
                let optionId = items.option_id
                if optionId.count == 0 {
                    optionsArray![i].option_id = "0"
                }
                if check == true && attr == "4" {
                    self.descriptionBtn.isHidden = false
                    if (enterDescription?.textView) != nil {
                        enterDescription?.textView.text = ""
                    }
                }
                print(optionsArray![i].isSelected)
            }
            
            let object = optionsArray?.filter({
                $0.isSelected == true
             })

            
            if object?.count == 0{
                enterDescription?.textView?.text = ""
                self.descriptionBtn.isHidden = false
            }
            
            if textAdded &&  object?.count == 2{
               
            if  let check = object{
                let checkD = checkDescription(optionArr: check)
               if checkD {
                    self.descriptionBtn.isHidden = true
                }
                else{
                    self.descriptionBtn.isHidden = false
                }
                }
            }
            
            ischangeQuestion = true
            _ = questionArray![questNumber!].questionoptions!.count - 1
           
            if  let check = object,check.count > 2 {
                self.descriptionBtn.isHidden = false
            }
            
                if let obj = optionsArray?.filter({
                    $0.cascade_ripa_id == "84" && $0.isSelected == true
                }), obj.count > 0{
                   
                    if let isOpSelect = obj[0].questionoptions?.filter({
                        $0.isSelected == true
                    }), isOpSelect.count > 0 && descriptionStr.count > 0 {
                        nextEnabled = true
                        enableNextButton(View: nextView)
                    }
            
                }
            
        }
        
        if questionArray![questNumber!].question_code == "T5"{
            for i in (0..<optionsArray!.count)
            {
                let id = optionsArray![i].cascade_ripa_id
                let question_code_for_cascading_id = optionsArray![i].question_code_for_cascading_id
                let question = newRipaViewModel.getCascadeQuestionUsingId(questionID: Int(id)!)
                let questionTypeCode = optionsArray![i].questionTypeCode
                if questionTypeCode == "SC" && optionsArray![i].inputTypeCode == "AN" && question_code_for_cascading_id != "C43" && question_code_for_cascading_id != "C44"{
                    if optionsArray![i].isSelected == true && question.questionoptions?.count ?? 0 > 1 {
                        question.questionoptions![0].isSelected = true
                        question.questionoptions![1].isSelected = false
                    }
                    else if question.questionoptions?.count ?? 0 > 1{
                        optionsArray![i].isSelected = false
                        question.questionoptions?[0].isSelected = false
                        question.questionoptions?[1].isSelected = true
                    }
                }
            }
        }
    
        if questionArray![questNumber!].question_code == "T6"{
            enableNextButton(View: nextView)
            for i in (0..<optionsArray!.count)
            {
                let id = optionsArray![i].cascade_ripa_id
                let question = newRipaViewModel.getCascadeQuestionUsingId(questionID: Int(id)!)
                let questionTypeCode = optionsArray![i].questionTypeCode
                if questionTypeCode == "SC" && optionsArray![i].inputTypeCode == "AN"{
                    if optionsArray![i].isSelected == true {
                        question.questionoptions![0].isSelected = true
                        question.questionoptions![1].isSelected = false
                    }
                    else {
                        optionsArray![i].isSelected = false
                        question.questionoptions![0].isSelected = false
                        question.questionoptions![1].isSelected = true
                    }
                }
            }
        }
        
        if questionArray![questNumber!].question_code == "17"{
            let personSearch =  getCascadeQuestionUsingQuestionCode(questionCode: "C13")
            let propertySearch =  getCascadeQuestionUsingQuestionCode(questionCode: "C14")
            var select = false
             if personSearch.questionoptions![0].isSelected || propertySearch.questionoptions![0].isSelected{
                select = true
              }
            if personSearch.questionoptions![1].isSelected || propertySearch.questionoptions![1].isSelected{
               select = false
             }
            for i in (0..<optionsArray!.count)
            {
                let optionId = optionsArray![i].option_id
                if optionId.count == 0 {
                    optionsArray![i].option_id = "0"
                }
                let items = optionsArray![i]
                let attr = items.physical_attribute
                print(items.option_value)
                if attr == "1"{
                    optionsArray![i].isSelected = select
                }
            }
        }
        
        if questionArray![questNumber!].question_code == "17"{
            let selectItem = optionsArray?.filter({
                $0.isSelected == true && $0.question_code_for_cascading_id == "C47"
            })
            if selectItem?.count ?? 0 > 0{
                let selectOptions = selectItem![0].questionoptions!.filter({
                    $0.isSelected == false
                })
                if selectOptions.count == 3 {
                    disableNextButton(View: nextView)
                } 
            }
        }
        
        if questionArray![questNumber!].question_code == "14"{
            let question = newRipaViewModel.getCascadeQuestionUsingQuestionCode(questionCode: "C2")
            let optionItem = question.questionoptions?.filter({$0.isSelected == true})
            let selectItem = optionsArray?.filter({
                $0.isSelected == true || $0.isExpanded == true
            })
           
            if selectItem?.count ?? 0 > 0{
                self.enableNextButton(View: nextView)
                if selectItem?[0].option_id == "91",optionItem?.count ?? 0 == 0 {
                    self.disableNextButton(View: nextView)
                }
            }
            else {
                self.disableNextButton(View: nextView)
            }
            
            if AppConstants.isTemplate == "temp",selectItem?.count ?? 0 > 0,selectItem?[0].question_code_for_cascading_id == "C1" {
                let objj =  newRipaViewModel.makeSelectedOptionList(isSaved: false)
                if objj[4].contains(where: {$0.ripa_id == "16"}) {
                    self.enableNextButton(View: nextView)
                }
            }
            
            if let objCount = optionsArray?.filter({$0.isSelected == true}),objCount.count == 0 {
                self.disableNextButton(View: nextView)
            }
            
            let objCount = optionsArray?.filter({$0.isSelected == true})
            var isReasonable : Bool = false
            if objCount?.count ?? 0 > 0,let check = objCount?.contains(where: {$0.cascade_ripa_id == "17"}) {
                isReasonable = check
            }
            if AppConstants.offenceCodes.count > 0,isReasonable == true {
                let cascadeQuestion = newRipaViewModel.getCascadeQuestionUsingId(questionID: 18)
                if cascadeQuestion.question_code == "C4" {
                    let objcts = cascadeQuestion.questionoptions?.filter({$0.isSelected == true})
                    if objcts?.count == 0 {
                        self.disableNextButton(View: nextView)
                    }
                }
            }
            
            let optt = optionsArray
            if let isProbble = optionsArray?.filter({$0.isSelected == true && $0.option_id == "1274"}),isProbble.count > 0 {
                let cascadeQ = newRipaViewModel.getCascadeQuestionUsingQuestionCode(questionCode: "C37")
                let probCount = cascadeQ.questionoptions?.filter({$0.isSelected == true})
                if probCount?.count == 0 {
                    self.disableNextButton(View: nextView)
                }
            }
            
            if let isreasonable = optionsArray?.filter({$0.isSelected == true && $0.option_id == "90"}),isreasonable.count > 0 {
                let cascadeQ = newRipaViewModel.getCascadeQuestionUsingQuestionCode(questionCode: "C4")
                let reasonCount = cascadeQ.questionoptions?.filter({$0.isSelected == true})
                if reasonCount?.count == 0 {
                    self.disableNextButton(View: nextView)
                }
            }
            
            let personDict = personArray[personcount]
            let selectedOptArray = personDict["SelectedOption"] as! [[Questionoptions1]]
            if selectedOptArray.count > 4 {
                let checkType = selectedOptArray[4].filter({$0.ripa_id == "15"})
                let checkTypeOption = selectedOptArray[4].filter({$0.ripa_id == "16"})
                if checkType.count > 0 && checkTypeOption.count > 0 {
                    self.enableNextButton(View: nextView)
                }
            }
        }
        
        if questionArray![questNumber!].question_code == "5" && self.durationTxtField.text?.count ?? 0 == 0{
            self.disableNextButton(View: nextView)
        }
        
        if questionArray![questNumber!].question_code == "5" && locTypeIndex == 4 {
            self.descriptionBtn.isHidden = false
        }

        return check.1
    }
    
    func getCascadeQuestionUsingQuestionCode(questionCode:String) -> QuestionResult1{
        var quest:QuestionResult1?
        for question in cascadeQuestionArray!{
            if question.question_code == questionCode{
                quest = question
            }
        }
        return quest!
    }
    
  
    func checkDescription(optionArr : [Questionoptions1]) -> Bool {
        var check : Bool = false
        var found : Bool = false
        for i in (0..<optionArr.count)
        {
            if optionArr[i].physical_attribute == "4"{
                check = true
            }
            if optionArr[i].physical_attribute.count>0 {
                found = true
            }
        }
        if check && found {
            return true
        }
      return false
    }
    
    
    func showDatePicker(){
        //Formate Date
        datePicker.datePickerMode = .date
        //Posiiton date picket within a view
        datePicker.frame = CGRect(x: 10, y: 50, width: self.view.frame.width, height: 200)
        let now = Date();
        datePicker.maximumDate = now
        datePicker.minimumDate = self.dateStringToDate(dateString: "2018-01-01")
        //Set some of UIDatePicker properties
        
        let checkDate = self.checkDate(stringDate: "2024-01-01")
        if checkDate == true {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.dateFormat = "yyyy-MM-dd"
            if let date = dateFormatter.date(from: "2024-01-01") {
                datePicker.minimumDate = date
            }
        }
        
        datePicker.timeZone = NSTimeZone.local
        datePicker.backgroundColor = UIColor.white
        //ToolBar
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        //toolbar = UIToolbar(frame: CGRect (x:0,y:0,width:self.view.frame.width,height:400))
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donedatePicker));
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker));
        
        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)
        
        dateTextField.inputAccessoryView = toolbar
        dateTextField.inputView = datePicker
        
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
    
    func dateStringToDate(dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.autoupdatingCurrent
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.date(from: dateString)
    }
    
    func showTimePicker(){
        //"[Expired]"
        
        timePicker.datePickerMode = .time
        timeTxtField.inputView = timePicker
        timePicker.locale = NSLocale(localeIdentifier: "en_GB") as Locale
        
        timePicker.frame = CGRect(x: 10, y: 50, width: self.view.frame.width, height: 200)
        let now = Date()
        
        print(viewType)
        
        if viewType == "StartNewRipa" ||  viewType == "Template"{
            timePicker.maximumDate = now
        }
        else {
            print(AppConstants.date)
            let checkDateStr = AppConstants.date.compareDateToCurrent(eventtDate: AppConstants.date)
            if checkDateStr == "[Expired]" {
                timePicker.date = now
            }
            else {
                timePicker.maximumDate = now
            }
        }
        
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donetimePicker));
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker));
        
        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: true)
        
        timeTxtField.inputAccessoryView = toolbar
    }
    
    
    @objc func donetimePicker(){
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let checkTime = self.checkDataDateTimeForCreateRipa(dttt: dateTextField.text!, timeT: formatter.string(from: timePicker.date))
        if checkTime && self.isEdit == false{
            self.showAlertMessage(titleStr: "", messageStr: "Another RIPA activity already exists with the same stop date, time and user.\n\nPlease validate and change the stop date and time in order to procees.")
        }
        else {
            timeTxtField.text = formatter.string(from: timePicker.date)
            AppConstants.time = timeTxtField.text!
        }
        self.view.endEditing(true)
    }
    
    var datetime = ""
    
    @objc func donedatePicker(){
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        let checkTime = self.checkDataDateTimeForCreateRipa(dttt: formatter.string(from: datePicker.date), timeT: timeTxtField.text!)
        if checkTime && self.isEdit == false{
            self.showAlertMessage(titleStr: "", messageStr: "Another RIPA activity already exists with the same stop date, time and user.\n\nPlease validate and change the stop date and time in order to procees.")
        }
        else {
            dateTextField.text = formatter.string(from: datePicker.date)
            datetime = dateTextField.text!
            AppConstants.date = dateTextField.text!
            if formatter.string(from: datePicker.date) < formatter.string(from: timePicker.date)
            {
                timePicker.maximumDate = nil
            }
            else{
                timePicker.maximumDate = Date()
            }
        }
        self.view.endEditing(true)
    }
    
    func checkDataDateTimeForCreateRipa(dttt : String, timeT : String) -> Bool {
        let userId =  "AND userid is " + (AppManager.getLastSavedLoginDetails()?.result?.userid)!
        var savedAllRipaList = [RipaTempMaster]()
        let combinedDateTime = "\(dttt) \(timeT)"
        savedAllRipaList = self.db.getRipaTempMaster(tableName: "SELECT * FROM ripaTempMasterTable WHERE mainStatus is NOT 1 \(userId) order by stopDate DESC") ?? []
        
        for data in savedAllRipaList {
            let dateFormatterGet = DateFormatter()
            dateFormatterGet.dateFormat = "MM/dd/yyyy HH:mm"
            let rDate = data.stopDate
            let rTime = data.stopTime
            if let datde = dateFormatterGet.date(from: rDate) {
                dateFormatterGet.dateFormat = "MM/dd/yyyy"
                let frDate = dateFormatterGet.string(from: datde) + " " + rTime
                if combinedDateTime ==  frDate{
                    return true
                }
            }
        }
     
        return false
    }
    
    func checkDateTimeForUpdate(dttt : String, timeT : String) -> Bool {
        let userId = AppManager.getLastSavedLoginDetails()?.result?.userid
        let ripaUserId = ripaActivity?.userid
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy HH:mm"
        
        let combinedDateTime = "\(dttt) \(timeT)"
        
        let ripaDate = AppConstants.date
        let ripaTime = AppConstants.time
        let ripaCombineDate = "\(ripaDate) \(ripaTime)"
        
        let ripaFinalDate = formatter.date(from: ripaCombineDate)
        
        if let releaseDate = formatter.date(from: combinedDateTime){
            if releaseDate == ripaFinalDate && userId == ripaUserId && self.isEdit == false{
                return true
            }
        }
        
        return false
    }
    
    
    @objc func cancelDatePicker(){
        dateTextField.resignFirstResponder()
        timeTxtField.resignFirstResponder()
    }
    
    
    func setRipaActivity(){
        
        var traini : String = "0"
        if  let userOption = UserDefaults.standard.object(forKey: "userOption") as? String,userOption == "Training/Testing" {
            traini = "1"
        }
        
        let os = ProcessInfo().operatingSystemVersion
     if viewType == "UseLastRipa"{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        AppConstants.date = dateFormatter.string(from: NSDate() as Date)
        dateFormatter.dateFormat = "HH:mm"
        AppConstants.time = dateFormatter.string(from: NSDate() as Date)
     }
        
       
        let getExperience = previewViewModel.calculateYearOfExp()
        ripaActivity = Ripaactivity(key: AppConstants.key, custid: previewViewModel.custId!, City: AppConstants.city, date_time: dateLbl.text!, userid: String(previewViewModel.userId!), username:  previewViewModel.userName!, Notes: AppConstants.notes, latitude: AppConstants.lati , longitude:  AppConstants.longi, start_date: startDate, end_date: "", deviceid: 0, Location: AppConstants.address, officer_experience: getExperience, is_K_12_Student: AppConstants.isStudent , CreatedBy:String(previewViewModel.userId!), ip_address: previewViewModel.strIPAddress , stop_date: AppConstants.date , stop_time: AppConstants.time, stop_duration: AppConstants.duration, app_version: previewViewModel.appVersion!, platform: "ios", traffic_id: AppConstants.trafficId, activity_status_id: AppConstants.activityStatusId, access_token: AppManager.getLastSavedLoginDetails()?.result?.access_token ?? "", timetaken: previewViewModel.getTimeTaken(), citation_number: AppConstants.citation, county_id: AppManager.getLastSavedLoginDetails()?.result?.county_id ?? "0", activity_id: AppConstants.activityID, time_duration_enable: AppConstants.ripaTimeDuration, call_number: AppConstants.call_number, onscene_time: AppConstants.onscene_time, clear_time_of_the_Offrcer: AppConstants.clear_time_of_the_Offrcer, overall_call_clear_time: AppConstants.overall_call_clear_time, call_type: AppConstants.call_type, unitId: AppConstants.unitId, zone: AppConstants.zone, ripaPersons: [], supervisorId: "", ripa_activity: AppConstants.activityID,os_version: os.getFullVersion(),is_trainee: traini, reason_for_stop: AppConstants.reason_for_stop)
        
    
        previewViewModel.ripaActivity = ripaActivity
        previewViewModel.questionArray = questionArray!
        previewViewModel.cascadeQuestionArray = cascadeQuestionArray!
    }
    
    
    @objc func swiperight(sender: UITapGestureRecognizer? = nil) {
        if questNumber! > 0{
            setOptionOrder()
            prevQuestion()
        }
    }
    
    @objc func swipeleft(sender: UITapGestureRecognizer? = nil) {
        if questNumber! < questionArray!.count-1{
            setOptionOrder()
            nextQuestion()
        }
    }
    
    
    func setOptionOrder(){
        questionArray![questNumber!].questionoptions = newRipaViewModel.moveSelectedToTop(Array:optionsArray!, questionCode: questionArray![questNumber!].question_code)
    }
    
    
    
    @objc func tick() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
        var dateInFormat = dateFormatter.string(from: NSDate() as Date)
        dateLbl.text = dateInFormat
        
        if dateTextField.text == ""{
            if (viewType != "UseSaveRipa" &&  viewType != "UseLastRipa") || AppConstants.isTemplate == "temp"{
                dateFormatter.dateFormat = "MM/dd/yyyy"
                dateInFormat = dateFormatter.string(from: NSDate() as Date)
                
                dateTextField.text = dateInFormat
                AppConstants.date = dateInFormat
                
                dateFormatter.dateFormat = "HH:mm"
                dateInFormat = dateFormatter.string(from: NSDate() as Date)
                
                
                timeTxtField.text = dateInFormat
                AppConstants.time = dateInFormat
            }
            
        }
    }
    
    
    func checkForDescription(){
        let isDiscriptionEntered = checkMandatorySelection()
        if isDiscriptionEntered == "No Description Found"{
            
             openDescriptionPopup()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [self] in
                enableNextButton(View: nextView)
            }
        }
    }
    
    
    @IBAction func actionSaveToServer(_ sender: Any) {
     let checkReasonStop = consensualEncounterAtSubmitting()
       if checkReasonStop == false{
          AppUtility.showAlertWithProperty("Alert", messageString: "Consensual encounter resulting in search was selected as a Reason for stop. Either Search of property was conducted or Search of Person was conducted must be selected for this question.")
          return
       }
        if questionArray![questNumber!].question_code == "21"{
            let selectItem = optionsArray?.filter({
                $0.isSelected == true
            })
            print(selectItem?.count)
            if selectItem?.count ?? 0 < 1 {
                AppUtility.showAlertWithProperty("Alert", messageString: "Result of stop is missing.")
                return
            }
        }
        durationTxtField.text = AppConstants.duration
        var durr : Float = 0
        if let durInt = durationTxtField.text {
            durr = Float(durInt) ?? 0
        }
       if durr < 1 {
           AppUtility.showAlertWithProperty("Alert", messageString: "Duration of stop should be between 1 to 1440 in minutes (24 hours).")
           return
       }
       if self.age != 0 && (self.age < 1 || self.age > 120){
           AppUtility.showAlertWithProperty("Alert", messageString: "Age should be greater than 1 & less than 120.")
           return
       }
        if self.age == 0 && questNumber == 2{
            AppUtility.showAlertWithProperty("Alert", messageString: "Age should be greater than 1 & less than 120.")
            return
        }
        
      
        if durr < 1 &&  questionArray![questNumber!].question_code == "5" && AppConstants.LocTypeIndex == 0 && AppConstants.LocTypeDescription.count == 0{}
        else if questionArray![questNumber!].question_code == "5" && AppConstants.LocTypeIndex == 0 && AppConstants.LocTypeDescription.count == 0{}
        else {
            trackApplicationTime()
            savetoServer(showAlertForSave: true)
        }
    }
    
    @IBAction func addPersionBtn(_ sender: Any) {
        trackApplicationTime()
        createPersonDict(checkEditHidden: true)
        self.checkRequiredForAddPerson()
    }
    
    
    
    func checkRequiredForAddPerson(){
        let requiredFilledData = previewViewModel.checkRequiredQuestion(questArray: questionArray, cascadeQuestArray: cascadeQuestionArray, selectedOpt: selectedOptionsArray)
        
         if requiredFilledData.0.count < 1 {
            self.addPerson(personIndex:personcount, personArray: personArray)
        }
        else{
            guard let customAlertVC1 = pendingQuestionPopup else { return }
            customAlertVC1.pendingQuestionDelegate = self
            customAlertVC1.newquestionArry = requiredFilledData.0
            customAlertVC1.newquestionIDArray = requiredFilledData.1
            
            customAlertVC1.personArray = personArray
            customAlertVC1.personIndex = personcount
            let popupVC = PopupViewController(contentController: customAlertVC1, position:.bottom(UIScreen.main.bounds.size.width/2), popupWidth: UIScreen.main.bounds.size.width-30, popupHeight:500)
            popupVC.cornerRadius = 5
            popupVC.delegate = self
            
            present(popupVC, animated: true, completion: nil)
        }
        
    }
    
    
    @IBAction func actionPrev(_ sender: Any) {
        trackApplicationTime()
        setOptionOrder()
        prevQuestion()
    }
    
    
    var nextEnabled = true
    @IBAction func actionNext(_ sender: Any) {
         if consensualEncounter() == false{
             AppUtility.showAlertWithProperty("Alert", messageString: "Consensual encounter resulting in search was selected as a Reason for stop. Either Search of property was conducted or Search of Person was conducted must be selected for this question.")
             return
        }
        durationTxtField.text = AppConstants.duration
        print(locTypeIndex)
        AppConstants.LocTypeIndex = locTypeIndex
        var durr : Float = 0
        if let durInt = durationTxtField.text {
            durr = Float(durInt) ?? 0
        }
        print("ActionNext")
        print(durr)
        if durr < 1 {
            AppUtility.showAlertWithProperty("Alert", messageString: "Duration of stop should be between 1 to 1440 in minutes (24 hours).")
            return
        }
        if is_k12 ?? false && AppConstants.schoolName.count == 0 && optionsArray![2].isSelected && optionsArray![2].isSelected == true {
            AppUtility.showAlertWithProperty("", messageString: "Please Select School.")
            return
        }
        if self.age != 0 && (self.age < 1 || self.age > 120){
            AppUtility.showAlertWithProperty("Alert", messageString: "Age should be greater than 1 & less than 120.")
            return
        }
        if self.age == 0 && questNumber == 2{
            AppUtility.showAlertWithProperty("Alert", messageString: "Age should be greater than 1 & less than 120.")
            return
        }
        
        if questionArray![questNumber!].question_code == "14"{
            let index = questionArray![questNumber!].questionoptions!.count - 1
            let text = (questionArray![questNumber!].questionoptions![index] ).option_value
            self.descriptionStrFirst = text
        }
       
        if questionArray![questNumber!].question_code == "17" && self.descriptionStr.count < 1{
            checkForDescription()
        }
        else if questionArray![questNumber!].question_code == "14" && self.descriptionStrFirst.count < 1{
            checkForDescription()
        }
        else if nextEnabled == false{
            checkForDescription()
        }
        else{
            disableNextButton(View: nextView)
            trackApplicationTime()
            setOptionOrder()
           
            nextQuestion()
        }
        
        
 }
    
    
    @IBAction func actionAutoNext(_ sender: Any) {
        // isChecked = !isChecked
        AppConstants.autoNext = !AppConstants.autoNext!
        autoNextBtn.setImage(UIImage(named: AppConstants.autoNext == true ? "checked" : "unchecked"), for: .normal)
    }
    
    @IBAction func actionBack(_ sender: Any) {
        print(viewType)
        if viewType == "StartNewRipa" ||  viewType == "Template" || AppConstants.status == "Created"{
            trackApplicationTime()
            save()
        }
        else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    
    @IBAction func actionReset(_ sender: Any) {
        trackApplicationTime()
        resetArray()
        loadData()
    }
    
    
    @IBAction func actionSave(_ sender: Any) {
        if consensualEncounter() == false{
            AppUtility.showAlertWithProperty("Alert", messageString: "Consensual encounter resulting in search was selected as a Reason for stop. Either Search of property was conducted or Search of Person was conducted must be selected for this question.")
            return
       }
        print(locTypeIndex)
        AppConstants.LocTypeIndex = locTypeIndex
        durationTxtField.text = AppConstants.duration
   
        trackApplicationTime()
        createPersonDict(checkEditHidden: true)
        if questionArray![questNumber!].question_code == "21"{
            let selectItem = optionsArray?.filter({
                $0.isSelected == true
            })
            print(selectItem?.count)
            if selectItem?.count ?? 0 < 1 {
                AppUtility.showAlertWithProperty("Alert", messageString: "Result of stop is missing.")
                return
            }
        }
        
        var durr : Float = 0
        if let durInt = durationTxtField.text {
            durr = Float(durInt) ?? 0
        }
        if durr < 1 &&  questionArray![questNumber!].question_code == "5" && AppConstants.LocTypeIndex == 0 && AppConstants.LocTypeDescription.count == 0{}
        else if questionArray![questNumber!].question_code == "5" && AppConstants.LocTypeIndex == 0 && AppConstants.LocTypeDescription.count == 0{}
        else {
            self.performSegue(withIdentifier: "ShowPreview", sender: self)
        }

    }
    
    
    @IBAction func actionCounty(_ sender: Any) {
        openCountyList(countylist:countyList)
    }
    
    
    func countyChanged(resetLoc: Bool) {
        AppConstants.city = ""
        street = ""
        getCounty()
        print(cityID)
        if resetLoc == true{
            let cityQuest = newRipaViewModel.getCascadeQuestionUsingQuestionCode(questionCode: "C6")
            cityQuest.questionoptions?.removeAll()
            cityID = ""
            resetLocation(onGPS: false)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                self.openList(index:0)
            }
        }
    }
    
    func savetoServer(showAlertForSave:Bool){
        self.showAlertForSave = showAlertForSave
        self.isSubmit = false
        AppUtility.showProgress(nil, title:nil)
        self.loginModel.updateVesionApp()
    }
    
    
    @IBAction func actionSubmit(_ sender: Any) {
        self.isSubmit = true
        AppUtility.showProgress(nil, title:nil)
        self.loginModel.updateVesionApp()
    }
    
    func currentVersionIsRunning() {
        if self.isSubmit == true {
            self.submitRipaData()
        }
        else {
            self.saveRipaData()
        }
    }
    
    func saveRipaData() {
        AppUtility.showProgress(nil, title:nil)
        setRipaActivity()
        previewViewModel.saveDelegate = self
        previewViewModel.ripaActivityArray.removeAll()
        createPersonDict(checkEditHidden: true)
        previewViewModel.previewModelDelegate = self
        
        var traini : String = "0"
     
        if  let userOption = UserDefaults.standard.object(forKey: "supervisorId") as? String{
            ripaActivity?.supervisorId = userOption
        }
       
        if  let userOption = UserDefaults.standard.object(forKey: "userOption") as? String,userOption == "Training/Testing" {
            traini = "1"
        }
        if  let userOption = UserDefaults.standard.object(forKey: "userOption") as? String,userOption == "Training/Testing" {
            traini = "1"
        }
        
        let os = ProcessInfo().operatingSystemVersion
        ripaActivity?.os_version = os.getFullVersion()
        ripaActivity?.is_trainee = traini
        
        if AppConstants.trafficId != ""{
            print(AppConstants.trafficId)
            ripaActivity?.traffic_id = AppConstants.trafficId
        }
        ripaActivity?.is_K_12_Student = "0"
        if let check = is_k12,check == true {
            ripaActivity?.is_K_12_Student = "1"
        }
        
        db.openDatabase()
        var userRipaResponse : RipaResponse = db.getRipaResponse()!
       
        if userRipaResponse.question_id.isEmpty {
             userRipaResponse  = self.createRipaResponseData(data: self.userSettingArray)
        }
        var temp1 : String!
        if  let userOption = UserDefaults.standard.object(forKey: "userOption") as? String{
            temp1 = "\(userOption)"
            userRipaResponse.response = temp1
        }
       
      
        ripaActivity?.os_version = os.getFullVersion()
        ripaActivity?.is_trainee = traini
        
        if AppConstants.trafficId != ""{
            print(AppConstants.trafficId)
            ripaActivity?.traffic_id = AppConstants.trafficId
        }
        
        userRipaResponse.ripa_activity = AppConstants.activityID
      
        
        // previewViewModel.setKey()
        self.saveRipaDataToCSV(custid: self.ripaActivity!.custid)
        previewViewModel.ripaActivity = self.ripaActivity
        AppConstants.activityStatusId = "9"
        previewViewModel.createPersonsDict(personArray: self.personArray, ripaActivity: ripaActivity!, statusId: "9", ripaResponse: userRipaResponse )
        let updateRipa:UpdateRipa = self.previewViewModel.updateRipaParam()
        self.previewViewModel.saveToDB(updateRipa: updateRipa, isUpdate: true, syncSccessful: "")
        previewViewModel.submitParam(params: updateRipa, toSave: true, showAlertForSave: self.showAlertForSave)
    }
    
    func submitRipaData() {
        let checkReasonStop = consensualEncounterAtSubmitting()
       if checkReasonStop == false{
          AppUtility.showAlertWithProperty("Alert", messageString: "Consensual encounter resulting in search was selected as a Reason for stop. Either Search of property was conducted or Search of Person was conducted must be selected for this question.")
          return
       }
      if questionArray![questNumber!].question_code == "21"{
          let selectItem = optionsArray?.filter({
              $0.isSelected == true
          })
         // print(selectItem?.count)
          if selectItem?.count ?? 0 < 1 {
              AppUtility.showAlertWithProperty("Alert", messageString: "Result of stop is missing.")
              return
          }
      }
          AppUtility.showProgress(nil, title:nil)
          trackApplicationTime()
          createPersonDict(checkEditHidden:true)
          let personDict = personArray[personcount]
        //  print(personDict)
          let questArr = (personDict["QuestionArray"] as! [QuestionResult1])
         // print(questArr)
          let cascadeQuestArr = (personDict["CascadeQuestionArray"] as! [QuestionResult1])
       //   print(cascadeQuestArr)
          selectedOptionsArray = personDict["SelectedOption"] as! [[Questionoptions1]]
       //   print(selectedOptionsArray)
          let requiredFilledData = previewViewModel.checkRequiredQuestion(questArray: questArr, cascadeQuestArray: cascadeQuestArr, selectedOpt: selectedOptionsArray)
          
          if requiredFilledData.0.count < 1 {
              previewViewModel.previewModelDelegate = self
              previewViewModel.viewType = viewType
              previewViewModel.personArray = personArray
             // print(personArray)
             
              db.openDatabase()
              var userRipaResponse : RipaResponse = db.getRipaResponse()!
              
              
              if userRipaResponse.question_id.isEmpty {
                   userRipaResponse  = self.createRipaResponseData(data: self.userSettingArray)
              }
              var typeAssignment : String = ""
              if  let userOption = UserDefaults.standard.object(forKey: "userOption") as? String{
                  typeAssignment = "\(userOption)"
                  userRipaResponse.response = typeAssignment
              }
              if  let userOption = UserDefaults.standard.object(forKey: "supervisorId") as? String{
                  ripaActivity?.supervisorId = userOption
              }
              var traini : String = "0"
              if  let userOption = UserDefaults.standard.object(forKey: "userOption") as? String,userOption == "Training/Testing" {
                  traini = "1"
              }
              
              let os = ProcessInfo().operatingSystemVersion
              ripaActivity?.os_version = os.getFullVersion()
              ripaActivity?.is_trainee = traini
              
              if AppConstants.trafficId != ""{
                  print(AppConstants.trafficId)
                  ripaActivity?.traffic_id = AppConstants.trafficId
              }
              
              userRipaResponse.ripa_activity = AppConstants.activityID
              ripaActivity?.ripa_activity = AppConstants.activityID
              ripaActivity?.is_K_12_Student = "0"
              
              if let check = is_k12,check == true {
                  ripaActivity?.is_K_12_Student = "1"
              }
              if AppConstants.isTemplate == "temp" {
                  AppConstants.activityStatusId = "1"
                  ripaActivity?.activity_status_id = "1"
              }
              else if isEditRequired{
                  AppConstants.activityStatusId = "4"
                  ripaActivity?.activity_status_id = "4"
              }
              else if isPendingEdit {
                  AppConstants.activityStatusId = "1"
                  ripaActivity?.activity_status_id = "1"
              }
              else {
                  AppConstants.activityStatusId = "1"
                  ripaActivity?.activity_status_id = "1"
              }
              
              print(screenType)
           
              db.insertRipaResponse(ripaRes: userRipaResponse)
              previewViewModel.createUserSettingPersonsDict(personArray: personArray, ripaActivity: ripaActivity!, statusId: "1", ripaResponse: userRipaResponse)
                  
              self.saveRipaDataToCSV(custid: ripaActivity!.custid)
              
              if typeAssignment.count == 0{
                  AppUtility.showAlertWithProperty("", messageString: "Type of assignment is blank.")
              }
              else if isEditRequired {
                  let updateRipa:UpdateRipa = previewViewModel.ripaCudActivity_postParam()
                 // print(updateRipa)
                  previewViewModel.submitParam(params: updateRipa, toSave: false, showAlertForSave: false)
              }
              else if isCreatedSaved {
                  let updateRipa:UpdateRipa = previewViewModel.updateRipaParam()
                 // print(updateRipa)
                  previewViewModel.submitParam(params: updateRipa, toSave: false, showAlertForSave: false)
              }
              else if viewType == "UseSaveRipa" && saveRipaStatus == "Saved"{
                   let updateRipa:UpdateRipa = previewViewModel.ripaCudActivity_postParam()
                  // print(updateRipa)
                   previewViewModel.submitParam(params: updateRipa, toSave: false, showAlertForSave: false)
               }
              else if saveRipaStatus == "Saved"{
                  let updateRipa:UpdateRipa = previewViewModel.updateRipaParam()
                 // print(updateRipa)
                  previewViewModel.submitParam(params: updateRipa, toSave: false, showAlertForSave: false)
              }
              else {
                  AppConstants.activityID = ""
                  let updateRipa:UpdateRipa = previewViewModel.updateRipaParam()
                 // print(updateRipa)
                  previewViewModel.submitParam(params: updateRipa, toSave: false, showAlertForSave: false)
              }
          }
          else{
              AppUtility.hideProgress()
              self.submitBtn.isUserInteractionEnabled = true
              guard let customAlertVC1 = pendingQuestionPopup else { return }
              customAlertVC1.pendingQuestionDelegate = self
              customAlertVC1.newquestionArry = requiredFilledData.0
              customAlertVC1.newquestionIDArray = requiredFilledData.1
              
              customAlertVC1.personArray = personArray
              customAlertVC1.personIndex = personcount
              let popupVC = PopupViewController(contentController: customAlertVC1, position:.bottom(UIScreen.main.bounds.size.width/2), popupWidth: UIScreen.main.bounds.size.width-30, popupHeight:500)
              popupVC.cornerRadius = 5
              popupVC.delegate = self
              
              present(popupVC, animated: true, completion: nil)
              NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newDataNotif"), object: nil)
          }
    }
    
    func saveRipaDataToCSV(custid : String) {
        let ripa1 = ["Location":AppConstants.address,"activity_id" :AppConstants.activityID,"custid":custid,"Basis_for_search":self.descriptionStr,"Reason_for_stop":self.descriptionStr] as [String : Any]
      
        let data:NSMutableArray  = NSMutableArray()
        data.add(ripa1)
        
        let header = ["Location", "activity_id", "custid", "Basis_for_search","Reason_for_stop"]
        // Create a object for write CSV
        let writeCSVObj = CSV()
        writeCSVObj.rows = data
        writeCSVObj.delimiter = DividerType.comma.rawValue
        writeCSVObj.fields = header as NSArray
        writeCSVObj.name = "custId_activityId"
        
        // Write File using CSV class object
        let output = CSVExport.export(writeCSVObj)
     

        if output.result.isSuccess {
            guard let filePath =  output.filePath else {
                print("Export Error: \(String(describing: output.message))")
                return
            }
            
            print("File Path: \(filePath)")
            self.readCSVPath(filePath)
        } else {
            print("Export Error: \(String(describing: output.message))")
        }
    }
    
    func readCSVPath(_ filePath: String) {

        let request = NSURLRequest(url:  URL(fileURLWithPath: filePath) )
        //webview.loadRequest(request as URLRequest)
        print(request)
        // Read File and convert as CSV class object
        let csvFile = CSVExport.readCSVObject(filePath);
        print(csvFile)
        // Use 'SwiftLoggly' pod framework to print the Dictionary
//        loggly(LogType.Info, text: readCSVObj.name)
//        loggly(LogType.Info, text: readCSVObj.delimiter)
    }
    
    
    func createRipaResponseData(data:UserSettingModel) -> RipaResponse {
        let optionArray = data.option?.filter({ item in
            item.is_select == true
        })
        let idUser = (AppManager.getLastSavedLoginDetails()?.result?.userid)!
        var questionId : String = ""
        if let qId = data.question?.id {
            questionId = qId
        }
        
        var rep : String = ""
        if let respo = data.question?.response {
            rep = respo
        }
        
        var inter : String = ""
        if let respo = data.question?.internall {
            inter = respo
        }
        
        var questn : String = ""
        if let respo = data.question?.question {
            questn = respo
        }
        
        var cDate : String = ""
        if let respo = data.question?.CreatedBy {
            cDate = respo
        }
        
        var attri : String = ""
        if let respo = optionArray?[0].physical_attribute {
            attri = respo
        }
        
        var keyS : String = ""
        if let respo = data.question?.question_key {
            keyS = respo
        }
        
        var pId : String = ""
        if let respo = data.supervisor?[0].PersonId {
            pId = respo
        }
        
        var qCode : String = ""
        if let respo = data.question?.question_code {
            qCode = respo
        }
        
        var orderN : String = ""
        if let respo = optionArray?[0].order_number {
            orderN = respo
        }
        
        var opId : String = "0"
        if let respo = optionArray?[0].option_id {
            opId = respo
        }
        
        var mId : String = ""
        if let respo = data.question?.id {
            mId = respo
        }
        
        var supId : String = ""
        if let arr = data.supervisor,let respo = arr[0].SupervisorId {
            supId = respo
        }
        
        var traini : String = "0"
        if  let userOption = UserDefaults.standard.object(forKey: "userOption") as? String,userOption == "Training/Testing" {
            traini = "1"
        }
        
        let os = ProcessInfo().operatingSystemVersion
        
        let ripaRes = RipaResponse(question_id: questionId, response: rep, internal: inter, userid: idUser, question: questn, CreatedBy: cDate, physical_attribute: attri, key: keyS, personId: pId, description: "", question_code: qCode, cascade_ques_id: "0", order_number: orderN, option_id: opId, cascade_option_id: "0", main_question_id: mId, supervisorId: supId, other_assignment_value: "", activity_id: AppConstants.activityID, ripa_activity: AppConstants.activityID,os_version : os.getFullVersion(), is_trainee: traini, isSelected: "")
        
        return ripaRes
    }
    
    func openCountyList(countylist:[CountyResult]){
        let listView = self.storyboard?.instantiateViewController(withIdentifier: "ListViewController") as! ListViewController
        listView.locationdelegate = self
        listView.listType = "County"
         let ccArray = countylist.sorted(by: { (Obj1, Obj2) -> Bool in
              let Obj1_Name = Obj1.countyName
              let Obj2_Name = Obj2.countyName
              return (Obj1_Name.localizedCaseInsensitiveCompare(Obj2_Name) == .orderedAscending)
           })
        listView.countyArray = ccArray
        self.navigationController?.present(listView, animated: true, completion: nil)
    }
    
    func setPreviewDelegate() {
        
    }
    
    func gotoselectedQuestion(index: Int, personArray: [[String : Any]]) {
        self.personArray = personArray
        questNumber = index
        splitOptions()
    }
    
    func setPreviewDelegate(success: String, message: String) {
       // if message == "Success"{
            if viewType == "UseSaveRipa"{
                //               self.db.openDatabase()
                //                self.db.deleteAllfrom(table: "saveRipaPersonTable")
                //                self.db.deleteAllfrom(table: "useSaveRipaOptionsTable")
            }
            AppConstants.notes = ""
            
            self.performSegue(withIdentifier: "ShowSuccess", sender: self)
           
      //  }
    }
    
    
    func goToDashboard(){
        let alert = UIAlertController(title: nil, message: "Submitted Succesfully", preferredStyle: UIAlertController.Style.alert)
        //  alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
            
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "DashBoardViewController") as! DashBoardViewController
            let navigationController = UINavigationController(rootViewController: nextViewController)
            UIApplication.shared.windows.first?.rootViewController = navigationController
            UIApplication.shared.windows.first?.makeKeyAndVisible()
             }
           )
        )
        self.present(alert, animated: true, completion: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        let segueID = segue.identifier
        if(segueID! == "ShowPreview"){
            
            let vc = segue.destination as! PreviewViewController
            vc.selectedIndexDelegate = self
            vc.addressString = completeAddressStr
            vc.questionsArray = questionArray!
            vc.descriptionString = self.descriptionStr
            vc.cascadeQuestionsArray = cascadeQuestionArray!
            vc.personIndex = personcount
            vc.isCreatedSaved = self.isCreatedSaved
            vc.isEditRequired = self.isEditRequired
            vc.personArray = personArray
           // let arr = personArray
            vc.saveRipaStatus = saveRipaStatus
            vc.viewType = viewType
            vc.isPendingEdit = isPendingEdit
            vc.ripaActivity = ripaActivity
        }
        else if(segueID! == "ShowSuccess"){
            let vc = segue.destination as! SuccessViewController
            if viewType == "UseSaveRipa" && saveRipaStatus == "Saved"{
                vc.viewType = "Saved"
            }
            else{
                vc.viewType = "New"
            }
        }
    }
    
    

    
    func createPersonDict(checkEditHidden:Bool){
        
        previewViewModel.ripaActivity = ripaActivity
        
        var questarr = [QuestionResult1]()
        var cascadeQuestArr = [QuestionResult1]()
        for quest in questionArray!{
            let ques = quest.copy()
            questarr.append(ques as! QuestionResult1)
        }
     
        for cascadeQues in cascadeQuestionArray!{
            let cascadeQuest = cascadeQues.copy()
            cascadeQuestArr.append(cascadeQuest as! QuestionResult1)
        }
        
        newRipaViewModel.questionsArray = questionArray
       
        newRipaViewModel.cascadeQuestionArray = cascadeQuestionArray
       
        selectedOptionsArray = newRipaViewModel.makeSelectedOptionList(isSaved: false)
        
        if AppConstants.isTrafficData == true ,personcount < personArray.count {
            var personDict = personArray[personcount]
            var objj = personDict["SelectedOption"] as! [[Questionoptions1]]
            var saveObj = [Questionoptions1]()
            for copyObj in objj[4] {
                let isPresent = saveObj.contains(where: {$0.option_value == copyObj.option_value})
                if isPresent == false,copyObj.option_value.count > 0 {
                    saveObj.append(copyObj)
                }
            }
            
            objj[4] = saveObj
            personDict["SelectedOption"] = objj
            personArray[personcount] = personDict
        }
        
        var arrrt = selectedOptionsArray
        
        if ((viewType != "StartNewRipa" && AppConstants.status != "LastRipa" && AppConstants.status != "Template" && saveRipaStatus != "Created") || AppConstants.isTemplate == "temp") && !(personArray.count > AppConstants.numberOfPerson) && personcount < personArray.count {
            let personDict = personArray[personcount]
            selectedOptionsArray = personDict["SelectedOption"] as! [[Questionoptions1]]
         
            if  selectedOptionsArray.count > 4,arrrt.count > 4,arrrt[4].count > 0 {
                if arrrt[4][0].mainQuestId == "14",arrrt[4][0].cascade_ripa_id.count > 0 {
                    selectedOptionsArray[4][0] = arrrt[4][0]
                }
                selectedOptionsArray[4] = self.removeDuplicateElements(posts: selectedOptionsArray[4])
                let isExist = selectedOptionsArray[4].contains(where: {$0.cascade_ripa_id == "70"})
                if isExist {
                    let optArr = newRipaViewModel.createProbaleCaseToArrestOption()
                    let opt1 = selectedOptionsArray[4].contains(where: {$0.cascade_ripa_id == "71"})
                    let opt2 = selectedOptionsArray[4].contains(where: {$0.cascade_ripa_id == "72"})
                    if selectedOptionsArray[4].count > 1,opt1 == false{
                        selectedOptionsArray[4].insert(optArr[0], at: 1)
                    }
                    else if opt1 == false{
                        selectedOptionsArray[4].append(optArr[0])
                    }
                    if opt2 == false {
                        selectedOptionsArray[4].insert(optArr[1], at: selectedOptionsArray[4].count - 2)
                    }
                }
               // let arrr5 = selectedOptionsArray
            }
            if selectedOptionsArray.count > 7,arrrt.count > 7,arrrt[7].count > 0 {
                selectedOptionsArray[7] = arrrt[7]
                let selectArray = personDict["SelectedOption"] as! [[Questionoptions1]]
                let personObj = selectedOptionsArray[7].filter({$0.cascade_ripa_id == "31"})
                if personObj.count > 0 , personObj[0].questionoptions?.count ?? 0 > 0 {
                   
                    selectedOptionsArray[7].removeAll(where: {$0.option_id == "145"})
                    selectedOptionsArray[7].removeAll(where: {$0.option_id == "146"})
                   
                    let obj1 = personObj[0].questionoptions?.filter({$0.isSelected == true})
                    if obj1?.count ?? 0 > 0{
                        if obj1?[0].option_value.capitalized == "Consent Given" {
                            obj1?[0].option_id = "144"
                        }
                        else if obj1?[0].option_value.capitalized == "Consent Not Given" {
                            obj1?[0].option_id = "143"
                        }
                        let index = selectedOptionsArray[7].firstIndex(where: {$0.cascade_ripa_id == "31"})
                        obj1?[0].ripa_id = "31"
                        selectedOptionsArray[7].insert((obj1?[0])!, at: index! + 1)
                    }
                }
                else {
                    let checkP = selectedOptionsArray[7].contains(where: {$0.cascade_ripa_id == "31"})
                    selectedOptionsArray[7].removeAll(where: {$0.option_id == "145"})
                    selectedOptionsArray[7].removeAll(where: {$0.ripa_id == "72"})
                    selectedOptionsArray[7].removeAll(where: {$0.option_id == "146"})
                    let findObj = selectArray[7].filter({$0.ripa_id == "31"})
                    if checkP == true,findObj.count > 0{
                        if findObj[0].option_value.capitalized == "Consent Given" {
                            findObj[0].option_id = "144"
                        }
                        else if findObj[0].option_value.capitalized == "Consent Not Given" {
                            findObj[0].option_id = "143"
                        }
                        selectedOptionsArray[7].append(findObj[0])
                    }
                }
               
                let propertyObj = selectedOptionsArray[7].filter({$0.cascade_ripa_id == "32"})
                if propertyObj.count > 0, propertyObj[0].questionoptions?.count ?? 0 > 0 {
                    let obj2 = propertyObj[0].questionoptions?.filter({$0.isSelected == true})
                   
                    if obj2?.count ?? 0 > 0{
                        if obj2?[0].option_value.capitalized == "Consent Given" {
                            obj2?[0].option_id = "146"
                        }
                        else if obj2?[0].option_value.capitalized == "Consent Not Given" {
                            obj2?[0].option_id = "145"
                        }
                        obj2?[0].ripa_id = "32"
                        let index = selectedOptionsArray[7].firstIndex(where: {$0.cascade_ripa_id == "32"})
                        selectedOptionsArray[7].insert((obj2?[0])!, at: index! + 1)
                    }
                }
                else {
                    let checkPr = selectedOptionsArray[7].contains(where: {$0.cascade_ripa_id == "32"})
                    let checkPrc = selectedOptionsArray[7].contains(where: {$0.ripa_id == "32"})
                    let findObj = selectArray[7].filter({$0.ripa_id == "32"})
                    if checkPr == true,checkPrc == false,findObj.count > 0 {
                        let findObj = selectArray[7].filter({$0.ripa_id == "32"})
                        if findObj[0].option_value.capitalized == "Consent Given" {
                            findObj[0].option_id = "146"
                        }
                        else if findObj[0].option_value.capitalized == "Consent Not Given" {
                            findObj[0].option_id = "145"
                        }
                        selectedOptionsArray[7].append(findObj[0])
                    }
                    else if checkPr == true,checkPrc == false {
                        let objt = newRipaViewModel.createNonForceRelatedActionOption()
                        objt[0].option_id = "146"
                        objt[0].ripa_id = "32"
                        let index = selectedOptionsArray[7].firstIndex(where: {$0.cascade_ripa_id == "32"})
                        selectedOptionsArray[7].insert(objt[0], at: index! + 1)
                    }
                   
                }
            }
          //  let ar2 = selectedOptionsArray
            if selectedOptionsArray.count > 8,arrrt.count > 8,arrrt[8].count > 0 {
                let isExist = arrrt[8].contains(where: {$0.ripa_id == "84"})
                let obj = selectedOptionsArray[8].filter({$0.ripa_id == "84"})
                if obj.count > 0,isExist == false{
                    arrrt[8].insert(obj[0], at: 1)
                }
                selectedOptionsArray[8] = arrrt[8]
            }
            if selectedOptionsArray.count > 9,arrrt.count > 9,arrrt[9].count > 0 {
                selectedOptionsArray[9] = arrrt[9]
            }
            if selectedOptionsArray.count > 10,arrrt.count > 10,arrrt[10].count > 0 {
                selectedOptionsArray[10] = arrrt[10]
            }
            if selectedOptionsArray.count > 11,arrrt.count > 11,arrrt[11].count > 0 {
                selectedOptionsArray[11] = arrrt[11]
            }
            if selectedOptionsArray.count > 12 {
               let exist = selectedOptionsArray[12].contains(where: {
                   $0.option_value.capitalized == "Written Warning"
                })
                let isConatin = selectedOptionsArray[12].contains(where: {
                    $0.option_id == "1291"
                 })
                if exist == true && isConatin == false{
                    if selectedOptionsArray[12].count > 1{
                        selectedOptionsArray[12].insert(newRipaViewModel.setWrittenWarningOption(), at: 1)
                    }
                    else {
                        selectedOptionsArray[12].append(newRipaViewModel.setWrittenWarningOption())
                    }
                }
            }
            if selectedOptionsArray.count > 2 {
                for i in (0 ..< (selectedOptionsArray[2].count )) {
                    if selectedOptionsArray[2][i].ripa_id == "68" && selectedOptionsArray[2][i].option_value == "No" {
                        let index = selectedOptionsArray[2].firstIndex(where: {
                            $0.cascade_ripa_id == "68"
                        })
                        selectedOptionsArray[2][index!].isSelected = false
                    }
                }
                if selectedOptionsArray[2][1].option_value == "No" {
                    selectedOptionsArray[2][0].isSelected = false
                }
                else if selectedOptionsArray[2][1].option_value.capitalized == "Yes" {
                    let option1:Questionoptions1 = Questionoptions1(mainQuestId: "62", mainQuestOrder:"3" ,option_id: "1247", ripa_id:"62", custid: "", option_value: "Yes", cascade_ripa_id: "", isK_12School: "", isHideQuesText: "", order_number: "3", createdBy: "", createdOn: "", updatedBy: "", updatedOn: "", isSelected: true, isAddtion: "", isDescription_Required : "",inputTypeCode : "", questionTypeCode: "", tag: "", physical_attribute: "", default_value: "", optionDescription: "", question_code_for_cascading_id: "", isQuestionMandatory: "", isQuestionDescriptionReq: "", main_question_id: "61", isExpanded: false, isNewAdded: false, mainId: "", questionoptions: [])
                    selectedOptionsArray[2].remove(at: 1)
                    selectedOptionsArray[2].append(option1)
                    selectedOptionsArray[2][0].isSelected = true
                }
            }
            let selectArr = newRipaViewModel.makeSelectedOptionList(isSaved: false)
            if questionArray![questNumber!].question_code == "21" , selectArr.count > 12{
                for obj in selectArr[12] {
                    let exist = selectedOptionsArray[12].contains(where: {
                        $0.option_value == obj.option_value
                    })
                    if exist == false{
                        selectedOptionsArray[12].append(obj)
                    }
                }
            }
           else if questionArray![questNumber!].question_code == "T7" , selectArr.count > 7{
               for obj in selectArr[7] {
                   let exist = selectedOptionsArray[7].contains(where: {
                       $0.option_value == obj.option_value
                   })
                   if exist == false{
                       selectedOptionsArray[7].append(obj)
                   }
               }
            }
            else if questionArray![questNumber!].question_code == "14" , selectArr.count > 4{
                //selectedOptionsArray[4] = selectArr[4]
            }
            else if questionArray![questNumber!].question_code == "T4" , selectArr.count > 5{
                for obj in selectArr[5] {
                    let exist = selectedOptionsArray[5].contains(where: {
                        $0.option_value == obj.option_value
                    })
                    if exist == false{
                        selectedOptionsArray[5].append(obj)
                    }
                }
             }
            else if questionArray![questNumber!].question_code == "T8" , selectArr.count > 6{
                for obj in selectArr[6] {
                    let exist = selectedOptionsArray[6].contains(where: {
                        $0.option_value == obj.option_value
                    })
                    if exist == false{
                        selectedOptionsArray[6].append(obj)
                    }
                }
             }
        }
        else if (viewType != "StartNewRipa" && AppConstants.status != "LastRipa" && AppConstants.status != "Template" && saveRipaStatus != "Created") || AppConstants.isTemplate == "temp" {
           //// let arrrV = selectedOptionsArray
            if selectedOptionsArray.count > 2,selectedOptionsArray[2].count > 1,selectedOptionsArray[2][1].option_value == "Perceived Age?" {
                selectedOptionsArray[2][2].option_value = String(self.age)
            }
            else if selectedOptionsArray.count > 2,selectedOptionsArray[2].count > 1,selectedOptionsArray[2][1].option_value == "Perceived Age?" {
                selectedOptionsArray[2][3].option_value = String(self.age)
            }
            
            let personDict = personArray[0]
            let selectArray = personDict["SelectedOption"] as! [[Questionoptions1]]
            if selectArray.count > 1, selectArray[1].count > 0 {
                selectedOptionsArray[1] = selectArray[1]
            }
            
            if selectedOptionsArray.count > 12{
                for obj in selectArray[12] {
                    if !selectedOptionsArray[12].contains(where: {$0.option_value == obj.option_value}) {
                        selectedOptionsArray[12].append(obj)
                    }
                }
                selectedOptionsArray[12] = selectedOptionsArray[12].uniqued()
             //   let objj = selectedOptionsArray[12]
                if selectedOptionsArray[12].contains(where: {$0.question_code_for_cascading_id == "C22" && $0.question_code_for_cascading_id != "C15"}) {
                    if let firstIndex = selectedOptionsArray[12].firstIndex(where: {$0.question_code_for_cascading_id == "C15"}) {
                        selectedOptionsArray[12].remove(at: firstIndex)
                    }
                   if selectedOptionsArray[12].count == 1 || selectedOptionsArray[12].count == 0 {
                        self.selectedOptionsArray[12].append(newRipaViewModel.createCitationForInfractionObject())
                    }
                    else {
                        self.selectedOptionsArray[12].insert(newRipaViewModel.createCitationForInfractionObject(), at: 1)
                    }
                }
                else if selectedOptionsArray[12].contains(where: {$0.question_code_for_cascading_id == "C23" && $0.question_code_for_cascading_id != "C16"}) {
                    if let firstIndex = selectedOptionsArray[12].firstIndex(where: {$0.question_code_for_cascading_id == "C16"}) {
                        selectedOptionsArray[12].remove(at: firstIndex)
                    }
                   if selectedOptionsArray[12].count == 1 || selectedOptionsArray[12].count == 0 {
                        self.selectedOptionsArray[12].append(newRipaViewModel.createInfieldOptionObject())
                    }
                    else {
                        self.selectedOptionsArray[12].insert(newRipaViewModel.createInfieldOptionObject(), at: 1)
                    }
                }
                else if selectedOptionsArray[12].contains(where: {$0.question_code_for_cascading_id == "C38" && $0.question_code_for_cascading_id != "C40"}) {
                    if let firstIndex = selectedOptionsArray[12].firstIndex(where: {$0.question_code_for_cascading_id == "C40"}) {
                        selectedOptionsArray[12].remove(at: firstIndex)
                    }
                   if selectedOptionsArray[12].count == 1 || selectedOptionsArray[12].count == 0 {
                        self.selectedOptionsArray[12].append(newRipaViewModel.createVerbalWarningObject())
                    }
                    else {
                        self.selectedOptionsArray[12].insert(newRipaViewModel.createVerbalWarningObject(), at: 1)
                    }
                }
                else if selectedOptionsArray[12].contains(where: {$0.question_code_for_cascading_id == "C8" && $0.question_code_for_cascading_id != "C17"}) {
                    if let firstIndex = selectedOptionsArray[12].firstIndex(where: {$0.question_code_for_cascading_id == "C17"}) {
                        selectedOptionsArray[12].remove(at: firstIndex)
                    }
                   if selectedOptionsArray[12].count == 1 || selectedOptionsArray[12].count == 0 {
                        self.selectedOptionsArray[12].append(newRipaViewModel.createCustodialArrestWithoutWarrantObject())
                    }
                    else {
                        self.selectedOptionsArray[12].insert(newRipaViewModel.createCustodialArrestWithoutWarrantObject(), at: 1)
                    }
                }
                else if selectedOptionsArray[12].contains(where: {$0.question_code_for_cascading_id == "C8" && $0.question_code_for_cascading_id != "C15"}) {
                    if let firstIndex = selectedOptionsArray[12].firstIndex(where: {$0.question_code_for_cascading_id == "C8"}) {
                        selectedOptionsArray[12].remove(at: firstIndex)
                    }
                   if selectedOptionsArray[12].count == 1 || selectedOptionsArray[12].count == 0 {
                        self.selectedOptionsArray[12].append(newRipaViewModel.createCitationForInfractionObject())
                    }
                    else {
                        self.selectedOptionsArray[12].insert(newRipaViewModel.createCitationForInfractionObject(), at: 1)
                    }
                }
                else if selectedOptionsArray[12].contains(where: {$0.question_code_for_cascading_id != "C8" && $0.question_code_for_cascading_id == "C15"}),selectedOptionsArray[12].count > 0 {
                    if let firstIndex = selectedOptionsArray[12].firstIndex(where: {$0.question_code_for_cascading_id == "C15"}) {
                        selectedOptionsArray[12].remove(at: firstIndex)
                    }
                    if selectedOptionsArray[12].count == 1 || selectedOptionsArray[12].count == 0,self.selectedOptionsArray[12].count > 0 {
                        self.selectedOptionsArray[12].append(newRipaViewModel.createCustodialArrestWithoutWarrantObject())
                    }
                    else  if self.selectedOptionsArray[12].count > 0{
                        self.selectedOptionsArray[12].insert(newRipaViewModel.createCustodialArrestWithoutWarrantObject(), at: 1)
                    }
                }
            }
            
            if selectedOptionsArray.count > 4 ,  selectArray.count > 4,saveRipaStatus != "Saved",saveRipaStatus != "Created" {
                selectedOptionsArray[4] = selectArray[4]
            }
            
            if selectedOptionsArray.count > 1, selectedOptionsArray[1].count == 9 {
                selectedOptionsArray[1].remove(at: 8)
            }
            if selectedOptionsArray.count > 2,selectArray.count > 2,selectedOptionsArray[2].count < selectArray[2].count,AppConstants.isAddPerson == false {
                selectedOptionsArray[2] = selectArray[2]
            }

        }
        else if questionArray![questNumber!].question_code == "14", saveRipaStatus == "Created"{
            let personDict = personArray[0]
            var selectArray = personDict["SelectedOption"] as! [[Questionoptions1]]
            let cascadeQuestion = newRipaViewModel.getCascadeQuestionUsingId(questionID: 17)
          //  let arrr2 = selectedOptionsArray
            if let subArr = cascadeQuestion.questionoptions {
                for obj in subArr {
                    let exist = selectArray[4].contains(where: {
                        $0.option_value == obj.option_value
                    })
                    if exist == false {
                        if selectArray[4].count == 0 {
                            selectArray[4] = self.createOptions(castId : "C35")
                            selectArray[4].insert(obj, at: 2)
                        }
                        else {
                            selectArray[4].append(obj)
                        }
                    }
                }
                for obj in selectArray[4] {
                    let contain = selectedOptionsArray[4].contains(where: {$0.option_value.uppercased() == obj.option_value.uppercased()})
                    if selectedOptionsArray[4].count > 2 && contain == false {
                        selectedOptionsArray[4].insert(obj, at: 2)
                    }
                    else if contain == false {
                        selectedOptionsArray[4].append(obj)
                    }
                }
             //   let arrr3 = selectedOptionsArray
                if let ObjIndex = selectedOptionsArray[4].firstIndex(where: {$0.cascade_ripa_id == "15"}) {
                    selectedOptionsArray[4][ObjIndex].isExpanded = true
                }
            }
          //  let arrr4 = selectedOptionsArray
        }
        
        if selectedOptionsArray.count > 4,AppConstants.isTrafficData == true {
            let traffIcDesc = selectedOptionsArray[4].contains(where: {$0.tag
                == "Description"})
            if traffIcDesc == false,AppConstants.isTrafficData == true {
                selectedOptionsArray[4].append(self.newRipaViewModel.setDescriptionForReasonForStop(stringg: self.descriptionStrFirst))
            }
          //  let arrr1 = selectedOptionsArray
        }
        
        
        if  saveRipaStatus == "Saved"{
            if selectedOptionsArray[1].count < 8 {
                selectedOptionsArray[1].append(setOptionStopOrder())
            }
            else if selectedOptionsArray[1][7].option_value != "Yes" {
                selectedOptionsArray[1][7] = setOptionStopOrder()
            }
        }
       
        var personType=""
        if  selectedOptionsArray[0].count > 0 {
            personType = selectedOptionsArray[0][0].option_value
        }
       
        if viewType == "UseSaveRipa" ,selectedOptionsArray.count > 8{
            selectedOptionsArray[4].removeAll(where: {$0.mainQuestId != "14"})
            let personDict = personArray[0]
            let selectArray = personDict["SelectedOption"] as! [[Questionoptions1]]
            if selectArray.count > 8{
                selectedOptionsArray[8] = selectArray[8]
            }
            let checkConsent = selectedOptionsArray[8].contains(where: {$0.cascade_ripa_id == "84" && $0.mainQuestId != "84"})
            if checkConsent == true {
                let obj = selectedOptionsArray[8].filter({$0.cascade_ripa_id == "84"})
                
                if let subObj = obj[0].questionoptions?.filter({$0.isSelected == true}) , subObj.count > 0{
                    let index = selectedOptionsArray[8].firstIndex(where: {$0.cascade_ripa_id == "84"}) ?? 0
                    let isExist = selectedOptionsArray[8].contains(where: {$0.ripa_id == subObj[0].ripa_id})
                    if selectedOptionsArray[8].count > index + 1 ,isExist == false{
                        selectedOptionsArray[8].insert(subObj[0], at: index + 1)
                    }
                    else {
                        selectedOptionsArray[8].append(subObj[0])
                    }
                }
            }
        }
        
    //  let arrr = selectedOptionsArray
        let reasonForStopObject = newRipaViewModel.createPersonInformation(selectedOptionArray: selectedOptionsArray)
        selectedOptionsArray[2] = reasonForStopObject
        
        
        if (AppConstants.status == "" || AppConstants.status == "Saved") && (questionArray![questNumber!].question_code == "5" || questionArray![questNumber!].question_code == "T5") && selectedOptionsArray.count > 1{
            let exist = selectedOptionsArray[1].contains(where: {
                $0.ripa_id == "78"
            })
            if exist == false{
                selectedOptionsArray[1].removeAll()
            }
        }
        
        if viewType == "UseSaveRipa" && AppConstants.status == "Saved" && saveRipaStatus == "Saved"{
            let selectedArr = newRipaViewModel.makeSelectedOptionList(isSaved: true)
            if selectedOptionsArray[3].count == 6 {
                let index1 = selectedOptionsArray[3].firstIndex(where: {
                    $0.cascade_ripa_id == "77"
                }) ?? 0
                if selectedOptionsArray[3][index1].isSelected == true {
                    selectedArr[3][index1+1].option_value = "Yes"
                    selectedArr[3][index1+1].option_id = "1292"
                }
                let index2 = selectedOptionsArray[3].firstIndex(where: {
                    $0.cascade_ripa_id == "80"
                })
                if selectedOptionsArray[3][index2 ?? 0].isSelected == true {
                    selectedArr[3][index2!+1].option_value = "Yes"
                    selectedArr[3][index2!+1].option_id = "1300"
                }
                let index3 = selectedOptionsArray[3].firstIndex(where: {
                    $0.cascade_ripa_id == "83"
                })
                if selectedOptionsArray[3][index3 ?? 0].isSelected == true {
                    selectedArr[3][index3!+1].option_value = "Yes"
                    selectedArr[3][index3!+1].option_id = "1302"
                }
            }
            selectedOptionsArray[3] = selectedArr[3]
            print(selectedArr)
        }
        
        if (AppConstants.status == "" || AppConstants.status == "Saved") && (questionArray![questNumber!].question_code == "5" || questionArray![questNumber!].question_code == "T5" || questionArray![questNumber!].question_code == "25") && selectedOptionsArray.count > 2{
            let exist = selectedOptionsArray[2].contains(where: {
                $0.ripa_id == "65"
            })
            if exist == false{
                selectedOptionsArray[2].removeAll()
            }
            if selectedOptionsArray.count > 3,selectedOptionsArray[3].count < 5{
                selectedOptionsArray[3].removeAll()
            }
        }
        if selectedOptionsArray.count > 4,selectedOptionsArray[4].count > 2{
            for object in selectedOptionsArray[4]{
                let obj = selectedOptionsArray[4].filter({$0.option_id == "222"})
                if object.option_value.contains("48900"),obj.count == 0{
                    let objj = newRipaViewModel.setEducationCodeOption()
                    selectedOptionsArray[4].insert(objj, at: 1)
                }
            }
        }
        
     //   let arv = selectedOptionsArray
     //   print(arv)
     
        if (viewType == "StartNewRipa" || viewType == "UseLastRipa" || viewType == "Template"){
            if selectedOptionsArray.count > 1,selectedOptionsArray[2].count > 2{
                for i in (0 ..< (selectedOptionsArray[2].count )) {
                    if selectedOptionsArray[2][i].mainQuestId == "61" && selectedOptionsArray[2][i].ripa_id == "65" {
                        selectedOptionsArray[2][i].option_value = String(self.age)
                    }
                }
            }
            if selectedOptionsArray.count > 3,selectedOptionsArray[3].count < 5{
                selectedOptionsArray[3].removeAll()
            }
        }
        else if selectedOptionsArray.count > 4 {
            selectedOptionsArray[4].forEach({$0.mainQuestOrder = "10"})
            selectedOptionsArray[4].forEach({$0.order_number = "10"})
            let obj = selectedOptionsArray[4].filter({
                $0.option_id == "91"
            })
            let contain = selectedOptionsArray[4].contains(where: {$0.ripa_id == "15" && $0.cascade_ripa_id == "20"})
            if contain ==  false  && obj.count > 0{
                if selectedOptionsArray[4].count > 2 {
                    selectedOptionsArray[4].insert(newRipaViewModel.setTrafficViolationOption(), at: 1)
                }
                else {
                    selectedOptionsArray[4].append(newRipaViewModel.setTrafficViolationOption())
                }
            }
            if let index = selectedOptionsArray[4].firstIndex(where: {$0.question_code_for_cascading_id == "C36" && $0.mainQuestId == "70"}) {
                selectedOptionsArray[4][index].main_question_id = "14"
            }
        }
        
        
        if (viewType != "StartNewRipa") {
            let obj = selectedOptionsArray[0].filter({
                ($0.ripa_id == "26" || $0.cascade_ripa_id == "27") && $0.mainQuestId == "21"
            })
            if obj.count > 0 , obj[0].questionoptions?.count ?? 0 > 0 {
                selectedOptionsArray[0].append((obj[0].questionoptions?[0])!)
            }
            else if obj.count > 0 {
                //cell.answer_lbl.text = obj[0].option_value
            }
            if let ind = selectedOptionsArray[0].firstIndex(where: {$0.option_id == "1407" && $0.mainQuestId == "21"}) {
                selectedOptionsArray[0][ind].isSelected = true
            }
        }
        
        if  personcount > 0,selectedOptionsArray[1].count < 8{
            let personDict = personArray[0]
            let selctOpArr = personDict["SelectedOption"] as! [[Questionoptions1]]
            selectedOptionsArray[1] = selctOpArr[1]
        }
        if viewType == "UseSaveRipa" && AppConstants.status == "Created" && saveRipaStatus == "Created" && selectedOptionsArray.count > 0 && AppConstants.LocTypeIndex == 2{
            let exist = selectedOptionsArray[0].contains(where: {$0.option_id == "1410"})
            if exist == false {
                let fIndex = selectedOptionsArray[0].firstIndex(where: {$0.option_id == "1407"})
                if selectedOptionsArray[0].count > (fIndex ?? 0)+1 {
                    selectedOptionsArray[0].insert(newRipaViewModel.setClosestIntersectionOption(), at: (fIndex ?? 0)+1)
                }
                else {
                    selectedOptionsArray[0].append(newRipaViewModel.setClosestIntersectionOption())
                }
            }
        }
        if AppConstants.LocTypeIndex == 1,selectedOptionsArray.count > 0 {
            let exist = selectedOptionsArray[0].contains(where: {$0.option_id == "1409" && $0.question_code_for_cascading_id == "C54"})
            if exist == false && selectedOptionsArray[0].count > 2{
                selectedOptionsArray[0].insert(newRipaViewModel.createBlockStreetObject(), at: 2)
            }
            else if exist == false {
                selectedOptionsArray[0].append(newRipaViewModel.createBlockStreetObject())
            }
        }
        
        if (AppConstants.status == "Created" || AppConstants.status == "Saved"),personArray.count > 0 {
            let personDict = personArray[0]
            let selctOpArr = personDict["SelectedOption"] as! [[Questionoptions1]]
            for obj in selctOpArr[4] {
                let contain = selectedOptionsArray[4].contains(where: {$0.option_value.uppercased() == obj.option_value.uppercased()})
                if selectedOptionsArray[4].count > 2 && contain == false && obj.option_value.capitalized != "No"{
                    selectedOptionsArray[4].insert(obj, at: 2)
                }
                else if contain == false && obj.option_value.capitalized != "No" {
                    selectedOptionsArray[4].append(obj)
                }
            }
            if selectedOptionsArray[4].contains(where: {$0.cascade_ripa_id == "15"}){
                var resonStop = [Questionoptions1]()
                let obj = selectedOptionsArray[4].filter({$0.cascade_ripa_id == "15"})
                resonStop.append(obj[0])
                let objj = selectedOptionsArray[4].filter({$0.cascade_ripa_id == "20"})
                resonStop.append(objj[0])
                let objjj = selectedOptionsArray[4].filter({$0.ripa_id == "20"})
                for min in objjj {
                    resonStop.append(min)
                }
                let objjjj = selectedOptionsArray[4].filter({$0.ripa_id == "16"})
                if objjjj.count > 0 {
                    resonStop.append(objjjj[0])
                }
                
                for minObj in selectedOptionsArray[4] {
                    let isContain = resonStop.contains(where: {$0.option_value == minObj.option_value})
                    if isContain == false {
                        resonStop.append(minObj)
                    }
                }
                selectedOptionsArray[4] = resonStop
            }
        }
        
        if selectedOptionsArray[4].count > 0,selectedOptionsArray[4].contains(where: {$0.cascade_ripa_id == "15"}) {
            let check = selectedOptionsArray[4].contains(where: {$0.option_value.uppercased() == "TYPE OF VIOLATION"})
            if check == false {
                let index = selectedOptionsArray[4].lastIndex(where: {$0.ripa_id == "20"}) ?? 2
                selectedOptionsArray[4].insert(newRipaViewModel.createTypeViolationObject(), at: index+1)
            }
            if let fIndex = selectedOptionsArray[4].firstIndex(where: {$0.cascade_ripa_id == "18"}) {
                selectedOptionsArray[4].remove(at: fIndex)
            }
            if let fIndex = selectedOptionsArray[4].firstIndex(where: {$0.cascade_ripa_id == "28"}) {
                selectedOptionsArray[4].remove(at: fIndex)
            }
        }
        
        if AppConstants.violation_type.count > 0,selectedOptionsArray.count > 4{
            let cid = selectedOptionsArray[4][0].question_code_for_cascading_id
            if cid == "C3"{
                selectedOptionsArray.append(self.createOptions(castId: "C3"))
            }
            
            let minObject = newRipaViewModel.setReasonableSuspiciousOptions(reasonArr: selectedOptionsArray[4])
            
            var saveObj = [Questionoptions1]()
            let selectItem = violationDict?["ViolationList"] as? [Questionoptions1]
            for obj in minObject {
                if obj.optionDescription.count == 0 {
                    saveObj.append(obj)
                }
                else {
                    let check = selectItem?.contains(where: {$0.option_value.capitalized == obj.option_value.capitalized})
                    if check == true {
                        saveObj.append(obj)
                    }
                }
            }
            selectedOptionsArray[4] = saveObj
        }
        
        if selectedOptionsArray.count > 8{
            for i in (0 ..< selectedOptionsArray[8].count) {
                if selectedOptionsArray[8][i].isQuestionDescriptionReq == "1" {
                    selectedOptionsArray[8][i].isDescription_Required = "1"
                }
                else if selectedOptionsArray[8][i].isDescription_Required == "1" {
                    selectedOptionsArray[8][i].isQuestionDescriptionReq = "1"
                }
            }
            let checkDes = questarr[8].questionoptions?.contains(where: {$0.tag == "Description"})
            if checkDes == false {
                questarr[8].questionoptions?.append(newRipaViewModel.setDescriptionForBasisForSearch(descripStr : self.descriptionStr))
            }
        }
        
        if questarr.count > 8{
            let checkDes = questarr[8].questionoptions?.contains(where: {$0.tag == "Description"})
            if checkDes == false {
                questarr[8].questionoptions?.append(newRipaViewModel.setDescriptionForBasisForSearch(descripStr : self.descriptionStr))
            }
        }
        
        
        let arobj = selectedOptionsArray[8]
        print(arobj)
        
        personDict = ["PersonType":personType,"SelectedOption":selectedOptionsArray,"QuestionArray":questarr,"CascadeQuestionArray":cascadeQuestArr]
       
        if personArray.count > personcount {
            personArray[personcount] = personDict!
           
        }
        else{
            personArray.append(personDict!)
        }
        
        print(personArray.count)
    }
    
    func removeDuplicateElements(posts: [Questionoptions1]) -> [Questionoptions1] {
        var uniquePosts = [Questionoptions1]()
        for post in posts {
            if !uniquePosts.contains(where: {$0.option_value == post.option_value }) {
                uniquePosts.append(post)
            }
        }
        return uniquePosts
    }
    
    func stringHasNumber(_ string:String) -> Bool {
        for character in string{
            if character.isNumber{
                return true
            }
        }
        return false
    }

    func setOptionStopOrder() -> Questionoptions1 {
        let option2:Questionoptions1 = Questionoptions1(mainQuestId: "101", mainQuestOrder:"2" ,option_id: "1414", ripa_id:"101", custid: "1", option_value: "NO", cascade_ripa_id: "", isK_12School: "", isHideQuesText: "", order_number: "2", createdBy: "", createdOn: "", updatedBy: "", updatedOn: "", isSelected: false, isAddtion: "", isDescription_Required : "",inputTypeCode : "", questionTypeCode: "0", tag: "", physical_attribute: "", default_value: "", optionDescription: "", question_code_for_cascading_id: "0", isQuestionMandatory: "", isQuestionDescriptionReq: "", main_question_id: "108", isExpanded: false, isNewAdded: false, mainId: "", questionoptions: [])
       
        return option2
    }
    
    func editPersonInformation (quCode : String) -> [Questionoptions1] {
        let personDict = personArray[0]
        let questArr = (personDict["QuestionArray"] as! [QuestionResult1])
        let infoQuest = questArr[1] as QuestionResult1
        for quest in questArr{
            if quest.question_code == quCode {
                return quest.questionoptions ?? []
            }
        }
        return infoQuest.questionoptions ?? []
    }
    
    
    func resetIsK12Options(){
        createPersonDict(checkEditHidden: true)
        questionArray = resetIsK12(questArray: questionArray!)
//        let arr2 = cascadeQuestionArray
//        print(arr2)
        cascadeQuestionArray = resetIsK12(questArray: cascadeQuestionArray!)
//        let arr1 = cascadeQuestionArray
//        print(arr1)
        
        newRipaViewModel.questionsArray = questionArray
        newRipaViewModel.cascadeQuestionArray = cascadeQuestionArray
        // splitOptions()
        AppConstants.isStudent = "0"
        is_k12 = false
        tableView.reloadData()
    }
    
    
    func resetIsK12(questArray:[QuestionResult1])->[QuestionResult1]{
        for question in questArray {
            for options in question.questionoptions!{
                if options.isK_12School == "1"{
                    options.isSelected = false
                }
            }
        }
        return questArray
    }
    
    
    
    func addPerson(personIndex:Int , personArray:[[String: Any]]){
        resetArray()
        self.personArray = personArray
        if personArray.count > 0{
            checkCommon = true
            checkEditable = true
        }
        else{
            checkCommon = false
            checkEditable = false
        }
        
        editQuest(personIndex: personIndex, personArray: personArray, addIfNonCommon: false, resetsk12: false)
        personcount = personArray.count
        personNumber.text = "P" + "" + String(personArray.count + 1)
        questNumber = 2
        // self.personIndex = personIndex
        splitOptions()
        tableView.reloadData()
    }
    
    
    func editForPerson(personIndex:Int , personArray:[[String: Any]]){
        resetArray()
        checkEditableAndCommonQues(personArray:personArray)
        editQuest(personIndex: personIndex, personArray: personArray, addIfNonCommon: true, resetsk12: false)
        self.personArray = personArray
        questNumber = 0
        personcount = personIndex
        personNumber.text = "P" + "" + String(personIndex + 1)
        splitOptions()
        if questionArray![questNumber!].question_code == "5"{
            optionsArray![1].isExpanded = false
            if locTypeIndex == 4 {
                self.descriptionBtn.isHidden = false
            }
        }
        tableView.reloadData()
    }
    
    
    func checkEditableAndCommonQues(personArray:[[String: Any]]){
        if personArray.count > 1{
            checkCommon = true
            checkEditable = true
        }
        else{
            checkCommon = false
            checkEditable = false
        }
    }
    
    
    func goToSelectedQuestion(personIndex: Int,  personArray: [[String : Any]], index:Int ,descriptionString : String) {
        self.descriptionStr = descriptionString
        resetArray()
        checkEditableAndCommonQues(personArray:personArray)
        personNumber.text = "P" + "" + String(personIndex + 1)
        personcount = personIndex
        self.personArray = personArray
        questNumber = index
        editQuest(personIndex: personIndex, personArray: personArray, addIfNonCommon: true, resetsk12: false)
        
        splitOptions()
    
        if questionArray![questNumber!].question_code == "17"{
            let selectItem = optionsArray?.filter({
                $0.isSelected == true
            })
            if selectItem?.count ?? 0 < 2{
                disableNextButton(View: nextView)
            }
        }
        if questionArray![questNumber!].question_code == "5"{
            if optionsArray?[1].questionoptions?.count == 0 {
                optionsArray?[1].questionoptions = locArray
             }
            optionsArray![1].isExpanded = false
            self.tableView.reloadData()
            if locTypeIndex == 4 {
                self.descriptionBtn.isHidden = false
            }
        }
    }
    
    
    func resetArray(){
        questionArray = newRipaViewModel.resetQuestion()
        cascadeQuestionArray = newRipaViewModel.resetCascadeQuestion()
        violationArray?.removeAll()
    }
    
    
    
    func editQuest(personIndex:Int , personArray:[[String: Any]], addIfNonCommon:Bool, resetsk12: Bool) {
        
        let personDict = personArray[personIndex]
        var questArr = (personDict["QuestionArray"] as! [QuestionResult1])
        
        // This method to edit question for add person
        
        let cascadeQuestArr = (personDict["CascadeQuestionArray"] as! [QuestionResult1])
        violationArray?.removeAll()
        
        var i = 0
        for question in questionArray! {
        
            if question.question_code != "17" && i < questArr.count{
                question.isDescription_Required = questArr[i].isDescription_Required
                question.is_required = questArr[i].is_required
                if question.question_code == "19" || question.question_code == "20"{
                      question.isDescription_Required = "0"
                      checkPropertySeziure()
                }
            }
            if question.common_question == "1" || addIfNonCommon == true && i < questArr.count{
                question.questionoptions = questArr[i].questionoptions
            }
            
            if question.question_code == "T7"{
                checkBasisRequired(checkBasis: true)
            }
            
            if question.question_code == "16"{
                checkBasisRequired(checkBasis: true)
            }
            
//            if question.question_code == "T5"{
//                question = self.editPersonInformation()
//            }
//            else if question.question_code == "5"{
//                question = self.editPersonInformation()
//            }
            
            i += 1
        }
        
        i = 0
        for question in cascadeQuestionArray! {
           // let arr2 = cascadeQuestionArray
            if i < cascadeQuestArr.count {
                question.isDescription_Required = cascadeQuestArr[i].isDescription_Required
                question.is_required = cascadeQuestArr[i].is_required
                if question.common_question == "1" || addIfNonCommon == true{
                  //  let arr = question.questionoptions
                    question.questionoptions = cascadeQuestArr[i].questionoptions
                    if question.question_code == "C52" && question.questionoptions?.count ?? 0 > 0 {
                        let filterCascadeArray =  cascadeQuestArr.filter { $0.question_code == "C52"}
                        question.questionoptions = filterCascadeArray[0].questionoptions
                        if AppConstants.LocTypeIndex == 6 {
                            question.questionoptions?[0].isSelected = true
                        }
                        else if AppConstants.LocTypeIndex == 1 && question.questionoptions?.count ?? 0 > 0{
                            if question.questionoptions?.count ?? 0 > 1 {
                                question.questionoptions?[1].isSelected = true
                            }
                            else {
                                question.questionoptions?[0].isSelected = true
                            }
                        }
                        else if AppConstants.LocTypeIndex == 2  && question.questionoptions?.count ?? 0 > 1{
                            question.questionoptions?[2].isSelected = true
                        }
                        else if AppConstants.LocTypeIndex == 3  && question.questionoptions?.count ?? 0 > 2{
                            question.questionoptions?[3].isSelected = true
                        }
                        else if AppConstants.LocTypeIndex == 4  && question.questionoptions?.count ?? 0 > 3 {
                            self.descriptionBtn.isHidden = false
                            question.questionoptions?[4].isSelected = true
                        }
                    }
                    if question.question_code == "C43" {
                        let filterCascadeArray =  cascadeQuestArr.filter { $0.question_code == "C43"}
                        question.questionoptions = filterCascadeArray[0].questionoptions
                    }
//                   if i == 68 {
//                        question.questionoptions = cascadeQuestArr[66].questionoptions
//                    }
                }
                i += 1
            }
        }
    
        locTypeIndex = AppConstants.LocTypeIndex
        
        newRipaViewModel.questionsArray = questionArray
        newRipaViewModel.cascadeQuestionArray = cascadeQuestionArray
      
        
    }
    
    @IBAction func actionAddOption(_ sender: Any) {
        trackApplicationTime()
        guard let customAlertVC = enterTextPopup else { return }
        customAlertVC.ripaId = questionArray![questNumber!].id
        customAlertVC.inputType = questionArray![questNumber!].inputTypeCode
        customAlertVC.question = questionArray![questNumber!].question
        customAlertVC.delegate = self
        let popupVC = PopupViewController(contentController: customAlertVC, position: .bottom(10), popupWidth: UIScreen.main.bounds.size.width, popupHeight: 220)
        popupVC.cornerRadius = 5
        popupVC.delegate = self
        present(popupVC, animated: true, completion: nil)
    }
    
    
    @IBAction func actionAddNote(_ sender: Any) {
        trackApplicationTime()
        openNotes(for:"Normal")
    }
    
    
    
    func openNotes(for:String){
        trackApplicationTime()
        guard let customAlertVC = enterDescription else { return }
        
        customAlertVC.addDescriptionDelegate = self
        customAlertVC.noteDelegate = self
        customAlertVC.enteredText = AppConstants.notes
        customAlertVC.inputType = "Notes"
        customAlertVC.noteType = `for`
        
        let popupVC = PopupViewController(contentController: customAlertVC, position: .bottom(UIScreen.main.bounds.size.height/2.8), popupWidth: UIScreen.main.bounds.size.width-30, popupHeight: 370)
        popupVC.cornerRadius = 5
        popupVC.delegate = self
        present(popupVC, animated: true, completion: nil)
    }

    
    @IBAction func actionLogout(_ sender: Any) {
        logout()
    }
    
    
    
    @IBAction func actionDescription(_ sender: Any) {
        openDescriptionPopup()
    }
    
    func openDescriptionPopup(){
        trackApplicationTime()
        guard let customAlertVC = enterDescription else { return }
        customAlertVC.addDescriptionDelegate = self
       
        let index = questionArray![questNumber!].questionoptions!.count - 1
        let text = (questionArray![questNumber!].questionoptions![index] ).option_value
        customAlertVC.enteredText = text
        self.enterDescription?.flag = 0
        if questionArray![questNumber!].question_code == "17" && ischangeQuestion == true{
            self.enterDescription?.enteredText = text
        }
        
        if questionArray![questNumber!].question_code == "5" && locTypeIndex == 4 {
            self.enterDescription?.flag = 2
            self.enterDescription?.enteredText = AppConstants.LocTypeDescription
        }
        
        customAlertVC.placeholder = "Additional details for" + " " + questionArray![questNumber!].question.lowercased()
        
        customAlertVC.inputType = "Description"
        
        let popupVC = PopupViewController(contentController: customAlertVC, position: .bottom(UIScreen.main.bounds.size.height/2.8), popupWidth: UIScreen.main.bounds.size.width-30, popupHeight: 370)
        popupVC.cornerRadius = 5
        popupVC.delegate = self
        present(popupVC, animated: true, completion: nil)
    }
    
    func clearDescription() {
        if questionArray![questNumber!].question_code == "14"{
            self.descriptionStrFirst = ""
            let index = questionArray![questNumber!].questionoptions!.count - 1
            (questionArray![questNumber!].questionoptions![index] ).option_value = ""
        }
        else if questionArray![questNumber!].question_code == "5"{
            AppConstants.LocTypeDescription = ""
        }
        else  if questionArray![questNumber!].question_code == "17"{
            self.descriptionStr = ""
            self.enterDescription?.enteredText = ""
        }
        checkMandatorySelection()
    }
   
    func addEnteredDescription(text: String?) {
        if questionArray![questNumber!].question_code == "17"{
            textAdded = true
            nextEnabled = true
            self.descriptionStr = text!
            self.enterDescription?.enteredText = ""
        }
        if questionArray![questNumber!].question_code == "14"{
            self.descriptionStrFirst = text!
        }
        
        if questionArray![questNumber!].question_code == "5" && locTypeIndex == 4 && optionsArray![1].questionoptions?.count ?? 0 > 4{
            AppConstants.LocTypeDescription = text!
            AppConstants.address = text!
            self.descriptionBtn.isHidden = false
            
            var option:Questionoptions1?
            let questionID : Int? = Int(optionsArray![1].questionoptions![4].cascade_ripa_id)!
            let question = newRipaViewModel.getCascadeQuestionUsingId(questionID: questionID ?? 0)
            let ripaId = optionsArray![1].questionoptions![4].cascade_ripa_id
            option = newRipaViewModel.createObj(mainQuestId: questionId, ripaID: ripaId,optionValue: text!, physical_attribute: "", description: "", isSelected: true, mainQuestOrder: orderId!, isNewAdded: false, mainId: vioQuestionId)
            option = setMainQuestIdAndOptn(optn: option!)
            question.questionoptions!.append(setMainQuestIdAndOptn(optn: option!))
            cascadeArray.removeAll()
            checkMandatorySelection()
        }
        else {
            let index = questionArray![questNumber!].questionoptions!.count - 1
            (questionArray![questNumber!].questionoptions![index] ).option_value = text!
            (questionArray![questNumber!].questionoptions![index] ).isSelected = true
            
            tableView.reloadData()
            self.checkMandatorySelection()
        }
        
    }
  
    func loadData(){
        questNumber = 0
        countLbl.text = currentQuestNumb
       
        DispatchQueue.main.async {
            self.groupView.setHeight(CGFloat(0), animateTime: 0.0)
            self.grpViewHeightConstrait.constant = 0
             UIView.animate(withDuration: 0, animations:{
                 self.groupView.layoutIfNeeded()
             })
        }
       
        if let ttlString = currentQuestNumb, let range = ttlString.range(of: "/") {
            let firstPart = ttlString[ttlString.startIndex..<range.lowerBound]
            let results = String(ttlString.prefix(firstPart.count))
            let attributeStr: NSMutableAttributedString = NSMutableAttributedString(string: ttlString)
             if self.traitCollection.userInterfaceStyle == .dark {
                countLbl.textColor = .white
             }
            attributeStr.setColor(color: UIColor(red:0/255.0, green:124/255.0, blue:183/255.0, alpha: 1.0), forText: results)
            countLbl.attributedText = attributeStr
        }
        splitOptions()
        showPrevNextBtn()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        tick()
        timer = Timer.scheduledTimer(timeInterval: 30.0, target: self, selector:#selector(self.tick) , userInfo: nil, repeats: true)
        setRipaActivity()
        
        if viewType != "UseSaveRipa" && viewType != "UseSaveRipa"{
            saveToDb(toUpdate:false)
        }
        if AppConstants.status == "Saved"{
            saveToDb(toUpdate:true)
        }
        
    }
    
    
    func nextQuestion(){
        answer = ""
        print(questionArray![questNumber!].question_code)
        questNumber! += 1
        if questionArray![questNumber!].is_required == "0" && questNumber! < questionArray!.count-1 {
            nextQuestion()
            return
        }
        splitOptions()
        self.saveToDb(toUpdate:true)
    }
    
    
    func prevQuestion(){
        answer = ""
        questNumber! -= 1
        if questionArray![questNumber!].is_required == "0"{
            prevQuestion()
            return
        }
        splitOptions()
        self.saveToDb(toUpdate:true)
//        optionsArray![1].isExpanded = false
//        locTypeIndex = 0
        if questionArray![questNumber!].question_code == "5"{
            optionsArray![1].isExpanded = false
            self.tableView.reloadData()
            if locTypeIndex == 4 {
                self.descriptionBtn.isHidden = false
            }
        }
    }
    
    func setSearchPersonProperty(index : Int) {
        if questionArray![index].question_code == "T7"{
            for i in (0 ..< (questionArray?.count ?? 0)) {
                if questionArray![i].question_code == "17" {
                    for j in (0 ..< (questionArray?[i].questionoptions?.count ?? 0)) {
                        (questionArray![i].questionoptions![j] ).isSelected = false
                    }
                }
            }
        }
    }
    
    func setDeselectForTakenActionNone(index : Int) {
            if questionArray![index].question_code == "T7"{
                for i in (0 ..< (questionArray?.count ?? 0)) {
                    print(questionArray![i].question_code)
                    print(questionArray![i].is_required)
                    if questionArray![i].question_code == "17" {
                        for j in (0 ..< (questionArray?[i].questionoptions?.count ?? 0)) {
                            (questionArray![i].questionoptions![j] ).isSelected = false
                        }
                    }
                    if questionArray![i].question_code == "19" || questionArray![i].question_code == "20" {
                        for j in (0 ..< (questionArray?[i].questionoptions?.count ?? 0)) {
                            (questionArray![i].questionoptions![j] ).isSelected = false
                        }
                    }
                }
            }
    }
   
    func setMandatoryQuestion(index : Int) {
        if questionArray![index].question_code == "T7"{
            for i in (0 ..< (questionArray?.count ?? 0)) {
                print(questionArray![i].question_code)
                print(questionArray![i].is_required)
                if questionArray![i].question_code == "19" || questionArray![i].question_code == "20" {
                    for j in (0 ..< (questionArray?[i].questionoptions?.count ?? 0)) {
                        (questionArray![i].questionoptions![j] ).isSelected = false
                    }
                }
            }
        }
    }
 
    
    func showPrevNextBtn(){
        if questNumber! < questionArray!.count-1{
            nextView.isHidden = false
         //   topNextView.isHidden = false
            submitBtn.isHidden = true
        }else{
            nextView.isHidden = true
          //  topNextView.isHidden = true
            submitBtn.isHidden = false
        }
        if questNumber! == 0{
            prevView.isHidden = true
           // topPrevView.isHidden = true
        }else{
            prevView.isHidden = false
          //  topPrevView.isHidden = false
        }
    }
    
    // Get Question Details and set option array for each questions
    
    func splitOptions(){
        isKeyboard = true
        self.tableView.isScrollEnabled = true
        if questionArray![questNumber!].question_code == "5" {
            self.tableView.isScrollEnabled = false
        }
        
        if let arrr = questionArray, arrr.count > 0 {
            questionLbl.text = questionArray![questNumber!].question
            orderId = questionArray![questNumber!].order_number
            questionType = questionArray![questNumber!].questionTypeCode
            questionId = questionArray![questNumber!].id
            checkAddBtn(show: questionArray![questNumber!].isAddtion)
            countLbl.text = currentQuestNumb
            
            DispatchQueue.main.async {
                self.groupView.setHeight(CGFloat(39), animateTime: 0.0)
                self.grpViewHeightConstrait.constant = 39
                UIView.animate(withDuration: 0, animations:{
                    self.groupView.layoutIfNeeded()
                })
                
                self.groupLbl.text = self.questionArray![self.questNumber!].groupName
                
                if self.questNumber ?? 0 < 2 {
                    self.groupView.setHeight(CGFloat(0), animateTime: 0.0)
                    self.grpViewHeightConstrait.constant = 0
                    UIView.animate(withDuration: 0, animations:{
                        self.groupView.layoutIfNeeded()
                    })
                }
            }
            
            if let ttlString = currentQuestNumb, let range = ttlString.range(of: "/") {
                let firstPart = ttlString[ttlString.startIndex..<range.lowerBound]
                let results = String(ttlString.prefix(firstPart.count))
                let attributeStr: NSMutableAttributedString = NSMutableAttributedString(string: ttlString)
                if self.traitCollection.userInterfaceStyle == .dark {
                   countLbl.textColor = .white
                }
                attributeStr.setColor(color: UIColor(red:0/255.0, green:124/255.0, blue:183/255.0, alpha: 1.0), forText: results)
                countLbl.attributedText = attributeStr
            }
            
            groupLbl.text = questionArray![questNumber!].groupName
            
            optionsArray = questionArray![questNumber!].questionoptions!
            
            if questionArray![questNumber!].question_code == "17" && viewType != "StartNewRipa"{
                let objj = optionsArray?.filter({
                    $0.mainQuestId == "25"
                })
                if objj?.count ?? 0 > 0 {
                    textAdded = true
                    nextEnabled = true
                    self.enterDescription?.enteredText = ""
                    self.descriptionStr = objj?[0].option_value ?? ""
                }
            }
          
            if questionArray![questNumber!].question_code == "25" && viewType != "StartNewRipa",optionsArray?.count ?? 0 > 2{
                optionsArray?[2].questionoptions = self.createGenderOptions()
            }
            
            if questionArray![questNumber!].question_code == "25" && viewType != "StartNewRipa",personcount < personArray.count{
                optionsArray?[1] = newRipaViewModel.setPercievedAgeOption()
                let personDict = personArray[personcount]
                let selectedOption = personDict["SelectedOption"] as! [[Questionoptions1]]
                if selectedOption.count > 3,selectedOptionsArray.count > 2,selectedOptionsArray[2].count > 3 {
                    if selectedOption[2][3].ripa_id == "65" {
                        selectedOptionsArray[2][2] = newRipaViewModel.setPercievedAgeOption()
                        selectedOptionsArray[2][3].option_value = selectedOption[2][3].option_value
                        self.age = Int(selectedOption[2][3].option_value) ?? 0
                    }
                }
            }
            
            if questionArray![questNumber!].question_code == "5" ,optionsArray?[1].questionoptions?.count == 0,locArray.count > 0 {
                optionsArray?[1].questionoptions = locArray
            }
            
            if questionArray![questNumber!].question_code == "14" {
                if let obj = optionsArray?.filter({
                    $0.optionDescription == "StReas_N"
                }), obj.count > 0 {
                    self.descriptionStrFirst = obj[0].option_value
                }
             }
          
            if questionArray![questNumber!].question_code == "15" && viewType == "StartNewRipa"{
                let check = checkQuestionUpdate15()
                if  !check{
                    optionsArray![0].isSelected = true
                    optionsArray![1].isSelected = false
                }
            }
            
            if questionArray![questNumber!].question_code == "15" && (viewType == "UseSaveRipa" || viewType == "Template") && saveRipaStatus == "Saved"{
                let check = checkQuestionUpdate15()
                if  check{
                    optionsArray![0].isSelected = true
                    optionsArray![1].isSelected = false
                }
            }
        }
        
        self.addPersonBtn.isHidden = true
        if String(questionArray!.count) == String(format: "%d",questNumber!+1){
          //  self.addPersonBtn.isHidden = false
        }
        
        checkEditable = false
        
        if questionArray![questNumber!].question_code == "T7" {
            if !self.checkForTypeOfVehicleStop() {
                
                let indexa = optionsArray?.firstIndex{$0.physical_attribute == "13"}
                let indexb = optionsArray?.firstIndex{$0.physical_attribute == "4"}
                self.optionsArray![indexa!].isSelected = false
                self.optionsArray![indexb!].isSelected = false
            }
            
            for i in (0..<optionsArray!.count)
            {
                let items = optionsArray![i]
                let physicalAttribute = items.physical_attribute
                if physicalAttribute == "12" {
                    if optionsArray![i].isSelected{
                       var question = newRipaViewModel.getQuestionUsingQuestionCode(question_code: 19)
                        question.is_required = "1"
                        question = newRipaViewModel.getQuestionUsingQuestionCode(question_code: 20)
                        question.is_required = "1"
                     }
                    else{
                        var question = newRipaViewModel.getQuestionUsingQuestionCode(question_code: 19)
                         question.is_required = "0"
                         question = newRipaViewModel.getQuestionUsingQuestionCode(question_code: 20)
                         question.is_required = "0"
                    }
                }
                else {
                    for j in (0 ..< (questionArray?.count ?? 0)) {
                        if (questionArray?[j].question_code == "19" || questionArray?[j].question_code == "20") && physicalAttribute == "18"{
                            questionArray?[j].is_required = "0"
                        }
                    }
                }
            }
        }
        
        if questionArray![questNumber!].question_code == "16" {
            for i in (0..<optionsArray!.count)
            {
                let items = optionsArray![i]
                let physicalAttribute = items.physical_attribute
                if physicalAttribute == "21" {
                    if optionsArray![i].isSelected{
                       var question = newRipaViewModel.getQuestionUsingQuestionCode(question_code: 19)
                        question.is_required = "1"
                        question = newRipaViewModel.getQuestionUsingQuestionCode(question_code: 20)
                        question.is_required = "1"
                     }
                    else{
                        var question = newRipaViewModel.getQuestionUsingQuestionCode(question_code: 19)
                         question.is_required = "0"
                         question = newRipaViewModel.getQuestionUsingQuestionCode(question_code: 20)
                         question.is_required = "0"
                    }
                }
                else {
                    for j in (0 ..< (questionArray?.count ?? 0)) {
                        if (questionArray?[j].question_code == "19" || questionArray?[j].question_code == "20") && physicalAttribute == "24"{
                            questionArray?[j].is_required = "0"
                        }
                    }
                }
            }
        }
        
        if questionArray![questNumber!].question_code == "T5" && optionsArray?.count ?? 0 > 4 {
            questionArray![questNumber!].questionoptions!.removeLast()
            optionsArray?.removeLast()
        }
        
        
        cascadeArray.removeAll()
        checkCityAndAdd()
       
        showPrevNextBtn()
       
        checkDiscriptionRequired()
        addCascadeOptions()
        
        let arr = optionsArray
        print(arr)
        
        if questionArray![questNumber!].question_code == "5" && viewType != "StartNewRipa" && optionsArray![2].questionoptions?.count ?? 0 > 0{
            optionsArray![2].questionoptions?[0].cascade_ripa_id = "52"
        }
        
        if questionArray![questNumber!].question_code == "14" && viewType != "StartNewRipa"{
            for i in (0..<optionsArray!.count)
            {
                if optionsArray?[i].question_code_for_cascading_id == "C35" && optionsArray?[i].mainQuestOrder == "10" {
                    optionsArray?[i].questionoptions = self.createOptions(castId : "C35")
                }
                else if optionsArray?[i].question_code_for_cascading_id == "C1" && optionsArray?[i].mainQuestOrder == "10" {
                    optionsArray?[i].questionoptions = self.createOptions(castId : "C1")
                }
                else if optionsArray?[i].question_code_for_cascading_id == "C19" && optionsArray?[i].mainQuestOrder == "10" {
                    optionsArray?[i].questionoptions = self.createOptions(castId : "C19")
                }
                else if optionsArray?[i].question_code_for_cascading_id == "C3" && optionsArray?[i].mainQuestOrder == "10" {
                    optionsArray?[i].questionoptions = self.createOptions(castId : "C3")
                }
            }
        }

       
        
        if questionArray![questNumber!].question_code == "T7" && viewType != "StartNewRipa"{
            let arrt = optionsArray
            let personDict = personArray[personcount]
            let selectedOption = personDict["SelectedOption"] as! [[Questionoptions1]]
            if selectedOption.count > 7 {
                let getObjAA = selectedOption[7].filter({$0.main_question_id == "106"})
                for obj in getObjAA {
                    if let indexa = optionsArray?.firstIndex(where: {$0.option_id == obj.option_id && $0.option_id != "1373"})  {
                        optionsArray?[indexa].isSelected = true
                    }
                }
            }
            for i in (0 ..< (optionsArray?.count ?? 0)) {
                let cascadeRipaId = optionsArray?[i].cascade_ripa_id
                if cascadeRipaId == "32" {
                    optionsArray?[i].questionoptions = newRipaViewModel.createNonForceRelatedActionOption()
                }
                for j in (0 ..< (selectedOption.count)) {
                    let fObj = selectedOption[j].filter({
                        $0.mainQuestId == cascadeRipaId
                    })
                    if fObj.count > 0 {
                        for k in (0 ..< (optionsArray?[i].questionoptions?.count ?? 0)) {
                            if fObj[0].option_value == optionsArray?[i].questionoptions?[k].option_value {
                                optionsArray?[i].questionoptions?.forEach({
                                    $0.isSelected = false
                                })
                                optionsArray?[i].questionoptions?[k].isSelected = true
                            }
                        }
                    }
                }
            }
            print(selectedOption)
        }
        
        checkNameView()
        checkMandatory()
        addSchoolToLocation()
        
        checkMandatorySelection()
        setmodelArray()
        
        
       if questionArray![questNumber!].question_code == "21" && viewType != "StartNewRipa"{
            let personDict = personArray[personcount]
            let selectedOption = personDict["SelectedOption"] as! [[Questionoptions1]]
            if selectedOption.count > 12 && selectedOption[12].count > 1{
                    let cascadeId = selectedOption[12][1].ripa_id
                   
                    for j in (0..<optionsArray!.count)
                    {
                        let casdId = optionsArray?[j].cascade_ripa_id
                        if cascadeId == casdId && cascadeId == "73"{
                           // selectedOption[12][1].cascade_ripa_id = "16"
                            optionsArray?[j].questionoptions?.removeAll()
                            let obj = selectedOption[12].filter({
                                $0.cascade_ripa_id == "75"
                            })
                            optionsArray?[j].questionoptions?.append(obj[0])
                          //  optionsArray?[j].questionoptions?.append(selectedOption[12][1] as Questionoptions1)
                        }
                        else if casdId == "74" {
                            optionsArray?[j].questionoptions?.forEach({
                                $0.cascade_ripa_id = "73"
                            })
                        }
                        else if cascadeId == casdId && cascadeId == "50" && optionsArray?[j].questionoptions?.count ?? 0 > 0{
                            optionsArray?[j].questionoptions?[0].cascade_ripa_id = cascadeId
                            if optionsArray?[j].questionoptions?.count ?? 0 > 1 {
                                optionsArray?[j].questionoptions?.remove(at: 1)
                            }
                        }
                        else if cascadeId == casdId && cascadeId == "51"{
                            optionsArray?[j].isSelected = true
                            if optionsArray?[j].questionoptions?.count ?? 0 > 0 {
                                optionsArray?[j].questionoptions?.insert(newRipaViewModel.createInfieldOptionObject(), at: 0)
                            }
                            else {
                                optionsArray?[j].questionoptions?.append(newRipaViewModel.createInfieldOptionObject())
                            }
                            optionsArray?[j].questionoptions?.removeAll(where: {$0.ripa_id == "41"})
                        }
                        else if cascadeId == casdId && cascadeId == "24" && optionsArray?[j].questionoptions?.count ?? 0 > 0{
                            optionsArray?[j].questionoptions?.removeAll()
                            selectedOption[12][1].cascade_ripa_id = cascadeId
                            optionsArray?[j].questionoptions?.append(selectedOption[12][1] as Questionoptions1)
                        }
                    }
            }
           if let fIndex = optionsArray!.firstIndex(where: {$0.isSelected == true}) {
               optionsArray?[fIndex].isExpanded = true
           }
        }
       

        if personcount > 0 && questionArray![questNumber!].question_code == "T5" && personcount < personArray.count {
            let personDict = personArray[personcount]
            let questArr = (personDict["QuestionArray"] as! [QuestionResult1])
            for i in (0 ..< questArr.count) {
                if questArr[i].question_code == "T5" {
                    optionsArray = self.editPersonInformation(quCode: "T5")
                }
            }
            
            if personArray.count > 1 {
                let firstDict = personArray[0]
                if optionsArray?[0].questionoptions?.count == 0 {
                    optionsArray?[0].questionoptions = newRipaViewModel.createStopInformationOption()
                }
                let selectArr = firstDict["SelectedOption"] as! [[Questionoptions1]]
                for ind in (0 ..< selectArr[1].count) {
                    let optValue = selectArr[1][ind].option_value
                    for optIndex in (0 ..< optionsArray!.count) {
                        if optionsArray![optIndex].option_value == optValue && selectArr[1][ind].isSelected ==  true {
                            optionsArray![optIndex].isSelected = true
                        }
                       
                        for innIndex in (0 ..< (optionsArray![optIndex].questionoptions?.count ?? 0)) {
                            if optionsArray![optIndex].questionoptions?[innIndex].option_value == optValue && selectArr[1][ind].isSelected ==  true {
                                optionsArray![optIndex].questionoptions?.forEach({
                                    $0.isSelected = false
                                })
                                optionsArray![optIndex].questionoptions?[innIndex].isSelected = true
                            }
                        }
                    }
                }
            }
        }
        // c43
        if questionArray![questNumber!].question_code == "T5" {
            if optionsArray?.count ?? 0 > 4 {
                optionsArray?.remove(at: 4)
            }
            optionsArray![0].isExpanded = true
            
              if let index = optionsArray!.firstIndex(where: { (dict) -> Bool in
                return dict.question_code_for_cascading_id == "C43"
               })
             {
                  let obj = optionsArray![index]
                  optionsArray!.remove(at: index)
                  optionsArray!.insert(obj, at: 0)
               } 
        }
        
      if questionArray![questNumber!].question_code == "T6" {
            let optArry = questionArray![1].questionoptions!
            for option in optArry{
                if option.question_code_for_cascading_id == "C43",let obj = option.questionoptions{
                    for subObj in obj{
                            for i in (0 ..< optionsArray!.count) {
                                if optionsArray![i].question_code_for_cascading_id == "C45" && subObj.physical_attribute == "1" && subObj.isSelected{
                                    
                                    if (self.optionsArray![i].isSelected) == true {
                                        (self.optionsArray![i].isSelected) = true
                                    }
                                    else {
                                        (self.optionsArray![i].isSelected) = false
                                    }
                                }
                                else if optionsArray![i].question_code_for_cascading_id == "C46" && subObj.physical_attribute == "3" && subObj.isSelected {
                                    if (self.optionsArray![i].isSelected) == true {
                                        (self.optionsArray![i].isSelected) = true
                                    }
                                    else {
                                        (self.optionsArray![i].isSelected) = false
                                    }
                                }
                                else if subObj.physical_attribute == "2" && subObj.isSelected {
                                    if (self.optionsArray![i].isSelected) == true {
                                        (self.optionsArray![i].isSelected) = true
                                    }
                                    else {
                                        (self.optionsArray![i].isSelected) = false
                                    }
                                }
                            }
                    }
                }
            }
        }
       
        if  let inputTypeStr = self.optionsArray?[1].inputTypeCode, questionArray?[questNumber!].question_code == "5" && inputTypeStr == "AN" && questionType == "MC"{
            optionsArray![1].isExpanded = true
        }
        
        isGpsEnable = false
        self.countyBtn.isUserInteractionEnabled = true
        if questionArray![questNumber!].question_code == "5" && self.locTypeIndex == 6{
            isGpsEnable = true
            self.countyBtn.isUserInteractionEnabled = false
        }
        
        if viewType == "Template" {
            var option:Questionoptions1?
            let questionID : Int?
            var ripaId : String = ""
            if optionsArray?.count ?? 0 > 1,optionsArray?[1].questionoptions?.count ?? 0 > 1,let qId = optionsArray?[1].questionoptions?[1].cascade_ripa_id {
                questionID = Int(qId)
                ripaId  = qId
            }
            else {
                questionID = 120
                ripaId = "120"
            }
            let question = newRipaViewModel.getCascadeQuestionUsingId(questionID: questionID ?? 0)
            option = newRipaViewModel.createObj(mainQuestId: questionId, ripaID: ripaId,optionValue:  AppConstants.block, physical_attribute: "", description: "", isSelected: true, mainQuestOrder: orderId!, isNewAdded: false, mainId: vioQuestionId)
            option = setMainQuestIdAndOptn(optn: option!)
            question.questionoptions!.append(setMainQuestIdAndOptn(optn: option!))
            
            let Obj = Questionoptions1(mainQuestId: "21", mainQuestOrder: "1", option_id: "0", ripa_id: "120", custid: "", option_value: AppConstants.street, cascade_ripa_id: "", isK_12School: "", isHideQuesText: "", order_number: "1", createdBy: "", createdOn: "", updatedBy: "", updatedOn: "", isSelected: true, isAddtion: "", isDescription_Required: "No", inputTypeCode: "", questionTypeCode: "", tag: "", physical_attribute: "", default_value: "", optionDescription: "", question_code_for_cascading_id: "", isQuestionMandatory: "Yes", isQuestionDescriptionReq: "No", main_question_id: "21", isExpanded: false, isNewAdded: false, mainId: "", questionoptions: [])
            question.questionoptions!.append(Obj)
        }
        
        if questionArray![questNumber!].question_code == "17" && viewType  != "StartNewRipa",personcount < personArray.count{
            let personDict = personArray[personcount]
            let selectedOption = personDict["SelectedOption"] as! [[Questionoptions1]]
            if  let index = optionsArray!.firstIndex(where: {$0.option_id == "112"}),selectedOption.count > 8 {
                let isConsent = selectedOption[8].contains(where: {$0.option_id == "112"})
                if isConsent == true {
                    optionsArray?[index].questionoptions = newRipaViewModel.createBasisForSearchConsentGivenOption()
                    optionsArray?[index].isSelected = true
                    optionsArray?[index].isExpanded = true
                 
                        for j in (0 ..< (selectedOption[8].count )) {
                            let optnId = selectedOption[8][j].option_id
                            for k in (0 ..< (optionsArray?[index].questionoptions?.count ?? 0)) {
                                if optionsArray?[index].questionoptions?[k].option_id == optnId {
                                    optionsArray?[index].questionoptions?[k].isSelected = true
                                }
                            }
                        }
                }
            }
        }
        
        if questionArray![questNumber!].question_code == "14",AppConstants.reason_for_stop.count > 0,saveRipaStatus == "Created",viewType == "UseSaveRipa" {
           print(viewType)
            self.addEnteredDescription(text: AppConstants.reason_for_stop)
            self.disableNextButton(View: nextView)
        }
        
        if questionArray![questNumber!].question_code == "T5" && AppConstants.violation_type.count > 0 {
           // let opttAr = optionsArray
            if let indexV = optionsArray?.firstIndex(where: {$0.cascade_ripa_id == "78"})
            {
                if let opIndex = optionsArray?[indexV].questionoptions?.firstIndex(where: {$0.physical_attribute == AppConstants.travel_method})
                {
                    optionsArray?[indexV].questionoptions?[opIndex].isSelected = true
                }
            }
        }
        
        if questionArray![questNumber!].question_code == "14" && AppConstants.violation_type.count > 0 && AppConstants.offenceCodes.count > 0 {
            let offenceArr = AppConstants.offenceCodes.components(separatedBy: ",")
            violationArray = newRipaViewModel.getViolations()
            
             if AppConstants.violation_type == "1" {
                violationArray = self.violationArray!.filter {
                    $0.violationGroup == "VC" || $0.violationGroup == "AA"
                }
               
                for obj in offenceArr {
                    if let row = self.violationArray?.firstIndex(where: {$0.offense_code == obj}) {
                        self.violationArray?[row].isSelected = true
                    }
                }
                if let opIndex = optionsArray?.firstIndex(where: {$0.cascade_ripa_id == "15" && $0.ripa_id == "14"})
                {
                    optionsArray?[opIndex].isExpanded = true
                    if optionsArray?[opIndex].questionoptions?.count ?? 0 > 0 {
                        optionsArray?[opIndex].questionoptions?.insert(newRipaViewModel.setTrafficViolationOption(), at: 0)
                        optionsArray?[opIndex].questionoptions?.remove(at: 1)
                    }
                    else {
                        optionsArray?[opIndex].questionoptions?.append(newRipaViewModel.setTrafficViolationOption())
                    }
                    optionsArray?[opIndex].questionoptions?.forEach({$0.isSelected = true})
                    indexPath = opIndex
                }
            }
            else if AppConstants.violation_type == "2" {
                violationArray = self.violationArray!.filter {
                    $0.violationGroup != "VC"
                }
                if let opIndex = optionsArray?.firstIndex(where: {$0.cascade_ripa_id == "17" && $0.ripa_id == "14"})
                {
                    for obj in offenceArr {
                        if let row = self.violationArray?.firstIndex(where: {$0.offense_code == obj}) {
                            self.violationArray?[row].isSelected = true
                        }
                    }
                    optionsArray?[opIndex].questionoptions?.forEach({$0.isSelected = true})
                    optionsArray?[opIndex].isExpanded = true
                    indexPath = opIndex
                }
            }
            self.refreshLocationLists(list: self.violationArray, listType: "Violation")
        }
       
        
        let arrr = optionsArray
        print(arrr)
     //   (optionsArray![indexPath!].questionoptions![0] ).cascade_ripa_id
        
        tableView.reloadData()
        
        tableView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        
        
    }
    
    
    func createOptions(castId : String) -> [Questionoptions1] {
        var questOption = [Questionoptions1]()
        if castId == "C35" {
            let Obj = Questionoptions1(mainQuestId: "70", mainQuestOrder: "10", option_id: "1275", ripa_id: "70", custid: "1", option_value: "Specific Code", cascade_ripa_id: "71", isK_12School: "", isHideQuesText: "", order_number: "10", createdBy: "", createdOn: "", updatedBy: "", updatedOn: "", isSelected: true, isAddtion: "", isDescription_Required: "No", inputTypeCode: "V ", questionTypeCode: "LV", tag: "", physical_attribute: "", default_value: "", optionDescription: "", question_code_for_cascading_id: "C36", isQuestionMandatory: "Yes", isQuestionDescriptionReq: "No", main_question_id: "14", isExpanded: false, isNewAdded: false, mainId: "", questionoptions: [])
            questOption.append(Obj)
            
            let Objj = Questionoptions1(mainQuestId: "70", mainQuestOrder: "10", option_id: "1276", ripa_id: "70", custid: "", option_value: "Basis (select all that apply)", cascade_ripa_id: "72", isK_12School: "", isHideQuesText: "", order_number: "10", createdBy: "", createdOn: "", updatedBy: "", updatedOn: "", isSelected: true, isAddtion: "", isDescription_Required: "No", inputTypeCode: "A ", questionTypeCode: "MC", tag: "", physical_attribute: "", default_value: "", optionDescription: "", question_code_for_cascading_id: "C37", isQuestionMandatory: "Yes", isQuestionDescriptionReq: "No", main_question_id: "14", isExpanded: false, isNewAdded: false, mainId: "", questionoptions: [])
            questOption.append(Objj)
        }
        else if castId == "C3" {
            let Obj = Questionoptions1(mainQuestId: "17", mainQuestOrder: "10", option_id: "98", ripa_id: "17", custid: "", option_value: "Specific Code (select one using SDCS Offence table)", cascade_ripa_id: "28", isK_12School: "", isHideQuesText: "", order_number: "10", createdBy: "", createdOn: "", updatedBy: "", updatedOn: "", isSelected: true, isAddtion: "", isDescription_Required: "No", inputTypeCode: "V ", questionTypeCode: "LV", tag: "", physical_attribute: "", default_value: "", optionDescription: "", question_code_for_cascading_id: "C11", isQuestionMandatory: "Yes", isQuestionDescriptionReq: "No", main_question_id: "14", isExpanded: false, isNewAdded: false, mainId: "", questionoptions: [])
            questOption.append(Obj)
            
            let Objj = Questionoptions1(mainQuestId: "17", mainQuestOrder: "10", option_id: "97", ripa_id: "17", custid: "", option_value: "Basis (select all applicable)", cascade_ripa_id: "18", isK_12School: "", isHideQuesText: "", order_number: "10", createdBy: "", createdOn: "", updatedBy: "", updatedOn: "", isSelected: true, isAddtion: "", isDescription_Required: "No", inputTypeCode: "A ", questionTypeCode: "MC", tag: "", physical_attribute: "", default_value: "", optionDescription: "", question_code_for_cascading_id: "C4", isQuestionMandatory: "Yes", isQuestionDescriptionReq: "No", main_question_id: "14", isExpanded: false, isNewAdded: false, mainId: "", questionoptions: [])
            questOption.append(Objj)
        }
        else if castId == "C19" {
            let Obj = Questionoptions1(mainQuestId: "16", mainQuestOrder: "10", option_id: "222", ripa_id: "46", custid: "", option_value: "Education Code", cascade_ripa_id: "47", isK_12School: "", isHideQuesText: "", order_number: "10", createdBy: "", createdOn: "", updatedBy: "", updatedOn: "", isSelected: true, isAddtion: "", isDescription_Required: "No", inputTypeCode: "EC", questionTypeCode: "DD", tag: "", physical_attribute: "1", default_value: "", optionDescription: "", question_code_for_cascading_id: "C20", isQuestionMandatory: "Yes", isQuestionDescriptionReq: "No", main_question_id: "14", isExpanded: false, isNewAdded: false, mainId: "", questionoptions: [])
            questOption.append(Obj)
        }
        else {
            let Obj = Questionoptions1(mainQuestId: "15", mainQuestOrder: "10", option_id: "93", ripa_id: "15", custid: "", option_value: "Specific Code", cascade_ripa_id: "17", isK_12School: "", isHideQuesText: "", order_number: "10", createdBy: "", createdOn: "", updatedBy: "", updatedOn: "", isSelected: true, isAddtion: "", isDescription_Required: "No", inputTypeCode: "V ", questionTypeCode: "LV", tag: "", physical_attribute: "1", default_value: "", optionDescription: "", question_code_for_cascading_id: "C5", isQuestionMandatory: "Yes", isQuestionDescriptionReq: "No", main_question_id: "14", isExpanded: false, isNewAdded: false, mainId: "", questionoptions: [])
            questOption.append(Obj)
            
            let Objj = Questionoptions1(mainQuestId: "15", mainQuestOrder: "10", option_id: "92", ripa_id: "15", custid: "1", option_value: "Type of violation", cascade_ripa_id: "15", isK_12School: "", isHideQuesText: "", order_number: "10", createdBy: "", createdOn: "", updatedBy: "", updatedOn: "", isSelected: true, isAddtion: "", isDescription_Required: "No", inputTypeCode: "A ", questionTypeCode: "SC", tag: "", physical_attribute: "1", default_value: "", optionDescription: "", question_code_for_cascading_id: "C2", isQuestionMandatory: "Yes", isQuestionDescriptionReq: "No", main_question_id: "14", isExpanded: false, isNewAdded: false, mainId: "", questionoptions: [])
            questOption.append(Objj)
        }
        
        return questOption
    }
    
    func createGenderOptions() -> [Questionoptions1] {
        let quest = newRipaViewModel.getCascadeQuestionUsingId(questionID: 65)
        var optionArr = [Questionoptions1]()
         for option in quest.questionoptions!{
                 let personDict = personArray[personcount]
                 let selectedOption = personDict["SelectedOption"] as! [[Questionoptions1]]
             if selectedOption.count > 3 && selectedOption[2].count > 4 {
                     let personOpt = selectedOption[2][4]
                     if option.physical_attribute == personOpt.physical_attribute && option.main_question_id == personOpt.main_question_id {
                         option.isSelected = true
                     }
                 }
             let copyoption = option.copy()
             optionArr.append(copyoption as! Questionoptions1)
         }
        return optionArr
    }
    
    func checkQuestionUpdate15() -> Bool {
        var check : Bool = false
        for person in personArray{
            var  selectedOptionsArray=[[Questionoptions1]]()
            selectedOptionsArray = (person["SelectedOption"] as! [[Questionoptions1]])
            for options in selectedOptionsArray{
                for opt in options{
                    if opt.option_value == "Yes" {
                        check = true
                    }
                }
            }
        }
        return check
    }
    
    
    var allowSave = true
    
    func saveToDb(toUpdate:Bool){
        
        if allowSave == true{
            setRipaActivity()
            createPersonDict(checkEditHidden: true)
            previewViewModel.previewModelDelegate = self
            
            var traini : String = "0"
         
            if  let userOption = UserDefaults.standard.object(forKey: "supervisorId") as? String{
                ripaActivity?.supervisorId = userOption
            }
           
            if  let userOption = UserDefaults.standard.object(forKey: "userOption") as? String,userOption == "Training/Testing" {
                traini = "1"
            }
            if  let userOption = UserDefaults.standard.object(forKey: "userOption") as? String,userOption == "Training/Testing" {
                traini = "1"
            }
            
            let os = ProcessInfo().operatingSystemVersion
            ripaActivity?.os_version = os.getFullVersion()
            ripaActivity?.is_trainee = traini
            
            if AppConstants.trafficId != ""{
                print(AppConstants.trafficId)
                ripaActivity?.traffic_id = AppConstants.trafficId
            }
            ripaActivity?.is_K_12_Student = "0"
            if let check = is_k12,check == true {
                ripaActivity?.is_K_12_Student = "1"
            }
            
            db.openDatabase()
            var userRipaResponse : RipaResponse = db.getRipaResponse()!
           
            if userRipaResponse.question_id.isEmpty {
                 userRipaResponse  = self.createRipaResponseData(data: self.userSettingArray)
            }
            var temp1 : String!
            if  let userOption = UserDefaults.standard.object(forKey: "userOption") as? String{
                temp1 = "\(userOption)"
                userRipaResponse.response = temp1
            }
           
          
            ripaActivity?.os_version = os.getFullVersion()
            ripaActivity?.is_trainee = traini
            
            if AppConstants.trafficId != ""{
                print(AppConstants.trafficId)
                ripaActivity?.traffic_id = AppConstants.trafficId
            }
            
            userRipaResponse.ripa_activity = AppConstants.activityID
           // let objj = self.personArray
            // previewViewModel.setKey()
            previewViewModel.ripaActivity = self.ripaActivity
            previewViewModel.createPersonsDict(personArray: self.personArray, ripaActivity: ripaActivity!, statusId: "1", ripaResponse: userRipaResponse )
            
            let updateRipa:UpdateRipa = self.previewViewModel.updateRipaParam()
            self.previewViewModel.saveToDB(updateRipa: updateRipa, isUpdate: toUpdate, syncSccessful: "")
            allowSave = false
            disableSave()
        }
    }
    
    
    func disableSave(){
        DispatchQueue.background(delay: 3.0, completion:{
            self.allowSave = true
        })
    }
    
    
    func checkNameView(){
        nemeViewHeight.constant = 42
        if AppConstants.ripaCounty == "Y"{
            dateTimeViewHeight.constant = 113
            countyView.isHidden = false
        }
        else{
            dateTimeViewHeight.constant = 57
            countyView.isHidden = true
        }
        
        userNameLbl.isHidden = false
        dateLbl.isHidden = false
        
        //dateTextField.isHidden = false
        //timeTxtField.isHidden = false
        //durationTxtField.isHidden = false
        
        if  questionArray![questNumber!].question != "Location"{
            DispatchQueue.main.async {
                self.nemeViewHeight.constant = 0
                self.dateTimeViewHeight.constant = 0
                self.userNameLbl.isHidden = true
                self.dateLbl.isHidden = true
                //       self.dateTextField.isHidden = true
                //     self.timeTxtField.isHidden = true
                //   self.durationTxtField.isHidden = true
            }
        }
        self.nameView.layoutIfNeeded()
        self.dateTimeView.layoutIfNeeded()
    }
  
    /*
    func isGeoLocation(check : Bool){
        if !check{
            dateTimeViewHeight.constant = 113
            countyView.isHidden = false
        }
        else{
            dateTimeViewHeight.constant = 57
            countyView.isHidden = true
        }
        
        self.dateTimeView.layoutIfNeeded()
    }
    */
    
    func checkMandatory(){
        let passwordAttriburedString = NSMutableAttributedString(string: questionLbl.text!)
        if questionArray![questNumber!].is_required == "1"{
            requiredImgView.image = #imageLiteral(resourceName: "required_icon")
        } else{
            requiredImgView.image = #imageLiteral(resourceName: "optional")
        }
        
        if questionArray![questNumber!].question_info != ""{
            let asterix = NSAttributedString(string: "\n"+questionArray![questNumber!].question_info, attributes: [.foregroundColor: UIColor.white , .font:UIFont.systemFont(ofSize: 14.0)])
            passwordAttriburedString.append(asterix)
            self.questionLbl.attributedText = passwordAttriburedString
        }
        
    }
    
    
    func disableOnLocation(){
        
        if checkEditable == true && questionArray![questNumber!].editable_question != "1"{
            dateTextField.isUserInteractionEnabled = false
            timeTxtField.isUserInteractionEnabled = false
            durationTxtField.isUserInteractionEnabled = false
            countyBtn.isUserInteractionEnabled = false
            countyLbl.isUserInteractionEnabled = false
        }
        else{
            dateTextField.isUserInteractionEnabled = true
            timeTxtField.isUserInteractionEnabled = true
            durationTxtField.isUserInteractionEnabled = true
            countyBtn.isUserInteractionEnabled = true
        }
    }
   
    func getCityId() {
        let cityList = newRipaViewModel.getCities()
        if !cityList.isEmpty {
            let filteredArray = cityList.filter{$0.city_name == AppConstants.city || $0.city_name == AppConstants.city.uppercased() || $0.city_name == AppConstants.city.capitalized}
            if !filteredArray.isEmpty{
                self.cityID = filteredArray[0].city_id
                print(self.cityID)
            }
        }
    }
    
    
    func checkCityAndAdd(){
        
        if questionArray![questNumber!].question_code == "5"{
            
            disableOnLocation()
            var option = [Questionoptions1]()
            let custId = previewViewModel.custId
            var id=[String]()
            let cityList = newRipaViewModel.getCities()
            let cascadeQuest = newRipaViewModel.getCascadeQuestionUsingQuestionCode(questionCode: "C6")
            print(viewType)
            for city in cityList{
                print(city.custid)
                if (city.custid == custId && viewType != "UseSaveRipa" && viewType != "UseLastRipa" && viewType != "Template")  || city.city_name == AppConstants.city && (viewType == "UseSaveRipa" || viewType == "UseLastRipa" || viewType == "Template") {
                    cityID = city.city_id
                    let obj = newRipaViewModel.createObj(mainQuestId: questionId, ripaID: cascadeQuest.id, optionValue: city.city_name, physical_attribute: "", description: "", isSelected: true, mainQuestOrder: "1", isNewAdded: false, mainId: vioQuestionId)
                    
                    option.append(setMainQuestIdAndOptn(optn: obj))
                    cascadeQuest.order_number = orderId!
                    
                    id.append(cityID)
                    
                    if (viewType == "UseSaveRipa" || viewType == "UseLastRipa" || viewType == "Template"){
                        if city.city_name == AppConstants.city{
                            if  saveRipaStatus == "Created"{
                                cascadeQuest.questionoptions?.removeAll()
                                cascadeQuest.questionoptions = option
                                
                                var option = [Questionoptions1]()
                                let cascadeQuest2 = newRipaViewModel.getCascadeQuestionUsingQuestionCode(questionCode: "C7")
                                cascadeQuest2.order_number = orderId!
                                cascadeQuest2.questionoptions?.removeAll()
                                let obj = newRipaViewModel.createObj(mainQuestId: questionId, ripaID:cascadeQuest2.id, optionValue: AppConstants.address, physical_attribute: "", description: "", isSelected: true, mainQuestOrder: "1", isNewAdded: false, mainId: vioQuestionId)
                                
                                option.append(setMainQuestIdAndOptn(optn: obj))
                                cascadeQuest2.questionoptions = option
                                
                            }
                            cityID = city.city_id
                        }
                    }
                }
            }
            
            
            if viewType != "UseSaveRipa" && viewType != "UseLastRipa" && viewType != "Template"{
               /*
                if  option.count == 1 {
                    cascadeQuest.questionoptions?.removeAll()
                    cascadeQuest.questionoptions = option
                    AppConstants.city = option[0].option_value
                    print(option[0].option_value)
                    cityID = id[0]
                }
                else { */
                    if let defaultCity = (UserDefaults.standard.object(forKey: "DefaultCity") as? [String : Any]){
                        if (defaultCity["City or Unincorporated Area"] as! String) != ""{
                            cascadeQuest.questionoptions?.removeAll()
                            option.removeAll()
                            
                            AppConstants.city = defaultCity["City or Unincorporated Area"] as! String
                            cityID = defaultCity["Id"] as! String
                            
                            let obj = newRipaViewModel.createObj(mainQuestId: questionId, ripaID: cascadeQuest.id, optionValue: AppConstants.city , physical_attribute: "", description: "", isSelected: true, mainQuestOrder: "1", isNewAdded: false, mainId: vioQuestionId)
                            option.append(setMainQuestIdAndOptn(optn: obj))
                            cascadeQuest.questionoptions = option
                        }
                        else if AppConstants.city.count == 0 {
                           cascadeQuest.questionoptions?.removeAll()
                           cascadeQuest.questionoptions = option
                           AppConstants.city = option[0].option_value
                           print(option[0].option_value)
                           cityID = id[0]
                       }
                    }
                //}
            }
            
        }
    }
    
    
    
    
    func checkDependentQuestions(){
        //        if questionArray![questNumber!].question_code == "9" {
        //            (questionArray![questNumber!+1].questionoptions![1] ).isSelected = false
        //            (questionArray![questNumber!+1].questionoptions![0] ).isSelected = false
        //            for options in optionsArray!{
        //                if (options.option_id == "3" || options.option_id == "159") && options.isSelected==true{
        //                    (questionArray![questNumber!+1].questionoptions![0] ).isSelected = true
        //                }
        //            }
        //        }
        
        
        if questionArray![questNumber!].question_code == "T7" {
            //            let quest = newRipaViewModel.getQuestionUsingQuestionCode(question_code: 17)
            //            quest.is_required = "0"
            //            quest.isDescription_Required = "0"
            //            for option in optionsArray!{
            //                if option.option_id == "128" ||  option.option_id == "126"{
            //                    if option.isSelected == true{
            //                        quest.is_required = "1"
            //                        quest.isDescription_Required = "1"
            //                    }
            //                }
            //            }
        }
    }
    
    
    
    
    func addSchoolToLocation(){
        if questionType == "MC" && questionArray![questNumber!].question == "Location"{
            optionsArray = questionArray![0].questionoptions
            _ = newRipaViewModel.getCascadeQuestionUsingQuestionCode(questionCode: "C10")
            if  questionArray![0].questionoptions!.count < 6{
                let cascadeQuest = newRipaViewModel.getCascadeQuestionUsingQuestionCode(questionCode: "C24")
                if cascadeQuest.questionoptions!.count > 0{
                    questionArray![0].questionoptions?.append(cascadeQuest.questionoptions![0])
                }
                optionsArray = questionArray![0].questionoptions
            }
            checkIs_K12()
        }
        setmodelArray()
    }
    
    
    
    func setmodelArray(){
        newRipaViewModel.questionsArray = questionArray
        newRipaViewModel.cascadeQuestionArray = cascadeQuestionArray
    }
    
    
    func checkDiscriptionEntered()->Bool{
        if questionArray![questNumber!].isDescription_Required == "1"{
            for option in optionsArray!{
                if option.tag == "Description" && option.option_value != "" {
                    return true
                }
                else{ return false }
            }
        }
        return true
    }
    
    
    func checkDiscriptionRequired(){
        
        if questionArray![questNumber!].isDescription_Required == "1"{
            descriptionBtn.isHidden = false
            var hasDescriptionObj = false
            for option in questionArray![questNumber!].questionoptions!{
                let optionId = option.option_id
                if optionId.count == 0 {
                    option.option_id = "0"
                }
                if option.tag == "Description"{
                    hasDescriptionObj = true
                } }
            if hasDescriptionObj == false{
                let option:Questionoptions1 = Questionoptions1(mainQuestId: questionId, mainQuestOrder:"" ,option_id: "0", ripa_id:questionArray![questNumber!].id, custid: "", option_value: "", cascade_ripa_id: "", isK_12School: "", isHideQuesText: "", order_number: "", createdBy: "", createdOn: "", updatedBy: "", updatedOn: "", isSelected: false, isAddtion: "", isDescription_Required : "",inputTypeCode : "", questionTypeCode: "0", tag: "Description", physical_attribute: "", default_value: "", optionDescription: "", question_code_for_cascading_id: "0", isQuestionMandatory: "1", isQuestionDescriptionReq: "1", main_question_id: questionId, isExpanded: false, isNewAdded: false, mainId: "", questionoptions: [])
                questionArray![questNumber!].questionoptions!.append(option)
            }
        }else{
            descriptionBtn.isHidden = true
        }
        optionsArray = questionArray![questNumber!].questionoptions!
        
    }
    
    
    func checkIs_K12(){
        setmodelArray()
        let ad = newRipaViewModel.getCascadeQuestionUsingQuestionCode(questionCode: "C10")
        
        let studentQuest = newRipaViewModel.getCascadeQuestionUsingQuestionCode(questionCode: "C27")
        if studentQuest.questionoptions![0].isSelected == true{
            is_k12 = true
            AppConstants.isStudent = "1"
        }
        cascadeQuestionType = ad.questionTypeCode
        if ad.questionoptions?.count ?? 0 > 0 , (ad.questionoptions![0] ).isSelected == true {
            
              is_k12 = true
            AppConstants.isStudent = "1"
            studentQuest.is_required = "1"
        }
        else{
        
            if optionsArray?.count ?? 0 > 5,let cascadeId = optionsArray?[5].cascade_ripa_id,cascadeId.count > 0 {
                let cascadeQuest = newRipaViewModel.getCascadeQuestionUsingId(questionID: Int(cascadeId)!)
                cascadeQuest.questionoptions = []
            }
            if optionsArray?.count ?? 0 > 4 {
                optionsArray![4].isSelected = false
            }
           
            studentQuest.is_required = "0"
        }
        
        if questionArray![questNumber!].question_code != "5" {
            if ad.questionoptions?.count ?? 0 > 0 , (ad.questionoptions![1] ).isSelected == true {
                // is_k12 = false
                // questionArray![questNumber!+1].is_required = "0"
                studentQuest.is_required = "0"
                optionsArray![4].isSelected = true
                // AppUtility.showAlertWithProperty("Alert", messageString: "All sk_12 Options Will Be Hidden")
            }
        }
    }
    
    
    func checkSingleAndMultiline(){
        
        let trimmedAnswer = answer.trimmingCharacters(in: .whitespacesAndNewlines)
        var select:Bool = false
        if answer != ""{select = true}
      
        if questionArray![questNumber!].question_code == "23" || questionArray![questNumber!].question_code == "25"{
            let cascadeQuest = newRipaViewModel.getCascadeQuestionUsingId(questionID: Int(optionsArray![indexPath!].cascade_ripa_id)!)
            cascadeQuest.questionoptions!.removeAll()
            let options = newRipaViewModel.createObj(mainQuestId: questionId, ripaID: cascadeQuest.id, optionValue: trimmedAnswer, physical_attribute: "", description: "", isSelected: select, mainQuestOrder: orderId!, isNewAdded: false, mainId: vioQuestionId)
            
            if  questionArray![questNumber!].question_code == "25"{
                cascadeQuest.questionoptions?.append(options)
                optionsArray![indexPath!].isSelected = true
            }
            else{
                cascadeQuest.questionoptions?.append(setMainQuestIdAndOptn(optn: options))
                optionsArray![indexPath!].isSelected = false
                checkForSingleSelection(index: indexPath!)
            }
        }
        
        if questionType == "MC" && questionArray![questNumber!].question == "Location"{
            let cascadeQuest = newRipaViewModel.getCascadeQuestionUsingQuestionCode(questionCode: "C25")
            cascadeQuest.questionoptions!.removeAll()
            let options = newRipaViewModel.createObj(mainQuestId: questionId, ripaID: cascadeQuest.id, optionValue: trimmedAnswer, physical_attribute: "", description: "", isSelected: select, mainQuestOrder: orderId!, isNewAdded: false, mainId: vioQuestionId)
            cascadeQuest.questionoptions?.append(setMainQuestIdAndOptn(optn: options))
        }
        
        if (questionType == "ML" || questionType == "SL"){
            questionArray![questNumber!].questionoptions!.removeAll()
            let options = newRipaViewModel.createObj(mainQuestId: questionId, ripaID: questionArray![questNumber!].id , optionValue: trimmedAnswer, physical_attribute: "", description: "", isSelected: select, mainQuestOrder: orderId!, isNewAdded: false, mainId: vioQuestionId)
            questionArray![questNumber!].questionoptions!.append(setMainQuestIdAndOptn(optn: options))
        }
        
        setmodelArray()
    }
    
    
    
    func checkAddBtn(show:String) {
        if show == "0"{
            addOptionBtn.isHidden = true
        }else{
            addOptionBtn.isHidden = false
        }
    }
    
    
    func checkDefaultSelected()->Bool {
        for option in optionsArray!{
            if option.default_value == "1" && option.isSelected == true{
                return true
            }
        }
        return false
    }
    
    
    
    func checkPropertySeziure(){
        let seziureQues = newRipaViewModel.getQuestionUsingQuestionCode(question_code: 16)
        for option in seziureQues.questionoptions!{
            if  (option.physical_attribute == "21" && option.isSelected){
                        var question = newRipaViewModel.getQuestionUsingQuestionCode(question_code: 19)
                        question.is_required = "1"
                        question = newRipaViewModel.getQuestionUsingQuestionCode(question_code: 20)
                        question.is_required = "1"
             }
        }
    }
    
    
    
    func checkBasisRequired(checkBasis:Bool){
        
        if questionArray![questNumber!].question_code == "T7" || checkBasis == true{
            let basisQues = newRipaViewModel.getQuestionUsingQuestionCode(question_code: 17)
            let consentQues = newRipaViewModel.getQuestionUsingQuestionCodeUsingString(question_code: "T7")
           // let consentQues = newRipaViewModel.getQuestionUsingQuestionCode(question_code: 16)
            
            for option in consentQues.questionoptions!{
                
                if option.physical_attribute == "14" && option.isSelected {
                    basisQues.is_required = "1"
                    basisQues.isDescription_Required = "1"
                    
                    for options in basisQues.questionoptions!{
                        options.isQuestionDescriptionReq = "1"
                        options.isQuestionMandatory = "1"
                        
                        if options.tag == "Description" && options.option_value != ""{
                            options.isSelected = true
                        }
                    }
                    break
                }
                else if option.physical_attribute == "15" && option.isSelected {
                    basisQues.is_required = "1"
                    basisQues.isDescription_Required = "1"
                    
                    for options in basisQues.questionoptions!{
                        options.isQuestionDescriptionReq = "1"
                        options.isQuestionMandatory = "1"
                        
                        if options.tag == "Description" && options.option_value != ""{
                            options.isSelected = true
                        }
                    }
                    break
                }
    
                else{
                    basisQues.is_required = "0"
                    basisQues.isDescription_Required = "0"
                    
                    for options in basisQues.questionoptions!{
                        options.isQuestionDescriptionReq = "0"
                        options.isQuestionMandatory = "0"
            
                        if options.tag == "Description"{
                            options.isSelected = false
                        }
                    }
                }
            }
            newRipaViewModel.checkConsent()
        }
    }
    
    
    func checkForSingleSelection(index : Int){
        if questionType == "SC" || questionType == "MC"{
            cascadeArray.removeAll()
            
            if questionArray![questNumber!].question_code == "15"{
                  for i in (0 ..< 2) {
                        optionsArray![i].isSelected = false
                   }
            }
            else {
                
                if questionArray![questNumber!].question_code != "21"{
                    optionsArray![index].isSelected  =  !optionsArray![index].isSelected
                }
                print(optionsArray![index].isSelected)
                print(optionsArray![index].physical_attribute)
                if questionArray![questNumber!].question_code == "T7" && optionsArray![index].physical_attribute == "12" && optionsArray![index].isSelected  == false{
                    self.setMandatoryQuestion(index: questNumber!)
                }
                if questionArray![questNumber!].question_code == "T7" && optionsArray![index].physical_attribute == "15" && optionsArray![index].isSelected  == false{
                    self.setSearchPersonProperty(index : questNumber!)
                }
                if questionArray![questNumber!].question_code == "T7" && optionsArray![index].physical_attribute == "14" && optionsArray![index].isSelected  == false{
                    self.setSearchPersonProperty(index : questNumber!)
                }
                if questionArray![questNumber!].question_code == "T7" && optionsArray![index].physical_attribute == "18" && optionsArray![index].isSelected  == true{
                    self.setDeselectForTakenActionNone(index : questNumber!)
                }
            }
            
            if questionArray![questNumber!].question_code == "15"{
                optionsArray![index].isSelected  =  true
            }
            
            let defaultSelected = checkDefaultSelected()
            
            if questionArray![questNumber!].question_code == "T5",((viewType != "StartNewRipa" && AppConstants.status != "LastRipa" && AppConstants.status != "Template" && saveRipaStatus != "Created") || AppConstants.isTemplate == "temp") {
                var personDict = personArray[personcount]
                var selectedOption = personDict["SelectedOption"] as! [[Questionoptions1]]
                if let indT = selectedOption[1].firstIndex(where: {$0.ripa_id == "78"}) {
                    selectedOption[1].remove(at: indT)
                    let stopOption = optionsArray?.filter({$0.cascade_ripa_id == "78"})
                    let optionObj = stopOption?[0].questionoptions?.filter({$0.isSelected == true})
                    if indT < selectedOption[1].count,optionObj?.count ?? 0 > 0 {
                        selectedOption[1].insert(optionObj![0], at: indT)
                    }
                    else {
                        selectedOption[1].insert(optionObj![0], at: 0)
                    }
                }
                personDict["SelectedOption"]  = selectedOption
                personArray[personcount] = personDict
            }

            
            if questionType == "SC" || defaultSelected == true{
                var i = 0
                for options in optionsArray!{
                    if options.tag != "Description"{
                        if (index != i){
                            options.isSelected = false
                            if options.cascade_ripa_id != ""{
                                let questions =  newRipaViewModel.getCascadeQuestionUsingId(questionID: Int(options.cascade_ripa_id)!)
                                
                                if questions.question_code == "C18"{
                                    questions.questionoptions = []
                                }
                                
                                for opt in questions.questionoptions!{
                                    opt.isSelected = false
                                    if opt.inputTypeCode == "V " ||  (opt ).inputTypeCode == "EC"{
                                        if opt.cascade_ripa_id != "" {
                                            let question =  newRipaViewModel.getCascadeQuestionUsingId(questionID:Int((opt ).cascade_ripa_id)!)
                                            question.questionoptions = []
                                        }
                                        else{
                                            (opt ).questionoptions = []
                                        }
                                    }
                                    else{
                                        if (opt).cascade_ripa_id != "" {
                                            let question =  newRipaViewModel.getCascadeQuestionUsingId(questionID:Int((opt ).cascade_ripa_id)!)
                                            for option in question.questionoptions!{
                                                (option ).isSelected = false
                                            }
                                        }
                                    }
                                }
                            }
                            else{
                                options.questionoptions = []
                            }
                        }
                    }
                    
                    if questionArray![questNumber!].question_code == "23"{
                        tableView.reloadSections([i], with: .none)
                    }
                    i += 1
                } }
            
            autoMoveNext(indexValue : index)
        }
        checkBasisRequired(checkBasis: false)
        tableView.reloadData()
        checkMandatorySelection()
    }
 
    
    func addEnteredOption(option: Questionoptions1) {
        for options in questionArray![questNumber!].questionoptions!{
            (options ).isSelected = false
        }
        questionArray![questNumber!].questionoptions?.append(option)
        
        let sortedOptions = questionArray![questNumber!].questionoptions?.sorted {
            ($0 ).option_value < ($1 ).option_value
        }
        optionsArray = (sortedOptions!)
        if questionType != "SL" || questionType != "ML"{
            tableView.reloadData()
        }
    }
    
    func logout(){
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
    
    
    func moveToPrevScreen(move: Bool) {
       // self.navigationController?.popViewController(animated: true)
    }
   
    func addnote(forSave:Bool){
        trackApplicationTime()
        if forSave == false{
            if viewType != "UseSaveRipa" {
                newRipaViewModel.removeThisRipa()
            }
            if AppConstants.status == "Saved"{
                newRipaViewModel.deleteRipaPram(activityId: AppConstants.activityID)
                newRipaViewModel.removeThisRipa()
                //newRipaViewModel.removeSavedData()
            }
            if AppConstants.status == "Resume"{
                newRipaViewModel.removeThisRipa()
            }
            
            self.navigationController?.popViewController(animated: true)
            
        }
        else{
            if AppConstants.status == "Resume" || AppConstants.status == "LastRipa"{
                saveToDb(toUpdate: true)
            }
            else if AppConstants.status == "Created"{
                saveToDb(toUpdate: true)
            }
            else if AppConstants.status == "Saved"{
                savetoServer(showAlertForSave: false)
                newRipaViewModel.removeSavedData()
            }
            else{
                newRipaViewModel.removeThisRipa()
                //  previewViewModel.setKey()
                //  saveToDb(toUpdate: false)
                saveToDb(toUpdate: false)
            }
            
            if AppConstants.status != "Saved"{
                self.navigationController?.popViewController(animated: true)
            }
        }
        
        if Reachability.isConnectedToNetwork(){
            AppManager.removeData()
        }
        
    }
    
    func save(){
        
        openNotes(for:"Back")
        
    }
    
}

extension NewRipaViewController: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let questionTypeCode = optionsArray![indexPath.section].questionTypeCode
        let inputTypeCode = optionsArray![indexPath.section].inputTypeCode
       
        if questionType == "SL"{
            return  50
        }
        else if questionArray![questNumber!].question_code == "T5" && optionsArray![indexPath.section].question_code_for_cascading_id == "C43"{
            return 70
        }
        else if questionArray![questNumber!].question_code == "T5" && optionsArray![indexPath.section].question_code_for_cascading_id == "15"{
            return 70
        }
        else if questionArray![questNumber!].question_code == "T5" && questionTypeCode == "SC"{
            return 120
        }
        else if questionArray![questNumber!].question_code == "T6" {
            return 80
        }
        else if questionArray![questNumber!].question_code == "T5" && questionTypeCode == "MC"{
            return UITableView.automaticDimension
         }
        else if questionType == "ML"{
            return  288
        }
        else if questionType == "MC" && questionArray![questNumber!].question == "Location"{
            return UITableView.automaticDimension
        }
        else{
            return  UITableView.automaticDimension
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(locTypeIndex)
        if questionArray![questNumber!].question_code == "5" && section == 1 && self.optionsArray![section].inputTypeCode == "AN" && questionType == "MC"{
           if locTypeIndex == 1 || locTypeIndex == 2 || locTypeIndex == 3{
                return 2
            }
            else if locTypeIndex == 6{
                return 1
            }
            else {
                return 0
            }
        }
        else if questionArray![questNumber!].question_code == "5"{
            return 1
        }
        else if questionType == "SL"{
            return 1
        }
        else if questionType == "ML"{
            return 1
        }
        else if questionArray![questNumber!].question_code == "25"{
            return optionsArray!.count
        }
        else if questionArray![questNumber!].question_code == "T5"{
            let questionTypeCode = optionsArray![section].question_code_for_cascading_id
            if questionTypeCode != "C43"{
                return 1
            }
            else {
                if optionsArray![section].isExpanded{
                    return optionsArray![section].questionoptions!.count
                }
                else {
                    return 0
                }
            }
        }
        else if questionArray![questNumber!].question_code == "T6"{
            return 1
        }
        else if questionType == "MC" && questionArray![questNumber!].question == "Location"{
            return 1
        }
        else if (optionsArray?[section].inputTypeCode == "AN" && optionsArray?[section].questionTypeCode == "ML") || optionsArray?[section].questionTypeCode == "SL"{
            return 1
        }
        
        else if !is_k12! && optionsArray?[section].isK_12School == "1"{
            return 0
        }
        
        else{
            if optionsArray![section].isExpanded{
                return optionsArray![section].questionoptions!.count
            }
            else {
                return 0
            }
        }
        
    }
    
   
    func numberOfSections(in tableView: UITableView) -> Int {
        if questionArray![questNumber!].question_code == "25" {
            return 1
        }
        else if questionArray![questNumber!].question_code == "T5" {
            return 4
        }
        else if questionArray![questNumber!].question_code == "T6" {
            return 3
        }
        else if questionType == "SL" || questionType == "ML"{
            return 1
        }
        
        else if questionType == "MC" && questionArray![questNumber!].question == "Location"{
            checkIs_K12()
            if !optionsArray![2].isSelected {
                return 3
            }
            if is_k12 ?? false {
                return 4
            }
            return 3
        }
        else if  questionArray![questNumber!].isDescription_Required == "1"{
            return optionsArray!.count-1
        }
        return optionsArray!.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1, questionArray![questNumber!].question_code == "5" && self.optionsArray![section].inputTypeCode == "AN" && questionType == "MC"{
            return UITableView.automaticDimension
        }
       else if questionArray![questNumber!].question_code == "25" || questionArray![questNumber!].question_code == "T6"{
            return 0
        }
        else  if !(is_k12 ?? false) && optionsArray![section].isK_12School == "1" && questionArray![questNumber!].question_code == "T7" {
            return 0.1
        }
        else if questionArray![questNumber!].question_code == "T7" && section != 0 {
            return 80
        }
        else  if !(is_k12 ?? false) && optionsArray![section].isK_12School == "1" && questionArray![questNumber!].question_code == "T4" {
            return 0.1
        }
        else  if !(is_k12 ?? false) && optionsArray![section].isK_12School == "1" && questionArray![questNumber!].question_code == "21" {
            return 0.1
        }
        else if questionArray![questNumber!].question_code == "T4" && optionsArray![section].option_id == "1439"{
            return 120
         }
        else if questionArray![questNumber!].question_code == "T4" && optionsArray![section].option_id == "1421"{
            return 90
         }
        else if questionArray![questNumber!].question_code == "T4" && optionsArray![section].option_id == "1430"{
            return 90
         }
        else if questionArray![questNumber!].question_code == "T4" && optionsArray![section].option_id == "1435"{
            return 90
         }
        else if questionArray![questNumber!].question_code == "T4" {
            return 60
        }
        else if questionArray![questNumber!].question_code == "21" && optionsArray![section].option_id == "211"{
            return 120
         }
        else if questionArray![questNumber!].question_code == "21" {
            return 80
        }
        else if questionArray![questNumber!].question_code == "T7" && section == 0 {
            return UITableView.automaticDimension
        }
        else if questionArray![questNumber!].question_code == "T5" {
            let questionTypeCode = optionsArray![section].question_code_for_cascading_id
            if questionTypeCode == "C43"{
                return UITableView.automaticDimension
            }
            return 0
        }
        else if questionType == "SL" || questionType == "ML"{
            return 0
        }
        else if questionType == "MC" && questionArray![questNumber!].question == "Location"{
           
            return 0
        }
        else if questionArray![questNumber!].question_code == "T8" {
            return 80
        }
        else  if !(is_k12 ?? false) && optionsArray![section].isK_12School == "1" && questionArray![questNumber!].question_code == "14" {
            return 0.1
        }
        else if questionArray![questNumber!].question_code == "14" {
            return 70
        }
        if !is_k12! && optionsArray![section].isK_12School == "1"{
            return 0
        }
        return UITableView.automaticDimension
    }
    
 
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 55
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let label = UILabel()
        let view = UIView()
        let sectionButton = UIButton()
        var headerView = UIView()
        optionsArray![section].order_number = orderId!
        headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 55))
        if !is_k12! && optionsArray![section].isK_12School == "1"{
            headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 0))
            return headerView
        }
        if questionArray![questNumber!].question_code == "T5" {
            headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 0))
            let questionTypeCode = optionsArray![section].question_code_for_cascading_id
            if questionTypeCode == "C43"{
                headerView.frame = CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 55)
            }
            else {
                return headerView
            }
        }
        
       if questionArray![questNumber!].question_code == "T7" && section != 0{
            headerView.frame = CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 80)
        }
       else if questionArray![questNumber!].question_code == "T8"{
            headerView.frame = CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 80)
        }
        else if questionArray![questNumber!].question_code == "T4" && optionsArray![section].option_id == "1439"{
             headerView.frame = CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 120)
         }
        else if questionArray![questNumber!].question_code == "T4" && optionsArray![section].option_id == "1421"{
            headerView.frame = CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 90)
         }
        else if questionArray![questNumber!].question_code == "T4" && optionsArray![section].option_id == "1430"{
            headerView.frame = CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 90)
         }
        else if questionArray![questNumber!].question_code == "T4" && optionsArray![section].option_id == "1435"{
            headerView.frame = CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 90)
         }
        else if questionArray![questNumber!].question_code == "T4"{
             headerView.frame = CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 60)
         }
        else if questionArray![questNumber!].question_code == "14"{
            headerView.frame = CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 70)
        }
        else if questionArray![questNumber!].question_code == "21" && optionsArray![section].option_id == "211"{
             headerView.frame = CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 120)
         }
        else if questionArray![questNumber!].question_code == "21"{
             headerView.frame = CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 80)
         }
        
        if questionArray![questNumber!].question_code == "T6" {
            headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 0))
            return headerView
        }
        
        view.frame = CGRect.init(x: 0, y: 2, width: headerView.frame.width, height: headerView.frame.height-4)
        view.backgroundColor = UIColor(named: "LightGrayLightBlack")
        
        label.frame = CGRect.init(x: 15, y: 5, width: headerView.frame.width-50, height: headerView.frame.height-10)
        label.text = optionsArray![section].option_value
        label.numberOfLines = 0
        if self.traitCollection.userInterfaceStyle == .dark && questionArray![questNumber!].question_code == "5"{
            label.textColor = .black
         }
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = .systemFont(ofSize: 18)
        if optionsArray![section].isK_12School == "1"{
            label.textColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        }
        
        let radioImgView = UIImageView(frame: CGRect(x:0,y:(headerView.frame.size.height - 20)/2,width: 0,height:0))
        
        headerView.addSubview(view)
        headerView.addSubview(label)
        
        // Add Button
        
        let id = optionsArray![section].cascade_ripa_id
        sectionButton.frame = CGRect.init(x: 25, y: 5, width: headerView.frame.width, height: headerView.frame.height-4)
        
        if id != "" {
            
            let dropdownImageView = UIImageView()
            var dropdownImage = UIImage()
            
            if optionsArray![section].isExpanded{
                dropdownImage = UIImage(systemName: "chevron.up")!
            }
            else{
                dropdownImage = UIImage(systemName: "chevron.down")!
            }
            
            dropdownImageView.tintColor = UIColor(named: "BlackWhite")
            
            dropdownImageView.frame = CGRect.init(x: headerView.frame.width-40, y: (headerView.frame.height/2)-4, width: 20, height: 8)
            if section == 1, questionArray![questNumber!].question_code == "5" && self.optionsArray![section].inputTypeCode == "AN" && questionType == "MC"{
                sectionButton.tag = section
                dropdownImage = UIImage(systemName: "chevron.down")!
                dropdownImageView.frame = CGRect.init(x: headerView.frame.width-38, y: (headerView.frame.height/2)-3, width: 12, height: 6)
                sectionButton.addTarget(self,action: #selector(self.openOptionsList(sender:)), for: .touchUpInside)
             
                if locTypeIndex != 0 {
                    label.text = self.setLocationTypeTitle(type: locTypeIndex)
                }
            }
            else if questionArray![questNumber!].question_code != "23" || questionArray![questNumber!].question_code != "25"{
                
                sectionButton.tag = section
                sectionButton.addTarget(self,action: #selector(self.hideSection(sender:)), for: .touchUpInside)
            }
            else  {
                dropdownImage = UIImage(systemName: "chevron.up")!
            }
           
            dropdownImageView.image = dropdownImage
            
            headerView.addSubview(dropdownImageView)
            
        }
        else{
            
            if checkEditable == true && questionArray![questNumber!].editable_question != "1" || questionArray![questNumber!].question_code == "25"{
                print("Cannot Change Data")
            }
            else{
                
                if questionArray![questNumber!].is_required != "1" && questionArray![questNumber!].question_code != "25" {
                    optionsArray![section].isSelected = false
                }
                
                if questionArray![questNumber!].question_code == "10" {
                    let allowSelection = checkGender()
                    if allowSelection{
                        sectionButton.tag = section
                        sectionButton.addTarget(self, action: #selector(selectOption(sender:)), for: .touchUpInside)
                    }
                }
                else{
                    sectionButton.tag = section
                    if questionArray![questNumber!].question_code == "21", let cascadeOption = self.optionsArray?[section].questionoptions,cascadeOption.count > 0,let cascadeId = Int((cascadeOption[0]).cascade_ripa_id){
                        let cascadeQuestion = newRipaViewModel.getCascadeQuestionUsingId(questionID: cascadeId)
                        if cascadeQuestion.questionoptions!.count > 0 {
                            optionsArray![section].isSelected = true
                        }
                     }
                    sectionButton.addTarget(self, action: #selector(selectOption(sender:)), for: .touchUpInside)
                }
            }
        }
        
        view.backgroundColor = UIColor(named: "LightGrayLightBlack")
        radioImgView.image = UIImage(named: "Unselect")
        radioImgView.backgroundColor = .white
        
        if  optionsArray![section].isSelected && questionArray![questNumber!].question_code != "25"{
           // view.backgroundColor = UIColor(named: "SelectionBlue")
            radioImgView.frame = CGRect(x:10,y:(headerView.frame.size.height - 20)/2,width: 20,height:20)
            radioImgView.image = UIImage(named: "Select")
            label.frame = CGRect.init(x: 40, y: 5, width: headerView.frame.width-50, height: headerView.frame.height-10)
            label.font = UIFont.boldSystemFont(ofSize: 16.0)
            radioImgView.backgroundColor = .clear
            
        }
        else{
            radioImgView.frame = CGRect(x:10,y:(headerView.frame.size.height - 20)/2,width: 20,height:20)
            view.backgroundColor = UIColor(named: "LightGrayLightBlack")
            label.frame = CGRect.init(x: 40, y: 5, width: headerView.frame.width-50, height: headerView.frame.height-10)
            label.font = UIFont.systemFont(ofSize: 18.0)
            radioImgView.backgroundColor = .clear
        }
        
        if  optionsArray![section].isSelected && questionArray![questNumber!].question_code == "T8"{
            radioImgView.frame = CGRect(x:10,y:(headerView.frame.size.height - 20)/2,width: 20,height:20)
            radioImgView.image = UIImage(named: "Check")
            label.frame = CGRect.init(x: 35, y: 5, width: headerView.frame.width-50, height: headerView.frame.height-10)
            label.font = UIFont.boldSystemFont(ofSize: 16.0)
        }
        else if questionArray![questNumber!].question_code == "T8" {
            radioImgView.frame = CGRect(x:10,y:(headerView.frame.size.height - 20)/2,width: 20,height:20)
            radioImgView.image = UIImage(named: "uncheck")
            label.frame = CGRect.init(x: 35, y: 5, width: headerView.frame.width-50, height: headerView.frame.height-10)
            label.font = UIFont.systemFont(ofSize: 18.0)
        }
        else  if  optionsArray![section].isSelected && questionArray![questNumber!].question_code == "T4"{
            radioImgView.frame = CGRect(x:10,y:(headerView.frame.size.height - 20)/2,width: 20,height:20)
            radioImgView.image = UIImage(named: "Check")
            label.frame = CGRect.init(x: 35, y: 5, width: headerView.frame.width-50, height: headerView.frame.height-10)
            label.font = UIFont.boldSystemFont(ofSize: 16.0)
        }
        else if questionArray![questNumber!].question_code == "T4" {
            radioImgView.frame = CGRect(x:10,y:(headerView.frame.size.height - 20)/2,width: 20,height:20)
            radioImgView.image = UIImage(named: "uncheck")
            label.frame = CGRect.init(x: 35, y: 5, width: headerView.frame.width-50, height: headerView.frame.height-10)
            label.font = UIFont.systemFont(ofSize: 18.0)
        }
       else if  optionsArray![section].isSelected && questionArray![questNumber!].question_code == "T7"{
            radioImgView.frame = CGRect(x:10,y:(headerView.frame.size.height - 20)/2,width: 20,height:20)
            radioImgView.image = UIImage(named: "Check")
            label.frame = CGRect.init(x: 35, y: 5, width: headerView.frame.width-50, height: headerView.frame.height-10)
            label.font = UIFont.boldSystemFont(ofSize: 16.0)
        }
        else if questionArray![questNumber!].question_code == "T7" {
            radioImgView.frame = CGRect(x:10,y:(headerView.frame.size.height - 20)/2,width: 20,height:20)
            radioImgView.image = UIImage(named: "uncheck")
            label.frame = CGRect.init(x: 35, y: 5, width: headerView.frame.width-50, height: headerView.frame.height-10)
            label.font = UIFont.systemFont(ofSize: 18.0)
        }
        else if  optionsArray![section].isSelected && questionArray![questNumber!].question_code == "18"{
            radioImgView.frame = CGRect(x:10,y:(headerView.frame.size.height - 20)/2,width: 20,height:20)
            radioImgView.image = UIImage(named: "Check")
            label.frame = CGRect.init(x: 35, y: 5, width: headerView.frame.width-50, height: headerView.frame.height-10)
            label.font = UIFont.boldSystemFont(ofSize: 16.0)
        }
        else if questionArray![questNumber!].question_code == "18" {
            radioImgView.frame = CGRect(x:10,y:(headerView.frame.size.height - 20)/2,width: 20,height:20)
            radioImgView.image = UIImage(named: "uncheck")
            label.frame = CGRect.init(x: 35, y: 5, width: headerView.frame.width-50, height: headerView.frame.height-10)
            label.font = UIFont.systemFont(ofSize: 18.0)
        }
        else if  optionsArray![section].isSelected && questionArray![questNumber!].question_code == "21"{
            radioImgView.frame = CGRect(x:10,y:(headerView.frame.size.height - 20)/2,width: 20,height:20)
            radioImgView.image = UIImage(named: "Check")
            label.frame = CGRect.init(x: 35, y: 5, width: headerView.frame.width-50, height: headerView.frame.height-10)
            label.font = UIFont.boldSystemFont(ofSize: 16.0)
            
        }
        else if questionArray![questNumber!].question_code == "21" {
            radioImgView.frame = CGRect(x:10,y:(headerView.frame.size.height - 20)/2,width: 20,height:20)
            radioImgView.image = UIImage(named: "uncheck")
            label.frame = CGRect.init(x: 35, y: 5, width: headerView.frame.width-50, height: headerView.frame.height-10)
            label.font = UIFont.systemFont(ofSize: 18.0)
        }
        else if  optionsArray![section].isSelected && questionArray![questNumber!].question_code == "17"{
            
            radioImgView.frame = CGRect(x:10,y:(headerView.frame.size.height - 20)/2,width: 20,height:20)
            radioImgView.image = UIImage(named: "Check")
            label.frame = CGRect.init(x: 35, y: 5, width: headerView.frame.width-50, height: headerView.frame.height-10)
            label.font = UIFont.boldSystemFont(ofSize: 16.0)
        }
        else if  optionsArray![section].isExpanded && questionArray![questNumber!].question_code == "17"{
            radioImgView.frame = CGRect(x:10,y:(headerView.frame.size.height - 20)/2,width: 20,height:20)
            radioImgView.image = UIImage(named: "Check")
            label.frame = CGRect.init(x: 35, y: 5, width: headerView.frame.width-50, height: headerView.frame.height-10)
            label.font = UIFont.boldSystemFont(ofSize: 16.0)
        }
        else if questionArray![questNumber!].question_code == "17" {
            radioImgView.frame = CGRect(x:10,y:(headerView.frame.size.height - 20)/2,width: 20,height:20)
            radioImgView.image = UIImage(named: "uncheck")
            label.frame = CGRect.init(x: 35, y: 5, width: headerView.frame.width-50, height: headerView.frame.height-10)
            label.font = UIFont.systemFont(ofSize: 18.0)
        }
        else if  optionsArray![section].isSelected && questionArray![questNumber!].question_code == "19"{
            radioImgView.frame = CGRect(x:10,y:(headerView.frame.size.height - 20)/2,width: 20,height:20)
            radioImgView.image = UIImage(named: "Check")
            label.frame = CGRect.init(x: 35, y: 5, width: headerView.frame.width-50, height: headerView.frame.height-10)
            label.font = UIFont.boldSystemFont(ofSize: 16.0)
        }
        else if questionArray![questNumber!].question_code == "19" {
            radioImgView.frame = CGRect(x:10,y:(headerView.frame.size.height - 20)/2,width: 20,height:20)
            radioImgView.image = UIImage(named: "uncheck")
            label.frame = CGRect.init(x: 35, y: 5, width: headerView.frame.width-50, height: headerView.frame.height-10)
            label.font = UIFont.systemFont(ofSize: 18.0)
        }
        else if  optionsArray![section].isSelected && questionArray![questNumber!].question_code == "20"{
            radioImgView.frame = CGRect(x:10,y:(headerView.frame.size.height - 20)/2,width: 20,height:20)
            radioImgView.image = UIImage(named: "Check")
            label.frame = CGRect.init(x: 35, y: 5, width: headerView.frame.width-50, height: headerView.frame.height-10)
            label.font = UIFont.boldSystemFont(ofSize: 16.0)
        }
        else if questionArray![questNumber!].question_code == "20" {
            radioImgView.frame = CGRect(x:10,y:(headerView.frame.size.height - 20)/2,width: 20,height:20)
            radioImgView.image = UIImage(named: "uncheck")
            label.frame = CGRect.init(x: 35, y: 5, width: headerView.frame.width-50, height: headerView.frame.height-10)
            label.font = UIFont.systemFont(ofSize: 18.0)
        }
        
        if questionArray![questNumber!].question_code == "T5" || questionArray![questNumber!].question_code == "5"{
            label.frame = CGRect.init(x: 40, y: 5, width: headerView.frame.width-50, height: headerView.frame.height-10)
            radioImgView.isHidden = true
            label.font = UIFont.boldSystemFont(ofSize: 18.0)
            
        }
        if questionArray![questNumber!].question_code == "T5"{
            let requiredImgView = UIImageView(frame: CGRect(x:10,y:(headerView.frame.size.height - 20)/2,width: 20,height:20))
            requiredImgView.image = UIImage(named: "required_icon")
            headerView.addSubview(requiredImgView)
        }
        
        if questionArray![questNumber!].question_code == "5"{
            radioImgView.isHidden = true
            label.frame = CGRect.init(x: 15, y: 5, width: headerView.frame.width-50, height: headerView.frame.height-10)
        }
        
        if section == 1, questionArray![questNumber!].question_code == "5" && self.optionsArray![section].inputTypeCode == "AN" && questionType == "MC"{
            //view.backgroundColor = UIColor(named: "SelectionBlue")
            view.frame = CGRect.init(x: 12, y: 2, width: headerView.frame.width-24, height: headerView.frame.height-4)
            label.frame = CGRect.init(x: 20, y: 5, width: headerView.frame.width-30, height: headerView.frame.height-10)
            view.layer.cornerRadius = 5
            view.layer.borderColor = UIColor.gray.cgColor
            view.layer.borderWidth = 1
         //   dropdownImageView = UIImage(systemName: "chevron.down")!
            label.font = UIFont.systemFont(ofSize: 18.0)
            view.backgroundColor = UIColor(red:252/255.0, green:245/255.0, blue:204/255.0, alpha: 1.0)
        }
        
        if saveRipaStatus == "Created" && questionArray![questNumber!].question_code == "5"{
            view.backgroundColor = UIColor(named: "LightGrayLightBlack")
        }
        
        if questionArray![questNumber!].question_code == "T7" && section == 0{
           headerView.frame = CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 55)
        }
    
        headerView.addSubview(sectionButton)
        headerView.addSubview(radioImgView)
        
        return headerView
    }
    
    func setLocationTypeTitle(type : Int) -> String {
        var nameStr : String = ""
        if type == 6 {
            nameStr = "Geographic Coordinates"
        }
        else if type == 1 {
            nameStr = "Block Number and Street Name"
        }
        else if type == 2 {
            nameStr = "Closest Intersection"
        }
        else if type == 3 {
            nameStr = "Highway and Closest Highway"
        }
        else if type == 4 {
            nameStr = "Other"
        }
        return nameStr
    }
    
    
    func showAlertMessage(){
        
    }
    
    func checkGender()->Bool{
        var allowSelection = true
        let quest = newRipaViewModel.getQuestionUsingQuestionCode(question_code: 9)
        for options in quest.questionoptions! {
            if ((options).physical_attribute == "3" || (options).physical_attribute == "4") && (options).isSelected == true{
                allowSelection = false
            }
        }
        return allowSelection
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view.endEditing(true)
        trackApplicationTime()
        if indexPath.section > 0, questionArray![questNumber!].question_code == "T5"{
          return
        }
        if questionArray![questNumber!].question_code != "25" && questionArray![questNumber!].question_code != "5"{
            
            let ad = newRipaViewModel.getCascadeQuestionUsingId(questionID: Int(optionsArray![indexPath.section].cascade_ripa_id)!)
            
            self.optionsArray![indexPath.row].order_number = orderId!
            if checkEditable == true && questionArray![questNumber!].editable_question != "1"{
                print("Cannot Change Data")
            }
            else{
                if  (optionsArray![indexPath.section].questionoptions!.count != 0){
                    checkForSingleSelectionInCascade(section : indexPath.section, row:indexPath.row)
                }
                else{
                    checkForSingleSelection(index: indexPath.row)
                }
            }
            
            if questionArray![questNumber!].question_code == "T7"{
                newRipaViewModel.checkConsent()
                
                DispatchQueue.background(delay: 0.3, completion:{ [self] in
                    openViolationPopup(index: indexPath.row, popupFor: "Consent")
                })
            }
            
            for options in ad.questionoptions!{
                options.order_number = orderId!
                options.mainQuestOrder = orderId!
                ad.order_number = orderId!
             }
         }
        
        if indexPath.section == 1, questionArray![questNumber!].question_code == "5" && self.optionsArray![indexPath.section].inputTypeCode == "AN" && questionType == "MC"{
            (optionsArray![indexPath.section].questionoptions)?.forEach({
                $0.isSelected = false
            })
            self.descriptionBtn.isHidden = true
            if indexPath.row == 0 , self.checkLocationIsEnabled() == false{
                showGpsAlert()
                locTypeIndex = 1
                (optionsArray![indexPath.section].questionoptions![1]).isSelected = true
            }
            else  if indexPath.row == 0 {
               (optionsArray![indexPath.section].questionoptions![indexPath.row]).isSelected = true
               locTypeIndex = 6
                var latString : String = ""
                var longString : String = ""
                if let lat = UserDefaults.standard.string(forKey: "latitude"),let longg = UserDefaults.standard.string(forKey: "longitude") {
                    latString = lat
                    longString = longg
                    AppConstants.address = String(format: "%@ , %@", latString,longString)
                }
                var option:Questionoptions1?
                let questionID : Int? = Int(optionsArray![1].questionoptions![0].cascade_ripa_id)!
                let question = newRipaViewModel.getCascadeQuestionUsingId(questionID: questionID ?? 0)
                let ripaId = optionsArray![1].questionoptions![0].cascade_ripa_id
                option = newRipaViewModel.createObj(mainQuestId: questionId, ripaID: ripaId,optionValue: String(format: "%@,%@", latString,longString), physical_attribute: "", description: "", isSelected: true, mainQuestOrder: orderId!, isNewAdded: false, mainId: vioQuestionId)
                option = setMainQuestIdAndOptn(optn: option!)
                question.questionoptions!.append(setMainQuestIdAndOptn(optn: option!))
                
                cascadeArray.removeAll()
                checkMandatorySelection()
                tableView.reloadData()
            }
            else if indexPath.row == 1 {
                locTypeIndex = indexPath.row
                self.openList(index: 11)
               (optionsArray![indexPath.section].questionoptions![indexPath.row]).isSelected = true
            }
            else if indexPath.row == 2 {
                locTypeIndex = indexPath.row
                self.openList(index: 12)
               (optionsArray![indexPath.section].questionoptions![indexPath.row]).isSelected = true
            }
            else if indexPath.row == 3 {
                locTypeIndex = indexPath.row
                self.openList(index: 14)
               (optionsArray![indexPath.section].questionoptions![indexPath.row]).isSelected = true
            }
            else if indexPath.row == 4 {
                self.descriptionBtn.isHidden = false
                locTypeIndex = indexPath.row
               (optionsArray![indexPath.section].questionoptions![indexPath.row]).isSelected = true
                openDescriptionPopup()
            }
            else {
                 locTypeIndex = indexPath.row
                (optionsArray![indexPath.section].questionoptions![indexPath.row]).isSelected = true
            }
            
            optionsArray![1].isExpanded = false
            tableView.reloadData()
        }
        
        if questionArray![questNumber!].question_code == "T6" {
            if optionsArray![indexPath.section].question_code_for_cascading_id == "C45" && self.checkForTypeOfVehicleStop() == false {
                AppUtility.showAlertWithProperty("", messageString: "Please select the Vehicular Stop in Type of stop.")
                let indexb = optionsArray?.firstIndex{$0.question_code_for_cascading_id == "C45"}
                self.optionsArray![indexb!].isSelected = false
            }
            else  if optionsArray![indexPath.section].question_code_for_cascading_id == "C45" && self.checkForTypeOfVehicleStop() == true {
                let indexb = optionsArray?.firstIndex{$0.question_code_for_cascading_id == "C45"}
                self.optionsArray![indexb!].isSelected = true
            }
            else if self.checkForTypeOfStopPedestrain() == false && optionsArray![indexPath.section].question_code_for_cascading_id == "C46" {
                let indexb = optionsArray?.firstIndex{$0.question_code_for_cascading_id == "C46"}
                self.optionsArray![indexb!].isSelected = false
                AppUtility.showAlertWithProperty("", messageString: "Please select the Pedestrian Stop in Type of stop.")
            }
            else if self.checkForTypeOfStopPedestrain() == true && optionsArray![indexPath.section].question_code_for_cascading_id == "C46" {
                let indexb = optionsArray?.firstIndex{$0.question_code_for_cascading_id == "C46"}
                self.optionsArray![indexb!].isSelected = true
            }
        }
     
  /*
        if questionArray![questNumber!].question_code == "T6" {
            if self.checkForTypeOfVehicleStop() && optionsArray![indexPath.section].question_code_for_cascading_id != "C42" {
                if optionsArray![indexPath.section].question_code_for_cascading_id == "C45" {
                    let indexa = optionsArray?.firstIndex{$0.question_code_for_cascading_id == "C45"}
                    let indexb = optionsArray?.firstIndex{$0.question_code_for_cascading_id == "C46"}
                  //self.optionsArray![indexa!].isSelected = true
                    self.optionsArray![indexb!].isSelected = false
                }
                else{
                    let indexb = optionsArray?.firstIndex{$0.question_code_for_cascading_id == "C46"}
                    self.optionsArray![indexb!].isSelected = false
                    AppUtility.showAlertWithProperty("", messageString: "Please select the Pedestrian Stop in Type of stop.")
                }
            }
            else if self.checkForTypeOfStopPedestrain() && optionsArray![indexPath.section].question_code_for_cascading_id != "C42" {
                if optionsArray![indexPath.section].question_code_for_cascading_id == "C46" {
                    let indexa = optionsArray?.firstIndex{$0.question_code_for_cascading_id == "C46"}
                    let indexb = optionsArray?.firstIndex{$0.question_code_for_cascading_id == "C45"}
                 //  self.optionsArray![indexa!].isSelected = true
                    self.optionsArray![indexb!].isSelected = false
                }
                else {
                    let indexb = optionsArray?.firstIndex{$0.question_code_for_cascading_id == "C45"}
                    self.optionsArray![indexb!].isSelected = false
                    AppUtility.showAlertWithProperty("", messageString: "Please select the Vehicular Stop in Type of stop.")
                   
                }
            }
        }  */
        
        if questionArray![questNumber!].question_code == "T5" && optionsArray![indexPath.section].question_code_for_cascading_id == "C43"{
            self.settingForPassengerInformation()
        }
        
        setmodelArray()
        checkMandatorySelection()
        
    }
    
    func settingForPassengerInformation() {
        let question = newRipaViewModel.getQuestionUsingQuestionCodeUsingString(question_code: "T6")
        for option in question.questionoptions!{
            option.isSelected = false
       }
    }
    
    
    func showGpsAlert() {
        let alert = UIAlertController(title: nil, message: "Device GPS is not enabled. Please select another option for the location type.", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
           // self.openList(index: 11)
            self.optionsArray![1].questionoptions?.forEach({
                $0.isSelected = false
            })
            self.locTypeIndex = 0
            self.tableView.reloadData()
            self.openLocationTypeOptionsList(sender:1)
           })
        )
        self.present(alert, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
            return false
     }
    
    internal func tableView(_ tableView: UITableView, commit editingStyle:   UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if (editingStyle == .delete) {
                tableView.beginUpdates()
                tableView.deleteRows(at: [indexPath], with: .middle)
                tableView.endUpdates()
           }
     }
    
    func checkLocationIsEnabled() -> Bool {
        if CLLocationManager.locationServicesEnabled() {
            switch locationManager.authorizationStatus {
                case .notDetermined, .restricted, .denied:
                    print("No access")
                   return false
                case .authorizedAlways, .authorizedWhenInUse:
                    print("Access")
                   return true
                @unknown default:
                    break
            }
        } else {
            print("Location services are not enabled")
            return false
        }
        return false
    }
    
    
    func checkForSingleSelectionInCascade(section : Int, row:Int){
      //  print(cascadeQuestionType)
        if cascadeQuestionType == "SC" || cascadeQuestionType == "MC"{
            (optionsArray![section].questionoptions![row] ).isSelected  =  !(optionsArray![section].questionoptions![row] ).isSelected
            
            if cascadeQuestionType == "SC"{
                var i = 0
                for options in optionsArray![section].questionoptions!{
                    if (row != i){
                        (options).isSelected = false
                    }
                    i += 1
                } }
        }
        
        checkNonCascadeSelection(section: section)
        if questionArray![questNumber!].question_code == "T5"{
            if (viewType == "StartNewRipa" || viewType == "UseLastRipa" || viewType == "Template"){
                if selectedOptionsArray.count > 3{
                    selectedOptionsArray[3].forEach({$0.isSelected = false})
                }
            }
            self.optionsArray![section].questionoptions?.forEach({
                $0.isSelected = false
            })
            (optionsArray![section].questionoptions![row] ).isSelected =  true
        }
        tableView.reloadData()
    }
    
    
    func checkNonCascadeSelection(section:Int){
        var selected = true
        for option in optionsArray![section].questionoptions!{
            if (option ).isSelected {
                selected = false
            }
        }
        optionsArray![section].isSelected  =  selected
        checkForSingleSelection(index: section)
    }
    
    
    @objc func autoMoveNext(indexValue : Int){
        if checkDiscriptionEntered(){
            setOptionOrder()
            if AppConstants.autoNext == true && questNumber! < questionArray!.count-1 && (questionType == "SC" || questionType == "SL" || (questionArray![questNumber!].question_code == "T8" && optionsArray?[indexValue].option_value.capitalized == "None" && optionsArray?[indexValue].isSelected == true) || (questionArray![questNumber!].question_code == "T7" && optionsArray?[indexValue].option_value.capitalized == "None" && optionsArray?[indexValue].isSelected == true) || (questionArray![questNumber!].question_code == "18" && optionsArray?[indexValue].option_value.capitalized == "None" && optionsArray?[indexValue].isSelected == true)) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                    self.nextQuestion()
                })
            }
        }
    }
    
    @objc func textIsChanging(_ textField:UITextField) -> Bool{

     print ("TextField is changing")
        var newString = textField.text!
        if questionType == "MC" && questionArray![questNumber!].question == "Location"{
            if textField.tag == 10{
                if let intValue = Float(newString), intValue > 1440{
                    AppUtility.showAlertWithProperty("Alert", messageString: "Duration should be between 1 to 1440 (24 hour)")
                    newString.removeLast()
                    enableNextButton(View: nextView)
                    self.durationTxtField.text = newString
                    return false
                }
                else  if let intValue = Float(newString), intValue < 1{
                    AppUtility.showAlertWithProperty("Alert", messageString: "Duration should be between 1 to 1440 (24 hour)")
                    newString.removeLast()
                    enableNextButton(View: nextView)
                    self.durationTxtField.text = newString
                    return false
                }
                ripaActivity?.stop_duration = newString
                if newString.contains("-") {
                    newString = newString.replacingOccurrences(of: "-", with: "")
                }
                self.durationTxtField.text = ""
                self.durationTxtField.text = newString
                if self.durationTxtField.text?.count ?? 0 > 0 && !previewViewModel.checkLocationIsEmpty() && locTypeIndex != 0{
                    enableNextButton(View: nextView)
                }
                print("should change character")
                print(newString)
                AppConstants.duration = newString
                return true
            }
            else if let intValue = Int(newString), intValue > 999999{
                return false
            }
            
        }
       return true
    }
 
   
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var newString = NSString(string: textField.text!).replacingCharacters(in: range, with: string)
        ///  let newLength:Int = newString.count
        print(newString)
        print(textField.text!)
        if  questionArray![questNumber!].question_code == "11" || questionArray![questNumber!].question_code == "25"{
            if let intValue = Int(newString), intValue > 120 || intValue < 1{
                return false
            }
        }
        
        if textField.tag == 99,questionArray![questNumber!].question_code == "5",locTypeIndex == 1 {
            newString = newString.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        if textField.tag == 99,questionArray![questNumber!].question_code == "5",locTypeIndex == 1,newString.count > 0,fizzbuzz(number: Int(newString) ?? 0) == false {
            self.showToastForStreet()
        }
        
        if  questionArray![questNumber!].question_code == "5",locTypeIndex == 1,newString.count > 8{
           return false
        }
        
        if questionArray![questNumber!].question_code == "23" || questionArray![questNumber!].question_code == "25" {
            indexPath = textField.tag
        }
        if textField.tag != 10{
            blockStr = newString
            answer = newString
            if questionArray![questNumber!].question_code != "23"{
                checkSingleAndMultiline()
            }
            let questionTypeCode = optionsArray![questNumber!].questionTypeCode
            
            if questionTypeCode == "SL" || textField.tag == 1{
                self.age = Int(textField.text!) ?? 0
             /*   if selectedOptionsArray.count > 0,selectedOptionsArray[2].count > 2,selectedOptionsArray[2][2].cascade_ripa_id == "65" {
                    selectedOptionsArray[2][2].option_value = String(self.age)
                }
               else  */
                if selectedOptionsArray.count > 0,selectedOptionsArray[2].count > 3 {                    selectedOptionsArray[2][3].option_value = String(self.age)
                }
                let otp = selectedOptionsArray[2]
            }
        }
        
        if textField.tag == 99,let intValue = Int(newString), intValue > 99999999 {
           return false
        }
        else if textField.tag == 99 {
            AppConstants.block = newString
        }
        else if textField.tag == 999 && newString.count > 75 {
            return false
        }
        else if textField.tag == 999 {
            AppConstants.closestHighway = newString
        }
        
        checkMandatorySelection()
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let newString = textField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
         if  questionArray![questNumber!].question_code == "5",locTypeIndex == 1,textField.tag == 99,textField.text == "00"{
            var option:Questionoptions1?
            let questionID : Int? = Int(optionsArray![1].questionoptions![1].cascade_ripa_id)!
            let question = newRipaViewModel.getCascadeQuestionUsingId(questionID: questionID ?? 0)
            let ripaId = optionsArray![1].questionoptions![1].cascade_ripa_id
            option = newRipaViewModel.createObj(mainQuestId: questionId, ripaID: ripaId,optionValue: textField.text!, physical_attribute: "", description: "", isSelected: true, mainQuestOrder: orderId!, isNewAdded: false, mainId: vioQuestionId)
            option = setMainQuestIdAndOptn(optn: option!)
            question.questionoptions!.append(setMainQuestIdAndOptn(optn: option!))
            AppConstants.block = textField.text!
            AppConstants.address = String(format: "%@ BLK & %@", AppConstants.block,AppConstants.street)
            cascadeArray.removeAll()
            checkMandatorySelection()
            tableView.reloadData()
         }
        else if  textField.tag == 99,questionArray![questNumber!].question_code == "5",locTypeIndex == 1,textField.text?.count ?? 0 > 0,fizzbuzz(number: Int(newString) ?? 0) == false {
            AppConstants.block = ""
            AppUtility.showAlertWithProperty("", messageString: "Please enter 100 Block.")
        }
        else  if  questionArray![questNumber!].question_code == "5",locTypeIndex == 1,textField.tag == 99{
    
            var option:Questionoptions1?
            var questionID : Int?
            var ripaId = "120"
            if optionsArray?[1].questionoptions?.count ?? 0 > 1, let qId = optionsArray?[1].questionoptions?[1].cascade_ripa_id {
                questionID = Int(qId)
                ripaId = qId
            }
            else {
                questionID = 120
            }
            
            let question = newRipaViewModel.getCascadeQuestionUsingId(questionID: questionID ?? 0)
            
            option = newRipaViewModel.createObj(mainQuestId: questionId, ripaID: ripaId,optionValue: textField.text!, physical_attribute: "", description: "", isSelected: true, mainQuestOrder: orderId!, isNewAdded: false, mainId: vioQuestionId)
            option = setMainQuestIdAndOptn(optn: option!)
            question.questionoptions!.append(setMainQuestIdAndOptn(optn: option!))
            AppConstants.block = textField.text!
            AppConstants.address = String(format: "%@ BLK & %@", AppConstants.block,AppConstants.street)
            cascadeArray.removeAll()
            checkMandatorySelection()
            tableView.reloadData()
         }
        else if  questionArray![questNumber!].question_code == "5",locTypeIndex == 3,textField.tag == 999,textField.text?.count ?? 0 < 1 {
            AppUtility.showAlertWithProperty("", messageString: "Please enter correct Closest Highway Exit!")
        }
        else if  questionArray![questNumber!].question_code == "5",locTypeIndex == 3,textField.tag == 999{

            var option:Questionoptions1?
            let questionID : Int? = Int(optionsArray![1].questionoptions![3].cascade_ripa_id)!
            let ripaId = optionsArray![1].questionoptions![3].cascade_ripa_id
      //      optionsArray![1].questionoptions![3].isSelected = true
            let question = newRipaViewModel.getCascadeQuestionUsingId(questionID: questionID ?? 0)
            option = newRipaViewModel.createObj(mainQuestId: questionId, ripaID: ripaId,optionValue: textField.text!, physical_attribute: "", description: "", isSelected: true, mainQuestOrder: orderId!, isNewAdded: false, mainId: vioQuestionId)
            option = setMainQuestIdAndOptn(optn: option!)
            question.questionoptions!.append(setMainQuestIdAndOptn(optn: option!))
            AppConstants.closestHighway = textField.text!
            AppConstants.address = String(format: "%@ & %@", AppConstants.highway,AppConstants.closestHighway)
            
            cascadeArray.removeAll()
            checkMandatorySelection()
            tableView.reloadData()
         }
        
       
        print("sdbfhdfbhgjcfhfg")
    }
    
    func showToastForStreet () {
        self.showToast(message: "Please enter 100 Block.", font: .systemFont(ofSize: 16.0))
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func fizzbuzz(number: Int) -> Bool {
        if number == 0 {
            return false
        }
        else if number < 91 && number % 10 == 0 {
            return true
        }
        else if number % 100 == 0 {
            return true
         }
        else {
            return false
        }
    }
    
    @objc func keyboardWillAppear() {
        
    }
    
    
    
    @objc func keyboardWillDisappear() {
        isKeyboard = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [self] in
            if self.questionArray![questNumber!].question_code == "23"{
                resignFirstResponder()
                if  self.answer != ""{
                    self.checkSingleAndMultiline()
                }
                self.tableView.reloadData()
                
            }
            
            //Location Condition
            if questionType == "MC" && questionArray![questNumber!].question_code == "5"{
                self.tableView.reloadData()
            }
            
            //Perceived Age of Person Stopped
            if self.questionArray![questNumber!].question_code == "11" || questionArray![questNumber!].question_code == "25"{
                checkMandatorySelection()
                if questionArray![questNumber!].questionoptions!.count > 0{
                    if questionArray![questNumber!].questionoptions![0].isSelected == true{
                        resignFirstResponder()
                        autoMoveNext(indexValue : 0)
                    }
                }
                self.tableView.reloadData()
            }
        }
    }
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool{
        let newString = NSString(string: textView.text!).replacingCharacters(in: range, with: text)
        let newLength:Int = newString.count
        if(newLength < 251){
            answer = newString
            checkSingleAndMultiline()
            return true
        }
        return false
    }
    
    
    @objc func switchChanged(_ sender : UISwitch!){
        let id = optionsArray![sender.tag].cascade_ripa_id
        let question = newRipaViewModel.getCascadeQuestionUsingId(questionID: Int(id)!)
        let studentQuest = newRipaViewModel.getCascadeQuestionUsingQuestionCode(questionCode: "C27")
        
        question.questionoptions![0].isSelected = false
        question.questionoptions![1].isSelected = true
        
        
        question.order_number = orderId!
        
        for opt in question.questionoptions!{
            opt.mainQuestOrder =  orderId!
            opt.order_number = orderId!
        }
        
        if questionArray![questNumber!].question_code == "25" && viewType == "UseSaveRipa",personcount < personArray.count{
           
            let personDict = personArray[personcount]
            var selectedOption = personDict["SelectedOption"] as! [[Questionoptions1]]
            if id == "68" {
    
                question.questionoptions!.removeAll()
                let object = newRipaViewModel.setLimitedOrNoEnglishFluenctOption()
                object.option_value = "Yes"
                object.option_id = "1259"
                question.questionoptions?.append(object)
                question.questionoptions?.append(newRipaViewModel.setLimitedOrNoEnglishFluenctOption())
                let index = selectedOption[2].firstIndex(where: {$0.ripa_id == "68"})!
                selectedOption[2].remove(at: index)
                if sender.isOn{
                    question.questionoptions![0].isSelected = true
                    question.questionoptions![1].isSelected = false
                    selectedOption[2][selectedOption[2].count - 1].isSelected = true
                    selectedOption[2].append(question.questionoptions![0])
                }
                else {
                    question.questionoptions![0].isSelected = false
                    question.questionoptions![1].isSelected = true
                    selectedOption[2][selectedOption[2].count - 1].isSelected = false
                    selectedOption[2].append(question.questionoptions![1])
                }
            }
            else if id == "62" {
                selectedOption[2].remove(at: 1)
                if sender.isOn{
                    question.questionoptions![0].isSelected = true
                    question.questionoptions![1].isSelected = false
                    selectedOption[2][0].isSelected = true
                    selectedOption[2].insert(question.questionoptions![0], at: 1)
                }
                else {
                    question.questionoptions![0].isSelected = false
                    question.questionoptions![1].isSelected = true
                    selectedOption[2][0].isSelected = false
                    selectedOption[2][0].isSelected = false
                    selectedOption[2].insert(question.questionoptions![1], at: 1)
                }
            }
             personArray[personcount]["SelectedOption"] = selectedOption
        }
        
        
        if sender.isOn{
            question.questionoptions![0].isSelected = true
            question.questionoptions![1].isSelected = false
        }
        else{
            studentQuest.questionoptions![0].isSelected = false
            studentQuest.questionoptions![1].isSelected = true
            is_k12 = false
            AppConstants.isStudent = "0"
            resetIsK12Options()
        }
        
        
        if question.question_code == "C27" {
            if question.questionoptions![0].isSelected == true{
                is_k12 = true
                AppConstants.isStudent = "1"
            }
            else if question.questionoptions![0].isSelected != true{
                if AppConstants.isSchoolSelected == "Yes"{
                    AppConstants.isStudent = "0"
                    studentQuest.questionoptions![0].isSelected = false
                    studentQuest.questionoptions![1].isSelected = true
                    is_k12 = false
                    resetIsK12Options()
                }
                else{
                    AppConstants.isStudent = "0"
                    question.questionoptions![1].isSelected = false
                }
            }
        }

        checkMandatory()
        tableView.reloadData()
    }
    
    
    @objc func openOptionsList(sender: UIButton) {
        if questionArray![questNumber!].question_code == "5" && cityID.count == 0{
            DispatchQueue.main.async {
                AppUtility.showAlertWithProperty("", messageString: "Please select another city.")
            }
        }
        else {
             let quest = newRipaViewModel.getCascadeQuestionUsingId(questionID: Int(optionsArray![sender.tag].cascade_ripa_id)!)
             guard let optionsPopup = selectOptionPopup else { return }
             indexPath = sender.tag
             optionsPopup.selectOptionsPopupDelegate = self

             //optionsPopup.question = "Select " + optionsArray![sender.tag].option_value
             optionsPopup.question = optionsArray![sender.tag].option_value
             optionsPopup.selectionType = quest.questionTypeCode
             optionsPopup.isK12 = is_k12
             
             var optionArr = [Questionoptions1]()
            
             for option in quest.questionoptions!{
                 if questionArray![questNumber!].question_code == "25" && viewType != "StartNewRipa",personcount < personArray.count{
                     var personDict = personArray[personcount]
                     var selectedOption = personDict["SelectedOption"] as! [[Questionoptions1]]
                     if selectedOption.count > 2 && option.option_value == "Straight/Heterosexual"{
                         let exist = selectedOption[2].contains(where: {$0.option_value == "Straight/Heterosexual"})
                         if exist == false {
                             option.isSelected = false
                             selectedOption[2].append(option)
                             personDict["SelectedOption"] = selectedOption
                             personArray[personcount] = personDict
                         }
                     }
                     if selectedOption.count > 2 && selectedOption[2].count > 5 && sender.tag == 2{
                         let personOpt = selectedOption[2][5]
                         option.isSelected = false
                         if option.option_value == personOpt.option_value && option.main_question_id == personOpt.main_question_id {
                             option.isSelected = true
                         }
                     }
                    else if selectedOption.count > 2 && selectedOption[2].count > 7 && sender.tag == 3{
                         let personOpt = selectedOption[2][7]
                         if option.option_value == personOpt.option_value && option.main_question_id == personOpt.main_question_id {
                             option.isSelected = true
                         }
                         else {
                             option.isSelected = false
                         }
                     }
                     else if selectedOption.count > 2 && selectedOption[2].count > 6 && sender.tag == 3{
                          let personOpt = selectedOption[2][6]
                          if option.option_value == personOpt.option_value && option.main_question_id == personOpt.main_question_id {
                              option.isSelected = true
                          }
                          else {
                              option.isSelected = false
                          }
                      }
                     else if selectedOption.count > 2 && sender.tag == 4{
                         let personOpt = selectedOption[2]
                         for dict in personOpt{
                             if dict.ripa_id == "67" {
                                 if option.option_value == dict.option_value && option.main_question_id == dict.main_question_id {
                                     option.isSelected = true
                                 }
                             }
                         }
                     }
                 }
                 if saveRipaStatus == "Saved" && questionArray![questNumber!].question_code == "25" && option.ripa_id == "33" && self.age == 0 && option.option_id == "162"{
                     option.isSelected = false
                 }
                 let copyoption = option.copy()
                 optionArr.append(copyoption as! Questionoptions1)
             }
            
            if questionArray![questNumber!].question_code == "5" , optionArr.count == 0 {
                optionArr = locArray
             }
            if questionArray![questNumber!].question_code == "5" , optionArr.count < 4 {
                optionsArray?[1].questionoptions = self.createOptionArray()
                optionArr = self.createOptionArray()
             }
            
             if !self.isGpsCityMatched {
                 optionArr[0].isSelected = false
             }
           
         //   print(locTypeIndex)
             optionsPopup.optionsArray = optionArr
            
             
             var height = 150
             if quest.questionTypeCode == "SC"{
                 height = 92
             }
            
            print(saveRipaStatus)
             if saveRipaStatus == "Created" && questionArray![questNumber!].question_code == "5"{}
            else if optionArr.isEmpty {
                AppUtility.showAlertWithProperty("", messageString: "Something Went Wrong! Please Go Back and Try Again....")
            }
            else {
                let popupVC = PopupViewController(contentController: optionsPopup, position: .bottom(UIScreen.main.bounds.size.width/2), popupWidth: UIScreen.main.bounds.size.width-30, popupHeight: CGFloat((50*optionArr.count)) + CGFloat(height))
                popupVC.cornerRadius = 5
                popupVC.delegate = self
                present(popupVC, animated: true, completion: nil)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "optionNotif"), object: nil)
            }
        }
    }
    
    func createOptionArray() -> [Questionoptions1] {
        var questOption = [Questionoptions1]()
        let geographicObj = Questionoptions1(mainQuestId: "118", mainQuestOrder: "1", option_id: "1408", ripa_id: "118", custid: "1", option_value: "Geographic Coordinate", cascade_ripa_id: "119", isK_12School: "", isHideQuesText: "", order_number: "1", createdBy: "", createdOn: "", updatedBy: "", updatedOn: "", isSelected: false, isAddtion: "", isDescription_Required: "No", inputTypeCode: "AN", questionTypeCode: "SC", tag: "", physical_attribute: "1", default_value: "", optionDescription: "", question_code_for_cascading_id: "C53", isQuestionMandatory: "Yes", isQuestionDescriptionReq: "No", main_question_id: "21", isExpanded: false, isNewAdded: false, mainId: "", questionoptions: [])
        if AppConstants.LocTypeIndex == 6 {
            geographicObj.isSelected = true
        }
        questOption.append(geographicObj)
        
        let blockObj = Questionoptions1(mainQuestId: "118", mainQuestOrder: "1", option_id: "1409", ripa_id: "118", custid: "1", option_value: "Block Number and Street Name", cascade_ripa_id: "120", isK_12School: "", isHideQuesText: "", order_number: "1", createdBy: "", createdOn: "", updatedBy: "", updatedOn: "", isSelected: false, isAddtion: "", isDescription_Required: "No", inputTypeCode: "A", questionTypeCode: "MC", tag: "", physical_attribute: "2", default_value: "", optionDescription: "", question_code_for_cascading_id: "C54", isQuestionMandatory: "Yes", isQuestionDescriptionReq: "No", main_question_id: "21", isExpanded: false, isNewAdded: false, mainId: "", questionoptions: [])
        if AppConstants.LocTypeIndex == 1 {
            blockObj.isSelected = true
        }
        questOption.append(blockObj)
        
        let IntObj = Questionoptions1(mainQuestId: "118", mainQuestOrder: "1", option_id: "1410", ripa_id: "118", custid: "1", option_value: "Closest Intersection", cascade_ripa_id: "121", isK_12School: "", isHideQuesText: "", order_number: "1", createdBy: "", createdOn: "", updatedBy: "", updatedOn: "", isSelected: false, isAddtion: "", isDescription_Required: "No", inputTypeCode: "A", questionTypeCode: "MC", tag: "", physical_attribute: "3", default_value: "", optionDescription: "", question_code_for_cascading_id: "C55", isQuestionMandatory: "Yes", isQuestionDescriptionReq: "No", main_question_id: "21", isExpanded: false, isNewAdded: false, mainId: "", questionoptions: [])
        if AppConstants.LocTypeIndex == 2 {
            IntObj.isSelected = true
        }
        questOption.append(IntObj)
        
        let highObj = Questionoptions1(mainQuestId: "118", mainQuestOrder: "1", option_id: "1411", ripa_id: "118", custid: "1", option_value: "Highway and Closest Highway Exit", cascade_ripa_id: "122", isK_12School: "", isHideQuesText: "", order_number: "1", createdBy: "", createdOn: "", updatedBy: "", updatedOn: "", isSelected: false, isAddtion: "", isDescription_Required: "No", inputTypeCode: "A", questionTypeCode: "MC", tag: "", physical_attribute: "4", default_value: "", optionDescription: "", question_code_for_cascading_id: "C56", isQuestionMandatory: "Yes", isQuestionDescriptionReq: "No", main_question_id: "21", isExpanded: false, isNewAdded: false, mainId: "", questionoptions: [])
        if AppConstants.LocTypeIndex == 3 {
            highObj.isSelected = true
        }
        questOption.append(highObj)
        
        let otherObj = Questionoptions1(mainQuestId: "118", mainQuestOrder: "1", option_id: "1412", ripa_id: "118", custid: "1", option_value: "Other", cascade_ripa_id: "123", isK_12School: "", isHideQuesText: "", order_number: "1", createdBy: "", createdOn: "", updatedBy: "", updatedOn: "", isSelected: false, isAddtion: "", isDescription_Required: "No", inputTypeCode: "AN", questionTypeCode: "ML", tag: "", physical_attribute: "5", default_value: "", optionDescription: "", question_code_for_cascading_id: "C57", isQuestionMandatory: "Yes", isQuestionDescriptionReq: "No", main_question_id: "21", isExpanded: false, isNewAdded: false, mainId: "", questionoptions: [])
        if AppConstants.LocTypeIndex == 4 {
            otherObj.isSelected = true
        }
        questOption.append(otherObj)
        
        return questOption
    }
    
    
    func openLocationTypeOptionsList(sender:Int) {
        let quest = newRipaViewModel.getCascadeQuestionUsingId(questionID: Int(optionsArray![sender].cascade_ripa_id)!)
        guard let optionsPopup = selectOptionPopup else { return }
        indexPath = sender
        optionsPopup.selectOptionsPopupDelegate = self
        //optionsPopup.question = "Select " + optionsArray![sender.tag].option_value
        optionsPopup.question = optionsArray![sender].option_value
        optionsPopup.selectionType = quest.questionTypeCode
        optionsPopup.isK12 = is_k12
        
        var optionArr = [Questionoptions1]()
        
        for option in quest.questionoptions!{
            let copyoption = option.copy()
            optionArr.append(copyoption as! Questionoptions1)
        }
        
        optionsPopup.optionsArray = optionArr
    
        var height = 150
        if quest.questionTypeCode == "SC"{
            height = 92
        }
       
            let popupVC = PopupViewController(contentController: optionsPopup, position: .bottom(UIScreen.main.bounds.size.width/2), popupWidth: UIScreen.main.bounds.size.width-30, popupHeight: CGFloat((50*optionArr.count)) + CGFloat(height))
            popupVC.cornerRadius = 5
            popupVC.delegate = self
            present(popupVC, animated: true, completion: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "optionNotif"), object: nil)
        
    }
    
    func selectedOptionFromPopup(optionArray: [Questionoptions1]){
        var chooseOptions = optionArray
      
        let id = optionsArray![indexPath!].cascade_ripa_id
        let question = newRipaViewModel.getCascadeQuestionUsingId(questionID: Int(id)!)
        if questionArray![questNumber!].question_code == "5"{
            if chooseOptions.count > 5 {
                chooseOptions.removeLast()
            }
            if chooseOptions.count > 5 {
                chooseOptions.removeLast()
            }
        }
        
        question.questionoptions = chooseOptions
        
        for opt in chooseOptions{
            opt.mainQuestOrder = orderId!
            opt.cascade_ripa_id = orderId!
            print(cityID)
           if questionArray![questNumber!].question_code == "5"{
    
                if opt.question_code_for_cascading_id == "C53" && opt.isSelected == true{
                   // self.isGeoLocation(check: false)
                    self.countyBtn.isUserInteractionEnabled = true
                    self.countyLbl.isUserInteractionEnabled = true
                    self.countyLbl.borderColor = .black
                  //  self.countyLbl.textColor = .black
                    self.dropImgView.tintColor = .black
                    isGpsEnable = false
                    if self.checkLocationIsEnabled() == false{
                       // locTypeIndex = 6
                        DispatchQueue.main.async(execute: {
                            self.showGpsAlert()
                        })
                      //  (optionsArray![1].questionoptions![1]).isSelected = true
                    }
                    else {
                        isGpsEnable = true
                        self.countyBtn.isUserInteractionEnabled = false
                        self.countyLbl.isUserInteractionEnabled = false
                        self.countyLbl.borderColor = .lightGray
                        self.countyLbl.textColor = .gray
                        self.dropImgView.tintColor = .lightGray
                        //self.isGeoLocation(check: true)
                        self.locTypeIndex = 6
                        var latString : String = ""
                        var longString : String = ""
                        if let lat = UserDefaults.standard.string(forKey: "latitude"),let longg = UserDefaults.standard.string(forKey: "longitude") {
                            latString = lat
                            longString = longg
                            AppConstants.address = String(format: "%@ , %@", lat,longg)
                        }
                        var option:Questionoptions1?
                        let questionID : Int? = Int(optionsArray![1].questionoptions![0].cascade_ripa_id)!
                        let question = newRipaViewModel.getCascadeQuestionUsingId(questionID: questionID ?? 0)
                        let ripaId = optionsArray![1].questionoptions![0].cascade_ripa_id
                        option = newRipaViewModel.createObj(mainQuestId: questionId, ripaID: ripaId,optionValue: String(format: "%@,%@", latString,longString), physical_attribute: "", description: "", isSelected: true, mainQuestOrder: orderId!, isNewAdded: false, mainId: vioQuestionId)
                        option = setMainQuestIdAndOptn(optn: option!)
                        question.questionoptions!.append(setMainQuestIdAndOptn(optn: option!))
                        gpsLocation.delegate = self
                        gpsLocation.getGPSLocation()
                        cascadeArray.removeAll()
                        checkMandatorySelection()
                        
                    }
                }
                else if opt.question_code_for_cascading_id == "C54" && opt.isSelected == true{
                    self.locTypeIndex = 1
                    self.countyBtn.isUserInteractionEnabled = true
                    self.countyLbl.isUserInteractionEnabled = true
                    self.countyLbl.borderColor = .black
                  //  self.countyLbl.textColor = .black
                    self.dropImgView.tintColor = .black
                    isGpsEnable = false
                    //self.isGeoLocation(check: false)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.openList(index: 11)
                    }
                    optionsArray![1].questionoptions?.forEach({
                        $0.isSelected = false
                    })
                    (optionsArray![1].questionoptions![1]).isSelected = true
                }
                else if opt.question_code_for_cascading_id == "C55" && opt.isSelected == true{
                    self.locTypeIndex = 2
                    self.countyBtn.isUserInteractionEnabled = true
                    self.countyLbl.isUserInteractionEnabled = true
                    self.countyLbl.borderColor = .black
                  //  self.countyLbl.textColor = .black
                    self.dropImgView.tintColor = .black
                    isGpsEnable = false
                   // self.isGeoLocation(check: false)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.openList(index: 12)
                    }
                    optionsArray![1].questionoptions?.forEach({
                        $0.isSelected = false
                    })
                    (optionsArray![1].questionoptions![2]).isSelected = true
                }
                else if opt.question_code_for_cascading_id == "C56" && opt.isSelected == true{
                    self.locTypeIndex = 3
                    self.countyBtn.isUserInteractionEnabled = true
                    self.countyLbl.isUserInteractionEnabled = true
                    self.countyLbl.borderColor = .black
                  //  self.countyLbl.textColor = .black
                    self.dropImgView.tintColor = .black
                    isGpsEnable = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.openList(index: 14)
                    }
                    optionsArray![1].questionoptions?.forEach({
                        $0.isSelected = false
                    })
                    (optionsArray![1].questionoptions![3]).isSelected = true
                }
                else if opt.isSelected == true{
                    self.locTypeIndex = 4
                    self.countyBtn.isUserInteractionEnabled = true
                    self.countyLbl.isUserInteractionEnabled = true
                    self.countyLbl.borderColor = .black
                 //   self.countyLbl.textColor = .black
                    self.dropImgView.tintColor = .black
                    isGpsEnable = false
                    DispatchQueue.background(delay: 0.1, completion:{
                        self.openDescriptionPopup()
                    })
                    optionsArray![1].questionoptions?.forEach({
                        $0.isSelected = false
                    })
                    (optionsArray![1].questionoptions![4]).isSelected = true
                  //  print((optionsArray![1].questionoptions![4]).option_value)
                }
            }
        }
        
     
        if questionArray![questNumber!].question_code == "25" && ((viewType != "StartNewRipa" && AppConstants.status != "LastRipa" && AppConstants.status != "Template" && saveRipaStatus != "Created") || AppConstants.isTemplate == "temp") && !(personcount > personArray.count - 1){
            let personDict = personArray[personcount]
            var selectedOption = personDict["SelectedOption"] as! [[Questionoptions1]]
            for opt in chooseOptions{
                if id == "67" && opt.isSelected == true {
                    opt.ripa_id = "67"
                    selectedOption[2] = selectedOption[2].filter{ $0.ripa_id != "67"}
                }
                else if id == "69" && opt.isSelected == true {
                    opt.ripa_id = "69"
                    selectedOption[2] = selectedOption[2].filter{$0.ripa_id != "69"}
                }
            }
            for opt in chooseOptions{
                if id == "64" && opt.isSelected == true {
                    selectedOption[2] = selectedOption[2].filter{ $0.ripa_id != "64"}
                    opt.mainQuestId = "64"
                    opt.ripa_id = "64"
                    opt.option_id = "1242"
                    opt.physical_attribute = newRipaViewModel.checkPhysicalAttribute(type: opt.option_value)
                    selectedOption[2].append(opt)
                }
                else if id == "66" && opt.isSelected == true {
                    selectedOption[2] = selectedOption[2].filter{ $0.ripa_id != "66"}
                    opt.mainQuestId = "66"
                    opt.ripa_id = "66"
                    opt.option_id = "1245"
                    opt.physical_attribute = newRipaViewModel.checkPhysicalAttribute(type: opt.option_value)
                    selectedOption[2].append(opt)
                }
                else if id == "67" && opt.isSelected == true {
                    opt.mainQuestId = "67"
                    opt.ripa_id = "67"
                    selectedOption[2].append(opt)
                }
                else if id == "69" && opt.isSelected == true {
                    opt.mainQuestId = "69"
                    opt.ripa_id = "69"
                    selectedOption[2].append(opt)
                }
            }
            
            selectedOption[2] = newRipaViewModel.createPersonInformation(selectedOptionArray: selectedOption)
           
            personArray[personcount]["SelectedOption"] = selectedOption
        }
        
        if optionsArray![indexPath!].question_code_for_cascading_id == "C30"{
            lgbtBtnDisable = false
            let cascsdeQuestion = newRipaViewModel.getCascadeQuestionUsingQuestionCode(questionCode: "C28")
          //  cascsdeQuestion.questionoptions![1].isSelected = true
          //  cascsdeQuestion.questionoptions![0].isSelected = false
            cascsdeQuestion.order_number = orderId!
            for options in question.questionoptions!{
                if options.isSelected{
                    options.order_number = orderId!
                    options.mainQuestOrder = orderId!
                    if options.option_value.contains("Transgender") && options.isSelected{
                     //   cascsdeQuestion.questionoptions![0].isSelected = true
                      //  cascsdeQuestion.questionoptions![1].isSelected = false
                        lgbtBtnDisable = true
                    }
                    optionsArray![indexPath!].isSelected = true
                }
            }
        }
        else{
            optionsArray![indexPath!].isSelected = true
        }
        checkMandatory()
        tableView.reloadData()
    }
    
    func selectedOptionFromConsentPopup(consentQuestion: QuestionResult1){
        questionArray![questNumber!] = consentQuestion
        optionsArray = consentQuestion.questionoptions
        setOptionOrder()
        checkBasisRequired(checkBasis: false)
        newRipaViewModel.checkConsent()
        checkMandatorySelection()
        if questionArray![questNumber!].question_code == "T7"{
            let index = optionsArray!.firstIndex(where: {
                $0.option_value == "None"
            })
            optionsArray![index!].isSelected = false
        }
        
        tableView.reloadData()
        DispatchQueue.background(delay: 0.1, completion:{
            self.tableView.setContentOffset(.zero, animated: true)
        })
        
        let question = newRipaViewModel.getQuestionUsingQuestionCode(question_code: 17)
        if question.is_required == "0" {
            print("Not Required")
            question.questionoptions?.forEach({
                $0.isSelected = false
            })
        }
        
    }
    
    
    @objc func locationSwitch(_ sender : UISwitch!){
        
        let id = optionsArray![sender.tag].cascade_ripa_id
        print(sender.tag)
        let question = newRipaViewModel.getCascadeQuestionUsingId(questionID: Int(id)!)
        // cascade
        if question.questionoptions?.count ?? 0 > 1 {
            question.questionoptions?[0].isSelected = false
            question.questionoptions?[1].isSelected = true
        }
        
        question.order_number = orderId!
        for opt in question.questionoptions!{
            opt.mainQuestOrder =  orderId!
            opt.order_number = orderId!
            
        }
        
        if questionArray![questNumber!].question_code == "5" {
             if cityID.count == 0{
                 DispatchQueue.main.async {
                    AppUtility.showAlertWithProperty("", messageString: "Please select another city.")
                }
            }
            else 
            if sender.isOn{
                if question.questionoptions?.count ?? 0 > 0 {
                    is_k12 = true
                    question.questionoptions![0].isSelected = true
                  //  question.questionoptions?[1].isSelected = false
                    openList(index:5)
                    optionsArray![2].isSelected = true
                }
                else  if question.questionoptions?.count == 0 {
                    question.questionoptions = self.createSchoolOption()
                }
                else {
                    AppUtility.showAlertWithProperty("", messageString: "Please select another city.")
                }
            }
            else{
                AppConstants.schoolName = ""
                AppConstants.isSchoolSelected = ""
                is_k12 = false
                AppConstants.isStudent = "0"
                if question.questionoptions?.count ?? 0 > 0 {
                    question.questionoptions![0].isSelected = false
                }
                optionsArray![2].isSelected = false
                resetIsK12Options()
            }
        }
        else if questionArray![questNumber!].question_code == "T5" {
             let obj = newRipaViewModel.setStopInformationOption(questId: id)
            if id == "35" && ((question.questionoptions?.contains(where: {$0.mainQuestId != "35"})) != nil) {
                question.questionoptions = obj
            }
            else if id == "79" && ((question.questionoptions?.contains(where: {$0.mainQuestId != "79"})) != nil) {
                question.questionoptions = obj
            }
            else if ((question.questionoptions?.contains(where: {$0.mainQuestId != "101"})) != nil) {
                question.questionoptions = obj
            }
            
             if sender.isOn{
                 question.questionoptions![0].isSelected = true
                 question.questionoptions![1].isSelected = false
                 optionsArray![sender.tag].isSelected = true
             }
             else{
                 question.questionoptions![0].isSelected = false
                 question.questionoptions![1].isSelected = true
                 optionsArray![sender.tag].isSelected = false
             }
            
            if ((viewType != "StartNewRipa" && AppConstants.status != "LastRipa" && AppConstants.status != "Template" && saveRipaStatus != "Created") || AppConstants.isTemplate == "temp") {
                var personDict = personArray[personcount]
                var selectedOption = personDict["SelectedOption"] as! [[Questionoptions1]]
                if let ind = selectedOption[1].firstIndex(where: {$0.mainQuestId == id}) {
                    selectedOption[1].remove(at: ind)
                    if ind < selectedOption[1].count {
                        if  sender.isOn{
                            selectedOption[1].insert(question.questionoptions![0], at: ind)
                        }
                        else {
                            selectedOption[1].insert(question.questionoptions![1], at: ind)
                        }
                    }
                    else {
                        if  sender.isOn{
                            selectedOption[1].append(question.questionoptions![0])
                        }
                        else {
                            selectedOption[1].insert(question.questionoptions![1], at: ind)
                        }
                    }
                }
                personDict["SelectedOption"] = selectedOption
                personArray[personcount] = personDict
            }
            
         }
       else if questionArray![questNumber!].question_code == "T6" {
            if sender.isOn{
                question.questionoptions![0].isSelected = true
                question.questionoptions![1].isSelected = false
                optionsArray![sender.tag].isSelected = true
            }
            else{
                question.questionoptions![0].isSelected = false
                question.questionoptions![1].isSelected = true
                optionsArray![sender.tag].isSelected = false
            }
        }
        else {
            if sender.isOn{
                question.questionoptions![0].isSelected = true
                question.questionoptions![1].isSelected = false
                openList(index:5)
                optionsArray![4].isSelected = true
            }
            else{
                AppConstants.schoolName = ""
                AppConstants.isSchoolSelected = ""
                is_k12 = false
                AppConstants.isStudent = "0"
                optionsArray![4].isSelected = false
                resetIsK12Options()
            }
        }
        
        
        if questionArray![questNumber!].question_code == "T6" {
            if self.checkForTypeOfVehicleStop() && optionsArray![sender.tag].question_code_for_cascading_id != "C42" {
                if optionsArray![sender.tag].question_code_for_cascading_id == "C45" {
                    let indexa = optionsArray?.firstIndex{$0.question_code_for_cascading_id == "C45"}
                    let indexb = optionsArray?.firstIndex{$0.question_code_for_cascading_id == "C46"}
                  //  self.optionsArray![indexa!].isSelected = true
                    self.optionsArray![indexb!].isSelected = false
                }
                else{
                    let indexb = optionsArray?.firstIndex{$0.question_code_for_cascading_id == "C46"}
                    self.optionsArray![indexb!].isSelected = false
                    AppUtility.showAlertWithProperty("", messageString: "Please select the Pedestrian Stop in Type of stop.")
                }
            }
            else if self.checkForTypeOfStopPedestrain() && optionsArray![sender.tag].question_code_for_cascading_id != "C42" {
                if optionsArray![sender.tag].question_code_for_cascading_id == "C46" {
                    let indexa = optionsArray?.firstIndex{$0.question_code_for_cascading_id == "C46"}
                    let indexb = optionsArray?.firstIndex{$0.question_code_for_cascading_id == "C45"}
                 //   self.optionsArray![indexa!].isSelected = true
                    self.optionsArray![indexb!].isSelected = false
                }
                else {
                    let indexb = optionsArray?.firstIndex{$0.question_code_for_cascading_id == "C45"}
                    self.optionsArray![indexb!].isSelected = false
                    AppUtility.showAlertWithProperty("", messageString: "Please select the Vehicular Stop in Type of stop.")
                   
                }
            }
            else if !self.checkForTypeOfStopPedestrain() && !self.checkForTypeOfVehicleStop() && optionsArray![sender.tag].question_code_for_cascading_id != "C42" {
                AppUtility.showAlertWithProperty("", messageString: "Please select the Vehicular Stop in Type of stop.")
                let indexa = optionsArray?.firstIndex{$0.question_code_for_cascading_id == "C46"}
                let indexb = optionsArray?.firstIndex{$0.question_code_for_cascading_id == "C45"}
                self.optionsArray![indexa!].isSelected = false
                self.optionsArray![indexb!].isSelected = false
            }
        }
        
        
        checkMandatory()
        checkMandatorySelection()
        tableView.reloadData()
    }
    
    func createSchoolOption () -> [Questionoptions1]{
        var questionoptions = [Questionoptions1]()
        let geographicObj1 = Questionoptions1(mainQuestId: "27", mainQuestOrder: "1", option_id: "114", ripa_id: "27", custid: "1", option_value: "Yes", cascade_ripa_id: "52", isK_12School: "0", isHideQuesText: "", order_number: "1", createdBy: "", createdOn: "", updatedBy: "", updatedOn: "", isSelected: false, isAddtion: "", isDescription_Required: "No", inputTypeCode: "AN", questionTypeCode: "SC", tag: "", physical_attribute: "", default_value: "", optionDescription: "", question_code_for_cascading_id: "C24", isQuestionMandatory: "", isQuestionDescriptionReq: "No", main_question_id: "21", isExpanded: false, isNewAdded: false, mainId: "", questionoptions: [])
        questionoptions.append(geographicObj1)
        
        let geographicObj2 = Questionoptions1(mainQuestId: "27", mainQuestOrder: "1", option_id: "113", ripa_id: "27", custid: "1", option_value: "No", cascade_ripa_id: "52", isK_12School: "0", isHideQuesText: "", order_number: "1", createdBy: "", createdOn: "", updatedBy: "", updatedOn: "", isSelected: true, isAddtion: "", isDescription_Required: "No", inputTypeCode: "AN", questionTypeCode: "SC", tag: "", physical_attribute: "", default_value: "", optionDescription: "", question_code_for_cascading_id: "C24", isQuestionMandatory: "", isQuestionDescriptionReq: "No", main_question_id: "21", isExpanded: false, isNewAdded: false, mainId: "", questionoptions: [])
        questionoptions.append(geographicObj2)
        
        return questionoptions
    }
    
    
    func reload(section:Int,index:Int){
        let quest = getViolQuest(section:section)
        if  quest.questionoptions?.count ?? 0 > 0 {
            quest.questionoptions?.remove(at: index)
        }
        
        addToPreSelectedViolArr(indexPath:section)
        if indexPath != nil {
            optionsArray![indexPath!].isSelected = false
        }
        if quest.questionoptions!.count>0 && indexPath != nil{
            checkForSingleSelection(index : indexPath!)
        }
        
        if questionArray![questNumber!].question_code == "14"{
            if ((viewType != "StartNewRipa" && AppConstants.status != "LastRipa" && AppConstants.status != "Template" && saveRipaStatus != "Created") || AppConstants.isTemplate == "temp") && (questionArray![questNumber!].question_code == "14"){
                var personDict = personArray[personcount]
                var selectedOptArray = personDict["SelectedOption"] as! [[Questionoptions1]]
                if index + 2 < selectedOptArray[4].count {
                    selectedOptArray[4].remove(at: index + 2)
                }
                personDict["SelectedOption"] = selectedOptArray
                personArray[personcount] = personDict
            }
            selectedViolationArray2 = quest.questionoptions ?? []
        }
        
        if questionArray![questNumber!].question_code == "14" &&  optionsArray![section].physical_attribute == "1" && selectedViolationArray2.count == 0 && quest.questionoptions?.count == 0{
            self.isClearViolations = true
            self.violationArray?.forEach({$0.isSelected = false})
            DispatchQueue.main.async(execute: {
                let btn = UIButton()
                btn.tag = section
                self.hideSection(sender: btn)
            })
        }
        
        tableView.reloadData()
    }
    
    @objc func dltAllViol(sender:UIButton){
        if selectedVioArray.count > 0 {
            let quest = getViolQuest(section:sender.tag)
            for obj in selectedVioArray {
                for index in (0 ..< (quest.questionoptions?.count ?? 0)) {
                    if index < quest.questionoptions?.count ?? 0 , obj.offense_code == quest.questionoptions?[index].optionDescription , obj.isNewAdded == true{
                        quest.questionoptions?.remove(at: index)
                    }
                }
            }
           
            selectedVioArray.removeAll()
            addToPreSelectedViolArr(indexPath:sender.tag)
          //  optionsArray![indexPath!].isSelected = false
            if quest.questionoptions!.count>0{
                checkForSingleSelection(index : indexPath!)
            }
            if questionArray![questNumber!].question_code == "14" &&  optionsArray![sender.tag].physical_attribute == "1" {
                self.isClearViolations = true
                self.violationArray?.forEach({$0.isSelected = false})
                DispatchQueue.main.async(execute: {
                    let btn = UIButton()
                    btn.tag = sender.tag
                    self.hideSection(sender: btn)
                })
            }
        }
        else {
            let quest = getViolQuest(section:sender.tag)
            quest.questionoptions?.removeAll()
           
            addToPreSelectedViolArr(indexPath:sender.tag)
            
            optionsArray![sender.tag].isSelected = false
           
            if questionArray![questNumber!].question_code == "21"{
                selectedViolationArray2.removeAll()
                    for i in (0 ..< (optionsArray?.count ?? 0)) {
                        optionsArray![i].isSelected = false
                        optionsArray![i].isExpanded = false
                    }
            }
            checkForSingleSelection(index : sender.tag)
            if questionArray![questNumber!].question_code == "21"{
                    for i in (0 ..< (optionsArray?.count ?? 0)) {
                        optionsArray![i].isSelected = false
                        optionsArray![i].isExpanded = false
                    }
            }
            
            if ((viewType != "StartNewRipa" && AppConstants.status != "LastRipa" && AppConstants.status != "Template" && saveRipaStatus != "Created") || AppConstants.isTemplate == "temp") && (questionArray![questNumber!].question_code == "14"){
                var personDict = personArray[personcount]
                var selectedOptArray = personDict["SelectedOption"] as! [[Questionoptions1]]
                let obj = selectedOptArray[4].filter({$0.ripa_id != "20" && $0.ripa_id != "16" })
                selectedOptArray[4] = obj
                personDict["SelectedOption"] = selectedOptArray
                personArray[personcount] = personDict
               
//                optionsArray![sender.tag].isExpanded = !optionsArray![sender.tag].isExpanded
//                optionsArray![sender.tag].isSelected = !optionsArray![sender.tag].isSelected
              
            }
        }
       
        tableView.reloadData()
    }
    
    func getViolQuest(section:Int)-> QuestionResult1{
        var ripaId =  optionsArray![section].cascade_ripa_id
        if  ripaId.count == 0{
            ripaId = "50"
        }
        
        var quest2 : QuestionResult1?
        let questt = QuestionResult1(id: "", custid: "", question: "", question_info: "", question_key: "", question_code: "", questionTypeId: "", inputTypeId: "", is_add_value: "", internal: "", is_required: "", isAddtion: "", isCascade_Question: "", ripa_group_id: "", isDescription_Required: "", common_question: "", editable_question: "", visible_question: "", order_number: "", is_active: "", CreatedBy: "", CreatedOn: "", UpdatedBy: "", UpdatedOn: "", inputTypeCode: "", questionTypeCode: "", groupName: "", questionoptions: [])
        
        let quest = newRipaViewModel.getCascadeQuestionUsingId(questionID:Int(ripaId)!)
        if quest.questionoptions?.count ?? 0 > 0 {
            quest2 = newRipaViewModel.getCascadeQuestionUsingId(questionID:Int(quest.questionoptions?[0].cascade_ripa_id ?? "") ?? 0)
        }
        if questionArray![questNumber!].question_code == "14"{
            selectedViolationArray2.removeAll()
        }
        cascadeArray.removeAll()
        if quest2 == nil {
            return questt
        }
        return quest2!
    }
    
    
    func addToPreSelectedViolArr(indexPath:Int){
        if questionArray![questNumber!].question_code == "14" {
            let ViolationFor = optionsArray![indexPath].option_value
            let optionId = optionsArray![indexPath].option_id
            violationDict = ["ViolationFor":ViolationFor, "optionID": optionId ,"ViolationList": selectedViolationArray2]
        }
    }
    
    
    @objc func swapStreetAndIntersection(sender:UIButton){
        var streetAvailable = false
        var intersectionAvailable = false
        var tempstOption:Questionoptions1?
        var tempInterOption:Questionoptions1?
        
        
        var orignalIntersectionQuestion = newRipaViewModel.getCascadeQuestionUsingQuestionCode(questionCode: "C26").questionoptions
        var orignalStreetQuestion = newRipaViewModel.getCascadeQuestionUsingQuestionCode(questionCode: "C7").questionoptions
        
        
        if orignalStreetQuestion!.count > 0{
            if let streetOption = orignalStreetQuestion?[0].copy(){
                streetAvailable = true
                tempstOption = streetOption as? Questionoptions1
            }
        }
        
        if orignalIntersectionQuestion!.count > 0{
            if let intersectionOption = orignalIntersectionQuestion?[0].copy(){
                intersectionAvailable = true
                tempInterOption = intersectionOption as? Questionoptions1
            }
        }
        else if !(street.count > 0 && intersectionStreet.count>0){
            AppUtility.showAlertWithProperty("Alert", messageString: "Cross street not selected. Cross street must be selected for swapping.")
        }
       
        
        if street.count>0 && intersectionStreet.count>0 {
            let str =  intersectionStreet
            intersectionStreet = street
            street = str
        }
        
        // For Adding Intersection In Street
        
        if intersectionAvailable{
            if streetAvailable{
                orignalStreetQuestion![0].option_value = tempInterOption!.option_value
            }
            else{
                orignalStreetQuestion?.removeAll()
                let optn = newRipaViewModel.createObj(mainQuestId: questionId, ripaID: optionsArray![1].cascade_ripa_id, optionValue: tempInterOption?.option_value, physical_attribute: "", description: "", isSelected: true, mainQuestOrder: orderId!, isNewAdded: false, mainId: vioQuestionId)
                orignalStreetQuestion?.append(optn)
            }
        }
        
        
        // For Adding Street In Intersection
        
        if streetAvailable{
            if intersectionAvailable{
                orignalIntersectionQuestion![0].option_value = tempstOption!.option_value
            }
            else{
                orignalIntersectionQuestion?.removeAll()
                let optn = newRipaViewModel.createObj(mainQuestId: questionId, ripaID: optionsArray![3].cascade_ripa_id, optionValue: tempstOption?.option_value, physical_attribute: "", description: "", isSelected: true, mainQuestOrder: orderId!, isNewAdded: false, mainId: vioQuestionId)
                orignalIntersectionQuestion?.append(optn)
            }
        }
        
        tableView.reloadData()
    }
    
    func textFieldDidBeginEditing(textField: UITextField!) {
       print("start block")
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        checkMandatorySelection()
        
        if questionArray![questNumber!].question_code == "25"  {
            let question = newRipaViewModel.getCascadeQuestionUsingQuestionCode(questionCode:optionsArray![indexPath.row].question_code_for_cascading_id)
            question.order_number = orderId!
            
            let questionTypeCode = optionsArray![indexPath.row].questionTypeCode
            if questionTypeCode == "SL"{
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "SingleLineCell", for: indexPath as IndexPath) as! SingleLineCell
                cell.TxtField.delegate = self
                cell.TxtField.text = ""
                cell.clearTxtBtn.isHidden = true
                cell.imgView.isHidden = false
                cell.TxtField.placeholder = "Enter Perceived Age of Person?"
                cell.TxtField.tag = indexPath.row
                cell.TxtField.isUserInteractionEnabled = true
                cell.TxtField.keyboardType = UIKeyboardType.numberPad
                
                if question.questionoptions!.count > 0{
                    question.questionoptions![0].main_question_id = self.questionId
                    optionsArray![indexPath.row].isSelected = true
                    print(self.age)
                     cell.TxtField.text = question.questionoptions?.first?.option_value
                    var ageInt : Int = 0
                    
                    if let ageF = question.questionoptions?.first?.option_value,ageF != "None",ageF != "" {
                        ageInt = Int(ageF)!
                    }
                    
                    
                    if ageInt > self.age{
                        self.age = ageInt
                    }
                    if viewType == "UseLastRipa" || viewType == "Template"{
                        if self.age == 0 {
                            cell.TxtField.text = ""
                        }
                        else {
                            cell.TxtField.text = "\( self.age)"
                        }
                    }
                    else if self.age > 0 {
                        cell.TxtField.text = "\( self.age)"
                    }
                    else if let myNumber = NumberFormatter().number(from: cell.TxtField.text!) {
                        self.age = myNumber.intValue
                      }
                    else {
                        self.age = 0
                    }
                   
                    if cell.TxtField.text == "0" {
                        cell.TxtField.text = ""
                    }
                    cell.clearTxtBtn.isHidden = false
                    cell.clearTxtBtn.addTarget(self, action: #selector(clearOption(sender:)), for: .touchUpInside)
                    cell.clearTxtBtn.tag = indexPath.row
                }
                else if isKeyboard{
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        cell.TxtField.becomeFirstResponder()
                    }
                    optionsArray![indexPath.row].isSelected = false
                }
                answer = cell.TxtField.text!
                checkMandatory()
                return cell
            }
            
            
            if questionTypeCode == "SC" || questionTypeCode == "MC"{
                if optionsArray![indexPath.row].inputTypeCode == "A "{
                    let  cell = tableView.dequeueReusableCell(withIdentifier: "PerceivedGenderCell", for: indexPath as IndexPath) as! PerceivedGenderCell
                    //  cell.optionTxt.text = optionsArray![indexPath.row].option_value
                    cell.btn.tag = indexPath.row
                    cell.btn.addTarget(self, action: #selector(self.openOptionsList(sender:)), for: .touchUpInside)
                    optionsArray![indexPath.row].isSelected = false
                    
                    let paragraphStyle = NSMutableParagraphStyle()
                    paragraphStyle.lineSpacing = 7
                    let yourAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "BlackWhite") ,NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 18)]
                    let yourAttributes1 = [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.2343381047, green: 0.5642583966, blue: 0.8001195788, alpha: 1) ,NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 17)] as [NSAttributedString.Key : Any]
                    
                    if questionArray![questNumber!].question_code == "25" && indexPath.row == 2 {
                        optionsArray![indexPath.row].option_value = "Perceived Gender"
                    }
                    
                    let questionString = NSMutableAttributedString(string: optionsArray![indexPath.row].option_value ,attributes: yourAttributes as [NSAttributedString.Key : Any])
                    
                    cell.optionTxt.attributedText = questionString
                    print(AppConstants.status)
                    
                     var optionArrObj = [Questionoptions1]()
                    if questionArray![questNumber!].question_code == "25" && optionsArray![indexPath.row].mainQuestId == "61" && ((AppConstants.status != "LastRipa" && AppConstants.status != "Template" && saveRipaStatus != "Created" && viewType != "StartNewRipa") || AppConstants.isTemplate == "temp"), personcount < personArray.count{
                        
                        let quest = newRipaViewModel.getCascadeQuestionUsingId(questionID: Int(optionsArray![indexPath.row].cascade_ripa_id)!)
                        
                        for option in quest.questionoptions!{
                            let personDict = personArray[personcount]
                            let selectedOption = personDict["SelectedOption"] as! [[Questionoptions1]]
                            if selectedOption.count > 3 && indexPath.row == 2 && selectedOption[2].count > 5{
                                let personOpt = selectedOption[2][5]
                                if option.option_value == personOpt.option_value && option.main_question_id == personOpt.main_question_id {
                                    option.isSelected = true
                                    optionArrObj.append(option)
                                }
                            }
                            else if selectedOption.count > 5 && selectedOption[2].count > 4 && indexPath.row == 3{
                                let obj = selectedOption[2].filter({$0.ripa_id == "66"})
                                if obj.count > 0 && optionArrObj.count == 0{
                                    obj[0].isSelected = true
                                    optionArrObj.append(obj[0])
                                }
                            }
                            else if selectedOption.count > 7 && indexPath.row == 4{
                                let personOpt = selectedOption[2]
                                for dict in personOpt{
                                    if dict.ripa_id == "67" {
                                        if option.physical_attribute == dict.physical_attribute && option.main_question_id == dict.main_question_id {
                                            option.isSelected = true
                                            optionArrObj.append(option)
                                        }
                                    }
                                }
                            }
                            else if selectedOption.count > 10 && indexPath.row == 5{
                                let personOpt = selectedOption[2]
                                for dict in personOpt{
                                    if dict.ripa_id == "69" {
                                        if option.physical_attribute == dict.physical_attribute && option.main_question_id == dict.main_question_id {
                                            option.isSelected = true
                                            let exist = optionArrObj.contains(where: {$0.option_value == option.option_value})
                                            if exist == false {
                                                optionArrObj.append(option)
                                            }
                                        }
                                    }
                                }
                            }
                         }
                          
                        if indexPath.row == 2,optionArrObj.count == 0 {
                            optionArrObj = quest.questionoptions!.filter({$0.isSelected == true})
                        }
                         
                         
                            var myAttrString = NSMutableAttributedString()
                            
                            if optionArrObj.count > 0 {
                                var makeStr : String = ""
                                for objjj in optionArrObj{
                                    let vStr = objjj.option_value
                                    if makeStr.count > 0 {
                                        makeStr = "\(makeStr) , \(vStr) "
                                    }
                                    else {
                                        makeStr = "\(vStr)"
                                    }
                                }
                                myAttrString = NSMutableAttributedString(string: "\n\(makeStr)", attributes: yourAttributes1)
                            }
                            
                            questionString.append(myAttrString)
                            questionString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, questionString.length))
                            cell.optionTxt.attributedText = questionString
                            
                            //cell.optionTxt.text = cell.optionTxt.text! + myAttrString.string
                            optionsArray![indexPath.row].isSelected = true
                    }
                    else {
                        for option in question.questionoptions!{
                            option.mainQuestOrder = orderId!
                            option.order_number = orderId!
                            if option.isSelected{
                                
                                if option.option_value.contains("Transgender") && question.question_code == "C30"{
                                    lgbtBtnDisable = true
                                }
                                checkGenderSelection = false
                                if option.option_value.contains("Male") || option.option_value.contains("Female") || option.option_value.contains("nonconforming"){
                                    checkGenderSelection = true
                                }
                                
                                let myAttrString = NSMutableAttributedString(string: "\n\(option.option_value)", attributes: yourAttributes1)
                              
                                questionString.append(myAttrString)
                                questionString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, questionString.length))
                                cell.optionTxt.attributedText = questionString
                                
                                //cell.optionTxt.text = cell.optionTxt.text! + myAttrString.string
                                optionsArray![indexPath.row].isSelected = true
                            }
                        }
                    }
                   
                    checkMandatory()
                    return cell
                }
                
                let  cell = tableView.dequeueReusableCell(withIdentifier: "togglCell", for: indexPath as IndexPath) as! togglCell
                cell.textLbl.text =  optionsArray![indexPath.row].option_value
                cell.toggleBtn.isOn = false
                cell.toggleBtn.removeTarget(nil, action: nil, for: .allEvents)
                cell.toggleBtn.tag = indexPath.row
                cell.toggleBtn.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)
                cell.toggleBtn.isUserInteractionEnabled = true
                cell.textLbl.textColor = UIColor(named: "BlackWhite")
                cell.reqImg.image = #imageLiteral(resourceName: "optional")
                cell.requiredView.isHidden = false
                
                if question.is_required == "1"{
                    cell.reqImg.image = #imageLiteral(resourceName: "required_icon")
                }
                if AppConstants.isSchoolSelected == "" && optionsArray![indexPath.row].question_code_for_cascading_id == "C27"{
                    cell.toggleBtn.isUserInteractionEnabled = false
                    cell.textLbl.textColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
                    question.questionoptions![0].isSelected = false
                    question.questionoptions![1].isSelected = true
                    optionsArray![indexPath.row].isSelected = true
                }
                else if AppConstants.isSchoolSelected == "Yes" && optionsArray![indexPath.row].question_code_for_cascading_id == "C27"{
                    optionsArray![indexPath.row].isSelected = true
                }
                else if optionsArray![indexPath.row].question_code_for_cascading_id == "C28"{
                    if lgbtBtnDisable == true{
                        cell.textLbl.textColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
                        cell.toggleBtn.isUserInteractionEnabled = false
                    }
                    if checkGenderSelection == true {
                        cell.textLbl.textColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
                        cell.toggleBtn.isUserInteractionEnabled = false
                    }
                    //question.questionoptions![0].isSelected = true
                }
                question.questionoptions![0].mainQuestOrder = orderId!
                question.questionoptions![0].order_number = orderId!
                question.questionoptions![1].mainQuestOrder = orderId!
                question.questionoptions![1].order_number = orderId!
              
                if question.questionoptions![0].isSelected == true{
                    optionsArray![indexPath.row].isSelected = true
                    cell.toggleBtn.isOn = true
                }
                else{
                    optionsArray![indexPath.row].isSelected = true
                    question.questionoptions![1].isSelected = true
                    
                    if AppConstants.isSchoolSelected == "" && optionsArray![indexPath.row].question_code_for_cascading_id == "C27"{
                        optionsArray![indexPath.row].isSelected = false
                        question.questionoptions![1].isSelected = false
                    }
                    
                    cell.toggleBtn.isOn = false
                }
                
             
                if questionArray![questNumber!].question_code == "25" && viewType != "StartNewRipa" && optionsArray![indexPath.row].mainQuestId == "61",personcount < personArray.count{
                    let personDict = personArray[personcount]
                    cell.toggleBtn.isOn = false
                    let selectedOption = personDict["SelectedOption"] as! [[Questionoptions1]]
                    let personOpt = selectedOption[2]
                    if indexPath.row == 0 {
                        let obj = personOpt.filter({
                            $0.cascade_ripa_id == "62" && $0.isSelected == true
                        })
                        if obj.count > 0 {
                            optionsArray![indexPath.row].isSelected = true
                            cell.toggleBtn.isOn = true
                        }
                        else {
                            cell.toggleBtn.isOn = false
                        }
                        let objj = personOpt.filter({
                            ($0.ripa_id == "C27" || $0.ripa_id == "62") && $0.option_value == "No"
                        })
                        if objj.count > 0 {
                            optionsArray![indexPath.row].isSelected = false
                            cell.toggleBtn.isOn = false
                        }
                    }
                    else {
                        let obj = personOpt.filter({
                            $0.cascade_ripa_id == "68" && $0.isSelected == true
                        })
                        if obj.count > 0 {
                            optionsArray![indexPath.row].isSelected = true
                            cell.toggleBtn.isOn = true
                        }
                        else {
                            cell.toggleBtn.isOn = false
                        }
                        let objj = personOpt.filter({
                            $0.ripa_id == "68" && $0.option_value == "No"
                        })
                        if objj.count > 0 {
                            optionsArray![indexPath.row].isSelected = false
                            cell.toggleBtn.isOn = false
                        }
                    }
                }
                
                checkMandatory()
                return cell
            }
        }
        if indexPath.section == 3,questionArray![questNumber!].question_code == "5"{
            let cell = tableView.dequeueReusableCell(withIdentifier: "clcell", for: indexPath as IndexPath) as! CLCell
            cell.label.text = ""
            inputTypeCode = self.optionsArray![indexPath.section].inputTypeCode
            let optionValue = self.optionsArray![indexPath.section].option_value
            let cascadeId = Int(self.optionsArray![indexPath.section].cascade_ripa_id)
            let cascadeQuest = newRipaViewModel.getCascadeQuestionUsingId(questionID: cascadeId!)
            optionsArray![indexPath.section].isSelected = false
            cell.bottomView.isHidden = true
            cell.closeView.isHidden = true
            cell.citybtn.isUserInteractionEnabled = true
           
            cell.label.text = AppConstants.schoolName
            if optionValue == "Name of school"{
                cell.label.placeholder = "Select name of school"
            }
            
            if cascadeQuest.questionoptions!.count>0{
                if optionValue == "Name of school"{
                    cell.label.text = AppConstants.schoolName
                   // AppConstants.schoolName = cascadeQuest.questionoptions![0].option_value
                }
            }
            else  if questionArray![questNumber!].question_code == "5" && viewType != "StartNewRipa" && AppConstants.schoolName != "Name of school" && AppConstants.schoolName.count > 0 {
                cell.label.text = AppConstants.schoolName
            }
            else  if questionArray![questNumber!].question_code == "5" && viewType != "StartNewRipa" && personArray.count > 0 {
                let personDict = personArray[personcount]
                let selectedOption = personDict["SelectedOption"] as! [[Questionoptions1]]
                let obj = selectedOption[0].filter({
                    $0.ripa_id == "21" && $0.cascade_ripa_id == "27"
                })
                
                if obj.count > 0 , obj[0].questionoptions?.count ?? 0 > 0 {
                    cell.label.text = obj[0].questionoptions?[0].option_value
                }
            }
            else  if questionArray![questNumber!].question_code == "25" && viewType != "StartNewRipa" {
                let personDict = personArray[personcount]
                let selectedOption = personDict["SelectedOption"] as! [[Questionoptions1]]
                let obj = selectedOption[0].filter({
                    $0.ripa_id == "21" && $0.cascade_ripa_id == "27"
                })
                
                if obj.count > 0 , obj[0].questionoptions?.count ?? 0 > 0 {
                    cell.label.text = obj[0].questionoptions?[0].option_value
                }
            }
            
            cell.citybtn.tag = 5
            cell.citybtn.addTarget(self, action: #selector(openListViewController(sender:)), for: .touchUpInside)
            
            disableNextButton(View: nextView)
            if self.durationTxtField.text?.count ?? 0 > 0 && !previewViewModel.checkLocationIsEmpty(){
                enableNextButton(View: nextView)
            }
            
            return cell
        }
        else if questionArray![questNumber!].question_code == "5" && indexPath.section == 1 && locTypeIndex == 1 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "clcell", for: indexPath as IndexPath) as! CLCell
                   
                    locTypeIndex = 1
                    cell.label.text = "Select Street"
                    cell.bottomView.isHidden = true
                    cell.bottomLbl.isHidden = true
                    cell.label.textColor = .lightGray
                    if AppConstants.street.count > 0 {
                      cell.label.textColor = .black
                      cell.label.text = AppConstants.street
                    }
                    cell.citybtn.isUserInteractionEnabled = true
                    cell.citybtn.addTarget(self, action: #selector(openListViewController(sender:)), for: .touchUpInside)
                    cell.citybtn.tag = 11
                
                cell.downImgView.isHidden = false
                cell.closeBtn.isHidden = true
                cell.closeView.isHidden = true
               
                disableNextButton(View: nextView)
                if self.durationTxtField.text?.count ?? 0 > 0 && !previewViewModel.checkLocationIsEmpty(){
                    enableNextButton(View: nextView)
                }
                if self.traitCollection.userInterfaceStyle == .dark {
                    cell.label.textColor = .white
                 }
                
                 return cell
            }
            else if indexPath.row == 1 {
                let  cell = tableView.dequeueReusableCell(withIdentifier: "SingleLineCell", for: indexPath as IndexPath) as! SingleLineCell
                cell.TxtField.keyboardType = UIKeyboardType.numberPad
                cell.TxtField.delegate = self
                cell.TxtField.text = ""
                cell.TxtField.placeholder = "Enter Block"
                cell.clearTxtBtn.isHidden = true
                cell.imgView.isHidden = true
                cell.TxtField.isUserInteractionEnabled = true
                if AppConstants.block.count > 0 {
                  cell.TxtField.text = AppConstants.block
                }
                cell.TxtField.tag = 99
                locTypeIndex = 1
                cell.clearTxtBtn.isHidden = false
                cell.clearTxtBtn.addTarget(self, action: #selector(clearOption(sender:)), for: .touchUpInside)
                cell.clearTxtBtn.tag = 99
                
                disableNextButton(View: nextView)
                if self.durationTxtField.text?.count ?? 0 > 0 && !previewViewModel.checkLocationIsEmpty(){
                    enableNextButton(View: nextView)
                }
                
                return cell
            }
        }
        else if questionArray![questNumber!].question_code == "5" && indexPath.section == 1 && locTypeIndex == 6 {
            let  cell = tableView.dequeueReusableCell(withIdentifier: "clcell", for: indexPath as IndexPath) as! CLCell
            cell.bottomView.isHidden = true
            cell.bottomLbl.isHidden = true
           
            cell.label.text = "Location"
            cell.label.textColor = .lightGray
            if let latString = UserDefaults.standard.string(forKey: "latitude"),let longString = UserDefaults.standard.string(forKey: "longitude") {
                
                cell.label.textColor = .black
                cell.label.text = String(format: "Latitude: %@, Longitude: %@", AppConstants.lati ,AppConstants.longi)
            }
            
            locTypeIndex = 6
            
            cell.downImgView.isHidden = true
            cell.citybtn.isUserInteractionEnabled = true
            if AppConstants.ripaGPS == "Y"{
                cell.closeView.isHidden = false
                cell.closeBtn.isHidden = false
            }
            cell.closeBtn.setImage(UIImage(named:"target_location.png")!, for: .normal)
            cell.closeBtn.tintColor = #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)
            
            if checkEditable == true && questionArray![questNumber!].editable_question != "1"{
                print("Cannot Edit")
                cell.closeBtn.removeTarget(nil, action: nil, for: .allEvents)
            }
            else{
              //  cell.closeBtn.removeTarget(nil, action: nil, for: .allEvents)
                cell.closeBtn.addTarget(self, action: #selector(getCityFromGPS(sender:)), for: .touchUpInside)
            }
           
            cell.label.isUserInteractionEnabled = false
            cell.closeBtn.tag = indexPath.section
            cell.closeBtn.isHidden = true
            cell.citybtn.isHidden = true
            cell.closeView.isHidden = true
            disableNextButton(View: nextView)
            if self.durationTxtField.text?.count ?? 0 > 0 && !previewViewModel.checkLocationIsEmpty(){
                enableNextButton(View: nextView)
            }
            
            if self.traitCollection.userInterfaceStyle == .dark {
                cell.label.textColor = .white
             }
            
            return cell
        }
        else if questionArray![questNumber!].question_code == "5" && indexPath.section == 1 && locTypeIndex == 2 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "clcell", for: indexPath as IndexPath) as! CLCell
                cell.label.text = "Cross street 1"
                cell.bottomView.isHidden = true
                cell.bottomLbl.isHidden = true
                if AppConstants.firstIntersection.count > 0 {
                  cell.label.text = AppConstants.firstIntersection
                }
                cell.citybtn.isUserInteractionEnabled = true
                cell.citybtn.addTarget(self, action: #selector(openListViewController(sender:)), for: .touchUpInside)
                cell.citybtn.tag = 12
                locTypeIndex = 2
            
                cell.closeView.isHidden = true
                cell.closeBtn.isHidden = true
                
                disableNextButton(View: nextView)
                if self.durationTxtField.text?.count ?? 0 > 0 && !previewViewModel.checkLocationIsEmpty(){
                    enableNextButton(View: nextView)
                }
            
             return cell
                
            }
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "clcell", for: indexPath as IndexPath) as! CLCell
                
                  cell.label.text = "Cross street 2"
                  cell.bottomView.isHidden = true
                  cell.bottomLbl.isHidden = true
                     
                      if AppConstants.secondIntersection.count > 0 {
                          cell.label.text = AppConstants.secondIntersection
                      }
                
                    locTypeIndex = 2
                 cell.citybtn.isUserInteractionEnabled = true
                  cell.citybtn.addTarget(self, action: #selector(openListViewController(sender:)), for: .touchUpInside)
                  cell.citybtn.tag = 13
                
                cell.closeView.isHidden = true
                cell.closeBtn.isHidden = true
               
                disableNextButton(View: nextView)
                if self.durationTxtField.text?.count ?? 0 > 0 && !previewViewModel.checkLocationIsEmpty(){
                    enableNextButton(View: nextView)
                }
                
                 return cell
            }
        }
        else if questionArray![questNumber!].question_code == "5" && indexPath.section == 1 && locTypeIndex == 3 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "clcell", for: indexPath as IndexPath) as! CLCell
                cell.label.text = "Highway"
                cell.bottomView.isHidden = true
                cell.bottomLbl.isHidden = true
                  if AppConstants.highway.count > 0 {
                    cell.label.text = AppConstants.highway
                  }
                  cell.citybtn.isUserInteractionEnabled = true
                  cell.citybtn.addTarget(self, action: #selector(openListViewController(sender:)), for: .touchUpInside)
                  cell.citybtn.tag = 14
                
                cell.closeView.isHidden = true
                cell.closeBtn.isHidden = true
                
                locTypeIndex = 3
                
                disableNextButton(View: nextView)
                if self.durationTxtField.text?.count ?? 0 > 0 && !previewViewModel.checkLocationIsEmpty(){
                    enableNextButton(View: nextView)
                }
                
                 return cell
            }
            else {
                let  cell = tableView.dequeueReusableCell(withIdentifier: "SingleLineCell", for: indexPath as IndexPath) as! SingleLineCell
                cell.TxtField.keyboardType = UIKeyboardType.default
                cell.TxtField.delegate = self
                cell.TxtField.text = ""
                cell.TxtField.placeholder = "Closest Highway Exit"
                cell.clearTxtBtn.isHidden = true
                cell.imgView.isHidden = true
                cell.TxtField.isUserInteractionEnabled = true
                if AppConstants.closestHighway.count > 0 {
                    cell.TxtField.text = AppConstants.closestHighway
                }
                cell.TxtField.tag = 999
                
               
                locTypeIndex = 3
                cell.clearTxtBtn.isHidden = false
                cell.clearTxtBtn.addTarget(self, action: #selector(clearOption(sender:)), for: .touchUpInside)
                cell.clearTxtBtn.tag = 999
                
                disableNextButton(View: nextView)
                if self.durationTxtField.text?.count ?? 0 > 0 && !previewViewModel.checkLocationIsEmpty(){
                    enableNextButton(View: nextView)
                }
                
                return cell
            }
            
        }
       else if indexPath.section == 1,questionArray![questNumber!].question_code == "5" && questionType == "MC" && (optionsArray![indexPath.section].inputTypeCode == "AN" || optionsArray![indexPath.section].inputTypeCode == "A" || optionsArray![indexPath.section].inputTypeCode == "ML"){
            let cell = tableView.dequeueReusableCell(withIdentifier: "SingleChoiceCell", for: indexPath as IndexPath) as! SingleChoiceCell
            cell.optionView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            cell.optionTxt.text = (self.optionsArray![indexPath.section].questionoptions![indexPath.row] ).option_value
            print(locTypeIndex)
            if  (optionsArray![indexPath.section].questionoptions![indexPath.row] ).isSelected{
                cell.optionView.backgroundColor = UIColor(named: "SelectionBlue")
            }
            if locTypeIndex == 1 {
                cell.optionView.backgroundColor = UIColor(named: "SelectionBlue")
            }
           locTypeIndex = 5
           disableNextButton(View: nextView)
           if self.durationTxtField.text?.count ?? 0 > 0 && !previewViewModel.checkLocationIsEmpty(){
               enableNextButton(View: nextView)
           }
            
            return cell
        }
      else  if questionArray![questNumber!].question_code == "T5" && optionsArray![indexPath.section].question_code_for_cascading_id == "C43" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RadioTextCell", for: indexPath as IndexPath) as! RadioTextCell
           // cell.optionView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            cell.titleLbl.text = (self.optionsArray![indexPath.section].questionoptions![indexPath.row] ).option_value
            cell.radioImage.image = UIImage(named: "Unselect")
             cell.titleLbl.font = .systemFont(ofSize: 18)
            if  (optionsArray![indexPath.section].questionoptions![indexPath.row] ).isSelected{
               // cell.optionView.backgroundColor = UIColor(named: "SelectionBlue")
                cell.radioImage.image = UIImage(named: "Select")
                cell.titleLbl.font = .boldSystemFont(ofSize: 18)
            }
            
            return cell
        }
       else if questionArray![questNumber!].question_code == "T5"{
            let question = newRipaViewModel.getCascadeQuestionUsingQuestionCode(questionCode:optionsArray![indexPath.section].question_code_for_cascading_id)
                question.order_number = orderId!
            
            let questionTypeCode = optionsArray![indexPath.section].questionTypeCode
            if questionTypeCode == "SC" && optionsArray![indexPath.section].inputTypeCode == "AN"{
                let cell = tableView.dequeueReusableCell(withIdentifier: "togglCell", for: indexPath as IndexPath) as! togglCell
                
                cell.requiredView.isHidden = true
                
                cell.toggleBtn.isOn = false
                cell.textLbl.text = optionsArray![indexPath.section].option_value
                cell.textLbl.textColor =  UIColor(named: "BlackWhite")
                cell.toggleBtn.tag = indexPath.section
                cell.reqImg.image = #imageLiteral(resourceName: "optional")
                cell.requiredView.isHidden = false

                if question.is_required == "1"{
                    cell.reqImg.image = #imageLiteral(resourceName: "required_icon")
                }
                
                cell.toggleBtn.addTarget(self, action: #selector(self.locationSwitch(_:)), for: .valueChanged)
                if optionsArray![indexPath.section].isSelected == true {
                    cell.toggleBtn.isOn = true
                }

                return cell
            }
        }
       else if questionArray![questNumber!].question_code == "T6"{
            let question = newRipaViewModel.getCascadeQuestionUsingQuestionCode(questionCode:optionsArray![indexPath.section].question_code_for_cascading_id)
                question.order_number = orderId!
            
            let questionTypeCode = optionsArray![indexPath.section].questionTypeCode
            if questionTypeCode == "SC" && optionsArray![indexPath.section].inputTypeCode == "AN"{
                let cell = tableView.dequeueReusableCell(withIdentifier: "togglCell", for: indexPath as IndexPath) as! togglCell
                
                cell.requiredView.isHidden = true
                
                cell.toggleBtn.isOn = false
                cell.textLbl.text = optionsArray![indexPath.section].option_value
               
                cell.textLbl.textColor =  UIColor(named: "BlackWhite")
                cell.toggleBtn.tag = indexPath.section
                cell.reqImg.image = #imageLiteral(resourceName: "optional")
                cell.requiredView.isHidden = false

                if question.is_required == "1"{
                    cell.reqImg.image = #imageLiteral(resourceName: "required_icon")
                }
                
                cell.toggleBtn.isUserInteractionEnabled = true
            
                cell.toggleBtn.addTarget(self, action: #selector(self.locationSwitch(_:)), for: .valueChanged)
                if optionsArray![indexPath.section].isSelected == true {
                    cell.toggleBtn.isOn = true
                }

                return cell
            }
        }
        
        if questionType == "SL"{
            let  cell = tableView.dequeueReusableCell(withIdentifier: "SingleLineCell", for: indexPath as IndexPath) as! SingleLineCell
            inputTypeCode = questionArray![questNumber!].inputTypeCode
            if inputTypeCode == "N "{
                cell.TxtField.keyboardType = UIKeyboardType.numberPad
            }
            else{
                cell.TxtField.keyboardType = UIKeyboardType.default
            }
            
            cell.clearTxtBtn.isHidden = true
            //cell.cellView.backgroundColor = #colorLiteral(red: 0.9215072393, green: 0.9216086268, blue: 0.9296415448, alpha: 1)
            cell.TxtField.delegate = self
            cell.TxtField.text = ""
            cell.TxtField.placeholder = questionArray![questNumber!].question
            
            if self.optionsArray!.count > 0{
                cell.TxtField.text! = self.optionsArray![indexPath.row].option_value
                
                checkMandatorySelection()
            }
            else{
                cell.TxtField.becomeFirstResponder()
            }
            answer = cell.TxtField.text!
            return cell
        }
        if questionType == "ML"{
            let cell = tableView.dequeueReusableCell(withIdentifier: "MultilineCell", for: indexPath as IndexPath) as! MultilineCell
            cell.textView.delegate = self
            cell.textView.text = ""
            cell.textView.becomeFirstResponder()
            if checkEditable == true && questionArray![questNumber!].editable_question != "1"{
                print("Cannot Change Data")
            }
            else{
                cell.clearBtn.addTarget(self, action: #selector(clearTextFromTextView(sender:)), for: .touchUpInside)
            }
            if optionsArray!.count > 0{
                cell.textView.text! = optionsArray![indexPath.row].option_value
            }
            answer = cell.textView.text
            return cell
        }
        if questionType == "DD" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "clcell", for: indexPath as IndexPath) as! CLCell
            
            return cell
        }
        else{
            
            if self.optionsArray![indexPath.section].questionTypeCode == "DD"{
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "clcell", for: indexPath as IndexPath) as! CLCell
                cell.label.text = ""
                inputTypeCode = self.optionsArray![indexPath.section].inputTypeCode
                let optionValue = self.optionsArray![indexPath.section].option_value
                let cascadeId = Int(self.optionsArray![indexPath.section].cascade_ripa_id)
                let cascadeQuest = newRipaViewModel.getCascadeQuestionUsingId(questionID: cascadeId!)
                optionsArray![indexPath.section].isSelected = false
                cell.bottomView.isHidden = true
                cell.closeView.isHidden = true

                if optionValue == "City or Unincorporated Area" || optionValue == "Street" || optionValue == "Name of school" || optionValue == "Intersection"{
                    cell.closeBtn.removeTarget(nil, action: nil, for: .allEvents)
                    if inputTypeCode == "C "{
                        if optionValue == "City or Unincorporated Area"{
                            cell.label.placeholder = "Select City"
                            cell.downImgView.isHidden = false
                            cell.label.text = AppConstants.city
                            cell.label.borderColor = .black
                            cell.downImgView.tintColor = .black
                           
                           
                            cell.citybtn.isUserInteractionEnabled = true
                            if self.isGpsEnable {
                                cell.label.textColor = .gray
                                cell.label.borderColor = .lightGray
                                cell.downImgView.tintColor = .lightGray
                                cell.citybtn.isUserInteractionEnabled = false
                            }
                           
                            if AppConstants.ripaGPS == "Y"{
                              //  cell.closeView.isHidden = false
                            }
                            
                            cell.closeBtn.setImage(UIImage(named:"target_location.png")!, for: .normal)
                            cell.closeBtn.tintColor = #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)
                            
                            if checkEditable == true && questionArray![questNumber!].editable_question != "1"{
                                print("Cannot Edit")
                                cell.closeBtn.removeTarget(nil, action: nil, for: .allEvents)
                            }
                            else{
                                cell.closeBtn.addTarget(self, action: #selector(getCityFromGPS(sender:)), for: .touchUpInside)
                            }
                            cell.closeBtn.tag = indexPath.section
                            
                            if self.traitCollection.userInterfaceStyle == .dark {
                                cell.label.textColor = .white
                             }
                        }
                    }
                    else if inputTypeCode == "L "{
                        if cascadeQuest.questionoptions!.count>0 && street.count == 0{
                            street =  cascadeQuest.questionoptions![0].option_value
                        }
                        cell.label.text = street
                        if optionValue == "Street"{
                            cell.label.placeholder = "Select Street"
                        }
                    }
                    else if inputTypeCode == "S "{
                        cell.label.text = AppConstants.schoolName
                        if optionValue == "Name of school"{
                            cell.label.placeholder = "Select name of school"
                        }
                    }
                    else if inputTypeCode == "IL"{
                        if cascadeQuest.questionoptions!.count>0 && intersectionStreet.count == 0{
                            intersectionStreet =  cascadeQuest.questionoptions![0].option_value
                        }
                        cell.label.text = intersectionStreet
                        if optionValue == "Intersection"{
                            cell.label.placeholder = "Cross street"
                            let loc = newRipaViewModel.showConcateLocation()
                            if loc != ""{
                                cell.closeBtn.setImage(UIImage(systemName: "multiply.circle")!, for: .normal)
                                cell.closeBtn.tintColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
                                cell.bottomView.isHidden = false
                                cell.bottomLbl.textColor = .red
                                cell.bottomLbl.text = loc
                                
                                if checkEditable == true && questionArray![questNumber!].editable_question != "1"{
                                    print("Cannot Edit")
                                    cell.swapBtn.removeTarget(nil, action: nil, for: .allEvents)
                                }
                                else{
                                    cell.swapBtn.isHidden = false
                                    cell.swapBtn.addTarget(self, action: #selector(swapStreetAndIntersection(sender:)), for: .touchUpInside)
                                }
                                if !is_k12!{
                                    cell.bottomLbl.textColor = UIColor(named: "BlackWhite")
                                }
                            }
                            else if intersectionStreet.count > 0 && street.count > 0{
                                cell.closeBtn.setImage(UIImage(systemName: "multiply.circle")!, for: .normal)
                                cell.closeBtn.tintColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
                                cell.bottomView.isHidden = false
                                cell.bottomLbl.textColor = .red
                                
                                cell.bottomLbl.text = blockStr + street + " & " +  intersectionStreet
                                completeAddressStr = blockStr + street + " & " +  intersectionStreet
                                if blockStr.count > 0 {
                                    cell.bottomLbl.text = blockStr + " BLK " + street + " & " +  intersectionStreet
                                    completeAddressStr = blockStr + " BLK " + street + " & " +  intersectionStreet
                                }
                               
                                if checkEditable == true && questionArray![questNumber!].editable_question != "1"{
                                    print("Cannot Edit")
                                    cell.swapBtn.removeTarget(nil, action: nil, for: .allEvents)
                                }
                                else{
                                    cell.swapBtn.isHidden = false
                                    cell.swapBtn.addTarget(self, action: #selector(swapStreetAndIntersection(sender:)), for: .touchUpInside)
                                }
                               // if !is_k12!{
                                    cell.bottomLbl.textColor = UIColor(named: "BlackWhite")
                              //  }
                            }
                            else if street.count > 0 && blockStr.count > 0{
                                cell.closeBtn.setImage(UIImage(systemName: "multiply.circle")!, for: .normal)
                                cell.closeBtn.tintColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
                                cell.bottomView.isHidden = false
                                cell.bottomLbl.textColor = .red
                                cell.bottomLbl.text = blockStr + " BLK " + street
                                completeAddressStr = blockStr + " BLK " + street
                                if intersectionStreet.count>0 {
                                    cell.bottomLbl.text = blockStr + " BLK " + street + " & " + intersectionStreet
                                    completeAddressStr = blockStr + " BLK " + street + " & " + intersectionStreet
                                }
                               
                                if checkEditable == true && questionArray![questNumber!].editable_question != "1"{
                                    print("Cannot Edit")
                                    cell.swapBtn.removeTarget(nil, action: nil, for: .allEvents)
                                }
                                else{
                                    cell.swapBtn.isHidden = false
                                    cell.swapBtn.addTarget(self, action: #selector(swapStreetAndIntersection(sender:)), for: .touchUpInside)
                                }
                               // if !is_k12!{
                                    cell.bottomLbl.textColor = UIColor(named: "BlackWhite")
                              //  }
                            }
                            
                            if intersectionStreet.count > 0 && blockStr.count > 0{
                               cell.closeBtn.setImage(UIImage(systemName: "multiply.circle")!, for: .normal)
                               cell.closeBtn.tintColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
                               cell.bottomView.isHidden = false
                               cell.bottomLbl.textColor = .red
                               cell.bottomLbl.text = blockStr + " BLK " + street + " & " +  intersectionStreet
                                completeAddressStr = blockStr + " BLK " + street + " & " +  intersectionStreet
                               if checkEditable == true && questionArray![questNumber!].editable_question != "1"{
                                   print("Cannot Edit")
                                   cell.swapBtn.removeTarget(nil, action: nil, for: .allEvents)
                               }
                               else{
                                   cell.swapBtn.isHidden = false
                                   cell.swapBtn.addTarget(self, action: #selector(swapStreetAndIntersection(sender:)), for: .touchUpInside)
                               }
                              // if !is_k12!{
                                   cell.bottomLbl.textColor = UIColor(named: "BlackWhite")
                             //  }
                           }
                            
                        }
                    }
                    
                    if cascadeQuest.questionoptions!.count>0{
                        
                        if optionValue == "Name of school"{
                            cell.label.text = AppConstants.schoolName
                            AppConstants.schoolName = cascadeQuest.questionoptions![0].option_value
                        }
                        if optionValue == "Intersection"{
                            if checkEditable == true && questionArray![questNumber!].editable_question != "1"{
                                print("Cannot Edit")
                            }
                            else{
                                cell.closeView.isHidden = false
                                cell.closeBtn.addTarget(self, action: #selector(clearOption(sender:)), for: .touchUpInside)
                                cell.closeBtn.tag = indexPath.section
                            }
                        }
                      
                     //   cell.label.text =  cascadeQuest.questionoptions![0].option_value
                        
                        if inputTypeCode == "L " && street.count > 0 && cell.label.text?.count == 0 {
                           
                            cell.label.text = street
                        }
                        else  if inputTypeCode == "L " && cell.label.text?.count != 0 && street.count == 0{
                            
                            street = cell.label.text!
                        }
                        else  if inputTypeCode == "L "{
                            street = cell.label.text!
                        }
                        if inputTypeCode == "IL" && intersectionStreet.count > 0 && cell.label.text?.count == 0{
                            cell.label.text = intersectionStreet
                        }
                         else  if inputTypeCode == "IL" && cell.label.text?.count != 0{
                             intersectionStreet = cell.label.text!
                         }
                        
                    }
                }
                else{
                    cell.label.text = optionValue
                }
             
                cell.citybtn.addTarget(self, action: #selector(openListViewController(sender:)), for: .touchUpInside)
                cell.citybtn.tag = indexPath.section
                cell.citybtn.isHidden = false
                if AppConstants.address.count > 2{
                    nextEnabled = false
                    enableNextButton(View: nextView)
                }
                if self.durationTxtField.text?.count == 0{
                    disableNextButton(View: nextView)
                }
    
                return cell
            }
            
            else if (self.optionsArray![indexPath.section].questionTypeCode == "SL" && self.optionsArray![indexPath.section].inputTypeCode == "N "){
                
                let  cell = tableView.dequeueReusableCell(withIdentifier: "SingleLineCell", for: indexPath as IndexPath) as! SingleLineCell
                
                cell.TxtField.keyboardType = UIKeyboardType.numberPad
                
                cell.TxtField.delegate = self
                cell.TxtField.text = ""
                cell.TxtField.placeholder = "Enter Block"
                cell.clearTxtBtn.isHidden = true
                cell.imgView.isHidden = true
                cell.TxtField.isUserInteractionEnabled = true
                
                let cascadeQuest = newRipaViewModel.getCascadeQuestionUsingId(questionID: Int(optionsArray![indexPath.section].cascade_ripa_id)!)
                
                let mainString = AppConstants.address
               
                if mainString.count > 2 {
                    let components = mainString.components(separatedBy: "BLOCK")
                    if components.count > 1 {
                        cell.TxtField.text! = components[0]
                    }
                }
                
                if cascadeQuest.questionoptions!.count > 0{
                    cell.TxtField.text! = (cascadeQuest.questionoptions![0] ).option_value
                }
                answer = cell.TxtField.text!
                
                
                if checkEditable == true && questionArray![questNumber!].editable_question != "1"{
                    print("Cannot Edit")
                    cell.TxtField.isUserInteractionEnabled = false
                }
                else{
                    if answer != "" {
                        cell.clearTxtBtn.isHidden = false
                        cell.clearTxtBtn.addTarget(self, action: #selector(clearOption(sender:)), for: .touchUpInside)
                        cell.clearTxtBtn.tag = indexPath.section
                    }
                }
                
                
                return cell
                
            }
            else{
                if optionsArray![indexPath.section].inputTypeCode == "AN" && optionsArray![indexPath.section].questionTypeCode == "SC"{
                    
                    if questionArray![questNumber!].question_code == "5"{
                        let cell = tableView.dequeueReusableCell(withIdentifier: "togglCell", for: indexPath as IndexPath) as! togglCell
                        
                        cell.requiredView.isHidden = true
                        //cell.label.placeholder = "Select name of school"
                        cell.toggleBtn.isOn = false
                        cell.textLbl.text = optionsArray![indexPath.section].option_value
                        cell.textLbl.textColor =  UIColor(named: "BlackWhite")
                        cell.toggleBtn.tag = indexPath.section
                        cell.toggleBtn.isUserInteractionEnabled = false
                        if checkEditable == true && questionArray![questNumber!].editable_question != "1"{
                            print("Cannot Change Data")
                        }
                        else{
                            cell.toggleBtn.isUserInteractionEnabled = true
                        }
                        
                        cell.toggleBtn.addTarget(self, action: #selector(self.locationSwitch(_:)), for: .valueChanged)
                        
                        let ad = newRipaViewModel.getCascadeQuestionUsingId(questionID: Int(optionsArray![2].cascade_ripa_id)!)
                        if ad.questionoptions?.count ?? 0 > 0 , (ad.questionoptions![0]).isSelected == true{
                            AppConstants.isSchoolSelected = "Yes"
                            cell.toggleBtn.isOn = true
                        }
                        AppConstants.isSchoolSelected = ""
                        cell.toggleBtn.isOn = false
                        if optionsArray![2].isSelected == true {
                            cell.toggleBtn.isOn = true
                            AppConstants.isSchoolSelected = "Yes"
                        }
                        
                        return cell
                    }
                    else{
                        let cell = tableView.dequeueReusableCell(withIdentifier: "SingleChoiceCell", for: indexPath as IndexPath) as! SingleChoiceCell
                        cell.optionView.backgroundColor = UIColor(named: "TextWhiteBlack")
                        
                        cell.optionTxt.text = (self.optionsArray![indexPath.section].questionoptions![indexPath.row] ).option_value
                        
                        cell.radioImage.image = UIImage(named: "Unselect")
                        cell.optionTxt.font = UIFont.systemFont(ofSize: 18.0)
                        
                        if  (optionsArray![indexPath.section].questionoptions![indexPath.row] ).isSelected{
                          //  cell.optionView.backgroundColor = UIColor(named: "SelectionBlue")
                            cell.radioImage.image = UIImage(named: "Select")
                            cell.optionTxt.font = UIFont.boldSystemFont(ofSize: 18.0)
                        }
                        return cell
                    }
                    
                    
                }
                
                if optionsArray![indexPath.section].inputTypeCode == "AN" && optionsArray![indexPath.section].questionTypeCode == "ML"{
                    let  cell = tableView.dequeueReusableCell(withIdentifier: "SingleLineCell", for: indexPath as IndexPath) as! SingleLineCell
                    cell.TxtField.placeholder = optionsArray![indexPath.section].option_value
                    cell.TxtField.keyboardType = UIKeyboardType.default
                    cell.TxtField.text = ""
                    cell.cellView.backgroundColor = UIColor(named: "TextWhiteBlack")
                    cell.TxtField.delegate = self
                    cell.TxtField.tag = indexPath.section
                    cell.clearTxtBtn.isHidden = true
                    cell.imgView.isHidden = true
                    let cascadeQuestion = newRipaViewModel.getCascadeQuestionUsingId(questionID: Int(optionsArray![indexPath.section].cascade_ripa_id)!)
                    
                    if cascadeQuestion.questionoptions!.count > 0{
                        //optionsArray![indexPath.section].isSelected = true
                        cell.TxtField.text! =  (cascadeQuestion.questionoptions!.first)!.option_value
                        enableNextButton(View: nextView)
                    }
                    answer = cell.TxtField.text!
                    return cell
                }
                
                
                let cascadeOption = self.optionsArray![indexPath.section].questionoptions
                let code = (cascadeOption![indexPath.row] ).questionTypeCode
                inputTypeCode = (cascadeOption![indexPath.row] ).inputTypeCode
                var cascadeId = Int((cascadeOption![indexPath.row] ).cascade_ripa_id)
                
                
                if code == "LV"{
                    let cell = tableView.dequeueReusableCell(withIdentifier: "ViolationCell2", for: indexPath as IndexPath) as! ViolationCell2
                    cell.dropdownBackgroundView.backgroundColor = UIColor(named: "TextWhiteBlack")
                    if inputTypeCode == "V "{
                        cell.requiredView.isHidden = false
                        if cascadeOption![0].question_code_for_cascading_id == "C11"{
                            cell.requiredImg.image = #imageLiteral(resourceName: "optional")
                        }
                        else if self.questionArray![self.questNumber!].question_code == "14" {
                            cell.requiredImg.image = UIImage(named: "required_icon")
                        }
                        
                        if questionArray![questNumber!].question_code != "14"{
                            cell.requiredView.isHidden = true
                        }
                        else if self.questionArray![self.questNumber!].question_code == "14" &&  self.optionsArray![indexPath.section].physical_attribute == "1" {
                            cell.requiredImg.image = UIImage(named: "required_icon")
                        }
                        
                        violationArray = newRipaViewModel.getViolations()
                        
                        optionsArray![indexPath.section].order_number = orderId!
                        optionsArray![indexPath.section].questionoptions![indexPath.row].order_number = orderId!
                        
                        optionsArray![indexPath.section].mainQuestOrder = orderId!
                        optionsArray![indexPath.section].questionoptions![indexPath.row].mainQuestOrder = orderId!
                        
                        cascadeDict = ["QuestionTag":Int(indexPath.section),"QuestionRow":Int(indexPath.row),"ViolationArray" :violationArray!]
                        let cascadeQuestion = newRipaViewModel.getCascadeQuestionUsingId(questionID: cascadeId!)
                        optionsArray![indexPath.section].isSelected = false
                       
                        if questionArray![questNumber!].question_code == "14" && ((viewType != "StartNewRipa" && AppConstants.status != "LastRipa" && AppConstants.status != "Template" && saveRipaStatus != "Created") || AppConstants.isTemplate == "temp") && saveRipaStatus != "" {
                           // cell.ClearBtn.isHidden = true
                           // cell.isResultStop = true
                           // cell.violTable.b
                            let personDict = personArray[personcount]
                            let selectedOption = personDict["SelectedOption"] as! [[Questionoptions1]]
                            if selectedOption.count > 4{
                                cascadeQuestion.questionoptions?.removeAll()
                                let minObj = selectedOption[4]
                                for jj in 0..<(minObj.count) {
                                    if (minObj[jj].mainQuestId == "14" || minObj[jj].mainQuestId == "109") && ( minObj[jj].ripa_id == "71" ||  minObj[jj].ripa_id == "20" ||  minObj[jj].ripa_id == "28"){
                                        let contains = cascadeQuestion.questionoptions?.contains(where: {
                                            $0.option_value == minObj[jj].option_value
                                        })
                                        if contains == false {
                                            minObj[jj].isNewAdded = false
                                            cascadeQuestion.questionoptions?.append(minObj[jj])
                                        }
                                    }
                                }
                            }
                        }
                        
                        if questionArray![questNumber!].question_code == "21" && ((viewType != "StartNewRipa" && AppConstants.status != "LastRipa" && AppConstants.status != "Template" && saveRipaStatus != "Created") || AppConstants.isTemplate == "temp") && AppConstants.status != "" {
                           // cell.ClearBtn.isHidden = true
                            cell.isResultStop = true
                           
                            let personDict = personArray[personcount]
                            let selectedOption = personDict["SelectedOption"] as! [[Questionoptions1]]
                            if selectedOption.count > 12{
                                cascadeQuestion.questionoptions?.removeAll()
                                let minObj = selectedOption[12]
                                for jj in 0..<(minObj.count) {
                                    if minObj[jj].mainQuestId == "39" && (minObj[jj].ripa_id == "40" || minObj[jj].ripa_id == "75") && indexPath.section == 12{
                                        let contains = cascadeQuestion.questionoptions?.contains(where: {
                                            $0.option_value == minObj[jj].option_value
                                        })
                                        if contains == false {
                                            minObj[jj].isNewAdded = false
                                            cascadeQuestion.questionoptions?.append(minObj[jj])
                                        }
                                    }
                                    else  if minObj[jj].mainQuestId == "39" && (minObj[jj].ripa_id == "40" || minObj[jj].ripa_id == "76") && indexPath.section == 13{
                                        let contains = cascadeQuestion.questionoptions?.contains(where: {
                                            $0.option_value == minObj[jj].option_value
                                        })
                                        if contains == false {
                                            minObj[jj].isNewAdded = false
                                            cascadeQuestion.questionoptions?.append(minObj[jj])
                                        }
                                    }
                                    else  if minObj[jj].mainQuestId == "39" && (minObj[jj].ripa_id == "40" || minObj[jj].ripa_id == "50") && indexPath.section == 1{
                                        let contains = cascadeQuestion.questionoptions?.contains(where: {
                                            $0.option_value == minObj[jj].option_value
                                        })
                                        if contains == false {
                                            minObj[jj].isNewAdded = false
                                            cascadeQuestion.questionoptions?.append(minObj[jj])
                                        }
                                    }
                                    else if minObj[jj].mainQuestId == "39" && (minObj[jj].ripa_id == "40" || minObj[jj].ripa_id == "42") && indexPath.section == 4{
                                        let contains = cascadeQuestion.questionoptions?.contains(where: {
                                            $0.option_value == minObj[jj].option_value
                                        })
                                        if contains == false {
                                            minObj[jj].isNewAdded = false
                                            cascadeQuestion.questionoptions?.append(minObj[jj])
                                        }
                                    }
                                    else if minObj[jj].mainQuestId == "39" && (minObj[jj].ripa_id == "40" || minObj[jj].ripa_id == "42") && indexPath.section == 6{
                                        let contains = cascadeQuestion.questionoptions?.contains(where: {
                                            $0.option_value == minObj[jj].option_value
                                        })
                                        if contains == false {
                                            minObj[jj].isNewAdded = false
                                            cascadeQuestion.questionoptions?.append(minObj[jj])
                                        }
                                    }
                                }
                            }
                        }
                        
                        if cascadeQuestion.questionoptions!.count > 0{
                            cascadeQuestion.order_number = orderId!
                            
                            optionsArray![indexPath.section].isSelected = true
                            optionsArray![indexPath.section].questionoptions![indexPath.row].isSelected = true
                            cell.textView.isHidden = false
                        
                            var arr = cascadeQuestion.questionoptions!
                            
                          /* if AppConstants.offenceCodes.count > 0 {
                                arr.removeAll()
                                let arrOps = cascadeQuestion.questionoptions!
                                let selectItem = violationDict!["ViolationList"] as! [Questionoptions1]
                                for obj in arrOps {
                                    let checkC = selectItem.contains(where: {$0.option_value.capitalized == obj.option_value.capitalized})
                                    if checkC == true {
                                        arr.append(obj)
                                    }
                                }
                            } */
                            
                            if questionArray![questNumber!].question_code == "21"{
                                cell.isResultStop = true
                            }
                            cell.violationsArr = cascadeQuestion.questionoptions!
                            cell.section = indexPath.section
                            cell.delegate = self
                            cell.cellHeight.constant = CGFloat(arr.count * 40)
                            cell.ClearBtn.tag = indexPath.section
                            cell.ClearBtn.addTarget(self, action: #selector(dltAllViol(sender:)), for: .touchUpInside)
                            
                            
                            cell.violTable.reloadData()
                            
                            var strArr=[String]()
                            for opt in arr{
                                violationArray!.first(where: { $0.violationDisplay == opt.option_value })?.isSelected = opt.isSelected
                                strArr.append(opt.option_value)
                            }
                            
                            var i = 0
                            for vol in violationArray!{
                                if vol.isSelected{
                                    violationArray = rearrange(array: violationArray!, fromIndex: i, toIndex: 0)
                                }
                                i += 1
                            }
                            
                            cascadeDict!["ViolationArray"] = violationArray
                            cascadeDict!["Selected"] = true
                        }
                        else{
                            cascadeDict!["Selected"] = false
                            
                            cell.textView.isHidden = true
                        }
                      
                        cascadeArray.append(cascadeDict!)
                        cell.dropdownLbl.text = "Select Violations"
                        if checkEditable == true && questionArray![questNumber!].editable_question != "1"{
                            print("Cannot Change Data")
                        }
                        else{
                            cell.dropdownBtn.addTarget(self, action: #selector(openViolationList(sender:)), for: .touchUpInside)
                            cell.dropdownBtn.tag = indexPath.section
                        }
                    }
                    checkMandatorySelection()
                    return cell
                }
                
                if code == "DD"{
                    if inputTypeCode == "EC" {
                        let cell = tableView.dequeueReusableCell(withIdentifier: "EducationCodeCell", for: indexPath as IndexPath) as! EducationCodeCell
                        let cascadeQuestion = newRipaViewModel.getCascadeQuestionUsingId(questionID: cascadeId!)
                        cell.topLbl.text = "Education Code"
                        let eduCode = newRipaViewModel.getEducationCode()
                        educationCodeSectionArray = eduCode.0
                        educationCodeSubSectionArray = eduCode.1
                        cell.bottomView.isHidden = true
                        if cascadeQuestion.questionoptions!.count > 0{
                            //optionsArray![indexPath.section].isSelected = true
                            
                            if questionArray![questNumber!].question_code == "14" && ((viewType != "StartNewRipa" && AppConstants.status != "LastRipa" && AppConstants.status != "Template" && saveRipaStatus != "Created" && AppConstants.status != "") || AppConstants.isTemplate == "temp"){
                                let personDict = personArray[personcount]
                                let selectedOption = personDict["SelectedOption"] as! [[Questionoptions1]]
                                if cascadeQuestion.questionoptions![0].ripa_id != "47" {
                                    cascadeQuestion.questionoptions?.remove(at: 0)
                                    self.disableNextButton(View: nextView)
                                }
                               // cascadeQuestion.questionoptions?.removeAll()
                                if selectedOption.count > 4{
                                    let minObj = selectedOption[4]
                                    for jj in 0..<(minObj.count) {
                                        if minObj[jj].mainQuestId == "14" && ( minObj[jj].ripa_id == String(cascadeId!)){
                                            minObj[jj].isNewAdded = false
                                            if cascadeQuestion.questionoptions?.count ?? 0 > 0 {
                                                cascadeQuestion.questionoptions?.removeAll()
                                            }
                                            cascadeQuestion.questionoptions?.append(minObj[jj])
                                        }
                                    }
                                }
                            }
                            
                            cell.bottomView.isHidden = false
                            let arr = cascadeQuestion.questionoptions!
                            
                            var strArr=[String]()
                            for opt in arr{
                                educationCodeSectionArray!.first(where: { $0.educationCodeDesc == opt.option_value })?.isSelected = opt.isSelected
                                strArr.append(opt.option_value)
                            }
                            
                            var i = 0
                            for vol in educationCodeSectionArray!{
                                if vol.isSelected{
                                    educationCodeSectionArray = rearrange(array: educationCodeSectionArray!, fromIndex: i, toIndex: 0)
                                }
                                i += 1
                            }
                            
                            cell.bottomLbl.text = strArr.joined(separator: "\n")
                            
                        }
                        if checkEditable == true && questionArray![questNumber!].editable_question != "1"{
                            print("Cannot Change Data")
                        }
                        else{
                            cell.btn.addTarget(self, action: #selector(openEducationCodeList(sender:)), for: .touchUpInside)
                            cell.btn.tag = indexPath.section
                        }
                        return cell
                    }
                }
                
                if code == "SC" || code == "MC"{
                    if questionArray![questNumber!].question_code == "14" && saveRipaStatus == "Created"{
                        let obj = self.optionsArray?.filter({$0.isExpanded == true})
                        if obj?.count ?? 0 > 0 {
                            if obj?[0].question_code_for_cascading_id == "C35" {
                                cascadeId = 72
                            }
                            else if obj?[0].question_code_for_cascading_id == "C3" {
                                cascadeId = 18
                            }
                            else if obj?[0].question_code_for_cascading_id == "C1" {
                                cascadeId = 16
                            }
                        }
                    }
                    
                    let cascadeQuestion = newRipaViewModel.getCascadeQuestionUsingId(questionID: cascadeId!)
                    
                    var voilationTypeSelected = false
                    cascadeDict = ["QuestionTag":Int(indexPath.section),"QuestionRow":Int(indexPath.row),"ViolationTypeArray":cascadeQuestion.questionoptions!,"QuestionTypeCode": code]
                    let cell = tableView.dequeueReusableCell(withIdentifier: "ViolationTextCell", for: indexPath as IndexPath) as! ViolationTextCell
                    
                    cell.requiredImg.image = #imageLiteral(resourceName: "required_icon")

                    cell.bottomView.isHidden = true
                    //cell.topViewText.text = optionsArray![indexPath.row].option_value
                    cell.topViewText.text = (self.optionsArray![indexPath.section].questionoptions![indexPath.row] ).option_value
                    
                    var arr = cascadeQuestion.questionoptions!
                    var strArr=[String]()
                    
                    if questionArray![questNumber!].question_code == "14" && ((viewType != "StartNewRipa" && AppConstants.status != "LastRipa" && AppConstants.status != "Template" && saveRipaStatus != "Created") || AppConstants.isTemplate == "temp"){
                        let personDict = personArray[personcount]
                        let selectedOption = personDict["SelectedOption"] as! [[Questionoptions1]]
                        if selectedOption.count > 4{
                            let minObj = selectedOption[4]
                            for jj in 0..<(minObj.count) {
                                if minObj[jj].mainQuestId == "72" {
                                    for kk in 0..<arr.count {
                                        if arr[kk].physical_attribute == minObj[jj].physical_attribute {
                                            arr[kk].isSelected = true
                                        }
                                    }
                                }
                                else if minObj[jj].ripa_id == "16" {
                                    for kk in 0..<arr.count {
                                        if arr[kk].option_value.capitalized == minObj[jj].option_value.capitalized {
                                            arr[kk].isSelected = true
                                        }
                                    }
                                }
                                else  if minObj[jj].ripa_id == "18" {
                                    checkEditable = true
                                    questionArray![questNumber!].editable_question = "0"
                                    if let indx = cascadeQuestion.questionoptions?.firstIndex(where: {$0.ripa_id != "18"}) {
                                        cascadeQuestion.questionoptions?.remove(at: indx)
                                        arr = cascadeQuestion.questionoptions ?? []
                                    }
                                    let isCheck = cascadeQuestion.questionoptions?.contains(where: {
                                        $0.option_value ==  minObj[jj].option_value
                                    })
                                    if isCheck == false {
                                        cascadeQuestion.questionoptions?.append(minObj[jj])
                                    }
                                }
                            }
                            if arr.count == 0 {
                                arr = cascadeQuestion.questionoptions ?? []
                            }
                        }
                    }
                    
                    for option in arr{
                        if option.isSelected == true{
                            voilationTypeSelected = true
                            cell.bottomView.isHidden = false
                            strArr.append(option.option_value)
                        }
                    }
                    
                    var voilationSelected : Bool = false
                    for dict in cascadeArray{
                        if dict["QuestionTag"] as! Int == indexPath.section && dict["QuestionRow"] as! Int == 0{
                            voilationSelected = dict["Selected"] as? Bool ?? false
                        }
                    }
                    cell.topView.backgroundColor = UIColor(named: "TextWhiteBlack")
                    (cascadeOption![indexPath.row] ).isSelected = false
                    if voilationSelected == true || voilationTypeSelected == true{
                        optionsArray![indexPath.section].isSelected = true
                        if voilationTypeSelected == true{
                            (cascadeOption![indexPath.row] ).isSelected = true
                            cell.topView.backgroundColor = UIColor(named: "LightGrayLightBlack")
                        }
                    }
                  
                    cell.bottomViewText.text = strArr.joined(separator: " \n\n ")
                    if checkEditable == true && questionArray![questNumber!].editable_question != "1"{
                        print("Cannot Change Data")
                    }
                    else{
                        cell.btn.addTarget(self, action: #selector(openViolationTypeList(sender:)), for: .touchUpInside)
                        cell.btn.tag = indexPath.section
                    }
                   
                    cascadeArray.append(cascadeDict!)
                    checkMandatorySelection()
                    return cell
                }
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "SingleChoiceCell", for: indexPath as IndexPath) as! SingleChoiceCell
                cell.optionView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                cell.radioImage.image = UIImage(named: "Unselect")
                cell.optionTxt.font = UIFont.systemFont(ofSize: 18.0)
                cell.optionTxt.text = (self.optionsArray![indexPath.section].questionoptions![indexPath.row] ).option_value
                if  (optionsArray![indexPath.section].questionoptions![indexPath.row] ).isSelected{
                    cell.radioImage.image = UIImage(named: "Select")
                    cell.optionTxt.font = UIFont.boldSystemFont(ofSize: 18.0)
                   // cell.optionView.backgroundColor = UIColor(named: "SelectionBlue")
                }
                
                return cell
            }
        }
        
    }
   
    func rearrange<T>(array: Array<T>, fromIndex: Int, toIndex: Int) -> Array<T>{
        var arr = array
        let element = arr.remove(at: fromIndex)
        arr.insert(element, at: toIndex)
        
        return arr
    }
    
    
    @objc func clearTextFromTextView(sender: UIButton) {
        optionsArray?.removeAll()
        tableView.reloadData()
    }
    
    
    
    @objc func clearOption(sender: UIButton) {
        if questionArray![questNumber!].question_code == "5" || questionArray![questNumber!].question_code == "25"{
            removeOptFromCascade(index: sender.tag)
        }
        if questionArray![questNumber!].question_code == "25"{
            removeOptFromCascade(index: sender.tag)
        }
        if sender.tag == 99 {
            AppConstants.block = ""
        }
        else if sender.tag == 999 {
            AppConstants.closestHighway = ""
        }
        tableView.reloadData()
    }
    
    
    func removeOptFromCascade(index:Int){
        if index < optionsArray?.count ?? 0 {
            let cascadeId = optionsArray![index].cascade_ripa_id
            let quest = newRipaViewModel.getCascadeQuestionUsingId(questionID: Int(cascadeId)!)
            quest.questionoptions?.removeAll()
        }
    }
    
    
    
    @objc func openEducationCodeList(sender: UIButton) {
        let registerView = self.storyboard?.instantiateViewController(withIdentifier: "ListViewController") as! ListViewController
        registerView.locationdelegate = self
        indexPath = sender.tag
        
        registerView.listType = "EducationCode"
        let eduCode = newRipaViewModel.getEducationCode()
        if questionArray![questNumber!].question_code == "14" && viewType != "StartNewRipa"{
            let personDict = personArray[personcount]
            let selectedOption = personDict["SelectedOption"] as! [[Questionoptions1]]
            if selectedOption.count > 4{
                let minObj = selectedOption[4]
                for jj in 0..<(minObj.count) {
                    if minObj[jj].mainQuestId == "14" && ( minObj[jj].ripa_id == "47"){
                        let optValue = minObj[jj].option_value
                        let index = eduCode.0.firstIndex(where: {
                            $0.educationCodeDesc == optValue
                        })
                        if index != nil {
                            eduCode.0[index!].isSelected = true
                        }
                    }
                }
            }
        }
        registerView.educationCodeSectionArray = eduCode.0
        registerView.educationCodeSubSectionArray = eduCode.1
        
        self.navigationController?.present(registerView, animated: true, completion: nil)
    }
    
    
    func openEducationSubCodeList() {
        let registerView = self.storyboard?.instantiateViewController(withIdentifier: "ListViewController") as! ListViewController
        registerView.locationdelegate = self
        
        registerView.listType = "EducationSubCode"
        let eduCode = newRipaViewModel.getEducationCode()
        registerView.educationCodeSectionArray = eduCode.0
        registerView.educationCodeSubSectionArray = eduCode.1
        
        self.navigationController?.present(registerView, animated: true, completion: nil)
    }
    
    
    @objc func openViolationTypeList(sender: UIButton) {
        let arr = cascadeArray
        for dict in cascadeArray{
            if sender.tag == dict["QuestionTag"] as! Int && dict["QuestionRow"] as! Int == 1{
                indexPath = sender.tag
                let registerView = self.storyboard?.instantiateViewController(withIdentifier: "ViolationTypeView") as! ViolationTypeViewController
                registerView.violationTypeDelegate = self
                if optionsArray?[sender.tag].option_value == "Reasonable suspicion that person was engaged in criminal activity" {
                    registerView.basisName = "Basis (select all applicable)"
                }
                registerView.listType = "ViolationType"
                registerView.selectionType = dict["QuestionTypeCode"] as? String
                registerView.listArray = dict["ViolationTypeArray"] as? [Questionoptions1]
                
                self.navigationController?.present(registerView, animated: true, completion: nil)
            }
        }
        
    }
    
    
    
    @objc func openViolationList(sender: UIButton) {
        resignFirstResponder()
        for dict in cascadeArray{
            
            if sender.tag == dict["QuestionTag"] as! Int && dict["QuestionRow"] as! Int == 0{
                indexPath = sender.tag
                violationArray = dict["ViolationArray"] as? [ViolationsResult]
                
                let violationListFor = (optionsArray![dict["QuestionTag"]as! Int].option_value).lowercased()
                if violationListFor.contains("traffic") || violationListFor.contains("warning") || violationListFor.contains("citation for infraction") {
                    violationArray = self.violationArray!.filter {
                        $0.violationGroup == "VC" || $0.violationGroup == "AA"
                    }
                }
                
                if (optionsArray![dict["QuestionTag"]as! Int].question_code_for_cascading_id) == "C1" || (optionsArray![dict["QuestionTag"]as! Int].question_code_for_cascading_id) == "C21" || (optionsArray![dict["QuestionTag"]as! Int].question_code_for_cascading_id) == "C22" || (optionsArray![dict["QuestionTag"]as! Int].question_code_for_cascading_id) == "C12"{
                    
                    violationArray = self.violationArray!.filter {
                        $0.violationGroup == "VC" || $0.violationGroup == "AA"
                    }
                }
                
                if (optionsArray![dict["QuestionTag"]as! Int].question_code_for_cascading_id) == "C8" {
                    violationArray = self.violationArray!.filter {
                        $0.violationGroup != "VC"
                    }
                }
                
                if violationListFor.contains("criminal activity") || violationListFor.contains("custodial arrest without warrant") {
                    violationArray = self.violationArray!.filter {
                        $0.violationGroup != "VC"
                    }
                }
                
                let registerView = self.storyboard?.instantiateViewController(withIdentifier: "ListViewController") as! ListViewController
                registerView.locationdelegate = self
                registerView.listType = "Violation"
                if questionArray![questNumber!].question_code == "21"{
                    registerView.isResultStop = true
                    for jj in 0..<(self.selectedVioArray.count) {
                        for row in 0..<self.violationArray!.count {
                            if self.violationArray?[row].violationID == self.selectedVioArray[jj].violationID {
                                self.violationArray![row].isNewAdded = self.selectedVioArray[jj].isNewAdded
                            }
                        }
                    }
                }
                
                if questionArray![questNumber!].question_code == "14" && self.isClearViolations == true{
                    violationArray?.forEach({$0.isSelected = false})
                }
                
                    let personDict = personArray[personcount]
                    let selectedOptArray = personDict["SelectedOption"] as! [[Questionoptions1]]
                    if selectedOptArray.count > 4 {
                        let objj = selectedOptArray[4].filter({$0.ripa_id == "20"})
                        if objj.count > 0 {
                            for cobj in objj {
                                if let index = violationArray?.firstIndex(where: {$0.violationDisplay.capitalized == cobj.option_value.capitalized}) {
                                    violationArray?[index].isSelected = true
                                }
                            }
                        }
                    }
                
                
                registerView.violationArray = violationArray
                self.navigationController?.present(registerView, animated: true, completion: nil)
                
            }
        }
        
    }
    
    
    @objc func openListViewController(sender: UIButton) {
        
        if checkEditable == true && questionArray![questNumber!].editable_question != "1"{
            print("Cannot Change Data")
        }
        else{
            openList(index: sender.tag)
        }
    }
  
    func openList(index:Int){
        var citySelected:Bool = false
        var streetSelected:Bool = false
        locTypeRow = index
        
        for quest in cascadeQuestionArray!{
            if quest.question_code == "C6"{
                if quest.questionoptions!.count > 0{
                    citySelected = true
                } }
            if quest.question_code == "C7"{
                if quest.questionoptions!.count > 0{
                    streetSelected = true
                } }
        }
        
        let listView = self.storyboard?.instantiateViewController(withIdentifier: "ListViewController") as! ListViewController
        listView.locationdelegate = self
        
        if index == 0{
            listView.listType = "City or Unincorporated Area"
            var ccArray = newRipaViewModel.getCities()
            ccArray = ccArray.sorted(by: { (Obj1, Obj2) -> Bool in
                  let Obj1_Name = Obj1.city_name
                  let Obj2_Name = Obj2.city_name
                  return (Obj1_Name.localizedCaseInsensitiveCompare(Obj2_Name) == .orderedAscending)
               })
            listView.cityArray = ccArray
        }
        else if index == 1 {
            listView.listType = "Location"
            let locDetail = newRipaViewModel.getLocation(cityID: cityID)
            listView.locationArray = locDetail.0
            listView.location = locDetail.1
            // listView.locationArray = newRipaViewModel.getLocation(cityID: cityID).0
            
            if citySelected != true && AppConstants.city.count == 0{
                AppUtility.showAlertWithProperty("Alert", messageString: "Select City")
                return
            }
        }
        else if index == 3 {
            listView.listType = "Intersection"
            let locDetail = newRipaViewModel.getLocation(cityID: cityID)
            listView.locationArray = locDetail.0
            listView.location = locDetail.1
            
            if citySelected != true && AppConstants.city.count == 0{
                AppUtility.showAlertWithProperty("Alert", messageString: "Select City")
                return
            }
            if streetSelected != true && street.count == 0 {
                AppUtility.showAlertWithProperty("Alert", messageString: "Select Street")
                return
            }
        }
        else if index == 11 {
            listView.listType = "Street"
            let locDetail = newRipaViewModel.getLocation(cityID: cityID)
            listView.locationArray = locDetail.0
            print(locDetail.0.count)
            listView.location = locDetail.1
           
        }
        else if index == 12 {
            listView.listType = "First Intersection"
            let locDetail = newRipaViewModel.getLocation(cityID: cityID)
            listView.locationArray = locDetail.0
            print(locDetail.0.count)
            listView.location = locDetail.1
           
        }
        else if index == 13 {
            listView.listType = "Second Intersection"
            let locDetail = newRipaViewModel.getLocation(cityID: cityID)
            listView.locationArray = locDetail.0
            print(locDetail.0.count)
            listView.location = locDetail.1
           
//            if citySelected != true && AppConstants.secondIntersection.count == 0{
//                AppUtility.showAlertWithProperty("Alert", messageString: "Select Second Intersection")
//                return
//            }
        }
        else if index == 14 {
            listView.listType = "Highway"
            let locDetail = newRipaViewModel.getHighways(cityID: cityID)
            listView.locationArray = locDetail.0
            print(locDetail.0.count)
            listView.location = locDetail.1
           
        }
        else if index == 15 {
            listView.listType = "Closest Highway Exit"
            let locDetail = newRipaViewModel.getLocation(cityID: cityID)
            listView.locationArray = locDetail.0
            print(locDetail.0.count)
            listView.location = locDetail.1
           
        }
        else{
            if citySelected != true && AppConstants.city.count == 0 {
                AppUtility.showAlertWithProperty("Alert", messageString: "Select City")
                return
            }
            
            listView.listType = "School"
            listView.schoolArray = newRipaViewModel.getSchool(cityID: cityID)
        }
        
        listView.cityID = cityID
        listView.streetName = streetName
        listView.intersectionName = intersectionName
        self.navigationController?.present(listView, animated: true, completion: nil)
    }
    
    func refreshViolationLists(list: [Questionoptions1]?, listType: String) {
        refreshLocationLists(list: list, listType: listType)
        
    }
    
    
    func setMainQuestIdAndOptn(optn:Questionoptions1)->Questionoptions1{
        optn.mainQuestId = questionId
        optn.mainQuestOrder = orderId ?? ""
        
        return optn
    }
    
    
    func refreshLocationLists(list:[Any]?, listType: String) {
        
        var questionID : Int?
        var option:Any?
        var selectedViolationArray = [Questionoptions1]()
        
        var violationTypeArray = [Questionoptions1]()
        var educationCodeId = ""
        var hasVal = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            UIApplication.shared.sendAction(#selector(UIApplication.resignFirstResponder), to: nil, from: nil, for: nil);
        }
        
        if listType == "EducationCode"{
            questionID =  Int((optionsArray![indexPath!].questionoptions![0] ).cascade_ripa_id)
            for educode in  list! as! [EducationCodeSection]{
                if educode.isSelected{
                    educationCodeId = educode.educationCodeSectionID
                    option = newRipaViewModel.createObj(mainQuestId: questionId, ripaID: String(questionID!), optionValue: educode.educationCodeDesc, physical_attribute: educode.physicalAttribute, description: educode.educationCode, isSelected: true, mainQuestOrder: orderId!, isNewAdded: false, mainId: vioQuestionId)
                    selectedViolationArray.append(setMainQuestIdAndOptn(optn: option as! Questionoptions1))
                    optionsArray![indexPath!].isSelected = false
                    
                    if ((viewType != "StartNewRipa" && AppConstants.status != "LastRipa" && AppConstants.status != "Template") || AppConstants.isTemplate == "temp") && saveRipaStatus != "Created" && (questionArray![questNumber!].question_code == "14"){
                        var personDict = personArray[personcount]
                        var selectedOptArray = personDict["SelectedOption"] as! [[Questionoptions1]]
                        if let index = selectedOptArray[4].firstIndex(where: {$0.ripa_id == "47" && $0.optionDescription != "48900"}) {
                            selectedOptArray[4].remove(at: index)
                        }
                        if  selectedOptArray[4].count > 1 {
                            selectedOptArray[4].insert(option as! Questionoptions1, at: 1)
                        }
                        else {
                            selectedOptArray[4].append(option as! Questionoptions1)
                        }
                        personDict["SelectedOption"] = selectedOptArray
                        personArray[personcount] = personDict
                    }
                }
            }
            
            checkForSingleSelection(index : indexPath!)
            
            optionsArray![indexPath!].order_number = orderId!
            optionsArray![indexPath!].mainQuestOrder = orderId!
            for options in optionsArray![indexPath!].questionoptions!{
                options.order_number = orderId!
                options.mainQuestOrder = orderId!
            }
        }
        
        
        
        if listType == "EducationSubCode"{
            optionsArray![indexPath!].mainQuestOrder = questionArray![questNumber!].id
            questionID = Int((optionsArray![indexPath!].questionoptions![0] ).cascade_ripa_id)
            for educode in list! as! [EducationCodeSubsection]{
                if educode.isSelected{
                    option = newRipaViewModel.createObj(mainQuestId: questionId, ripaID: String(questionID!), optionValue: educode.educationCodeSubsectionDesc, physical_attribute: educode.physicalAttribute, description: educode.educationCodeSubsection, isSelected: true, mainQuestOrder: orderId!, isNewAdded: false, mainId: vioQuestionId)
                    optionsArray![indexPath!].isSelected = false
                    //optionsArray![indexPath!].order_number = orderId!
                    if ((viewType != "StartNewRipa" && AppConstants.status != "LastRipa" && AppConstants.status != "Template") || AppConstants.isTemplate == "temp") && saveRipaStatus != "Created" && (questionArray![questNumber!].question_code == "14"){
                        var personDict = personArray[personcount]
                        var selectedOptArray = personDict["SelectedOption"] as! [[Questionoptions1]]
                        if  selectedOptArray[4].count > 1 {
                            selectedOptArray[4].insert(option as! Questionoptions1, at: selectedOptArray[4].count - 1)
                        }
                        else {
                            selectedOptArray[4].append(option as! Questionoptions1)
                        }
                        personDict["SelectedOption"] = selectedOptArray
                        personArray[personcount] = personDict
                        
                    }
                }
            }
            
            if tempautoNext == true{
                AppConstants.autoNext = true
            }
            checkForSingleSelection(index : indexPath!)
            
            optionsArray![indexPath!].order_number = orderId!
            optionsArray![indexPath!].mainQuestOrder = orderId!
            for options in optionsArray![indexPath!].questionoptions!{
                options.order_number = orderId!
                options.mainQuestOrder = orderId!
            }
        }
        
        if listType == "ViolationType"{
            violationTypeArray = list as! [Questionoptions1]
          //  let obj = optionsArray
            questionID =  Int((optionsArray![indexPath!].questionoptions![1] ).cascade_ripa_id)
            
            for violation in violationTypeArray{
                if violation.isSelected{
                    hasVal = true
                    print(violation.option_value)
                    violation.order_number = orderId!
                    violation.mainQuestOrder = orderId!
                    //optionsArray![indexPath!].order_number = orderId!
                    if ((viewType != "StartNewRipa" && AppConstants.status != "LastRipa" && AppConstants.status != "Template") || AppConstants.isTemplate == "temp") && saveRipaStatus != "Created" && (questionArray![questNumber!].question_code == "14"){
                        var personDict = personArray[personcount]
                        var selectedOptArray = personDict["SelectedOption"] as! [[Questionoptions1]]
                        if let index = selectedOptArray[4].firstIndex(where: {$0.ripa_id == "16"}) {
                            let optID = optionsArray![indexPath!].option_id
                            if optID != "90" && optID != "1274"{
                                selectedOptArray[4].remove(at: index)
                            }
                           
                            option = newRipaViewModel.createObj(mainQuestId: questionId, ripaID: "16", optionValue: violation.option_value, physical_attribute: "", description: violation.optionDescription, isSelected: true, mainQuestOrder: orderId!, isNewAdded: violation.isNewAdded, mainId: vioQuestionId)
                            if  selectedOptArray[4].count > 4 {
                                selectedOptArray[4].insert(option as! Questionoptions1, at: 4)
                            }
                            else if  selectedOptArray[4].count < 4 {
                                selectedOptArray[4].insert(option as! Questionoptions1, at: selectedOptArray[4].count - 1)
                            }
                            else {
                                selectedOptArray[4].append(option as! Questionoptions1)
                            }
                            personDict["SelectedOption"] = selectedOptArray
                            personArray[personcount] = personDict
                            tableView.reloadData()
                        }
                        else {
                            option = newRipaViewModel.createObj(mainQuestId: questionId, ripaID: "16", optionValue: violation.option_value, physical_attribute: "", description: violation.optionDescription, isSelected: true, mainQuestOrder: orderId!, isNewAdded: violation.isNewAdded, mainId: vioQuestionId)
                            if  selectedOptArray[4].count > 4 {
                                selectedOptArray[4].insert(option as! Questionoptions1, at: 4)
                            }
                            else if  selectedOptArray[4].count < 4 {
                                selectedOptArray[4].insert(option as! Questionoptions1, at: selectedOptArray[4].count - 1)
                            }
                            else {
                                selectedOptArray[4].append(option as! Questionoptions1)
                            }
                            personDict["SelectedOption"] = selectedOptArray
                            personArray[personcount] = personDict
                            tableView.reloadData()
                        }
                    }
                }
            }
            if hasVal == true{
                checkForSingleSelection(index : indexPath!)
            }
            optionsArray![indexPath!].isSelected = true
            optionsArray![indexPath!].order_number = orderId!
            optionsArray![indexPath!].mainQuestOrder = orderId!
            for options in optionsArray![indexPath!].questionoptions!{
                options.order_number = orderId!
                options.mainQuestOrder = orderId!
            }
        }
        
        if listType == "Violation"{
            
            questionID =  Int((optionsArray![indexPath!].questionoptions![0] ).cascade_ripa_id)
            //print(questionID)
            if list!.count > 0{
                if questionArray![questNumber!].question_code == "14"{
                    selectedViolationArray2.removeAll()
                }
            }
            self.isClearViolations = false
            selectedVioArray.removeAll()
            for violation in list! as! [ViolationsResult]{
                if violation.isSelected{
                    option = newRipaViewModel.createObj(mainQuestId: questionId, ripaID: String(questionID!), optionValue: violation.violationDisplay, physical_attribute: "", description: violation.offense_code, isSelected: true, mainQuestOrder: orderId!, isNewAdded: violation.isNewAdded, mainId: vioQuestionId)
                    violation.mainId = vioQuestionId
                    
                    selectedVioArray.append(violation)
                    print(violation.violationDisplay)
                    if AppConstants.violation_type.count > 0 && AppConstants.offenceCodes.count > 0 {
                        let checkk = selectdViolationByDropDown.contains(where: {$0.option_value.capitalized == violation.violationDisplay.capitalized})
                        if checkk == true {
                            selectedViolationArray.append(option as! Questionoptions1)
                            selectedViolationArray2.append(option as! Questionoptions1)
                        }
                    }
                    else {
                        selectedViolationArray.append(option as! Questionoptions1)
                        selectedViolationArray2.append(option as! Questionoptions1)
                    }
                    
                   
                    optionsArray![indexPath!].isSelected = false
                    hasVal = true
                   
                    if ((viewType != "StartNewRipa" && AppConstants.status != "LastRipa" && AppConstants.status != "Template") || AppConstants.isTemplate == "temp") && (questionArray![questNumber!].question_code == "21"){
                        var personDict = personArray[personcount]
                        var selectedOptArray = personDict["SelectedOption"] as! [[Questionoptions1]]
                        let exist = selectedOptArray[12].contains(where: {
                            $0.option_value == violation.violationDisplay
                        })
                        
                         if exist == false {
                             option = newRipaViewModel.createObj(mainQuestId: questionId, ripaID: "40", optionValue: violation.violationDisplay, physical_attribute: "", description: violation.offense_code, isSelected: true, mainQuestOrder: orderId!, isNewAdded: violation.isNewAdded, mainId: vioQuestionId)
                            violation.mainId = vioQuestionId
                            selectedOptArray[12].append(option as! Questionoptions1)
                            personDict["SelectedOption"] = selectedOptArray
                            personArray[personcount] = personDict
                            tableView.reloadData()
                         }
                    } //&& saveRipaStatus != "Created"
                    else  if ((viewType != "StartNewRipa" && AppConstants.status != "LastRipa" && AppConstants.status != "Template") || AppConstants.isTemplate == "temp") && (questionArray![questNumber!].question_code == "14"){
                        var personDict = personArray[personcount]
                        var selectedOptArray = personDict["SelectedOption"] as! [[Questionoptions1]]
                        let exist = selectedOptArray[4].contains(where: {
                            $0.option_value == violation.violationDisplay
                        })
                        
                         if exist == false {
                             option = newRipaViewModel.createObj(mainQuestId: questionId, ripaID: "20", optionValue: violation.violationDisplay, physical_attribute: "", description: violation.offense_code, isSelected: true, mainQuestOrder: orderId!, isNewAdded: violation.isNewAdded, mainId: vioQuestionId)
                            violation.mainId = vioQuestionId
                             if selectedOptArray[4].count > 0 {
                                 selectedOptArray[4].insert(option as! Questionoptions1, at: 1)
                             }
                             else {
                                 selectedOptArray[4].append(option as! Questionoptions1)
                             }
                            personDict["SelectedOption"] = selectedOptArray
                            personArray[personcount] = personDict
                            tableView.reloadData()
                         }
                    }
                }
            }
        
            
            if questionArray![questNumber!].question_code == "14"{
                let question = newRipaViewModel.getCascadeQuestionUsingQuestionCode(questionCode: "C2")
                question.order_number = orderId!
                for options in selectedViolationArray{
                    if options.option_value.contains("4000(A)") || options.option_value.contains("5200"){
                        //  optionsArray![indexPath!].questionoptions![1].isSelected = true
                        for questionOption in question.questionoptions!{
                            questionOption.order_number = orderId!
                            questionOption.main_question_id = questionId
                            if (questionOption.option_value.contains("Equipment violation") && options.option_value.contains("4000(A)")) || (questionOption.option_value.contains("Non-moving") && options.option_value.contains("5200")){
                              //  questionOption.isSelected = true
                            }
                        }
                    }
                }
            }
            
            if questionArray![questNumber!].question_code == "14"{
                addToPreSelectedViolArr(indexPath:indexPath!)
            }
            
            if hasVal == true{
                checkForSingleSelection(index : indexPath!)
            }
            
            optionsArray![indexPath!].order_number = orderId!
            optionsArray![indexPath!].mainQuestOrder = orderId!
            for options in optionsArray![indexPath!].questionoptions!{
                options.order_number = orderId!
                options.mainQuestOrder = orderId!
            }
            
        }
        else{
            if listType == "City or Unincorporated Area"{
                if let defaultCity = (UserDefaults.standard.object(forKey: "DefaultCity") as? [String : Any]){
                    if (defaultCity["City or Unincorporated Area"] as! String) != ""{
                        AppConstants.city = defaultCity["City or Unincorporated Area"] as! String
                        cityID = defaultCity["Id"] as! String
                    }
                }
                questionID = Int(optionsArray![0].cascade_ripa_id)!
                let question = newRipaViewModel.getCascadeQuestionUsingId(questionID: questionID ?? 0)
              //  setLocationObj(list: list, listType: listType)
                option = getLocationObj(list: list, listType: listType)
                question.questionoptions!.append(setMainQuestIdAndOptn(optn: option as! Questionoptions1))
            }
            else if listType == "Location"{
                questionID = Int(optionsArray![1].cascade_ripa_id)!
                let question = newRipaViewModel.getCascadeQuestionUsingId(questionID: questionID ?? 0)
                option = getLocationObj(list: list, listType: listType)
                question.questionoptions!.append(setMainQuestIdAndOptn(optn: option as! Questionoptions1))
            }
            else if listType == "Street"{
                questionID = Int(optionsArray![1].cascade_ripa_id)!
                let question = newRipaViewModel.getCascadeQuestionUsingId(questionID: questionID ?? 0)
                option = getLocationObj(list: list, listType: listType)
                question.questionoptions!.append(setMainQuestIdAndOptn(optn: option as! Questionoptions1))
                
            }
            else if listType == "Highway"{
                optionsArray![1].questionoptions?.forEach({
                    $0.isSelected = false
                })
                questionID = Int(optionsArray![3].cascade_ripa_id)!
                let question = newRipaViewModel.getCascadeQuestionUsingId(questionID: questionID ?? 0)
                option = getLocationObj(list: list, listType: listType)
                question.questionoptions!.append(setMainQuestIdAndOptn(optn: option as! Questionoptions1))
            }
            else if listType == "Closest Highway Exit"{
                questionID = Int(optionsArray![3].cascade_ripa_id)!
                let question = newRipaViewModel.getCascadeQuestionUsingId(questionID: questionID ?? 0)
                option = getLocationObj(list: list, listType: listType)
                question.questionoptions!.append(setMainQuestIdAndOptn(optn: option as! Questionoptions1))
            }
            else if listType == "School"{
                if optionsArray![2].questionoptions?.count == 0 {
                    optionsArray![2].questionoptions = self.createSchoolOption()
                }
                questionID = Int(optionsArray![2].questionoptions![0].cascade_ripa_id)!
                let question = newRipaViewModel.getCascadeQuestionUsingId(questionID: questionID ?? 0)
                option = getLocationObj(list: list, listType: listType)
                let objj = self.setMainQuestIdAndOptn(optn: option as! Questionoptions1)
                if question.questionoptions?.count == 1 {
                    question.questionoptions!.append(objj)
                }
                else {
                    question.questionoptions?[1] = objj
                }
                if questionArray![questNumber!].question_code == "5" && ((viewType != "StartNewRipa" && AppConstants.status != "LastRipa" && AppConstants.status != "Template") || AppConstants.isTemplate == "temp") && personArray.count > 0 {
                    var personDict = personArray[personcount]
                    var selectedOption = personDict["SelectedOption"] as! [[Questionoptions1]]
                    let firstIndex = selectedOption[0].firstIndex(where: {$0.ripa_id == "26"})
                    if firstIndex != nil {
                        selectedOption[0].remove(at: firstIndex!)
                    }
                    objj.option_id = "3"
                    objj.ripa_id = "26"
                    objj.main_question_id = "61"
                    selectedOption[0].append(objj)
                    personDict["SelectedOption"] = selectedOption
                    personArray[personcount] = personDict
                }
            }
            else if listType == "First Intersection"{
                optionsArray![1].questionoptions?.forEach({
                    $0.isSelected = false
                })
                questionID = Int(optionsArray![2].cascade_ripa_id)!
                let question = newRipaViewModel.getCascadeQuestionUsingId(questionID: questionID ?? 0)
                option = getLocationObj(list: list, listType: listType)
                question.questionoptions!.append(setMainQuestIdAndOptn(optn: option as! Questionoptions1))
                
                if AppConstants.firstIntersection.count > 0 && AppConstants.secondIntersection.count == 0 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.openList(index: 13)
                    }
                }
            }
            else if listType == "Second Intersection"{
                questionID = Int(optionsArray![2].cascade_ripa_id)!
                let question = newRipaViewModel.getCascadeQuestionUsingId(questionID: questionID ?? 0)
                option = getLocationObj(list: list, listType: listType)
                question.questionoptions!.append(setMainQuestIdAndOptn(optn: option as! Questionoptions1))
            }
        }
       
        let question = newRipaViewModel.getCascadeQuestionUsingId(questionID: questionID ?? 0)
        if  listType != "EducationSubCode" && questionArray![questNumber!].question_code != "5"{
            question.questionoptions!.removeAll()
        }

        if listType == "ViolationType"{
            question.questionoptions = violationTypeArray
            optionsArray![indexPath!].isSelected = hasVal
        }
        else if  listType == "EducationSubCode"{
            question.questionoptions?.append(option as! Questionoptions1)
        }
        else if listType != "Violation" && listType != "EducationCode" && questionArray![questNumber!].question_code != "5"{
            option = getLocationObj(list: list, listType: listType)
            question.questionoptions!.append(setMainQuestIdAndOptn(optn: option as! Questionoptions1))
            if questionArray![questNumber!].question_code == "5" && locTypeIndex == 2 && AppConstants.firstIntersection.count > 0 && AppConstants.secondIntersection.count == 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.openList(index: 13)
                }
            }
        }
        else if questionArray![questNumber!].question_code != "5"{
            print(selectedViolationArray.count)
            question.questionoptions = selectedViolationArray
        }
        question.order_number = orderId!
        
        if educationCodeId == "1"{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.openEducationSubCodeList()
            }
        }
       
        cascadeArray.removeAll()
        checkMandatorySelection()
        tableView.reloadData()
       
        if listType == "Violation" && questionArray![questNumber!].question_code == "14" {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                let violnBtn = UIButton ()
                violnBtn.tag = self.indexPath!
                var cascadeQuestion:QuestionResult1?
                print(questionID)
                if questionID == 20 || questionID == 17 {
                    cascadeQuestion = self.newRipaViewModel.getCascadeQuestionUsingId(questionID: 16)
                    if cascadeQuestion?.questionoptions?.count == 0 {
                        cascadeQuestion!.questionoptions = self.newRipaViewModel.setviolationType()
                    }
                    self.cascadeDict = ["QuestionTag":9,"QuestionRow":1,"ViolationTypeArray":cascadeQuestion!.questionoptions!,"QuestionTypeCode": "SC"]
                    //setviolationOrder()
                    self.cascadeArray.append(self.cascadeDict!)
                    if self.isOffenceCode == true && AppConstants.violation_type == "1" {
                        self.openViolationTypeList(sender: violnBtn)
                        self.isOffenceCode = false
                    }
                    else if AppConstants.violation_type != "1" {
                        self.openViolationTypeList(sender: violnBtn)
                    }
                }
            }
            
           // AppConstants.violation_type = ""
        }
        
    }
    
 
    func resetLocation(onGPS:Bool){
        if onGPS == false{
            removeOptFromCascade(index: 1)
            removeOptFromCascade(index: 3)
        }
        removeOptFromCascade(index: 2)
        removeOptFromCascade(index: 5)
        
//        optionsArray![4].isSelected = false
//        optionsArray![4].isExpanded = false
//        if optionsArray![4].questionoptions?.count ?? 0 > 0 {
//            optionsArray![4].questionoptions![0].isSelected = false
//            optionsArray![4].questionoptions![1].isSelected = false
//        }
       
        AppConstants.isSchoolSelected = ""
        AppConstants.schoolName = ""
        resetIsK12Options()
        is_k12 = false
        AppConstants.isStudent = "0"
    }
    
   
    func getLocationObj(list:[Any]?, listType: String)->Questionoptions1{
        var option:Questionoptions1?
        for listObj in list! {
            if listType == "City or Unincorporated Area"{
                if (listObj as! CityResult).isSelected{
                    option = newRipaViewModel.createObj(mainQuestId: questionId, ripaID: optionsArray![0].cascade_ripa_id, optionValue: (listObj as! CityResult).city_name, physical_attribute: "", description: "", isSelected: true, mainQuestOrder: orderId!, isNewAdded: false, mainId: vioQuestionId)
                    if cityID != (listObj as! CityResult).city_id{
                        resetLocation(onGPS: false)
                    }
                    
                    AppConstants.street = ""
                    AppConstants.block = ""
                    AppConstants.highway = ""
                    AppConstants.closestHighway = ""
                    AppConstants.firstIntersection = ""
                    AppConstants.secondIntersection = ""
                    
                    cityID = (listObj as! CityResult).city_id
                    print(cityID)
                    // ripaActivity?.City = (listObj as! CityResult).city_name
                    AppConstants.city = (listObj as! CityResult).city_name
            
                    option = setMainQuestIdAndOptn(optn: option!)
                }
            }
            if listType == "Location" || listType == "First Intersection" || listType == "Second Intersection" || listType == "Street" || listType == "Highway" || listType == "Closest Highway Exit"{
                var ripaId = optionsArray![1].cascade_ripa_id
                
                if (listObj as! LocationResult).isSelected{
                    if listType == "Location"{
                        streetName = (listObj as! LocationResult).location
                    }
                    if listType == "First Intersection" || listType == "Second Intersection"{
                      
                         if optionsArray?[1].questionoptions?.count ?? 0 > 1, let ripID = optionsArray?[1].questionoptions?[2].cascade_ripa_id {
                             ripaId = ripID
                         }
                         else {
                             ripaId = "121"
                         }
                        
                        intersectionName = (listObj as! LocationResult).location
                        if locTypeRow == 12 {
                            AppConstants.firstIntersection = (listObj as! LocationResult).location
                        }
                        else {
                            AppConstants.secondIntersection = (listObj as! LocationResult).location
                        }
                        AppConstants.street = ""
                        AppConstants.highway = ""
                        AppConstants.closestHighway = ""
                        AppConstants.address = String(format: "%@ & %@", AppConstants.firstIntersection,AppConstants.secondIntersection)
                        option = newRipaViewModel.createObj(mainQuestId: questionId, ripaID: ripaId,optionValue: (listObj as! LocationResult).location, physical_attribute: "", description: "", isSelected: true, mainQuestOrder: orderId!, isNewAdded: false, mainId: vioQuestionId)
                        option = setMainQuestIdAndOptn(optn: option!)
                    }
                    else if listType == "Highway"{
                        ripaId = optionsArray![1].questionoptions![3].cascade_ripa_id
                        AppConstants.highway = (listObj as! LocationResult).location
                        AppConstants.address = String(format: "%@ & %@", AppConstants.highway,AppConstants.closestHighway)
  
                        option = newRipaViewModel.createObj(mainQuestId: questionId, ripaID: ripaId,optionValue: (listObj as! LocationResult).location, physical_attribute: "", description: "", isSelected: true, mainQuestOrder: orderId!, isNewAdded: false, mainId: vioQuestionId)
                        option = setMainQuestIdAndOptn(optn: option!)
                    }
                    else if listType == "Closest Highway Exit"{
                        ripaId = optionsArray![1].questionoptions![3].cascade_ripa_id
                        AppConstants.closestHighway = (listObj as! LocationResult).location
                        AppConstants.address = String(format: "%@ & %@", AppConstants.highway,AppConstants.closestHighway)
                        
                        option = newRipaViewModel.createObj(mainQuestId: questionId, ripaID: ripaId,optionValue: (listObj as! LocationResult).location, physical_attribute: "", description: "", isSelected: true, mainQuestOrder: orderId!, isNewAdded: false, mainId: vioQuestionId)
                        option = setMainQuestIdAndOptn(optn: option!)
                    }
                    else if listType == "Street"{
                        if optionsArray?[1].questionoptions?.count ?? 0 > 1, let ripID = optionsArray?[1].questionoptions?[1].cascade_ripa_id {
                            ripaId = ripID
                        }
                        else {
                            ripaId = "120"
                        }
                       
                        AppConstants.street = (listObj as! LocationResult).location
                        AppConstants.address = AppConstants.street
                        AppConstants.address = String(format: "%@ & %@", AppConstants.block,AppConstants.street)
                        
                        option = newRipaViewModel.createObj(mainQuestId: questionId, ripaID: ripaId,optionValue: (listObj as! LocationResult).location, physical_attribute: "", description: "", isSelected: true, mainQuestOrder: orderId!, isNewAdded: false, mainId: vioQuestionId)
                       
                        option = setMainQuestIdAndOptn(optn: option!)
                    }
                }
            }
            if listType == "School"{
                if (listObj as! SchoolResult).isSelected{
                    AppConstants.schoolName = (listObj as! SchoolResult).school
                    option = newRipaViewModel.createObj(mainQuestId: questionId, ripaID: optionsArray![3].cascade_ripa_id,optionValue: (listObj as! SchoolResult).school, physical_attribute: "", description: (listObj as! SchoolResult).cdsCode , isSelected: true, mainQuestOrder: orderId!, isNewAdded: false, mainId: vioQuestionId)
                 }
            }
        }
        
        return option!
    }
    
    
    func consensualEncounter()->Bool{
        var conducted = true
        if questionArray![questNumber!].question_code == "T7"{
            let question = newRipaViewModel.getQuestionUsingQuestionCode(question_code: 14)
            for option in question.questionoptions!{
                if option.physical_attribute == "6" && option.isSelected == true{
                    conducted = false
                    for option in optionsArray!{
                        if (option.physical_attribute == "14" || option.physical_attribute == "15") && option.isSelected{
                            conducted = true
                            return conducted
                     }
                   }
                }
            }
        }
        return conducted
    }
    
    func consensualEncounterAtSubmitting()->Bool{
        var conducted = true
        for questions in questionArray!{
            if questions.question_code == "T7"{
                let question = newRipaViewModel.getQuestionUsingQuestionCode(question_code: 14)
                for option in question.questionoptions!{
                    if option.physical_attribute == "6" && option.isSelected == true{
                        conducted = false
                        for option in optionsArray!{
                            if (option.physical_attribute == "18" || option.physical_attribute == "15") && option.isSelected{
                                conducted = true
                                return conducted
                            }
                        }
                    }
                }
            }
        }
        return conducted
    }
    
    
    
    @objc func selectOption(sender: UIButton){
        trackApplicationTime()
        let physicalAttribute = optionsArray![sender.tag].physical_attribute
        
        if self.questionArray![self.questNumber!].question_code == "14" {
                   self.isClearViolations = true
                   let btn = UIButton()
                   btn.tag = sender.tag
                   self.dltAllViol(sender: btn)
               
               let quest = self.getViolQuest(section:sender.tag)
               quest.questionoptions?.removeAll()
               
               self.optionsArray!.forEach({$0.isSelected = false})
               self.optionsArray!.forEach({$0.isExpanded = false})
               self.disableNextButton(View: self.nextView)
               self.tableView.reloadData()
           }
       
        if questionArray![questNumber!].is_required != "1" {
            if questionArray![questNumber!].question_code == "17" {
                AppUtility.showAlertWithProperty("Alert", messageString: "Question is not required to provide answer. If required then select Search of person and/or property conducted options(s) of Action Taken by Officer During Stop.")
                return
            }
            else if questionArray![questNumber!].question_code == "19" || questionArray![questNumber!].question_code == "20"{
                AppUtility.showAlertWithProperty("Alert", messageString: "Question is not required to provide answer. If required then select Property was seized option of Action Taken by Officer During Stop.")
            }
        }
        else {
        if questionArray![questNumber!].question_code == "19" && (physicalAttribute == "2" || physicalAttribute == "3"){
            let question = newRipaViewModel.getQuestionUsingQuestionCode(question_code: 18)
            for option in question.questionoptions!{
                if option.physical_attribute == "1" && option.isSelected{
                    AppUtility.showAlertWithProperty("Alert", messageString: "NONE was selected for Contraband or Evidence Discovered. Cannot select them for this question.")
                    return
                }
            }
         }

            
        if questionArray![questNumber!].question_code == "18" && (physicalAttribute == "1"){
            let question = newRipaViewModel.getQuestionUsingQuestionCode(question_code: 19)
            for option in question.questionoptions!{
                if (option.physical_attribute == "2" || option.physical_attribute == "3") && option.isSelected{
                    AppUtility.showAlertWithProperty("Alert", messageString: "Evidence or Contraband option was selected for Basis for Property Seizure. NONE cannot be used at this time.")
                    return
                }
            }
         }
        
        
        if questionArray![questNumber!].question_code == "17" && physicalAttribute == "12"{
            let question = newRipaViewModel.getQuestionUsingQuestionCodeUsingString(question_code: "T7")
            for option in question.questionoptions!{
              if option.physical_attribute == "15" && !option.isSelected{
                    AppUtility.showAlertWithProperty("Alert", messageString: "Search of Property was not selected as an option for Action Taken by Officer During Stop. Cannot select Vehicle Inventory option for this question.")
                    return
                }
            }
         }
        
            
        if questionArray![questNumber!].question_code == "14" && physicalAttribute == "6"{
            let question = newRipaViewModel.getQuestionUsingQuestionCode(question_code: 16)
            for option in question.questionoptions!{
                if option.physical_attribute == "24" && option.isSelected{
                    option.isSelected = false
                }
            }
         }
           
            
         if questionArray![questNumber!].question_code == "T8" && physicalAttribute == "18"{
                let question = newRipaViewModel.getQuestionUsingQuestionCodeUsingString(question_code: "T8")
                for option in question.questionoptions!{
                    if option.physical_attribute != "18"{
                        option.isSelected = false
                    }
                }
         }
         else  if questionArray![questNumber!].question_code == "T8" && physicalAttribute != "18"{
                let question = newRipaViewModel.getQuestionUsingQuestionCodeUsingString(question_code: "T8")
                for option in question.questionoptions!{
                    if option.physical_attribute == "18"{
                        option.isSelected = false
                    }
             }
         }
            
            if questionArray![questNumber!].question_code == "T7" && physicalAttribute == "18"{
                   let question = newRipaViewModel.getQuestionUsingQuestionCodeUsingString(question_code: "T7")
                  //(optionsArray![section].questionoptions![row] ).isSelected
                   for option in question.questionoptions!{
                       if option.physical_attribute != "18"{
                           option.isSelected = false
                           self.disableNextButton(View: nextView)
                           for subOption in option.questionoptions!{
                               subOption.isSelected = false
                               option.isExpanded = false
                           }
                       }
                   }
            }
            else  if questionArray![questNumber!].question_code == "T7" && (physicalAttribute == "13" || physicalAttribute == "4"){
                if self.checkForTypeOfVehicleStop() {
                    let question = newRipaViewModel.getQuestionUsingQuestionCodeUsingString(question_code: "T7")
                    for option in question.questionoptions!{
                        if option.physical_attribute == "18"{
                            option.isSelected = false
                        }
                   }
                }
                else {
                    AppUtility.showAlertWithProperty("Alert", messageString: "You can't select \"Asked for identification of stopped person's passenger\" && \"Ran name of stopped person's passenger\" options ")
                    return
                }
            }
            else  if questionArray![questNumber!].question_code == "T7" && physicalAttribute != "18"{
                   let question = newRipaViewModel.getQuestionUsingQuestionCodeUsingString(question_code: "T7")
                   for option in question.questionoptions!{
                       if option.physical_attribute == "18"{
                           option.isSelected = false
                       }
                }
            }
        
          let obt = self.optionsArray
    
       checkForSingleSelection(index: sender.tag)
        addAssignmentOfOfficer(index: sender.tag)
        checkMandatorySelection()
        checkDependentQuestions()
            
            if questionArray![questNumber!].question_code == "21" && physicalAttribute == "1"{
                let selectedItems = self.optionsArray!.filter {
                    $0.isSelected == true
                }
                if selectedItems.count > 0 {
                    self.createClearDataForResultStop(index : sender.tag)
                }
                else {
                    optionsArray![sender.tag].isSelected = !optionsArray![sender.tag].isSelected
                }
            }
            else  if questionArray![questNumber!].question_code == "21" && physicalAttribute != "1"{
                if let row = optionsArray?.firstIndex(where: {$0.physical_attribute == "1"}) {
                    optionsArray?[row].isSelected = false
                }
                optionsArray![sender.tag].isSelected = !optionsArray![sender.tag].isSelected
            }
       
        if questionArray![questNumber!].question_code == "T7" && (physicalAttribute == "14" || physicalAttribute == "15"){
            DispatchQueue.background(delay: 0.3, completion:{ [self] in
                openViolationPopup(index: sender.tag, popupFor: "Consent")
            })
            if physicalAttribute == "15" && optionsArray![sender.tag].isSelected == false{
                let question = newRipaViewModel.getQuestionUsingQuestionCode(question_code: 17)
                for option in question.questionoptions!{
                    if option.physical_attribute == "12"{
                        option.isSelected = false
                    }
                }
            }
        }
            
        if questionArray![questNumber!].question_code == "T7" && physicalAttribute == "18"{
            self.optionsArray![sender.tag].isSelected = !self.optionsArray![sender.tag].isSelected
            for row in 0..<self.optionsArray!.count {
                if sender.tag != row {
                    self.optionsArray![row].isSelected = false
                }
            }
        }
       
            
      if questionArray![questNumber!].question_code == "T7" {
          if physicalAttribute == "12" {
              if optionsArray![sender.tag].isSelected{
                 var question = newRipaViewModel.getQuestionUsingQuestionCode(question_code: 19)
                  question.is_required = "1"
                  question = newRipaViewModel.getQuestionUsingQuestionCode(question_code: 20)
                  question.is_required = "1"
               }
              else{
                  var question = newRipaViewModel.getQuestionUsingQuestionCode(question_code: 19)
                   question.is_required = "0"
                   question = newRipaViewModel.getQuestionUsingQuestionCode(question_code: 20)
                   question.is_required = "0"
              }
          }
          else {
              for i in (0 ..< (questionArray?.count ?? 0)) {
                  if (questionArray?[i].question_code == "19" || questionArray?[i].question_code == "20") && physicalAttribute == "18"{
                      questionArray?[i].is_required = "0"
                  }
              }
          }
          
          if physicalAttribute == "18" {
              optionsArray![sender.tag].isSelected = true
          }
      }

     }
        
        if questionArray![questNumber!].question_code == "T7"{
            let selectItem = optionsArray?.filter({
                $0.isSelected == true && $0.option_value == "None"
            })
            if selectItem?.count ?? 0 > 0 {
                self.enableNextButton(View: nextView)
            }
        }
        else if questionArray![questNumber!].question_code == "14",let obj = optionsArray?.filter({$0.isSelected == true}),obj.count > 0,obj.count == 1,obj[0].tag == "Description"{
            self.disableNextButton(View: nextView)
        }
        
       if questionArray![questNumber!].question_code == "17" && self.descriptionStr.count > 1{
         self.descriptionBtn.isHidden = true
       }
        
        
    }
    
    func createClearDataForResultStop(index : Int) {
        let alert = UIAlertController(title: "Alert", message: "Previously selected options will be cleared.", preferredStyle: .alert)
            
             let ok = UIAlertAction(title: "CANCEL", style: .default, handler: { action in
                
             })
        
             let cancel = UIAlertAction(title: "OK", style: .default, handler: { action in
                 self.cleareAllResultOfStopData(index : index)
             })
             alert.addAction(cancel)
             alert.addAction(ok)
             DispatchQueue.main.async(execute: {
                self.present(alert, animated: true)
        })
        
    }
    
    func cleareAllResultOfStopData(index : Int) {
        optionsArray?.forEach({
            $0.isSelected = false
        })
        
        let quest = getViolQuest(section:1)
        quest.questionoptions?.removeAll()
        
        addToPreSelectedViolArr(indexPath:index)
       
         selectedVioArray.removeAll()
            selectedViolationArray2.removeAll()
                for i in (0 ..< (optionsArray?.count ?? 0)) {
                    optionsArray![i].isSelected = false
                    optionsArray![i].isExpanded = false
                }
        
        if indexPath != nil {
            checkForSingleSelection(index : indexPath!)
        }
        
        if questionArray![questNumber!].question_code == "21",((viewType != "StartNewRipa" && AppConstants.status != "LastRipa" && AppConstants.status != "Template" && saveRipaStatus != "Created") || AppConstants.isTemplate == "temp") {
            var personDict = personArray[personcount]
            var selectedOption = personDict["SelectedOption"] as! [[Questionoptions1]]
            selectedOption[12].removeAll()
            selectedOption[12].append(optionsArray![index])
            personDict["SelectedOption"] = selectedOption
            personArray[personcount] = personDict
        }
        
        optionsArray![index].isSelected = true
        tableView.reloadData()
        
    }
    
    func checkForTypeOfVehicleStop() -> Bool {
        let optArry = questionArray![1].questionoptions!
        for option in optArry{
            if option.question_code_for_cascading_id == "C43",var obj = option.questionoptions{
                if obj.isEmpty {
                    obj = newRipaViewModel.createStopInformationOption()
                }
                for subObj in obj{
                    print(subObj.option_value)
                    if subObj.physical_attribute == "1" && subObj.isSelected{
                        return true
                    }
                }
            }
        }
        return false
    }
    
    func checkForTypeOfStopPedestrain() -> Bool {
        let optArry = questionArray![1].questionoptions!
        for option in optArry{
            if option.question_code_for_cascading_id == "C43",let obj = option.questionoptions{
                for subObj in obj{
                    if subObj.physical_attribute == "3" && subObj.isSelected {
                        return true
                    }
                }
            }
        }
        return false
    }
    
    
    func addAssignmentOfOfficer(index:Int){
        if questionArray![questNumber!].question_code == "23"{
            defaults.set(optionsArray![index].option_value, forKey: "OptionValue")
            defaults.synchronize()
        }
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        trackApplicationTime()
        super.touchesEnded(touches , with: event)
    }
    
    func trackApplicationTime(){
        AppConstants.applicationtime = String(Int(AppConstants.applicationtime) ?? 0 + MyGlobalTimer.sharedTimer.time)
        MyGlobalTimer.sharedTimer.stopTimer()
        MyGlobalTimer.sharedTimer.startTimer()
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isDragging {
            trackApplicationTime()
            
        }
    }
    
    
    func addViolationForResultOfStop(section:Int)->Bool{
        var addOptns = false
        if questionArray![questNumber!].question_code == "21"{
            let optionVal = optionsArray![section].option_value
            // let optionId = optionsArray![section].option_id
            let physicalAttribute = optionsArray![section].physical_attribute
            if physicalAttribute == "6" && optionsArray![section].questionoptions?.count == 0 {
                optionsArray![section].questionoptions?.append(newRipaViewModel.createCustodialArrestWithoutWarrantObject())
            }
            else if physicalAttribute == "4" && optionsArray![section].questionoptions?.count == 0 {
                optionsArray![section].questionoptions?.append(newRipaViewModel.createInfieldOptionObject())
            }
            else if physicalAttribute == "14" && optionsArray![section].questionoptions?.count == 0 {
                optionsArray![section].questionoptions?.append(newRipaViewModel.createVerbalWarningObject())
            }
           
            let questionId = Int((optionsArray![section].questionoptions![0]).cascade_ripa_id)
           
            var question:QuestionResult1?
            let viol = (violationDict?["ViolationList"] as? [Questionoptions1]) ?? []
            if  viol.count < 1{
                violationDict?["ViolationList"] = selectedViolationArray2
            }
            
            //violationDict = ["ViolationFor":ViolationFor, "optionID": optionId ,"ViolationList": selectedViolationArray]
            if let violationList:[Questionoptions1] = violationDict?["ViolationList"] as? [Questionoptions1]{
                let ViolationFor:String? = violationDict!["ViolationFor"] as? String
                
                //    if violationList != nil{
                if ViolationFor!.contains("Traffic") && questionId != 0{
                    if optionVal.contains("Warning") || physicalAttribute == "2" {
                        question = newRipaViewModel.getCascadeQuestionUsingId(questionID: questionId!)
                        addOptns = true
                    }
                    else if optionVal.contains("Citation") || physicalAttribute == "3"{
                        question = newRipaViewModel.getCascadeQuestionUsingId(questionID: questionId!)
                        if AppConstants.status == "Created" || AppConstants.status == "Saved"{
                            question?.questionoptions?.removeAll()
                        }
                        addOptns = true
                    }
                }
                else {
                    if optionVal.contains("Custodial arrest") || physicalAttribute == "6" {
                        question = newRipaViewModel.getCascadeQuestionUsingId(questionID: questionId!)
                        addOptns = true
                    }
                }
                
                if question?.questionoptions!.count ?? 2 < 1 && addOptns{
                    var optionList = [Questionoptions1]()
                    for viol in violationList{
                        
                        let option = newRipaViewModel.createObj(mainQuestId: self.questionId, ripaID: question!.id, optionValue: viol.option_value, physical_attribute: viol.physical_attribute, description: viol.optionDescription, isSelected: true, mainQuestOrder: orderId!, isNewAdded: false, mainId: vioQuestionId)
                        if AppConstants.status == "Created" || AppConstants.status == "Saved"{
                            var personDict = personArray[personcount]
                            var selectedOptArray = personDict["SelectedOption"] as! [[Questionoptions1]]
                            if selectedOptArray.count > 12 , selectedOptArray[12].count > 2 {
                                selectedOptArray[12].insert(option, at: 2)
                            }
                            else {
                                selectedOptArray[12].append(option)
                            }
                            personDict["SelectedOption"] = selectedOptArray
                            personArray[personcount] = personDict
                        }
                        optionList.append(option)
                    }
                    question?.questionoptions = optionList
                    optionsArray![section].questionoptions![0].isSelected = true
                    
                    return true
                }
                //      }
            }
        }
        return false
    }
    
    
    func addViolationForReasonForStop(section:Int)->Bool{
        if questionArray![questNumber!].question_code == "14" && optionsArray![section].questionoptions?.count ?? 0 > 0{
            
            var questionId = Int((optionsArray![section].questionoptions![0]).cascade_ripa_id)
            if (optionsArray![section].questionoptions![0]).cascade_ripa_id.count == 0 {
                questionId = 20
            }
            let sfddg = optionsArray![section]
            var question:QuestionResult1?
            let violationList:[Questionoptions1] = selectedViolationArray2
            question = newRipaViewModel.getCascadeQuestionUsingId(questionID: questionId!)
            if question?.questionoptions!.count ?? 2 < 1{
                if violationList.count > 0 {
                    violationDict = ["ViolationFor":"Traffic", "optionID": "" ,"ViolationList": violationList]
                    var optionList = [Questionoptions1]()
                    for viol in violationList{
                        let option = newRipaViewModel.createObj(mainQuestId: self.questionId, ripaID: question!.id, optionValue: viol.option_value, physical_attribute: viol.physical_attribute, description: viol.optionDescription, isSelected: true, mainQuestOrder: orderId!, isNewAdded: false, mainId: vioQuestionId)
                        
                        optionList.append(option)
                    }
                    question?.questionoptions = optionList
                    optionsArray![section].questionoptions![0].isSelected = true
                    
                    return true
                }
            }
        }
        return false
    }
   
    @objc  private func hideLocationSection(sender: UIButton) {
       // let section = sender.tag
        self.view.endEditing(true)
        locTypeIndex = 0
        optionsArray![sender.tag].isExpanded  =  !optionsArray![sender.tag].isExpanded
        self.tableView.reloadData()
    }
    
    @objc  private func hideSection(sender: UIButton) {
        let section = sender.tag
        var addOptns = false
        trackApplicationTime()
        
        //=> This condition For checking ConsentGiven is selected or Not in Non-Force-Related Actions Taken
       
        if questionArray![questNumber!].question_code == "17" && self.checkForNonForceConsentSelectedOrNot() && optionsArray![sender.tag].question_code_for_cascading_id == "C47" {
            AppUtility.showAlertWithProperty("", messageString: "Please select another Non-Force-Related Actions Taken.")
            return
        }
        
        if questionArray![questNumber!].question_code == "17" && viewType  != "StartNewRipa",personcount < personArray.count{
            let personDict = personArray[personcount]
            let selectedOption = personDict["SelectedOption"] as! [[Questionoptions1]]
            if selectedOption.count > 7 {
                var checkConsent : Bool = false
                for subObj in selectedOption[7] {
                    if subObj.option_id == "145" && subObj.isSelected == true{
                        checkConsent =  true
                    }
                    else if subObj.option_id == "143" && subObj.isSelected == true{
                        checkConsent =  true
                    }
                }
                if checkConsent == true {
                    AppUtility.showAlertWithProperty("", messageString: "Please select another Non-Force-Related Actions Taken.")
                    return
                }
            }
        }
        
        if questionArray![questNumber!].question_code == "T5" {
            return
        }
        
        if questionArray![questNumber!].question_code == "17"{
            let checkConsent = checkForConsentWillSelectOrNot()
            if checkConsent == true {
                return
            }
         }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            for i in 0..<self.optionsArray!.count {
                if i != sender.tag {
                  //  self.optionsArray![i].isExpanded =  false
                  //  self.optionsArray![i].isSelected =  false
                }
            }
            if self.questionArray![self.questNumber!].question_code == "14" &&  self.optionsArray![section].physical_attribute != "1" {
                    self.isClearViolations = true
                    let btn = UIButton()
                    btn.tag = sender.tag
                    self.dltAllViol(sender: btn)
            }
            
            if self.questionArray![self.questNumber!].question_code != "21" {
                let quest = self.getViolQuest(section:section)
                quest.questionoptions?.removeAll()
            }
           
            if self.questionArray![self.questNumber!].question_code == "14" {
                self.optionsArray!.forEach({$0.isSelected = false})
                for i in 0..<self.optionsArray!.count {
                    if i != sender.tag {
                        self.optionsArray![i].isExpanded =  false
                    }
                }
                self.disableNextButton(View: self.nextView)
            }
            self.tableView.reloadData()
        }
        
          optionsArray![sender.tag].isExpanded  =  !optionsArray![sender.tag].isExpanded
        
            func indexPathsForSection() -> [IndexPath] {
                var indexPaths = [IndexPath]()
                
                for row in 0..<self.optionsArray![section].questionoptions!.count {
                    indexPaths.append(IndexPath(row: row, section: section))
                }
                return indexPaths
            }
        
        if optionsArray![section].isExpanded{
            if questionArray![questNumber!].question_code == "21"  {
                print(questionArray![questNumber!].question_code)
                vioQuestionId = optionsArray![sender.tag].mainQuestId
                addOptns = addViolationForResultOfStop(section:section)
                if optionsArray![section].physical_attribute != "1" {
                    let index = optionsArray?.firstIndex(where: {
                        $0.isSelected == true && $0.physical_attribute == "1"
                    })
                    optionsArray![index ?? 0].isSelected = false
                }
            }
            
            if questionArray![questNumber!].question_code == "14" &&  optionsArray![section].physical_attribute == "1" {
                addOptns = addViolationForReasonForStop(section:section)
                DispatchQueue.main.async(execute: {
                    let btn = UIButton()
                    btn.tag = sender.tag
                    self.openViolationList(sender: btn)
                })
            }
            
            self.hiddenSections.remove(section)
            self.tableView.insertRows(at: indexPathsForSection(),
                                      with: .fade)
            if addOptns{
                // optionsArray![0].isSelected = false
                optionsArray![section].isSelected = false
                checkForSingleSelection(index: section)
            }
        }
        else{
            optionsArray![sender.tag].isExpanded = false
            if self.hiddenSections.count > 0 {
                self.hiddenSections.insert(section)
                self.tableView.deleteRows(at: indexPathsForSection(),
                                          with: .fade)
            }
        }

        if !addOptns{
            if questionArray![questNumber!].question_code == "21"  {
              //  removeSelectedResultOfStopData(index: sender.tag)
            }
            optionsArray![sender.tag].isSelected = false
            tableView.reloadSections(IndexSet(integer: section), with: .none)
        }
        
    }
    
    
    func removeSelectedResultOfStopData(index : Int) {
        let quest = getViolQuest(section:index)
        quest.questionoptions?.removeAll()
        checkForSingleSelection(index : indexPath!)
    }
    
    
  func checkForNonForceConsentSelectedOrNot() -> Bool {
          let question = newRipaViewModel.getQuestionUsingQuestionCodeUsingString(question_code: "T7")
          let optionT7 = question.questionoptions!
          for obj in optionT7 {
              if obj.question_code_for_cascading_id == "C13" || obj.question_code_for_cascading_id == "C14" {
                  let consentOpt = obj.questionoptions!
                  for subObj in consentOpt {
                      if subObj.option_id == "145" && subObj.isSelected == true{
                          return true
                      }
                      else if subObj.option_id == "143" && subObj.isSelected == true{
                          return true
                      }
                  }
              }
          }
      return false
  }
    
    func checkForConsentWillSelectOrNot() -> Bool {
            let question = newRipaViewModel.getQuestionUsingQuestionCodeUsingString(question_code: "T7")
            let optionT7 = question.questionoptions!
            for obj in optionT7 {
                if (obj.physical_attribute == "2" && obj.isSelected == true) || obj.physical_attribute == "3" && obj.isSelected == true {
                    let consentOpt = obj.questionoptions!
                    for subObj in consentOpt {
                        if subObj.option_value.lowercased() == "consent given" && subObj.isSelected == true{
                            return true
                        }
                    }
                }
            }
        return false
    }
    
    
}



extension NewRipaViewController:GPSLocationDelegate{
    
    @objc func getCityFromGPS(sender: UIButton){
    
            gpsLocation.delegate = self
            gpsLocation.getGPSLocation()
   
    }
    
    
    func fetchedLocationDetails(location: CLLocation, countryCode: String, city: String, street: String, intersection:String ,county: String) {
        print(location,countryCode,city)
        
        var countyFound:Bool = false
        var cityFound:Bool = false
        var tempCountyId:String?
        
        let cityList = newRipaViewModel.getCities()
        
        for counti in countyList{
            if (counti.countyName).lowercased() == (county).lowercased() && AppConstants.ripaCounty == "Y"{
                countyFound = true
                tempCountyId = counti.countyID
            }
        }
        
        if countyFound == true || AppConstants.ripaCounty == "N"{
            for citi in cityList{
                if ((citi.city_name).lowercased().contains((city).lowercased())) {
                  /* if cityID == citi.city_id {
                        AppUtility.showAlertWithProperty("Alert", messageString: "City already selected.")
                        return
                    } */
                    
                    let cityQuest = newRipaViewModel.getCascadeQuestionUsingQuestionCode(questionCode: "C6")
                    cityQuest.questionoptions!.removeAll()
                    let obj = newRipaViewModel.createObj(mainQuestId: questionId, ripaID: cityQuest.id, optionValue: citi.city_name, physical_attribute: "", description: "", isSelected: true, mainQuestOrder: "1", isNewAdded: false, mainId: vioQuestionId)
                    cityQuest.questionoptions!.append(obj)
                    cityQuest.order_number = orderId!
                    
                    let streetQuest = newRipaViewModel.getCascadeQuestionUsingQuestionCode(questionCode: "C7")
                    streetQuest.questionoptions!.removeAll()
                    if street != "" {
                        let stretObj = newRipaViewModel.createObj(mainQuestId: questionId, ripaID: streetQuest.id, optionValue:street.uppercased(), physical_attribute: "", description: "", isSelected: true, mainQuestOrder: "1", isNewAdded: false, mainId: vioQuestionId)
                        streetQuest.questionoptions!.append(stretObj)
                        streetQuest.order_number = orderId!
                    }
                    
                    let intersectionQuest = newRipaViewModel.getCascadeQuestionUsingQuestionCode(questionCode: "C26")
                    intersectionQuest.questionoptions!.removeAll()
                    if intersection != "" {
                        let intersectionObj = newRipaViewModel.createObj(mainQuestId: questionId, ripaID: intersectionQuest.id, optionValue:intersection.uppercased(), physical_attribute: "", description: "", isSelected: true, mainQuestOrder: "1", isNewAdded: false, mainId: vioQuestionId)
                        intersectionQuest.questionoptions!.append(intersectionObj)
                        intersectionQuest.order_number = orderId!
                    }
                    
                    AppConstants.city = city
                    
                    resetLocation(onGPS: true)
                    
                    cityID = citi.city_id
                    cityFound = true
                    countyLbl.text = (county).uppercased()
                    
                    AppConstants.firstIntersection = intersection
                    AppConstants.street = street
                    AppConstants.address = street
                    AppConstants.lati = String(location.coordinate.latitude)
                    AppConstants.longi = String(location.coordinate.longitude)
                    
                    AppManager.getLastSavedLoginDetails()?.result?.county_id = tempCountyId!
                    tableView.reloadData()
                    return
                }
                
            }
            print(AppConstants.ripaCounty)
            if cityFound == false && AppConstants.ripaCounty == "Y"{
                AppUtility.showAlertWithProperty("Alert", messageString: "Selected county does not have your current city. Select city from the list or change county.")
                self.countyLbl.borderColor = .black
                self.countyLbl.textColor = .black
                self.dropImgView.tintColor = .black
                self.isGpsCityMatched = false
            }
        }
        else if countyFound == false{
            DispatchQueue.main.async(execute: {
                self.showAlertIfCityNotMatchedWithCounty()
            })
        }

    }
  
    func showAlertIfCityNotMatchedWithCounty() {
        let alert = UIAlertController(title: "Alert", message: "Current county not available in the county list. Please select county from the list.", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
           // self.openList(index: 11)
            self.optionsArray![1].questionoptions?.forEach({
                $0.isSelected = false
            })
            self.isGpsCityMatched = false
            self.countyLbl.borderColor = .black
         //   self.countyLbl.textColor = .black
            self.dropImgView.tintColor = .black
            self.isGpsEnable = false
            self.countyBtn.isUserInteractionEnabled = true
           // self.isGeoLocation(check: false)
            self.locTypeIndex = 0
            self.tableView.reloadData()
          //  self.openLocationTypeOptionsList(sender:1)
           })
        )
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func failedFetchingLocationDetails(error: Error) {
        print(error)
    }
    
    func determineMyCurrentLocation() {
           DispatchQueue.main.async(execute: {
               self.locationManager = CLLocationManager()
               self.locationManager.delegate = self
               self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
               self.locationManager.requestAlwaysAuthorization()
               self.locationManager.distanceFilter = kCLDistanceFilterNone
               self.locationManager.activityType = .other
               if CLLocationManager.locationServicesEnabled() {
                   self.locationManager.startUpdatingLocation()
                   self.locationManager.startMonitoringVisits()
                   self.locationManager.startMonitoringSignificantLocationChanges()
               }
              
               self.locationManager.allowsBackgroundLocationUpdates = false
               self.locationManager.pausesLocationUpdatesAutomatically = false
           })
     }
       
       func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
           self.locationManager.stopUpdatingLocation()
           let userLocation:CLLocation = locations[0] as CLLocation
           
           let latflt =  Float(String(userLocation.coordinate.latitude))
           let longflt =  Float(String(userLocation.coordinate.longitude))
           AppConstants.lati = String(format: "%.3f", latflt!)
           AppConstants.longi = String(format: "%.3f", longflt!)
            UserDefaults.standard.set(String(format: "%.3f", latflt!), forKey: "latitude")
            UserDefaults.standard.set(String(format: "%.3f", longflt!), forKey: "longitude")
       }
             
       func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
             {
            print("Error \(error)")
       }
    
}

class Formatter {
  static let numberFormatter: NumberFormatter = {
    $0.minimumFractionDigits = 0
    $0.maximumFractionDigits = 1
    return $0
  }(NumberFormatter())

  class func string(from double: Double) -> String {
    let nsNumber = NSNumber(value: double)
    guard let formattedString = numberFormatter.string(from: nsNumber) else { fatalError("Should never happen")  }
    return formattedString
  }
}
