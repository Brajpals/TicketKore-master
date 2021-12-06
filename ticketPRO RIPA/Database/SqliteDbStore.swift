//
//  SqliteDbStore.swift
//  ticketPRO RIPA



import Foundation
import Foundation
import SQLite3

class SqliteDbStore {
    
    
    let fileURL = try! FileManager.default
        .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        .appendingPathComponent("ticketpro.db")
    
    var db: OpaquePointer?
    
    
    
    
    func openDatabase(){
        if sqlite3_open(fileURL.path, &db) == SQLITE_OK {
            print("Successfully opened connection to database at \(fileURL.path)")
            
        } else {
            print("Unable to open database.")
            return
        }
    }
    
    
    let  AllQues = "QuestionTable";
    let  AllOptions = "OptionTable";
    let  AllSaveQues = "useSaveRipaQuestionsTable";
    let  AllSaveOptions = "useSaveRipaOptionsTable";
    let  city = "cityTable";
    let  location = "locationTable";
    let  violation = "violationTable";
    let  school = "schoolTable";
    let  educationCode = "educationCodeTable";
    
    let  saveripaactivity = "saveRipaActivityTable";
    let  saveripaPersons = "saveripaPersonsTable";
    // let  saveripaResponse = "saveripaResponseTable";
    
    let  ripaTempMaster = "ripaTempMasterTable"
    
    
    
    
    var  createQuestionsTable = "create table if not exists QuestionTable (id TEXT,custid TEXT,question TEXT ,question_info TEXT,question_key TEXT, question_code TEXT, questionTypeId TEXT, inputTypeId TEXT, is_add_value TEXT,`internal` TEXT, is_required TEXT, isAddtion TEXT, isCascade_Question TEXT, ripa_group_id TEXT, isDescription_Required TEXT, common_question TEXT, editable_question TEXT, visible_question TEXT,order_number TEXT,is_active TEXT, CreatedBy TEXT,CreatedOn TEXT,UpdatedBy TEXT, UpdatedOn TEXT,inputTypeCode TEXT,questionTypeCode TEXT,groupName TEXT);"
    
    
    
    var  createOptionsTable = "create table if not exists OptionTable (key TEXT, person_name TEXT, mainQuestId TEXT, mainQuestOrder TEXT,option_id TEXT,ripa_id TEXT,custid TEXT,option_value TEXT,cascade_ripa_id TEXT,isK_12School TEXT,isHideQuesText TEXT,order_number TEXT,CreatedBy TEXT,CreatedOn TEXT,UpdatedBy TEXT,UpdatedOn TEXT,isSelected TEXT, isAddtion TEXT, isDescription_Required TEXT, inputTypeCode TEXT, questionTypeCode TEXT , tag TEXT, physical_attribute TEXT, default_value TEXT, description TEXT,question_code_for_cascading_id TEXT , isQuestionMandatory TEXT, isQuestionDescriptionReq TEXT, main_question_id TEXT)"
    
    
    
    
    var  createUseSaveRipaOptionTable = "create table if not exists useSaveRipaOptionsTable (key TEXT, person_name TEXT, mainQuestId TEXT, mainQuestOrder TEXT, option_id TEXT,ripa_id TEXT,custid TEXT,option_value TEXT,cascade_ripa_id TEXT,isK_12School TEXT,isHideQuesText TEXT,order_number TEXT,CreatedBy TEXT,CreatedOn TEXT,UpdatedBy TEXT,UpdatedOn TEXT,isSelected TEXT, isAddtion TEXT, isDescription_Required TEXT, inputTypeCode TEXT, questionTypeCode TEXT , tag TEXT, physical_attribute TEXT, default_value TEXT, description TEXT,question_code_for_cascading_id TEXT, isQuestionMandatory TEXT, isQuestionDescriptionReq TEXT, main_question_id TEXT)"
    
    
    var  createSaveRipaActivityTable = "create table if not exists saveRipaActivityTable(key TEXT,custid TEXT,date_time TEXT,userid TEXT,username TEXT,Notes TEXT,latitude TEXT,longitude TEXT,start_date TEXT,end_date TEXT,deviceid TEXT,is_K_12_Student TEXT,CreatedBy TEXT, ip_address TEXT)"
    
    var  createSaveRipaPersonTable = "create table if not exists saveRipaPersonTable(key TEXT, person_name TEXT , date TEXT, time TEXT, duration TEXT)"
    
    
    
    var  createRipaTempMasterTable = "create table if not exists ripaTempMasterTable(key TEXT, skeletonID TEXT,activityId TEXT, custid TEXT, userid TEXT, username TEXT, rmsid TEXT, phoneNumber TEXT, location TEXT, city TEXT, street TEXT, block TEXT, intersectionStreet TEXT, note TEXT, activity_notes TEXT, CreatedBy TEXT, ticketDate TEXT, declarationDate TEXT, violation TEXT, violationCode TEXT, violationType TEXT, violationID TEXT, offenceCode TEXT, email TEXT, createdOn TEXT, updatedBy TEXT, updatedOn TEXT, citationNumber TEXT, status TEXT, statusChnageDate TEXT, ripaTempId TEXT, tempType TEXT, stopDate TEXT, stopTime TEXT , stopDuration TEXT,rejectedURL TEXT,mainStatus TEXT, syncStatus TEXT, startDate TEXT , endDate TEXT, is_K_12_Student TEXT, lat TEXT,Long TEXT, timeTaken TEXT, countyId TEXT, deviceid TEXT,  callNumber TEXT, callTime TEXT , onsceneTime TEXT, clearTimeOfOfficer TEXT, overallCallClearTime TEXT, callType TEXT, unitId TEXT, zone TEXT)"
    
