//
//  TransferFundsViewController.swift
//  BalanceOpen
//
//  Created by Red Davis on 03/08/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Cocoa


internal final class TransferFundsViewController: NSViewController
{
    // Private
    private let viewModel = TransferFundsViewModel()
    private var transferController: TransferController?
    
    private let container = NSView()
    
    private let sourceAccountPopupButton = NSPopUpButton()
    private let sourceAccountBalanceLabel = LabelField(frame: NSRect.zero)
    
    private let recipientAccountPopupButton = NSPopUpButton()
    private let recipientAccountBalanceLabel = LabelField(frame: NSRect.zero)
    
    private let exchangeAmountTextField = TextField(frame: NSRect.zero)
    private let exchangeAmountCurrencyPopupButton = NSPopUpButton()
    
    private let recipientAmountLabel = LabelField(frame: NSRect.zero)
    
    private let minerFeeLabel = LabelField(frame: NSRect.zero)
    
    private let minerFeeHelpButton: Button = {
        let button = Button(frame: NSRect.zero)
        button.bezelStyle = .helpButton
        button.title = ""
        
        return button
    }()
    
    private let cancelButton: Button = {
        let button = Button(frame: NSRect.zero)
        button.title = "Cancel"
        button.bezelStyle = .rounded
        
        return button
    }()
    
    private let exchangeButton: Button = {
        let button = Button(frame: NSRect.zero)
        button.title = "Exchange"
        button.bezelStyle = .rounded
        
        return button
    }()
    
    // MARK: Initialization
    
    internal required init()
    {
        super.init(nibName: nil, bundle: nil)
        self.title = "Transfer Funds"
    }
    
    internal required init?(coder: NSCoder)
    {
        abort()
    }
    
    // MARK: View lifecycle
    
    override func loadView()
    {
        self.view = NSView(frame: NSRect(origin: CGPoint.zero, size: CGSize(width: 500.0, height: 500.0)))
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Container
        self.view.addSubview(self.container)
        
        self.container.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        // Source account combo box
        self.sourceAccountPopupButton.target = self
        self.sourceAccountPopupButton.action = #selector(self.accountSelectionChanged(_:))
        self.sourceAccountPopupButton.addItems(withTitles: self.viewModel.accountNames)
        self.container.addSubview(self.sourceAccountPopupButton)
        
        self.sourceAccountPopupButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview().inset(10.0)
            make.top.equalToSuperview().inset(10.0)
            make.width.equalTo(140.0)
        }
        
        // Source account balance label
        self.container.addSubview(self.sourceAccountBalanceLabel)
        
        self.sourceAccountBalanceLabel.snp.makeConstraints { (make) in
            make.right.equalTo(self.sourceAccountPopupButton)
            make.top.equalTo(self.sourceAccountPopupButton.snp.bottom).offset(5.0)
        }
        
        // Recipient account combo box
        self.recipientAccountPopupButton.target = self
        self.recipientAccountPopupButton.action = #selector(self.accountSelectionChanged(_:))
        self.recipientAccountPopupButton.addItems(withTitles: self.viewModel.accountNames)
        self.container.addSubview(self.recipientAccountPopupButton)
        
