//
//  ToastManager.swift
//  SmartLog
//
//  Created by David on 2021/05/21.
//  Copyright © 2021 isens. All rights reserved.
//

import Foundation
import UIKit

private var manager: ToastManager?

class ToastManager: NSObject {
    private var toastView: UIView?
    private var contentView: UIView?
    private var lbContent: UILabel?
    private var keyboardHeight: CGFloat = 0
    private var originRect: CGRect = .zero

    public static let shared: ToastManager = {
        if (manager == nil) {
            manager = ToastManager()
        }

        return manager!
    }()

    func destroy() {
        manager = nil
    }

    override private init() {
        super.init()

        self.registerObserver()
    }

    @objc func adjustForKeyboard(notification: Notification) {
        let userInfo = notification.userInfo!
        let keyboardViewEndFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        if let _keyboardHeight = keyboardViewEndFrame?.height {
            self.keyboardHeight = (notification.name == UIResponder.keyboardWillShowNotification) ? _keyboardHeight : 0
        }
    }

    func registerObserver() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
    }

    func removeObserver() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }

    public func setBaseViewController() {
        self.toastView = UIView(frame: UIScreen.main.bounds)
        self.toastView?.backgroundColor = .clear
        self.toastView?.alpha = 0

        let rect: CGRect = UIScreen.main.bounds
        let fGap: CGFloat = 10.0
        let fWidth: CGFloat = rect.size.width - fGap * 2
        let fHeight: CGFloat = rect.size.height * (60/640)
        let fY: CGFloat = rect.size.height - fHeight - fGap

        self.contentView = UIView(frame: CGRect(x: fGap, y: fY, width: fWidth, height: fHeight))
        self.contentView?.backgroundColor = .black
        self.contentView?.alpha = 0.9
        self.contentView?.layer.cornerRadius = 3.0
        self.contentView?.clipsToBounds = true

        self.lbContent = UILabel(frame: self.contentView!.bounds)
        self.lbContent?.backgroundColor = .clear
        self.lbContent?.textAlignment = .center
        self.lbContent?.numberOfLines = 0
        self.lbContent?.textColor = .white
        self.lbContent?.font = .systemFont(ofSize: 16)
        self.lbContent?.text = "Test Contents 입니다."

        self.contentView?.addSubview(lbContent!)
        self.toastView?.addSubview(contentView!)

        self.toastView?.alpha = 0
        let rootWindow = UIApplication.shared.windows.first
        rootWindow?.addSubview(self.toastView!)

        originRect = self.contentView!.frame
    }

    public func hide(completion: (() -> Void)? = nil) {
        guard let _toast = self.toastView, _toast.alpha == 0  else { return }
        self.contentView?.frame = originRect

        UIView.animate(withDuration: DF_ANIMATE_DURATION, delay: 0, options: .curveEaseInOut, animations: {
            _toast.alpha = 0
            completion?()
        })
    }

    public func showConnectingFailError( completion: (() -> Void)? = nil) {
        guard self.toastView?.alpha == 0 else { return }
        self.lbContent?.text = ""

        self.show(text: "Connecting fail.") {
            if let _completion = completion {
                _completion()
            }
        }
    }

    public func show(text: String? = nil, completion: (() -> Void)? = nil) {
        guard self.toastView != nil, text != nil, text != "", text!.count != 0, self.toastView?.alpha == 0 else { return }
        print("check the Toast Message : \(String(describing: text))")
        self.lbContent?.text = ""

        let rootWindow = UIApplication.shared.windows.first
        rootWindow?.bringSubviewToFront(self.toastView!)

        DispatchQueue.main.async() {
            self._show(text: text, self.keyboardHeight, completion: completion)
        }
    }

    private func _show(text: String? = nil, _ constant: CGFloat? = nil, completion: (()->Void)? = nil) {
        guard self.toastView != nil else { return }
        self.toastView?.alpha = 0

        if let _constant = constant, _constant != 0 {
            // 토스트 UI 스크린 위치 변경
            let rt: CGRect = self.contentView!.frame
            let yPos: CGFloat = UIScreen.main.bounds.height - CGFloat(constant! + rt.size.height + 10)
            self.contentView?.frame = CGRect(x: rt.origin.x, y: yPos, width: rt.size.width, height: rt.size.height)
        }

        if let _text = text {
            self.lbContent?.text = _text
        } else {
            self.lbContent?.text = ""
        }

        UIView.animate(withDuration: DF_ANIMATE_DURATION, delay: 0, options: .curveEaseInOut, animations: {
            self.toastView?.alpha = 1
        }, completion: { (_) in
            UIView.animate(withDuration: DF_ANIMATE_DURATION, delay: 1, options: .curveEaseInOut, animations: {
                self.toastView?.alpha = 0
            }, completion: { (_) in
                ToastManager.shared.hide(completion: completion)
            })
        })
    }
}
