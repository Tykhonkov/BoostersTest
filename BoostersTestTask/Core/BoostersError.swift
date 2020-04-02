//
//  BoostersError.swift
//  BoostersTestTask
//
//  Created by Elias on 02.04.2020.
//  Copyright © 2020 Elias. All rights reserved.
//

import Foundation

enum BoostersError: Error {
    
    case audioSessionError(string: String)
    case permissionDeniedError

}
