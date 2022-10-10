//
//  LoadingManager.swift
//  SmartLog
//
//  Created by David on 2021/05/21.
//  Copyright © 2021 isens. All rights reserved.
//

import Foundation
import UIKit

private var manager: LoadingManager?

class LoadingManager: UIView {
    public static let shared: LoadingManager = {
        if (manager == nil) {
            manager = LoadingManager()
        }

        return manager!
    }()

    private init() {
        super.init(frame: .zero)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func destroy() {
        manager = nil
    }

    private var backgroundView: UIView?
    private var indicator: UIActivityIndicatorView?
    private var lbProcess: UILabel?

    private var processTask: DispatchWorkItem? = nil
    private var taskTimeInterval: TimeInterval = 60     // Network : 10, Indicator : 60


    func setBaseViewController () {
        self.frame = UIScreen.main.bounds
        self.backgroundColor = UIColor.clear

        let rootWindow = UIApplication.shared.windows.first
        rootWindow?.addSubview(self)

        self.backgroundView = UIView(frame: UIScreen.main.bounds)
        self.backgroundView?.backgroundColor = UIColor.black
        self.backgroundView?.alpha = 0.3
        
        if #available(iOS 13.0, *) {
            self.indicator = UIActivityIndicatorView(style: .large)
        }
        else {
            self.indicator = UIActivityIndicatorView(style: .whiteLarge)
        }
        
        self.indicator?.frame = CGRect(x: 0, y: 0, width: (self.indicator?.frame.size.width)!, height: (self.indicator?.frame.size.height)!)
        self.indicator?.center = self.backgroundView!.center
        //self.indicator?.color = UIColor.colorFromHex(0x1D87D8) // Color TEST

        let rt: CGRect = UIScreen.main.bounds
        let gap: CGFloat = 30.0
        let yPos: CGFloat = (indicator?.frame.origin.y)! + (self.indicator?.frame.size.height)! + 10.0
        let w: CGFloat = rt.size.width - gap*2
        self.lbProcess = UILabel(frame:CGRect(x: gap, y: yPos, width: w, height: gap * 2))
        self.lbProcess?.textAlignment = .center
        self.lbProcess?.textColor = UIColor.white
        self.lbProcess?.numberOfLines = 3
        self.lbProcess?.font = UIFont.boldSystemFont(ofSize: 20)

        self.addSubview(self.backgroundView!)
        self.addSubview(self.indicator!)
        self.addSubview(self.lbProcess!)

        self.indicator?.stopAnimating()
        self.isHidden = true
    }

    func showIndicator (_ str: String) {
        if (str != "") {
            lbProcess?.isHidden = false
            lbProcess?.text = str
        }
        else {
            lbProcess?.isHidden = true
        }

        DispatchQueue.main.async {
            self.attachIndicator()
        }
    }

    private func startProcessMonitor() {
        self.stopProcessMonitor()

        self.processTask = DispatchWorkItem { self.runProcessTask() }
        DispatchQueue.main.asyncAfter(deadline: .now() + taskTimeInterval, execute: self.processTask!)
    }

    private func runProcessTask() {
        self.stopProcessMonitor()
        print("LoadingManager has been finished by ProcessTask")
        self.hideIndicator()
    }

    private func stopProcessMonitor() {
        if (processTask != nil) {
            if (processTask?.isCancelled == false) {
                processTask?.cancel()
            }

            processTask = nil
        }
    }

    func showIndicator() {
        DispatchQueue.main.async {
            if (self.indicator?.isAnimating == true) {
                return
            }

            if (self.lbProcess != nil) {
                self.lbProcess?.isHidden = true
            }

            // After saved indicator TimeInterval, just remove the Indicator by David
            self.startProcessMonitor()
            self.attachIndicator()
        }
    }

    func attachIndicator() {
        self.indicator?.startAnimating()
        self.isHidden = false
        let rootWindow = UIApplication.shared.windows.first
        rootWindow?.bringSubviewToFront(self)
    }

    func hideIndicator() {
        // After saved indicator TimeInterval, just remove the Indicator by David
        self.stopProcessMonitor()

        DispatchQueue.main.async {
            if (self.indicator != nil && self.indicator?.isAnimating == true) {
                if (self.lbProcess != nil) {
                    self.lbProcess?.isHidden = true
                }

                self.indicator?.stopAnimating()
            }

            self.isHidden = true
        }
    }
}
