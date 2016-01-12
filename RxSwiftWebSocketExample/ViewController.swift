//
//  ViewController.swift
//  RxSwiftWebSocketExample
//
//  Created by Zachary Gray on 11/16/15.
//  Copyright © 2015 Zachary Gray. All rights reserved.
//

import UIKit
import SwiftWebSocket
import RxCocoa
import RxSwift

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let ws = WebSocket()
        
        // subscribe to trace signal and print messages
        _ = ws.rx_trace
            .takeUntil(self.rx_deallocated)
            .subscribeNext { (element:TraceElement) in
                print("[TRACE]: \(element.eventName)\(element.message)(\(element.id.UUIDString))")
            }
        
        // subscribe to open
        let openSubscription = ws.rx_event.open
            .takeUntil(self.rx_deallocated)
            .subscribeNext { print("[socket example] > OPEN") }
        
        // subscribe to close
        let closeSubscription = ws.rx_event.close
            .takeUntil(self.rx_deallocated)
            .subscribeNext { (closeEvent:SocketCloseEvent) in
                print("[socket example] > CLOSE | code:\(closeEvent.code), reason:\(closeEvent.reason)")
            }
        
        // subscribe to error
        let errorSubscription = ws.rx_event.error
            .takeUntil(self.rx_deallocated)
            .subscribeNext { error in
                print("[socket example] > ERROR | error: \(error)")
            }
        
        let endSubscription = ws.rx_event.end
            .takeUntil(self.rx_deallocated)
            .subscribeNext { endEvent in
                print("[socket example] > END | reason: \(endEvent.reason), error: \(endEvent.error)")
            }
        
        let messageSubscription = ws.rx_event.message
            .takeUntil(self.rx_deallocated)
            .subscribeNext { message in
                print("[socket example] > MESSAGE: \(message)")
            }
        
        // define a message variable, with one element "hello" which will be dispatched to subscribers immediately upon
        // subscription
        let message = Variable<String>("hello")
        
        // open a bad url:
        ws.open("wz://echo.websocket.org")
        
        // open a working url:
        delay(3) {
            ws.close()
            ws.open("ws://echo.websocket.org")
            
            // bind the message variable to the send sink, resulting in an immediate send (and receive from echo server)
            // of "hello", followed by "world" after a second
            _ = ws.rx_send <- message
            delay(1) { message.value = "world" }
        }
        
        // then close it:
        delay(10) {
            ws.close()
        }
        
        delay(20) {
            openSubscription.dispose()
            closeSubscription.dispose()
            errorSubscription.dispose()
            endSubscription.dispose()
            messageSubscription.dispose()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

