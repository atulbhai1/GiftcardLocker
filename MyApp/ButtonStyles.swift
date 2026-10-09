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

struct dismissButtonStyle: ButtonStyle{
    let width = UIScreen.main.bounds.size.width * 0.4
    let height = UIScreen.main.bounds.size.height * 0.1
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title)
            .bold()
            .frame(width: width, height: height)
            .background(.blue, in: RoundedRectangle(cornerRadius: 20))
            .foregroundStyle(.white)
    }
}

struct brandScrollButtonStyle: ButtonStyle{
    let width = UIScreen.main.bounds.size.width * 0.8
    let height = UIScreen.main.bounds.size.height * 0.1
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title)
            .bold()
            .frame(width: width, height: height)
            .background(Color(red: 0.4627, green: 0.8392, blue: 1.0), in: RoundedRectangle(cornerRadius: 20))
            .foregroundStyle(.white)
    }
}

struct modifyOrDeleteButtonStyle: ButtonStyle{
    let width = UIScreen.main.bounds.size.width * 0.8
    let height = UIScreen.main.bounds.size.height * 0.1
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title)
            .foregroundStyle(.blue)
            .padding(10)
    }
}
