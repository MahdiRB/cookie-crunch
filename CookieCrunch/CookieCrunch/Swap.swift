//
//  Swap.swift
//  CookieCrunch
//
//  Created by Katherine Fang on 10/27/14.
//  Copyright (c) 2014 Firebase. All rights reserved.
//

struct Swap: Printable {
    let cookieA: Cookie
    let cookieB: Cookie

    init(cookieA: Cookie, cookieB: Cookie) {
        self.cookieA = cookieA
        self.cookieB = cookieB
    }
    
    var description: String {
        return "swap \(cookieA) with \(cookieB)"
    }
}
