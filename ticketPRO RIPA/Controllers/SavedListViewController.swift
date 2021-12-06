//
//  SavedListViewController.swift
//  ticketPRO RIPA
//
//  Created by Nitin Singh on 27/05/21.
//

import UIKit
import SafariServices
import EzPopup


class SavedListViewController: UIViewController,PopupViewControllerDelegate, UITableViewDelegate, UITableViewDataSource,SavedListModelDelegate,FilterPopupDelegate {
   
    
    
    
    var savedRipaList = [RipaTempMaster]()
    var dashboardViewModel = DashboardViewModel()
    var questionsArray : [QuestionResult1]?
    var cascadeQuestionsArray : [QuestionResult1]?
    let db = SqliteDbStore()
    var ripaIndex:Int?
    var savedListViewModel = SavedListViewModel()
    var rejectedApplication:RejectedApplication?
    let filterPopup = FilterPopup.instantiateOption()
    var personArray: [[String: Any]] = []
    var saveRipaStatus:String?
    var filterFor = ""
    var newRipaViewModel = NewRipaViewModel()
    
    var filterList = [FilterList]()
    var indexForTemplate:Int?
    
     let generator = UIImpactFeedbackGenerator(style: .heavy)
  
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var refreshBtn: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
 
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "SavedListTableViewCell", bundle: nil), forCellReuseIdentifier: "SavedListTableViewCell")
        
        self.tableView.estimatedRowHeight = 48.0
        self.tableView.rowHeight = UITableView.automaticDimension
        
        
        filterList = [FilterList(statusName: "Pending Review", isSelected: false),
                      FilterList(statusName: "Approved", isSelected: false),
                       FilterList(statusName: "Resume", isSelected: false),
                       FilterList(statusName: "Saved", isSelected: false),
                      FilterList(statusName: "Edit Required", isSelected: false),
                      FilterList(statusName: "Created", isSelected: false)]
    }
    
    // FilterList(statusName: "Saved", isSelected: false),
    
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        
        if AppConstants.theme == "1"{
            overrideUserInterfaceStyle = .dark
        }
        else{
            overrideUserInterfaceStyle = .light
            AppConstants.theme = "0"
        }
        
        AppManager.removeData()
        db.openDatabase()
        db.createTable(insertTableString: db.createUseSaveRipaOptionTable)
        reloadData()
        AppConstants.trafficId = ""
    }
    
    
    func respondToLPGesture(gesture: UIGestureRecognizer) {

        if(gesture.state == UIGestureRecognizer.State.began) {

        }
        if(gesture.state == UIGestureRecognizer.State.ended) {

        }
    }
    
    
    // Handle Long Press
    @objc func longPressed(sender: UILongPressGestureRecognizer) {
 
         if sender.state == UIGestureRecognizer.State.began {
             let touchPoint = sender.location(in: self.tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
 
                showTemplateAlert(index:indexPath.row)
                print("Long pressed row: \(indexPath.row)")
                generator.impactOccurred()
            }
        }
    }
  
    
    
    func reloadData(){
        AppUtility.showProgress(nil, title:nil)
        let userId =  "AND userid is " + (AppManager.getLastSavedLoginDetails()?.result?.userid)!
        let statusEditReq = "\"Edit Required\""
        let pendingReview = "\"Pending Review\""
        let approved = "\"Approved\""
        //   \(userId)
        
        if filterFor == "Edit Required"{
            savedRipaList = db.getRipaTempMaster(tableName: "SELECT * FROM ripaTempMasterTable WHERE status is \(statusEditReq) AND mainStatus is NOT 1 \(userId)") ?? []
            filterList[4].isSelected = true
        }
        else if filterFor == "Pending Review"{
            savedRipaList = db.getRipaTempMaster(tableName: "SELECT * FROM ripaTempMasterTable WHERE status is \(pendingReview) AND mainStatus is NOT 1 \(userId)") ?? []
            filterList[0].isSelected = true
        }
        else if filterFor == "Approved"{
          //  ripaTempMasterTable WHERE status is \(statusEditReq) AND mainStatus is NOT 1
            savedRipaList = db.getRipaTempMaster(tableName: "SELECT * FROM ripaTempMasterTable WHERE status is \(approved) AND mainStatus is NOT 1 \(userId)") ?? []
            filterList[1].isSelected = true
        }
        else{
            savedRipaList = db.getRipaTempMaster(tableName: "SELECT * FROM ripaTempMasterTable WHERE mainStatus is NOT 1 \(userId) order by stopDate DESC") ?? []
        }
        
 
        tableView.reloadData()
        filterFor = ""
        
        AppUtility.hideProgress()
    }
    
    
 
    
    
    
    @IBAction func actionSubmit(_ sender: Any) {
        reloadData()
    }
    
    @IBAction func actionBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func actionTopBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func actionFilter(_ sender: Any) {
        openFilterPopup()
    }
    
    
    
    func convertDateFormater(date: String){
        if date != ""{
            let inputFormatter = DateFormatter()
            inputFormatter.dateFormat = "MM/dd/yyyy HH:mm"
            let showDate = inputFormatter.date(from: date)
            inputFormatter.dateFormat = "MM/dd/yyyy"
            var resultString = inputFormatter.string(from: showDate!)
            AppConstants.date = resultString
            
            inputFormatter.dateFormat = "HH:mm"
            resultString = inputFormatter.string(from: showDate!)
            AppConstants.time = resultString
        }
    }
    
    
    
    func getonlydate(date: String)->String{
        var resultString = ""
        let date = date.components(separatedBy: ("."))[0]
        if date != "" && date != " "{
            let inputFormatter = DateFormatter()
            inputFormatter.dateFormat = "MM/dd/yyyy HH:mm"
            let showDate = inputFormatter.date(from: date)
            inputFormatter.dateFormat = "MM/dd/yyyy"
            resultString = inputFormatter.string(from: showDate!)
        }
        return resultString
    }
    
    
    func getonlyTime(date: String)->String{
        var resultString = ""
        let date = date.components(separatedBy: ("."))[0]
        if date != ""{
            let inputFormatter = DateFormatter()
            inputFormatter.dateFormat = "HH:mm:ss"
            let showDate = inputFormatter.date(from: date)
            inputFormatter.dateFormat = "HH:mm"
            resultString = inputFormatter.string(from: showDate!)
        }
        return resultString
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedRipaList.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SavedListTableViewCell", for: indexPath as IndexPath) as! SavedListTableViewCell
        let status = savedRipaList[indexPath.row].status
         cell.dateLbl.text = savedRipaList[indexPath.row].stopDate
        
        if savedRipaList[indexPath.row].location != ""{
            let date = getonlydate(date: savedRipaList[indexPath.row].stopDate) + " " + savedRipaList[indexPath.row].stopTime
            cell.dateLbl.text = date + "\n\(savedRipaList[indexPath.row].location)"
        }
        
        cell.note.text = savedRipaList[indexPath.row].note
        cell.statusLbl.text = status
        
        if status == "Saved"{
            cell.view.backgroundColor = #colorLiteral(red: 0.8024624586, green: 0.9411919713, blue: 0.9451370835, alpha: 1)
            cell.textView.backgroundColor = #colorLiteral(red: 0.1427696049, green: 0.7019013762, blue: 0.7181896567, alpha: 1)
            cell.leftstyleview.backgroundColor = #colorLiteral(red: 0.1427696049, green: 0.7019013762, blue: 0.7181896567, alpha: 1)
            cell.note.textColor = #colorLiteral(red: 0.1427696049, green: 0.7019013762, blue: 0.7181896567, alpha: 1)
            let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressed(sender:)))
            cell.view.addGestureRecognizer(longPressRecognizer)
            cell.callTypeTxt.attributedText = setAttributedTextForCallType(index: indexPath.row)
        }
        else if status == "Created" {
            cell.view.backgroundColor = #colorLiteral(red: 0.9724934697, green: 0.8666279912, blue: 0.9441578984, alpha: 1)
            cell.textView.backgroundColor = #colorLiteral(red: 0.7705615163, green: 0.4350548387, blue: 0.6462814808, alpha: 1)
            cell.leftstyleview.backgroundColor = #colorLiteral(red: 0.7705615163, green: 0.4350548387, blue: 0.6462814808, alpha: 1)
            cell.note.textColor = #colorLiteral(red: 0.7705615163, green: 0.4350548387, blue: 0.6462814808, alpha: 1)
            cell.callTypeTxt.attributedText = setAttributedTextForCallType(index: indexPath.row)
        }
        else if status == "Resume" {
            cell.view.backgroundColor = #colorLiteral(red: 0.9064636827, green: 0.9215990305, blue: 0.9337291121, alpha: 1)
            cell.textView.backgroundColor = #colorLiteral(red: 0.3620900214, green: 0.5682560802, blue: 0.7757706046, alpha: 1)
            cell.leftstyleview.backgroundColor = #colorLiteral(red: 0.3620900214, green: 0.5682560802, blue: 0.7757706046, alpha: 1)
            cell.note.textColor = #colorLiteral(red: 0.3620900214, green: 0.5682560802, blue: 0.7757706046, alpha: 1)
            cell.callTypeTxt.attributedText = setAttributedTextForCallType(index: indexPath.row)
        }
        else if status == "Pending Review"{
            cell.view.backgroundColor = #colorLiteral(red: 0.9806935191, green: 0.8983079195, blue: 0.7415288091, alpha: 1)
            cell.textView.backgroundColor = #colorLiteral(red: 0.9385960698, green: 0.6358305812, blue: 0.07396490127, alpha: 1)
            cell.leftstyleview.backgroundColor = #colorLiteral(red: 0.9385960698, green: 0.6358305812, blue: 0.07396490127, alpha: 1)
            cell.note.textColor = #colorLiteral(red: 0.9385960698, green: 0.6358305812, blue: 0.07396490127, alpha: 1)
            let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressed(sender:)))
            cell.view.addGestureRecognizer(longPressRecognizer)
            cell.callTypeTxt.attributedText = setAttributedTextForCallType(index: indexPath.row)
        }
        else if status == "Approved"{
            cell.view.backgroundColor = #colorLiteral(red: 0.9091035724, green: 0.9883603454, blue: 0.9224985242, alpha: 1)
            cell.textView.backgroundColor = #colorLiteral(red: 0.1629365087, green: 0.8004216552, blue: 0.2451622188, alpha: 1)
            cell.leftstyleview.backgroundColor = #colorLiteral(red: 0.1629365087, green: 0.8004216552, blue: 0.2451622188, alpha: 1)
            cell.note.textColor = #colorLiteral(red: 0.1629365087, green: 0.8004216552, blue: 0.2451622188, alpha: 1)
            cell.callTypeTxt.attributedText = setAttributedTextForCallType(index: indexPath.row)
        }
        else {
            cell.view.backgroundColor = #colorLiteral(red: 0.9895220399, green: 0.9255647063, blue: 0.9212974906, alpha: 1)
            cell.textView.backgroundColor = #colorLiteral(red: 0.9808295369, green: 0.6276214719, blue: 0.6192635298, alpha: 1)
            cell.leftstyleview.backgroundColor = #colorLiteral(red: 0.9808295369, green: 0.6276214719, blue: 0.6192635298, alpha: 1)
            cell.note.textColor = #colorLiteral(red: 0.9808295369, green: 0.6276214719, blue: 0.6192635298, alpha: 1)
         }
        return cell
    }
    
    
    
    
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let note = savedRipaList[indexPath.row].note
        if note == ""{
            selectFunc(indexPath:indexPath.row)
        }
        else{
            showAlert(index:indexPath.row)
        }
        
    }
    
    
    func showTemplateAlert(index:Int){
        let alert = UIAlertController(title: "Set this RIPA as a template.", message: savedRipaList[index].note, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { [self] action in
            
            indexForTemplate = index
            savedListViewModel.savedListModelDelegate = self
            savedListViewModel.forTemplate = true
            savedListViewModel.getApprovedOrPendingPram(activityId:self.savedRipaList[index].activityId)
            
        }         )
        )
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    func showAlert(index:Int){
        let alert = UIAlertController(title: "Note", message: savedRipaList[index].note, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Continue", style: UIAlertAction.Style.default, handler: { action in
            
            self.selectFunc(indexPath:index)
            
        }         )
        )
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    func selectFunc(indexPath:Int){
        
        saveRipaStatus = savedRipaList[indexPath].status
        AppConstants.status = saveRipaStatus!
        AppConstants.citation = savedRipaList[indexPath].citationNumber
        AppConstants.applicationtime = "0"
        AppConstants.deviceid = "0"
        AppConstants.citation = ""
        
        setDispatchConstant(indexPath:indexPath)
        
        if  saveRipaStatus == "Saved" || saveRipaStatus == "Edit Required" || saveRipaStatus == "Resume" || saveRipaStatus == "Template"{
            print(savedRipaList[indexPath].timeTaken)
            let timeInSec = (Int(savedRipaList[indexPath].timeTaken) ?? 1) * 60
            AppConstants.applicationtime = String(timeInSec)
            print(AppConstants.applicationtime)
            
//            if saveRipaStatus == "Template"{
//            setConstant(indexPath: indexPath)
//            }
            
            if savedRipaList[indexPath].countyId != ""{
            AppManager.getLastSavedLoginDetails()?.result?.county_id = savedRipaList[indexPath].countyId
             }
            else{
                AppManager.getLastSavedLoginDetails()?.result?.county_id = UserDefaults.standard.string(forKey: "defaultCountyId") ?? "1"
                print(AppManager.getLastSavedLoginDetails()?.result?.county_id)
             }
            AppManager.saveLoginDetails()
            print( AppManager.getLastSavedLoginDetails()?.result?.county_id)
         }
        
        if saveRipaStatus == "Approved" || saveRipaStatus == "Pending Review" || saveRipaStatus == "Saved" {
            let activity_id = savedRipaList[indexPath].activityId
 
            setConstant(indexPath: indexPath)
            
             savedListViewModel.savedListModelDelegate = self
            self.savedListViewModel.forTemplate = false
            savedListViewModel.getApprovedOrPendingPram(activityId:activity_id)
            
         }
        else{
           
             if saveRipaStatus == "Edit Required"{
                let activity_uid = savedRipaList[indexPath].tempType
                
                savedListViewModel.savedListModelDelegate = self
                self.savedListViewModel.forTemplate = false
                savedListViewModel.getRejectedRipaPram(uid: activity_uid)
                
                return
            }
            
            if saveRipaStatus != "Saved"{
                AppConstants.key = savedRipaList[indexPath].key
                ripaIndex = indexPath
                
                if saveRipaStatus != "Created" {
                    
                    personArray = dashboardViewModel.getUseSavedRipa(key: savedRipaList[indexPath].key)
                  
                    convertDateFormater(date: savedRipaList[indexPath].ticketDate)
                    let dur = Date().calculateTime(from_date: savedRipaList[indexPath].ticketDate, to_date:  savedRipaList[indexPath].declarationDate)
                    AppConstants.duration = dur
                    
                    if saveRipaStatus == "Resume"{
                        AppConstants.duration = savedRipaList[indexPath].stopDuration
                        if  AppConstants.duration == "0" {
                            AppConstants.duration = ""
                        }
                    }
                    
                    AppConstants.city =  savedRipaList[indexPath].city
                    print(AppConstants.city)
                    AppConstants.address =  savedRipaList[indexPath].location
                    AppConstants.key = savedRipaList[indexPath].key
                    AppConstants.trafficId = savedRipaList[indexPath].skeletonID
                    AppConstants.notes = savedRipaList[indexPath].note
                    
                }
                
                if saveRipaStatus == "Created" {
                    AppConstants.city =  savedRipaList[indexPath].city
                    print(AppConstants.city)
                    AppConstants.key = savedRipaList[indexPath].key
                    AppConstants.trafficId = savedRipaList[indexPath].skeletonID
                    AppConstants.notes = savedRipaList[indexPath].note
                    AppConstants.duration = savedRipaList[indexPath].stopDuration
                    AppConstants.date = savedRipaList[indexPath].stopDate
                    convertDateFormater(date: savedRipaList[indexPath].stopDate)
                    AppConstants.address = savedRipaList[indexPath].location
                    
                    AppConstants.deviceid = savedRipaList[indexPath].deviceid
                    AppConstants.citation = savedRipaList[indexPath].citationNumber
                }
                
                if saveRipaStatus == "Template"{
                     newRipaViewModel.questionsArray = personArray[0]["QuestionArray"] as? [QuestionResult1]
                    newRipaViewModel.cascadeQuestionArray = personArray[0]["CascadeQuestionArray"] as? [QuestionResult1]
                    personArray[0]["SelectedOption"] = newRipaViewModel.makeSelectedOptionList()
                     self.performSegue(withIdentifier: "ShowPreview", sender: self)
                }
                else{
                self.performSegue(withIdentifier: "ShowRipaView", sender: self)
                }
            }
        }
    }
    
    
    func setConstant(indexPath:Int){
         AppConstants.address = savedRipaList[indexPath].location
        AppConstants.city =  savedRipaList[indexPath].city
        AppConstants.key = savedRipaList[indexPath].key
        ripaIndex = indexPath
        AppConstants.date = getonlydate(date: savedRipaList[indexPath].stopDate)
        AppConstants.time = savedRipaList[indexPath].stopTime
        AppConstants.duration = savedRipaList[indexPath].stopDuration
        AppConstants.notes = savedRipaList[indexPath].note
        AppConstants.activityID = savedRipaList[indexPath].activityId
        print(AppConstants.activityID)
        
    }
    
    
    func setDispatchConstant(indexPath:Int){
        AppConstants.call_number = savedRipaList[indexPath].callNumber
        AppConstants.onscene_time =  savedRipaList[indexPath].onsceneTime
        AppConstants.clear_time_of_the_Offrcer = savedRipaList[indexPath].clearTimeOfOfficer
        ripaIndex = indexPath
        AppConstants.overall_call_clear_time = savedRipaList[indexPath].overallCallClearTime
        AppConstants.call_type = savedRipaList[indexPath].callType
        AppConstants.unitId = savedRipaList[indexPath].unitId
        AppConstants.zone = savedRipaList[indexPath].zone
        
      }
    
     
    
    
    
    func proceedToRejectedView(applicationData: RejectedApplication?) {
        rejectedApplication = applicationData
        self.performSegue(withIdentifier: "RejectedApplicationView", sender: self)
    }
    
  
    var previewPersonArray = [RipaPerson]()
    
    func proceedToPreviewScreen(previewPram: [RipaPerson], forTemplate: Bool?) {
        previewPersonArray = previewPram
        personArray = savedListViewModel.createPersonDict(personarray:previewPersonArray)
         if forTemplate == true{
            saveTemplateDetail(templatePersonArray: previewPram)
            return
        }
        
        if saveRipaStatus == "Saved"{
            self.performSegue(withIdentifier: "ShowRipaView", sender: self)
        }
        else{
            self.performSegue(withIdentifier: "ShowPreview", sender: self)
        }
    }
    
    
    func saveTemplateDetail(templatePersonArray: [RipaPerson]){
        
        let template = "\"Template\""
        db.deleteAllfrom(table: "ripaTempMasterTable WHERE status  = \(template)")
        db.deleteAllfrom(table: "saveRipaPersonTable WHERE key = \(0)")
        db.deleteAllfrom(table: "useSaveRipaOptionsTable WHERE key = \(0)")
        AppConstants.status = "Template"
        
        AppConstants.applicationtime = "0"
        savedRipaList[indexForTemplate!].activityId = "0"
        savedRipaList[indexForTemplate!].key = "0"
        savedRipaList[indexForTemplate!].status = "Template"
         db.insertRipaTempMaster(ripaResponse: savedRipaList[indexForTemplate!], tableName: db.ripaTempMaster)
 
        var ad = templatePersonArray[0]
        ad.key = "0"
            
            db.insertRipaPerson(ripaPerson: ad, tableName: "saveRipaPersonTable")
            
            let response = personArray[0]
            var questionArray = (response["QuestionArray"] as! [QuestionResult1])
            let cascadeOptionsArray = (response["CascadeQuestionArray"] as! [QuestionResult1])
            questionArray.append(contentsOf: cascadeOptionsArray)
             for question in questionArray{
                if question.question_code == "5"{
                    if question.questionoptions!.count > 5{
                        question.questionoptions?.removeLast()
                    }
                }
                for options in question.questionoptions!{
                     db.insertOptions(options: options, tableName: "useSaveRipaOptionsTable", personID: ad.person_name, key: ad.key)
                 }
            }
         reloadData()
 
    }
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        let segueID = segue.identifier
        if(segueID! == "ShowRipaView"){
            let vc = segue.destination as! NewRipaViewController
            
            vc.viewType = "UseSaveRipa"
            vc.saveRipaStatus = saveRipaStatus
            vc.personArray = personArray
            vc.savedRipaList = savedRipaList[ripaIndex!]
        }
        
        if(segueID! == "RejectedApplicationView"){
            let vc = segue.destination as! RejectedApplicationViewController
            vc.rejectedApplication = rejectedApplication
        }
        
        if(segueID! == "ShowPreview"){
            let vc = segue.destination as! PreviewViewController
            vc.personArray = personArray
            //   vc.previewPersonArray = self.previewPersonArray
            vc.personIndex = 0
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return  UITableView.automaticDimension
    }
    
    
    
    
    func openFilterPopup(){
        guard let selectfilterPopup = filterPopup else { return }
        selectfilterPopup.filterPopupDelegate = self
        
        selectfilterPopup.filterList = filterList
 
        let popupVC = PopupViewController(contentController: selectfilterPopup, popupWidth: UIScreen.main.bounds.size.width-30, popupHeight: CGFloat(50 * filterList.count) + 224)
        popupVC.cornerRadius = 5
        popupVC.delegate = self
        present(popupVC, animated: true, completion: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "optionFilter"), object: nil)
    }
    
    
    
    
    
    func selectedOptionFromPopup(filteredList: [FilterList],fromDate:String,toDate:String) {
        self.filterList = filteredList
        var arr:[String] = []
        var statusString = ""
        var i = 0
        for status in filteredList{
            if status.isSelected == true{
                // statusString = statusString + status.statusName
                let str =  "\"\(status.statusName)\""
                arr.append(str)
                i += 1
            }
        }
        statusString = arr.joined(separator: ",")
        let efe = "\"\(toDate + "%")\""
        let newfromDate = "\"\(fromDate)\""
        let newtoDate = "\"\(toDate)\""
 
      
        if fromDate != "" && toDate != "" && i>0 {
           
            savedRipaList = db.getRipaTempMaster(tableName:"select * from ( Select * from ripaTempMasterTable t where t.stopDate  LIKE \(efe) UNION Select * from ripaTempMasterTable t where  t.stopDate between \(newfromDate) and \(newtoDate)) ts where ts.status in (\(statusString))") ?? []
            tableView.reloadData()
         }
        else if fromDate != "" && toDate != "" && i<1{
            savedRipaList = db.getRipaTempMaster(tableName:"select * from ( Select * from ripaTempMasterTable t where t.stopDate  LIKE  \(efe)  UNION Select * from ripaTempMasterTable t where  t.stopDate between  \(newfromDate) and \(newtoDate))") ?? []
            tableView.reloadData()
        }
        else if i > 0 {
            savedRipaList = db.getRipaTempMaster(tableName: "SELECT * FROM ripaTempMasterTable WHERE status IN (\(statusString)) AND mainStatus is NOT 1 order by stopDate DESC") ?? []
            tableView.reloadData()
        }
        else{
            reloadData()
        }
 
    }
    
    
    
    func setAttributedTextForCallType(index:Int) -> NSMutableAttributedString{
        
        let callNumber = savedRipaList[index].callNumber
        let callType = savedRipaList[index].callType
        let unitID = savedRipaList[index].unitId
        
         let yourAttributes = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 15)]
        
        let myString = NSMutableAttributedString()
        let seperator = NSMutableAttributedString(string: " | ", attributes:yourAttributes)
        
        if callNumber != ""{
            let attributedcallNumber = NSMutableAttributedString(string: "Call Number: ", attributes:yourAttributes)
            myString.append(attributedcallNumber)
            myString.append(NSMutableAttributedString(string: callNumber))
            myString.append(seperator)
        }
        if callType != "" {
            let attributedCallType = NSMutableAttributedString(string: "Call Type: ", attributes:yourAttributes)
            myString.append(attributedCallType)
            myString.append(NSMutableAttributedString(string: callType))
            myString.append(seperator)
        }
        
        if unitID != "" {
            let attributedUnitId = NSMutableAttributedString(string: "Unit Id: ", attributes:yourAttributes)
            myString.append(attributedUnitId)
            myString.append(NSMutableAttributedString(string: unitID))
         }
        
         return myString
 
    }
    
    
}
