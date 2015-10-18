//
//  LineaStagionale.swift
//  Meridiana
//
//  Created by Francesco Meschia on 9/29/15.
//  Copyright © 2015 Francesco Meschia. All rights reserved.
//

import Cocoa

enum LineaStagionaleError: ErrorType {
    case NoPoints
}

class LineaStagionale: Segno {
    var theModel: MeridianaModel
    var delta: Double
    var scala: Double
    var ridotto: Bool
    var segmenti = [Polilinea]()

    
    init(theModel: MeridianaModel, mesi: Double, ridotto: Bool) throws {
        self.theModel = theModel
        self.ridotto = ridotto
        self.delta = 1.0 + (2.58924/1200.0)
        self.delta += (Double(mesi)/1200.0)
        self.scala = 1.0
        try calcola()
    }
    
    func calcola() throws  {
        var calcolato: Bool = false
        var p : CGPoint
        var segm = Polilinea()
        for var i = 0; i <= 96; i++ {
            do {
                try p = theModel.calcola(Utils.deg2rad(Double(i-24)*3.75), tau:delta, medio: false, strict: true, ridotto: ridotto)
                if i%4 == 0 || !segm.isEmpty {
                    segm.append(p)
                    calcolato = true
                }
            } catch {
                if !segm.isEmpty {
                    while segm.count % 4 != 1 {
                        segm.removeLast()
                    }
                    segmenti.append(segm)
                    segm = Polilinea()
                }
            }
        }
        if !calcolato {
            throw LineaStagionaleError.NoPoints
        }
        if !segm.isEmpty {
            while segm.count % 4 != 1 {
                segm.removeLast()
            }
            segmenti.append(segm)
        }
    }
    
    func draw(ctx: CGContext, scale: CGFloat) {
        for segmento in segmenti {
            var primo = true
            for punto in segmento {
                if (primo) {
                    CGContextMoveToPoint(ctx, punto.x, punto.y)
                    primo = false
                } else {
                    CGContextAddLineToPoint(ctx, punto.x, punto.y)
                }
            }
        }
    }
    
    func getBounds() -> CGRect {
        var primo = true
        var bounds : CGRect = CGRectZero
        for segmento in segmenti {
            for punto in segmento {
                if (primo) {
                    bounds = CGRect(origin: punto, size: CGSize(width: 0.0, height: 0.0))
                    primo = false
                } else {
                    bounds = CGRectUnion(bounds, CGRect(origin:punto, size:CGSize(width:0.0, height: 0.0)));
                }
            }
        }
        return bounds
    }

}
