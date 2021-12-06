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




class NewRipaViewController: UIViewController,PopupViewControllerDelegate,AddOptionDelegate,LocationDelegate, UITextFieldDelegate, UITextViewDelegate,ViolationTypeDelegate, GoToQuestion, AddDescriptionDelegate, PreviewModelDelegate, PendingQuestionDelegate,SelectOptionsPopupDelegate, ViolationPopupDelegate, NoteDelegate, SaveDelegate, UIGestureRecognizerDelegate, violDelegate {
    
    
    
    
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
    @IBOutlet weak var submitBtn: UIButton!
    
    @IBOutlet weak var requiredImgView: UIImageView!
    
    @IBOutlet weak var topPrevBtn: UIButton!
    @IBOutlet weak var topNextBtn: UIButton!
    
    @IBOutlet weak var topPrevView: UIView!
    @IBOutlet weak var topNextView: UIView!
    @IBOutlet weak var saveToServerBtn: UIButton!
    @IBOutlet weak var countyLbl: UITextField!
    @IBOutlet weak var countyView: UIView!
    @IBOutlet weak var countyBtn: UIButton!
    
    
    
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
    var educationCodeSectionArray : [EducationCodeSection]?
    var educationCodeSubSectionArray : [EducationCodeSubsection]?
    var cascadeDict:[String:Any]?
    var cascadeArray: [[String: Any]] = []
    var personDict:[String:Any]?
    var violationDict:[String:Any]?
    
    var cascadeQuestionArray : [QuestionResult1]?
    var ripaActivity: Ripaactivity?
    
    var previewViewModel = PreviewViewModel()
    
    var cascadeQuestionType:String?
    var indexPath:Int?
    var is_k12:Bool?
    
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
    
    var timer = Timer()
    
    var lat = ""
    var long = ""
    
    var cityID=""
    var questionId=""
    
    var cityName=""
    var streetName=""
    var intersectionName=""
    var saveRipaStatus:String?
    
    var lgbtBtnDisable:Bool?
    
    var personcount = 0
    var crashDict:[String:Any] = [:]
    var newRipaViewModel = NewRipaViewModel()
    
    var  selectedOptionsArray=[[Questionoptions1]]()
    var  personArray: [[String: Any]] = []
    
    var currentQuestNumb:String?{
        String(questNumber!+1) + "/" + String(questionArray!.count)
    }
    
    var startDate = ""
    
    let datePicker = UIDatePicker()
    let timePicker = UIDatePicker()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        startDate = previewViewModel.getCurrentTime()
        
        submitBtn.isHidden = true
        
        
        self.saveBtn.orangeGradientButton()
        self.nextView.orangeGradientButton()
        self.topNextView.orangeGradientButton()
        self.saveToServerBtn.orangeGradientButton()
        
        newRipaViewModel.setFeature()
        getCounty()
        resetArray()
        
        
        if (viewType == "UseSaveRipa" && saveRipaStatus != "Created") || (viewType == "UseLastRipa" || viewType == "Template"){
            var i = 0
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
            editForPerson(personIndex: personArray.count-1, personArray: personArray)
            personNumber.text = "P" + "" + String(personArray.count)
            if viewType == "UseLastRipa" || viewType == "Template"{
                newRipaViewModel.clearPersonData()
            }
            checkAndAddViolations()
        }
        else{
            if  saveRipaStatus == "Created"{
                let trafficeViolTupple = newRipaViewModel.splitViolatons(code: savedRipaList!.offenceCode, violation: savedRipaList!.violation)
                offenceArr = trafficeViolTupple.0!
                violArr = trafficeViolTupple.1!
                trafficVoilArray()
            }
            
            personNumber.text = "P1"
            let value = defaults.object(forKey: "OptionValue")
            if value != nil{
                let assignmentQuest = newRipaViewModel.getQuestionUsingQuestionCode(question_code: 23)
                assignmentQuest.questionoptions!.first(where: { $0.option_value == value as! String })?.isSelected = true
            }
        }
        
        
        userNameLbl.text = AppManager.getLastSavedLoginDetails()?.result?.first_name
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
        
