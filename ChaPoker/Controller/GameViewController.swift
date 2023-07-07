//
//  GameViewController.swift
//  ChaPoker
//
//  Created by Elad Sabag on 30/06/2023.
//

import UIKit

class GameViewController: UIViewController {
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var betButton: UIButton!
    @IBOutlet weak var foldButton: UIButton!
    @IBOutlet weak var blindLabel: UILabel!
    @IBOutlet weak var checkIcon: UIImageView!
    @IBOutlet weak var callIcon: UIImageView!
    @IBOutlet weak var betIcon: UIImageView!
    @IBOutlet weak var foldIcon: UIImageView!
    @IBOutlet weak var flopImg1: UIImageView!
    @IBOutlet weak var flopImg2: UIImageView!
    @IBOutlet weak var flopImg3: UIImageView!
    @IBOutlet weak var turnImg: UIImageView!
    @IBOutlet weak var riverImg: UIImageView!
    @IBOutlet weak var leftCardImg1: UIImageView!
    @IBOutlet weak var leftCardImg2: UIImageView!
    @IBOutlet weak var leftMiddleCardImg1: UIImageView!
    @IBOutlet weak var leftMiddleCardImg2: UIImageView!
    @IBOutlet weak var middleCardImg1: UIImageView!
    @IBOutlet weak var middleCardImg2: UIImageView!
    @IBOutlet weak var rightMiddleCardImg1: UIImageView!
    @IBOutlet weak var rightMiddleCardImg2: UIImageView!
    @IBOutlet weak var rightCardImg1: UIImageView!
    @IBOutlet weak var rightCardImg2: UIImageView!
    @IBOutlet weak var betLabel: UILabel!
    @IBOutlet weak var betSlider: UISlider!
    @IBOutlet weak var potLabel: UILabel!
    @IBOutlet weak var leftPlayerImg: UIImageView!
    @IBOutlet weak var leftMiddlePlayerImg: UIImageView!
    @IBOutlet weak var middlePlayerImg: UIImageView!
    @IBOutlet weak var rightMiddlePlayerImg: UIImageView!
    @IBOutlet weak var rightPlayerImg: UIImageView!
    @IBOutlet weak var leftPlayerPotLabel: UILabel!
    @IBOutlet weak var leftMiddlePlayerPotLabel: UILabel!
    @IBOutlet weak var middlePlayerPotLabel: UILabel!
    @IBOutlet weak var rightMiddlePlayerPotLabel: UILabel!
    @IBOutlet weak var rightPlayerPotLabel: UILabel!
    
