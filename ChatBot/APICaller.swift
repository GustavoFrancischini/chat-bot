//
//  APICaller.swift
//  ChatBot
//
//  Created by Gustavo Francischini on 22/02/24.
//

import OpenAISwift
import Foundation

/// Classe responsável por fazer chamadas à API do OpenAI.
final class APICaller {
    /// Singleton para acesso global à instância da classe APICaller.
    static let shared = APICaller()
    
    /// Estrutura contendo constantes utilizadas pela classe APICaller.
    @frozen enum Constants {
        /// Chave de API utilizada para autenticação.
        static let key = "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"
    }
    
    /// Cliente para fazer chamadas à API do OpenAI.
    private var client: OpenAISwift?
    
    /// Inicializador privado para garantir que a classe seja um singleton.
    private init() {}
    
    /// Configura o cliente OpenAISwift com as configurações padrão.
    public func setup() {
        let config = OpenAISwift.Config.makeDefaultOpenAI(apiKey: Constants.key)
        self.client = OpenAISwift(config: config)
    }
        
    /// Obtém uma resposta da API do OpenAI para a entrada fornecida.
    ///
    /// - Parameters:
    ///   - input: A entrada para a qual se deseja obter uma resposta.
    ///   - completion: O bloco de conclusão que será chamado quando a resposta for recebida.
    public func getResponse(input: String,
                            completion: @escaping (Result<String, Error>) -> Void) {
        // Envia a solicitação para a API do OpenAI usando o cliente configurado.
        client?.sendCompletion(with: input, model: .codex(.davinci) ,completionHandler: { result in
            switch result {
            case .success(let model):
                // Se a solicitação for bem-sucedida, obtém o texto da primeira escolha do modelo.
                print(String(describing: model.choices))
                let output = model.choices?.first?.text ?? ""
                completion(.success(output))
            case .failure(let error):
                // Se a solicitação falhar, chama a conclusão com o erro recebido.
                completion(.failure(error))
            }
        })
    }
}

