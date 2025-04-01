//
//  ViewController.swift
//  SnakeDash
//
//  Created by Harshali Chaudhari on 31/02/20.
//

import UIKit

class ViewController: UIViewController {
    var snake: [UIView] = []
    var food: UIView!
    var timer: Timer?
    var directionX: CGFloat = 20
    var directionY: CGFloat = 0
    var score: Int = 0
    var gameOverLabel: UILabel!
    var scoreLabel: UILabel!
    var replayButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupGame()
    }

    func setupGame() {
        view.backgroundColor = .black
        
        // Create the snake head
        let head = createSegment(x: 100, y: 100)
        snake.append(head)

        // Create the food
        snakeFood()

        scoreLabel = UILabel(frame: CGRect(x: 10, y: UIScreen.main.bounds.height - 100, width: 200, height: 40))
        scoreLabel.text = "Score: 0"
        scoreLabel.font = UIFont.boldSystemFont(ofSize: 24)
        scoreLabel.textColor = .white
        view.addSubview(scoreLabel)

        gameOverLabel = UILabel(frame: CGRect(x: view.bounds.midX - 100, y: view.bounds.midY - 50, width: 200, height: 40))
        gameOverLabel.text = "Game Over"
        gameOverLabel.font = UIFont(name: "BrunoAceSC-Regular", size: 28)
        gameOverLabel.textColor = .red
        gameOverLabel.textAlignment = .center
        gameOverLabel.isHidden = true
        view.addSubview(gameOverLabel)

        replayButton = UIButton(frame: CGRect(x: view.bounds.midX - 75, y: view.bounds.midY, width: 150, height: 40))
        replayButton.setTitle("Replay", for: .normal)
        replayButton.backgroundColor = .purple
        replayButton.titleLabel?.textColor = .white
        replayButton.layer.cornerRadius = 10
        replayButton.isHidden = true
        replayButton.addTarget(self, action: #selector(restartGame), for: .touchUpInside)
        view.addSubview(replayButton)

        // To Start moving the snake
        timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(moveSnake), userInfo: nil, repeats: true)

        // Swipe gestures for movement
        let directions: [UISwipeGestureRecognizer.Direction] = [.up, .down, .left, .right]
        for direction in directions {
            let swipe = UISwipeGestureRecognizer(target: self, action: #selector(changeDirection(_:)))
            swipe.direction = direction
            view.addGestureRecognizer(swipe)
        }
        
        for family in UIFont.familyNames {
            print("\(family): \(UIFont.fontNames(forFamilyName: family))")
        }
    }

    func createSegment(x: CGFloat, y: CGFloat) -> UIView {
        let segment = UIView(frame: CGRect(x: x, y: y, width: 20, height: 20))
        segment.backgroundColor = .cyan
        segment.layer.cornerRadius = 5
        view.addSubview(segment)
        return segment
    }

    func snakeFood() {
        let maxX = Int(view.bounds.width / 20) * 20
        let maxY = Int(view.bounds.height / 20) * 20
        let randomX = CGFloat(Int.random(in: 0..<maxX) / 20 * 20)
        let randomY = CGFloat(Int.random(in: 0..<maxY) / 20 * 20)

        if food != nil {
            food.removeFromSuperview()
        }
        
        food = UIView(frame: CGRect(x: randomX, y: randomY, width: 20, height: 20))
        food.backgroundColor = .yellow
        food.layer.cornerRadius = 5
        view.addSubview(food)
    }

    @objc func moveSnake() {
        let previousX = snake[0].frame.origin.x
        let previousY = snake[0].frame.origin.y

        let newX = previousX + directionX
        let newY = previousY + directionY

        // Check for dash with screen
        if newX < 0 || newX + 20 > view.bounds.width || newY < 0 || newY + 20 > view.bounds.height {
            gameOver()
            return
        }

        // Move snake
        for i in (1..<snake.count).reversed() {
            snake[i].frame.origin = snake[i - 1].frame.origin
        }
        snake[0].frame.origin = CGPoint(x: newX, y: newY)

        // if snake eats food
        if snake[0].frame.intersects(food.frame) {
            growSnake()
            snakeFood()
            score += 1
            scoreLabel.text = "Score: \(score)"
        }
    }

    func growSnake() {
        guard let lastSegment = snake.last else { return }
        let newSegment = createSegment(x: lastSegment.frame.origin.x, y: lastSegment.frame.origin.y)
        snake.append(newSegment)
    }

    @objc func changeDirection(_ sender: UISwipeGestureRecognizer) {
        switch sender.direction {
        case .up:
            if directionY == 0 { directionX = 0; directionY = -20 }
        case .down:
            if directionY == 0 { directionX = 0; directionY = 20 }
        case .left:
            if directionX == 0 { directionX = -20; directionY = 0 }
        case .right:
            if directionX == 0 { directionX = 20; directionY = 0 }
        default:
            break
        }
    }

    func gameOver() {
        gameOverLabel.isHidden = false
        replayButton.isHidden = false
        timer?.invalidate()
    }

    // Reset game state
    @objc func restartGame() {
        gameOverLabel.isHidden = true
        replayButton.isHidden = true
        score = 0
        scoreLabel.text = "Score: 0"
        directionX = 20
        directionY = 0
        
        for segment in snake {
            segment.removeFromSuperview()
        }
        snake.removeAll()

        let head = createSegment(x: 100, y: 100)
        snake.append(head)

        snakeFood()

        // Restart timer
        timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(moveSnake), userInfo: nil, repeats: true)
    }
}
