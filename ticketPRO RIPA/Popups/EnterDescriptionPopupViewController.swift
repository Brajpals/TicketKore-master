//
//  EnterDescriptionPopupViewController.swift
//  ticketPRO RIPA
//
//  Created by Nitin Singh on 02/04/21.
//

import UIKit
import Speech
import AVKit

protocol AddDescriptionDelegate: class {
    func addEnteredDescription(text:String?)
    
}

protocol NoteDelegate: class {
    func addnote(forSave:Bool)
    
}

let audioSession = AVAudioSession.sharedInstance()
class EnterDescriptionPopupViewController: UIViewController,UITextViewDelegate {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var micBtn: UIButton!
    @IBOutlet weak var clearBtn: UIButton!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var placeholderLbl: UILabel!
    @IBOutlet weak var popupLbl: UILabel!
    
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var discardBtn: UIButton!
    
    
    weak var addDescriptionDelegate: AddDescriptionDelegate?
    weak var noteDelegate: NoteDelegate?
    
    
    // var micClass: MicViewModel?
    var enteredText:String?
    var placeholder:String?
    var inputType:String?
    var noteType:String?
    
    let speechRecognizer       = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    var sfDelegate: SFSpeechRecognizerDelegate?
    var recognitionRequest      : SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask         : SFSpeechRecognitionTask?
    let audioEngine             = AVAudioEngine()
    
    let listOfSwearWords = ["id", "race", "crap", "fuck", "darn", "damn","shit","dl","color","weight","jerk","bipolar","height"]
    
    
    static func instantiate() -> EnterDescriptionPopupViewController? {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "\(EnterDescriptionPopupViewController.self)") as? EnterDescriptionPopupViewController
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
        textView.delegate = self
        
        textView.text = enteredText
        
        
        if enteredText == ""{
            placeholderLbl.isHidden = false
            textView.becomeFirstResponder()
        }
        else{
            placeholderLbl.isHidden = true
        }
        
        
        if inputType == "Notes"{
            if noteType == "Back"{
                submitBtn.isHidden = true
                saveBtn.isHidden = false
                discardBtn.isHidden = false
            }
            else{
                submitBtn.isHidden = false
                saveBtn.isHidden = true
                discardBtn.isHidden = true
            }
            
            popupLbl.text = "Enter Notes"
            placeholderLbl.text = ""
            placeholderLbl.isHidden = true
        }
        else{
            submitBtn.isHidden = false
            saveBtn.isHidden = true
            discardBtn.isHidden = true
            popupLbl.text = "Enter Description"
            placeholderLbl.text = placeholder
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    
    
    @IBAction func action_close(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        
    }
    
    
    
    @IBAction func actionSave(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        AppConstants.notes = textView.text
        self.noteDelegate?.addnote(forSave:true)
        
    }
    
    
    @IBAction func actionDiscard(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        self.noteDelegate?.addnote(forSave:false)
        
    }
    
    
    @IBAction func action_micPress(_ sender: Any) {
        if audioEngine.isRunning {
            self.audioEngine.stop()
            self.recognitionRequest?.endAudio()
            // self.micBtn.isEnabled = false
            // self.micBtn.setTitle("Start Recording", for: .normal)
            micBtn.tintColor = UIColor.darkGray
        } else {
            if AVAudioSession.sharedInstance().isOtherAudioPlaying == false{
                setupSpeech()
            }
            else{
                AppUtility.showAlertWithProperty("Alert", messageString: "Microphone currently unavailable.")
                micBtn.tintColor = UIColor.darkGray
            }
        }
        enteredText = textView.text
    }
    
    
    @IBAction func action_submit(_ sender: Any) {
        self.audioEngine.stop()
        self.recognitionRequest?.endAudio()
        enteredText = textView.text
        let trimmed = enteredText!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmed == "" || trimmed == " "{
            showAlertMessage(titleStr: "Alert", messageStr: "Description cannot be empty.")
            return
        }
        
        if inputType == "Description" && trimmed.count < 5{
            showAlertMessage(titleStr: "Alert", messageStr: "Description must be at least 5 characters.")
            return
        }
        
        
        dismiss(animated: true, completion: nil)
        if inputType == "Notes"{
            AppConstants.notes = enteredText!
        }
        if inputType == "Description"{
            if enteredText == placeholder{
                enteredText = ""
            }
            self.addDescriptionDelegate?.addEnteredDescription(text: enteredText)
        }
        
    }
    
    @IBAction func action_clear(_ sender: Any) {
        
        textView.text = ""
        self.audioEngine.stop()
        self.recognitionRequest?.endAudio()
        
        self.micBtn.isEnabled = true
        micBtn.tintColor = UIColor.darkGray
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [self] in
            //call any function
            textView.text = ""
            enteredText = ""
            placeholderLbl.isHidden = false
        }
        
    }
    
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool{
        
        var newString = NSString(string: textView.text!).replacingCharacters(in: range, with: text)
        let newLength:Int = newString.count
        if newLength < 1{
            placeholderLbl.isHidden = false
        }
        else{
            placeholderLbl.isHidden = true
        }
        
        var arr = newString.components(separatedBy: " ")
        let wordTyped = (arr[arr.count-1]).lowercased()
        if (containsSwearWord(text: wordTyped , swearWords: listOfSwearWords)){
            //let string = newString.replacingOccurrences(of: (arr[arr.count-1]), with: "")
            //showAlertMessage(titleStr: "Alert", messageStr: "")
            arr[arr.count-1] = ""
            let string = arr.joined(separator: " ")
            newString = string
            textView.text = newString
            return false
        }
        
        let containsSpclChr = newString.hasSpecialCharacters()
        if containsSpclChr == true{
            //            let filteredString = newString.removeSpecialCharacters()
            //            enteredText = newString
            //                textView.text = filteredString
            return false
        }
        
        if(newLength < 251){
            enteredText = newString
            return true
        }
        
        return false
    }
    
    
    
    
    //    func textViewDidEndEditing(_ textView: UITextView) {
    //       // Run code here for when user ends editing text view
    //        print(containsSwearWord(text: textView.text, swearWords: listOfSwearWords)) // Here you check every text change on input UITextField
    //     }
    
    
    func containsSwearWord(text: String, swearWords: [String]) -> Bool {
        for word in swearWords{
            if word == text{
                return true
            }
        }
        //    return swearWords
        //        .reduce(false) { $0 || text == ($1.lowercased()) }
        return false
    }
    
    
    
    
    @objc func keyboardWillAppear() {
        //Do something here
        if enteredText == "" && textView.text == ""{
            placeholderLbl.isHidden = false
        }
    }
    
