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
    public private(set) var isShowing: Bool = false
    
    private var hiddenConstraint: NSLayoutConstraint?
    private var showingConstraint: NSLayoutConstraint?
    private var rootView: UIView?
    private var textLabel: UILabel?
    private var actionButton: MKButton?
    private var isAnimating: Bool = false
    private var delegates: NSMutableSet = NSMutableSet()
    
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
        super.init(frame: CGRect.zero)
        self.text = title
        if let duration = duration {
            self.duration = duration
        }
        self.textColor = titleColor
        self.actionTitle = actionTitle
        self.actionTitleColor = actionColor
        self.setup()
    }
    
    private func setup() {
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
            textLabel.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: .horizontal)
        }
        
        actionButton = MKButton()
        if let actionButton = actionButton {
            actionButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
            actionButton.setTitleColor(actionTitleColor, for: .normal)
            actionButton.alpha = 0
            actionButton.isEnabled = false
            actionButton.translatesAutoresizingMaskIntoConstraints = false
            actionButton.setContentHuggingPriority(.required, for: .horizontal)
            actionButton.addTarget(
                self,
                action: #selector(actionButtonClicked(_:)),
                for: .touchUpInside)
        }
    }
    
    // Mark: Public functions
    
    public func show() {
        MKSnackbarManager.getInstance().showSnackbar(self)
    }
    
    @objc public func dismiss() {
        if !isShowing || isAnimating {
            return
        }
        
        isAnimating = true
        
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(dismiss), object: nil)
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
//                        self.performDelegateAction(#selector(snackbarDismissed(_:)))
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
    
    @objc func actionButtonClicked(_ sender: AnyObject) {
//        performDelegateAction(action: #selector(self.actionClicked(_:)))
        if let actionButton = actionButton {
            actionButton.isEnabled = false
        }
        dismiss()
    }
    
    
    // Mark: Private functions
    
    private func arrangeContent() {
        if let textLabel = textLabel, let actionButton = actionButton {
            self.addSubview(textLabel)
            if let _ = actionTitle {
                self.addSubview(actionButton)
            }
            
            let views: Dictionary<String, AnyObject> = [
                "label": textLabel,
                "button": actionButton
            ]
            let metrics: Dictionary<String, Any> = [
                "normalPadding": 14,
                "largePadding": 24
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
                    attribute: .centerY,
                    relatedBy: .equal,
                    toItem: self,
                    attribute: .centerY,
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
    
    private func addToScreen() {
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
                attribute: .top,
                relatedBy: .equal,
                toItem: rootView,
                attribute: .bottom,
                multiplier: 1.0,
                constant: 0)
            
            showingConstraint = NSLayoutConstraint(
                item: self,
                attribute: .bottom,
                relatedBy: .equal,
                toItem: rootView,
                attribute: .bottom,
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
//                        self.performDelegateAction(action: #selector(self.snackbarShown(_:)))
                        self.perform(#selector(self.dismiss), with: nil, afterDelay: self.duration)
                        if let actionButton = self.actionButton {
                            actionButton.isEnabled = true
                        }
                    }
                })
        }
    }
    
    private func performDelegateAction(action: Selector) {
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
    @objc optional func snackbarShown(_ snackbar: MKSnackbar)
    @objc optional func snackbarDismissed(_ snackbar: MKSnackbar)
    @objc optional func actionClicked(_ snackbar: MKSnackbar)
}

// MARK:- MKSnackbar Manager

private class MKSnackbarManager: NSObject, MKSnackbarDelegate {
    
    static var instance: MKSnackbarManager!
    
    private var snackbarQueue: Array<MKSnackbar>?
    
    private override init() {
        snackbarQueue = Array<MKSnackbar>()
    }
    
    static func getInstance() -> MKSnackbarManager {
        if instance == nil {
            instance = MKSnackbarManager()
        }
        return instance
    }
    
    func showSnackbar(_ snackbar: MKSnackbar) {
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
    
    @objc(snackbarDismissed:)
    public func snackbarDismissed(_ snackbar: MKSnackbar) {
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
