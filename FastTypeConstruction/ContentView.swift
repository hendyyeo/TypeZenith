//
//  ContentView.swift
//  ContentView
//
//  Created by Hendy Rusnanto on 06/02/24.
//  please run on real device / simulator not on canvas

import UIKit
import SwiftUI
import AVFoundation



//MARK: Sentences Model
struct Sentence {
    let text: String
}



//MARK: BuildingBlocks Model
struct Block: View {
    let imageName: String
    let size: CGSize
    let blockHeight: CGFloat
    let totalHeight: CGFloat
    let index: Int
    let blockScaleFactor: CGFloat // control blocks scaling
    
    var body: some View {
        Image(imageName)
            .resizable()
            .scaledToFit()
            .frame(width: size.width / blockScaleFactor, height: size.height / blockScaleFactor)
        
            .offset(y: totalHeight - CGFloat(index) * blockHeight / blockScaleFactor)
            .transition(.move(edge: .top))
            .animation(.easeInOut(duration: 0.5))
    }
}



//MARK: AudioPlayer
class SoundPlayer {
    var mainMenuPlayer: AVAudioPlayer?
    var effectPlayer: AVAudioPlayer?
    
    //Music that will keep playing nonstop
    func playGameMusic() {
        if let path = Bundle.main.path(forResource: "gameMusic", ofType: "mp3") {
            let url = URL(fileURLWithPath: path)
            do {
                mainMenuPlayer = try AVAudioPlayer(contentsOf: url)
                mainMenuPlayer?.numberOfLoops = -1 // Loop indefinitely
                mainMenuPlayer?.play()
            } catch {
                print("Error: Couldn't load main menu music")
            }
        }
    }
    
    //Sound effect that only play once during certain condition
    func playSoundEffect(soundFileName: String, type: String) {
        if let path = Bundle.main.path(forResource: soundFileName, ofType: type) {
            let url = URL(fileURLWithPath: path)
            do {
                effectPlayer = try AVAudioPlayer(contentsOf: url)
                effectPlayer?.play()
            } catch {
                print("Error: Couldn't load sound effect file")
            }
        }
    }
    
    /*func stopMainMenuMusic() {
     mainMenuPlayer?.stop() //changed mind I like this music, so not gonna switch between mainmenu music & game mode music ehehe
     } */
}



//MARK: MainView
struct ContentView: View {
    // Model State Var to play animation when app run
    @State private var isAnimatingTitle = false
    @State private var isTriangleFalling = false
    @State private var isAnimatingStartButton = false
    @State private var isAnimatingSettingsButton = false
    @State private var isAnimatingAchievementButton = false
    
    // Model State Var to check whether game is running or over
    @State private var isGameRunning = false
    @State private var gameOver = false
    
    // Model State Var to check whether settingBottomSheet is displaying or no
    @State private var isSettingsSheetPresented = false
    @State private var isSettingsSheetSound = false
    
    // Model State Var to check whether achievementBottomSheet is displaying or no
    @State private var isAchievementSheetPresented = false
    @State private var achievedAchievements: [String] = [] // unlocked achievements tracker
    
    // Model State Var to check when to display quitgame Popup
    @State private var showQuitConfirmation = false
    
    // Model State Var to choose background index to display when startgame
    @State private var backgroundRandomIndex: Int
    
    // Model State variable to keep track of the initial block used
    @State private var initialBlockUsed: String?
    @State private var initialBlockDropped = false
    
    // Model State Var to show which index of sentenceArray to show
    @State private var currentSentenceIndex = 0
    @State private var userInput = "" // user match this with currentSentence
    @State private var accuracy: Double = 0.0 //track user input's Accuracy
    
    
    // Model State Var to track combo & play their animation
    @State private var comboCount = 0
    @State private var isAnimatingCombo1 = false
    @State private var isAnimatingCombo2 = false
    @State private var isAnimatingCombo3 = false
    @State private var isAnimatingCombo4 = false
    
    // Model State Var to track and store score
    @State private var towerBlocks: [(Sentence, CGFloat)] = []
    @State private var score = 0
    @State private var totalScore = 0
    @State private var highScore = UserDefaults.standard.integer(forKey: "highScore")
    @State private var isHighScoreVisible = true
    
    // Model State Var to set, pause & start the time countdown
    @State private var countdownTime = 60
    @State private var countdownValue = 60
    @State private var isCountdownPaused = false
    
    // Model State to set when to display news
    @State private var futureDevelopmentNews = false
    
    //Call AudioPlayer's Struct
    let soundPlayer = SoundPlayer()
    
    //Set Timer
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    
    // Set random GameBackGround's Array
    let iphoneGameBackgrounds = ["iphone_background1", "iphone_background2"]
    let ipadGameBackgrounds = ["ipad_background1", "ipad_background2"]
    init() {
        // Initialize randomIndex with a random value within the range of the backgrounds array
        _backgroundRandomIndex = State(initialValue: Int.random(in: 0..<2))
    }
    
    // Define an array to hold the possible initial blocks
    let initialBlocks = ["initialBlock1", "initialBlock2", "initialBlock3", "initialBlock4", "initialBlock5", "initialBlock6", "initialBlock7"]
    // Define an array to hold the building blocks
    let buildingBlocks = ["Building1", "Building2", "Building3", "Building4", "Building5", "Building6", "Building7"]
    // Define an array to hold the building ascenssion
    let ascendToIntermediet = ["ascendToIntermediet1", "ascendToIntermediet2", "ascendToIntermediet3", "ascendToIntermediet4", "ascendToIntermediet5", "ascendToIntermediet6", "ascendToIntermediet7"]
    // Define an array to hold the building ascenssion
    let ascendToAdvance = ["ascendToAdvance1", "ascendToAdvance2", "ascendToAdvance3", "ascendToAdvance4", "ascendToAdvance5", "ascendToAdvance6", "ascendToAdvance7"]
    // Define an array to hold the building ascenssion
    let ascendToPro = ["ascendToPro1", "ascendToPro2", "ascendToPro3", "ascendToPro4", "ascendToPro5", "ascendToPro6", "ascendToPro7"]
    // Define an array to hold the building ascenssion
    let ascendToElite = ["ascendToElite1", "ascendToElite2", "ascendToElite3", "ascendToElite4", "ascendToElite5", "ascendToElite6", "ascendToElite7"]
    // Define an array to hold the building ascenssion
    let ascendToMaster = ["ascendToMaster1", "ascendToMaster2", "ascendToMaster3", "ascendToMaster4", "ascendToMaster5", "ascendToMaster6", "ascendToMaster7"]
    
