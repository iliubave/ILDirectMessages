//
//  ILMessageMetadata.swift
//  ILDirectMessages
//
//  Created by Igar Liubavetskiy on 2017-06-16.
//  Copyright © 2017 Igar Liubavetskiy. All rights reserved.
//

import Foundation

protocol ILMessageMetadata: class {
    var senderName: String! { get }
    var date: Date! { get }
    var body: String! { get }
    var hash: Int { get }
    
    // todo
    // media object
}
