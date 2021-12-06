//
//  PreviewViewController.swift
//  ticketPRO RIPA
//  Created by Nitin on 2/26/21.
//

import UIKit
import EzPopup



protocol GoToQuestion: class {
    func goToSelectedQuestion(personIndex: Int,  personArray: [[String : Any]], index:Int)
    func addPerson(personIndex:Int , personArray:[[String: Any]])
    func editForPerson(personIndex:Int , personArray:[[String: Any]])
    func setPreviewDelegate()
}

class PreviewViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,PersonTypeDelegate,PreviewModelDelegate,PopupViewControllerDelegate,PendingQuestionDelegate ,UIGestureRecognizerDelegate {
 
    
    let enterDescription = EnterDescriptionPopupViewController.instantiate()
    let pendingQuestionPopup = PendingQuestionsPopup.instantiateQuestion()
    
    weak var selectedIndexDelegate : GoToQuestion?
    var questionsArray : [QuestionResult1]?
    var optionsArray : [Questionoptions1]?
    var cascadeQuestionsArray : [QuestionResult1]?
    var previewViewModel = PreviewViewModel()
    // var previewViewModel = PreviewViewModel()
    var  selectedOptionsArray=[[Questionoptions1]]()
    var questionnumber : Int?
    var  personArray: [[String: Any]] = []
//    var previewPersonArray = [RipaPerson]()
//    var previewPersonIndex = 0
    var personIndex:Int?
    var viewType:String = ""
    
     let db = SqliteDbStore()
    var ripaActivity : Ripaactivity?
    
    @IBOutlet weak var preview_tbl: UITableView!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var notesBtn: UIButton!
    @IBOutlet weak var personLbl: UILabel!
    
    

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        trackApplicationTime()
        super.touchesEnded(touches , with: event)
    }
    
     func trackApplicationTime(){
      
        AppConstants.applicationtime = String(Int(AppConstants.applicationtime)! + MyGlobalTimer.sharedTimer.time)
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
        preview_tbl.dataSource = self
        preview_tbl.delegate = self
        preview_tbl.register(UINib(nibName: "PreviewCell", bundle: nil), forCellReuseIdentifier: "PreviewCell")
        preview_tbl.estimatedRowHeight = 30.0
        preview_tbl.rowHeight = UITableView.automaticDimension
        
        let personDict = personArray[personIndex!]
        
       if AppConstants.status == "Pending Review" || AppConstants.status == "Approved" || AppConstants.status == "Template"{
           // addBtn.isHidden = true
             notesBtn.isHidden = true
            questionsArray = personDict["QuestionArray"] as? [QuestionResult1]
            cascadeQuestionsArray = personDict["CascadeQuestionArray"] as? [QuestionResult1]
            
        }
        
        if #available(iOS 15.0, *) {
           self.preview_tbl.sectionHeaderTopPadding = 0.0
       }
        
      //  else{
             selectedOptionsArray = personDict["SelectedOption"] as! [[Questionoptions1]]
              previewViewModel.ripaActivity = ripaActivity
            
            previewViewModel.viewType = viewType
            previewViewModel.questionArray = questionsArray!
            previewViewModel.cascadeQuestionArray = cascadeQuestionsArray!
    //    }
        

    }
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if AppConstants.status == "Pending Review" || AppConstants.status == "Approved" || AppConstants.status == "Template"{
            if personArray.count > 1{
                addBtn.isHidden = true
                submitBtn.setTitle("REVIEW FOR ALL", for: .normal)
            }
            else{
                submitBtn.isHidden = true
                addBtn.isHidden = true
            }
        }
         else{
        if personArray.count > 1{
            submitBtn.setTitle("REVIEW FOR ALL", for: .normal)
        }
        else{
            submitBtn.setTitle("SUBMIT", for: .normal)
        }
     }
        
        if AppConstants.theme == "1"{
            overrideUserInterfaceStyle = .dark
        }
        else{
            overrideUserInterfaceStyle = .light
            AppConstants.theme = "0"
        }
  
    }
    
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        if AppConstants.status == "Pending Review" || AppConstants.status == "Approved"{
//            personLbl.text = "Person" + " " + String(previewPersonIndex + 1)
//         }
//        else{
        personLbl.text = "Person" + " " + String(Int(personIndex!)+1)
   //     }
    }
    
    
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
           return questionsArray!.count
     }
    
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 55.0
    }
    
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        
        let label = UILabel()
        let view = UIView()
        //  let imgView = UIImage()
        let sectionButton = UIButton()
        
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 55))
        
        view.frame = CGRect.init(x: 0, y: 2, width: headerView.frame.width, height: headerView.frame.height-4)
        view.backgroundColor = #colorLiteral(red: 0.3789433241, green: 0.6938186288, blue: 0.8649699092, alpha: 1)
        
        label.frame = CGRect.init(x: 15, y: 5, width: headerView.frame.width-50, height: headerView.frame.height-10)
        let questNumber:String = String(section+1)+". "+" "
