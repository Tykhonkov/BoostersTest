//
//  Formatters.swift
//  BoostersTestTask
//
//  Created by Elias on 01.04.2020.
//  Copyright © 2020 Elias. All rights reserved.
//

import Foundation

let timeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm a"
    
    return formatter
}()
