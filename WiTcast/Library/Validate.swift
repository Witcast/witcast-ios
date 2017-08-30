//
//  Validate.swift
//  WiTcast
//
//  Created by Tanakorn Phoochaliaw on 7/17/16.
//  Copyright © 2016 Tanakorn Phoochaliaw. All rights reserved.
//

import Foundation

class ValidateFunc {
    class func titleColor(categoryTitle: String) -> UInt {
        var colorTitle:(UInt) = 0xffffff;
        
        if categoryTitle == "WITCAST SPECIAL"{
            colorTitle = colorSpecial;
        }
        else if categoryTitle == "WITTHAI"{
            colorTitle = colorWitthai;
        }
        else if categoryTitle == "WITSHOT"{
            colorTitle = colorWitshot;
        }
        else if categoryTitle == "THRONECAST"{
            colorTitle = colorThronecast;
        }
        else if categoryTitle == "MOVIECAST"{
            colorTitle = colorMoviecast
        }
        else {
            colorTitle = colorEtc;
        }
        
        return colorTitle;
    }
}