//        if AppConstants.status == "Pending Review" || AppConstants.status == "Approved"{
//            label.text = previewPersonArray[0].ripa_response[section].question
//        }
//        else{
        label.text = questNumber + questionsArray![section].question
 //       }
        
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        label.font =  UIFont.boldSystemFont(ofSize:18)
        
        headerView.addSubview(view)
        headerView.addSubview(label)
        
//        if AppConstants.status == "Pending Review" || AppConstants.status == "Approved"{
//
//        }
//        else{
        if questionsArray![section].is_required == "1" {
            let mandatoryImgView = UIImageView()
            var mandatoryImage = UIImage()
            
            mandatoryImage = UIImage(named: "asterisk")!
            
            mandatoryImgView.frame = CGRect.init(x: headerView.frame.width-40, y:(headerView.frame.height/2)-10, width: 15, height: 15)
            mandatoryImgView.image = mandatoryImage
            
            headerView.addSubview(mandatoryImgView)
        }
         
         sectionButton.tag = section
        sectionButton.addTarget(self, action: #selector(self.goToSelectedQuest(sender:)), for: .touchUpInside)
        sectionButton.frame = CGRect.init(x: 0, y: 2, width: headerView.frame.width, height: headerView.frame.height-4)
         headerView.addSubview(sectionButton)
  //      }
        
         return headerView
    }
    
    
    var locationArray=[String]()
    
    func locationCellCount()-> Int{
        locationArray.removeAll()
        var i = 1
        
        if AppConstants.city != ""{
            locationArray.append(AppConstants.city)
        }
        if AppConstants.address != ""{
            locationArray.append(AppConstants.address)
            i += 1
        }
        if AppConstants.isSchoolSelected != ""{
            locationArray.append("Is K-12 school?")
            locationArray.append(AppConstants.isSchoolSelected)
            i += 2
        }
        if AppConstants.schoolName != ""{
            locationArray.append(AppConstants.schoolName)
             i += 1
        }
        
        return i
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
//        if AppConstants.status == "Pending Review" || AppConstants.status == "Approved"{
//            return  1
//        }
//        else{
        if selectedOptionsArray[section].count>0{
            if section == 0{
                return locationCellCount()
            }
            return selectedOptionsArray[section].count
        }
        else {
            return 1
        }
    //    }
    }
    
    
    
    func gotoselectedQuestion(index: Int, personArray: [[String : Any]]) {
        print(index)
        self.selectedIndexDelegate?.goToSelectedQuestion(personIndex: personIndex!, personArray: personArray, index: index)
        navigationController?.popViewController(animated: true)
    }
    
    
    func addPerson(personIndex: Int, personArray: [[String : Any]]) {
        self.selectedIndexDelegate?.addPerson(personIndex:personIndex, personArray: personArray)
        navigationController?.popViewController(animated: true)
    }
    
    func editPerson(personIndex: Int,  personArray: [[String : Any]]) {
        self.selectedIndexDelegate?.editForPerson(personIndex:personIndex, personArray: personArray)
        navigationController?.popViewController(animated: true)
    }
    
    
    
    func previewPerson(personIndex: Int, personArray: [[String : Any]]) {
//        if AppConstants.status == "Pending Review" || AppConstants.status == "Approved"{
//            previewPersonIndex = personIndex
//         }
//        else{
        personLbl.text = "Person" + " " + String(Int(personIndex)+1)
        self.personArray = personArray
        self.personIndex = personIndex
        let personDict = personArray[personIndex]
        selectedOptionsArray = personDict["SelectedOption"] as! [[Questionoptions1]]
//    }
        preview_tbl.reloadData()
    }
    
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PreviewCell", for: indexPath as IndexPath) as! PreviewTableViewCell

