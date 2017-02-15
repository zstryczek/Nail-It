//
//  GameScene.swift
//  Nail It
//
//  Created by zstryczek on 12/7/16.
//  Copyright © 2016 zstryapps. All rights reserved.
//

import SpriteKit
import GameplayKit
import GameKit
import AudioToolbox
import GoogleMobileAds

class GameScene: SKScene, GKGameCenterControllerDelegate, UIAlertViewDelegate {
    
    var interstitial: GADInterstitial!
    
    //// INITALIZE NODES ////
    var background : SKSpriteNode!
    var lowerSection : SKSpriteNode!
    var boardBottom : SKSpriteNode!
    var roofBottom1 : SKSpriteNode!
    var roofBottom2 : SKSpriteNode!
    var roofBottom3 : SKSpriteNode!
    var roofBottom4 : SKSpriteNode!
    var bodyBoard1 : SKSpriteNode!
    var bodyBoard2 : SKSpriteNode!
    var bodyBoard3 : SKSpriteNode!
    var bodyBoard4 : SKSpriteNode!
    var roof1 : SKSpriteNode!
    var roof2 : SKSpriteNode!
    var roof3 : SKSpriteNode!
    var roof4 : SKSpriteNode!
    var roofTop : SKSpriteNode!
    var startButton: SKSpriteNode!
    var rateButton: SKSpriteNode!
    var shareButton: SKSpriteNode!
    var gameCenterButton: SKSpriteNode!
    var shadow1 : SKSpriteNode!
    var shadow2 : SKSpriteNode!
    var shadow3 : SKSpriteNode!
    var shadow4 : SKSpriteNode!
    var shadow5 : SKSpriteNode!
    var nail : SKSpriteNode!
    var door : SKSpriteNode!
    var windows : SKSpriteNode!
    var level = 1
    var timer = Timer()
    var seperateHouseCounter = 0
    var scoreLabel = SKLabelNode()
    var scoreReportLabel = SKLabelNode()
    var recordLabel = SKLabelNode()
    var highScore = Int()

    var startButtonTapped = false
    
    // start game at score of 0
    var score = 0
        
        {
        didSet //Called immediatiley after a new value is stored it's a property observer
        {
            scoreLabel.text = "\(score)"
        }
    }

    
    override func didMove(to view: SKView) {
        
        createBackground()
        createBodyBoard1()
        createBodyBoard2()
        createBodyBoard3()
        createBodyBoard4()
        createRoof1()
        createRoof2()
        createRoof3()
        createRoof4()
        createRoofTop()
        createStartButton()
        createScoreReportLabel()
        createRecordLabel()
        createLowerSection()
        createDoor()
        createWindows()
        createRateButton()
        createGameCenterButton()
        createShareButton()
        authPlayer()
        createAndLoadInterstitial()

       
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch: AnyObject in touches {
            // Get the location of the touch in this scene
            let location = touch.location(in: self)
            
            // screen tapped while playing game
            if (self.startButtonTapped == true && self.contains(location))
            {
                tapChecker()
            }
            
            
            
            // checks to see if start button was tapped and starts to play the game
            if (startButton.contains(location) && startButtonTapped == false)
            {
                startButtonTapped = true
                
                // Button fades out and blocks start to animate for game to start
                
                self.view?.isUserInteractionEnabled = false
                self.scoreReportLabel.run(SKAction.fadeOut(withDuration: 0.5))
                self.recordLabel.run(SKAction.fadeOut(withDuration: 0.5))
                self.door.run(SKAction.fadeOut(withDuration: 0.5))
                self.windows.run(SKAction.fadeOut(withDuration: 0.5))
                self.rateButton.run(SKAction.fadeOut(withDuration: 0.5))
                self.gameCenterButton.run(SKAction.fadeOut(withDuration: 0.5))
                self.shareButton.run(SKAction.fadeOut(withDuration: 0.5))


                
                startButton.run(SKAction.fadeOut(withDuration: 0.5), completion: {finished in
                    
                self.score = 0
                self.timer = Timer.scheduledTimer(timeInterval: 0.1, target:self, selector: #selector(GameScene.animateUp), userInfo: nil, repeats: true)
                
                })
                
            }
            
            if (gameCenterButton.contains(location) && startButtonTapped == false)
            {
                showLeaderBoard()
            }
            
            
            if (shareButton.contains(location) && startButtonTapped == false)
            {
                // takes screenshot
                UIGraphicsBeginImageContextWithOptions(UIScreen.main.bounds.size, false, 0)
                self.view!.drawHierarchy(in: self.view!.bounds, afterScreenUpdates: true)
                let image:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
                
                UIGraphicsEndImageContext()
                
                let Image = image //The image is stored in the variable Image
                
                let vc = self.view?.window?.rootViewController
                
                let myText = "I just got \(score) nails in #ShackStack see how many you can get! https://itunes.apple.com/us/app/shack-stack/id1204004137?ls=1&mt=8"
                
                let activityVC:UIActivityViewController = UIActivityViewController(activityItems: [Image, myText], applicationActivities: nil)
                
                vc?.present(activityVC, animated: true, completion: nil)
            }
            
            
            if (rateButton.contains(location) && startButtonTapped == false)
            {
                let link = NSURL(string:"https://itunes.apple.com/us/app/shack-stack/id1204004137?ls=1&mt=8")
            
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(link as! URL, options: [:], completionHandler: nil)
                } else {
                    // Fallback on earlier versions
                    UIApplication.shared.openURL(NSURL(string:"https://itunes.apple.com/us/app/shack-stack/id1204004137?ls=1&mt=8") as! URL)
                }
                
            }

            
            
        }
    }
    
    
    /// Ad Mob stuff
    
    private func createAndLoadInterstitial() {
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-6036964001864201/1487854771")
        let request = GADRequest()
        // Request test ads on devices you specify. Your test device ID is printed to the console when
        // an ad request is made.
        request.testDevices = [ kGADSimulatorID, "2077ef9a63d2b398840261c8221a0c9b" ]
        interstitial.load(request)
    }
    