    //var createRipaResponseTable = "create table if not exists createRipaResponseTable(question_id TEXT, response TEXT,internal TEXT,userid TEXT,question TEXT,CreatedBy TEXT,physical_attribute TEXT, key TEXT,personName TEXT, personId TEXT)"
    
    var  createCountyTable = "create table if not exists countyTable(countyID TEXT, countyName TEXT, courtHolidays TEXT, webAddress TEXT)"
    
    var  createFeatureTable = "create table if not exists featureTable(feature_id TEXT, custid TEXT, feature TEXT, admin TEXT, officer TEXT, value TEXT, is_active TEXT, order_number TEXT, module_name TEXT, module TEXT )"
    
    var  createCityTable = "create table if not exists cityTable(JsonString TEXT);"
    
    var  createLocationTable = "create table if not exists locationTable(JsonString TEXT);"
    
    var  createViolationTable = "create table if not exists violationTable(JsonString TEXT);"
    
    var  createSchoolTable = "create table if not exists schoolTable(JsonString TEXT);"
    
    var  createEducationCodeTable = "create table if not exists educationCodeTable(JsonString TEXT);"
    
    
    
    
    func createTable(insertTableString:String) {
        var createTableStatement: OpaquePointer?
        if sqlite3_prepare_v2(db,insertTableString, -1, &createTableStatement, nil) == SQLITE_OK
        {
            if sqlite3_step(createTableStatement) == SQLITE_DONE
            {
                print("TABLE created.")
            } else {
                print("TABLE could not be created.")
            }
        } else {
            print("CREATE TABLE statement could not be prepared.")
        }
        sqlite3_finalize(createTableStatement)
    }
    
    
    
    
    func checkEmptyTable(insertTableString:String) -> String{
        var stmt: OpaquePointer?
        var count:String?
        let query = "SELECT count(*) FROM \(insertTableString)"
        if sqlite3_prepare_v2(db,query, -1, &stmt, nil) == SQLITE_OK
        {
            while(sqlite3_step(stmt) == SQLITE_ROW){
                count = String(cString: sqlite3_column_text(stmt, 0))
                print(count!)
            }
        } else {
            print("")
        }
        return count ?? String(0)
        // sqlite3_finalize(stmt)
    }
    
    
    func UpdateDatabase() {
        
        //   DispatchQueue.main.asyncAfter(deadline: .now() + 2.0){ }
        
        self.adddbfield(sFieldName: "main_question_id",sTable: "OptionTable");
        self.adddbfield(sFieldName: "main_question_id",sTable: "useSaveRipaOptionsTable");
        self.adddbfield(sFieldName: "timeTaken",sTable: "ripaTempMasterTable");
        self.adddbfield(sFieldName: "countyID",sTable: "ripaTempMasterTable");
        self.adddbfield(sFieldName: "deviceid",sTable: "ripaTempMasterTable");
        
        self.adddbfield(sFieldName: "callNumber",sTable: "ripaTempMasterTable");
        self.adddbfield(sFieldName: "callTime",sTable: "ripaTempMasterTable");
        self.adddbfield(sFieldName: "clearTimeOfOfficer",sTable: "ripaTempMasterTable");
        self.adddbfield(sFieldName: "overallCallClearTime",sTable: "ripaTempMasterTable");
        self.adddbfield(sFieldName: "callType",sTable: "ripaTempMasterTable");
        self.adddbfield(sFieldName: "unitId",sTable: "ripaTempMasterTable");
        self.adddbfield(sFieldName: "zone",sTable: "ripaTempMasterTable");
    }
    
    
    
 
    
