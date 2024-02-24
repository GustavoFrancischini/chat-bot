//
//  ViewController.swift
//  ChatBot
//
//  Created by Gustavo Francischini on 22/02/24.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    // MARK: - Propiedades
    
    // Campo de texto para o user.
    private let field: UITextField = {
        let textField = UITextField()
        textField.placeholder = " Digite aqui..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 20
        textField.clipsToBounds = true
        textField.returnKeyType = .done
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        
        return textField
    }()
    
    /// Exibição das mensagens.
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    /// Mensagens do chat.
    private var messages: [String] = []
    
    // MARK: - Métodos
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Adiciona a tabela e o campo de texto à hierarquia de visualização.
        view.addSubview(tableView)
        view.addSubview(field)
        view.backgroundColor = .orange // estou mexendo aqui
        tableView.backgroundColor = .orange // estou mexendo aqui
        
        // Configuração dos delegates e datasources da tabela e do campo de texto.
        tableView.delegate = self
        tableView.dataSource = self
        field.delegate = self
        
        // Configuração constraints.
        NSLayoutConstraint.activate([
            field.heightAnchor.constraint(equalToConstant: 50),
            field.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20),
            field.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20),
            field.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor),
            
            tableView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: field.topAnchor)
        ])
    }
    
    // MARK: - TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = messages[indexPath.row]
        return cell
    }
    
    // MARK: - TextField
    
    // Mensagens para respostas
    let messageResponses: [String: String] = [
        "ola": "- Oi! Como posso ajudá-lo?",
        "oi": "- Olá! Como posso ajudá-lo?",
        "tudo bem?": "- Estou bem, obrigado!",
        "gustavo francischini": "- Esse é o meu criador!",
        "qual seu nome?": "- Sou o ChatzinhoBot!"
        
    ]
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text, !text.isEmpty {
            // Pré-processamento da mensagem
            let processedText = text.preprocessarMensagem()
            
            // Adiciona a mensagem do usuário ao array de mensagens.
            messages.append(text)
            
            // Verifica se há uma resposta para a mensagem do user.
            if let response = messageResponses[processedText.lowercased()] {
                messages.append(response)
            } else {
                // Se não houve resposta..
                messages.append("- Ainda não tenho resposta para isso =(")
            }
            
            // Atualiza a tabela e limpa o campo de texto.
            tableView.reloadData()
            textField.text = nil
        }
        
        return true
    }
}

extension String {
    func removaAcentos() -> String {
        return folding(options: .diacriticInsensitive, locale: .current)
    }
    
    func preprocessarMensagem() -> String {
        var mensagem = self.lowercased() // Converter para minúsculas
        mensagem = mensagem.removaAcentos() // Remover acentos
        mensagem = mensagem.replacingOccurrences(of: "\u{8}", with: "") // Remover backspaces (\u{8}
        return mensagem
    }
}