    func showInterstitial()
    {
        if (self.interstitial.isReady) {
            interstitial.present(fromRootViewController: (self.view?.window?.rootViewController!)!)
        }
    }
    
    
    // Ad Mob stuff done
    

    
    /// GAME CENTER STUFF START
    
    func authPlayer(){
        let localPlayer = GKLocalPlayer.localPlayer()
        
        localPlayer.authenticateHandler = {
            (view, error) in
            
            if view != nil {
                
                self.view?.window?.rootViewController!.present(view!, animated: true, completion:nil)
                
            }
            else {
                
                print(GKLocalPlayer.localPlayer().isAuthenticated)
                
            }
            
            
        }
    }
    
    func showLeaderBoard(){
        let viewController = self.view?.window?.rootViewController
        let gcvc = GKGameCenterViewController()
        
        gcvc.gameCenterDelegate = self
        
        viewController?.present(gcvc, animated: true, completion: nil)
    }
    
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
        
    }
    
    
    ///// GAME CENTER STUFF DONE
    
    
    
    func tapChecker()
    {
        var height = CGFloat()
        var layer = CGFloat()
        var nailDownDistance = CGFloat()
        
        if (level == 1)
        {
            height = 0
            layer = 1.5
            nailDownDistance = 96
        }
        
        if (level == 2)
        {
            height = 70
            layer = 3.5
            nailDownDistance = 96
        }
        
        if (level == 3)
        {
            height = 140
            layer = 5.5
            nailDownDistance = 96
            
        }
        
        if (level == 4)
        {
            height = 210
            layer = 7.5
            nailDownDistance = 96
            
        }
        
        if (level == 5)
        {
            height = 250
            layer = 9.5
            nailDownDistance = 81
            
            
        }
        
        if (level == 6)
        {
            height = 300
            layer = 11.5
            nailDownDistance = 79
            
        }
        
        if (level == 7)
        {
            height = 350
            layer = 13.5
            nailDownDistance = 77
            
        }
        
        if (level == 8)
        {
            height = 400
            layer = 15.5
            nailDownDistance = 75
            
        }
        
        
        
        // check to see if tap was on top of "button" node and if it has been tapped game is played
        
        if(nail.position.x > shadow1.position.x - 10 && nail.position.x < shadow1.position.x + 10 && nail.position.y == shadow1.position.y)
        {
            score += 1
            shadow1.removeFromParent()
            
            if(level == 5)
            {
                self.createShadowNail1(xOffset: -132, yOffset: height, image: "nail",layer : layer)
            }
            
            if(level == 6)
            {
                self.createShadowNail1(xOffset: -73, yOffset: height, image: "nail",layer : layer)
                
            }
            
            if(level == 7)
            {
                self.createShadowNail1(xOffset: -37.5, yOffset: height, image: "nail",layer : layer)
            }
            
            if(level == 8)
            {
                self.createShadowNail1(xOffset: 0, yOffset: height, image: "nail",layer : layer)
            }
            if(level == 1 || level == 2 || level == 3 || level == 4)
            {
                createShadowNail1(xOffset: -214, yOffset : height, image: "nail", layer : layer)
            }
            
            shadow1.run(SKAction.moveTo(y: shadow1.position.y - nailDownDistance, duration: 0.5), completion: {finished in
                
                self.checkProgress()
            })
            return
            
            
        }
        
        if(nail.position.x > shadow2.position.x - 10 && nail.position.x < shadow2.position.x + 10 && nail.position.y == shadow2.position.y)
        {
            score += 1
            shadow2.removeFromParent()
            
            if(level == 5)
            {
                self.createShadowNail2(xOffset: -49, yOffset: height, image: "nail", layer : layer)
            }
            
            if(level == 6)
            {
                self.createShadowNail2(xOffset: 0, yOffset: height, image: "nail", layer : layer)
            }
            
            if(level == 7)
            {
                self.createShadowNail2(xOffset: 35.5, yOffset: height, image: "nail", layer : layer)
            }
            
            if(level == 1 || level == 2 || level == 3 || level == 4)
            {
                createShadowNail2(xOffset: -107, yOffset : height, image: "nail", layer : layer)
            }
            
            shadow2.run(SKAction.moveTo(y: shadow2.position.y - nailDownDistance, duration: 0.5), completion: {finished in
                
                self.checkProgress()
            })
            return
            
            
            
        }
        
        
        
        if(nail.position.x > shadow3.position.x - 10 && nail.position.x < shadow3.position.x + 10 && nail.position.y == shadow3.position.y)
        {
            score += 1
            shadow3.removeFromParent()
            
            if(level == 5)
            {
                self.createShadowNail3(xOffset: 36, yOffset: height, image: "nail", layer : layer)
            }
            
            if(level == 6)
            {
                self.createShadowNail3(xOffset: 73, yOffset: height, image: "nail", layer : layer)
            }
            
            if(level == 1 || level == 2 || level == 3 || level == 4)
            {
                createShadowNail3(xOffset: 0, yOffset : height, image: "nail", layer : layer)
            }
            
            shadow3.run(SKAction.moveTo(y: shadow3.position.y - nailDownDistance, duration: 0.5), completion: {finished in
                
                self.checkProgress()
            })
            return
            
        }
        
        
        
        if(nail.position.x > shadow4.position.x - 10 && nail.position.x < shadow4.position.x + 10 && nail.position.y == shadow4.position.y)
        {
            score += 1
            shadow4.removeFromParent()
            
            if(level == 5)
            {
                self.createShadowNail4(xOffset: 121, yOffset: height, image: "nail", layer : layer)
            }
            
            if(level == 1 || level == 2 || level == 3 || level == 4)
            {
                createShadowNail4(xOffset: 107, yOffset : height, image: "nail", layer : layer)
            }
            
            shadow4.run(SKAction.moveTo(y: shadow4.position.y - nailDownDistance, duration: 0.5), completion: {finished in
                
                self.checkProgress()
            })
            
            return
        }
        
        
        
        if(nail.position.x > shadow5.position.x - 10 && nail.position.x < shadow5.position.x + 10 && nail.position.y == shadow5.position.y)
        {
            score += 1
            shadow5.removeFromParent()
            if(level == 1 || level == 2 || level == 3 || level == 4)
            {
                createShadowNail5(xOffset: 214, yOffset : height, image: "nail", layer : layer)
            }
            
            shadow5.run(SKAction.moveTo(y: shadow5.position.y - nailDownDistance, duration: 0.5), completion: {finished in
                
                self.checkProgress()
                
                
            })
            return
        }
        
        gameOver()
        
    }

    
    func animateUp()
    {
        
        seperateHouseCounter += 1
        
        let animDuration = 1.0
        let distanceUp = self.background.frame.height + 200

        
        if (seperateHouseCounter == 1)
        {
            self.roofTop.run(SKAction.moveTo(y: distanceUp, duration: animDuration))
        }
        if (seperateHouseCounter == 2)
        {
            self.roof4.run(SKAction.moveTo(y: distanceUp, duration: animDuration))
        }
        if (seperateHouseCounter == 3)
        {
            self.roof3.run(SKAction.moveTo(y: distanceUp, duration: animDuration))
        }
        if (seperateHouseCounter == 4)
        {
            self.roof2.run(SKAction.moveTo(y: distanceUp, duration: animDuration))
        }
        if (seperateHouseCounter == 5)
        {
            self.roof1.run(SKAction.moveTo(y: distanceUp, duration: animDuration))
        }

        if (seperateHouseCounter == 6)
        {
            self.bodyBoard4.run(SKAction.moveTo(y: distanceUp, duration: animDuration))
        }
        if (seperateHouseCounter == 7)
        {
            self.bodyBoard3.run(SKAction.moveTo(y: distanceUp, duration: animDuration))
        }
        if (seperateHouseCounter == 8)
        {
            self.bodyBoard2.run(SKAction.moveTo(y: distanceUp, duration: animDuration), completion: {finished in
                
                self.playGame()
                self.timer.invalidate()
                self.seperateHouseCounter = 0
                self.createScore()
                self.view?.isUserInteractionEnabled = true

            })

        }
        
    }


    func playGame()
    {
        
        createShadowNail1(xOffset: -214, yOffset : 0, image: "nailShadow", layer : 1.5)
        createShadowNail2(xOffset: -107,  yOffset : 0, image: "nailShadow", layer : 1.5 )
        createShadowNail3(xOffset: 0,  yOffset : 0, image: "nailShadow", layer : 1.5)
        createShadowNail4(xOffset: 107,  yOffset : 0, image: "nailShadow", layer : 1.5)
        createShadowNail5(xOffset: 214,  yOffset : 0, image: "nailShadow", layer : 1.5)
        
        createNail()
        animateNail()
        
    }
    
    func animateNail()
    {
        let animation = SKAction.moveTo(x: frame.width * 0.05, duration: 4.5)
            
        let animateBack = SKAction.moveTo(x: self.frame.width * 0.95, duration: 4.5)
        
        let moveSequence = SKAction.sequence([animation,animateBack])
    
        let moveLoop = SKAction.repeatForever(moveSequence)
        nail.run(moveLoop)
    
    }
    
    
    func checkProgress()
    {
        // Leval 1 transitioning to leval 2
        
        if (shadow1.position.y < 40 && shadow2.position.y < 40 && shadow3.position.y < 40 && shadow4.position.y < 40 && shadow5.position.y < 40)
        {
            self.bodyBoard2.run(SKAction.moveTo(y: background.frame.height * 0.1 + 70, duration: 1), completion: {finished in
                
                self.shadow1.removeFromParent()
                self.shadow2.removeFromParent()
                self.shadow3.removeFromParent()
                self.shadow4.removeFromParent()
                self.shadow5.removeFromParent()
                
                self.boardBottom.removeFromParent()
                
                self.nail.run(SKAction.moveTo(y: self.nail.position.y + 70, duration: 0.1))
                self.nail.speed = 1.3
                
                
                
                self.createShadowNail1(xOffset: -214, yOffset: 70, image: "nailShadow",layer : 1.5)
                self.createShadowNail2(xOffset: -107, yOffset: 70, image: "nailShadow", layer : 1.5)
                self.createShadowNail3(xOffset: 0, yOffset: 70, image: "nailShadow", layer : 1.5)
                self.createShadowNail4(xOffset: 107, yOffset: 70, image: "nailShadow", layer : 1.5)
                self.createShadowNail5(xOffset: 214, yOffset: 70, image: "nailShadow", layer : 1.5)
                
                self.createBottomBoardCover(height: -60, zPosition: 4)
                
                self.level = 2

            })

        }
        
        // Level 2 transitioning to level 3
        let animatedNailHeight2 = Int((background.frame.height * 0.1 + 70) - 96)
        
        if (Int(shadow1.position.y) == animatedNailHeight2 && Int(shadow2.position.y) == animatedNailHeight2 && Int(shadow3.position.y) == animatedNailHeight2 && Int(shadow4.position.y) == animatedNailHeight2 && Int(shadow5.position.y) == animatedNailHeight2)
        {
            self.bodyBoard3.run(SKAction.moveTo(y: background.frame.height * 0.1 + 140, duration: 1), completion: {finished in
                
                self.shadow1.removeFromParent()
                self.shadow2.removeFromParent()
                self.shadow3.removeFromParent()
                self.shadow4.removeFromParent()
                self.shadow5.removeFromParent()
                
                self.boardBottom.removeFromParent()
                
                self.nail.run(SKAction.moveTo(y: self.nail.position.y + 70, duration: 0.1))
                self.nail.speed = 1.6
                
                self.createShadowNail1(xOffset: -214, yOffset: 140, image: "nailShadow",layer : 1.5)
                self.createShadowNail2(xOffset: -107, yOffset: 140, image: "nailShadow", layer : 1.5)
                self.createShadowNail3(xOffset: 0, yOffset: 140, image: "nailShadow", layer : 1.5)
                self.createShadowNail4(xOffset: 107, yOffset: 140, image: "nailShadow", layer : 1.5)
                self.createShadowNail5(xOffset: 214, yOffset: 140, image: "nailShadow", layer : 1.5)
                
                self.createBottomBoardCover(height: 10, zPosition: 6)
                
                self.level = 3
                
            })
            
        }
        
        // Level 3 transitioning to level 4
        let animatedNailHeight3 = Int((background.frame.height * 0.1 + 140) - 96)
        
        if (Int(shadow1.position.y) == animatedNailHeight3 && Int(shadow2.position.y) == animatedNailHeight3 && Int(shadow3.position.y) == animatedNailHeight3 && Int(shadow4.position.y) == animatedNailHeight3 && Int(shadow5.position.y) == animatedNailHeight3)
        {
            self.bodyBoard4.run(SKAction.moveTo(y: background.frame.height * 0.1 + 210, duration: 1), completion: {finished in
                
                self.shadow1.removeFromParent()
                self.shadow2.removeFromParent()
                self.shadow3.removeFromParent()
                self.shadow4.removeFromParent()
                self.shadow5.removeFromParent()
                
                self.boardBottom.removeFromParent()
                
                self.nail.run(SKAction.moveTo(y: self.nail.position.y + 70, duration: 0.1))
                self.nail.speed = 1.9
                
                self.createShadowNail1(xOffset: -214, yOffset: 210, image: "nailShadow",layer : 1.5)
                self.createShadowNail2(xOffset: -107, yOffset: 210, image: "nailShadow", layer : 1.5)
                self.createShadowNail3(xOffset: 0, yOffset: 210, image: "nailShadow", layer : 1.5)
                self.createShadowNail4(xOffset: 107, yOffset: 210, image: "nailShadow", layer : 1.5)
                self.createShadowNail5(xOffset: 214, yOffset: 210, image: "nailShadow", layer : 1.5)
                
                self.createBottomBoardCover(height: 80, zPosition: 8)
                
                self.level = 4
                
            })
            
        }
        
        // Level 4 transitioning to level 5
        let animatedNailHeight4 = Int((background.frame.height * 0.1 + 210) - 96)
        
        if (Int(shadow1.position.y) == animatedNailHeight4 && Int(shadow2.position.y) == animatedNailHeight4 && Int(shadow3.position.y) == animatedNailHeight4 && Int(shadow4.position.y) == animatedNailHeight4 && Int(shadow5.position.y) == animatedNailHeight4)
        {
            self.roof1.run(SKAction.moveTo(y: background.frame.height * 0.1 + 280, duration: 1), completion: {finished in
                
                self.shadow1.removeFromParent()
                self.shadow2.removeFromParent()
                self.shadow3.removeFromParent()
                self.shadow4.removeFromParent()
                self.shadow5.removeFromParent()
                
                self.boardBottom.removeFromParent()
                
                self.nail.run(SKAction.moveTo(y: self.nail.position.y + 40, duration: 0.1))
                self.nail.speed = 2.2
                
                self.createShadowNail1(xOffset: -132, yOffset: 250, image: "nailShadow",layer : 1.5)
                self.createShadowNail2(xOffset: -50, yOffset: 250, image: "nailShadow", layer : 1.5)
                self.createShadowNail3(xOffset: 35, yOffset: 250, image: "nailShadow", layer : 1.5)
                self.createShadowNail4(xOffset: 120, yOffset: 250, image: "nailShadow", layer : 1.5)
                
                
                self.createRoofCover1()
                
                self.level = 5
                
            })
            
        }
        
        // Level 5 transitioning to level 6
        let animatedNailHeight5 = Int((background.frame.height * 0.1 + 250) - 81)
        
        if (Int(shadow1.position.y) == animatedNailHeight5 && Int(shadow2.position.y) == animatedNailHeight5 && Int(shadow3.position.y) == animatedNailHeight5 && Int(shadow4.position.y) == animatedNailHeight5)
        {
            self.roof2.run(SKAction.moveTo(y: background.frame.height * 0.1 + 350, duration: 1), completion: {finished in
                
                self.shadow1.removeFromParent()
                self.shadow2.removeFromParent()
                self.shadow3.removeFromParent()
                self.shadow4.removeFromParent()
                
                
                self.roofBottom1.removeFromParent()
                
                self.nail.run(SKAction.moveTo(y: self.nail.position.y + 50, duration: 0.1))
                self.nail.speed = 2.5
                
                self.createShadowNail1(xOffset: -73, yOffset: 300, image: "nailShadow",layer : 1.5)
                self.createShadowNail2(xOffset: 0, yOffset: 300, image: "nailShadow", layer : 1.5)
                self.createShadowNail3(xOffset: 73, yOffset: 300, image: "nailShadow", layer : 1.5)
                
                self.createRoofCover2()
                
                self.level = 6
                
            })
            
        }
        
        // Level 6 transitioning to level 7
        let animatedNailHeight6 = Int((background.frame.height * 0.1 + 300) - 79)
        
        if (Int(shadow1.position.y) == animatedNailHeight6 && Int(shadow2.position.y) == animatedNailHeight6 && Int(shadow3.position.y) == animatedNailHeight6)
        {
            self.roof3.run(SKAction.moveTo(y: background.frame.height * 0.1 + 420, duration: 1), completion: {finished in
                
                self.shadow1.removeFromParent()
                self.shadow2.removeFromParent()
                self.shadow3.removeFromParent()
               
                
                self.roofBottom2.removeFromParent()
                
                self.nail.run(SKAction.moveTo(y: self.nail.position.y + 50, duration: 0.1))
                self.nail.speed = 2.8
                
                self.createShadowNail1(xOffset: -37.5, yOffset: 350, image: "nailShadow",layer : 1.5)
                self.createShadowNail2(xOffset: 35.5, yOffset: 350, image: "nailShadow", layer : 1.5)
                
                
                self.createRoofCover3()
                
                self.level = 7
                
            })
            
        }
        
        // Level 7 transitioning to level 8
        let animatedNailHeight7 = Int((background.frame.height * 0.1 + 350) - 77)
        
        if (Int(shadow1.position.y) == animatedNailHeight7 && Int(shadow2.position.y) == animatedNailHeight7)
        {
            self.roof4.run(SKAction.moveTo(y: background.frame.height * 0.1 + 490, duration: 1), completion: {finished in
                
                self.shadow1.removeFromParent()
                self.shadow2.removeFromParent()
                
                
                self.roofBottom3.removeFromParent()
                
                self.nail.run(SKAction.moveTo(y: self.nail.position.y + 50, duration: 0.1))
                self.nail.speed = 3.0
                
                self.createShadowNail1(xOffset: 0, yOffset: 400, image: "nailShadow",layer : 1.5)
               
                self.createRoofCover4()
                
                self.level = 8
                
            })
            
        }
        
        
        // Level 8 transitioning to end of game
        let animatedNailHeight8 = Int((background.frame.height * 0.1 + 400) - 75)
        
        if (Int(shadow1.position.y) == animatedNailHeight8)
        {
            self.roofTop.run(SKAction.moveTo(y: background.frame.height * 0.1 + 560, duration: 1), completion: {finished in
                
                self.removeAllChildren()
                self.createBackground() // loads score to game center when background is created
                self.createLowerSection()
                self.createBodyBoard1()
                self.createBodyBoard2()
                self.createBodyBoard3()
                self.createBodyBoard4()
                self.createRoof1()
                self.createRoof2()
                self.createRoof3()
                self.createRoof4()
                self.createRoofTop()
                self.createStartButton()
                self.level = 1
                self.startButtonTapped = false
                self.createScoreReportLabel()
                self.createRecordLabel()
                self.createDoor()
                self.createWindows()
                
                
            })
            
        }

    }
    
    func DisplayHighScore() -> Int {
        UserDefaults.standard.integer(forKey: "highscore")
        
        //Check if score is higher than NSUserDefaults stored value and change NSUserDefaults stored value if it's true
        if score > UserDefaults.standard.integer(forKey: "highscore") {
            highScore = score
            UserDefaults.standard.set(highScore, forKey: "highscore")
            UserDefaults.standard.synchronize()
            
        }
        
        return UserDefaults.standard.integer(forKey: "highscore")
    }

    func gameOver()
    {
        self.view?.isUserInteractionEnabled = false
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
        self.nail.speed = 1.0
        nail.removeAllActions()
        nail.run(SKAction.colorize(with: UIColor.red, colorBlendFactor: 1, duration: 0.1), completion: {finished in
            
            self.nail.run(SKAction.fadeOut(withDuration: 1), completion: {finished in
                
                self.view?.isUserInteractionEnabled = true
                self.removeAllChildren()
                self.createBackground() // loads score to game center when background is created
                self.createLowerSection()
                self.createBodyBoard1()
                self.createBodyBoard2()
                self.createBodyBoard3()
                self.createBodyBoard4()
                self.createRoof1()
                self.createRoof2()
                self.createRoof3()
                self.createRoof4()
                self.createRoofTop()
                self.createStartButton()
                self.level = 1
                self.startButtonTapped = false
                self.createScoreReportLabel()
                self.createRecordLabel()
                self.createDoor()
                self.createWindows()
                self.createRateButton()
                self.createGameCenterButton()
                self.createShareButton()
                
                let randomAdNum = arc4random_uniform(5)
                
                if (randomAdNum == 1)
                {
                    self.showInterstitial()
                    self.createAndLoadInterstitial()
                }


                
            })
        })
        
    }

    
    
    
    
    

    ////// ////// ////// ////// ////// ////// CREATE NODES ////// ////// ////// ////// ////// ////// ////// //////
   ////// ////// ////// ////// ////// ////// ////// ////// ////// ////// ////// ////// ////// ////// ////// //////
    
    
    func createScore()
    {
        scoreLabel = SKLabelNode(fontNamed: "Arial Bold")
        scoreLabel.fontSize = 150
        scoreLabel.position = CGPoint(x: 0, y: frame.maxY * 0.55)
        scoreLabel.horizontalAlignmentMode = .center
        scoreLabel.verticalAlignmentMode = .center
        scoreLabel.zPosition = 0
        scoreLabel.text = "0"
        scoreLabel.fontColor = UIColor.white
        scoreLabel.alpha = 0.0
        
        addChild(scoreLabel)
        scoreLabel.run(SKAction.fadeIn(withDuration: 0.5))
        
    }
    
    func createRecordLabel()
    {
        recordLabel = SKLabelNode(fontNamed: "Arial")
        recordLabel.fontSize = 50
        recordLabel.position = CGPoint(x: 0, y: frame.maxY * 0.38)
        recordLabel.horizontalAlignmentMode = .center
        recordLabel.verticalAlignmentMode = .center
        recordLabel.zPosition = 0
        recordLabel.text = ("BEST: \(DisplayHighScore()) / 30")
        recordLabel.fontColor = UIColor.white
        
        addChild(recordLabel)
        
    }

    
    func createScoreReportLabel()
    {
        scoreReportLabel = SKLabelNode(fontNamed: "Arial Bold")
        scoreReportLabel.fontSize = 150
        scoreReportLabel.position = CGPoint(x: 0, y: frame.maxY * 0.55)
        scoreReportLabel.horizontalAlignmentMode = .center
        scoreReportLabel.verticalAlignmentMode = .center
        scoreReportLabel.zPosition = 0
        scoreReportLabel.text = "\(score)"
        scoreReportLabel.fontColor = UIColor.white
        
        addChild(scoreReportLabel)
        
    }
    
   
    func createBackground()
    {
        let backgroundTexture = SKTexture(imageNamed: "Background") //Sets texture to node
        backgroundTexture.filteringMode = SKTextureFilteringMode.nearest
        background = SKSpriteNode(texture: backgroundTexture) //Sets texture to sprite node
        background.zPosition = -1 //Staking order
        background.position = CGPoint(x: frame.midX, y: frame.midY) //Location on the view
        background.size = CGSize(width: frame.width + 20, height: frame.height + 10)
        
        addChild(background) //Add to scene
        
        
        if GKLocalPlayer.localPlayer().isAuthenticated {
            
            let scoreReporter = GKScore(leaderboardIdentifier: "ShackStack")
            
            scoreReporter.value = Int64(UserDefaults.standard.integer(forKey: "highscore"))
            
            let scoreArray : [GKScore] = [scoreReporter]
            
            GKScore.report(scoreArray, withCompletionHandler: nil)
        }
        

        
    }
    
    func createLowerSection()
    {
        let lowerSectionTexture = SKTexture(imageNamed: "lower section") //Sets texture to node
        lowerSectionTexture.filteringMode = SKTextureFilteringMode.nearest
        lowerSection = SKSpriteNode(texture: lowerSectionTexture) //Sets texture to sprite node
        //lowerSection.anchorPoint = CGPoint(x: 0.53, y: 1.4)
        lowerSection.zPosition = 5 //Staking order
        lowerSection.position = CGPoint(x: frame.midX, y: -517 ) //Location on the view
        lowerSection.size = CGSize(width: frame.width * 1.05, height: frame.height * 0.3)
        
        addChild(lowerSection) //Add to scene
        
    }
    
    func createStartButton()
    {
        let startButtonTexture = SKTexture(imageNamed: "playButton")
        startButtonTexture.filteringMode = SKTextureFilteringMode.nearest
        startButton = SKSpriteNode(texture: startButtonTexture) //Sets texture to sprite node
        startButton.anchorPoint = CGPoint(x: 2, y: 2.9)
        startButton.zPosition = 19 //Staking order
        startButton.position = CGPoint(x: frame.width * 0.5, y: background.frame.height * 0.5) //Location on the view
        startButton.size = CGSize(width: 250, height: 250)
        
        addChild(startButton) //Add to scene
    }
    
    func createRateButton()
    {
        let rateButtonTexture = SKTexture(imageNamed: "RateButton")
        rateButtonTexture.filteringMode = SKTextureFilteringMode.nearest
        rateButton = SKSpriteNode(texture: rateButtonTexture) //Sets texture to sprite node
        rateButton.anchorPoint = CGPoint(x: 3.4, y: 5.8)
        rateButton.zPosition = 10 //Staking order
        rateButton.position = CGPoint(x: frame.width * 0.5, y: background.frame.height * 0.1) //Location on the view
        rateButton.size = CGSize(width: 132, height: 132)
        
        addChild(rateButton) //Add to scene
    }
    
    func createShareButton()
    {
        let shareButtonTexture = SKTexture(imageNamed: "shareButton")
        shareButtonTexture.filteringMode = SKTextureFilteringMode.nearest
        shareButton = SKSpriteNode(texture: shareButtonTexture) //Sets texture to sprite node
        shareButton.anchorPoint = CGPoint(x: 3.4, y: 5.8)
        shareButton.zPosition = 10 //Staking order
        shareButton.position = CGPoint(x: frame.width * 0.8, y: background.frame.height * 0.1) //Location on the view
        shareButton.size = CGSize(width: 132, height: 132)
        
        addChild(shareButton) //Add to scene
    }
    
    func createGameCenterButton()
    {
        let gameCenterButtonTexture = SKTexture(imageNamed: "gameCenterButton")
        gameCenterButtonTexture.filteringMode = SKTextureFilteringMode.nearest
        gameCenterButton = SKSpriteNode(texture: gameCenterButtonTexture) //Sets texture to sprite node
        gameCenterButton.anchorPoint = CGPoint(x: 3.4, y: 5.8)
        gameCenterButton.zPosition = 10 //Staking order
        gameCenterButton.position = CGPoint(x: frame.width * 0.2, y: background.frame.height * 0.1) //Location on the view
        gameCenterButton.size = CGSize(width: 132, height: 132)
        
        addChild(gameCenterButton) //Add to scene
    }



    func createDoor()
    {
        let doorTexture = SKTexture(imageNamed: "door")
        doorTexture.filteringMode = SKTextureFilteringMode.nearest
        door = SKSpriteNode(texture: doorTexture) //Sets texture to sprite node
        door.anchorPoint = CGPoint(x: 4.08, y: 4.2)
        door.zPosition = 10 //Staking order
        door.position = CGPoint(x: frame.width * 0.5, y: background.frame.height * 0.3) //Location on the view
        door.size = CGSize(width: 106, height: 188)
        
        addChild(door) //Add to scene

    }
    
    func createWindows()
    {
        let windowsTexture = SKTexture(imageNamed: "windows")
        windowsTexture.filteringMode = SKTextureFilteringMode.nearest
        windows = SKSpriteNode(texture: windowsTexture) //Sets texture to sprite node
        windows.anchorPoint = CGPoint(x: 1.2, y: 2.5)
        windows.zPosition = 15 //Staking order
        windows.position = CGPoint(x: frame.width * 0.5, y: background.frame.height * 0.3) //Location on the view
        windows.size = CGSize(width: 538, height: 286)
        
        addChild(windows) //Add to scene
        
    }

    
    func createBodyBoard1()
    {
        let boardTexture = SKTexture(imageNamed: "Body")
        boardTexture.filteringMode = SKTextureFilteringMode.nearest
        bodyBoard1 = SKSpriteNode(texture: boardTexture) //Sets texture to sprite node
        bodyBoard1.anchorPoint = CGPoint(x: 1.14, y: 5)
        bodyBoard1.zPosition = 1 //Staking order
        bodyBoard1.position = CGPoint(x: frame.width * 0.5, y: background.frame.height * 0.1) //Location on the view
        bodyBoard1.size = CGSize(width: 588, height: 109)
        
        addChild(bodyBoard1) //Add to scene
        
        createBottomBoardCover(height: -130, zPosition: 2)
        
        
    }
    
    func createBodyBoard2()
    {
        let boardTexture = SKTexture(imageNamed: "Body")
        boardTexture.filteringMode = SKTextureFilteringMode.nearest
        bodyBoard2 = SKSpriteNode(texture: boardTexture) //Sets texture to sprite node
        bodyBoard2.anchorPoint = CGPoint(x: 1.14, y: 5)
        bodyBoard2.zPosition = 3 //Staking order
        bodyBoard2.position = CGPoint(x: frame.width * 0.5, y: background.frame.height * 0.1 + 70) //Location on the view
        bodyBoard2.size = CGSize(width: 588, height: 109)
        
        addChild(bodyBoard2) //Add to scene
    }
    
    func createBodyBoard3()
    {
        let boardTexture = SKTexture(imageNamed: "Body")
        boardTexture.filteringMode = SKTextureFilteringMode.nearest
        bodyBoard3 = SKSpriteNode(texture: boardTexture) //Sets texture to sprite node
        bodyBoard3.anchorPoint = CGPoint(x: 1.14, y: 5)
        bodyBoard3.zPosition = 5 //Staking order
        bodyBoard3.position = CGPoint(x: frame.width * 0.5, y: background.frame.height * 0.1 + 140) //Location on the view
        bodyBoard3.size = CGSize(width: 588, height: 109)
        
        addChild(bodyBoard3) //Add to scene
    }
    
    func createBodyBoard4()
    {
        let boardTexture = SKTexture(imageNamed: "Body")
        boardTexture.filteringMode = SKTextureFilteringMode.nearest
        bodyBoard4 = SKSpriteNode(texture: boardTexture) //Sets texture to sprite node
        bodyBoard4.anchorPoint = CGPoint(x: 1.14, y: 5)
        bodyBoard4.zPosition = 7 //Staking order
        bodyBoard4.position = CGPoint(x: frame.width * 0.5, y: background.frame.height * 0.1 + 210) //Location on the view
        bodyBoard4.size = CGSize(width: 588, height: 109)
        
        addChild(bodyBoard4) //Add to scene
    }
    
    func createRoof1()
    {
        let roofTexture = SKTexture(imageNamed: "roof1")
        roofTexture.filteringMode = SKTextureFilteringMode.nearest
        roof1 = SKSpriteNode(texture: roofTexture) //Sets texture to sprite node
        roof1.anchorPoint = CGPoint(x: 1.14, y: 6.98)
        roof1.zPosition = 9 //Staking order
        roof1.position = CGPoint(x: frame.width * 0.5, y: background.frame.height * 0.1 + 280) //Location on the view
        roof1.size = CGSize(width: 588, height: 78)
        
        addChild(roof1) //Add to scene
    }
    
    func createRoof2()
    {
        let roofTexture = SKTexture(imageNamed: "roof2")
        roofTexture.filteringMode = SKTextureFilteringMode.nearest
        roof2 = SKSpriteNode(texture: roofTexture) //Sets texture to sprite node
        roof2.anchorPoint = CGPoint(x: 1.44, y: 7.216)
        roof2.zPosition = 11 //Staking order
        roof2.position = CGPoint(x: frame.width * 0.5, y: background.frame.height * 0.1 + 350) //Location on the view
        roof2.size = CGSize(width: 399, height: 78)
        
        addChild(roof2) //Add to scene
    }
    
    func createRoof3()
    {
        let roofTexture = SKTexture(imageNamed: "roof3")
        roofTexture.filteringMode = SKTextureFilteringMode.nearest
        roof3 = SKSpriteNode(texture: roofTexture) //Sets texture to sprite node
        roof3.anchorPoint = CGPoint(x: 1.867, y: 7.44)
        roof3.zPosition = 13 //Staking order
        roof3.position = CGPoint(x: frame.width * 0.5, y: background.frame.height * 0.1 + 420) //Location on the view
        roof3.size = CGSize(width: 274, height: 78)
        
        addChild(roof3) //Add to scene
    }
    
    func createRoof4()
    {
        let roofTexture = SKTexture(imageNamed: "roof4")
        roofTexture.filteringMode = SKTextureFilteringMode.nearest
        roof4 = SKSpriteNode(texture: roofTexture) //Sets texture to sprite node
        roof4.anchorPoint = CGPoint(x: 2.489, y: 10.88)
        roof4.zPosition = 15 //Staking order
        roof4.position = CGPoint(x: frame.width * 0.5, y: background.frame.height * 0.1 + 490) //Location on the view
        roof4.size = CGSize(width: 189.04, height: 55)
        
        addChild(roof4) //Add to scene
    }
    
    func createRoofTop()
    {
        let roofTopTexture = SKTexture(imageNamed: "roofTop")
        roofTopTexture.filteringMode = SKTextureFilteringMode.nearest
        roofTop = SKSpriteNode(texture: roofTopTexture) //Sets texture to sprite node
        roofTop.anchorPoint = CGPoint(x: 1.12, y: 2.97)
        roofTop.zPosition = 17 //Staking order
        roofTop.position = CGPoint(x: frame.width * 0.5, y: background.frame.height * 0.1 + 560) //Location on the view
        roofTop.size = CGSize(width: 604, height: 278)
        
        addChild(roofTop) //Add to scene
    }
    
    
    func createShadowNail1(xOffset : CGFloat, yOffset : CGFloat, image : String, layer : CGFloat)
    {
        let nailShadowTexture = SKTexture(imageNamed: image)
        nailShadowTexture.filteringMode = SKTextureFilteringMode.nearest
        shadow1 = SKSpriteNode(texture: nailShadowTexture) //Sets texture to sprite node
        shadow1.anchorPoint = CGPoint(x: 9.65, y: 4.9)
        shadow1.zPosition = layer //Staking order
        shadow1.position = CGPoint(x: frame.width * 0.5 + xOffset, y: background.frame.height * 0.1 + yOffset) //Location on the view
        shadow1.size = CGSize(width: 41, height: 89)
        
        addChild(shadow1) //Add to scene
        
    }
    
    func createShadowNail2(xOffset : CGFloat, yOffset : CGFloat, image : String, layer : CGFloat)
    {
        let nailShadowTexture = SKTexture(imageNamed: image)
        nailShadowTexture.filteringMode = SKTextureFilteringMode.nearest
        shadow2 = SKSpriteNode(texture: nailShadowTexture) //Sets texture to sprite node
        shadow2.anchorPoint = CGPoint(x: 9.65, y: 4.9)
        shadow2.zPosition = layer //Staking order
        shadow2.position = CGPoint(x: frame.width * 0.5 + xOffset, y: background.frame.height * 0.1 + yOffset) //Location on the view
        shadow2.size = CGSize(width: 41, height: 89)
        
        addChild(shadow2) //Add to scene
        
    }
    
    func createShadowNail3(xOffset : CGFloat, yOffset : CGFloat, image : String, layer : CGFloat)
    {
        let nailShadowTexture = SKTexture(imageNamed: image)
        nailShadowTexture.filteringMode = SKTextureFilteringMode.nearest
        shadow3 = SKSpriteNode(texture: nailShadowTexture) //Sets texture to sprite node
        shadow3.anchorPoint = CGPoint(x: 9.65, y: 4.9)
        shadow3.zPosition = layer //Staking order
        shadow3.position = CGPoint(x: frame.width * 0.5 + xOffset, y: background.frame.height * 0.1 + yOffset) //Location on the view
        shadow3.size = CGSize(width: 41, height: 89)
        
        addChild(shadow3) //Add to scene
        
    }
    
    func createShadowNail4(xOffset : CGFloat, yOffset : CGFloat, image : String, layer : CGFloat)
    {
        let nailShadowTexture = SKTexture(imageNamed: image)
        nailShadowTexture.filteringMode = SKTextureFilteringMode.nearest
        shadow4 = SKSpriteNode(texture: nailShadowTexture) //Sets texture to sprite node
        shadow4.anchorPoint = CGPoint(x: 9.65, y: 4.9)
        shadow4.zPosition = layer //Staking order
        shadow4.position = CGPoint(x: frame.width * 0.5 + xOffset, y: background.frame.height * 0.1 + yOffset) //Location on the view
        shadow4.size = CGSize(width: 41, height: 89)
        
        addChild(shadow4) //Add to scene
        
    }
    
    func createShadowNail5(xOffset : CGFloat, yOffset : CGFloat, image : String, layer : CGFloat)
    {
        let nailShadowTexture = SKTexture(imageNamed: image)
        nailShadowTexture.filteringMode = SKTextureFilteringMode.nearest
        shadow5 = SKSpriteNode(texture: nailShadowTexture) //Sets texture to sprite node
        shadow5.anchorPoint = CGPoint(x: 9.65, y: 4.9)
        shadow5.zPosition = layer //Staking order
        shadow5.position = CGPoint(x: frame.width * 0.5 + xOffset, y: background.frame.height * 0.1 + yOffset) //Location on the view
        shadow5.size = CGSize(width: 41, height: 89)
        
        addChild(shadow5) //Add to scene
        
    }
    
    func createNail()
    {
        let nailTexture = SKTexture(imageNamed: "nail")
        nailTexture.filteringMode = SKTextureFilteringMode.nearest
        nail = SKSpriteNode(texture: nailTexture) //Sets texture to sprite node
        nail.anchorPoint = CGPoint(x: 9.65, y: 4.9)
        nail.zPosition = 10 //Staking order
        nail.position = CGPoint(x: frame.width * 0.95, y: background.frame.height * 0.1) //Location on the view
        nail.size = CGSize(width: 41, height: 89)
        
        addChild(nail) //Add to scene
        
    }
    
    func createBottomBoardCover(height : CGFloat, zPosition: CGFloat) //height = bottom bord # height - 130
    {
        let bottomTexture = SKTexture(imageNamed: "boardBottom")
        bottomTexture.filteringMode = SKTextureFilteringMode.nearest
        boardBottom = SKSpriteNode(texture: bottomTexture) //Sets texture to sprite node
        boardBottom.anchorPoint = CGPoint(x: 1.14, y: 5)
        boardBottom.zPosition = CGFloat(zPosition) //Staking order
        boardBottom.position = CGPoint(x: frame.width * 0.5, y: background.frame.height * 0.1 + height) //Location on the view
        boardBottom.size = CGSize(width: 588, height: 83)
        
        addChild(boardBottom) //Add to scene
        

    }
    
    func createRoofCover1() //height = bottom bord # height - 130
    {
        let bottomTexture = SKTexture(imageNamed: "roofBottom1")
        bottomTexture.filteringMode = SKTextureFilteringMode.nearest
        roofBottom1 = SKSpriteNode(texture: bottomTexture) //Sets texture to sprite node
        roofBottom1.anchorPoint = CGPoint(x: 1.14, y: 5)
        roofBottom1.zPosition = 10 //Staking order
        roofBottom1.position = CGPoint(x: frame.width * 0.5, y: background.frame.height * 0.1 + 35) //Location on the view
        roofBottom1.size = CGSize(width: 588, height: 60)
        
        addChild(roofBottom1) //Add to scene
        
        
    }
    
    func createRoofCover2() //height = bottom bord # height - 130
    {
        let bottomTexture = SKTexture(imageNamed: "roofBottm2")
        bottomTexture.filteringMode = SKTextureFilteringMode.nearest
        roofBottom2 = SKSpriteNode(texture: bottomTexture) //Sets texture to sprite node
        roofBottom2.anchorPoint = CGPoint(x: 1.439, y: 5)
        roofBottom2.zPosition = 12 //Staking order
        roofBottom2.position = CGPoint(x: frame.width * 0.5, y: background.frame.height * 0.1 + 92.5) //Location on the view
        roofBottom2.size = CGSize(width: 399, height: 61)
        
        addChild(roofBottom2) //Add to scene
        
        
    }
    
    func createRoofCover3() //height = bottom bord # height - 130
    {
        let bottomTexture = SKTexture(imageNamed: "roofBottom3")
        bottomTexture.filteringMode = SKTextureFilteringMode.nearest
        roofBottom3 = SKSpriteNode(texture: bottomTexture) //Sets texture to sprite node
        roofBottom3.anchorPoint = CGPoint(x: 1.87, y: 5)
        roofBottom3.zPosition = 14 //Staking order
        roofBottom3.position = CGPoint(x: frame.width * 0.5, y: background.frame.height * 0.1 + 145) //Location on the view
        roofBottom3.size = CGSize(width: 274, height: 61)
        
        addChild(roofBottom3) //Add to scene
        
        
    }
    
    func createRoofCover4() //height = bottom bord # height - 130
    {
        let bottomTexture = SKTexture(imageNamed: "roofBottom4")
        bottomTexture.filteringMode = SKTextureFilteringMode.nearest
        roofBottom4 = SKSpriteNode(texture: bottomTexture) //Sets texture to sprite node
        roofBottom4.anchorPoint = CGPoint(x: 2.49, y: 5)
        roofBottom4.zPosition = 16 //Staking order
        roofBottom4.position = CGPoint(x: frame.width * 0.5, y: background.frame.height * 0.1 + 102) //Location on the view
        roofBottom4.size = CGSize(width: 189, height: 42)
        
        addChild(roofBottom4) //Add to scene
        
        
    }



}
