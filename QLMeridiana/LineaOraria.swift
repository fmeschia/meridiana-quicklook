//
//  LineaOraria.swift
//  Meridiana
//
//  Created by Francesco Meschia on 9/29/15.
//  Copyright © 2015 Francesco Meschia. All rights reserved.
//

import Cocoa

enum LineaOrariaError: ErrorType {
    case NoPoints
}

typealias Polilinea = [CGPoint]

class LineaOraria: Segno {
    var inizio: CGPoint?
    var fine: CGPoint?
    var curva: Polilinea = Polilinea()
    var line: CTLineRef
    var ora: Int
    var alfa: Double
    var theModel: MeridianaModel
    var scala: Double
    var ridotto: Bool
    var tutto : Bool = false
    var lemniscata: Bool = true
    var premuto: Bool = false
    let roman = ["XXIV", "I", "II", "III", "IV", "V", "VI", "VII", "VIII",
    "IX", "X", "XI", "XII", "XIII", "XIV", "XV", "XVI",
    "XVII", "XVIII", "XIX", "XX", "XXI", "XXII", "XXIII", "XXIV"]
    
    init(theModel: MeridianaModel, ha: Double, ridotto: Bool) throws {
        self.theModel = theModel
        self.ridotto = ridotto
        self.alfa = ha
        self.scala = 1.0
        self.ora = Int(round(12 + alfa/Utils.deg2rad(15)))
        let attrString : CFAttributedStringRef =
        CFAttributedStringCreate(kCFAllocatorDefault, roman[ora], nil)
        line = CTLineCreateWithAttributedString(attrString)
        try calcola()
    }
    
    func calcola() throws {
        var calcolato: Bool = false
        tutto = true
        var tau: Double
        var p: CGPoint
        for var k = 0; k <= 144 ; k++ {
            do {
                tau = 1.0 + 2.58924/1200.0
                tau += Double(k) / 14400.0
                try p = theModel.calcola(alfa, tau: tau, medio: true, strict: true, ridotto: ridotto)
                if (!calcolato) {
                    curva.append(p)
                    calcolato = true
                } else {
                    curva.append(p)
                }
            } catch {
                tutto = false
                break
            }			
        }
        //if (calcolato) {
            calcolato = false
            for var m = -3; m <= 3 ; m++ {
            do {
                    tau = 1.0 + (2.58924/1200.0)
                    tau += (Double(m)/1200.0)
                    try p = theModel.calcola(alfa, tau:tau, medio:false, strict:true, ridotto:ridotto)
                    if (!calcolato) {
                        inizio = p //inizio.scale(scala);
                        fine = p
                        calcolato = true;
                    } else {
                        fine = p //inizio.scale(scala);
                    }
                } catch {
                    tutto = false
                }
            }
        if inizio == fine {
            calcolato = false
            tutto = false
        }
        //}
        if (!tutto) {
            lemniscata = false
        }
        if (!calcolato) {
            throw LineaOrariaError.NoPoints
        }
            //inizio!.y = -(inizio!.y)
        //fine!.y = -(fine!.y)
    }
    
    func draw(ctx: CGContext, scale: CGFloat) {
        var deltax : Double = Double(fine!.x) - Double(inizio!.x)
        if deltax == 0.0 {
            deltax = 0.001
        }
//        let m =
        let x = (fine!.x) + 15 * CGFloat(cos(atan2(Double(fine!.y) - Double(inizio!.y), deltax)))
        let y = (fine!.y) + 15 * CGFloat(sin(atan2(Double(fine!.y) - Double(inizio!.y), deltax)))
        let textBounds = CTLineGetImageBounds(line, ctx)
        CGContextSetRGBStrokeColor(ctx, 0, 0, 0, 1)
        CGContextSetTextPosition(ctx, x-textBounds.width/2, y-textBounds.height/2);
        CTLineDraw(line, ctx);
         if (premuto) {
            CGContextSetLineWidth(ctx,CGFloat(3.0))
        }
        if (tutto && lemniscata) {
            var primo : Bool = true
            for punto: CGPoint in curva {
                if primo {
                    CGContextMoveToPoint(ctx, punto.x, punto.y)
                    primo = false
                } else {
                    CGContextAddLineToPoint(ctx, punto.x, punto.y)
                }
            }
        } else {
            CGContextMoveToPoint(ctx, inizio!.x, inizio!.y)
            CGContextAddLineToPoint(ctx, fine!.x, fine!.y)
        }
        
    }
    
    
    func contiene(p: CGPoint, scale: CGFloat) -> Bool {
        var dentro: Bool
        let bounds: CGRect = getBounds()
        let pt : CGPoint = p
        if bounds.contains(pt) {
            if (lemniscata) {
                let path : CGMutablePath = CGPathCreateMutable()
                var primo : Bool = true
                for punto: CGPoint in curva {
                    if primo {
                        CGPathMoveToPoint(path, nil, punto.x, punto.y)
                        primo = false
                    } else {
                        CGPathAddLineToPoint(path, nil, punto.x, punto.y)
                    }
                }
                dentro = CGPathContainsPoint(path, nil, pt, true)
            }else {
                var m : Double = Double((inizio!.y - fine!.y) / (inizio!.x - fine!.x))
                if (isinf(m)) {
                    m = 1e6
                }
                let n: Double =  Double(fine!.y) - m * Double(fine!.x)
                let d : Double = abs((m * Double(pt.x) - Double(pt.y) + n) / sqrt(m*m+1.0));
                dentro = d < 3.0
            }
        } else {
            dentro = false
        }
            return dentro
        }
    

    
    func getBounds() -> CGRect {
        var boundsRect : CGRect!
        if (tutto && lemniscata) {
            var primo : Bool = true
            for punto: CGPoint in curva {
                if primo {
                    boundsRect = CGRect(origin: punto, size: CGSizeZero)
                    primo = false
                } else {
                    boundsRect = CGRectUnion(boundsRect, CGRect(origin: punto, size:CGSizeZero))
                }
            }
            return boundsRect
        } else {
            boundsRect = CGRect(x: min(inizio!.x, fine!.x), y: min(inizio!.y, fine!.y), width: abs(fine!.x-inizio!.x), height:abs(fine!.y - inizio!.y))
        }
        return boundsRect
    }
}