        if #available(iOS 15.0, *) {
            self.tableView.sectionHeaderTopPadding = 0.0
        }
        
        self.tableView.sectionHeaderHeight = UITableView.automaticDimension;
        self.tableView.estimatedSectionHeaderHeight = 55;
        
        self.tableView.estimatedRowHeight = 100.0
        self.tableView.rowHeight = UITableView.automaticDimension
        is_k12 = false
        
        loadData()
        
        showDatePicker()
        showTimePicker()
        durationTxtField.delegate = self
        durationTxtField.tag = 10
        durationTxtField.text = AppConstants.duration
        dateTextField.text = AppConstants.date
        timeTxtField.text = AppConstants.time
        durationTxtField.keyboardType = UIKeyboardType.numberPad
        
        if AppConstants.duration == ""{
            durationTxtField.becomeFirstResponder()
        }
        disableNextButton(View: nextView)
        // disableButton(Button: prevQuestBtn)
        
        let userDefaults = UserDefaults.standard
        let isNil = "0"
        userDefaults.set(isNil, forKey: "isOffline")
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
        //self.mainView.backgroundlayer()
        self.groupView.orangeGradientButton()
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
        if violIndex <= offenceArr.count - 1{
            for offCode in offenceArr[violIndex]{
                let offCode = offCode.lowercased()
                if offCode == "" || offCode == "null" || offCode.contains("null") {
                    let violation = violArr[violIndex]
                    showAlertWithProperty("", messageString: "Offence code is not available for \(violation). \n (CODE NOT FOUND) will be used.")
                    return
                }
                else{
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
            violationArray = newRipaViewModel.getViolations()
            for str in offenceArr[index]{
                let formattedString = str.replacingOccurrences(of: " ", with: "")
                offenceArr1.append(formattedString)
            }
            offenceArr[index] = offenceArr1
            let filteredViolations = violationArray!.filter({offenceArr[index].contains($0.offense_code) })
            selectViolationPopup.violationArray = filteredViolations
            arrayCount = filteredViolations.count
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
    
    
    
    func selectedOptionFromViolationPopup(optionArray: [Questionoptions1]){
        selectedViolationArray2.append(contentsOf: optionArray)
        violationDict = ["ViolationFor":"Traffic", "optionID": "" ,"ViolationList": selectedViolationArray2]
        violIndex += 1
        trafficVoilArray()
    }
    
    
    
    
    func showAlertWithProperty(_ title: String, messageString: String) -> Void {
        let alertController = UIAlertController.init(title: title, message: messageString, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { [self] action in
            
            violationArray = newRipaViewModel.getViolations()
            
            for options in violationArray!{
                if options.offense_code == "99999"{
                    let option = newRipaViewModel.createObj( mainQuestId: "", ripaID: "", optionValue: options.violationDisplay, physical_attribute:"", description: options.offense_code, isSelected: true, mainQuestOrder: "")
                    selectedViolationArray2.append(option)
                }
            }
            
            //            let option = newRipaViewModel.createObj(ripaID: "", optionValue: violArr[violIndex], physical_attribute:"", description: "99999", isSelected: true, mainQuestOrder: "")
            //   selectedViolationArray2.append(option)
            
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
                topNextView.layer.sublayers?.first!.removeFromSuperlayer()
            }
            nextView.disablebutton()
            topNextView.disablebutton()
        }
        removeSwipeGesture()
        // nextQuestBtn.isUserInteractionEnabled = false
        // topNextBtn.isUserInteractionEnabled = false
        nextEnabled = false
    }
    
    
    func enableNextButton(View: UIView) {
        if let layer = View.layer.sublayers? .first {
            if View.layer.sublayers!.count>1{
                layer.removeFromSuperlayer ()
                topNextView.layer.sublayers?.first!.removeFromSuperlayer()
            }
            nextView.orangeGradientButton()
            topNextView.orangeGradientButton()
        }
        addSwipeGesture()
        //  nextQuestBtn.isUserInteractionEnabled = true
        // topNextBtn.isUserInteractionEnabled = true
        // nextEnabled = true
    }
    
    
    func checkRequired()->(Bool,String){
        
        if questionArray![questNumber!].question_code == "25"{
            for options in optionsArray!{
                let quest = newRipaViewModel.getCascadeQuestionUsingQuestionCode(questionCode: options.question_code_for_cascading_id)
                if quest.is_required == "1" && options.isSelected == false{
                    return (false,"Please Select City")
                }
            }
            return (true,"Please Select City")
        }
        
        
        
        if questionArray![questNumber!].question_code == "5"{
            if AppConstants.date == "" || AppConstants.time == "" || AppConstants.duration == "" {
                return (false,"Durartion Required")
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
            if (quest.questionoptions![0] ).isSelected == true{
                quest = newRipaViewModel.getCascadeQuestionUsingQuestionCode(questionCode: "C9")
                if quest.questionoptions!.count < 1{
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
                            if typeQuest!.questionoptions![1].isSelected == false{
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
                disableNextButton(View: nextView)}
        }
        return check.1
    }
    
    
    
    func showDatePicker(){
        
        //Formate Date
        datePicker.datePickerMode = .date
        // Posiiton date picket within a view
        datePicker.frame = CGRect(x: 10, y: 50, width: self.view.frame.width, height: 200)
        let now = Date();
        datePicker.maximumDate = now
        // Set some of UIDatePicker properties
        datePicker.timeZone = NSTimeZone.local
        datePicker.backgroundColor = UIColor.white
        //ToolBar
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        //  toolbar = UIToolbar(frame: CGRect (x:0,y:0,width:self.view.frame.width,height:400))
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donedatePicker));
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker));
        
        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)
        
        dateTextField.inputAccessoryView = toolbar
        dateTextField.inputView = datePicker
        
        
    }
    
    
    func showTimePicker(){
        //Formate Date
        
        timePicker.datePickerMode = .time
        timeTxtField.inputView = timePicker
        timePicker.locale = NSLocale(localeIdentifier: "en_GB") as Locale
        
        timePicker.frame = CGRect(x: 10, y: 50, width: self.view.frame.width, height: 200)
        let now = Date()
        
        timePicker.maximumDate = now
        // timePicker.date = now
        //ToolBar
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
        timeTxtField.text = formatter.string(from: timePicker.date)
        AppConstants.time = timeTxtField.text!
        self.view.endEditing(true)
    }
    
    var datetime = ""
    
    @objc func donedatePicker(){
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        dateTextField.text = formatter.string(from: datePicker.date)
        datetime = dateTextField.text!
        //var d1 = formatter.string(from: datePicker.date)
        AppConstants.date = dateTextField.text!
        if formatter.string(from: datePicker.date) < formatter.string(from: timePicker.date)
        {
            timePicker.maximumDate = nil
        }
        else{
            timePicker.maximumDate = Date()
        }
        self.view.endEditing(true)
    }
    
    
    @objc func cancelDatePicker(){
        dateTextField.resignFirstResponder()
        timeTxtField.resignFirstResponder()
    }
    
    
    func setRipaActivity(){
        print(AppConstants.city)
        let getExperience = previewViewModel.calculateYearOfExp()
        ripaActivity = Ripaactivity(key: AppConstants.key, custid: previewViewModel.custId!, City: AppConstants.city, date_time: dateLbl.text!, userid: String(previewViewModel.userId!), username:  previewViewModel.userName!, Notes: AppConstants.notes, latitude: AppConstants.lati , longitude:  AppConstants.longi, start_date: startDate, end_date: "", deviceid: 0, Location: AppConstants.address, officer_experience: getExperience, is_K_12_Student: AppConstants.isStudent , CreatedBy:String(previewViewModel.userId!), ip_address: previewViewModel.strIPAddress , stop_date: AppConstants.date , stop_time: AppConstants.time, stop_duration: AppConstants.duration, app_version: previewViewModel.appVersion!, platform: "ios", traffic_id: AppConstants.trafficId, activity_status_id: "1", access_token: AppManager.getLastSavedLoginDetails()?.result?.access_token ?? "", timetaken: previewViewModel.getTimeTaken(), citation_number: AppConstants.citation, county_id: AppManager.getLastSavedLoginDetails()?.result?.county_id ?? "0", time_duration_enable: AppConstants.ripaTimeDuration, call_number: AppConstants.call_number, onscene_time: AppConstants.onscene_time, clear_time_of_the_Offrcer: AppConstants.clear_time_of_the_Offrcer, overall_call_clear_time: AppConstants.overall_call_clear_time, call_type: AppConstants.call_type, unitId: AppConstants.unitId, zone: AppConstants.zone, ripaPersons: [])
        
        
        
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
            if viewType != "UseSaveRipa" &&  viewType != "UseLastRipa"{
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
        trackApplicationTime()
        savetoServer(showAlertForSave: true)
    }
    
    
    @IBAction func actionPrev(_ sender: Any) {
        trackApplicationTime()
        setOptionOrder()
        prevQuestion()
    }
    
    
    var nextEnabled = true
    @IBAction func actionNext(_ sender: Any) {
        
         if consensualEncounter() == false{
             AppUtility.showAlertWithProperty("Alert", messageString: "You have selected Consensual encounter resulting in search option of question(Reason for stop). Please select option Search of property was conducted or Search of person was conducted option of current question.")
             return
        }
        
        if nextEnabled == false{
            checkForDescription()
        }
        else{
            trackApplicationTime()
            setOptionOrder()
            if questionType == "SL" || questionType == "ML"{
            }
            nextQuestion()
        }
    }
    
    
    @IBAction func actionAutoNext(_ sender: Any) {
        // isChecked = !isChecked
        AppConstants.autoNext = !AppConstants.autoNext!
        autoNextBtn.setImage(UIImage(named: AppConstants.autoNext == true ? "checked" : "unchecked"), for: .normal)
    }
    
    @IBAction func actionBack(_ sender: Any) {
        trackApplicationTime()
        //AppConstants.notes = ""
        save()
    }
    
    
    @IBAction func actionReset(_ sender: Any) {
        trackApplicationTime()
        resetArray()
        loadData()
    }
    
    
    @IBAction func actionSave(_ sender: Any) {
        trackApplicationTime()
        createPersonDict(checkEditHidden: true)
        self.performSegue(withIdentifier: "ShowPreview", sender: self)
    }
    
    
    @IBAction func actionCounty(_ sender: Any) {
        openCountyList(countylist:countyList)
    }
    
    
    func countyChanged(resetLoc: Bool) {
        getCounty()
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
    
    
    @IBAction func actionSubmit(_ sender: Any) {
        trackApplicationTime()
        //        defaults.removeObject(forKey: "CrashedDict")
        //        defaults.synchronize()
        createPersonDict(checkEditHidden:true)
        let personDict = personArray[personcount]
        let questArr = (personDict["QuestionArray"] as! [QuestionResult1])
        let cascadeQuestArr = (personDict["CascadeQuestionArray"] as! [QuestionResult1])
        selectedOptionsArray = personDict["SelectedOption"] as! [[Questionoptions1]]
        
        let requiredFilledData = previewViewModel.checkRequiredQuestion(questArray: questArr, cascadeQuestArray: cascadeQuestArr, selectedOpt: selectedOptionsArray)
        
        // let requiredFilledId = previewViewModel.checkRequiredQuestionID(questArray: questArr, selectedOpt: selectedOptionsArray)
        
        if requiredFilledData.0.count < 1 {
            previewViewModel.previewModelDelegate = self
            previewViewModel.viewType = viewType
            previewViewModel.personArray = personArray
            previewViewModel.createPersonsDict(personArray: personArray, ripaActivity: ripaActivity!, statusId: "1")
            // previewViewModel.createPersonsSelectedOptionDict(questionArray: questionsArray!, cascadeQuestArray: cascadeQuestionsArray!)
            let updateRipa:UpdateRipa = previewViewModel.updateRipaParam()
            
            //previewViewModel.saveToDB(updateRipa: updateRipa)
            previewViewModel.submitParam(params: updateRipa, toSave: false, showAlertForSave: false)
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
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newDataNotif"), object: nil)
        }
    }
    
    
    func openCountyList(countylist:[CountyResult]){
        let listView = self.storyboard?.instantiateViewController(withIdentifier: "ListViewController") as! ListViewController
        listView.locationdelegate = self
        listView.listType = "County"
        listView.countyArray = countylist
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
            //            AppManager.removeData()
            
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "DashBoardViewController") as! DashBoardViewController
            let navigationController = UINavigationController(rootViewController: nextViewController)
            UIApplication.shared.windows.first?.rootViewController = navigationController
            UIApplication.shared.windows.first?.makeKeyAndVisible()
            
        }         )
        )
        self.present(alert, animated: true, completion: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        let segueID = segue.identifier
        if(segueID! == "ShowPreview"){
            let vc = segue.destination as! PreviewViewController
            vc.selectedIndexDelegate = self
            vc.questionsArray = questionArray!
            vc.cascadeQuestionsArray = cascadeQuestionArray!
            vc.personIndex = personcount
            vc.personArray = personArray
            vc.viewType = viewType
            vc.ripaActivity = ripaActivity
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
        
        selectedOptionsArray = newRipaViewModel.makeSelectedOptionList()
        
        var personType=""
        if  selectedOptionsArray[0].count > 0 {
            personType = selectedOptionsArray[0][0].option_value
        }
        
        personDict = ["PersonType":personType,"SelectedOption":selectedOptionsArray,"QuestionArray":questarr,"CascadeQuestionArray":cascadeQuestArr]
        if personArray.count > personcount {
            personArray[personcount] = personDict!
        }
        else{
            personArray.append(personDict!)
        }
    }
    
    
    
    func resetIsK12Options(){
        createPersonDict(checkEditHidden: true)
        questionArray = resetIsK12(questArray: questionArray!)
        cascadeQuestionArray = resetIsK12(questArray: cascadeQuestionArray!)
        
        newRipaViewModel.questionsArray = questionArray
        newRipaViewModel.cascadeQuestionArray = cascadeQuestionArray
        // splitOptions()
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
        questNumber = 0
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
    
    
    func goToSelectedQuestion(personIndex: Int,  personArray: [[String : Any]], index:Int) {
        resetArray()
        checkEditableAndCommonQues(personArray:personArray)
        personNumber.text = "P" + "" + String(personIndex + 1)
        personcount = personIndex
        self.personArray = personArray
        questNumber = index
        editQuest(personIndex: personIndex, personArray: personArray, addIfNonCommon: true, resetsk12: false)
        splitOptions()
    }
    
    
    
    func resetArray(){
        questionArray = newRipaViewModel.resetQuestion()
        cascadeQuestionArray = newRipaViewModel.resetCascadeQuestion()
        violationArray?.removeAll()
    }
    
    
    
    func editQuest(personIndex:Int , personArray:[[String: Any]], addIfNonCommon:Bool, resetsk12: Bool) {
        
        let personDict = personArray[personIndex]
        let questArr = (personDict["QuestionArray"] as! [QuestionResult1])
        let cascadeQuestArr = (personDict["CascadeQuestionArray"] as! [QuestionResult1])
        violationArray?.removeAll()
        
        
        var i = 0
        for question in questionArray! {
            
            if question.question_code != "17"{
                question.isDescription_Required = questArr[i].isDescription_Required
                question.is_required = questArr[i].is_required
                if question.question_code == "19" || question.question_code == "20"{
                      question.isDescription_Required = "0"
                      checkPropertySeziure()
                }
            }
            if question.common_question == "1" || addIfNonCommon == true{
                question.questionoptions = questArr[i].questionoptions
            }
            
            if question.question_code == "16"{
                checkBasisRequired(checkBasis: true)
            }
            
            
            i += 1
        }
        
        i = 0
        for question in cascadeQuestionArray! {
            question.isDescription_Required = cascadeQuestArr[i].isDescription_Required
            question.is_required = cascadeQuestArr[i].is_required
            if question.common_question == "1" || addIfNonCommon == true{
                question.questionoptions = cascadeQuestArr[i].questionoptions
            }
            i += 1
            
            //            if question.question_code == "C9"{
            //                AppConstants.isSchoolSelected = "Yes"
            //            }
        }
        
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
        customAlertVC.placeholder = "Additional details for" + " " + questionArray![questNumber!].question.lowercased()
        
        customAlertVC.inputType = "Description"
        
        let popupVC = PopupViewController(contentController: customAlertVC, position: .bottom(UIScreen.main.bounds.size.height/2.8), popupWidth: UIScreen.main.bounds.size.width-30, popupHeight: 370)
        popupVC.cornerRadius = 5
        popupVC.delegate = self
        present(popupVC, animated: true, completion: nil)
    }
    
    
    func addEnteredDescription(text: String?) {
        
        let index = questionArray![questNumber!].questionoptions!.count - 1
        (questionArray![questNumber!].questionoptions![index] ).option_value = text!
        (questionArray![questNumber!].questionoptions![index] ).isSelected = true
        tableView.reloadData()
        checkMandatorySelection()
    }
    
    
    
    
    func loadData(){
        questNumber = 0
        countLbl.text = currentQuestNumb
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
        
        splitOptions()
        self.saveToDb(toUpdate:true)
    }
    
    
    func showPrevNextBtn(){
        if questNumber! < questionArray!.count-1{
            nextView.isHidden = false
            topNextView.isHidden = false
            submitBtn.isHidden = true
        }else{
            nextView.isHidden = true
            topNextView.isHidden = true
            submitBtn.isHidden = false
        }
        if questNumber! == 0{
            prevView.isHidden = true
            topPrevView.isHidden = true
        }else{
            prevView.isHidden = false
            topPrevView.isHidden = false
        }
    }
    
    
    // Get Question Details and set option array for each questions
    func splitOptions(){
        
        questionLbl.text = questionArray![questNumber!].question
        orderId = questionArray![questNumber!].order_number
        questionType = questionArray![questNumber!].questionTypeCode
        questionId = questionArray![questNumber!].id
        checkAddBtn(show: questionArray![questNumber!].isAddtion)
        countLbl.text = currentQuestNumb
        groupLbl.text = questionArray![questNumber!].groupName
        
        cascadeArray.removeAll()
        checkCityAndAdd()
        showPrevNextBtn()
        optionsArray = questionArray![questNumber!].questionoptions!
        checkDiscriptionRequired()
        addCascadeOptions()
        
        checkNameView()
        checkMandatory()
        addSchoolToLocation()
        
        checkMandatorySelection()
        setmodelArray()
        tableView.reloadData()
        
    }
    
    
    var allowSave = true
    
    func saveToDb(toUpdate:Bool){
        
        //        if viewType != "UseSaveRipa" || isCrashedRipa == true{
        //            crashDict = ["Key": AppConstants.key, "Index": String(questNumber!)]
        //            defaults.set(crashDict, forKey: "CrashedDict")
        //            defaults.synchronize()
        //         }
        
        if allowSave == true{
            setRipaActivity()
            createPersonDict(checkEditHidden: true)
            previewViewModel.previewModelDelegate = self
            
            // previewViewModel.setKey()
            previewViewModel.ripaActivity = self.ripaActivity
            previewViewModel.createPersonsDict(personArray: self.personArray, ripaActivity: ripaActivity!, statusId: "1" )
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
        //       dateTextField.isHidden = false
        //     timeTxtField.isHidden = false
        //   durationTxtField.isHidden = false
        
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
    
    
    
    func checkCityAndAdd(){
        
        if questionArray![questNumber!].question_code == "5"{
            
            disableOnLocation()
            var option = [Questionoptions1]()
            let custId = previewViewModel.custId
            var id=[String]()
            let cityList = newRipaViewModel.getCities()
            let cascadeQuest = newRipaViewModel.getCascadeQuestionUsingQuestionCode(questionCode: "C6")
            for city in cityList{
                
                if (city.custid == custId && viewType != "UseSaveRipa" && viewType != "UseLastRipa" && viewType != "Template")  || city.city_name == AppConstants.city && (viewType == "UseSaveRipa" || viewType == "UseLastRipa" || viewType == "Template") {
                    cityID = city.city_id
                    let obj = newRipaViewModel.createObj(mainQuestId: questionId, ripaID: cascadeQuest.id, optionValue: city.city_name, physical_attribute: "", description: "", isSelected: true, mainQuestOrder: "1")
                    
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
                                let obj = newRipaViewModel.createObj(mainQuestId: questionId, ripaID:cascadeQuest2.id, optionValue: AppConstants.address, physical_attribute: "", description: "", isSelected: true, mainQuestOrder: "1")
                                
                                option.append(setMainQuestIdAndOptn(optn: obj))
                                cascadeQuest2.questionoptions = option
                                
                            }
                            cityID = city.city_id
                        }
                    }
                }
            }
            
            
            if viewType != "UseSaveRipa" && viewType != "UseLastRipa" && viewType != "Template"{
                
                if  option.count == 1 {
                    cascadeQuest.questionoptions?.removeAll()
                    cascadeQuest.questionoptions = option
                    AppConstants.city = option[0].option_value
                    cityID = id[0]
                }
                else {
                    if let defaultCity = (UserDefaults.standard.object(forKey: "DefaultCity") as? [String : Any]){
                        if (defaultCity["City"] as! String) != ""{
                            cascadeQuest.questionoptions?.removeAll()
                            option.removeAll()
                            
                            AppConstants.city = defaultCity["City"] as! String
                            cityID = defaultCity["Id"] as! String
                            
                            let obj = newRipaViewModel.createObj(mainQuestId: questionId, ripaID: cascadeQuest.id, optionValue: AppConstants.city , physical_attribute: "", description: "", isSelected: true, mainQuestOrder: "1")
                            option.append(setMainQuestIdAndOptn(optn: obj))
                            cascadeQuest.questionoptions = option
                        }
                    }
                }
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
        
        
        if questionArray![questNumber!].question_code == "16" {
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
                if option.tag == "Description"{
                    hasDescriptionObj = true
                } }
            if hasDescriptionObj == false{
                let option:Questionoptions1 = Questionoptions1(mainQuestId: questionId, mainQuestOrder:"" ,option_id: "", ripa_id:questionArray![questNumber!].id, custid: "", option_value: "", cascade_ripa_id: "", isK_12School: "", isHideQuesText: "", order_number: "", createdBy: "", createdOn: "", updatedBy: "", updatedOn: "", isSelected: false, isAddtion: "", isDescription_Required : "",inputTypeCode : "", questionTypeCode: "", tag: "Description", physical_attribute: "", default_value: "", optionDescription: "", question_code_for_cascading_id: "", isQuestionMandatory: "1", isQuestionDescriptionReq: "1", main_question_id: questionId, isExpanded: false, questionoptions: [])
                questionArray![questNumber!].questionoptions!.append(option)
            }
        }else{
            descriptionBtn.isHidden = true
        }
        optionsArray = questionArray![questNumber!].questionoptions!
        //tableView.reloadData()
        
    }
    
    
    func checkIs_K12(){
        setmodelArray()
        let ad = newRipaViewModel.getCascadeQuestionUsingQuestionCode(questionCode: "C10")
        
        let studentQuest = newRipaViewModel.getCascadeQuestionUsingQuestionCode(questionCode: "C27")
        if studentQuest.questionoptions![0].isSelected == true{
            is_k12 = true
        }
        cascadeQuestionType = ad.questionTypeCode
        if (ad.questionoptions![0] ).isSelected == true {
            
            //  is_k12 = true
            studentQuest.is_required = "1"
            //questionArray![questNumber!+1].is_required = "1"
        }
        else{
            //  is_k12 = false
            let cascadeQuest = newRipaViewModel.getCascadeQuestionUsingId(questionID: Int(optionsArray![5].cascade_ripa_id)!)
            optionsArray![4].isSelected = false
            // questionArray![questNumber!+1].is_required = "0"
            studentQuest.is_required = "0"
            cascadeQuest.questionoptions = []
        }
        if (ad.questionoptions![1] ).isSelected == true {
            // is_k12 = false
            // questionArray![questNumber!+1].is_required = "0"
            studentQuest.is_required = "0"
            optionsArray![4].isSelected = true
            // AppUtility.showAlertWithProperty("Alert", messageString: "All sk_12 Options Will Be Hidden")
        }
        
        
    }
    
    
    func checkSingleAndMultiline(){
        
        let trimmedAnswer = answer.trimmingCharacters(in: .whitespacesAndNewlines)
        var select:Bool = false
        if answer != ""{select = true}
        
        if questionArray![questNumber!].question_code == "23" || questionArray![questNumber!].question_code == "25"{
            let cascadeQuest = newRipaViewModel.getCascadeQuestionUsingId(questionID: Int(optionsArray![indexPath!].cascade_ripa_id)!)
            cascadeQuest.questionoptions!.removeAll()
            let options = newRipaViewModel.createObj(mainQuestId: questionId, ripaID: cascadeQuest.id, optionValue: trimmedAnswer, physical_attribute: "", description: "", isSelected: select, mainQuestOrder: orderId!)
            
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
            let options = newRipaViewModel.createObj(mainQuestId: questionId, ripaID: cascadeQuest.id, optionValue: trimmedAnswer, physical_attribute: "", description: "", isSelected: select, mainQuestOrder: orderId!)
            cascadeQuest.questionoptions?.append(setMainQuestIdAndOptn(optn: options))
        }
        
        if (questionType == "ML" || questionType == "SL"){
            questionArray![questNumber!].questionoptions!.removeAll()
            let options = newRipaViewModel.createObj(mainQuestId: questionId, ripaID: questionArray![questNumber!].id , optionValue: trimmedAnswer, physical_attribute: "", description: "", isSelected: select, mainQuestOrder: orderId!)
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
        
        if questionArray![questNumber!].question_code == "16" || checkBasis == true{
            let basisQues = newRipaViewModel.getQuestionUsingQuestionCode(question_code: 17)
            let consentQues = newRipaViewModel.getQuestionUsingQuestionCode(question_code: 16)
            
            for option in consentQues.questionoptions!{
                
                
                
                if  (option.physical_attribute == "18" && option.isSelected) || (option.physical_attribute == "20" && option.isSelected){
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
            optionsArray![index].isSelected  =  !optionsArray![index].isSelected
            
            
            let defaultSelected = checkDefaultSelected()
            
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
            
            autoMoveNext()
        }
        checkBasisRequired(checkBasis: false)
        tableView.reloadData()
        checkMandatorySelection()
    }
    
    
    
    
    
    
    func savetoServer(showAlertForSave:Bool){
        setRipaActivity()
        previewViewModel.saveDelegate = self
        previewViewModel.ripaActivityArray.removeAll()
        createPersonDict(checkEditHidden: true)
        previewViewModel.previewModelDelegate = self
        
        // previewViewModel.setKey()
        previewViewModel.ripaActivity = self.ripaActivity
        previewViewModel.createPersonsDict(personArray: self.personArray, ripaActivity: ripaActivity!, statusId: "9" )
        let updateRipa:UpdateRipa = self.previewViewModel.updateRipaParam()
        self.previewViewModel.saveToDB(updateRipa: updateRipa, isUpdate: true, syncSccessful: "")
        previewViewModel.submitParam(params: updateRipa, toSave: true, showAlertForSave: showAlertForSave)
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
        self.navigationController?.popViewController(animated: true)
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
            AppManager.removeData()
            
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
            AppManager.removeData()
            if AppConstants.status != "Saved"{
                self.navigationController?.popViewController(animated: true)
            }
        }
        
        
    }
    
    
    
    
    
    func save(){
        
        openNotes(for:"Back")
        
    }
    
}






///////////////////////


extension NewRipaViewController: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if questionType == "SL"{
            return  50
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
        
        if questionType == "SL"{
            return 1
        }
        else if questionType == "ML"{
            return 1
        }
        
        else if questionArray![questNumber!].question_code == "25"{
            return optionsArray!.count
        }
        else if questionType == "MC" && questionArray![questNumber!].question == "Location"{
            if section == 4{
                //                if !optionsArray![section].isExpanded{
                //                    return 0
                //                }
                //                let ad = newRipaViewModel.getCascadeQuestionUsingId(questionID: Int(optionsArray![section].cascade_ripa_id)!)
                //                return ad.questionoptions!.count
                //                return 0
            }
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
        if questionType == "SL" || questionType == "ML"{
            return 1
        }
        else if questionType == "MC" && questionArray![questNumber!].question == "Location"{
            checkIs_K12()
            //if is_k12 {
            if AppConstants.isSchoolSelected == "Yes" {
                return 6
            }else{
                return 5
            }
        }
        else if  questionArray![questNumber!].isDescription_Required == "1"{
            return optionsArray!.count-1
        }
        return optionsArray!.count
    }
    
    
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if questionArray![questNumber!].question_code == "25" {
            return 0
        }
        if questionType == "SL" || questionType == "ML"{
            return 0
        }
        else if questionType == "MC" && questionArray![questNumber!].question == "Location"{
            //            if section == 4{
            //                return UITableView.automaticDimension
            //            }
            //            else{
            return 0
            //            }
        }
        if !is_k12! && optionsArray![section].isK_12School == "1"{
            return 0
        }
        return UITableView.automaticDimension
    }
    
    
    
    
    
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 55
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let label = UILabel()
        let view = UIView()
        let sectionButton = UIButton()
        var headerView = UIView()
        optionsArray![section].order_number = orderId!
        if !is_k12! && optionsArray![section].isK_12School == "1"{
            headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 0))
            return headerView
        }
        headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 55))
        
        view.frame = CGRect.init(x: 0, y: 2, width: headerView.frame.width, height: headerView.frame.height-4)
        view.backgroundColor = UIColor(named: "LightGrayLightBlack")
        
        label.frame = CGRect.init(x: 15, y: 5, width: headerView.frame.width-50, height: headerView.frame.height-10)
        label.text = optionsArray![section].option_value
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = .systemFont(ofSize: 18)
        if optionsArray![section].isK_12School == "1"{
            label.textColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        }
        
        headerView.addSubview(view)
        headerView.addSubview(label)
        
        // Add Button
        
        let id = optionsArray![section].cascade_ripa_id
        sectionButton.frame = CGRect.init(x: 0, y: 2, width: headerView.frame.width, height: headerView.frame.height-4)
        
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
            
            if questionArray![questNumber!].question_code != "23" || questionArray![questNumber!].question_code != "25"{
                sectionButton.tag = section
                sectionButton.addTarget(self,action: #selector(self.hideSection(sender:)), for: .touchUpInside)
            }
            else  {
                dropdownImage = UIImage(systemName: "chevron.up")!
            }
            dropdownImageView.frame = CGRect.init(x: headerView.frame.width-40, y: (headerView.frame.height/2)-4, width: 20, height: 8)
            dropdownImageView.image = dropdownImage
            
            headerView.addSubview(dropdownImageView)
            
        }
        else{
            if checkEditable == true && questionArray![questNumber!].editable_question != "1" || questionArray![questNumber!].question_code == "25"{
                print("Cannot Change Data")
            }
            else{
                if questionArray![questNumber!].question_code == "10" {
                    let allowSelection = checkGender()
                    if allowSelection{
                        sectionButton.tag = section
                        sectionButton.addTarget(self, action: #selector(selectOption(sender:)), for: .touchUpInside)
                    }
                }
                else{
                    sectionButton.tag = section
                    sectionButton.addTarget(self, action: #selector(selectOption(sender:)), for: .touchUpInside)
                }
            }
        }
        if  optionsArray![section].isSelected && questionArray![questNumber!].question_code != "25"{
            view.backgroundColor = UIColor(named: "SelectionBlue")
        }
        else{
            view.backgroundColor = UIColor(named: "LightGrayLightBlack")
        }
        
        headerView.addSubview(sectionButton)
        
        return headerView
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
        trackApplicationTime()
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
            
            
            if questionArray![questNumber!].question_code == "16"{
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
        setmodelArray()
        checkMandatorySelection()
        //checkDependentQuestions()
    }
    
    
    
    
    func checkForSingleSelectionInCascade(section : Int, row:Int){
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
    
    
    @objc func autoMoveNext(){
        if checkDiscriptionEntered(){
            setOptionOrder()
            if AppConstants.autoNext == true && questNumber! < questionArray!.count-1 && (questionType == "SC" || questionType == "SL") {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                    self.nextQuestion()
                })
            }
        }
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newString = NSString(string: textField.text!).replacingCharacters(in: range, with: string)
        ///  let newLength:Int = newString.count
        
        if  questionArray![questNumber!].question_code == "11" || questionArray![questNumber!].question_code == "25"{
            if let intValue = Int(newString), intValue > 120 || intValue < 1{
                return false
            }
        }
        
        if questionType == "MC" && questionArray![questNumber!].question == "Location"{
            if textField.tag == 10{
                if let intValue = Int(newString), intValue > 1440{
                    AppUtility.showAlertWithProperty("Alert", messageString: "Duration should be between 1 to 1440 (24 hour)")
                    return false
                }
                AppConstants.duration = newString
                return true
            }
            else if let intValue = Int(newString), intValue > 999999{
                return false
            }
            
        }
        
        if questionArray![questNumber!].question_code == "23" || questionArray![questNumber!].question_code == "25" {
            indexPath = textField.tag
        }
        
        
        answer = newString
        if questionArray![questNumber!].question_code != "23"{
            checkSingleAndMultiline()
        }
        
        checkMandatorySelection()
        
        return true
        
    }
    
    
    
    
    @objc func keyboardWillAppear() {
        
    }
    
    
    
    @objc func keyboardWillDisappear() {
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
                        autoMoveNext()
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
                    AppConstants.isStudent = ""
                    question.questionoptions![1].isSelected = false
                }
            }
        }
        
        checkMandatory()
        tableView.reloadData()
    }
    
    
    
    @objc func openOptionsList(sender: UIButton) {
        
        let quest = newRipaViewModel.getCascadeQuestionUsingId(questionID: Int(optionsArray![sender.tag].cascade_ripa_id)!)
        guard let optionsPopup = selectOptionPopup else { return }
        indexPath = sender.tag
        optionsPopup.selectOptionsPopupDelegate = self
        optionsPopup.question = "Select " + optionsArray![sender.tag].option_value
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
            height = 90
        }
        
        let popupVC = PopupViewController(contentController: optionsPopup, position: .bottom(UIScreen.main.bounds.size.width/2), popupWidth: UIScreen.main.bounds.size.width-30, popupHeight: CGFloat((50*optionArr.count)) + CGFloat(height))
        popupVC.cornerRadius = 5
        popupVC.delegate = self
        present(popupVC, animated: true, completion: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "optionNotif"), object: nil)
    }
    
    
    func selectedOptionFromPopup(optionArray: [Questionoptions1]){
        let id = optionsArray![indexPath!].cascade_ripa_id
        let question = newRipaViewModel.getCascadeQuestionUsingId(questionID: Int(id)!)
        question.questionoptions = optionArray
        for opt in optionArray{
            opt.mainQuestOrder = orderId!
            opt.cascade_ripa_id = orderId!
        }
        
        
        if optionsArray![indexPath!].question_code_for_cascading_id == "C30"{
            lgbtBtnDisable = false
            let cascsdeQuestion = newRipaViewModel.getCascadeQuestionUsingQuestionCode(questionCode: "C28")
            cascsdeQuestion.questionoptions![1].isSelected = true
            cascsdeQuestion.questionoptions![0].isSelected = false
            cascsdeQuestion.order_number = orderId!
            for options in question.questionoptions!{
                if options.isSelected{
                    options.order_number = orderId!
                    options.mainQuestOrder = orderId!
                    if options.option_value.contains("Transgender") && options.isSelected{
                        cascsdeQuestion.questionoptions![0].isSelected = true
                        cascsdeQuestion.questionoptions![1].isSelected = false
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
        
        tableView.reloadData()
        DispatchQueue.background(delay: 0.1, completion:{
            self.tableView.setContentOffset(.zero, animated: true)
        })
    }
    
    
    @objc func locationSwitch(_ sender : UISwitch!){
        
        let id = optionsArray![sender.tag].cascade_ripa_id
        let question = newRipaViewModel.getCascadeQuestionUsingId(questionID: Int(id)!)
        // cascade
        question.questionoptions![0].isSelected = false
        question.questionoptions![1].isSelected = true
        
        question.order_number = orderId!
        for opt in question.questionoptions!{
            opt.mainQuestOrder =  orderId!
            opt.order_number = orderId!
            
        }
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
            optionsArray![4].isSelected = false
            resetIsK12Options()
        }
        checkMandatory()
        checkMandatorySelection()
        tableView.reloadData()
    }
    
    
    func reload(section:Int,index:Int){
        let quest = getViolQuest(section:section)
        quest.questionoptions?.remove(at: index)
        addToPreSelectedViolArr(indexPath:section)
        optionsArray![indexPath!].isSelected = false
        if quest.questionoptions!.count>0{
            checkForSingleSelection(index : indexPath!)
        }
        if questionArray![questNumber!].question_code == "14"{
            selectedViolationArray2 = quest.questionoptions ?? []
        }
        tableView.reloadData()
    }
    
    
    @objc func dltAllViol(sender:UIButton){
        let quest = getViolQuest(section:sender.tag)
        quest.questionoptions?.removeAll()
        addToPreSelectedViolArr(indexPath:sender.tag)
        optionsArray![indexPath!].isSelected = false
        checkForSingleSelection(index : indexPath!)
        tableView.reloadData()
    }
    
    func getViolQuest(section:Int)-> QuestionResult1{
        let ripaId =  optionsArray![section].cascade_ripa_id
        let quest = newRipaViewModel.getCascadeQuestionUsingId(questionID:Int(ripaId)!)
        let quest2 = newRipaViewModel.getCascadeQuestionUsingId(questionID:Int(quest.questionoptions![0].cascade_ripa_id)!)
        if questionArray![questNumber!].question_code == "14"{
            selectedViolationArray2.removeAll()
        }
        cascadeArray.removeAll()
        return quest2
    }
    
    
    func addToPreSelectedViolArr(indexPath:Int){
        if questionArray![questNumber!].question_code == "14"{
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
        else{
            AppUtility.showAlertWithProperty("Alert", messageString: "Intersection not selected. Intersection and Street must be selected for swapping.")
        }
        
        
        // For Adding Intersection In Street
        
        if intersectionAvailable{
            if streetAvailable{
                orignalStreetQuestion![0].option_value = tempInterOption!.option_value
            }
            else{
                orignalStreetQuestion?.removeAll()
                let optn = newRipaViewModel.createObj(mainQuestId: questionId, ripaID: optionsArray![1].cascade_ripa_id, optionValue: tempInterOption?.option_value, physical_attribute: "", description: "", isSelected: true, mainQuestOrder: orderId!)
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
                let optn = newRipaViewModel.createObj(mainQuestId: questionId, ripaID: optionsArray![3].cascade_ripa_id, optionValue: tempstOption?.option_value, physical_attribute: "", description: "", isSelected: true, mainQuestOrder: orderId!)
                orignalIntersectionQuestion?.append(optn)
            }
        }
        
        
        
        
        tableView.reloadData()
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
                    cell.TxtField.text = question.questionoptions?.first?.option_value
                    cell.clearTxtBtn.isHidden = false
                    cell.clearTxtBtn.addTarget(self, action: #selector(clearOption(sender:)), for: .touchUpInside)
                    cell.clearTxtBtn.tag = indexPath.row
                }
                else{
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
                    
                    let questionString = NSMutableAttributedString(string: optionsArray![indexPath.row].option_value ,attributes: yourAttributes as [NSAttributedString.Key : Any])
                    
                    cell.optionTxt.attributedText = questionString
                    
                    for option in question.questionoptions!{
                        option.mainQuestOrder = orderId!
                        option.order_number = orderId!
                        if option.isSelected{
                            
                            if option.option_value.contains("Transgender") && question.question_code == "C30"{
                                lgbtBtnDisable = true
                            }
                            
                            let myAttrString = NSMutableAttributedString(string: "\n\(option.option_value)", attributes: yourAttributes1)
                            questionString.append(myAttrString)
                            questionString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, questionString.length))
                            cell.optionTxt.attributedText = questionString
                            
                            //cell.optionTxt.text = cell.optionTxt.text! + myAttrString.string
                            optionsArray![indexPath.row].isSelected = true
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
                checkMandatory()
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
                if optionValue == "City" || optionValue == "Street" || optionValue == "Name of school" || optionValue == "Intersection"{
                    if inputTypeCode == "C "{
                        if optionValue == "City"{
                            cell.label.placeholder = "Select City"
                            if AppConstants.ripaGPS == "Y"{
                                cell.closeView.isHidden = false
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
                        }
                    }
                    else if inputTypeCode == "L "{
                        if optionValue == "Street"{
                            cell.label.placeholder = "Select Street"
                        }
                    }
                    else if inputTypeCode == "S "{
                        if optionValue == "Name of school"{
                            cell.label.placeholder = "Select name of school"
                        }
                    }
                    else if inputTypeCode == "IL"{
                        if optionValue == "Intersection"{
                            cell.label.placeholder = "Select Intersection"
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
                        }
                    }
                    
                    if cascadeQuest.questionoptions!.count>0{
                        
                        if optionValue == "Name of school"{
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
                        // optionsArray![indexPath.section].isSelected = true
                        cell.label.text =  cascadeQuest.questionoptions![0].option_value
                    }
                }
                else{
                    cell.label.text = optionValue
                }
                cell.citybtn.addTarget(self, action: #selector(openListViewController(sender:)), for: .touchUpInside)
                cell.citybtn.tag = indexPath.section
                
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
                        
                        let ad = newRipaViewModel.getCascadeQuestionUsingId(questionID: Int(optionsArray![4].cascade_ripa_id)!)
                        if (ad.questionoptions![0]).isSelected == true{
                            AppConstants.isSchoolSelected = "Yes"
                            cell.toggleBtn.isOn = true
                        }
                        return cell
                    }
                    else{
                        let cell = tableView.dequeueReusableCell(withIdentifier: "SingleChoiceCell", for: indexPath as IndexPath) as! SingleChoiceCell
                        cell.optionView.backgroundColor = UIColor(named: "TextWhiteBlack")
                        cell.optionTxt.text = (self.optionsArray![indexPath.section].questionoptions![indexPath.row] ).option_value
                        if  (optionsArray![indexPath.section].questionoptions![indexPath.row] ).isSelected{
                            cell.optionView.backgroundColor = UIColor(named: "SelectionBlue")
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
                let cascadeId = Int((cascadeOption![indexPath.row] ).cascade_ripa_id)
                
                
                if code == "LV"{
                    let cell = tableView.dequeueReusableCell(withIdentifier: "ViolationCell2", for: indexPath as IndexPath) as! ViolationCell2
                    cell.dropdownBackgroundView.backgroundColor = UIColor(named: "TextWhiteBlack")
                    if inputTypeCode == "V "{
                        cell.requiredView.isHidden = false
                        if cascadeOption![0].question_code_for_cascading_id == "C11"{
                            cell.requiredImg.image = #imageLiteral(resourceName: "optional")
                        }
                        if questionArray![questNumber!].question_code != "14"{
                            cell.requiredView.isHidden = true
                        }
                        
                        
                        violationArray = newRipaViewModel.getViolations()
                        
                        optionsArray![indexPath.section].order_number = orderId!
                        optionsArray![indexPath.section].questionoptions![indexPath.row].order_number = orderId!
                        
                        optionsArray![indexPath.section].mainQuestOrder = orderId!
                        optionsArray![indexPath.section].questionoptions![indexPath.row].mainQuestOrder = orderId!
                        
                        cascadeDict = ["QuestionTag":Int(indexPath.section),"QuestionRow":Int(indexPath.row),"ViolationArray" :violationArray!]
                        let cascadeQuestion = newRipaViewModel.getCascadeQuestionUsingId(questionID: cascadeId!)
                        optionsArray![indexPath.section].isSelected = false
                        if cascadeQuestion.questionoptions!.count > 0{
                            cascadeQuestion.order_number = orderId!
                            
                            optionsArray![indexPath.section].isSelected = true
                            optionsArray![indexPath.section].questionoptions![indexPath.row].isSelected = true
                            cell.textView.isHidden = false
                            let arr = cascadeQuestion.questionoptions!
                            cell.violationsArr = cascadeQuestion.questionoptions!
                            cell.section = indexPath.section
                            cell.delegate = self
                            cell.cellHeight.constant = CGFloat(arr.count * 40)
                            cell.ClearBtn.addTarget(self, action: #selector(dltAllViol(sender:)), for: .touchUpInside)
                            cell.ClearBtn.tag = indexPath.section
                            
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
                            
                            //                           cell.textLbl.text = strArr.joined(separator: "\n")
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
                    let cascadeQuestion = newRipaViewModel.getCascadeQuestionUsingId(questionID: cascadeId!)
                    
                    var voilationTypeSelected = false
                    cascadeDict = ["QuestionTag":Int(indexPath.section),"QuestionRow":Int(indexPath.row),"ViolationTypeArray":cascadeQuestion.questionoptions!,"QuestionTypeCode": code]
                    let cell = tableView.dequeueReusableCell(withIdentifier: "ViolationTextCell", for: indexPath as IndexPath) as! ViolationTextCell
                    
                    cell.requiredImg.image = #imageLiteral(resourceName: "required_icon")
                    
                    
                    cell.bottomView.isHidden = true
                    //cell.topViewText.text = optionsArray![indexPath.row].option_value
                    cell.topViewText.text = (self.optionsArray![indexPath.section].questionoptions![indexPath.row] ).option_value
                    
                    let arr = cascadeQuestion.questionoptions!
                    var strArr=[String]()
                    
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
                            voilationSelected = dict["Selected"] as! Bool
                        }
                    }
                    cell.topView.backgroundColor = UIColor(named: "TextWhiteBlack")
                    (cascadeOption![indexPath.row] ).isSelected = false
                    if voilationSelected == true || voilationTypeSelected == true{
                        optionsArray![indexPath.section].isSelected = true
                        if voilationTypeSelected == true{
                            (cascadeOption![indexPath.row] ).isSelected = true
                            cell.topView.backgroundColor = UIColor(named: "SelectionBlue")
                        }
                        //                        else{
                        //                             (cascadeOption![indexPath.row] as! Questionoptions1).isSelected = false
                        //                        }
                    }
                    //                    else{
                    //                        (cascadeOption![indexPath.row] as! Questionoptions1).isSelected = false
                    //                        //cell.topView.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                    //                    }
                    cell.bottomViewText.text = strArr.joined(separator: "\n")
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
                cell.optionTxt.text = (self.optionsArray![indexPath.section].questionoptions![indexPath.row] ).option_value
                if  (optionsArray![indexPath.section].questionoptions![indexPath.row] ).isSelected{
                    cell.optionView.backgroundColor = UIColor(named: "SelectionBlue")
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
        tableView.reloadData()
    }
    
    
    func removeOptFromCascade(index:Int){
        let cascadeId = optionsArray![index].cascade_ripa_id
        let quest = newRipaViewModel.getCascadeQuestionUsingId(questionID: Int(cascadeId)!)
        quest.questionoptions?.removeAll()
    }
    
    
    
    @objc func openEducationCodeList(sender: UIButton) {
        let registerView = self.storyboard?.instantiateViewController(withIdentifier: "ListViewController") as! ListViewController
        registerView.locationdelegate = self
        indexPath = sender.tag
        
        registerView.listType = "EducationCode"
        let eduCode = newRipaViewModel.getEducationCode()
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
        for dict in cascadeArray{
            if sender.tag == dict["QuestionTag"] as! Int && dict["QuestionRow"] as! Int == 1{
                indexPath = sender.tag
                let registerView = self.storyboard?.instantiateViewController(withIdentifier: "ViolationTypeView") as! ViolationTypeViewController
                registerView.violationTypeDelegate = self
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
                        $0.violationGroup == "VC" || $0.offense_code == "99999"
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
            listView.listType = "City"
            listView.cityArray = newRipaViewModel.getCities()
        }
        else if index == 1 {
            listView.listType = "Location"
            let locDetail = newRipaViewModel.getLocation(cityID: cityID)
            listView.locationArray = locDetail.0
            listView.location = locDetail.1
            // listView.locationArray = newRipaViewModel.getLocation(cityID: cityID).0
            
            if citySelected != true{
                AppUtility.showAlertWithProperty("Alert", messageString: "Select City")
                return
            }
        }
        else if index == 3 {
            listView.listType = "Intersection"
            let locDetail = newRipaViewModel.getLocation(cityID: cityID)
            listView.locationArray = locDetail.0
            listView.location = locDetail.1
            
            if citySelected != true{
                AppUtility.showAlertWithProperty("Alert", messageString: "Select City")
                return
            }
            if streetSelected != true {
                AppUtility.showAlertWithProperty("Alert", messageString: "Select Street")
                return
            }
        }
        else{
            if citySelected != true {
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
                    option = newRipaViewModel.createObj(mainQuestId: questionId, ripaID: String(questionID!), optionValue: educode.educationCodeDesc, physical_attribute: educode.physicalAttribute, description: educode.educationCode, isSelected: true, mainQuestOrder: orderId!)
                    selectedViolationArray.append(setMainQuestIdAndOptn(optn: option as! Questionoptions1))
                    optionsArray![indexPath!].isSelected = false
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
                    option = newRipaViewModel.createObj(mainQuestId: questionId, ripaID: String(questionID!), optionValue: educode.educationCodeSubsectionDesc, physical_attribute: educode.physicalAttribute, description: educode.educationCodeSubsection, isSelected: true, mainQuestOrder: orderId!)
                    optionsArray![indexPath!].isSelected = false
                    //optionsArray![indexPath!].order_number = orderId!
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
            questionID =  Int((optionsArray![indexPath!].questionoptions![1] ).cascade_ripa_id)
            
            for violation in violationTypeArray{
                if violation.isSelected{
                    hasVal = true
                    violation.order_number = orderId!
                    violation.mainQuestOrder = orderId!
                    //optionsArray![indexPath!].order_number = orderId!
                }
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
        
        if listType == "Violation"{
            
            questionID =  Int((optionsArray![indexPath!].questionoptions![0] ).cascade_ripa_id)
            if list!.count > 0{
                if questionArray![questNumber!].question_code == "14"{
                    selectedViolationArray2.removeAll()
                }
            }
            for violation in list! as! [ViolationsResult]{
                if violation.isSelected{
                    option = newRipaViewModel.createObj(mainQuestId: questionId, ripaID: String(questionID!), optionValue: violation.violationDisplay, physical_attribute: "", description: violation.offense_code, isSelected: true, mainQuestOrder: orderId!)
                    
                    selectedViolationArray.append(option as! Questionoptions1)
                    selectedViolationArray2.append(option as! Questionoptions1)
                    
                    optionsArray![indexPath!].isSelected = false
                    hasVal = true
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
                                questionOption.isSelected = true
                            }
                        }
                    }
                }
            }
            
            if questionArray![questNumber!].question_code == "14"{
                addToPreSelectedViolArr(indexPath:indexPath!)
                //                let ViolationFor = optionsArray![indexPath!].option_value
                //                let optionId = optionsArray![indexPath!].option_id
                //                violationDict = ["ViolationFor":ViolationFor, "optionID": optionId ,"ViolationList": selectedViolationArray2]
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
            if listType == "City"{
                questionID = Int(optionsArray![0].cascade_ripa_id)!
            }
            if listType == "Location"{
                questionID = Int(optionsArray![1].cascade_ripa_id)!
            }
            if listType == "School"{
                questionID = Int(optionsArray![5].cascade_ripa_id)!
            }
            if listType == "Intersection"{
                questionID = Int(optionsArray![3].cascade_ripa_id)!
            }
        }
        
        
        
        
        // for question in cascadeQuestionArray!{
        //  if Int(question.id) == questionID{
        let question = newRipaViewModel.getCascadeQuestionUsingId(questionID: questionID!)
        if  listType != "EducationSubCode"{
            question.questionoptions!.removeAll()
        }
        if listType == "ViolationType"{
            question.questionoptions = violationTypeArray
            optionsArray![indexPath!].isSelected = hasVal
            
            // (optionsArray![indexPath!].questionoptions![1] as! Questionoptions1).isSelected = hasVal
        }
        else if  listType == "EducationSubCode"{
            question.questionoptions?.append(option as! Questionoptions1)
        }
        else if listType != "Violation" && listType != "EducationCode"{
            option = getLocationObj(list: list, listType: listType)
            question.questionoptions!.append(setMainQuestIdAndOptn(optn: option as! Questionoptions1))
        }
        else{
            question.questionoptions = selectedViolationArray
        }
        question.order_number = orderId!
        //    }
        //  }
        if educationCodeId == "1"{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.openEducationSubCodeList()
            }
        }
        
        if listType == "City"{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.openList(index:1)
            }
        }
        
        cascadeArray.removeAll()
        checkMandatorySelection()
        tableView.reloadData()
        
    }
    
    
    func resetLocation(onGPS:Bool){
        if onGPS == false{
            removeOptFromCascade(index: 1)
            removeOptFromCascade(index: 3)
        }
        removeOptFromCascade(index: 2)
        removeOptFromCascade(index: 5)
        
        optionsArray![4].isSelected = false
        optionsArray![4].isExpanded = false
        optionsArray![4].questionoptions![0].isSelected = false
        optionsArray![4].questionoptions![1].isSelected = false
        AppConstants.isSchoolSelected = ""
        AppConstants.schoolName = ""
        resetIsK12Options()
        is_k12 = false
    }
    
    
    
    func getLocationObj(list:[Any]?, listType: String)->Questionoptions1{
        var option:Questionoptions1?
        for listObj in list! {
            if listType == "City"{
                if (listObj as! CityResult).isSelected{
                    option = newRipaViewModel.createObj(mainQuestId: questionId, ripaID: optionsArray![0].cascade_ripa_id, optionValue: (listObj as! CityResult).city_name, physical_attribute: "", description: "", isSelected: true, mainQuestOrder: orderId!)
                    if cityID != (listObj as! CityResult).city_id{
                        resetLocation(onGPS: false)
                    }
                    cityID = (listObj as! CityResult).city_id
                    // ripaActivity?.City = (listObj as! CityResult).city_name
                    AppConstants.city = (listObj as! CityResult).city_name
                    option = setMainQuestIdAndOptn(optn: option!)
                }
            }
            if listType == "Location" || listType == "Intersection" {
                var ripaId = optionsArray![1].cascade_ripa_id
                
                if (listObj as! LocationResult).isSelected{
                    if listType == "Location"{
                        streetName = (listObj as! LocationResult).location
                    }
                    if listType == "Intersection"{
                        ripaId = optionsArray![3].cascade_ripa_id
                        intersectionName = (listObj as! LocationResult).location
                    }
                    option = newRipaViewModel.createObj(mainQuestId: questionId, ripaID: ripaId,optionValue: (listObj as! LocationResult).location, physical_attribute: "", description: "", isSelected: true, mainQuestOrder: orderId!)
                    option = setMainQuestIdAndOptn(optn: option!)
                }
            }
            if listType == "School"{
                if (listObj as! SchoolResult).isSelected{
                    option = newRipaViewModel.createObj(mainQuestId: questionId, ripaID: optionsArray![5].cascade_ripa_id,optionValue: (listObj as! SchoolResult).school, physical_attribute: "", description: (listObj as! SchoolResult).cdsCode , isSelected: true, mainQuestOrder: orderId!)
                 }
            }
        }
        
        
        return option!
    }
    
    
    
    func consensualEncounter()->Bool{
        var conducted = true
        if questionArray![questNumber!].question_code == "16"{
            let question = newRipaViewModel.getQuestionUsingQuestionCode(question_code: 14)
            for option in question.questionoptions!{
                if option.physical_attribute == "6" && option.isSelected == true{
                    conducted = false
                    for option in optionsArray!{
                        if (option.physical_attribute == "18" || option.physical_attribute == "20") && option.isSelected{
                            conducted = true
                            return conducted
                     }
                   }
                }
            }
        }
//        else{
//            conducted = true
//        }
        return conducted
    }
    
    
    
    @objc func selectOption(sender: UIButton){
        trackApplicationTime()
        let physicalAttribute = optionsArray![sender.tag].physical_attribute
 
        if questionArray![questNumber!].question_code == "19" && (physicalAttribute == "2" || physicalAttribute == "3"){
            let question = newRipaViewModel.getQuestionUsingQuestionCode(question_code: 18)
            for option in question.questionoptions!{
                if option.physical_attribute == "1" && option.isSelected{
                    AppUtility.showAlertWithProperty("Alert", messageString: "You have selected None option for question(Contraband or Evidence Discovered). So you can't select Evidence or Contraband option of current question.")
                    return
                }
            }
         }
        
        
        if questionArray![questNumber!].question_code == "18" && (physicalAttribute == "1"){
            let question = newRipaViewModel.getQuestionUsingQuestionCode(question_code: 19)
            for option in question.questionoptions!{
                if (option.physical_attribute == "2" || option.physical_attribute == "3") && option.isSelected{
                    AppUtility.showAlertWithProperty("Alert", messageString: "You have selected Evidence or Contraband option for question(Basis for property seizure). So you have to select option other than None for current question.")
                    return
                }
            }
         }
        
        
        if questionArray![questNumber!].question_code == "17" && physicalAttribute == "12"{
            let question = newRipaViewModel.getQuestionUsingQuestionCode(question_code: 16)
            for option in question.questionoptions!{
                if option.physical_attribute == "20" && !option.isSelected{
                    AppUtility.showAlertWithProperty("Alert", messageString: "You haven't selected Search of property was conducted for question(Action taken by officer during stop). So you can't select this option for current question.")
                    return
                }
            }
         }
        
        
        
        checkForSingleSelection(index: sender.tag)
        addAssignmentOfOfficer(index: sender.tag)
        checkMandatorySelection()
        checkDependentQuestions()
        
        //  let optionId = optionsArray![sender.tag].option_id
       
        if questionArray![questNumber!].question_code == "16" && (physicalAttribute == "18" || physicalAttribute == "20"){
            DispatchQueue.background(delay: 0.3, completion:{ [self] in
                openViolationPopup(index: sender.tag, popupFor: "Consent")
            })
            if physicalAttribute == "20" && optionsArray![sender.tag].isSelected == false{
                let question = newRipaViewModel.getQuestionUsingQuestionCode(question_code: 17)
                for option in question.questionoptions!{
                    if option.physical_attribute == "12"{
                        option.isSelected = false
                    }
                }
            }
        }
        
        if questionArray![questNumber!].question_code == "16" && (physicalAttribute == "21"){
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
        print(AppConstants.applicationtime)
        print(String(MyGlobalTimer.sharedTimer.time))
        AppConstants.applicationtime = String(Int(AppConstants.applicationtime) ?? 0 + MyGlobalTimer.sharedTimer.time)
        print(AppConstants.applicationtime)
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
                if ViolationFor!.contains("Traffic"){
                    if optionVal.contains("Warning") || physicalAttribute == "2" {
                        question = newRipaViewModel.getCascadeQuestionUsingId(questionID: questionId!)
                        addOptns = true
                    }
                    else if optionVal.contains("Citation") || physicalAttribute == "3"{
                        question = newRipaViewModel.getCascadeQuestionUsingId(questionID: questionId!)
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
                        
                        let option = newRipaViewModel.createObj(mainQuestId: self.questionId, ripaID: question!.id, optionValue: viol.option_value, physical_attribute: viol.physical_attribute, description: viol.optionDescription, isSelected: true, mainQuestOrder: orderId!)
                        
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
        if questionArray![questNumber!].question_code == "14"{
            
            let questionId = Int((optionsArray![section].questionoptions![0]).cascade_ripa_id)
            
            var question:QuestionResult1?
            let violationList:[Questionoptions1] = selectedViolationArray2
            question = newRipaViewModel.getCascadeQuestionUsingId(questionID: questionId!)
            if question?.questionoptions!.count ?? 2 < 1{
                if violationList.count > 0 {
                    violationDict = ["ViolationFor":"Traffic", "optionID": "" ,"ViolationList": violationList]
                    var optionList = [Questionoptions1]()
                    for viol in violationList{
                        let option = newRipaViewModel.createObj(mainQuestId: self.questionId, ripaID: question!.id, optionValue: viol.option_value, physical_attribute: viol.physical_attribute, description: viol.optionDescription, isSelected: true, mainQuestOrder: orderId!)
                        
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
    
    
    
    @objc  private func hideSection(sender: UIButton) {
        let section = sender.tag
        var addOptns = false
        trackApplicationTime()
        optionsArray![sender.tag].isExpanded  =  !optionsArray![sender.tag].isExpanded
        
        func indexPathsForSection() -> [IndexPath] {
            var indexPaths = [IndexPath]()
            
            for row in 0..<self.optionsArray![section].questionoptions!.count {
                indexPaths.append(IndexPath(row: row, section: section))
            }
            return indexPaths
        }
        
        
        if optionsArray![section].isExpanded{
            
            if questionArray![questNumber!].question_code == "21"{
                addOptns = addViolationForResultOfStop(section:section)
            }
            if questionArray![questNumber!].question_code == "14" && optionsArray![section].physical_attribute == "1"{
                addOptns = addViolationForReasonForStop(section:section)
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
            self.hiddenSections.insert(section)
            self.tableView.deleteRows(at: indexPathsForSection(),
                                      with: .fade)
        }
        
        if !addOptns{
            tableView.reloadSections(IndexSet(integer: section), with: .none)
        }
    }
    
}



extension NewRipaViewController:GPSLocationDelegate{
    
    @objc func getCityFromGPS(sender: UIButton){
        gpsLocation.delegate = self
        gpsLocation.getGPSLocation()
        
    }
    
    
    func fetchedLocationDetails(location: CLLocation, countryCode: String, city: String, street: String, intersection:String ,county: String) {
        print(location,countryCode,city)
        AppConstants.lati = String(location.coordinate.latitude)
        AppConstants.longi = String(location.coordinate.longitude)
        
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
                    if cityID == citi.city_id {
                        AppUtility.showAlertWithProperty("Alert", messageString: "City already selected.")
                        return
                    }
                    
                    let cityQuest = newRipaViewModel.getCascadeQuestionUsingQuestionCode(questionCode: "C6")
                    cityQuest.questionoptions!.removeAll()
                    let obj = newRipaViewModel.createObj(mainQuestId: questionId, ripaID: cityQuest.id, optionValue: citi.city_name, physical_attribute: "", description: "", isSelected: true, mainQuestOrder: "1")
                    cityQuest.questionoptions!.append(obj)
                    cityQuest.order_number = orderId!
                    
                    let streetQuest = newRipaViewModel.getCascadeQuestionUsingQuestionCode(questionCode: "C7")
                    streetQuest.questionoptions!.removeAll()
                    if street != "" {
                        let stretObj = newRipaViewModel.createObj(mainQuestId: questionId, ripaID: streetQuest.id, optionValue:street.uppercased(), physical_attribute: "", description: "", isSelected: true, mainQuestOrder: "1")
                        streetQuest.questionoptions!.append(stretObj)
                        streetQuest.order_number = orderId!
                    }
                    
                    
                    let intersectionQuest = newRipaViewModel.getCascadeQuestionUsingQuestionCode(questionCode: "C26")
                    intersectionQuest.questionoptions!.removeAll()
                    if intersection != "" {
                        let intersectionObj = newRipaViewModel.createObj(mainQuestId: questionId, ripaID: intersectionQuest.id, optionValue:intersection.uppercased(), physical_attribute: "", description: "", isSelected: true, mainQuestOrder: "1")
                        intersectionQuest.questionoptions!.append(intersectionObj)
                        intersectionQuest.order_number = orderId!
                    }
                    
                    
                    resetLocation(onGPS: true)
                    
                    cityID = citi.city_id
                    cityFound = true
                    countyLbl.text = (county).uppercased()
                    
                    AppManager.getLastSavedLoginDetails()?.result?.county_id = tempCountyId!
                    tableView.reloadData()
                    return
                }
                
            }
            print(AppConstants.ripaCounty)
            if cityFound == false && AppConstants.ripaCounty == "Y"{
                AppUtility.showAlertWithProperty("Alert", messageString: "Selected county does not have your current city. Select city from the list or change county.")
            }
        }
        else if countyFound == false{
            AppUtility.showAlertWithProperty("Alert", messageString: "Current county not available in the county list. Please select county from the list.")
        }
        
    }
    
    
    func failedFetchingLocationDetails(error: Error) {
        print(error)
    }
}
