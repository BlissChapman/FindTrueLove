//
//  ContactsHelper.swift
//  FindTrueLove-Practice
//
//  Created by Bliss Chapman on 1/3/16.
//  Copyright © 2016 Bliss Chapman. All rights reserved.
//

import Foundation
import UIKit
import Contacts

class ContactsHelper {
    
    static private let contactStore = CNContactStore()
    
    ///Detects the users permission to view their contacts and requests permission if necessary, passing the result of the request to the completionHandler.
    static func requestAccess(completionHandler: (accessGranted: Bool, accessError: ErrorType? ) -> Void) {
        let authorizationStatus = CNContactStore.authorizationStatusForEntityType(.Contacts)
        
        switch authorizationStatus {
        case .Authorized:
            completionHandler(accessGranted: true, accessError: nil)
            
        case .NotDetermined:
            contactStore.requestAccessForEntityType(.Contacts, completionHandler: { (access, accessError) -> Void in
                
                completionHandler(accessGranted: access, accessError: accessError)
            })
        case .Denied, .Restricted:
            completionHandler(accessGranted: false, accessError: nil)
        }
    }
    
    ///Finds a random contact with a valid name and contact photo.  If successful, the name and photo will be passed into the completion handler, otherwise the tuple will be nil.
    static func findRandomValentine(completionHandler: (name: String, contactPhoto: UIImage)? -> Void) {
        
        retrievePotentialValentines { (contacts) -> Void in
            guard let potentialValentines = contacts else {
                completionHandler(nil)
                return
            }
            
            //chose random contact from potentialValentines
            let randomContactIndex = arc4random_uniform(UInt32(potentialValentines.count))
            let randomlyChosenValentine = potentialValentines[Int(randomContactIndex)]
            
            //retrieve the contacts full name
            guard let fullName = CNContactFormatter.stringFromContact(randomlyChosenValentine, style: .FullName) else {
                completionHandler(nil)
                return
            }
            
            //retrieve the contacts photo which is guaranteed to exist
            let contactPhoto = UIImage(data: randomlyChosenValentine.imageData!)!
            
            //send the contacts info to the completionHandler
            let valentinesInfo = (name: fullName, contactPhoto: contactPhoto)
            completionHandler(valentinesInfo)
        }
    }
    
    static private func retrievePotentialValentines(callback: ([CNContact]?)->Void) -> Void {
        
        //move off the main queue while doing intense tasks like enumerating through a users entire contacts list
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) { () -> Void in
            
            //an array of contact properties to be fetched in the returned contacts
            let keys = [
                CNContactImageDataAvailableKey,
                CNContactImageDataKey,
                CNContactFormatter.descriptorForRequiredKeysForStyle(.FullName)
            ]
            
            //the contact fetch request that will fetch all contacts and the requested properties
            let fetchRequest = CNContactFetchRequest(keysToFetch: keys)
            
            //an array we will fill with the results of the fetch
            var validResults: [CNContact] = []
            
            do {
                //fetch all contacts
                try contactStore.enumerateContactsWithFetchRequest(fetchRequest, usingBlock: { (contact, stop) -> Void in
                    
                    //if the contact could be our valentine, then add it to the array of valid results
                    if contact.isPotentialValentine() {
                        validResults.append(contact)
                    }
                })
                
                
//                if validResults.isEmpty {
//                    callback(nil)
//                } else {
//                    callback(validResults)
//                }
                //this line is shorthand for the commented code above
                validResults.isEmpty ? callback(nil) : callback(validResults)
                
            } catch {
                debugPrint(error)
                callback(nil)
            }
        }
    }
}

extension CNContact {
    func isPotentialValentine() -> Bool {
        return self.imageDataAvailable && CNContactFormatter.stringFromContact(self, style: .FullName) != nil
    }
}