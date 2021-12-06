
import UIKit

extension Date {
    
    func yearsFrom(_ date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(.year, from: date, to: self, options: []).year!
    }
    func monthsFrom(_ date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(.month, from: date, to: self, options: []).month!
    }
    func weeksFrom(_ date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(.weekOfYear, from: date, to: self, options: []).weekOfYear!
    }
    func daysFrom(_ date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(.day, from: date, to: self, options: []).day!
    }
    func hoursFrom(_ date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(.hour, from: date, to: self, options: []).hour!
    }
    func minutesFrom(_ date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(.minute, from: date, to: self, options: []).minute!
    }
    func secondsFrom(_ date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(.second, from: date, to: self, options: []).second!
    }
    
    func offsetFrom(_ date:Date) -> String {
        if yearsFrom(date)   > 0 { return "\(yearsFrom(date)) "+"year\(yearsFrom(date)>1 ? "s" : "")"   }
        if monthsFrom(date)  > 0 { return "\(monthsFrom(date)) "+"month\(monthsFrom(date)>1 ? "s" : "")"  }
        if weeksFrom(date)   > 0 { return "\(weeksFrom(date)) "+"week\(weeksFrom(date)>1 ? "s" : "")"   }
        if daysFrom(date)    > 0 { return "\(daysFrom(date)) "+"day\(daysFrom(date)>1 ? "s" : "")"    }
        if hoursFrom(date)   > 0 { return "\(hoursFrom(date)) "+"hour\(hoursFrom(date)>1 ? "s" : "")"   }
        if minutesFrom(date) > 0 { return "\(minutesFrom(date)) "+"minute\(minutesFrom(date)>1 ? "s" : "")" }
        if secondsFrom(date) > 0 { return "\(secondsFrom(date)) "+"second\(secondsFrom(date)>1 ? "s" : "")" }
        return ""
    }
    
    func dateStringWithFormat(_ formatString: String, local: Bool,_ showExtension: Bool = false) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        if !local{
            dateFormatter.timeZone = TimeZone.init(abbreviation: "UTC")
        }else {
            dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        }
        
        dateFormatter.dateFormat = formatString
        var dateString = dateFormatter.string(from: self)
        if !showExtension {
            dateString = dateString.replacingOccurrences(of: " AM", with: "").replacingOccurrences(of: " PM", with: "")
        }
        return dateString
    }
    
    static func dateByAdding(day: Int) -> Date? {
        return Calendar.current.date(byAdding: .day, value: day, to: Date())
    }
}
