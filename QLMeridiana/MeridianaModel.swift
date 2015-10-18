//
//  MeridianaModel.swift
//  Meridiana
//
//  Created by Francesco Meschia on 9/28/15.
//  Copyright © 2015 Francesco Meschia. All rights reserved.
//

import Cocoa

public enum MeridianaCalculationError: ErrorType {
    case TooLow
}

public enum LineaOrariaState: Int {
    case LineaOrariaCompleta = 1
    case Lemniscata = 2
    case LineaParziale = 3
}

public class MeridianaModel: NSObject {
    var lambda : Double = Double.NaN
    var fi     : Double = Double.NaN
    var iota   : Double = Double.NaN
    var delta  : Double = Double.NaN
    var lambdar: Double = Double.NaN
    var altezza: Double = Double.NaN
    var lineaOrariaLemniscata : [Bool] = [Bool](count:25, repeatedValue:true)
    private let e   : Double = 0.01670924
    private let eta : Double = 0.409092637
    private var sfi : Double = Double.NaN
    private var cfi : Double = Double.NaN
    private var d0 : Double = Double.NaN
    private var d1 : Double = Double.NaN
    private var af : Double = Double.NaN
    private var sf : Double = Double.NaN
    private var cf : Double = Double.NaN
    private var tf : Double = Double.NaN
    private var saf : Double = Double.NaN
    private var caf : Double = Double.NaN
    let printScala = 72.0/25.4
    let videoScala: Double = 50.0
    
    override init() {
        lambda = Utils.deg2rad(8.2)
        fi = Utils.deg2rad(0)
        iota = Utils.deg2rad(0)
        delta = Utils.deg2rad(0)
        lambdar = Utils.deg2rad(15)
        altezza = 100
        super.init()
        calcPrelim()
    }
    
    func toDictionary() -> NSDictionary {
        return NSDictionary(dictionary: [
            "lambda": lambda,
            "fi": fi,
            "iota": iota,
            "delta": delta,
            "lambdar": lambdar,
            "altezza": altezza,
            "lemniscate": lineaOrariaLemniscata,
        ])
    }
    
    func fromDictionary(dict: NSDictionary)  {
        lambda = (dict["lambda"]! as! Double)
        fi = (dict["fi"]! as! Double)
        iota = (dict["iota"]! as! Double)
        delta = (dict["delta"]! as! Double)
        lambdar = (dict["lambdar"]! as! Double)
        altezza = (dict["altezza"]! as! Double)
        lineaOrariaLemniscata = (dict["lemniscate"]! as! [Bool])
        calcPrelim()
    }

    
    func calcPrelim() {
        sfi = sin(fi)
        cfi = cos(fi)
        d0 = atan2((-sin(iota)*sin(delta)),(cos(iota)*cos(fi)+sin(iota)*sin(fi)*cos(delta)))
        af = atan2((cos(fi)*sin(delta)),(sin(fi)*sin(iota)+cos(fi)*cos(iota)*cos(delta)))
        sf = sin(fi)*cos(iota)-cos(fi)*sin(iota)*cos(delta)
        cf = sqrt(1.0-(sf*sf))
        tf = sf/cf
        saf = sin(af)
        caf = cos(af);
        d1 = lambda - lambdar;
    }
    
    func calcola(alfa: Double, tau: Double,  medio: Bool, strict: Bool,  ridotto:Bool) throws -> CGPoint {
        var out = CGPoint()
    
        let L : Double = 4.881627973 + 628.3319509 * tau
        let M : Double = 6.256583522 + 628.3019457 * tau
        let C : Double = (0.033500897 - 0.000083584 * tau) * sin(M)
    
        let sd : Double = 0.397777002 * sin(L + C)
        let cd : Double = sqrt (1 - sd*sd)
        var E : Double = 0
        
        if (medio) {
            var y: Double = tan(eta/2.0)
            y = y*y
            E = y * sin(2*L) - 2 * e * sin(M)
            E += 4 * e * y * sin(M) * cos(2*L)
        }
    
        var h0 : Double = alfa - d1 - E
        let a1  : Double = sfi*sd + cfi*cd*cos(h0)
        h0 -= d0
        let a2 : Double = sf*sd+cf*cd*cos(h0)
        if (a1 <= 0.0 || (a2 < 0.17 && strict)) {
            throw MeridianaCalculationError.TooLow
        }
        let x : Double = (ridotto ? videoScala : altezza * printScala) * (cd * sin(h0))/a2
        let y : Double = (ridotto ? videoScala : altezza * printScala) * (-cf*sd + sf*cd*cos(h0))/a2
        out.x = CGFloat(x*caf+y*saf)
        out.y = CGFloat(y*caf-x*saf)
        return out
    }
    
    func lunghezza() -> Double {
        return abs(cf/sf) * altezza;
    }
    
    func centro(ridotto: Bool) -> CGPoint  {
        var out = CGPoint()
        var y1 : Double
        let sf1 : Double = (sf == 0.0 ? 0.00001 : sf)
    
        if (abs(cf/sf1) < 3.0) {
            y1 = -(ridotto ? videoScala : altezza * printScala) * cf / sf1
        } else {
            y1 = -50 * (cf/sf1) / abs(cf/sf1)
        }
        out.x = CGFloat(y1 * saf)
        out.y = CGFloat(y1 * caf)
        return out
    }

}