    //List of Sentences Model
    let sentences = [
        Sentence(text: "Banana yum"),
        Sentence(text: "Tree swing"),
        Sentence(text: "Ooh ooh ah"),
        Sentence(text: "Typing monkey"),
        Sentence(text: "Coconuts fall"),
        Sentence(text: "Jungle fun"),
        Sentence(text: "Monkey business"),
        Sentence(text: "Vine swinging"),
        Sentence(text: "Chatter chatter"),
        Sentence(text: "Nut cracking"),
        Sentence(text: "Jungle beat"),
        Sentence(text: "Typewriter clack"),
        Sentence(text: "Fuzzy tail"),
        Sentence(text: "Branch balancing"),
        Sentence(text: "Leaf munching"),
        Sentence(text: "Coconut bash"),
        Sentence(text: "Wild adventure"),
        Sentence(text: "Tarzan yell"),
        Sentence(text: "Hanging around"),
        Sentence(text: "Paw prints"),
        Sentence(text: "Jungle boogie"),
        Sentence(text: "Barrel roll"),
        Sentence(text: "Forest frolic"),
        Sentence(text: "Vine dance"),
        Sentence(text: "Coconut treat"),
        Sentence(text: "Banana peel"),
        Sentence(text: "Chimpanzee dance"),
        Sentence(text: "Curious George"),
        Sentence(text: "Jungle gym"),
        Sentence(text: "Baboon butt"),
        Sentence(text: "Primate play"),
        Sentence(text: "Coconut juice"),
        Sentence(text: "Palm tree sway"),
        Sentence(text: "Swing high"),
        Sentence(text: "Monkey see"),
        Sentence(text: "Monkey do"),
        Sentence(text: "Jungle fever"),
        Sentence(text: "Coconut snack"),
        Sentence(text: "Swinging tails"),
        Sentence(text: "Tarzans jungle"),
        Sentence(text: "Leafy greens"),
        Sentence(text: "Primate party"),
        Sentence(text: "Banana split"),
        Sentence(text: "Treehouse fun"),
        Sentence(text: "Hooting monkeys"),
        Sentence(text: "Jungle rhythm"),
        Sentence(text: "Banana bunch"),
        Sentence(text: "Monkey magic"),
        Sentence(text: "Coconut milk"),
        Sentence(text: "Furry friends"),
        Sentence(text: "Tropical delight"),
        Sentence(text: "Monkey madness"),
        Sentence(text: "Jungle sounds"),
        Sentence(text: "Leaf canopy"),
        Sentence(text: "Coconut craze"),
        Sentence(text: "Climbing high"),
        Sentence(text: "Primate power"),
        Sentence(text: "Banana bread"),
        Sentence(text: "Vine surfing"),
        Sentence(text: "Jungle trek"),
        Sentence(text: "Playful primates"),
        Sentence(text: "Coconut shell"),
        Sentence(text: "Swing low"),
        Sentence(text: "Branch break"),
        Sentence(text: "Tarzans call"),
        Sentence(text: "Monkey swing"),
        Sentence(text: "Banana peel slip"),
        Sentence(text: "Forest canopy"),
        Sentence(text: "Coconut cluster"),
        Sentence(text: "Monkey mischief"),
        Sentence(text: "Jungle king"),
        Sentence(text: "Vine twirl"),
        Sentence(text: "Hanging loose"),
        Sentence(text: "Leafy paradise"),
        Sentence(text: "Coconut crunch"),
        Sentence(text: "Swing set"),
        Sentence(text: "Jungle thrills"),
        Sentence(text: "Banana hammock"),
        Sentence(text: "Tarzans roar"),
        Sentence(text: "Monkeying around"),
        Sentence(text: "Tropical paradise"),
        Sentence(text: "Vine swing"),
        Sentence(text: "Coconut paradise"),
        Sentence(text: "Primate paradise"),
        Sentence(text: "Jungle jive"),
        Sentence(text: "Banana boat"),
        Sentence(text: "Monkey jump"),
        Sentence(text: "Jungle joy"),
        Sentence(text: "Vine hop"),
        Sentence(text: "Coconut conundrum"),
        Sentence(text: "Swing time"),
        Sentence(text: "Banana frenzy"),
        Sentence(text: "Tarzanss leap"),
        Sentence(text: "Monkey chatter"),
        Sentence(text: "Jungle escapade"),
        Sentence(text: "Coconut chaos"),
        Sentence(text: "Primate antics"),
        Sentence(text: "Vine dance"),
        Sentence(text: "Banana bash"),
        Sentence(text: "Jungle quest"),
    ]
    