    func adddbfield(sFieldName:String, sTable:String)
    {
        //  let bReturn:Bool = false;
        let sSQL="ALTER TABLE \(sTable) ADD COLUMN \(sFieldName) NOT NULL DEFAULT ''";
        var alterstatement:OpaquePointer?
        var count:String?
        if sqlite3_prepare_v2(db,sSQL, -1, &alterstatement, nil) == SQLITE_OK
        {
            while(sqlite3_step(alterstatement) == SQLITE_ROW){
                count = String(cString: sqlite3_column_text(alterstatement, 0))
                print(count!)
            }
        } else {
            print("Failed to prepare statement")
        }
        //   return bReturn
    }
    
    
    
    
    func deleteAllfrom(table : String){
        var insertStatement: OpaquePointer?
        
        if(sqlite3_prepare_v2(db, "delete from \(table)", -1, &insertStatement, nil) == SQLITE_OK) {
            // Loop through the results and add them to the feeds array
            while(sqlite3_step(insertStatement) == SQLITE_ROW) {
                // Read the data from the result row
                print("result is here");
            }
        }
    }
    
    
    
    
    func updateActivityId(key:String, activityId:String){
        let updateStatementString = "UPDATE ripaTempMasterTable SET activityId = '\(activityId)' WHERE key = '\(key)'"
        var updateStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, updateStatementString, -1, &updateStatement, nil) == SQLITE_OK {
            if sqlite3_step(updateStatement) == SQLITE_DONE {
                print("Successfully updated row.")
            } else {
                print("Could not update row.")
            }
        } else {
            print("UPDATE statement could not be prepared")
        }
        sqlite3_finalize(updateStatement)
    }
    
    
    
    
    func insertCounty(county : CountyResult) {
        var insertStatement: OpaquePointer?
        
        let insertQuestionString = "insert into countyTable(countyID , countyName , courtHolidays, webAddress ) VALUES (?,?,?,?);"
        
        if sqlite3_prepare_v2(db, insertQuestionString, -1, &insertStatement, nil) == SQLITE_OK {
            
            sqlite3_bind_text(insertStatement, 1, (county.countyID as NSString).utf8String , -1, nil)
            sqlite3_bind_text(insertStatement, 2, (county.countyName as NSString).utf8String , -1, nil)
            sqlite3_bind_text(insertStatement, 3, (county.courtHolidays as NSString).utf8String , -1, nil)
            sqlite3_bind_text(insertStatement, 4, (county.webAddress as NSString).utf8String , -1, nil)
            
            if sqlite3_step(insertStatement) == SQLITE_DONE {
            } else {
                print("\nCould not insert row.")
            }
        } else {
            print("\nINSERT statement is not prepared.")
        }
        sqlite3_finalize(insertStatement)
    }
    
    
    func getCounty()-> [CountyResult]? {
        let queryString = "SELECT * FROM countyTable"
        
        var countyList = [CountyResult]()
        var stmt:OpaquePointer?
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return nil
        }
        while(sqlite3_step(stmt) == SQLITE_ROW){
            let countyID = String(cString: sqlite3_column_text(stmt, 0))
            let countyName = String(cString: sqlite3_column_text(stmt, 1))
            let courtHolidays = String(cString: sqlite3_column_text(stmt,2))
            let webAddress = String(cString: sqlite3_column_text(stmt, 3))
            
            let county = CountyResult(countyID: countyID, countyName: countyName, courtHolidays: courtHolidays, webAddress: webAddress, isSelected: false)
            countyList.append(county)
        }
        return countyList
    }
    
    
    
    func insertFeature(feature : FeaturesResult) {
        var insertStatement: OpaquePointer?
        
        let insertQuestionString = "insert into featureTable(feature_id, custid, feature, admin, officer, value, is_active, order_number, module_name, module) VALUES (?,?,?,?,?,?,?,?,?,?);"
        
        if sqlite3_prepare_v2(db, insertQuestionString, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(insertStatement, 1, (feature.featureID as NSString).utf8String , -1, nil)
            sqlite3_bind_text(insertStatement, 2, (feature.custid as NSString).utf8String , -1, nil)
            sqlite3_bind_text(insertStatement, 3, (feature.feature as NSString).utf8String , -1, nil)
            sqlite3_bind_text(insertStatement, 4, (feature.admin as NSString).utf8String , -1, nil)
            sqlite3_bind_text(insertStatement, 5, (feature.officer as NSString).utf8String , -1, nil)
            sqlite3_bind_text(insertStatement, 6, (feature.value as NSString).utf8String , -1, nil)
            sqlite3_bind_text(insertStatement, 7, (feature.isActive as NSString).utf8String , -1, nil)
            sqlite3_bind_text(insertStatement, 8, (feature.orderNumber as NSString).utf8String , -1, nil)
            sqlite3_bind_text(insertStatement, 9, (feature.moduleName as NSString).utf8String , -1, nil)
            sqlite3_bind_text(insertStatement, 10,(feature.module as NSString).utf8String , -1, nil)
            
            if sqlite3_step(insertStatement) == SQLITE_DONE {
            } else {
                print("\nCould not insert row.")
            }
        } else {
            print("\nINSERT statement is not prepared.")
        }
        sqlite3_finalize(insertStatement)
    }
    
    
    func getFeature()-> [FeaturesResult]? {
        let queryString = "SELECT * FROM featureTable"
        
        var FeatureList = [FeaturesResult]()
        var stmt:OpaquePointer?
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return nil
        }
        while(sqlite3_step(stmt) == SQLITE_ROW){
            let feature_id = String(cString: sqlite3_column_text(stmt, 0))
            let custid = String(cString: sqlite3_column_text(stmt, 1))
            let feature = String(cString: sqlite3_column_text(stmt,2))
            let admin = String(cString: sqlite3_column_text(stmt, 3))
            let officer = String(cString: sqlite3_column_text(stmt, 4))
            let value = String(cString: sqlite3_column_text(stmt,5))
            let is_active = String(cString: sqlite3_column_text(stmt, 6))
            let order_number = String(cString: sqlite3_column_text(stmt, 7))
            let module_name = String(cString: sqlite3_column_text(stmt, 8))
            let module = String(cString: sqlite3_column_text(stmt,9))
            
            let features = FeaturesResult(featureID: feature_id, custid: custid, feature: feature, admin: admin, officer: officer, value: value, isActive: is_active, orderNumber: order_number, moduleName: module_name, module: module)
            FeatureList.append(features)
        }
        return FeatureList
    }
    
    
    
    
    func insertData(jsonString : String, tableName:String) {
        
        var insertStatement: OpaquePointer?
        
        let insertString = "insert into \(tableName) (JsonString) VALUES (?);"
        
        if sqlite3_prepare_v2(db, insertString, -1, &insertStatement, nil) == SQLITE_OK {
            
            sqlite3_bind_text(insertStatement, 1,(jsonString as NSString).utf8String , -1, nil)
            
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                // print("\nSuccessfully inserted row.")
            } else {
                print("\nCould not insert row.")
            }
        } else {
            print("\nINSERT statement is not prepared.")
        }
        // 5
        sqlite3_finalize(insertStatement)
    }
    
    
    
    
    
    
    
    func getCity(tableName:String)-> String? {
        
        let queryString = "SELECT * FROM \(tableName)"
        
        //statement pointer
        var stmt:OpaquePointer?
        
        //preparing the query
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return nil
        }
        var jsonString:String?
        //traversing through all the records
        while(sqlite3_step(stmt) == SQLITE_ROW){
            jsonString = String(cString: sqlite3_column_text(stmt, 0))
        }
        return jsonString
    }
    
    
    
    
    
    func insertRipaPerson(ripaPerson : RipaPerson, tableName:String) {
        var insertStatement: OpaquePointer?
        
        let insertQuestionString = "insert into \(tableName)(key , person_name , date, time , duration) VALUES (?,?,?,?,?);"
        
        if sqlite3_prepare_v2(db, insertQuestionString, -1, &insertStatement, nil) == SQLITE_OK {
            
            sqlite3_bind_text(insertStatement, 1, (ripaPerson.key as NSString).utf8String , -1, nil)
            sqlite3_bind_text(insertStatement, 2, (ripaPerson.person_name as NSString).utf8String , -1, nil)
            sqlite3_bind_text(insertStatement, 3, (ripaPerson.date as NSString).utf8String , -1, nil)
            sqlite3_bind_text(insertStatement, 4, (ripaPerson.time as NSString).utf8String , -1, nil)
            sqlite3_bind_text(insertStatement, 5, (ripaPerson.duration as NSString).utf8String , -1, nil)
            
            if sqlite3_step(insertStatement) == SQLITE_DONE {
            } else {
                print("\nCould not insert row.")
            }
        } else {
            print("\nINSERT statement is not prepared.")
        }
        sqlite3_finalize(insertStatement)
    }
    
    
    
    
    func getRipaPerson(tableName:String)-> [RipaPerson]? {
        let queryString = "SELECT * FROM \(tableName)"
        
        var ripaPerson = [RipaPerson]()
        var stmt:OpaquePointer?
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return nil
        }
        while(sqlite3_step(stmt) == SQLITE_ROW){
            let key = String(cString: sqlite3_column_text(stmt, 0))
            let id = String(cString: sqlite3_column_text(stmt, 1))
            let date = String(cString: sqlite3_column_text(stmt,2))
            let time = String(cString: sqlite3_column_text(stmt, 3))
            let duration = String(cString: sqlite3_column_text(stmt, 4))
            
            let person = RipaPerson(CreatedBy: "", person_name: id, key: key,date : date,time : time,duration : duration, ripa_response: [])
            ripaPerson.append(person)
        }
        return ripaPerson
    }
    
    
    
    
    
    
    func insertRipaTempMaster(ripaResponse : RipaTempMaster, tableName:String) {
        var insertStatement: OpaquePointer?
        
        let insertQuestionString = "insert into ripaTempMasterTable (key , skeletonID ,activityId, custid , userid , username , rmsid , phoneNumber , location , city , street , block , intersectionStreet , note , activity_notes , CreatedBy , ticketDate , declarationDate , violation , violationCode , violationType , violationID , offenceCode , email , createdOn , updatedBy , updatedOn , citationNumber , status, statusChnageDate , ripaTempId, tempType , stopDate, stopTime ,stopDuration, rejectedURL, mainStatus,syncStatus ,startDate,endDate,is_K_12_Student,lat, long, timeTaken, countyId, deviceid, callNumber, callTime, onsceneTime, clearTimeOfOfficer, overallCallClearTime, callType, unitId, zone)VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);"
        
        if sqlite3_prepare_v2(db, insertQuestionString, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(insertStatement, 1,  (ripaResponse.key as NSString).utf8String , -1, nil)
            sqlite3_bind_text(insertStatement, 2,  (ripaResponse.skeletonID as NSString).utf8String , -1, nil)
            sqlite3_bind_text(insertStatement, 3,  (ripaResponse.activityId as NSString).utf8String , -1, nil)
            sqlite3_bind_text(insertStatement, 4,  (ripaResponse.custid as NSString).utf8String , -1, nil)
            sqlite3_bind_text(insertStatement, 5,  (ripaResponse.userid as NSString).utf8String , -1, nil)
            sqlite3_bind_text(insertStatement, 6,  (ripaResponse.username as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 7,  (ripaResponse.rmsid as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 8,  (ripaResponse.phoneNumber as NSString).utf8String , -1, nil)
            sqlite3_bind_text(insertStatement, 9,  (ripaResponse.location as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 10, (ripaResponse.city as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 11,  (ripaResponse.street as NSString).utf8String , -1, nil)
            sqlite3_bind_text(insertStatement, 12,  (ripaResponse.block as NSString).utf8String , -1, nil)
            sqlite3_bind_text(insertStatement, 13,  (ripaResponse.intersectionStreet as NSString).utf8String , -1, nil)
            sqlite3_bind_text(insertStatement, 14,  (ripaResponse.note as NSString).utf8String , -1, nil)
            sqlite3_bind_text(insertStatement, 15,  (ripaResponse.activity_notes as NSString).utf8String , -1, nil)
            sqlite3_bind_text(insertStatement, 16,  (ripaResponse.CreatedBy as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 17,  (ripaResponse.ticketDate as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 18,  (ripaResponse.declarationDate as NSString).utf8String , -1, nil)
            sqlite3_bind_text(insertStatement, 19,  (ripaResponse.violation as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 20,  (ripaResponse.violationCode as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 21,  (ripaResponse.violationType as NSString).utf8String , -1, nil)
            sqlite3_bind_text(insertStatement, 22,  (ripaResponse.violationID as NSString).utf8String , -1, nil)
            sqlite3_bind_text(insertStatement, 23,  (ripaResponse.offenceCode as NSString).utf8String , -1, nil)
            sqlite3_bind_text(insertStatement, 24,  (ripaResponse.email as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 25,  (ripaResponse.createdOn as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 26,  (ripaResponse.updatedBy as NSString).utf8String , -1, nil)
            sqlite3_bind_text(insertStatement, 27,  (ripaResponse.updatedOn as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 28,  (ripaResponse.citationNumber as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 29,  (ripaResponse.status as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 30, (ripaResponse.statusChnageDate as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 31,  (ripaResponse.ripaTempId as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 32, (ripaResponse.tempType as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 33,  (ripaResponse.stopDate as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 34,  (ripaResponse.stopTime as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 35,  (ripaResponse.stopDuration as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 36, (ripaResponse.rejectedURL as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 37, (ripaResponse.mainStatus as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 38, (ripaResponse.syncStatus as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 39, (ripaResponse.startDate as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 40, (ripaResponse.endDate as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 41, (ripaResponse.is_K_12_Student as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 42, (ripaResponse.lat as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 43, (ripaResponse.long as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 44, (ripaResponse.timeTaken as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 45, (ripaResponse.countyId as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 46, (ripaResponse.deviceid as NSString).utf8String, -1, nil)
            
            sqlite3_bind_text(insertStatement, 47, (ripaResponse.callNumber as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 48, (ripaResponse.callTime as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 49, (ripaResponse.onsceneTime as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 50, (ripaResponse.clearTimeOfOfficer as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 51, (ripaResponse.overallCallClearTime as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 52, (ripaResponse.callType as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 53, (ripaResponse.unitId as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 54, (ripaResponse.zone as NSString).utf8String, -1, nil)
            
            if sqlite3_step(insertStatement) == SQLITE_DONE {
            } else {
                print("\nCould not insert row.")
            }
        } else {
            print("\nINSERT statement is not prepared.")
        }
        sqlite3_finalize(insertStatement)
    }
    
    
    
    func getRipaTempMaster(tableName:String)-> [RipaTempMaster]? {
        let queryString = tableName
        //"SELECT * FROM ripaTempMasterTable"
        
        var ripaTemp = [RipaTempMaster]()
        var stmt:OpaquePointer?
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return nil
        }
        
        while(sqlite3_step(stmt) == SQLITE_ROW){
            let key = String(cString: sqlite3_column_text(stmt, 0))
            let skeletonID = String(cString: sqlite3_column_text(stmt, 1))
            let activityId = String(cString: sqlite3_column_text(stmt, 2))
            let custid = String(cString: sqlite3_column_text(stmt,3))
            let userid = String(cString: sqlite3_column_text(stmt, 4))
            let username = String(cString: sqlite3_column_text(stmt, 5))
            let rmsid = String(cString: sqlite3_column_text(stmt, 6))
            let phoneNumber = String(cString: sqlite3_column_text(stmt, 7))
            let location = String(cString: sqlite3_column_text(stmt,8))
            let city = String(cString: sqlite3_column_text(stmt, 9))
            let street = String(cString: sqlite3_column_text(stmt, 10))
            let block = String(cString: sqlite3_column_text(stmt, 11))
            let intersectionStreet = String(cString: sqlite3_column_text(stmt, 12))
            let note = String(cString: sqlite3_column_text(stmt,13))
            let activity_notes = String(cString: sqlite3_column_text(stmt,14))
            let CreatedBy = String(cString: sqlite3_column_text(stmt, 15))
            let ticketDate = String(cString: sqlite3_column_text(stmt, 16))
            let declarationDate = String(cString: sqlite3_column_text(stmt, 17))
            let violation = String(cString: sqlite3_column_text(stmt, 18))
            let violationCode = String(cString: sqlite3_column_text(stmt,19))
            let violationType = String(cString: sqlite3_column_text(stmt, 20))
            let violationID = String(cString: sqlite3_column_text(stmt, 21))
            let offenceCode = String(cString: sqlite3_column_text(stmt, 22))
            let email = String(cString: sqlite3_column_text(stmt, 23))
            let createdOn = String(cString: sqlite3_column_text(stmt,24))
            let updatedBy = String(cString: sqlite3_column_text(stmt, 25))
            let updatedOn = String(cString: sqlite3_column_text(stmt, 26))
            let citationNumber = String(cString: sqlite3_column_text(stmt, 27))
            let status = String(cString: sqlite3_column_text(stmt, 28))
            let statusChnageDate = String(cString: sqlite3_column_text(stmt,29))
            let ripaTempId = String(cString: sqlite3_column_text(stmt, 30))
            let tempType = String(cString: sqlite3_column_text(stmt, 31))
            let stopDate = String(cString: sqlite3_column_text(stmt, 32))
            let stopTime = String(cString: sqlite3_column_text(stmt, 33))
            let stopDuration = String(cString: sqlite3_column_text(stmt, 34))
            let rejectedURL = String(cString: sqlite3_column_text(stmt, 35))
            let mainStatus = String(cString: sqlite3_column_text(stmt, 36))
            let syncStatus = String(cString: sqlite3_column_text(stmt, 37))
            let startDate = String(cString: sqlite3_column_text(stmt, 38))
            let endDate = String(cString: sqlite3_column_text(stmt, 39))
            let is_K_12_Student = String(cString: sqlite3_column_text(stmt, 40))
            let lat = String(cString: sqlite3_column_text(stmt, 41))
            let long = String(cString: sqlite3_column_text(stmt, 42))
            let timeTaken = String(cString: sqlite3_column_text(stmt, 43))
            let countyId = String(cString: sqlite3_column_text(stmt, 44))
            let deviceid = String(cString: sqlite3_column_text(stmt, 45))
            
            let callNumber = String(cString: sqlite3_column_text(stmt, 46))
            let callTime = String(cString: sqlite3_column_text(stmt, 47))
            let onsceneTime = String(cString: sqlite3_column_text(stmt, 48))
            let clearTimeOfOfficer = String(cString: sqlite3_column_text(stmt, 49))
            let overallCallClearTime = String(cString: sqlite3_column_text(stmt, 50))
            let callType = String(cString: sqlite3_column_text(stmt, 51))
            let unitId = String(cString: sqlite3_column_text(stmt, 52))
            let zone = String(cString: sqlite3_column_text(stmt, 53))
            
            let ripaList = RipaTempMaster(key: key, skeletonID: skeletonID,activityId: activityId, custid: custid, userid: userid, username: username, rmsid: rmsid, phoneNumber: phoneNumber, location: location, city: city, street: street, block: block, intersectionStreet: intersectionStreet, note: note, activity_notes: activity_notes, CreatedBy: CreatedBy, ticketDate: ticketDate, declarationDate: declarationDate, violation: violation, violationCode: violationCode, violationType: violationType, violationID: violationID, offenceCode: offenceCode, email: email, createdOn: createdOn, updatedBy: updatedBy, updatedOn: updatedOn, citationNumber: citationNumber, status: status, mainStatus: mainStatus, statusChnageDate: statusChnageDate, ripaTempId: ripaTempId, tempType: tempType, stopDate: stopDate, stopTime: stopTime, stopDuration: stopDuration, rejectedURL: rejectedURL, syncStatus: syncStatus,startDate:startDate,endDate: endDate,is_K_12_Student: is_K_12_Student,lat: lat,long: long, timeTaken: timeTaken, countyId: countyId, deviceid: deviceid, callNumber: callNumber, callTime: callTime, onsceneTime: onsceneTime, clearTimeOfOfficer: clearTimeOfOfficer, overallCallClearTime: overallCallClearTime, callType: callType, unitId: unitId, zone: zone)
            
            ripaTemp.append(ripaList)
            
        }
        return ripaTemp
    }
    
    
    
    
    
    // Insert Questions Data
    
    func insertQuestion(question : QuestionResult1, tableName:String) {
        
        var insertStatement: OpaquePointer?
        
        
        let insertQuestionString = "insert into \(tableName) (id ,custid ,question , question_info,question_key, question_code, questionTypeId, inputTypeId, is_add_value ,`internal`, is_required , isAddtion, isCascade_Question, ripa_group_id, isDescription_Required, common_question, editable_question,visible_question,order_number,is_active, CreatedBy,CreatedOn,UpdatedBy, UpdatedOn,inputTypeCode,questionTypeCode,groupName ) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);"
        
        if sqlite3_prepare_v2(db, insertQuestionString, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(insertStatement, 1,  (question.id as NSString).utf8String , -1, nil)
            sqlite3_bind_text(insertStatement, 2,  (question.custid as NSString).utf8String , -1, nil)
            sqlite3_bind_text(insertStatement, 3,  (question.question as NSString).utf8String , -1, nil)
            sqlite3_bind_text(insertStatement, 4,  (question.question_info as NSString).utf8String , -1, nil)
            sqlite3_bind_text(insertStatement, 5,  (question.question_key as NSString).utf8String , -1, nil)
            sqlite3_bind_text(insertStatement, 6,  (question.question_code as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 7,  (question.questionTypeId as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 8,  (question.inputTypeId as NSString).utf8String , -1, nil)
            sqlite3_bind_text(insertStatement, 9,  (question.is_add_value as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 10, (question.internal as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 11, (question.is_required as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 12, (question.isAddtion as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 13, (question.isCascade_Question as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 14, (question.ripa_group_id as NSString).utf8String , -1, nil)
            sqlite3_bind_text(insertStatement, 15, (question.isDescription_Required as NSString).utf8String , -1, nil)
            sqlite3_bind_text(insertStatement, 16, (question.common_question as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 17, (question.editable_question as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 18, (question.visible_question as NSString).utf8String , -1, nil)
            sqlite3_bind_text(insertStatement, 19, (question.order_number as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 20, (question.is_active as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 21, (question.CreatedBy as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 22, (question.CreatedOn as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 23, (question.UpdatedBy as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 24, (question.UpdatedOn as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 25, (question.inputTypeCode as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 26, (question.questionTypeCode as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 27, (question.groupName as NSString).utf8String, -1, nil)
 
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                // print("\nSuccessfully inserted row.")
            } else {
                print("\nCould not insert row.")
            }
        } else {
            print("\nINSERT statement is not prepared.")
        }
        // 5
        sqlite3_finalize(insertStatement)
    }
    
    
    
    
    
    // Insert options Data
    
    func insertOptions(options : Questionoptions1,tableName:String, personID:String,key:String) {
        var insertStatement: OpaquePointer?
        
        let insertOptionString = "insert into \(tableName) (key ,person_name ,mainQuestId , mainQuestOrder ,option_id ,ripa_id ,custid ,option_value, cascade_ripa_id, isK_12School, isHideQuesText, order_number ,CreatedBy, CreatedOn , UpdatedBy, UpdatedOn, isSelected, isAddtion, isDescription_Required, inputTypeCode, questionTypeCode,tag,physical_attribute,default_value,description, question_code_for_cascading_id, isQuestionMandatory , isQuestionDescriptionReq , main_question_id ) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);"
        
        if sqlite3_prepare_v2(db, insertOptionString, -1, &insertStatement, nil) == SQLITE_OK {
            
            sqlite3_bind_text(insertStatement, 1, (key as NSString).utf8String , -1, nil)
            sqlite3_bind_text(insertStatement, 2, (personID as NSString).utf8String , -1, nil)
            
            sqlite3_bind_text(insertStatement, 3, (options.mainQuestId as NSString).utf8String , -1, nil)
            sqlite3_bind_text(insertStatement, 4, (options.mainQuestOrder as NSString).utf8String , -1, nil)
            
            sqlite3_bind_text(insertStatement, 5, (options.option_id as NSString).utf8String , -1, nil)
            sqlite3_bind_text(insertStatement, 6, (options.ripa_id as NSString).utf8String , -1, nil)
            sqlite3_bind_text(insertStatement, 7, (options.custid as NSString).utf8String , -1, nil)
            sqlite3_bind_text(insertStatement, 8, (options.option_value as NSString).utf8String , -1, nil)
            sqlite3_bind_text(insertStatement, 9, (options.cascade_ripa_id as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 10,(options.isK_12School as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 11,(options.isHideQuesText as NSString).utf8String , -1, nil)
            sqlite3_bind_text(insertStatement, 12,(options.order_number as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 13,(options.createdBy as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 14,(options.createdOn as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 15,(options.updatedBy as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 16,(options.updatedOn as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 18,(options.isAddtion as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 19,(options.isDescription_Required as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 20,(options.inputTypeCode as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 21,(options.questionTypeCode as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 22,(options.tag as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 23,(options.physical_attribute as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 24,(options.default_value as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 25,(options.optionDescription as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 26,(options.question_code_for_cascading_id as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 27,(options.isQuestionMandatory as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 28,(options.isQuestionDescriptionReq as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 29,(options.main_question_id as NSString).utf8String, -1, nil)
            
            let isSelected = options.isSelected
            var selected:String?
            if isSelected == false{selected="false"}else{selected="true"}
            
            sqlite3_bind_text(insertStatement, 17, (selected! as NSString).utf8String, -1, nil)
            
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                //print("\nSuccessfully inserted row.")
            } else {
                print("\nCould not insert row.")
            }
        } else {
            print("\nINSERT statement is not prepared.")
        }
    }
    
    
    
    
    
    
    //Get questions from database
    
    var questionList = [QuestionResult1]()
    
    func getQuestions(tableName:String , getcascadeQuest:Int)-> [QuestionResult1]? {
        questionList.removeAll()
        let queryString = "SELECT * FROM \(tableName)"
        
        //statement pointer
        var stmt:OpaquePointer?
        
        //preparing the query
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return nil
        }
        
        //traversing through all the records
        while(sqlite3_step(stmt) == SQLITE_ROW){
            let id = String(cString: sqlite3_column_text(stmt, 0))
            let custid = String(cString: sqlite3_column_text(stmt, 1))
            let question = String(cString: sqlite3_column_text(stmt, 2))
            let question_info = String(cString: sqlite3_column_text(stmt, 3))
            let question_key = String(cString: sqlite3_column_text(stmt, 4))
            let question_code = String(cString: sqlite3_column_text(stmt, 5))
            let questionTypeId = String(cString: sqlite3_column_text(stmt, 6))
            let inputTypeId = String(cString: sqlite3_column_text(stmt, 7))
            let is_add_value = String(cString: sqlite3_column_text(stmt, 8))
            let `internal` = String(cString: sqlite3_column_text(stmt, 9))
            let is_required = String(cString: sqlite3_column_text(stmt, 10))
            let isAddtion = String(cString: sqlite3_column_text(stmt, 11))
            let isCascade_Question = String(cString: sqlite3_column_text(stmt, 12))
            let ripa_group_id = String(cString: sqlite3_column_text(stmt, 13))
            let isDescription_Required = String(cString: sqlite3_column_text(stmt,14))
            let common_question = String(cString: sqlite3_column_text(stmt, 15))
            let editable_question = String(cString: sqlite3_column_text(stmt, 16))
            let visible_question = String(cString: sqlite3_column_text(stmt, 17))
            let order_number = String(cString: sqlite3_column_text(stmt, 18))
            let is_active = String(cString: sqlite3_column_text(stmt, 19))
            let CreatedBy = String(cString: sqlite3_column_text(stmt, 20))
            let CreatedOn = String(cString: sqlite3_column_text(stmt, 21))
            let UpdatedBy = String(cString: sqlite3_column_text(stmt, 22))
            let UpdatedOn = String(cString: sqlite3_column_text(stmt, 23))
            let inputTypeCode = String(cString: sqlite3_column_text(stmt, 24))
            let questionTypeCode = String(cString: sqlite3_column_text(stmt, 25))
            let groupName = String(cString: sqlite3_column_text(stmt, 26))
            
            
            //adding values to list
            
            let quest = QuestionResult1(id: id, custid: custid, question: question, question_info: question_info ,question_key: question_key ,question_code: question_code, questionTypeId: questionTypeId, inputTypeId: inputTypeId, is_add_value: is_add_value, internal: `internal`, is_required: is_required, isAddtion: isAddtion, isCascade_Question: isCascade_Question, ripa_group_id: ripa_group_id, isDescription_Required: isDescription_Required, common_question: common_question, editable_question: editable_question, visible_question: visible_question, order_number: order_number, is_active: is_active, CreatedBy: CreatedBy, CreatedOn: CreatedOn, UpdatedBy:UpdatedBy, UpdatedOn:UpdatedOn , inputTypeCode:inputTypeCode , questionTypeCode:questionTypeCode , groupName: groupName, questionoptions: [])
            
            if isCascade_Question == "0" && getcascadeQuest == 0 && visible_question == "1" {
                questionList.append(quest)
            }
            else if (isCascade_Question == "1" || visible_question == "0") && getcascadeQuest == 1{
                questionList.append(quest)
            }
            
         }
        return questionList
        
    }
    
    
    
    //   Get Options And Merge With Questions
    
    var optionList = [Questionoptions1]()
    
    func getQuestionOptions(tableName:String , optionFor:String, person_name:String, key:String) -> [QuestionResult1]? {
        
        for question in questionList {
            optionList.removeAll()
            let  quesId =  question.id
            var queryString = ""
            if optionFor == ""{
                queryString = "SELECT * FROM  \(tableName)  WHERE  ripa_id = \(quesId)"
            }
            else{
                queryString = "SELECT * FROM  \(tableName)  WHERE  ripa_id = \(quesId) AND person_name = \(person_name) AND key = \(key)"
            }
            
            optionList = getOptions(queryString: queryString)!
            
            question.questionoptions = optionList
            if optionList.count > 0{
                if question.isCascade_Question == "1"{
                    print(optionList[0].mainQuestOrder)
                    question.order_number = optionList[0].mainQuestOrder
                }
                
                if question.isCascade_Question == "0"{
                    if question.is_required == "0"{
                        if optionList[0].isQuestionDescriptionReq != ""{
                            question.isDescription_Required = optionList[0].isQuestionDescriptionReq
                            question.is_required = optionList[0].isQuestionMandatory
                        }
                    }
                }
                
            }
            //  i += 1
        }
        return questionList
    }
    
    
    
    func getOptions(queryString:String)->[Questionoptions1]?{
        optionList.removeAll()
        var stmt:OpaquePointer?
        var options:Questionoptions1?
        
        //preparing the query
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return nil
        }
        
        //traversing through all the records
        while(sqlite3_step(stmt) == SQLITE_ROW){
            let mainQuestId = String(cString: sqlite3_column_text(stmt, 2))
            let mainQuestOrder = String(cString: sqlite3_column_text(stmt, 3))
            
            let option_id = String(cString: sqlite3_column_text(stmt, 4))
            let ripa_id = String(cString: sqlite3_column_text(stmt, 5))
            let custid = String(cString: sqlite3_column_text(stmt, 6))
            let option_value = String(cString: sqlite3_column_text(stmt, 7))
            let cascade_ripa_id = String(cString: sqlite3_column_text(stmt, 8))
            let isK_12School = String(cString: sqlite3_column_text(stmt, 9))
            let isHideQuesText = String(cString: sqlite3_column_text(stmt, 10))
            let order_number = String(cString: sqlite3_column_text(stmt, 11))
            let createdBy = String(cString: sqlite3_column_text(stmt, 12))
            let createdOn = String(cString: sqlite3_column_text(stmt, 13))
            let updatedBy = String(cString: sqlite3_column_text(stmt, 14))
            let updatedOn = String(cString: sqlite3_column_text(stmt, 15))
            let isSelected = String(cString: sqlite3_column_text(stmt, 16))
            let isAddtion = String(cString: sqlite3_column_text(stmt, 17))
            let isDescription_Required = String(cString: sqlite3_column_text(stmt, 18))
            let inputTypeCode = String(cString: sqlite3_column_text(stmt, 19))
            let questionTypeCode = String(cString: sqlite3_column_text(stmt, 20))
            let tag = String(cString: sqlite3_column_text(stmt, 21))
            let physical_attribute = String(cString: sqlite3_column_text(stmt, 22))
            let default_value = String(cString: sqlite3_column_text(stmt, 23))
            let description = String(cString: sqlite3_column_text(stmt, 24))
            let question_code_for_cascading_id = String(cString: sqlite3_column_text(stmt, 25))
            let isQuestionMandatory = String(cString: sqlite3_column_text(stmt, 26))
            let isQuestionDescriptionReq = String(cString: sqlite3_column_text(stmt, 27))
            let main_question_id = String(cString: sqlite3_column_text(stmt, 28))
            
            var selected:Bool?
            if isSelected == "false"{selected=false}else{selected=true}
            
            
            
            //adding values to list
            options = Questionoptions1(mainQuestId: mainQuestId, mainQuestOrder: mainQuestOrder, option_id: option_id, ripa_id: ripa_id, custid: custid, option_value: option_value, cascade_ripa_id: cascade_ripa_id, isK_12School: isK_12School, isHideQuesText: isHideQuesText, order_number: order_number, createdBy: createdBy, createdOn: createdOn, updatedBy: updatedBy, updatedOn: updatedOn, isSelected: selected! ,isAddtion: isAddtion, isDescription_Required: isDescription_Required, inputTypeCode: inputTypeCode, questionTypeCode: questionTypeCode,tag:tag,  physical_attribute:physical_attribute, default_value: default_value, optionDescription: description, question_code_for_cascading_id: question_code_for_cascading_id, isQuestionMandatory: isQuestionMandatory, isQuestionDescriptionReq: isQuestionDescriptionReq, main_question_id: main_question_id , isExpanded: false, questionoptions: [])
            
            optionList.append(options!)
        }
        return optionList
    }
    
    
}




// Indicates an exception during a SQLite Operation.
class SqliteError : Error {
    var message = ""
    var error = SQLITE_ERROR
    init(message: String = "") {
        self.message = message
    }
    init(error: Int32) {
        self.error = error
    }
    
}
