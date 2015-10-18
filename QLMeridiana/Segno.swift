//
//  Segno.swift
//  Meridiana
//
//  Created by Francesco Meschia on 9/29/15.
//  Copyright © 2015 Francesco Meschia. All rights reserved.
//

import Cocoa

protocol Segno {
    func draw(ctx: CGContext, scale: CGFloat)
    func getBounds() -> CGRect
}