    // Set when to ascending block
    var currentBlocks: [String] {
        return towerBlocks.indices.contains(5) ? ascendToIntermediet : buildingBlocks
    }
    
    
    var body: some View {
        ZStack {
            //Default Background when game is not running
            if !isGameRunning {
                LinearGradient(gradient: Gradient(colors: [.blue, .purple]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
            }
            // Game Mode is running (inside gamePlay)
            if isGameRunning {
                // Game Interface
                ZStack {
                    ScrollView{
                        // Select which random backGround to display for specific apple device model when in GameMode
                        if UIDevice.current.userInterfaceIdiom == .pad {
                            Image(ipadGameBackgrounds[backgroundRandomIndex])
                                .resizable()
                                .edgesIgnoringSafeArea(.all)
                                .scaledToFill()
                        } else {
                            Image(iphoneGameBackgrounds[backgroundRandomIndex])
                                .resizable()
                                .edgesIgnoringSafeArea(.all)
                                .scaledToFill()
                        }
                    }
                    // ForEach loop for tower blocks: block model thats fall from top when user complate the sentence
                    ForEach(towerBlocks.indices, id: \.self) { index in
                        let scaleFactor = CGFloat(min(towerBlocks.count / 5 + 1, 5)) // Determine scale factor
                        Block(imageName: imageName(for: index), size: CGSize(width: 300, height: 150), blockHeight: 150, totalHeight: 300, index: index, blockScaleFactor: scaleFactor)
                            .opacity(0.75)
                            .offset(y: CGFloat(index + (currentSentenceIndex + 50))) // Adjust y-position for each block
                    }
                    VStack {
                        //Quit Game button
                        HStack{
                            Button(action: {
                                showQuitConfirmation = true
                                isCountdownPaused = true
                                isHighScoreVisible = true
                                
                            }) {
                                Image(systemName: "chevron.left")
                                    .foregroundColor(.red)
                                Text("Quit game")
                                    .foregroundColor(.red)
                            }
                            .padding(.top, 5)
                            .padding()
                            Spacer()
                        }
                        
                        HStack {
                            //Show Score in Game
                            Text("Score: \(score)")
                                .font(.headline)
                                .foregroundColor(.white)
                                .opacity(0.5)
                                .padding()
                            Spacer()
                            //Show Tower Height in Game
                            Text("Tower Height: \(towerBlocks.count)")
                                .font(.headline)
                                .foregroundColor(.white)
                                .opacity(0.5)
                                .padding()
                        }
                        .padding(.bottom, 50)
                        
                        //Combo Display Logic
                        if comboCount <= 1 {
                            Text("")
                                .font(.headline)
                                .foregroundColor(.black)
                                .padding()
                        } else if comboCount >= 2 && comboCount <= 5 {
                            
                            Text("Combo: \(comboCount)")
                                .font(.custom("Arial", size: 15))
                                .font(.headline)
                                .foregroundColor(.gray)
                                .padding()
                                .scaleEffect(isAnimatingCombo1 ? 1.5 : 1) // Scale the text when isAnimating is true
                                .rotationEffect(.degrees(isAnimatingCombo1 ? 10 : 0)) // Rotate the text when isAnimating is true
                                .foregroundColor(isAnimatingCombo1 ? .red : .black) // Change text color when isAnimating is true
                                .animation(
                                    Animation
                                        .easeInOut(duration: 0.2)
                                        .repeatCount(3, autoreverses: true) // Repeat the animation 3 times
                                )
                                .onAppear {
                                    isAnimatingCombo1 = true
                                }
                        } else if comboCount >= 6 && comboCount <= 10 {
                            
                            Text("Combo: \(comboCount)")
                                .font(.custom("Times New Roman", size: 25))
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                                .padding()
                                .scaleEffect(isAnimatingCombo2 ? 1.2 : 1) // Scale the text when isAnimating is true
                                .rotationEffect(.degrees(isAnimatingCombo2 ? -20 : 0)) // Rotate the text when isAnimating is true
                                .opacity(isAnimatingCombo2 ? 0.5 : 1) // Reduce opacity when isAnimating is true
                                .foregroundColor(isAnimatingCombo2 ? .red : .black) // Change text color when isAnimating is true
                                .animation(
                                    Animation
                                        .easeInOut(duration: 0.4)
                                        .repeatCount(3, autoreverses: true) // Repeat the animation 3 times
                                )
                                .onAppear {
                                    isAnimatingCombo2 = true
                                }
                            
                        } else if comboCount >= 11 && comboCount <= 15 {
                            
                            Text("Combo: \(comboCount)")
                                .font(.custom("Phosphate", size: 35))
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding()
                                .scaleEffect(isAnimatingCombo3 ? 1.5 : 1) // Scale the text when isAnimating is true
                                .rotationEffect(.degrees(isAnimatingCombo3 ? 360 : 0)) // Rotate the text when isAnimating is true
                                .opacity(isAnimatingCombo3 ? 0.1 : 1) // Reduce opacity when isAnimating is true
                                .foregroundColor(isAnimatingCombo3 ? .blue : .black) // Change text color when isAnimating is true
                                .animation(
                                    Animation
                                        .interpolatingSpring(stiffness: 200, damping: 5)
                                        .repeatCount(3, autoreverses: true) // Repeat the animation 3 times
                                )
                                .onAppear {
                                    isAnimatingCombo3 = true
                                }
                            
                        } else {
                            Text("Combo: \(comboCount)")
                                .font(.custom("Zapfino", size: 35))
                                .rainbow()
                                .font(.title)
                                .fontWeight(.bold)
                                .padding()
                                .scaleEffect(isAnimatingCombo4 ? 1.5 : 1) // Scale the text when isAnimating is true
                                .rotationEffect(.degrees(isAnimatingCombo4 ? 10 : 0)) // Rotate the text when isAnimating is true
                                .opacity(isAnimatingCombo4 ? 0.1 : 1) // Reduce opacity when isAnimating is true
                                .foregroundColor(isAnimatingCombo4 ? .blue : .black) // Change text color when isAnimating is true
                                .animation(
                                    Animation
                                        .easeInOut(duration: 3.0) // Adjust the duration to make it slower
                                        .repeatForever(autoreverses: true) // Repeat the animation forever
                                )
                                .onAppear {
                                    isAnimatingCombo4 = true
                                }
                            
                        }
                        
                        HStack {
                            // Countdown Timer image display in Game Mode
                            HStack(spacing: -0.15) {
                                if countdownTime > countdownValue * 50/100 {
                                    Image(systemName: "clock.arrow.circlepath")
                                        .foregroundColor(.green)
                                        .opacity(0.75)
                                        .fontWeight(.bold)
                                } else if countdownTime <= countdownValue * 50/100 && countdownTime > countdownValue * 10/100 {
                                    Image(systemName: "alarm")
                                        .foregroundColor(.yellow)
                                        .opacity(0.75)
                                        .fontWeight(.bold)
                                } else if countdownTime <= countdownValue * 10/100 {
                                    Image(systemName: "alarm.waves.left.and.right")
                                        .foregroundColor(.red)
                                        .opacity(0.75)
                                        .fontWeight(.bold)
                                }
                                // Countdown Timer  display in Game Mode
                                Text("Time: \(countdownTime)")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                    .opacity(0.5)
                            }
                            .padding()
                            
                            Spacer()
                            //Accuracy Display in Game Mode
                            VStack(spacing: -1.3) {
                                HStack(spacing: -0.5) {
                                    Image(systemName: "scope")
                                        .foregroundColor(.black)
                                        .opacity(0.5)
                                    Text("Accuracy: ")
                                        .font(.headline)
                                        .foregroundColor(.black)
                                        .opacity(0.5)
                                        .padding(.trailing)
                                }
                                
                                AccuracyBar(BarData: (accuracy * 100, specifier: "%.2f"))
                                    .padding(.trailing)
                            }
                            
                        }
                        .padding(.top, 50)
                        
                        //Sentence Display in game Mode
                        HStack(spacing: 0) {
                            ForEach(Array(sentences[currentSentenceIndex].text.enumerated()), id: \.offset) { index, character in
                                let typedCharacter: String = {
                                    guard index < userInput.count else {
                                        return " "
                                    }
                                    return String(userInput[userInput.index(userInput.startIndex, offsetBy: index)])
                                }()
                                
                                let textColor: Color = {
                                    guard index < userInput.count else {
                                        return .white
                                    }
                                    if typedCharacter == String(character) {
                                        return .green
                                    } else {
                                        return .red
                                    }
                                }()
                                
                                Text(String(character))
                                    .font(.title)
                                    .foregroundColor(textColor)
                            }
                            
                        }
                        
                        //User input(TextField) Display in Game Mode
                        TextField("Type here", text: $userInput)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding()
                            .background(Color.clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.black, lineWidth: 1) // Add black border
                            )
                            .foregroundColor(.white)
                            .padding(.horizontal)
                            .onChange(of: userInput) { newValue in
                                checkInput()
                                if newValue.count == sentences[currentSentenceIndex].text.count && newValue == sentences[currentSentenceIndex].text {
                                    moveToNextSentence()
                                }
                            }
                        Spacer()
                    }
                }
                .padding(.top, 35)
                .opacity(gameOver ? 0.5 : 1.0)
                //Show quitGame Alert
                .alert(isPresented: $showQuitConfirmation) {
                    Alert(title: Text("Quit Game"), message: Text("Are you sure you want to quit the game? your current progress will be gone."), primaryButton: .default(Text("Yes")) {
                        replayGame() //when tap "yess" =  quit Game &  reset all data
                    }, secondaryButton: .cancel {
                        // pause countdown when quitGame popup appear, If the user cancels, resume the countdown
                        isCountdownPaused = false
                    })
                }
                
                .padding(.top, -50)
            } else if gameOver {
                // Game Over UI
                VStack {
                    // Display Total Score = FinalScore + Final Tower Height
                    Text("Total Score: \(totalScore)")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .padding()
                        .padding(.top)
                    
                    Spacer()
                    // Logical what to Display during specific condition
                    if totalScore > highScore {
                        Text("🎊Congratulations🎉")
                        Text("You make a new highscore")
                        Image("Champion")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 150, height: 150, alignment: .center)
                        Text("What a mighty TypeZenith Champion")
                    } else if totalScore == highScore {
                        Image("Champion")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 150, height: 150, alignment: .center)
                        Text("What a mighty TypeZenith Champion")
                        
                    } else if totalScore > (highScore - (5%highScore)) {
                        Text("Congrats for being one of")
                        Text("TypeZenith's Legend")
                        Image("Legendary")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 150, height: 150, alignment: .center)
                        Text("Almost beat the Champion")
                    } else if totalScore > (highScore - (15%highScore)) {
                        Text("What a trully TypeZenith's Warrior")
                        Image("Warrior")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 150, height: 150, alignment: .center)
                        Text("Keep going, you're close to be a Legend")
                    } else if totalScore > (highScore - (30%highScore)) {
                        Text("New Born future's Champion")
                        Text("Keep going, we all know that you are the choosen one")
                    } else if totalScore > (highScore - (50%highScore)) {
                        Text("The Great First Step, Keep going ^^")
                    } else if totalScore > (highScore - (75%highScore)) {
                        Text("play more game to improve your skill")
                    } else {
                        Text("You not even trying -_-")
                    }
                    
                    Spacer()
                    
                    Text("Tap anywhere to go back to starting screen")
                        .foregroundColor(.white)
                        .padding()
                }
                .onTapGesture {
                    replayGame() //when tap anywhere during gameOver screen = back to mainscreen & all data reset
                }
                .onAppear {
                    // when current totalscore > highscore = play this audioplayer (during GameOver Screen)
                    if totalScore > highScore {
                        soundPlayer.playSoundEffect(soundFileName: "highScore", type: "mp3")
                    }
                }
            } else {
                // Starting/Main Screen & Replay Screen
                VStack {
                    //MainScreen Title Display
                    Text("TypeZenith")
                        .font(.title)
                        .rainbow()
                        .opacity(isAnimatingTitle ? 1 : 0) // Initially invisible
                        .animation(.easeInOut(duration: 1.75).delay(2)) // Delayed animation
                        .onAppear {
                            isAnimatingTitle = true
                        }
                    //MainSnreen Neon High Score Display (with Animation)
                    Text("High Score: \(highScore)")
                        .font(.headline)
                        .addGlowEffect(color1: Color(Color.RGBColorSpace.sRGB, red: 96/255, green: 252/255, blue: 255/255, opacity: 1), color2: Color(Color.RGBColorSpace.sRGB, red: 44/255, green: 158/255, blue: 238/255, opacity: 1), color3: Color(Color.RGBColorSpace.sRGB, red: 0/255, green: 129/255, blue: 255/255, opacity: 1))
                        .opacity(isHighScoreVisible ? 0 : 0.7)
                        .padding()
                        .onAppear {
                            // Blink animation for high score
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                withAnimation(Animation.easeInOut(duration: 0.5).repeatCount(5)) {
                                    isHighScoreVisible.toggle()
                                }
                            }
                        }
                    Spacer()
                    
                    VStack {
                        Spacer()
                        // Roof top / Triangle (Animation)
                        TriangleView(color: .red, size: CGSize(width: 50, height: 50), blockScaleFactor: 1)
                            .offset(y: isTriangleFalling ? 0 : -300) // Start the triangle off-screen
                            .onAppear {
                                // Trigger the triangle animation when the game starts
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                    withAnimation {
                                        isTriangleFalling = true
                                    }
                                }
                            }
                        //Button to start Game (onAppear withAnimation)
                        Button("Start", action: {
                            startGame()
                            soundPlayer.playSoundEffect(soundFileName: "startGame", type: "mp3")
                        })
                        .buttonStyle(GameButtonStyle(color: .green))
                        .padding()
                        .offset(y: isAnimatingStartButton ? 0 : -200) // Start button offset
                        .animation(.easeInOut(duration: 1.0).delay(0.6))
                        .onAppear {
                            isAnimatingStartButton = true // Trigger animation
                        }
                        //Button to open Settings (onAppear withAnimation)
                        Button("Settings", action: {
                            isSettingsSheetPresented.toggle()
                            soundPlayer.playSoundEffect(soundFileName: "openMenu", type: "mp3")
                            isSettingsSheetSound = true
                        })
                        .buttonStyle(GameButtonStyle(color: .orange))
                        .padding()
                        .offset(y: isAnimatingSettingsButton ? 0 : -100) // Settings button offset
                        .animation(.easeInOut(duration: 1.0).delay(0.3))
                        .onAppear {
                            isAnimatingSettingsButton = true // Trigger animation
                        }
                        .sheet(isPresented: $isSettingsSheetPresented, content: {
                            SettingsBottomSheet(countdownValue: $countdownValue, countdownTime: $countdownTime, isSettingsSheetPresented: $isSettingsSheetPresented, isSettingSheetSound: $isSettingsSheetSound)
                                .frame(height: 50)
                                .onDisappear {
                                    if isSettingsSheetSound == true {
                                        soundPlayer.playSoundEffect(soundFileName: "closeMenu", type: "mp3")
                                    }
                                }
                        })
                        //Button to open Achievement (onAppear withAnimation)
                        Button("Achievements", action: {
                            toggleBottomSheet()
                            soundPlayer.playSoundEffect(soundFileName: "openMenu", type: "mp3")
                        })
                        .buttonStyle(GameButtonStyle(color: .red))
                        .padding()
                        .offset(y: isAnimatingAchievementButton ? 0 : -50) // Exit button offset
                        .animation(.easeInOut(duration: 1.0))
                        .onAppear {
                            isAnimatingAchievementButton = true // Trigger animation
                        }
                        .sheet(isPresented: $isAchievementSheetPresented) {
                            AchievementSheetView(totalScore: $totalScore, comboCount: $comboCount)
                                .onDisappear {
                                    soundPlayer.playSoundEffect(soundFileName: "closeMenu", type: "mp3")
                                }
                        }
                        
                        
                        Spacer()
                    }
                    Spacer()
                    HStack {
                        Text("Version 0.3 Beta")
                        Spacer()
                        Button(action: {
                            futureDevelopmentNews = true
                            soundPlayer.playSoundEffect(soundFileName: "openNews", type: "mp3")
                        }) {
                            Image(systemName: "questionmark.circle")
                                .foregroundColor(.yellow)
                            Text("Whats new?")
                                .foregroundColor(.yellow)
                                .underline(true, color: .yellow)
                        }
                    }
                    .padding(.leading)
                    .padding(.trailing)
                    .sheet(isPresented: $futureDevelopmentNews, content: {
                        BottomSheetView()
                            .onDisappear {
                                soundPlayer.playSoundEffect(soundFileName: "closeNews", type: "mp3")
                            }
                    })
                }
                
            }
        }
        .onReceive(timer) { _ in
            updateCountdown()
        }
        
        .onAppear {
            // Code that auto run when app Open
            dropInitialBlock()
            comboCount = 0
            achievedAchievements = []
            soundPlayer.playGameMusic()
        }
        .onTapGesture {
            //Idk why I add this tapHapticFeedback when touch anywhere around the screen ^^
            UISelectionFeedbackGenerator().selectionChanged()
        }
    }
    
    //MARK: Function to determine the image name for the block at the given index
    func imageName(for index: Int) -> String {
        // If no initial block has been used yet, return a default building block
        guard let initialBlockUsed = initialBlockUsed else {
            return "Building1"
        }
        
        // If the index is 0, it means it's the first block, so return the initial block used
        if index == 0 {
            return initialBlockUsed
        } else {
            // Determine the array to use based on the index of the block
            var blocksArray: [String]
            switch index {
            case 5..<10: // When reaching the 20th block
                blocksArray = ascendToIntermediet
            case 10..<15: // When reaching the 25th block
                blocksArray = ascendToAdvance
            case 15..<20: // When reaching the 30th block
                blocksArray = ascendToPro
            case 20..<25: // When reaching the 35th block or beyond
                blocksArray = ascendToElite
            case 25...: // When reaching the 35th block or beyond
                blocksArray = ascendToMaster
            default:
                blocksArray = buildingBlocks
                
            }
            
            // Get the last digit of the initial block used
            if let lastDigit = initialBlockUsed.last,
               let digit = Int(String(lastDigit)),
               digit >= 1 && digit <= 7 {
                // Use the corresponding block from the array
                return blocksArray[digit - 1] // Adjust to zero-based index
            } else {
                // Default to "Building1" if unable to determine
                return "Building1"
            }
        }
    }
    
    //MARK: Function to drop the initial block
    func dropInitialBlock() {
        // Ensure that the initial block hasn't been dropped yet
        guard !initialBlockDropped else {
            return
        }
        
        // Drop the initial block
        let randomIndex = Int.random(in: 0..<initialBlocks.count)
        initialBlockUsed = initialBlocks[randomIndex]
        
        // Set the flag to indicate that the initial block has been dropped
        initialBlockDropped = true
    }
    
    
    //MARK: Function to toggle the presentation of the bottom sheet (achievement sheet).
    func toggleBottomSheet() {
        isAchievementSheetPresented.toggle() // Toggles the boolean value to present or dismiss the achievement sheet.
    }

    
    //MARK: Function that run when enter GameMode(user tapped Start Button).
    func startGame() {
        // Reset game variables and state
        isGameRunning = true // Set game as running
        gameOver = false // Reset game over state
        
        resetbackgroundRandomIndex() // Reset background image to a random index
        
        initialBlockDropped = false  // Reset initial block flag to allow dropping a new initial block
        dropInitialBlock() // Drop a new initial block for the next game
        
        nextSentence() // Load the next sentence for the game
        accuracy = 0.0 // Reset accuracy
        
        comboCount = 0 // Reset combo count
        
        towerBlocks.removeAll() // Remove all tower blocks from the previous game
        score = 0 // Reset score
        
        isCountdownPaused = false // Resume countdown if paused
        countdownTime = countdownValue // Reset countdown time
    }

    
    //MARK: Function that run when first open app also after tapped anywhere around gameOver Screen.
    func replayGame() {
        // Reset combo animation states
        isAnimatingCombo1 = false
        isAnimatingCombo2 = false
        isAnimatingCombo3 = false
        isAnimatingCombo4 = false
        
        // Reset game states and variables
        isGameRunning = false // Set game as not running
        gameOver = false // Reset game over state
        
        resetbackgroundRandomIndex() // Reset background image to a random index
        
        initialBlockDropped = false  // Reset initial block flag to allow dropping a new initial block
        dropInitialBlock() // Drop a new initial block for the next game
        
        nextSentence() // Load the next sentence for the game
        userInput = "" // Reset user input
        
        towerBlocks.removeAll() // Remove all tower blocks from the previous game
        
        isCountdownPaused = false // Resume countdown if paused
        countdownTime = countdownValue // Reset countdown time
        
        // Update highScore to totalScore if totalScore is greater
        if totalScore > highScore {
            highScore = totalScore
            UserDefaults.standard.set(highScore, forKey: "highScore")
        }
    }
    

    //MARK: Countdown Func
    func updateCountdown() {
        if isGameRunning && countdownTime > 0 && !isCountdownPaused {
            countdownTime -= 1 //keep decrease by 1 when countdown not reach zero yet
            if countdownTime == 0 {
                endGame() //run this func when countdown reach zero
            }
        }
    }
    
    
    //MARK: Sentence random generator
    func nextSentence() {
        // Choose a random index within the range of available sentences
        currentSentenceIndex = Int.random(in: 0..<sentences.count)
    }

    
    //MARK: Completed a sentence Logic handler
    func moveToNextSentence() {
        // Calculate the combo multiplier
        let comboMultiplier = max(comboCount, 1)
        
        // Calculate the score for the completed sentence
        let sentenceScore = comboMultiplier
        
        // Add the score to the total score
        score += sentenceScore
        
        //the total score
        let totalScore = score + towerBlocks.count
        
        // Only append the new block if there isn't one already for the current sentence
        if towerBlocks.last?.0.text != sentences[currentSentenceIndex].text {
            // Append the new block to the tower
            towerBlocks.append((sentences[currentSentenceIndex], -100 - CGFloat(towerBlocks.count) * 60))
        }
        
        // Choose the next sentence
        nextSentence()
        
        // Reset user input for the next sentence
        userInput = ""
        
        // Save the current score
        UserDefaults.standard.set(score, forKey: "score")
        
        //play sound effect when reach combo 16
        if comboCount == 16 {
            soundPlayer.playSoundEffect(soundFileName: "maxCombo", type: "mp3")
        }
    }
    
    
    // MARK: Check User Typing Input
    // Function to validate user input against the target sentence and update game variables accordingly.
    func checkInput() {
        // Retrieve the target sentence and its length
        let targetSentence = sentences[currentSentenceIndex].text
        let targetLength = targetSentence.count
        
        // Guard against empty target sentence
        guard targetLength > 0 else {
            return
        }
        
        var correctCount = 0
        
        // Iterate through user input and check against the target sentence
        for (index, char) in userInput.prefix(targetLength).enumerated() {
            if char == targetSentence[targetSentence.index(targetSentence.startIndex, offsetBy: index)] {
                correctCount += 1
            } else {
                // If there's a mistake, reset the combo count to 0 and exit the loop
                comboCount = 0
                soundPlayer.playSoundEffect(soundFileName: "comboBroken", type: "mp3")
                isAnimatingCombo1 = false
                isAnimatingCombo2 = false
                isAnimatingCombo3 = false
                isAnimatingCombo4 = false
                return
            }
        }
        
        // Calculate accuracy based on correct character count
        accuracy = Double(correctCount) / Double(targetLength)
        
        if userInput.prefix(targetLength) == targetSentence {
            // User input matches the sentence
            score += comboCount + 1 // Increment score based on combo count
            comboCount += 1 // Increment the combo count after completing a sentence without mistakes
            soundPlayer.playSoundEffect(soundFileName: "increaseCombo", type: "mp3") // Play combo sound effect
            
            // Append one block to the tower
            let previousOffset = towerBlocks.last?.1 ?? 0
            towerBlocks.append((sentences[currentSentenceIndex], -100 - CGFloat(towerBlocks.count) * 60))
            
            // Play ascend sound effect at certain tower heights
            if towerBlocks.count == 6 || towerBlocks.count == 11 || towerBlocks.count == 16 || towerBlocks.count == 21 || towerBlocks.count == 26 {
                soundPlayer.playSoundEffect(soundFileName: "ascend", type: "mp3")
            }
            
            // Load the next sentence and reset user input
            nextSentence()
            userInput = ""
            
            // Update and save score if it's higher than the high score
            UserDefaults.standard.set(score, forKey: "score")
            if score > highScore {
                highScore = score
                UserDefaults.standard.set(highScore, forKey: "highScore")
            }
        }
    }

    
    //MARK: when timer reach zero = run this func = gameOver
    func endGame() {
        // Calculate the total score including tower height
        totalScore = score + towerBlocks.count
        
        // Update game state
        isGameRunning = false
        gameOver = true
    }
    
    // Method to reset randomIndex
    private func resetbackgroundRandomIndex() {
        backgroundRandomIndex = Int.random(in: 0..<2)
    }
    
}



