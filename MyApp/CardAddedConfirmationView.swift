//
//  CardAddedConfirmationView.swift
//  MyApp
//
//  Created by Atul Nitin on 10/5/26.
//
import SwiftUI
struct CardAddedConfirmationView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Text("Your Card Was Added Successfully")
            .multilineTextAlignment(.center)
            .font(.largeTitle)
        Button("Dismiss"){
            dismiss()
        }
        .buttonStyle(dismissButtonStyle())
    }
}
#Preview(){
    CardAddedConfirmationView()
}
