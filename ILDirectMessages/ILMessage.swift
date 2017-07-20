//
//  ILMessage.swift
//  ILDirectMessages
//
//  Created by Igar Liubavetskiy on 2017-06-14.
//  Copyright © 2017 Igar Liubavetskiy. All rights reserved.
//

import UIKit

class ILMessage: NSObject {
    var senderName: String!
    var date: Date!
    var body: String?
    var isIncoming: Bool!
    override var hash: Int  {
        get {
            var hash = self.senderName.hashValue ^ self.date.hashValue
            
            if let body = body {
                hash ^= body.hashValue
            }
            
            return hash
        }
    }
    
    //todo
    //init
}
