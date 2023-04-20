//
//  EditLocationViewController.swift
//  ticketPRO RIPA
//
//  Created by Nitin Singh on 04/06/21.
//

import UIKit
import SwiftyJSON

class RejectedApplicationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate,LocationEditViewDelegate,UIGestureRecognizerDelegate,SavedListModelDelegate {
 
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var activityIdLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    
    @IBOutlet weak var officerLbl: UILabel!
    @IBOutlet weak var reviewerNameLbl: UILabel!
    @IBOutlet weak var locationNameLbl: UILabel!
    @IBOutlet weak var cityNameLbl: UILabel!
    @IBOutlet weak var cityLbl: UILabel!
    
    @IBOutlet weak var locationLbl: UILabel!
    @IBOutlet weak var reviewerNote: UILabel!
    @IBOutlet weak var noteDetailTextField: UITextField!
    @IBOutlet weak var noteReviewTextView: UITextView!
    @IBOutlet weak var reviewNoteHeightConstrait : NSLayoutConstraint!
    
    var rejectedApplication:RejectedApplication?
    var index:Int?
    var activity:Ativity?
    var response=[Response]()
    var newRipaViewModel = NewRipaViewModel()
    var savedListViewModel = SavedListViewModel()
    
    var cityId = ""
    var viewType=""
    var saveRipaStatus:String?
    var  personArray: [[String: Any]] = []
    var savedRipaList:RipaTempMaster?
    