    @objc func keyboardWillDisappear() {
        //Do something here
        if textView.text == ""{
            placeholderLbl.isHidden = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.audioEngine.stop()
        self.recognitionRequest?.endAudio()
        micBtn.tintColor = UIColor.darkGray
        NotificationCenter.default.removeObserver(self)
    }
}








// MIC EXTENSION








extension EnterDescriptionPopupViewController{
    
    func setupSpeech() {
        //self.micBtn.isEnabled = false
        self.speechRecognizer?.delegate = sfDelegate
        
        SFSpeechRecognizer.requestAuthorization { [self] (authStatus) in
            
            var isButtonEnabled = false
            
            switch authStatus {
            case .authorized:
                isButtonEnabled = true
                if AVAudioSession.sharedInstance().isOtherAudioPlaying == true{
                    // DispatchQueue.main.async {
                    stopMic()
                    //     return
                    //   }
                }
                else{
                    checkMic(speechEnabled:isButtonEnabled)
                }
                
            case .denied:
                isButtonEnabled = false
                print("User denied access to speech recognition")
                showPermissonAlert()
                self.micBtn.tintColor = UIColor.darkGray
            case .restricted:
                isButtonEnabled = false
                print("Speech recognition restricted on this device")
                showPermissonAlert()
                self.micBtn.tintColor = UIColor.darkGray
            case .notDetermined:
                isButtonEnabled = false
                self.micBtn.tintColor = UIColor.darkGray
                print("Speech recognition not yet authorized")
                showPermissonAlert()
            @unknown default:
                self.micBtn.tintColor = UIColor.darkGray
                print("Speech recognition not yet authorized")
                showPermissonAlert()
            }
            
        }
    }
    
    
    
    func checkMic(speechEnabled:Bool){
        var isButtonEnabled = false
        
        if (audioSession.responds(to: #selector(AVAudioSession.requestRecordPermission(_:)))) {
            AVAudioSession.sharedInstance().requestRecordPermission({(granted: Bool)-> Void in
                if granted {
                    isButtonEnabled = true
                    if isButtonEnabled == true && speechEnabled == true{
                        OperationQueue.main.addOperation() { [self] in
                            startRecording()
                            micBtn.tintColor = UIColor.systemOrange
                        }
                    }
                    else{
                        self.showPermissonAlert()
                        self.micBtn.tintColor = UIColor.darkGray
                    }
                    do {
                        try audioSession.setCategory(AVAudioSession.Category.playAndRecord)
                        try audioSession.setActive(true)
                    }
                    catch {
                        
                        print("Couldn't set Audio session category")
                    }
                } else{
                    self.showPermissonAlert()
                    self.micBtn.tintColor = UIColor.darkGray
                }
            })
        }
        
        
        
    }
    
    
    func showPermissonAlert(){
        AppUtility.showAlertWithProperty("Alert", messageString: "To use microphone go to app settings and turn on Microphone and Speech Recognition"  )
        return
    }
    
    
    
    
    func startRecording(){
        let prevText = enteredText
        // Clear all previous session data and cancel task
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        // Create instance of audio session to record voice
        //  let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.record,
                                         mode: AVAudioSession.Mode.measurement)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
            micBtn.tintColor = .darkGray
        }
        
