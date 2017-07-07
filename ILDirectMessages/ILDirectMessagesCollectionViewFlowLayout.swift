//
//  ILDirectMessagesCollectionViewFlowLayout.swift
//  ILDirectMessages
//
//  Created by Igar Liubavetskiy on 2017-06-14.
//  Copyright © 2017 Igar Liubavetskiy. All rights reserved.
//

import UIKit

class ILDirectMessagesCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    var messageFont: UIFont!
    var messageTextViewFrameInsets: UIEdgeInsets!
    var messageTextViewTextContainerInsets: UIEdgeInsets!
    var topLabelHeight: CGFloat!
    var bottomLabelHeight: CGFloat!
    var incomingProfileImageViewSize: CGSize!
    var outgoingProfileImageViewSize: CGSize!
    
    internal var cellSizeCalculator = ILDirectMessagesCellSizeCalculator()
    
    var itemWidth: CGFloat {
        get {
            guard let collectionView = self.collectionView else { return 0.0 }
            return collectionView.frame.width - self.sectionInset.left - self.sectionInset.right
        }
    }
    
    
    override class var layoutAttributesClass: AnyClass {
        return ILDirectMessagesCollectionViewLayoutAttributes.self
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.commonPrepare()
    }
    
    override func prepare() {
        super.prepare()
        self.commonPrepare()
    }
    
    func commonPrepare() {
        self.scrollDirection = .vertical
        self.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
        self.minimumLineSpacing = 2.0;
        
        self.messageFont = UIFont.systemFont(ofSize: 17)
        
        self.messageTextViewFrameInsets = UIEdgeInsetsMake(8.0, 8.0, 8.0, 8.0)
        self.messageTextViewTextContainerInsets = UIEdgeInsetsMake(0.0, 0, 0.0, 0.0)
        
        let defaultProfileImageSize = CGSize(width: 30.0, height: 30.0)
        self.incomingProfileImageViewSize = defaultProfileImageSize
        self.outgoingProfileImageViewSize = defaultProfileImageSize
        
        self.topLabelHeight = 0.0
        self.bottomLabelHeight = 0.0

        // todo 
        // Add observer for Memory warning notifications
        // Add observer for Orientation change notifications
    }
    
}

extension ILDirectMessagesCollectionViewFlowLayout {
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributesInRect = super.layoutAttributesForElements(in: rect)!
        for attributes in attributesInRect {
            if (attributes.representedElementCategory == UICollectionElementCategory.cell) {
                self.configureMessageCellLayoutAttributes(with: attributes as! ILDirectMessagesCollectionViewLayoutAttributes)
            } else {
                attributes.zIndex = -1
            }
        }
        
        return attributesInRect
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let customAttributes = super.layoutAttributesForItem(at: indexPath) as? ILDirectMessagesCollectionViewLayoutAttributes else { return nil }
        
        if (customAttributes.representedElementCategory == UICollectionElementCategory.cell) {
            self.configureMessageCellLayoutAttributes(with: customAttributes)
        }
        
        return customAttributes
    }
    
    func prepareAttributes(forElementAtIndexPath indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return self.prepareAttributes(forElementAtIndexPath: indexPath)
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}

extension ILDirectMessagesCollectionViewFlowLayout {
    func messageContainerSizeForItem(at indexPath: IndexPath) -> CGSize {
        guard let collectionView = self.collectionView as? ILDirectMessagesCollectionView else { return CGSize.zero }
        let messageMetadata = collectionView.message(at: indexPath)
        
        return self.cellSizeCalculator.cellContainerSizeForItem(at: indexPath, messageMetadata: messageMetadata, layout: self)
    }
    
    func sizeForItem(at indexPath: IndexPath) -> CGSize {
        let messageSize = self.messageContainerSizeForItem(at: indexPath)
        return CGSize(width: self.itemWidth, height: messageSize.height)
    }
    
    func configureMessageCellLayoutAttributes(with layoutAttributes: ILDirectMessagesCollectionViewLayoutAttributes) {
        let indexPath = layoutAttributes.indexPath
        
        let messageCellSize = self.messageContainerSizeForItem(at: indexPath)
        
        layoutAttributes.messageContainerViewWidth = ceil(messageCellSize.width)
        
        layoutAttributes.textViewFrameInsets = self.messageTextViewFrameInsets
        
        layoutAttributes.topLabelHeight = self.topLabelHeight
        
        layoutAttributes.bottomLabelHeight = self.bottomLabelHeight
        
        layoutAttributes.textViewTextContainerInsets = self.messageTextViewTextContainerInsets
        
        layoutAttributes.incomingProfileImageViewSize = self.incomingProfileImageViewSize
        
        layoutAttributes.outgoingProfileImageViewSize = self.outgoingProfileImageViewSize

        layoutAttributes.messageFont = self.messageFont
    }
    
}
