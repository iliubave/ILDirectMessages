//
//  ILMediaMessage.swift
//  ILDirectMessages
//
//  Created by Igar Liubavetskiy on 2017-07-16.
//  Copyright © 2017 Igar Liubavetskiy. All rights reserved.
//

import UIKit

class ILMediaMessage: ILMessage {
    var url: String!
    var image: UIImage!
    var isAudioMessage: Bool = false
    
    override var hash: Int  {
        get {
            return super.hash ^ self.url.hashValue ^ self.image.hashValue
        }
    }
}