//MARK: Custom ButtonStyle for game buttons.
struct GameButtonStyle: ButtonStyle {
    var color: Color // Color for the button
    
    // Create the button's appearance
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding() // Add padding to the button
            .background(configuration.isPressed ? color.opacity(0.8) : color) // Change button's background color when pressed
            .cornerRadius(8) // Apply corner radius to the button
            .foregroundColor(.white) // Set text color to white
    }
}


//MARK: Custom Triangle Shape that will apear and fall during starting app.
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Define the triangle's points
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY)) // Bottom left corner
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY)) // Top center
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY)) // Bottom right corner
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY)) // Bottom left corner (close path)
        
        return path
    }
}



//MARK: Triangle View.
struct TriangleView: View {
    let color: Color // Color of the triangle
    let size: CGSize // Size of the triangle
    let blockScaleFactor: CGFloat // Scale factor for adjusting size
    
    var body: some View {
        Triangle() // Create a triangle shape
            .fill(color) // Fill the triangle with the specified color
            .frame(width: size.width / blockScaleFactor, height: size.height / blockScaleFactor) // Adjust size based on the scale factor
            .overlay(
                Triangle()
                    .stroke(Color.black, lineWidth: 2) // Add stroke to the triangle
            )
            .transition(.move(edge: .top)) // Apply transition effect
            .animation(.easeInOut(duration: 0.7)) // Apply animation
            .modifier(BouncingAnimation()) // Apply bouncing animation modifier
    }
}



