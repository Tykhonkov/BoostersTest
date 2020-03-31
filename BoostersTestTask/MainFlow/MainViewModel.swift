//
//  MainViewModel.swift
//  BoostersTestTask
//
//  Created by Elias on 01.04.2020.
//  Copyright © 2020 Elias. All rights reserved.
//

import Combine

class MainViewModel: ObservableObject {
    
    @Published private(set) var statusString: String = "Idle"
    
}
