//
//  MKSnackbar.swift
//  MaterialKit
//
//  Created by Rahul Iyer on 14/01/16.
//  Copyright © 2016 Le Van Nghia. All rights reserved.
//

import UIKit

public class MKSnackbar: UIControl {
    
    public var text: String? {
        didSet {
            if let textLabel = self.textLabel {
                textLabel.text = text
            }
        }
    }
    public var actionTitle: String? {
        didSet {
            if let actionButton = self.actionButton {
                actionButton.setTitle(actionTitle, for: .normal)
            }
        }
    }
    public var textColor: UIColor? {
        didSet {
            if let textLabel = self.textLabel {
                textLabel.textColor = textColor
            }
        }
    }
    public var actionTitleColor: UIColor? {
        didSet {
            if let actionButton = self.actionButton {
                actionButton.setTitleColor(actionTitleColor, for: .normal)
            }
        }
    }
    public var actionRippleColor: UIColor? {
        didSet {
            if let actionButton = self.actionButton, let actionRippleColor = self.actionRippleColor {
                actionButton.rippleLayerColor = actionRippleColor
            }
        }
    }
    public var duration: TimeInterval = 3.5
    public var isShowing: Bool = false
    
    public var hiddenConstraint: NSLayoutConstraint?
    public var showingConstraint: NSLayoutConstraint?
    public var rootView: UIView?
    public var textLabel: UILabel?
    public var actionButton: MKButton?
    public var isAnimating: Bool = false
    public var delegates: NSMutableSet = NSMutableSet()
    
    // MARK: Init
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    public init(
        withTitle title: String,
        withDuration duration: TimeInterval?,
        withTitleColor titleColor: UIColor?,
        withActionButtonTitle actionTitle: String?,
        withActionButtonColor actionColor: UIColor?) {
        super.init(frame: .zero)
        self.text = title
        if let duration = duration {
            self.duration = duration
        }
        self.textColor = titleColor
        self.actionTitle = actionTitle
        self.actionTitleColor = actionColor
        self.setup()
    }
    
    public func setup() {
        if actionTitleColor == nil {
            actionTitleColor = UIColor.white
        }
        if textColor == nil {
            textColor = UIColor.white
        }
        self.backgroundColor = UIColor.black
        self.translatesAutoresizingMaskIntoConstraints = false
        
        textLabel = UILabel()
        if let textLabel = textLabel {
            textLabel.font = UIFont.systemFont(ofSize: 16)
            textLabel.textColor = textColor
            textLabel.alpha = 0
            textLabel.numberOfLines = 0
            textLabel.translatesAutoresizingMaskIntoConstraints = false
            textLabel.setContentCompressionResistancePriority(UILayoutPriority.defaultLow,
                                                              for: NSLayoutConstraint.Axis.horizontal)
        }
        
        actionButton = MKButton()
        if let actionButton = actionButton {
            actionButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
            actionButton.setTitleColor(actionTitleColor, for: .normal)
            actionButton.alpha = 0
            actionButton.isEnabled = false
            actionButton.translatesAutoresizingMaskIntoConstraints = false
            actionButton.setContentHuggingPriority(UILayoutPriority.required,
                                                   for: NSLayoutConstraint.Axis.horizontal)
            actionButton.addTarget(
                self,
                action: #selector(self.actionButtonClicked),
                for: .touchUpInside)
        }
    }
    
    // Mark: Public functions
    
    @objc public func show() {
        MKSnackbarManager.getInstance().showSnackbar(snackbar: self)
    }
    