//MARK:  Modifier for implementing a bouncing animation effect currently only use for Triangle.
struct BouncingAnimation: ViewModifier {
    @State private var offsetY: CGFloat = 0 // Vertical offset of the view
    @State private var velocityY: Double = 0 // Velocity of the view
    @State private var isFalling = false // Flag to indicate if the view is falling
    @State private var isFirstBounce = false // Flag to indicate the first bounce
    @State private var isSecondBounce = false // Flag to indicate the second bounce
    
    let startBlockHeight: CGFloat = 30 // Height of the start block
    let damping: Double = 0.5 // Damping for the spring animation
    
    // Apply the bouncing animation to the view's content
    func body(content: Content) -> some View {
        content
            .offset(y: offsetY) // Apply vertical offset
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { // Delay to ensure the start block animation is completed
                    withAnimation(Animation.interpolatingSpring(stiffness: 50, damping: damping, initialVelocity: velocityY)) {
                        offsetY = startBlockHeight // Move the view downwards initially
                    }
                    isFalling = true
                }
            }
            .onChange(of: offsetY) { newValue in
                // Perform animation based on current offset value
                if newValue == startBlockHeight && isFalling {
                    isFalling = false
                    isFirstBounce = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation(Animation.interpolatingSpring(stiffness: 50, damping: damping, initialVelocity: velocityY)) {
                            offsetY = -1.5 * startBlockHeight // Move the view upwards for the first bounce
                        }
                    }
                } else if newValue == -1.5 * startBlockHeight && isFirstBounce {
                    isFirstBounce = false
                    isSecondBounce = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation(Animation.interpolatingSpring(stiffness: 50, damping: damping, initialVelocity: velocityY)) {
                            offsetY = 1 * startBlockHeight // Move the view downwards for the second bounce
                        }
                    }
                } else if newValue == 1 * startBlockHeight && isSecondBounce {
                    isSecondBounce = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation(Animation.interpolatingSpring(stiffness: 50, damping: damping, initialVelocity: velocityY)) {
                            offsetY = -0.5 * startBlockHeight // Move the view upwards for the final bounce
                        }
                    }
                } else {
                    // Apply default animation if no specific condition is met
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation(Animation.interpolatingSpring(stiffness: 50, damping: damping, initialVelocity: velocityY)) {
                            offsetY = 0.5 * startBlockHeight // Apply slight upwards motion
                        }
                    }
                }
            }
            .gesture(DragGesture().onChanged { _ in
                velocityY = 0 // Reset velocity
                offsetY = 0 // Reset offset
            })
    }
}