    var gameManager: GameManager?
    var table: Table?
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gameManager = GameManager(table: table, user: user)
        gameManager?.delegate = self
        gameManager?.observeTable()
    }
    
    @IBAction func betChanged(_ sender: Any) {
        if let currentPlayerChips = gameManager?.table?.currentPlayerTurn?.chips {
            betLabel.text = betSlider.value == betSlider.maximumValue || Int(betSlider.value) == currentPlayerChips ? "All-In" : "\(Int(betSlider.value))$"
        }
    }

    @IBAction func checkPressed(_ sender: UIButton) {
        if gameManager!.isSomeoneMadeBet() {
            return
        }
        updateCheckedIcon(i: 0)
        gameManager?.updateAction(userId: user!.userId, action: Action.CHECK)
    }
    
    @IBAction func callPressed(_ sender: Any) {
        updateCheckedIcon(i: 1)
        gameManager?.updateAction(userId: user!.userId, action: Action.CALL)
    }
    
    @IBAction func betPressed(_ sender: Any) {
        updateCheckedIcon(i: 2)
        gameManager?.updateAction(userId: user!.userId, action: Action.BET, bet: Int(betSlider.value))
    }
    
    @IBAction func foldPressed(_ sender: Any) {
        updateCheckedIcon(i: 3)
        gameManager?.updateAction(userId: user!.userId, action: Action.FOLD)
    }
    
    func updateCheckedIcon(i: Int) {
        checkIcon.isHidden = !(i == 0)
        callIcon.isHidden = !(i == 1)
        betIcon.isHidden = !(i == 2)
        foldIcon.isHidden = !(i == 3)
    }
    
    @IBAction func leavePressed(_ sender: Any) {
        gameManager?.leaveTable()
    }
    
    func updateProfileImg(img: UIImageView, player: User?) {
        if let url = player?.profilePictureUrl {
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data, error == nil else { return }
                
                DispatchQueue.main.async { /// execute on main thread
                    img.image = UIImage(data: data)
                }
            }
            
            task.resume()
        }
        img.layer.cornerRadius = img.frame.size.height / 2;
        img.layer.masksToBounds = true;
        img.layer.borderWidth = 0;
    }
    
    func initProfileImages() {
        if let players = gameManager?.table?.players {
            for (i, player) in players.enumerated() {
                var img: UIImageView? = nil
                img = i == 0 ? leftPlayerImg : i == 1 ? leftMiddlePlayerImg : i == 2 ? middlePlayerImg : i == 3 ? rightMiddlePlayerImg : rightPlayerImg
                updateProfileImg(img: img!, player: player)
            }
        }
    }
    
    func initPlayersCards() {
        
    }
    
    func initTableCards() {
        
    }
    
    func initBlinds() {
        blindLabel.text = "Blind: \(table!.smallBlind)/\(table!.bigBlind)"
    }
    
    func initRoundPot() {
        potLabel.text = "Pot: \(gameManager?.table?.pot ?? 0)$"
    }
    
    func initRoundTimer() {
        
    }
    
    func initPlayersPotsAndCards() {
        if let seats = gameManager?.table?.seats {
            for seat in seats {
                let isHidden = seat.player == nil
                let player = gameManager?.table?.players?.first(where: { $0.userId == seat.player?.userId })
                let isInGame = gameManager?.table?.currentRoundPlayers?.first(where: { $0?.userId == player?.userId }) != nil
                switch(seat.seatIndex) {
                case 0:
                    if !isHidden {
                        leftPlayerPotLabel.text = "\(player!.chips)$"
                    }
                    leftPlayerPotLabel.isHidden = isHidden
                    leftCardImg1.isHidden = isHidden || !isInGame
                    leftCardImg2.isHidden = isHidden || !isInGame
                    break
                case 1:
                    if !isHidden {
                        leftMiddlePlayerPotLabel.text = "\(player!.chips)$"
                    }
                    leftMiddlePlayerPotLabel.isHidden = isHidden
                    leftMiddleCardImg1.isHidden = isHidden || !isInGame
                    leftMiddleCardImg2.isHidden = isHidden || !isInGame
                    break
                case 2:
                    if !isHidden {
                        middlePlayerPotLabel.text = "\(player!.chips)$"
                    }
                    middlePlayerPotLabel.isHidden = isHidden
                    middleCardImg1.isHidden = isHidden || !isInGame
                    middleCardImg2.isHidden = isHidden || !isInGame
                    break
                case 3:
                    if !isHidden {
                        rightMiddlePlayerPotLabel.text = "\(player!.chips)$"
                    }
                    rightMiddlePlayerPotLabel.isHidden = isHidden
                    rightMiddleCardImg1.isHidden = isHidden || !isInGame
                    rightMiddleCardImg2.isHidden = isHidden || !isInGame
                    break
                case 4:
                    if !isHidden {
                        rightPlayerPotLabel.text = "\(player!.chips)$"
                    }
                    rightPlayerPotLabel.isHidden = isHidden
                    rightCardImg1.isHidden = isHidden || !isInGame
                    rightCardImg2.isHidden = isHidden || !isInGame
                    break
                default:
                    break
                }
            }
        }
    }
    
    func initPlayerMoves() {
        if let isMyTurn = gameManager?.isMyTurn(userId: user!.userId) {
            checkButton.isHidden = !isMyTurn
            checkIcon.isHidden = !isMyTurn
            callButton.isHidden = !isMyTurn
            callIcon.isHidden = !isMyTurn
            betButton.isHidden = !isMyTurn
            betIcon.isHidden = !isMyTurn
            foldButton.isHidden = !isMyTurn
            foldIcon.isHidden = !isMyTurn
        }
    }
    
    func initCurrentBet() {
        if let isMyTurn = gameManager?.isMyTurn(userId: user!.userId),
            let isSomeoneMadeBet = gameManager?.isSomeoneMadeBet(),
           let table = gameManager?.table, let currentPlayer = table.currentPlayerTurn {
            betSlider.minimumValue = isSomeoneMadeBet ? Float(table.currentBet * 2) : Float(table.bigBlind)
            betSlider.maximumValue = Float(user!.chips)
            betLabel.text = betSlider.value == betSlider.maximumValue || Int(betSlider.value) == currentPlayer.chips ? "All-In" : "\(Int(betSlider.value))$"
            betSlider.isHidden = !isMyTurn
            betSlider.isHidden = !isMyTurn
            betLabel.isHidden = !isMyTurn
        }
    }
    
    func updateUI() {
        initProfileImages()
        initTableCards()
        initBlinds()
        initRoundPot()
        initRoundTimer()
        initPlayersPotsAndCards()
        initPlayerMoves()
        initCurrentBet()
    }
}

extension GameViewController: GameManagerDelegate {
    
    func onUserLeavedTable() {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func onTableUpdated() {
        DispatchQueue.main.async {
            self.updateUI()
            self.gameManager?.startGameIfNotPlaying()
        }
    }
}