    @objc public func dismiss() {
        if !isShowing || isAnimating {
            return
        }
        
        isAnimating = true
        
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.dismiss), object: nil)
        if let rootView = rootView {
            rootView.layoutIfNeeded()
            
            UIView.animate(
                withDuration: 0.25,
                delay: 0,
                options: .curveEaseInOut,
                animations: {() -> Void in
                    if let textLabel = self.textLabel,
                        let actionButton = self.actionButton,
                        let hiddenConstraint = self.hiddenConstraint,
                        let showingConstraint = self.showingConstraint {
                        textLabel.alpha = 0
                        actionButton.alpha = 0
                        rootView.removeConstraint(showingConstraint)
                        rootView.addConstraint(hiddenConstraint)
                        rootView.layoutIfNeeded()
                    }
                    
                }, completion: {(finished: Bool) -> Void in
                    if finished {
                        self.isAnimating = false
                        self.performDelegateAction(action: #selector(self.dismiss))
                        self.removeFromSuperview()
                        if let textLabel = self.textLabel, let actionButton = self.actionButton {
                            textLabel.removeFromSuperview()
                            actionButton.removeFromSuperview()
                        }
                        self.isShowing = false
                    }
                })
        }
    }
    
    public func addDeleagte(delegate: MKSnackbarDelegate) {
        delegates.add(delegate)
    }
    
    public func removeDelegate(delegate: MKSnackbarDelegate) {
        delegates.remove(delegate)
    }
    
    public func actionButtonSelector(withTarget target: AnyObject, andAction action: Selector) {
        if let actionButton = actionButton {
            actionButton.addTarget(target, action: action, for: .touchUpInside)
        }
    }
    
    // Mark: Action
    
    @objc internal func actionButtonClicked(sender: AnyObject) {
        performDelegateAction(action: #selector(self.actionButtonClicked))
        if let actionButton = actionButton {
            actionButton.isEnabled = false
        }
        dismiss()
    }
    
    
    // Mark: public functions
    
    public func arrangeContent() {
        if let textLabel = textLabel, let actionButton = actionButton {
            self.addSubview(textLabel)
            if let _ = actionTitle {
                self.addSubview(actionButton)
            }
            
            let views: Dictionary<String, AnyObject> = [
                "label": textLabel,
                "button": actionButton
            ]
            let metrics: Dictionary<String, AnyObject> = [
                "normalPadding": 14 as AnyObject,
                "largePadding": 24 as AnyObject
            ]
            
            let labelConstraints = NSLayoutConstraint.constraints(
                withVisualFormat: "V:|-largePadding-[label]-largePadding-|",
                options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                metrics: metrics,
                views: views
            )
            self.addConstraints(labelConstraints)
            
            if let _ = actionTitle {
                let centerConstraint = NSLayoutConstraint(
                    item: actionButton,
                    attribute: NSLayoutConstraint.Attribute.centerY,
                    relatedBy: NSLayoutConstraint.Relation.equal,
                    toItem: self,
                    attribute: NSLayoutConstraint.Attribute.centerY,
                    multiplier: 1,
                    constant: 0)
                
                self.addConstraint(centerConstraint)
                
                let horizontalContraint = NSLayoutConstraint.constraints(
                    withVisualFormat: "H:|-largePadding-[label]-largePadding-[button]-largePadding-|",
                    options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                    metrics: metrics,
                    views: views)
                self.addConstraints(horizontalContraint)
            } else {
                let horizontalContraint = NSLayoutConstraint.constraints(
                    withVisualFormat: "H:|-largePadding-[label]-largePadding-|",
                    options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                    metrics: metrics,
                    views: views)
                self.addConstraints(horizontalContraint)
            }
        }
    }
    
    public func addToScreen() {
        if let window = UIApplication.shared.keyWindow {
            rootView = window
        } else if let window = UIApplication.shared.delegate?.window {
            rootView = window
        }
        
        if let rootView = rootView {
            rootView.addSubview(self)
            let views: Dictionary<String, AnyObject> = [
                "view": self
            ]
            
            let horizontalConstraints = NSLayoutConstraint.constraints(
                withVisualFormat: "H:|-0-[view]-0-|",
                options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                metrics: nil,
                views: views)
            
            rootView.addConstraints(horizontalConstraints)
            
            hiddenConstraint = NSLayoutConstraint(
                item: self,
                attribute: NSLayoutConstraint.Attribute.top,
                relatedBy: NSLayoutConstraint.Relation.equal,
                toItem: rootView,
                attribute: NSLayoutConstraint.Attribute.bottom,
                multiplier: 1.0,
                constant: 0)
            
            showingConstraint = NSLayoutConstraint(
                item: self,
                attribute: NSLayoutConstraint.Attribute.bottom,
                relatedBy: NSLayoutConstraint.Relation.equal,
                toItem: rootView,
                attribute: NSLayoutConstraint.Attribute.bottom,
                multiplier: 1.0,
                constant: 0)
            
            rootView.addConstraint(hiddenConstraint!)
        }
        
        if let text = text, let textLabel = textLabel {
            textLabel.text = text
        }
        
        if let actionTitle = actionTitle, let actionButton = actionButton {
            actionButton.setTitle(actionTitle, for: .normal)
        }
    }
    
    public func displaySnackbar() {
        if isShowing || isAnimating {
            return
        }
        
        isShowing = true
        isAnimating = true
        
        arrangeContent()
        addToScreen()
        
        if let rootView = rootView {
            rootView.layoutIfNeeded()
            UIView.animate(
                withDuration: 0.25,
                delay: 0,
                options: .curveEaseInOut,
                animations: {() -> Void in
                    if let textLabel = self.textLabel,
                        let actionButton = self.actionButton,
                        let hiddenConstraint = self.hiddenConstraint,
                        let showingConstraint = self.showingConstraint {
                        textLabel.alpha = 1
                        actionButton.alpha = 1
                        rootView.removeConstraint(hiddenConstraint)
                        rootView.addConstraint(showingConstraint)
                        rootView.layoutIfNeeded()
                    }
                    
                }, completion: {(finished: Bool) -> Void in
                    if finished {
                        self.isAnimating = false
                        self.performDelegateAction(action: #selector(self.show))
                        self.perform(#selector(self.dismiss), with: self.dismiss(), afterDelay: self.duration)
                        if let actionButton = self.actionButton {
                            actionButton.isEnabled = true
                        }
                    }
                })
        }
    }
    
    public func performDelegateAction(action: Selector) {
        for delegate in delegates {
            if let delegate = delegate as? MKSnackbarDelegate {
                if delegate.responds(to: action) {
                    delegate.perform(action, with: self)
                }
            }
        }
    }
    
}

// MARK:- MKSnackbar Delegate
@objc public protocol MKSnackbarDelegate: NSObjectProtocol {
    @objc optional func snackbarShown(snackbar: MKSnackbar)
    @objc optional func snackbabrDismissed(snackbar: MKSnackbar)
    @objc optional func actionClicked(snackbar: MKSnackbar)
}

// MARK:- MKSnackbar Manager

public class MKSnackbarManager: NSObject, MKSnackbarDelegate {
    
    static var instance: MKSnackbarManager!
    
    public var snackbarQueue: Array<MKSnackbar>?
    
    public override init() {
        snackbarQueue = Array<MKSnackbar>()
    }
    
    static func getInstance() -> MKSnackbarManager {
        if instance == nil {
            instance = MKSnackbarManager()
        }
        return instance
    }
    
    func showSnackbar(snackbar: MKSnackbar) {
        if var snackbarQueue = snackbarQueue {
            if !snackbarQueue.contains(snackbar) {
                snackbar.addDeleagte(delegate: self)
                snackbarQueue.append(snackbar)
                
                if snackbarQueue.count == 1 {
                    snackbar.displaySnackbar()
                } else {
                    snackbarQueue[0].dismiss()
                }
            }
        }
    }
    
    @objc public func snackbabrDismissed(snackbar: MKSnackbar) {
        if var snackbarQueue = snackbarQueue {
            if let index = snackbarQueue.firstIndex(of: snackbar) {
                snackbarQueue.remove(at: index)
            }
            if snackbarQueue.count > 0 {
                snackbarQueue[0].displaySnackbar()
            }
        }
    }
}
