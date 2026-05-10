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
  @State private var outputMode: OutputMode = .tree

  private var outputText: String {
    switch outputMode {
    case .tree:
      return parser.results
    case .json:
      return parser.ast?.description ?? parser.results
    }
  }

  var body: some View {
    HStack(spacing: 0) {
      VStack {
        TextEditor(text: $textFieldContent)
          .textFieldStyle(RoundedBorderTextFieldStyle())
          .padding()
        HStack {
          Button("Parse") {
            _ = try? parser.parse(textFieldContent)
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
        TextEditor(text: .constant(outputText))
          .padding()
        HStack {
          Button(outputMode.buttonTitle) {
            outputMode.toggle()
          }
        }
        Spacer()
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(Color.gray.opacity(0.1))
    }
    .frame(minWidth: 600, minHeight: 400) // Adjust minimum size
  }
}

private enum OutputMode {
  case tree
  case json

  var buttonTitle: String {
    switch self {
    case .tree:
      return "JSON"
    case .json:
      return "Tree"
    }
  }

  mutating func toggle() {
    switch self {
    case .tree:
      self = .json
    case .json:
      self = .tree
    }
  }
}
