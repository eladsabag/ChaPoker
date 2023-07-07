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
    
    @IBOutlet weak var leftPlayerImg: UIImageView!
    @IBOutlet weak var leftMiddlePlayerImg: UIImageView!
    @IBOutlet weak var middlePlayerImg: UIImageView!
    @IBOutlet weak var rightMiddlePlayerImg: UIImageView!
    @IBOutlet weak var rightPlayerImg: UIImageView!
    
    var gameManager: GameManager?
    var table: Table?
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gameManager = GameManager(table: table, user: user)
        gameManager?.delegate = self
        gameManager?.observeTable()
        initViews()
    }
    
    func testAceLowStraight() {
        let flop = [Card(rank: .two, suit: .hearts), Card(rank: .three, suit: .clubs), Card(rank: .four, suit: .diamonds)]
        let turn = Card(rank: .five, suit: .spades)
        let river = Card(rank: .ace, suit: .hearts)

        let hand = [Card(rank: .ace, suit: .clubs), Card(rank: .two, suit: .hearts)]

        let strongestHand = GameValidator.findStrongestHand(flop: flop, turn: turn, river: river, hand: hand)

        print("Strongest Hand: \(strongestHand)")
    }

    
    func testGameValidator() {
        let flop = [Card(rank: .two, suit: .hearts), Card(rank: .king, suit: .hearts), Card(rank: .queen, suit: .hearts)]
        let turn = Card(rank: .jack, suit: .hearts)
        let river = Card(rank: .ten, suit: .hearts)

        let player1Hand = [Card(rank: .nine, suit: .hearts), Card(rank: .eight, suit: .hearts)]
        let player2Hand = [Card(rank: .ace, suit: .clubs), Card(rank: .king, suit: .clubs)]
        let player3Hand = [Card(rank: .ace, suit: .spades), Card(rank: .king, suit: .spades)]

        let player1StrongestHand = GameValidator.findStrongestHand(flop: flop, turn: turn, river: river, hand: player1Hand)
        let player2StrongestHand = GameValidator.findStrongestHand(flop: flop, turn: turn, river: river, hand: player2Hand)
        let player3StrongestHand = GameValidator.findStrongestHand(flop: flop, turn: turn, river: river, hand: player3Hand)

        let strongestHands = [player1StrongestHand, player2StrongestHand, player3StrongestHand]

        print("Player 1 Strongest Hand: \(player1StrongestHand)")
        print("Player 2 Strongest Hand: \(player2StrongestHand)")
        print("Player 3 Strongest Hand: \(player3StrongestHand)")

        let winners = GameValidator.determineWinners(strongestHands.map { $0.hand })

        if winners.count == 1 {
            print("Player \(winners[0] + 1) is the winner!")
        } else if winners.count > 1 {
            print("It's a tie between players: \(winners.map { $0 + 1 })")
        } else {
            print("No winners found.")
        }
    }

    
    @IBAction func betChanged(_ sender: Any) {
        betLabel.text = betSlider.value == betSlider.maximumValue ? "All-In" : "\(Int(betSlider.value))$"
    }
    

    @IBAction func checkPressed(_ sender: UIButton) {
        updateCheckedIcon(i: 0)
    }
    
    @IBAction func callPressed(_ sender: Any) {
        updateCheckedIcon(i: 1)
    }
    
    @IBAction func betPressed(_ sender: Any) {
        updateCheckedIcon(i: 2)
    }
    
    @IBAction func foldPressed(_ sender: Any) {
        updateCheckedIcon(i: 3)
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
    
    func initViews() {
        blindLabel.text = "Blind: \(table!.smallBlind)/\(table!.bigBlind)"
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
}

extension GameViewController: GameManagerDelegate {
    
    func onUserLeavedTable() {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func onTableUpdated() {
        DispatchQueue.main.async {
            self.initProfileImages()
        }
    }
}
