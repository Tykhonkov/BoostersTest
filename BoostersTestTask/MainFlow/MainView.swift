//
//  MainView.swift
//  BoostersTestTask
//
//  Created by Elias on 31.03.2020.
//  Copyright © 2020 Elias. All rights reserved.
//

import SwiftUI

struct MainView: View {
    
    @ObservedObject var viewModel: MainViewModel

    init(viewModel: MainViewModel) {
      self.viewModel = viewModel
    }
    
    var body: some View {
        Text("Hello, World!")
    }
    
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(viewModel: MainViewModel())
    }
}
