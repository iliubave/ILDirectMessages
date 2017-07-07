//
//  ILDirectCollectionView.swift
//  ILDirectMessages
//
//  Created by Igar Liubavetskiy on 2017-06-18.
//  Copyright © 2017 Igar Liubavetskiy. All rights reserved.
//

import UIKit

class ILDirectMessagesCollectionView: UICollectionView {

    var messages: [ILMessage]!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func message(at indexPath: IndexPath) -> ILMessage {
        return messages[indexPath.item]
    }
}