//        if AppConstants.status == "Pending Review" || AppConstants.status == "Approved"{
//            print(previewPersonIndex)
//            cell.check_img.isHidden = false
//            cell.answer_lbl.text = previewPersonArray[previewPersonIndex].ripa_response[indexPath.section].response
//            return cell
//         }
//        else{
        
        cell.check_img.isHidden = true
        cell.answer_lbl.text = "_ _ _ _ _ _ _ _ _"
        cell.answer_lbl.textColor = UIColor(named: "BlackWhite")
        if indexPath.section == 0 {
            if indexPath.row == 0 && AppConstants.address != ""{
                cell.check_img.isHidden = false
            }
            if indexPath.row == 0 && AppConstants.city == ""{
                return  cell
            }
            if AppConstants.isSchoolSelected != "" && (AppConstants.address == locationArray[indexPath.row] || AppConstants.isSchoolSelected == locationArray[indexPath.row] ){
                cell.answer_lbl.textColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
            }
            
            if locationArray.count > 0 {
                cell.answer_lbl.text = locationArray[indexPath.row]
            }
            
            return  cell
        }
        
        if selectedOptionsArray[indexPath.section].count>0 {
            if selectedOptionsArray[indexPath.section][indexPath.row].tag == "Description"{
                cell.answer_lbl.text = "Description - " + selectedOptionsArray[indexPath.section][indexPath.row].option_value
            }
            else{
            cell.answer_lbl.text = selectedOptionsArray[indexPath.section][indexPath.row].option_value
            }
            if indexPath.row == 0{
                cell.check_img.isHidden = false
            }
        }
        return cell
