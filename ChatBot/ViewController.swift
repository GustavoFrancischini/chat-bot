//
//  ViewController.swift
//  ChatBot
//
//  Created by Gustavo Francischini on 22/02/24.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    // MARK: - Propriedades
    
    // Campo de texto para o usuário.
    private let field: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Digite aqui..."
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
    private var messages: [(text: String, isUser: Bool)] = []
    
    // Cor de fundo das respostas do bot (optei por um branco mais claro para diferenciação).
    private let botResponseBackgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.97, alpha: 1.0)

    
    // MARK: - Métodos
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Adiciona a tabela e o campo de texto à hierarquia de visualização.
        view.addSubview(tableView)
        view.addSubview(field)
        view.backgroundColor = .orange
        tableView.backgroundColor = .orange
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 50 // Altura estimada da célula
        
        // Configuração dos delegates e datasources da tabela e do campo de texto.
        tableView.delegate = self
        tableView.dataSource = self
        field.delegate = self
        
        // Configuração constraints.
        NSLayoutConstraint.activate([
            field.heightAnchor.constraint(equalToConstant: 50),
            field.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20),
            field.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20),
            field.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            
            tableView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15),
            tableView.bottomAnchor.constraint(equalTo: field.topAnchor, constant: -15)
        ])
}
    
    // MARK: - TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let message = messages[indexPath.row]
        cell.textLabel?.text = message.text
        cell.textLabel?.numberOfLines = 0 // Quebra de texto
        
        // Configura a cor de fundo da célula com base no tipo de mensagem
        if !message.isUser {
            cell.backgroundColor = botResponseBackgroundColor
        } else {
            cell.backgroundColor = .white
        }
        
        // Optei por remover a linha/margem da célula
        tableView.separatorStyle = .none
        
        return cell
    }

    
    
    // MARK: - TextField
    
    // Mensagens para respostas
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty {
            // Pré-processamento da mensagem
            let processedText = text.preprocessarMensagem()
            
            // Adiciona a mensagem do usuário ao array de mensagens.
            messages.append((text, true)) // Marca como mensagem do usuário
            
            // Verifica se há uma resposta para a mensagem do usuário.
            if let response = messageResponses[processedText.lowercased()] {
                // Animação suave.
                UIView.transition(with: tableView, duration: 0.3, options: .transitionCrossDissolve, animations: {
                    self.messages.append((response, false)) // Marca como resposta do bot
                    self.tableView.reloadData()
                }, completion: { _ in
                    textField.text = nil
                    
                    // Rolagem da tabela.
                    let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                    self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                })
            } else {
                // Mensagem padrão do bot caso não tenha prompt equivalente.
                messages.append(("🤖 - Ainda não tenho resposta para isso =(", false))
                
                // Atualiza a tabela com a animação e limpa o campo de texto.
                UIView.transition(with: tableView, duration: 0.3, options: .transitionCrossDissolve, animations: {
                    self.tableView.reloadData()
                }, completion: { _ in
                    textField.text = nil
                    
                    // Rolando a tabela
                    let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                    self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                })
            }
        }
        
        return true
    }
}

// Manipulação dos prompts usuário.
extension String {
    // Remover acentos
    func removaAcentos() -> String {
        return folding(options: .diacriticInsensitive, locale: .current)
    }
    
    // Pré-processamento da mensagem
    func preprocessarMensagem() -> String {
        var mensagem = self.lowercased() // Converter para minúsculas
        mensagem = mensagem.removaAcentos() // Remover acentos
        mensagem = mensagem.replacingOccurrences(of: "\u{8}", with: "") // Remover backspaces (\u{8}
        return mensagem
    }
}
