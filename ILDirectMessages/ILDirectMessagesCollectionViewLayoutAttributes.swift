//
//  ILDirectMessagesCollectionViewLayoutAttributes.swift
//  ILDirectMessages
//
//  Created by Igar Liubavetskiy on 2017-06-15.
//  Copyright © 2017 Igar Liubavetskiy. All rights reserved.
//

import UIKit

class ILDirectMessagesCollectionViewLayoutAttributes: UICollectionViewLayoutAttributes {
    var messageFont: UIFont!
    var messageContainerViewWidth: CGFloat!
    var textViewTextContainerInsets: UIEdgeInsets!
    var textViewFrameInsets: UIEdgeInsets!
    var topLabelHeight: CGFloat!
    var bottomLabelHeight: CGFloat!
    var incomingProfileImageViewSize: CGSize!
    var outgoingProfileImageViewSize: CGSize!
    
    override var hash: Int {
        get {
            return self.indexPath.hashValue
        }
    }
}

extension ILDirectMessagesCollectionViewLayoutAttributes {
    override func copy(with zone: NSZone? = nil) -> Any {
        let copy = super.copy(with: zone) as! ILDirectMessagesCollectionViewLayoutAttributes
        
        if (copy.representedElementCategory != UICollectionElementCategory.cell) {
            return copy
        }
        
        copy.messageFont = self.messageFont;
        copy.textViewFrameInsets = self.textViewFrameInsets;
        copy.messageContainerViewWidth = self.messageContainerViewWidth;
        copy.textViewTextContainerInsets = self.textViewTextContainerInsets;
        copy.incomingProfileImageViewSize = self.incomingProfileImageViewSize;
        copy.outgoingProfileImageViewSize = self.outgoingProfileImageViewSize;
        copy.topLabelHeight = self.topLabelHeight;
        copy.bottomLabelHeight = self.bottomLabelHeight;
        
        return copy;
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let attributesObject = object as? ILDirectMessagesCollectionViewLayoutAttributes else { return false }
        
        return (attributesObject.messageFont == self.messageFont &&
            UIEdgeInsetsEqualToEdgeInsets(attributesObject.textViewFrameInsets, self.textViewFrameInsets) &&
            UIEdgeInsetsEqualToEdgeInsets(attributesObject.textViewTextContainerInsets, self.textViewTextContainerInsets) &&
            __CGSizeEqualToSize(attributesObject.incomingProfileImageViewSize, self.incomingProfileImageViewSize) &&
            __CGSizeEqualToSize(attributesObject.outgoingProfileImageViewSize, self.outgoingProfileImageViewSize) &&
            (attributesObject.messageContainerViewWidth != self.messageContainerViewWidth) &&
            (attributesObject.topLabelHeight != self.topLabelHeight) &&
            (attributesObject.bottomLabelHeight != self.bottomLabelHeight))
    }
}
