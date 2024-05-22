//
//  ContentView.swift
//  openAIProject
//
//  Created by Artem Talko on 23.05.2024.
//

import OpenAISwift
import SwiftUI

final class ViewModel: ObservableObject {
    init() {}
    
    private var client: OpenAISwift?
    
    func setup() {
        client = OpenAISwift(config: OpenAISwift.Config.makeDefaultOpenAI(apiKey: "**UR KEY**"))
    }
    
    func send(text: String, completion: @escaping (String) -> (Void)) {
        client?.sendCompletion(with: text, maxTokens: 500, completionHandler: { result in
            switch result {
            case .success(let model):
                let output = model.choices?.first?.text ?? "I dont wanna answer.."
                completion(output)
            case .failure(_):
                break
            }
        })
    }
}

struct ContentView: View {
    @ObservedObject var viewModel = ViewModel()
    @State var text = ""
    @State var models = [String]()
    
    var body: some View {
        VStack(alignment: .leading, content: {
            ForEach(models, id: \.self) { string in
                Text(string)
            }
            Spacer()
            
            HStack {
                TextField("Type there...", text: $text)
                Button("send") {
                    send()
                }
            }
            
        })
        .onAppear {
            viewModel.setup()
        }
        .padding()
    }
    
    func send () {
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        models.append ("Me: \(text)")
        viewModel.send(text: text) { response in
            DispatchQueue.main.async {
                self.models.append ("ChatGPT: "+response)
                self.text = ""
            }
        }
    }
}

#Preview {
    ContentView()
}
