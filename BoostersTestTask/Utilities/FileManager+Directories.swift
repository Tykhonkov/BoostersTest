//
//  FileManager+Directories.swift
//  BoostersTestTask
//
//  Created by Elias on 02.04.2020.
//  Copyright © 2020 Elias. All rights reserved.
//

import Foundation

extension FileManager {

    static func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
}
