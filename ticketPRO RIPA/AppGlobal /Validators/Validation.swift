//
//  Validation.swift
//  ticketPRO RIPA
//
//  Created by Mamta yadav on 07/01/21.
//

import Foundation
class Validation {
   public func validatEnrollmentId(enrollment: String) ->Bool {
      
      let enrollmentRegex = "^[a-zA-Z0-9]+$"
      let trimmedString = enrollment.trimmingCharacters(in: .whitespaces)
      let validateEnrollment = NSPredicate(format: "SELF MATCHES %@", enrollmentRegex)
      let isValidateEnrollmentId = validateEnrollment.evaluate(with: trimmedString)
      return isValidateEnrollmentId
   }
   public func validPhoneNumber(phoneNumber: String) -> Bool {
      let phoneNumberRegex = "^[0-9]\\d{9}$"
      let trimmedString = phoneNumber.trimmingCharacters(in: .whitespaces)
      let validatePhone = NSPredicate(format: "SELF MATCHES %@", phoneNumberRegex)
      let isValidPhone = validatePhone.evaluate(with: trimmedString)
      return isValidPhone
   }
    public func validHeight(height: String) -> Bool {
       let phoneNumberRegex = "^\\d+'\\d+\"$"
       let trimmedString = height.trimmingCharacters(in: .whitespaces)
       let validatePhone = NSPredicate(format: "SELF MATCHES %@", phoneNumberRegex)
       let isValidPhone = validatePhone.evaluate(with: trimmedString)
       return isValidPhone
    }
   public func validateEmailId(emailID: String) -> Bool {
      let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
      let trimmedString = emailID.trimmingCharacters(in: .whitespaces)
      let validateEmail = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
      let isValidateEmail = validateEmail.evaluate(with: trimmedString)
      return isValidateEmail
   }
   public func validatePassword(password: String) -> Bool {
      //Minimum 8 characters at least 1 Alphabet and 1 Number:
      let passRegEx = "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{8,}$"
      let trimmedString = password.trimmingCharacters(in: .whitespaces)
      let validatePassord = NSPredicate(format:"SELF MATCHES %@", passRegEx)
      let isvalidatePass = validatePassord.evaluate(with: trimmedString)
      return isvalidatePass
   }
   public func validateAnyOtherTextField(otherField: String) -> Bool {
      let otherRegexString = "Your regex String"
      let trimmedString = otherField.trimmingCharacters(in: .whitespaces)
      let validateOtherString = NSPredicate(format: "SELF MATCHES %@", otherRegexString)
      let isValidateOtherString = validateOtherString.evaluate(with: trimmedString)
      return isValidateOtherString
   }
}
