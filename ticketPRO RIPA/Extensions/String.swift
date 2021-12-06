
import UIKit

extension String {
    
    var digits: String {
        return components(separatedBy: CharacterSet.decimalDigits.inverted)
            .joined()
    }
    
//    var localized: String {
//        let path = Bundle.main.path(forResource: LanguageManger.shared.currentLanguage.rawValue, ofType: "lproj")
//        let bundle = Bundle(path: path!)
//        return NSLocalizedString(self, tableName: nil, bundle: bundle!, value: "", comment: "")
//    }
    
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        
        return String(data: data, encoding: .utf8)
    }
    
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
    
    var dateFomatterSeconds : Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.date(from: self)!
    }
    
    func convertedDate() -> Date{
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.init(abbreviation: "UTC")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let convertedDate = dateFormatter.date(from: self.replacingOccurrences(of: "T", with: " ").replacingOccurrences(of: "Z", with: "")) {
            return convertedDate
        } else {
            let timeArray = self.replacingOccurrences(of: "T", with: " ").split(separator: " ")
            if timeArray.count > 1 {
                let yearMonthDate = timeArray[0].split(separator: "-")
                let hourMinuteSecond = timeArray[1].split(separator: ":")
                if let year = Int(yearMonthDate[0]), let month = Int(yearMonthDate[1]), let date = Int(yearMonthDate[2]), let hour = Int(hourMinuteSecond[0]), let minute = Int(hourMinuteSecond[1]), let second = Int(hourMinuteSecond[2]) {
                    var dateComponents = DateComponents()
                    dateComponents.year = year
                    dateComponents.month = month
                    dateComponents.day = date
                    dateComponents.timeZone = TimeZone(abbreviation: "UTC")
                    dateComponents.hour = hour
                    dateComponents.minute = minute
                    dateComponents.second = second
                    if let convertedDate = Calendar.current.date(from: dateComponents) {
                        return convertedDate
                    } else {
                        return Date()
                    }
                } else {
                    return Date()
                }
            } else {
                return Date()
            }
        }
    }
    
    func convertDate(_ formatString: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.init(abbreviation: "UTC")
        dateFormatter.dateFormat = formatString
        if let convertedDate = dateFormatter.date(from: self.replacingOccurrences(of: "T", with: " ")) {
            return convertedDate
        }
        return Date()
    }
    
    subscript(_ range: NSRange) -> String {
        let start = self.index(self.startIndex, offsetBy: range.lowerBound)
        let end = self.index(self.startIndex, offsetBy: range.upperBound)
        let subString = self[start..<end]
        return String(subString)
    }
    
    func toImage() -> UIImage? {
        if let imageData = Data(base64Encoded: self, options: .ignoreUnknownCharacters) {
            if let decodedimage: UIImage = UIImage(data: imageData) {
                return decodedimage
            } else {
                return nil
            }
        }
        return nil
    }
    
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }
    
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}

//MARK: Text size
extension String {
    
    func widthOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }
    
    func heightOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.height
    }
    
    func sizeOfString(usingFont font: UIFont) -> CGSize {
        let fontAttributes = [NSAttributedString.Key.font: font]
        return self.size(withAttributes: fontAttributes)
    }
}
extension String {

    /// Handles 10 or 11 digit phone numbers
    ///
    /// - Returns: formatted phone number or original value
    public func toPhoneNumber() -> String {
        let digits = self.digitsOnly
        if digits.count == 10 {
            return digits.replacingOccurrences(of: "(\\d{3})(\\d{3})(\\d+)", with: "$1-$2-$3", options: .regularExpression, range: nil)
        }
        else if digits.count == 11 {
            return digits.replacingOccurrences(of: "(\\d{1})(\\d{3})(\\d{3})(\\d+)", with: "$1($2)-$3-$4", options: .regularExpression, range: nil)
        }
        else {
            return self
        }
    }

}

extension StringProtocol {

    /// Returns the string with only [0-9], all other characters are filtered out
    var digitsOnly: String {
        return String(filter(("0"..."9").contains))
    }

}
