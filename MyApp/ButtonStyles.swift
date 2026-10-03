//
//  ButtonStyles.swift
//  MyApp
//
//  Created by Atul Nitin on 10/3/26.
//

import SwiftUI

struct homeScreenButtonStyle: ButtonStyle{
    let width = UIScreen.main.bounds.size.width * 0.8
    let height = UIScreen.main.bounds.size.height * 0.2
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title)
            .bold()
            .frame(width: width, height: height)
            .background(.green, in: RoundedRectangle(cornerRadius: 20))
    }
}
