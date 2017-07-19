//
//  ILDirectMessagesCollectionViewFlowLayout.swift
//  ILDirectMessages
//
//  Created by Igar Liubavetskiy on 2017-06-14.
//  Copyright © 2017 Igar Liubavetskiy. All rights reserved.
//

import UIKit

class ILDirectMessagesCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    internal var messageFont: UIFont!
    internal var messageTextViewFrameInsets: UIEdgeInsets!
    internal var messageTextViewTextContainerInsets: UIEdgeInsets!
    internal var topLabelHeight: CGFloat!
    internal var bottomLabelHeight: CGFloat!
    internal var incomingProfileImageViewSize: CGSize!
    internal var outgoingProfileImageViewSize: CGSize!
    
    internal var cellSizeCalculator = ILDirectMessagesCellSizeCalculator()
    
    internal lazy var dynamicAnimator: UIDynamicAnimator = {
        return UIDynamicAnimator(collectionViewLayout: self)
    }()
    
    internal var itemWidth: CGFloat {
        get {
            guard let collectionView = self.collectionView else { return 0.0 }
            return collectionView.frame.width - self.sectionInset.left - self.sectionInset.right
        }
    }
    
    internal var visibleIndexPaths: [IndexPath] = []
    internal var lastContentOffset: CGPoint = CGPoint.zero
    internal var lastScrollDelta: CGFloat = 0.0
    internal var lastTouchLocation: CGPoint = CGPoint.zero
    
    internal let scrollPadding: CGFloat = 300.0
    internal let scrollRefreshThreshold: CGFloat = 50.0
    internal let scrollResistanceCoefficient: CGFloat = 1 / 4500.0
    internal let damping: CGFloat = 1.0
    internal let frequency: CGFloat = 1.0
    
    override class var layoutAttributesClass: AnyClass {
        return ILDirectMessagesCollectionViewLayoutAttributes.self
    }
    
    override class var invalidationContextClass: AnyClass {
        return ILDirectMessagesCollectionViewFlowLayoutInvalidationContext.self
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
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
    }
    
    override func prepare() {
        super.prepare()
        self.commonPrepare()
    }
    
    func commonPrepare() {
        if let collectionView = self.collectionView,
            let itemsInCurrentRect = super.layoutAttributesForElements(in: currentRect),
            !self.shouldReturnOnPrepare {
            
            lastContentOffset = collectionView.contentOffset
            
            let indexPathsInVisibleRect = itemsInCurrentRect.map { $0.indexPath }
            
            self.dynamicAnimator.behaviors.forEach { self.removeIfNeeded(forBehavior: $0, indexPaths: indexPathsInVisibleRect) }
            
            let newVisibleItems = itemsInCurrentRect.filter { !self.visibleIndexPaths.contains($0.indexPath) }
            
            newVisibleItems.forEach { add(toAttributes: $0) }
        }
    }
    
}

extension ILDirectMessagesCollectionViewFlowLayout {
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var rect = rect
        rect.size.height += scrollPadding
        rect.origin.y -= scrollPadding
        
        guard let attributesInRect: [UICollectionViewLayoutAttributes] = super.layoutAttributesForElements(in: rect),
            var attributesInRectCopy = NSArray(array: attributesInRect, copyItems: true) as? [UICollectionViewLayoutAttributes] else { return nil }
        
        let dynamicAttributes = dynamicAnimator.items(in: rect) as! [UICollectionViewLayoutAttributes]
            
        for attributesObject in attributesInRectCopy {
            let attributesObjectCopy = attributesObject.copy() as! ILDirectMessagesCollectionViewLayoutAttributes
            for dynamicAttributesObject in dynamicAttributes {
                if (attributesObjectCopy.indexPath == dynamicAttributesObject.indexPath &&
                    attributesObjectCopy.representedElementCategory == dynamicAttributesObject.representedElementCategory) {
                    
                    if let indexOfAttributesObject = attributesInRectCopy.index(of: attributesObjectCopy) {
                        attributesInRectCopy.remove(at: indexOfAttributesObject)
                        attributesInRectCopy.append(dynamicAttributesObject)
                        continue
                    }
                }
            }
        }
        
        for attributesObject in attributesInRectCopy {
            if (attributesObject.representedElementCategory == UICollectionElementCategory.cell) {
                self.configureMessageCellLayoutAttributes(with: attributesObject as! ILDirectMessagesCollectionViewLayoutAttributes)
            } else {
                attributesObject.zIndex = -1
            }
        }
        
        return attributesInRectCopy
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let customAttributes = super.layoutAttributesForItem(at: indexPath) as? ILDirectMessagesCollectionViewLayoutAttributes else { return nil }
        
        if (customAttributes.representedElementCategory == UICollectionElementCategory.cell) {
            self.configureMessageCellLayoutAttributes(with: customAttributes)
        }
        
        return customAttributes
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard let collectionView = self.collectionView else { return false }
        
        self.lastScrollDelta = newBounds.origin.y - collectionView.bounds.origin.y
        self.lastTouchLocation = collectionView.panGestureRecognizer.location(in: collectionView)
        
        if !self.shouldReturnOnPrepare {
            self.invalidateLayout()
        }
        
        self.dynamicAnimator.behaviors.forEach { update($0, withLastTouchLocation: lastTouchLocation) }
        
