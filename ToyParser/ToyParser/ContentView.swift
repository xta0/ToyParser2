//
//  ContentView.swift
//  ToyParser
//
//  Created by Tao Xu on 1/2/25.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var parser = Parser()
    @State private var textFieldContent: String = ""
    var body: some View {
        HStack(spacing: 0) {
             VStack {
                 TextEditor(text: $textFieldContent)
                     .textFieldStyle(RoundedBorderTextFieldStyle())
                     .padding()
                 HStack {
                     Button("Parse") {
                       try? parser.parse(textFieldContent)
                     }
                     Button("Clear") {
                         textFieldContent = ""
                     }
                 }
                 Spacer()
             }
             .frame(maxWidth: .infinity, maxHeight: .infinity)
             .background(Color.gray.opacity(0.2))
             
             Divider() // Optional divider for visual separation

             // Right: TextView (TextEditor)
             VStack {
                TextEditor(text: .constant(parser.results))
                     .padding()
                 Spacer()
             }
             .frame(maxWidth: .infinity, maxHeight: .infinity)
             .background(Color.gray.opacity(0.1))
         }
         .frame(minWidth: 600, minHeight: 400) // Adjust minimum size
    }
}
