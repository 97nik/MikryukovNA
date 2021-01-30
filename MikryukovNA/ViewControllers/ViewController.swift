//
//  ViewController.swift
//  MikryukovNA
//
//  Created by Никита on 29.01.2021.
//

import UIKit
//import Parse

class ViewController: UIViewController {

    @IBOutlet var companyNameLabel: UILabel!
    @IBOutlet var companySymbolLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var priceChangeLabel: UILabel!
    @IBOutlet weak var companyPickerView: UIPickerView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var logoImageView: UIImageView!
    
    private lazy var companies = [
        "Apple" : "AAPL",
        "Microsoft": "MSFT",
        "Google": "GOOG",
        "Facebook": "FB",
        ]
    
   
    //private let token = "pk_690a52ea2c454af2b1b32b4978a58738"
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        companyPickerView.dataSource = self
        companyPickerView.delegate = self
        
        activityIndicator.hidesWhenStopped = true
//        guard let uurl = URL(string: "https://storage.googleapis.com/iexcloud-hl37opg/api/logos/AAPL.png") else { return }
//        guard let imageData = try? Data(contentsOf: uurl ) else { return }
//       logoImageView.image = UIImage(data: imageData)
        
        requestQuteUpdate()
        //chengeColor()
        
//        activityIndicator.startAnimating()
//        requestQuote(for: "AAPL")
        
    }
    func requestQuote(for symbol:String) {
        
        guard let url = URL(string: "https://cloud.iexapis.com/stable/stock/\(symbol)/quote?&token=pk_690a52ea2c454af2b1b32b4978a58738") else { return }
        
        let dataTask = URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
           if let data = data,
              (response as? HTTPURLResponse)?.statusCode == 200,
              error == nil{
            self?.parseQuote(from: data)
           } else {
            print("Network error!")
           }
        }
        dataTask.resume()
    }
    
    private func parseQuote(from data: Data){
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data)
            
            guard
                let json = jsonObject as? [String: Any],
                let companyName = json["companyName"] as? String,
                let companySymbol = json["symbol"] as? String,
                let price = json["latestPrice"] as? Double,
                let priceChange = json["change"] as? Double else { return print("Invalid JSON")}
            print("Company name is" + companyName)
            
            DispatchQueue.main.async {[weak self] in
                self?.displayStockInfo(companyName: companyName,
                                       companySymbol: companySymbol,
                                       price: price,
                                       priceChange: priceChange)
                
            }
            
        } catch {
            print("JSON parsing error " + error.localizedDescription)
        }
    }
    
    private func displayStockInfo(companyName: String,
                                  companySymbol: String,
                                  price: Double,
                                  priceChange: Double){
        activityIndicator.stopAnimating()
        companyNameLabel.text = companyName
        companySymbolLabel.text = companySymbol
        priceLabel.text = "\(price)"
        priceChangeLabel.text = "\(priceChange)"
        
        if priceChange < 0 {
            priceChangeLabel.textColor = .red
        } else if priceChange > 0 {
            priceChangeLabel.textColor = .green
        } else {
            priceChangeLabel.textColor = .black
        }
    }
    
    func requestQuoteImage(for symbol:String) {
        
        guard let url = URL(string: "https://cloud.iexapis.com/stable/stock/\(symbol)/logo/quote?&token=pk_690a52ea2c454af2b1b32b4978a58738") else { return }
        
        let dataTask = URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
           if let data = data,
              (response as? HTTPURLResponse)?.statusCode == 200,
              error == nil{
            self?.parseQuoteImage(from: data)
           } else {
            print("Network error!")
           }
        }
        dataTask.resume()
    }
    
    private func parseQuoteImage(from data: Data){
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data)
            
            guard
                let json = jsonObject as? [String: Any],
                let imageUrl = json["url"] as? String else { return print("Invalid JSON")}
            print("Company name is" + imageUrl)
        
        DispatchQueue.main.async {[weak self] in
            self?.displayStockInfoImage(imageUrl: imageUrl)
            
        }
        
    } catch {
    print("JSON parsing error " + error.localizedDescription)
    }

}
    private func displayStockInfoImage(imageUrl: String){
    activityIndicator.stopAnimating()
        guard let imageUrl = URL(string: imageUrl) else { return }
        guard let imageData = try? Data(contentsOf: imageUrl ) else { return }
       logoImageView.image = UIImage(data: imageData)
}
}


extension ViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return companies.keys.count
    }
    
   
}

extension ViewController: UIPickerViewDelegate {
        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
            return Array(companies.keys)[row]
        }
    
    
    func requestQuteUpdate() {
        activityIndicator.startAnimating()
        companySymbolLabel.text = "-"
        companyNameLabel.text = "-"
        priceLabel.text = "-"
        priceChangeLabel.text = "-"
       // priceChangeLabel.textColor = .black
        
        
        let selectedRow = companyPickerView.selectedRow(inComponent: 0)
        let selectedSymbol = Array(companies.values)[selectedRow]
        requestQuote(for: selectedSymbol)
        requestQuoteImage(for: selectedSymbol)
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        requestQuteUpdate()
        
        
    }

    
}

