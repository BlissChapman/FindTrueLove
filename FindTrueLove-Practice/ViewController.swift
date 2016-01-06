//
//  ViewController.swift
//  FindTrueLove-Practice
//
//  Created by Bliss Chapman on 1/3/16.
//  Copyright © 2016 Bliss Chapman. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var valentinesPortraitImageView: UIImageView!
    @IBOutlet weak var valentinesNameLabel: UILabel!
    
    private let contactsHelper = ContactsHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        
        if motion == .MotionShake {
            self.promptLabel.text = "Searching..."
            
            contactsHelper.requestAccess { (accessGranted, accessError) -> Void in
                guard accessError == nil else {
                    debugPrint(accessError)
                    return
                }
                
                if accessGranted {
                    self.contactsHelper.findRandomValentine({ (valentineInfo) -> Void in
                        
                        //explicitly move back to the main queue to make sure that all user interface work is done in the proper place
                        dispatch_async(dispatch_get_main_queue()) { () -> Void in
                            
                            guard let valentineInfo = valentineInfo else {
                                self.promptLabel.text = "You will be lonely for life."
                                return
                            }
                            
                            self.promptLabel.text = "We found you a match!"
                            self.valentinesPortraitImageView.image = valentineInfo.contactPhoto
                            self.valentinesNameLabel.text = "\(valentineInfo.name)"
                        }
                    })
                } else {
                    self.promptLabel.text = "We require access to your contacts in order to function.  Please adjust your privacy settings."
                }
            }
        }
    }
}