//MARK: Modifier for applying a rainbow color effect to a view currently use for rainbow color text.
struct Rainbow: ViewModifier {
    // Generate an array of colors with varying hues
    let hueColors = stride(from: 0, to: 1, by: 0.01).map {
        Color(hue: $0, saturation: 1, brightness: 1)
    }
    
    // Apply the rainbow effect to the view's content
    func body(content: Content) -> some View {
        content
            .overlay(GeometryReader { (proxy: GeometryProxy) in
                ZStack {
                    // Create a linear gradient with the array of colors
                    LinearGradient(gradient: Gradient(colors: self.hueColors),
                                   startPoint: .leading,
                                   endPoint: .trailing)
                    .frame(width: proxy.size.width) // Match the width of the content
                }
            })
            .mask(content) // Apply the content as a mask
    }
}




//MARK: Accuracy bar with blocks indicating accuracy levels.
struct AccuracyBar: View {
    let BarData: (Double, specifier: String) // Tuple containing accuracy data
    
    var body: some View {
        HStack(alignment: .center, spacing: 1) { // Horizontal stack for blocks with adjusted spacing
            ForEach(0..<8) { index in // Loop to create blocks based on accuracy level
                BlocksOfBar(index: index, BarData: BarData)
            }
        }
        .padding(2) // Padding for border
        .background(Color.black) // Black background for the bar
        .cornerRadius(5) // Rounded corners
        .border(Color.black, width: 1) // Thin black border around the bar
    }
}