//        }
    }
    
    
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        trackApplicationTime()
        if AppConstants.status == "Pending Review" || AppConstants.status == "Approved"{
         }
        else{
        self.selectedIndexDelegate?.goToSelectedQuestion(personIndex: personIndex!, personArray: personArray, index: indexPath.section)
        navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func goToSelectedQuest(sender:UIButton){
        trackApplicationTime()
        self.selectedIndexDelegate?.goToSelectedQuestion(personIndex: personIndex!, personArray: personArray, index: sender.tag)
        navigationController?.popViewController(animated: true)
    }
    
    
    func setPreviewDelegate(success: String, message: String) {
       // if message == "Success"{
            //  self.db.openDatabase()
            //                           self.db.deleteAllfrom(table: "saveRipaPersonTable")
            //                           self.db.deleteAllfrom(table: "useSaveRipaOptionsTable")
            AppConstants.notes = ""
            //            UserDefaults.standard.removeObject(forKey: "CrashedDict")
            //            UserDefaults.standard.synchronize()
            self.performSegue(withIdentifier: "ShowSuccess", sender: self)
      //  }
    }
    
    
    func goToSuccess(){
        
    }
    
    
    
    
    
    
    @IBAction func actionSubmit(_ sender: Any) {
        trackApplicationTime()
        if AppConstants.status == "Pending Review" || AppConstants.status == "Approved"{
            self.performSegue(withIdentifier: "ShowPersonView", sender: self)
         }
        else{
         let requiredFilledData = previewViewModel.checkRequiredQuestion(questArray: questionsArray, cascadeQuestArray: cascadeQuestionsArray, selectedOpt: selectedOptionsArray)
        
        if personArray.count > 1{
            self.performSegue(withIdentifier: "ShowPersonView", sender: self)
        }
        else{
            if requiredFilledData.0.count < 1 {
                previewViewModel.previewModelDelegate = self
                previewViewModel.personArray = personArray
                previewViewModel.createPersonsDict(personArray: personArray, ripaActivity: ripaActivity!, statusId: "1")
                let updateRipa:UpdateRipa = previewViewModel.updateRipaParam()
 
                previewViewModel.submitParam(params: updateRipa, toSave: false, showAlertForSave: false)
             }
            else{
                guard let customAlertVC1 = pendingQuestionPopup else { return }
                customAlertVC1.pendingQuestionDelegate = self
                customAlertVC1.newquestionArry = requiredFilledData.0
                customAlertVC1.newquestionIDArray = requiredFilledData.1
                
                customAlertVC1.personArray = personArray
                customAlertVC1.personIndex = personIndex
                let popupVC = PopupViewController(contentController: customAlertVC1, position:.bottom(UIScreen.main.bounds.size.width/2), popupWidth: UIScreen.main.bounds.size.width-30, popupHeight:500)
                popupVC.cornerRadius = 5
                popupVC.delegate = self
                
                present(popupVC, animated: true, completion: nil)
            }
        }
        }
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        let segueID = segue.identifier
        
        if(segueID! == "ShowPersonView"){
            let vc = segue.destination as! PersonViewController
            vc.personTypeDelegate = self
//            if AppConstants.status == "Pending Review" || AppConstants.status == "Approved"{
//                vc.previewPersonArray = self.previewPersonArray
//                vc.previewPersonIndex =  self.previewPersonIndex
//             }
//            else{
            vc.prsonIndex = personIndex
            vc.questionsArray = questionsArray!
            vc.cascadeQuestionsArray = cascadeQuestionsArray
            vc.personArray = personArray
            vc.ripaActivity = ripaActivity
       
      //      }
        }
        
    }
    
  
    
    @IBAction func actionBack(_ sender: Any) {
        trackApplicationTime()
        self.selectedIndexDelegate?.editForPerson(personIndex:personIndex!, personArray: personArray)
        navigationController?.popViewController(animated: true)
    }
    
    
    
    @IBAction func actionAdd(_ sender: Any) {
        trackApplicationTime()
        checkRequired()
    }
    
    
    
    @IBAction func actionNotes(_ sender: Any) {
        trackApplicationTime()
        guard let customAlertVC = enterDescription else { return }
        
        //customAlertVC.addDescriptionDelegate = self
        customAlertVC.enteredText = AppConstants.notes
        customAlertVC.inputType = "Notes"
        
        let popupVC = PopupViewController(contentController: customAlertVC, position: .bottom(UIScreen.main.bounds.size.width/2), popupWidth: UIScreen.main.bounds.size.width-30, popupHeight: 370)
        popupVC.cornerRadius = 5
        popupVC.delegate = self
        present(popupVC, animated: true, completion: nil)
    }
    
    
    
    func checkRequired(){
        let requiredFilledData = previewViewModel.checkRequiredQuestion(questArray: questionsArray, cascadeQuestArray: cascadeQuestionsArray, selectedOpt: selectedOptionsArray)
        
        // let requiredFilledId = previewViewModel.checkRequiredQuestionID(questArray: questionsArray, selectedOpt: selectedOptionsArray)
        
         if requiredFilledData.0.count < 1 {
            navigationController!.removeViewController(PersonViewController.self)
            self.selectedIndexDelegate?.addPerson(personIndex:personIndex!, personArray: personArray)
            navigationController?.popViewController(animated: true)
        }
        else{
            guard let customAlertVC1 = pendingQuestionPopup else { return }
            customAlertVC1.pendingQuestionDelegate = self
            customAlertVC1.newquestionArry = requiredFilledData.0
            customAlertVC1.newquestionIDArray = requiredFilledData.1
            
            customAlertVC1.personArray = personArray
            customAlertVC1.personIndex = personIndex
            let popupVC = PopupViewController(contentController: customAlertVC1, position:.bottom(UIScreen.main.bounds.size.width/2), popupWidth: UIScreen.main.bounds.size.width-30, popupHeight:500)
            popupVC.cornerRadius = 5
            popupVC.delegate = self
            
            present(popupVC, animated: true, completion: nil)
        }
        
    }
    
    
    @IBAction func actionLogout(_ sender: Any) {
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
    
    
    
    override func viewWillDisappear(_ animated: Bool)
    {
        
    }
    
}

extension UINavigationController {
    
    func removeViewController(_ controller: UIViewController.Type) {
        if let viewController = viewControllers.first(where: { $0.isKind(of: controller.self) }) {
            viewController.removeFromParent()
        }
    }
    
    
}