        return false
    }
    
    func invalidateLayout(with context: ILDirectMessagesCollectionViewFlowLayoutInvalidationContext) {
        if context.invalidateDataSourceCounts {
            context.invalidateFlowLayoutAttributes = true
            context.invalidateFlowLayoutDelegateMetrics = true
        }
        
        if (context.invalidateFlowLayoutAttributes || context.invalidateFlowLayoutDelegateMetrics) {
            self.dynamicAnimator.removeAllBehaviors()
            self.visibleIndexPaths.removeAll()
        }
        
        if context.invalidateFlowLayoutCache {
            self.cellSizeCalculator.cache.removeAll()
            self.dynamicAnimator.removeAllBehaviors()
            self.visibleIndexPaths.removeAll()
            print("if context.invalidateFlowLayoutCache")
        }
        
        super.invalidateLayout(with: context)
    }
    
}

extension ILDirectMessagesCollectionViewFlowLayout {
    
    internal func adjust(_ attachmentBehavior: UIAttachmentBehavior, centerForTouchPosition touchLocation: CGPoint) {
        guard let item = attachmentBehavior.items.first else { return }
        
        let distanceFromTouchY = fabs(touchLocation.y - attachmentBehavior.anchorPoint.y)
        let distanceFromTouchX = fabs(touchLocation.x - attachmentBehavior.anchorPoint.x)
        let scrollResistance = (distanceFromTouchX + distanceFromTouchY) * self.scrollResistanceCoefficient
        
        var center = item.center
        guard !__CGPointEqualToPoint(center, CGPoint.zero) else { return }
        
        if self.lastScrollDelta < 0.0 {
            center.y += max(lastScrollDelta, self.lastScrollDelta * scrollResistance)
        } else {
            center.y += min(lastScrollDelta, self.lastScrollDelta * scrollResistance)
        }
        
        item.center = center
    }
    
    internal func attachmentBehavior(with attributes: UICollectionViewLayoutAttributes) -> UIAttachmentBehavior {
        let attachmentBehavior = UIAttachmentBehavior.init(item: attributes, attachedToAnchor: attributes.center)
        attachmentBehavior.length = 0.0
        attachmentBehavior.frequency = self.frequency
        attachmentBehavior.damping = self.damping
        attachmentBehavior.action = { [weak attachmentBehavior] in
            guard let attachmentBehavior = attachmentBehavior else { return }
            
            let delta = fabs(attributes.center.y - attachmentBehavior.anchorPoint.y)
            attachmentBehavior.damping = delta <= 1.0 ? 100.0 : self.damping
        }
        
        return attachmentBehavior
    }
    
    internal func removeIfNeeded(forBehavior behavior: UIDynamicBehavior, indexPaths: [IndexPath]) {
        guard let attachmentBehavior = behavior as? UIAttachmentBehavior,
            let firstBehavior = attachmentBehavior.items.first,
            let attributes = firstBehavior as? UICollectionViewLayoutAttributes,
            !indexPaths.contains(attributes.indexPath) else { return }
        
        self.dynamicAnimator.removeBehavior(behavior)
        
        if let index = visibleIndexPaths.index(of: attributes.indexPath) {
            visibleIndexPaths.remove(at: index)
        }
    }
    
    internal func add(toAttributes attributes: UICollectionViewLayoutAttributes) {
        let attachmentBehavior = self.attachmentBehavior(with: attributes)
        
        if self.lastScrollDelta != 0.0 {
            self.adjust(attachmentBehavior, centerForTouchPosition: lastTouchLocation)
        }
        
        self.dynamicAnimator.addBehavior(attachmentBehavior)
        self.visibleIndexPaths.append(attributes.indexPath)
    }
    
    internal func update(_ behavior: UIDynamicBehavior, withLastTouchLocation touchLocation: CGPoint) {
        guard let attachmentBehavior = behavior as? UIAttachmentBehavior,
            let item = attachmentBehavior.items.first else { return }
        
        self.adjust(attachmentBehavior, centerForTouchPosition: self.lastTouchLocation)
        self.dynamicAnimator.updateItem(usingCurrentState: item)
    }
    
    internal var scrollBelowThreshold: Bool {
        guard let contentOffset = self.collectionView?.contentOffset else { return true }
        return fabs(contentOffset.y - self.lastContentOffset.y) < self.scrollRefreshThreshold
    }
    
    internal var shouldReturnOnPrepare: Bool {
        return self.scrollBelowThreshold && self.visibleIndexPaths.count == 0
    }

    
    internal var currentRect: CGRect {
        guard let collectionView = self.collectionView else { return CGRect.zero }
        
        let y: CGFloat = collectionView.contentOffset.y - self.scrollPadding
        let height: CGFloat = collectionView.bounds.size.height + self.scrollPadding
        
        return CGRect(x: 0.0, y: y, width: collectionView.bounds.width, height: height)
    }
}

extension ILDirectMessagesCollectionViewFlowLayout {
    func messageContainerSizeForItem(at indexPath: IndexPath) -> CGSize {
        guard let collectionView = self.collectionView as? ILDirectMessagesCollectionView  else { return CGSize.zero }
        
        let message = collectionView.message(at: indexPath)
        return self.cellSizeCalculator.cellContainerSizeForItem(at: indexPath, message: message, layout: self)
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
