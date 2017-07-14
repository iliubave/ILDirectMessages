//
//  ILDirectMessagesCollectionViewFlowLayoutInvalidationContext.swift
//  ILDirectMessages
//
//  Created by Igar Liubavetskiy on 2017-07-12.
//  Copyright © 2017 Igar Liubavetskiy. All rights reserved.
//

import UIKit

class ILDirectMessagesCollectionViewFlowLayoutInvalidationContext: UICollectionViewFlowLayoutInvalidationContext {

    var invalidateFlowLayoutCache: Bool = false
    
    static var context = ILDirectMessagesCollectionViewFlowLayoutInvalidationContext()
    
    override init() {
        super.init()
        
        self.invalidateFlowLayoutCache = true
        self.invalidateFlowLayoutDelegateMetrics = true
        self.invalidateFlowLayoutAttributes = true
    }
    
}
