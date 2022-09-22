//
//  iConstant.swift
//  bt
//
//  Created by David on 2021/05/24.
//  Copyright © 2021 i-SENS, Inc. All rights reserved.
//

import Foundation

public let VERSION_INFO: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
public let BUNDLE_INFO: String = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
