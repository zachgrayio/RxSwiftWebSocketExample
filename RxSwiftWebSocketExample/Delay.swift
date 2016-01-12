//
//  Delay.swift
//  RxSwiftWebSocketExample
//
//  Created by Zachary Gray on 11/17/15.
//  Copyright © 2015 Zachary Gray. All rights reserved.
//

import Foundation

func delay(delay:Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}