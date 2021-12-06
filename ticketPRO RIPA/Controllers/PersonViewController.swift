//
//  PersonViewController.swift
//  ticketPRO RIPA
//
//  Created by Nitin Singh on 06/04/21.
//

import UIKit
import EzPopup



protocol PersonTypeDelegate: class {
    func addPerson(personIndex:Int , personArray:[[String: Any]])
    func editPerson(personIndex:Int, personArray:[[String: Any]])
    func previewPerson(personIndex:Int , personArray:[[String: Any]])
}


class PersonViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,PreviewModelDelegate,PopupViewControllerDelegate,UIGestureRecognizerDelegate {
    
    
    
    weak var personTypeDelegate : PersonTypeDelegate?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var noteBtn: UIButton!
    
    
    let enterDescription = EnterDescriptionPopupViewController.instantiate()
    var questionsArray : [QuestionResult1]?
    var optionsArray : [Questionoptions1]?
    var cascadeQuestionsArray : [QuestionResult1]?
    var selectedOptionsArray=[[Questionoptions1]]()
    var personArray: [[String: Any]] = []
    var prsonIndex:Int?
    var previewViewModel = PreviewViewModel()
    var ripaActivity : Ripaactivity?
    
    var previewPersonArray = [RipaPerson]()
    var previewPersonIndex = 0
    
    
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
    
     @objc func scrollViewTapped() {
        trackApplicationTime()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
       
        if scrollView.isDragging {
            trackApplicationTime()
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        trackApplicationTime()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "PersonsTableCell", bundle: nil), forCellReuseIdentifier: "PersonsTableCell")
        