    var screenType : String = ""
    var isPendingEdit:Bool = false
    var isEditRequired:Bool = false

    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        trackApplicationTime()
        super.touchesEnded(touches , with: event)
    }
    
     func trackApplicationTime(){
        print(AppConstants.applicationtime)
        print(String(MyGlobalTimer.sharedTimer.time))
        AppConstants.applicationtime = String(Int(AppConstants.applicationtime)! + MyGlobalTimer.sharedTimer.time)
        print(AppConstants.applicationtime)
        MyGlobalTimer.sharedTimer.stopTimer()
        MyGlobalTimer.sharedTimer.startTimer()
     }
   
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
       
        if scrollView.isDragging {
            trackApplicationTime()
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        trackApplicationTime()
        newRipaViewModel.setFeature()
     //   noteReviewTextView.contentInset = UIEdgeInsets(top: 2, left: 10, bottom: 2, right: 10)

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "RejectedApplicationCell", bundle: nil), forCellReuseIdentifier: "RejectedApplicationCell")
       
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: UIResponder.keyboardWillShowNotification, object: nil)
        
     //   noteDetailTextField.isUserInteractionEnabled = false
        activity = rejectedApplication?.ativity
        response = rejectedApplication?.response ?? []
        
        for i in (0..<response.count)
        {
            let mainId = response[i].main_question_id
            var respo = [Response]()
            if mainId == "14" {
                respo.append(response[i])
                response.remove(at: i)
                response.insert(respo[0], at: 0)
            }
        }
        
        setData()
        getCityId()
        
        savedListViewModel.savedListModelDelegate = self
        
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
    
    var address = ""
    func setData(){
        activityIdLbl.text = activity!.activityID
       
        reviewerNameLbl.text = activity!.activityCheckedBy
        dateLbl.text = convertDateFormater(date: activity!.activityCreationDate)
        cityNameLbl.text = activity!.city
        locationNameLbl.text = activity!.location
      
    //    noteDetailTextField.text = "  " + activity!.activityNotes
      //  noteDetailTextField.isHidden = true
        noteReviewTextView.text = "  " + activity!.activityNotes
       
        let sizeThatShouldFitTheContent = self.noteReviewTextView.sizeThatFits(self.noteReviewTextView.frame.size)
        let height = sizeThatShouldFitTheContent.height
        if height > 44 {
            reviewNoteHeightConstrait.constant = CGFloat(height)
            UIView.animate(withDuration: 0, animations:{
              self.noteReviewTextView.layoutIfNeeded()
            })
        }
     }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(response.count)
        return response.count
    }
    var responsetext = ""
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RejectedApplicationCell", for: indexPath as IndexPath) as! RejectedApplicationCell
 
        cell.personLbl.text = response[indexPath.row].personName
        cell.descriptionLbl.text = "Explanation for " + response[indexPath.row].question
        if response[indexPath.row].main_question_id == "14" {
            cell.descriptionLbl.text = "Reason Explanation"
        }
        else if response[indexPath.row].main_question_id == "25" {
            cell.descriptionLbl.text = "Search Basis Explanation"
        }
        
        
        cell.descriptionTextView.text = response[indexPath.row].response
       
        responsetext = response[indexPath.row].response
        cell.descriptionTextView.tag = indexPath.row
        cell.descriptionTextView.delegate = self
        index = indexPath.row
        cell.descriptionTextView.textAlignment = .justified
        
        cell.clearBtn.tag = indexPath.row
        cell.clearBtn.addTarget(self, action: #selector(clearTxt(sender:)), for: .touchUpInside)
        
        return cell
    }
    
    
    @objc func clearTxt(sender: UIButton){
        print(sender.tag)
        response[sender.tag].response = ""
        tableView.reloadData()
    }
    
    
    @IBAction func actionEditRipaButton(_ sender: Any) {
        if let activityId = self.savedRipaList?.activityId {
            savedListViewModel.getApprovedOrPendingPram(activityId:activityId)
        }
        
    }
    
    func proceedToPreviewScreen(previewPram: [RipaPerson], forTemplate: Bool?) {
        personArray = savedListViewModel.createPersonDict(personarray:previewPram)
        self.setConstants ()
           let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "NewRipaViewController") as! NewRipaViewController
           vc.viewType = "UseSaveRipa"
           vc.saveRipaStatus = "Saved"
            vc.screenType = screenType
            vc.isPendingEdit = isPendingEdit
           vc.ripaTypeStr = "Edit"
           vc.isEditRequired = self.isEditRequired
           AppConstants.status = ""
           vc.personArray = personArray
           vc.savedRipaList = savedRipaList
           self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func setConstants () {
        AppConstants.activityStatusId = "4"
        if let city = savedRipaList?.city {
            AppConstants.city =  city
        }
        if let key = savedRipaList?.key {
            AppConstants.key = key
        }
        if let activityId = savedRipaList?.activityId {
            AppConstants.activityID = activityId
        }
        if let trafficid = savedRipaList?.skeletonID {
            AppConstants.trafficId = trafficid
        }
        if let notes = savedRipaList?.note {
            AppConstants.notes = notes
        }
        if let duration = savedRipaList?.stopDuration {
            AppConstants.duration = duration
        }
        if let stopDate = savedRipaList?.stopDate {
            AppConstants.date = stopDate
            if stopDate != ""{
                let inputFormatter = DateFormatter()
                inputFormatter.dateFormat = "MM/dd/yyyy HH:mm"
                let showDate = inputFormatter.date(from: stopDate)
                inputFormatter.dateFormat = "MM/dd/yyyy"
                var resultString = inputFormatter.string(from: showDate!)
                AppConstants.date = resultString
                
                inputFormatter.dateFormat = "HH:mm"
                resultString = inputFormatter.string(from: showDate!)
                AppConstants.time = resultString
            }
        }
        
        if let stopTime = savedRipaList?.stopTime {
            AppConstants.time = stopTime
        }
        
        if let location = savedRipaList?.location {
            AppConstants.address = location
        }
        
        if let deviceid = savedRipaList?.deviceid {
            AppConstants.deviceid = deviceid
        }
        if let citationNumber = savedRipaList?.citationNumber {
            AppConstants.citation = citationNumber
        }
        
    }
    
    
    func proceedToRejectedView(applicationData: RejectedApplication?) {
        
    }
    
    
    @IBAction func actionBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        trackApplicationTime()
    }
    
    @IBAction func actionUpdate(_ sender: Any) {
        getUpdateRipaResponse()
        trackApplicationTime()
    }
    
    @IBAction func actionOpenLocationEditPage(_ sender: Any) {
        self.performSegue(withIdentifier: "EditLocationPage", sender: self)
        trackApplicationTime()
       // openLocationPage()
     }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        let segueID = segue.identifier
      
        if(segueID! == "EditLocationPage"){
            let locationEditView = segue.destination as! LocationEditViewController
            locationEditView.locationEditDelegate = self
             locationEditView.updateRipaLocation = self.rejectedApplication!.location
            locationEditView.cityId = self.cityId
            locationEditView.city = self.rejectedApplication!.ativity.city
        }
    }
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool{
        let newString = NSString(string: textView.text!).replacingCharacters(in: range, with: text)
        let newLength:Int = newString.count
        if(newLength < 251){
            responsetext = newString
            index = textView.tag
            response[index!].response = responsetext
            return true
        }
        return false
    }
    
    
    @objc func keyboardWillAppear() {
        trackApplicationTime()
     }
    
    
    
    @objc func keyboardWillDisappear() {
        trackApplicationTime()
        response[index!].response = responsetext
    }
  
    
    func setLocationEdit(locationObject: RejectedApplicationLocation, address: String , city:String) {
        rejectedApplication?.location = locationObject
        self.address = address
        activity?.location = self.address
        activity?.city = city
        locationLbl.text = activity?.location
        cityLbl.text = "City/Jurisdiction : " + (activity!.city)
    }
      
    
    var updateRipaResponseArray = [UpdateRipaResponse]()
    var updateRipaLocation = [UpdateRipaLocation]()
    var updatePram:UpdateParams?
    var updateRejectedApplication:UpdateRejectedApplication?
    
    
    func getUpdateRipaResponse(){
        for object in response{
            let ripaResponse = UpdateRipaResponse(activity_id: object.activityID, question_id : object.questionID, rec_id: object.recID, ripa_person_id: object.ripaPersonID, response: object.response, description: object.responseDescription, userid: object.userid, optionID: object.optionID)
            updateRipaResponseArray.append(ripaResponse)
        }
        getRipaLocation()
    }
    
    var previewViewModel = PreviewViewModel()
    
    func getRipaLocation(){
        let street = (rejectedApplication?.location.street)!
        let block = (rejectedApplication?.location.block)!
        let intesection = getIntersection(location: (activity?.location)!)
        let location = (activity?.location)!
        let city = activity!.city
        
        let loc = UpdateRipaLocation(Street: street , Block: block, Intersection: intesection, Location: location, City: city, timetaken: getTimeTaken(),access_token: (AppManager.getLastSavedLoginDetails()?.result!.access_token)!, ip_address: previewViewModel.getIPAddress(), platform:"ios", app_version : Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "2.5" , time_duration_enable:AppConstants.ripaTimeDuration, deviceid: "0", ripa_response: updateRipaResponseArray)
        updateRipaLocation.append(loc)
        
        getUpdatePram()
    }
    
    func getTimeTaken()-> String{
        let timetaken =  Double(AppConstants.applicationtime)!/60
        var roundedtimetaken = Int(timetaken.rounded())
        if roundedtimetaken == 0{
            roundedtimetaken = 1
        }
        return String(roundedtimetaken)
    }
    
    func getUpdatePram(){
        updatePram = UpdateParams(ripa_location: updateRipaLocation)
         updatedApplication()
    }
    
    func  updatedApplication(){
        let updateRejectedApplication = UpdateRejectedApplication(id: "82F85DB43CBF6", jsonrpc: "2.0", method: "ripaResubmitActivity", params: updatePram!)
          submitParam(params: updateRejectedApplication)
    }
    
    func submitParam(params:UpdateRejectedApplication){
        let encodedData = try! JSONEncoder().encode(params)
        let jsonString = String(data: encodedData,
                                encoding: .utf8)
        print(jsonString!)
        let dict = convertStringToDictionary(text: jsonString!)
        
         submitAnswers(params: dict!)
     }
    
    
    
    func submitAnswers(params:[String:Any]) {
        
        AppUtility.showProgress(nil, title:nil)
        var URL:String?
        
        URL = AppConstants.Api.updateRipa
        ApiManager.updateEditedRipa(params: params, methodTyPe: .post, url: URL!, completion: { [self] (success,message) in
            
            if message == "Success"{
                
                showAlertWithProperty("Updated", messageString: "Activity updated successfully")
              
            }
            else if message == "Fail"{
                AppUtility.showAlertWithProperty("Alert", messageString: success as! String)
             }
             AppUtility.hideProgress(nil)
        })
        { (error, code, message) in
            AppUtility.hideProgress(nil)
            if let errorMessage = message {
                 AppUtility.showAlertWithProperty("Alert", messageString: errorMessage)
            }
        }
    }
    
    func getCityId(){
        let cityList = newRipaViewModel.getCities()
          let city = cityList.first{$0.city_name == activity!.city}
         cityId = city?.city_id ?? ""
    }
    
    func showAlertWithProperty(_ title: String, messageString: String) -> Void {
        let alertController = UIAlertController.init(title: title, message: messageString, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { [self] action in
           
//            let id = activity?.activityID
//            let db = SqliteDbStore()
//            db.openDatabase()
//            db.deleteAllfrom(table: "ripaTempMasterTable WHERE activityId = \(id!)")
            
              self.navigationController?.popViewController(animated: true)
         })
        )
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    
    func getIntersection(location:String)->String{
        var Intersection = ""
        if location.contains(" & "){
          Intersection = location.components(separatedBy: (" & "))[1]
        }
        else if location.contains("/"){
            Intersection = location.components(separatedBy: ("/"))[1]
        }
        return Intersection
    }
    
    func convertDateFormater(date: String)->String{
        var resultString = ""
        let date = date.components(separatedBy: ("."))[0]
        if date != ""{
            let inputFormatter = DateFormatter()
            inputFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let showDate = inputFormatter.date(from: date)
            inputFormatter.dateFormat = "MM/dd/yyyy HH:mm"
            resultString = inputFormatter.string(from: showDate!)
        }
        return resultString
    }
    
    
    func convertStringToDictionary(text: String) -> [String:AnyObject]? {
        if let data = text.data(using: .utf8) {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:AnyObject]
                return json
            } catch {
                print("Something went wrong")
            }
        }
        return nil
    }
}