        self.recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
            micBtn.tintColor = .darkGray
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        self.recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { [self] (result, error) in
            
            var isFinal = false
            
            if result != nil {
                print(result?.bestTranscription.formattedString as Any)
                
                placeholderLbl.isHidden = true
                let attributedString:String  =  (result?.bestTranscription.formattedString)!
                
                
                let finalString = attributedString
                    .split(separator: " ")  // Split them
                    .lazy                   // Maybe it's very long, and we don't want intermediates
                    .map(String.init)       // Convert to the same type as array
                    .filter { !listOfSwearWords.contains(($0).lowercased()) } // Filter
                    .joined(separator: " ")
                
                
                
                textView.text = prevText! + finalString
                
                isFinal = (result?.isFinal)!
                
            }
            
            if error != nil || isFinal {
                enteredText = textView.text
                
                if enteredText == ""{
                    placeholderLbl.isHidden = true
                }
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                micBtn.tintColor = .darkGray
                
            }
        })
        
        
        //    let recordingFormat = inputNode.inputFormat(forBus: 0)
        //   let recordingFormat = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)
        inputNode.removeTap(onBus: 0)
        let sampleRate = inputNode.inputFormat(forBus: 0).sampleRate // the default sample rate from mic is 48000
        let channelCount = inputNode.inputFormat(forBus: 0).channelCount // 1
        
        let avAudioFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: sampleRate, channels: channelCount, interleaved: false)
        
        
        if AVAudioSession.sharedInstance().isOtherAudioPlaying == true{
            stopMic()
            micBtn.tintColor = .darkGray
        }
        else{
            
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: avAudioFormat) { [self] (buffer, when) in
                if AVAudioSession.sharedInstance().isOtherAudioPlaying == true{
                    stopMic()
                    self.micBtn.tintColor = UIColor.darkGray
                }
                self.recognitionRequest?.append(buffer)
            }
            
            self.audioEngine.prepare()
            
            do {
                try self.audioEngine.start()
            } catch {
                print("audioEngine couldn't start because of an error.")
                self.micBtn.tintColor = .darkGray
            }
            
        }
        //  self.lblText.text = "Say something, I'm listening!"
    }
    
    
    func stopMic(){
        self.micBtn.tintColor = UIColor.darkGray
        
//        DispatchQueue.main.async {
//            if(self.audioEngine.isRunning){
//                self.audioEngine.inputNode.removeTap(onBus: 0)
//                self.audioEngine.inputNode.reset()
//                self.audioEngine.stop()
//                self.recognitionRequest?.endAudio()
//                self.recognitionTask?.cancel()
//                    recognitionTask = nil;
//                    recognitionRequest = nil;
//                }
//        }

        self.audioEngine.stop()
        self.recognitionRequest?.endAudio()

        //          let node = audioEngine.inputNode
        //        node.removeTap(onBus: 0)
        self.recognitionRequest = nil
        self.recognitionTask = nil
        recognitionTask?.cancel()
        
    }
}



extension String {
    var condensedWhitespace: String {
        let components = self.components(separatedBy: NSCharacterSet.whitespacesAndNewlines)
        return components.filter { !$0.isEmpty }.joined(separator: " ")
    }
    
    
    func removeSpecialCharacters() -> String {
        let okayChars = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890 .,")
        return String(self.unicodeScalars.filter { okayChars.contains($0)})
    }
    
      func hasSpecialCharacters() -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: ".*[^A-Za-z0-9.,-/\"_*%#@!&()<>?\\[\\] ].*", options: .caseInsensitive)
            if let _ = regex.firstMatch(in: self, options: NSRegularExpression.MatchingOptions.reportCompletion, range: NSMakeRange(0, self.count)) {
                return true
            }
            
        } catch {
            debugPrint(error.localizedDescription)
            return false
        }
        return false
    }
    
    func hasSpecialCharactersforMail() -> Bool {
      do {
          let regex = try NSRegularExpression(pattern: ".*[^0-9].*", options: .caseInsensitive)
          if let _ = regex.firstMatch(in: self, options: NSRegularExpression.MatchingOptions.reportCompletion, range: NSMakeRange(0, self.count)) {
              return true
          }
          
      } catch {
          debugPrint(error.localizedDescription)
          return false
      }
      return false
  }
}