        let scrollViewTap = UITapGestureRecognizer(target: self, action: #selector(scrollViewTapped))
        tableView.addGestureRecognizer(scrollViewTap)
        
        if AppConstants.status == "Pending Review" || AppConstants.status == "Approved"{
            addBtn.isHidden = true
            submitBtn.isHidden = true
            noteBtn.isHidden = true
         }
       
        previewViewModel.ripaActivity = ripaActivity
        previewViewModel.questionArray = questionsArray!
        previewViewModel.cascadeQuestionArray = cascadeQuestionsArray!
        //   navigationController!.removeViewController(PreviewViewController.self)
      
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
    
    
    func setPreviewDelegate(success: String, message: String) {
        print(success)
       // if message == "Success"{
            //            UserDefaults.standard.removeObject(forKey: "CrashedDict")
            //            UserDefaults.standard.synchronize()
            AppConstants.notes = ""
            goToSuccess()
     //   }
    }
    
    
  
    
    
    
    
    func goToSuccess(){
        self.performSegue(withIdentifier: "ShowSuccess", sender: self)
    }
    
    
    
    func goToDashboard(){
        let alert = UIAlertController(title: nil, message: "Submitted Succesfully", preferredStyle: UIAlertController.Style.alert)
        //  alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
            
        }         )
        )
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    @IBAction func action_submit(_ sender: Any) {
        trackApplicationTime()
        
        if checkRequiredFilled().1 == false{
            AppUtility.showAlertWithProperty("Alert", messageString: "Fill all required questions or their description for \(checkRequiredFilled().0)")
            return
        }
        
        
        previewViewModel.previewModelDelegate = self
        previewViewModel.personArray = personArray
        previewViewModel.createPersonsDict(personArray: personArray, ripaActivity: ripaActivity!, statusId: "1")
        // previewViewModel.createPersonsSelectedOptionDict(questionArray: questionsArray!, cascadeQuestArray: cascadeQuestionsArray!)
        let updateRipa:UpdateRipa = previewViewModel.updateRipaParam()
        
        //previewViewModel.saveToDB(updateRipa: updateRipa)
        
        previewViewModel.submitParam(params: updateRipa, toSave: false, showAlertForSave: false)
        
    }
    
    
    
    
    func checkRequiredFilled() -> (String,Bool){
        var i = 1
        var allFilled = true
        var personName = ""
        for person in personArray{
            let questArr = (person["QuestionArray"] as! [QuestionResult1])
            let cascadeQuestArr = (person["CascadeQuestionArray"] as! [QuestionResult1])
            let selectedOptionsArray = person["SelectedOption"] as! [[Questionoptions1]]
            
            let requiredFilledData = previewViewModel.checkRequiredQuestion(questArray: questArr, cascadeQuestArray: cascadeQuestArr, selectedOpt: selectedOptionsArray)
            
            if requiredFilledData.0.count > 0 {
                allFilled = false
                personName = "Person " + String(i)
                return  (personName,allFilled)
            }
            i += 1
        }
        return  (personName,allFilled)
    }
    
    
    
    
    @IBAction func addNote(_ sender: Any) {
        trackApplicationTime()
        guard let customAlertVC = enterDescription else { return }
        
        // customAlertVC.addDescriptionDelegate = self
        customAlertVC.enteredText = AppConstants.notes
        customAlertVC.inputType = "Notes"
        
        let popupVC = PopupViewController(contentController: customAlertVC, position: .bottom(UIScreen.main.bounds.size.height/2.8), popupWidth: UIScreen.main.bounds.size.width-30, popupHeight: 370)
        popupVC.cornerRadius = 5
        popupVC.delegate = self
        present(popupVC, animated: true, completion: nil)
    }
    
    
    
    @IBAction func action_back(_ sender: Any) {
         // navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func actionAdd(_ sender: Any){
        trackApplicationTime()
        if checkRequiredFilled().1 == false{
            AppUtility.showAlertWithProperty("Alert", messageString: "Fill all required questions or their description for \(checkRequiredFilled().0)")
            return
        }
        
        self.personTypeDelegate?.addPerson(personIndex:prsonIndex!, personArray: personArray)
        navigationController?.popViewController(animated: true)
    }
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        if personArray.count > 0{
            return personArray.count
        }
        else {
            return 0
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return  65
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PersonsTableCell", for: indexPath as IndexPath) as! PersonsTableCell
        //        let personDict = personArray[indexPath.row]
        //        let personType = personDict["PersonType"]
        
        cell.personNumberLbl.text = "Person " + String(indexPath.row+1)
        
        if AppConstants.status == "Pending Review" || AppConstants.status == "Approved"{
            cell.deleteBtn.isHidden = true
            cell.editBtn.isHidden = true
        }
   
        cell.deleteBtn.addTarget(self, action: #selector(deleteUser(sender:)), for: .touchUpInside)
        cell.deleteBtn.tag = indexPath.row
        
        cell.editBtn.addTarget(self, action: #selector(editUser(sender:)), for: .touchUpInside)
        cell.editBtn.tag = indexPath.row
        
        cell.previewBtn.addTarget(self, action: #selector(previewUser(sender:)), for: .touchUpInside)
        cell.previewBtn.tag = indexPath.row
       
        
        return cell
    }
    
    
    @objc func deleteUser(sender: UIButton) {
        if personArray.count > 0{
            
            showAlertWithProperty("Alert", messageString: "You are about to delete the application. Continue?", index: sender.tag )
            
        }
        
    }
    
    
    func showAlertWithProperty(_ title: String, messageString: String, index : Int) -> Void {
        
        let alertController = UIAlertController.init(title: title, message: messageString, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alertController.addAction(UIAlertAction(title: "Continue", style: .cancel, handler: { [self] action in
            personArray.remove(at:index)
            tableView.reloadData()
        })
        )
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    
    @objc func editUser(sender: UIButton) {
        print(sender.tag)
        prsonIndex = sender.tag
        self.personTypeDelegate?.editPerson(personIndex: prsonIndex!, personArray: personArray)
        navigationController?.popViewController(animated: true)
    }
    
    @objc func previewUser(sender: UIButton) {
        print(sender.tag)
        prsonIndex = sender.tag
      
         self.personTypeDelegate?.previewPerson(personIndex:prsonIndex!, personArray: personArray)
        
        navigationController?.popViewController(animated: true)
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        let segueID = segue.identifier
        if(segueID! == "ShowPreview"){
            let vc = segue.destination as! PreviewViewController
            //vc.selectedIndexDelegate = self
            vc.questionsArray = questionsArray!
            vc.cascadeQuestionsArray = cascadeQuestionsArray
            vc.personIndex = prsonIndex
            vc.personArray = personArray
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        trackApplicationTime()
        // self.selectedIndexDelegate?.goToSelectedQuestion(index:indexPath.section)
        // navigationController?.popViewController(animated: true)
    }
    
    
    
}
