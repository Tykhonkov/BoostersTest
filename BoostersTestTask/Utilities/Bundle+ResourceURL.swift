//
//  Bundle+ResourceURL.swift
//  BoostersTestTask
//
//  Created by Elias on 06.04.2020.
//  Copyright © 2020 Elias. All rights reserved.
//

import Foundation

extension Bundle {

    func resourceURL(_ resourceName: String) -> URL {
        guard let path = Bundle.main.path(forResource: resourceName, ofType: nil) else {
            fatalError("Failed to get bundle resource named: \(resourceName) ")
        }
        return URL(fileURLWithPath: path)
    }
    
}