        self.recipientAccountPopupButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().inset(10.0)
            make.top.equalToSuperview().inset(10.0)
            make.width.equalTo(140.0)
        }
        
        // Recipient account balance label
        self.container.addSubview(self.recipientAccountBalanceLabel)
        
        self.recipientAccountBalanceLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.recipientAccountPopupButton)
            make.top.equalTo(self.recipientAccountPopupButton.snp.bottom).offset(5.0)
        }
        
        // Exchange amount currency popup button
        // TODO:
        // Unhide once we support main currency to X
        self.exchangeAmountCurrencyPopupButton.isHidden = true
        self.container.addSubview(self.exchangeAmountCurrencyPopupButton)
        
        self.exchangeAmountCurrencyPopupButton.snp.makeConstraints { (make) in
            make.right.equalTo(self.sourceAccountPopupButton)
            make.width.equalTo(60.0)
            make.top.equalTo(self.sourceAccountBalanceLabel.snp.bottom).offset(10.0)
        }
        
        // Exchange amount text field
        self.exchangeAmountTextField.delegate = self
        self.exchangeAmountTextField.stringValue = "1.00"
        self.exchangeAmountTextField.formatter = CurrencyTextFieldFormatter()
        self.exchangeAmountTextField.alignment = .right
        self.container.addSubview(self.exchangeAmountTextField)
        
        self.exchangeAmountTextField.snp.makeConstraints { (make) in
            make.width.equalTo(104.0)
            make.height.equalTo(self.exchangeAmountCurrencyPopupButton)
            make.right.equalTo(self.sourceAccountPopupButton)
            make.top.equalTo(self.exchangeAmountCurrencyPopupButton)
        }
        
        // Recipient amount label
        self.container.addSubview(self.recipientAmountLabel)
        
        self.recipientAmountLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.recipientAccountPopupButton.snp.left)
            make.centerY.equalTo(self.exchangeAmountCurrencyPopupButton)
        }
        
        // Cancel button
        self.cancelButton.set(target: self, action: #selector(self.cancelButtonClicked(_:)))
        self.container.addSubview(self.cancelButton)
        
        self.cancelButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview().inset(10.0)
            make.bottom.equalToSuperview().inset(10.0)
        }
        
        // Exchange button
        self.exchangeButton.set(target: self, action: #selector(self.cancelButtonClicked(_:)))
        self.container.addSubview(self.exchangeButton)
        
        self.exchangeButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().inset(10.0)
            make.bottom.equalToSuperview().inset(10.0)
        }
        
        // Miner fee label
        self.container.addSubview(self.minerFeeLabel)
        
        self.minerFeeLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.container.snp.right).multipliedBy(0.25)
            make.bottom.equalTo(self.cancelButton.snp.top).offset(-8.0)
        }
        
        // Miner fee help button
        self.minerFeeHelpButton.set(target: self, action: #selector(self.minerFeeHelpButtonClicked(_:)))
        self.container.addSubview(self.minerFeeHelpButton)
        
        self.minerFeeHelpButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.minerFeeLabel)
            make.left.equalTo(self.minerFeeLabel.snp.right).offset(5.0)
        }
    }
    
    override func viewDidAppear()
    {
        super.viewDidAppear()
        
        self.updateUI()
    }
    
    // MARK: State
    
    private func updateUI()
    {
        guard let selectedSourceAccountTitle = self.sourceAccountPopupButton.titleOfSelectedItem,
              let sourceAccount = self.viewModel.account(for: selectedSourceAccountTitle),
              let selectedRecipientAccountTitle = self.recipientAccountPopupButton.titleOfSelectedItem,
              let recipientAccount = self.viewModel.account(for: selectedRecipientAccountTitle) else
        {
            return
        }
        
        self.viewModel.sourceAccount = sourceAccount
        self.viewModel.recipientAccount = recipientAccount
        
        self.sourceAccountBalanceLabel.stringValue = "\(sourceAccount.currentBalance)"
        self.recipientAccountBalanceLabel.stringValue = "\(recipientAccount.currentBalance)"
        
        // Exchange currencies
        let currencyTitles = self.viewModel.sourceCurrencies.map { (currency) -> String in
            return currency.rawValue.uppercased()
        }
        
        self.exchangeAmountCurrencyPopupButton.removeAllItems()
        self.exchangeAmountCurrencyPopupButton.addItems(withTitles: currencyTitles)
        
        self.updateTransferDetails()
    }
    
    fileprivate func updateTransferDetails()
    {
        // Note:
        // Calling self.exchangeAmountTextField.doubleValue/stringValue etc
        // causes the text field to use the formatter to format the text and then
        // replace(!) the text fields content with the value.
        // This makes it impossible to type "1.23", because as soon as the "." is typed
        // the value is reformatted to "1"
        guard let sourceAccount = self.viewModel.sourceAccount,
              let recipientAccount = self.viewModel.recipientAccount,
              let recipientAccountCurrency = Currency(rawValue: recipientAccount.currency),
              let amountString = self.exchangeAmountTextField.currentEditor()?.string,
              let amount = Double(amountString) else
        {
            return
        }
        
        do
        {
            let transferRequest = try TransferRequest(sourceAccount: sourceAccount, recipientAddress: "test", recipientCurrency: recipientAccountCurrency, amount: amount)
            self.transferController = try TransferController(request: transferRequest)
            self.transferController?.fetchQuote({ (quote, error) in
                DispatchQueue.main.async {
                    guard let unwrappedQuote = quote else
                    {
                        return
                    }
                    
                    self.recipientAmountLabel.stringValue = "\(unwrappedQuote.recipientAmount) \(recipientAccountCurrency.rawValue)"
                    self.minerFeeLabel.stringValue = "Miner fee: \(unwrappedQuote.minerFee) \(unwrappedQuote.minerFeeCurrency.rawValue.uppercased())"
                }
            })
        }
        catch let error
        {
            // TODO: Handle error
            print(error)
        }
    }
    
    // MARK: Actions

    @objc private func accountSelectionChanged(_ sender: Any)
    {
        // TODO:
        // - Fetch quote for inputted value
        // - Update UI
        self.updateUI()
    }
    
    @objc private func minerFeeHelpButtonClicked(_ sender: Any)
    {
        
    }
    
    @objc private func exchangeButtonClicked(_ sender: Any)
    {
        
    }
    
    @objc private func cancelButtonClicked(_ sender: Any)
    {
        
    }
}

// MARK: State

fileprivate extension TransferFundsViewController
{
    fileprivate enum State
    {
        case loading(message: String)
        case awaitingAmountInput(marketInformation: ShapeShiftAPIClient.MarketInformation)
        case displaying(quote: ShapeShiftAPIClient.Quote)
        case transferComplete
        case error(message: String)
    }
}

// MARK: NSTextFieldDelegate

extension TransferFundsViewController: NSTextFieldDelegate
{
    override func controlTextDidChange(_ obj: Notification)
    {
        self.updateTransferDetails()
    }
}
