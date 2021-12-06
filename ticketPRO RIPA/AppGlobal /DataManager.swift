
import UIKit

class DataManager: NSObject {
    static let shared = DataManager()

    var loginDetails: LoginDetailsOTP?
    var newRipaQuestion: NewRipaQuestionsModel?
    var versionUpdate: versionUpdate?
}