//MARK: Individual blocks of accuracy bar.
struct BlocksOfBar: View {
    let index: Int // Index of the block
    let BarData: (Double, specifier: String) // Tuple containing accuracy data
    
    var body: some View {
        let blockColor = self.blockColor() // Determine color of the block
        
        return Rectangle()
            .fill(blockColor) // Fill the rectangle with determined color
            .frame(width: 12, height: 10) // Adjusted size of the block
    }
    
    // Determine color of the block based on index and accuracy data
    private func blockColor() -> Color {
        let blocksOn = self.blocksOn() // Determine the number of blocks to be turned on
        
        switch index {
        case 0..<blocksOn:
            switch Int(BarData.0) {
            case 0: return Color.gray
            case 1..<19: return index == 0 ? Color.red : Color.gray
            case 19..<29: return index < 2 ? Color.red : Color.gray
            case 29..<39: return index < 3 ? Color.red : Color.gray
            case 39..<49: return index < 3 ? Color.yellow : Color.gray
            case 49..<59: return index < 4 ? Color.yellow : Color.gray
            case 59..<69: return index < 5 ? Color.yellow : Color.gray
            case 69..<79: return index < 5 ? Color.green : Color.gray
            case 79..<89: return index < 6 ? Color.green : Color.gray
            case 89..<99: return index < 7 ? Color.green : Color.gray
            case 99..<100: return index < 8 ? Color.green : Color.gray
            default: return Color.green
            }
        default:
            return Color.gray
        }
    }
    
    // Determine the number of blocks to be turned on based on accuracy data
    private func blocksOn() -> Int {
        let blocksOn: Int
        switch Int(BarData.0) {
        case 0: blocksOn = 0
        case 1..<19: blocksOn = 1
        case 19..<29: blocksOn = 2
        case 29..<39: blocksOn = 3
        case 39..<49: blocksOn = 3
        case 49..<59: blocksOn = 4
        case 59..<69: blocksOn = 5
        case 69..<79: blocksOn = 5
        case 79..<89: blocksOn = 6
        case 89..<99: blocksOn = 7
        case 99..<100: blocksOn = 7
        default: blocksOn = 8
        }
        return blocksOn
    }
}



//MARK: Setting BottomSheet Screen Content
struct SettingsBottomSheet: View {
    // Bindings to manage settings state
    @Binding var countdownValue: Int
    @Binding var countdownTime: Int
    @Binding var isSettingsSheetPresented: Bool
    @Binding var isSettingSheetSound: Bool
    
    let soundPlayer = SoundPlayer() // Sound player instance
    
    // Temporary variable to hold the countdown value before applying
    @State private var tempCountdownValue: Int
    
    // Initialize the settings bottom sheet
    init(countdownValue: Binding<Int>, countdownTime: Binding<Int>, isSettingsSheetPresented: Binding<Bool>, isSettingSheetSound: Binding<Bool>) {
        _countdownValue = countdownValue
        _countdownTime = countdownTime
        _isSettingsSheetPresented = isSettingsSheetPresented
        _isSettingSheetSound = isSettingSheetSound
        _tempCountdownValue = State(initialValue: countdownValue.wrappedValue)
    }
    
    var body: some View {
        VStack {
            // Display countdown settings
            if tempCountdownValue < 60 {
                Text("Set Countdown: \(tempCountdownValue) seconds")
                    .font(.headline)
                    .padding()
            } else if tempCountdownValue % 60 == 0 {
                let minutes = tempCountdownValue / 60
                Text("Set Countdown: \(minutes) minute\(minutes > 1 ? "s" : "")")
                    .font(.headline)
                    .padding()
            } else {
                let minutes = tempCountdownValue / 60
                let seconds = tempCountdownValue % 60
                Text("Set Countdown: \(minutes) minute\(minutes > 1 ? "s" : "") \(seconds) seconds")
                    .font(.headline)
                    .padding()
            }
            
            // Adjust countdown settings
            HStack {
                Image(systemName: "arrow.left.circle.fill")
                    .foregroundColor(.blue)
                    .onTapGesture {
                        if tempCountdownValue > 30 {
                            tempCountdownValue -= 1
                        } else {
                            UISelectionFeedbackGenerator().selectionChanged()
                        }
                    }
                
                Slider(value: Binding<Double>(
                    get: { Double(tempCountdownValue) },
                    set: { newValue in
                        tempCountdownValue = Int(newValue)
                        UISelectionFeedbackGenerator().selectionChanged()
                    }
                ), in: 30...300, step: 1)
                .accentColor(.blue)
                
                Image(systemName: "arrow.right.circle.fill")
                    .foregroundColor(.blue)
                    .onTapGesture {
                        if tempCountdownValue < 300 {
                            tempCountdownValue += 1
                        } else {
                            UISelectionFeedbackGenerator().selectionChanged()
                        }
                    }
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            // Apply settings button
            Button("Apply") {
                self.isSettingSheetSound = false
                self.isSettingsSheetPresented = false
                self.countdownTime = self.tempCountdownValue // Update countdownTime
                self.countdownValue = self.tempCountdownValue // Update countdownValue
                soundPlayer.playSoundEffect(soundFileName: "setSetting", type: "mp3") // Play sound effect
            }
            .padding()
        }
        .cornerRadius(16) // Round corners
        .padding() // Add padding
    }
}



//MARK: Achievement Model
struct Achievement: Identifiable, Codable {
    var id = UUID()
    var title: String
    var unlocked: Bool
    var imageName: String
    var description: String
}



//MARK: AchievementView BottomSheet Screen Content
struct AchievementSheetView: View {
    
    @Binding var totalScore: Int
    @Binding var comboCount: Int
    @State private var achievements: [Achievement]
    
    // Initialize AchievementSheetView with bindings for totalScore and comboCount
    init(totalScore: Binding<Int>, comboCount: Binding<Int>) {
        self._totalScore = totalScore
        self._comboCount = comboCount
        
        // Initialize achievements with an empty array
        self._achievements = State(initialValue: [])
    }
    
