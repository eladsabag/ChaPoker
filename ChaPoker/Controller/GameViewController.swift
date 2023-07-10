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
    @IBOutlet weak var playerTurnLabel: UILabel!
    @IBOutlet weak var turnTimeLabel: UILabel!
    
    var gameManager: GameManager?
    var table: Table?
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gameManager = GameManager(table: table!, user: user!)
        gameManager?.delegate = self
        gameManager?.observeTable()
        gameManager?.observeAllPlayersConnectivity(userId: user!.userId)
        initBlinds()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("viewWillDisappear")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("viewDidDisappear")
  
    }
    
    @IBAction func betChanged(_ sender: Any) {
        if let currentPlayerChips = gameManager?.table.currentPlayerSeatTurn?.player?.chips {
            betLabel.text = betSlider.value == betSlider.maximumValue || Int(betSlider.value) == currentPlayerChips ? "All-In" : "\(Int(betSlider.value))$"
        }
    }

    @IBAction func checkPressed(_ sender: UIButton) {
        if gameManager!.isSomeoneMadeBet() || !gameManager!.isInGame() {
            return
        }
        gameManager?.updateRoundState(action: Action.CHECK)
    }
    
    @IBAction func callPressed(_ sender: Any) {
        if !gameManager!.isInGame() {
            return
        }
        gameManager?.updateRoundState(action: Action.CALL)
    }
    
    @IBAction func betPressed(_ sender: Any) {
        if !gameManager!.isInGame() {
            return
        }
        gameManager?.updateRoundState(action: Action.BET, bet: Int(betSlider.value))
    }
    
    @IBAction func foldPressed(_ sender: Any) {
        if !gameManager!.isInGame() {
            return
        }
        gameManager?.updateRoundState(action: Action.FOLD)
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
        if let seats = gameManager?.table.seats {
            for seat in seats {
                var img: UIImageView? = nil
                switch(seat.seatIndex) {
                case 0:
                    img = leftPlayerImg
                    break
                case 1:
                    img = leftMiddlePlayerImg
                    break
                case 2:
                    img = middlePlayerImg
                    break
                case 3:
                    img = rightMiddlePlayerImg
                    break
                case 4:
                    img = rightPlayerImg
                    break
                default:
                    break
                }
                img?.isHidden = seat.isSeatEmpty()
                if let player = seat.player {
                    updateProfileImg(img: img!, player: player)
                }
            }
        }
    }
    
    func initPlayersChipsLabels() {
        if let seats = gameManager?.table.seats {
            for seat in seats {
                var lbl: UILabel? = nil
                switch(seat.seatIndex) {
                case 0:
                    lbl = leftPlayerPotLabel
                    break
                case 1:
                    lbl = leftMiddlePlayerPotLabel
                    break
                case 2:
                    lbl = middlePlayerPotLabel
                    break
                case 3:
                    lbl = rightMiddlePlayerPotLabel
                    break
                case 4:
                    lbl = rightPlayerPotLabel
                    break
                default:
                    break
                }
                lbl?.isHidden = seat.isSeatEmpty()
                if !seat.isSeatEmpty() {
                    lbl?.text = "\(seat.player!.chips)$"
                }
            }
        }
    }
    
    func initPlayersCards() {
        if let seats = gameManager?.table.seats {
            for seat in seats {
                var img1: UIImageView? = nil
                var img2: UIImageView? = nil
                switch(seat.seatIndex) {
                case 0:
                    img1 = leftCardImg1
                    img2 = leftCardImg2
                    break
                case 1:
                    img1 = leftMiddleCardImg1
                    img2 = leftMiddleCardImg2
                    break
                case 2:
                    img1 = middleCardImg1
                    img2 = middleCardImg2
                    break
                case 3:
                    img1 = rightMiddleCardImg1
                    img2 = rightMiddleCardImg2
                    break
                case 4:
                    img1 = rightCardImg1
                    img2 = rightCardImg2
                    break
                default:
                    break
                }
                img1?.isHidden = !seat.hasCards()
                img2?.isHidden = !seat.hasCards()
                if seat.hasCards() {
                    let cardImg1 = seat.player?.hand![0].imageName
                    let cardImg2 = seat.player?.hand![1].imageName
                    
                    img1?.image = UIImage(named: seat.isMySeat(userId: user!.userId) ? cardImg1! : "card")
                    img2?.image = UIImage(named: seat.isMySeat(userId: user!.userId) ? cardImg2! : "card")
                }
            }
        }
    }
    
    func initPlayerMoves() {
        let isMyTurn = gameManager?.isMyTurn() ?? false
        checkButton.isHidden = !isMyTurn
        callButton.isHidden = !isMyTurn
        betButton.isHidden = !isMyTurn
        foldButton.isHidden = !isMyTurn
        betSlider.isHidden = !isMyTurn
        betLabel.isHidden = !isMyTurn
        if isMyTurn,
            let table = gameManager?.table, let currentPlayer = table.currentPlayerSeatTurn?.player {
            // TODO
            betSlider.minimumValue = table.currentBet > table.bigBlind ? Float(table.currentBet * 2) : Float(table.bigBlind)
            betSlider.maximumValue = Float(user!.chips)
            betLabel.text = betSlider.value == betSlider.maximumValue || Int(betSlider.value) == currentPlayer.chips ? "All-In" : "\(Int(betSlider.value))$"
        }
    }
    
    func initTableCards() {
        let flop = gameManager?.table.flop
        let turn = gameManager?.table.turn
        let river = gameManager?.table.river
        if let flop = flop {
            if !flop.isEmpty {
                flopImg1.image = UIImage(named: flop[0].imageName)
                flopImg2.image = UIImage(named: flop[1].imageName)
                flopImg3.image = UIImage(named: flop[2].imageName)
            }
        }
        if let turn = turn {
            turnImg.image = UIImage(named: turn.imageName)
        }
        if let river = river {
            riverImg.image = UIImage(named: river.imageName)
        }
        flopImg1.isHidden = flop == nil || flop!.isEmpty
        flopImg2.isHidden = flop == nil || flop!.isEmpty
        flopImg3.isHidden = flop == nil || flop!.isEmpty
        turnImg.isHidden = turn == nil
        riverImg.isHidden = river == nil
    }
    
    func initBlinds() {
        blindLabel.text = "Blind: \(table!.smallBlind)/\(table!.bigBlind)"
    }
    
    func initRoundPot() {
        potLabel.text = "Pot: \(gameManager?.table.pot ?? 0)$"
    }
    
    func initPlayerTurnLabel() {
        let isGameIdle = gameManager?.table.gameState == GameState.IDLE
        playerTurnLabel.isHidden = isGameIdle
        if !isGameIdle {
            if let playerName = gameManager?.table.currentPlayerSeatTurn?.player?.name {
                playerTurnLabel.text = "Turn: \(playerName)"
            }
        }
        
    }
    
    func initPlayerTimer() {
        //TODO
    }
    
    func updateUI() {
        // 1. leave table button - always show ✓
        // 2. blind label - always show ✓
        // 3. pot label - always show ✓
        // 4. profile images - seat not empty(player in it != nil) - show ✓
        // 5. players chips label - seat not empty(player in it != nil) - show ✓
        // 6. players cards face down - player hand not empty - show ✓
        // 7. players cards face up - player hand not empty && (my cards(user id equals to the seat player user id) || round ends) - show ✓
        // 8. action buttons(check, call, bet, fold, bet slider, bet label) - is my turn - show ✓
        // 9. flop cards - flop cards not empty - show ✓
        // 10. turn card - turn card not empty - show ✓
        // 11. river card - river card not empty - show ✓
        // 12. round pot label - set to current round pot or 0 - always show
        // 13. player turn label - set to current player first name and show if game is not idle - show
        // 14. player turn timer - set to 30 seconds when game is running, and my turn - show
        initProfileImages()
        initPlayersChipsLabels()
        initPlayersCards() // TODO add round ends
        initPlayerMoves() // TODO change during round when users makes bet, bet slider and bet label must update
        initTableCards()
        initRoundPot()
        initPlayerTurnLabel()
        initPlayerTimer()
    }
}

extension GameViewController: GameManagerDelegate {
    
    func onUserLeavedTable() {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func onTableUpdated() {
        print("onTablesUpdated")
        DispatchQueue.main.async {
            self.updateUI()
            self.gameManager?.startGameIfNotPlaying()
        }
    }
}