    var body: some View {
        VStack {
            if achievements.isEmpty {
                // Display message when no achievements are unlocked
                Text("No achievements unlocked")
                    .foregroundColor(.black)
                    .opacity(0.3)
            } else {
                NavigationView {
                    List(achievements) { achievement in
                        VStack(alignment: .leading) {
                            if achievement.unlocked {
                                // Display unlocked achievements
                                HStack {
                                    VStack(alignment: .leading) {
                                        HStack {
                                            Image(systemName: achievement.imageName)
                                                .foregroundColor(.yellow)
                                            Text(achievement.title)
                                                .foregroundColor(.black)
                                                .fontWeight(.bold)
                                        }
                                        
                                        Text(achievement.description)
                                            .font(.footnote)
                                            .foregroundColor(.gray)
                                    }
                                    
                                }
                            } else {
                                // Display locked achievements
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text("???")
                                            .foregroundColor(.black)
                                            .fontWeight(.bold)
                                        
                                        Text(achievement.description)
                                            .font(.footnote)
                                            .foregroundColor(.gray)
                                    }
                                    Spacer()
                                    Image(systemName: "lock.fill")
                                        .frame(alignment: .trailing)
                                }
                                .opacity(0.3)
                            }
                        }
                    }
                    .navigationTitle("Your Achievements")
                    .font(.title)
                    .fontWeight(.bold)
                }
                Spacer()
                // Display message about more achievements under development
                Text("More Achievements under development")
                    .rainbow() // Assuming rainbow() applies a visual effect
                    .opacity(0.5)
            }
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .cornerRadius(20)
        .padding()
        .onAppear {
            // Load achievements from UserDefaults
            self.loadAchievements()
            
            // Check conditions for unlocking achievements for combo count condition
            if self.comboCount >= 3 && !self.achievements[0].unlocked {
                self.achievements[0].unlocked = true
                self.saveAchievements()
            }
            if self.comboCount >= 7 && !self.achievements[1].unlocked {
                self.achievements[1].unlocked = true
                self.saveAchievements()
            }
            if self.comboCount >= 9 && !self.achievements[2].unlocked {
                self.achievements[2].unlocked = true
                self.saveAchievements()
            }
            if self.comboCount > 15 && !self.achievements[3].unlocked {
                self.achievements[3].unlocked = true
                self.saveAchievements()
            }
            
            // Check if totalScore is greater than a certain value for another achievement
            if self.totalScore > 150 && !self.achievements[4].unlocked {
                self.achievements[4].unlocked = true
                self.saveAchievements()
            }
            if self.totalScore > 300 && !self.achievements[5].unlocked {
                self.achievements[5].unlocked = true
                self.saveAchievements()
            }
            if self.totalScore > 500 && !self.achievements[6].unlocked {
                self.achievements[6].unlocked = true
                self.saveAchievements()
            }
            if self.totalScore > 750 && !self.achievements[7].unlocked {
                self.achievements[7].unlocked = true
                self.saveAchievements()
            }
            if self.totalScore > 1000 && !self.achievements[8].unlocked {
                self.achievements[8].unlocked = true
                self.saveAchievements()
            }
            if self.totalScore > 1500 && !self.achievements[9].unlocked {
                self.achievements[9].unlocked = true
                self.saveAchievements()
            }
            
        }
    }
    
    
    //MARK: Func to Load achievements from UserDefaults
    private func loadAchievements() {
        if let data = UserDefaults.standard.data(forKey: "achievements"),
           let decodedAchievements = try? JSONDecoder().decode([Achievement].self, from: data) {
            self.achievements = decodedAchievements
        } else {
            // If no achievements are found, initialize with predefined achievements
            self.achievements = [
                Achievement(title: "The Great First Step", unlocked: false, imageName: "figure.stair.stepper", description: "reach Combo x3 till end game"),
                Achievement(title: "Typing Machine", unlocked: false, imageName: "bag.circle", description: "reach Combo x7 till end game"),
                Achievement(title: "Legendary", unlocked: false, imageName: "bolt.fill", description: "reach Combo x10 till end game"),
                Achievement(title: "God hand", unlocked: false, imageName: "hand.raised.brakesignal", description: "reach Combo x15 till end game"),
                Achievement(title: "Zenith Warrior", unlocked: false, imageName: "shield.checkered", description: "reach more than 150 total score"),
                Achievement(title: "Zenith Elite", unlocked: false, imageName: "medal.fill", description: "reach more than 250 total score"),
                Achievement(title: "Zenith Master", unlocked: false, imageName: "trophy.fill", description: "reach more than 500 total score"),
                Achievement(title: "Zenith Legend", unlocked: false, imageName: "flag.filled.and.flag.crossed", description: "reach more than 750 total score"),
                Achievement(title: "Zenith Champion", unlocked: false, imageName: "crown.fill", description: "reach more than 1000 total score"),
                Achievement(title: "God Like", unlocked: false, imageName: "sparkle", description: "reach more than 1500 total score")
            ]
        }
    }
    
    //MARK: Func to Save achievements to UserDefaults
    private func saveAchievements() {
        if let encodedAchievements = try? JSONEncoder().encode(self.achievements) {
            UserDefaults.standard.set(encodedAchievements, forKey: "achievements")
        }
    }
}
//MARK: AppNews BottomSheet Content
struct BottomSheetView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("On Progress Development")
                .rainbow()
                .font(.title)
                .padding()
                .padding()
                .frame(alignment: .center)
            Text("- Add more sentnce ")
                .foregroundColor(.green)
                .padding()
            Text("- improve design")
                .foregroundColor(.green)
                .padding()
            Text("- Upgrade Tower Animation")
                .foregroundColor(.yellow)
                .padding()
            Text("- Replacement of 'Tower auto size scalling' to 'Tower auto Positioning'")
                .foregroundColor(.yellow)
                .padding()
            Text("- Add 'interactive background' that support the 'tower auto positioning feature' ")
                .foregroundColor(.yellow)
                .padding()
            Text("- More Settings include: Difficulty")
                .foregroundColor(.red)
                .padding()
            Text("- Interactive objects around 'MainScreen' ")
                .foregroundColor(.red)
                .padding()
            Text("- More Achievements")
                .foregroundColor(.red)
                .padding()
            Spacer()
        }
        .padding()
    }
}



//MARK: Extension to add a rainbow effect to any View.
extension View {
    // Function to apply the rainbow effect modifier to a View.
    func rainbow() -> some View {
        self.modifier(Rainbow()) // Apply Rainbow modifier to the View.
    }
}



//MARK: Extension to add a glow effect with multiple colors to any View currently use to highscore at mainscreen.
extension View {
    // Function to apply a glow effect with multiple colors to a View.
    func addGlowEffect(color1: Color, color2: Color, color3: Color) -> some View {
        self
            .foregroundColor(Color(hue: 0.5, saturation: 0.8, brightness: 1)) // Set base color
            .background {
                self
                    .foregroundColor(color1) // Apply first color
                    .blur(radius: 0) // No blur
                    .brightness(0.8) // Adjust brightness
            }
            .background {
                self
                    .foregroundColor(color2) // Apply second color
                    .blur(radius: 4) // Apply blur
                    .brightness(0.35) // Adjust brightness
            }
            .background {
                self
                    .foregroundColor(color3) // Apply third color
                    .blur(radius: 2) // Apply blur
                    .brightness(0.35) // Adjust brightness
            }
            .background {
                self
                    .foregroundColor(color3) // Apply fourth color
                    .blur(radius: 12) // Apply blur
                    .brightness(0.35) // Adjust brightness
            }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
