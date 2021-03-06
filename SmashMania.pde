import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

// Import the minim library for sound effects
import ddf.minim.*;

// Set the size of the window and databar
final int GAME_WIDTH = 800;
final int GAME_HEIGHT = 800;
final int DATABAR_HEIGHT = 50;

// Set player car parameters
int PLAYER_CAR_WIDTH = 30;
int PLAYER_CAR_HEIGHT = 15;
float PLAYER_CAR_BRAKING_POWER = 0.4f;
float PLAYER_CAR_MAX_SPEED = 3f;
float PLAYER_CAR_MAX_ACCELERATION = 0.2f;
float PLAYER_CAR_MAX_STEERING = PI / 64;
float PLAYER_CAR_FRICTION = 0.975f;
float PLAYER_CAR_FRICTION_MULTIPLIER = 0.02f;
int PLAYER_CAR_MAX_LIVES = 3;
int PLAYER_CAR_SAFE_ZONE = 150;

// Set police car parameters
int POLICE_CAR_WIDTH = 30;
int POLICE_CAR_HEIGHT = 15;
float POLICE_CAR_MAX_SPEED = 1f;
float POLICE_CAR_MAX_ACCELERATION = 0.1f;
float POLICE_CAR_VISION_RADIUS = 2 * POLICE_CAR_WIDTH;

// Set human parameters
int HUMAN_SIZE = 10;
float HUMAN_MAX_SPEED = 0.25f;
int HUMAN_SAFE_ZONE = 50;

// Set intial wave parameters
int INITIAL_HUMAN_COUNT = 10;
int INITIAL_POLICE_CAR_COUNT = 3;
float INITIAL_POLICE_CAR_MAX_SPEED = 1f;

// Set grass multipliers
float GRASS_MAX_SPEED_MULTIPLIER = 0.5f;
float GRASS_FRICTION_MULTIPLIER = 0.98f;

// Set item shop prices
int AMBULANCE_COST = 10000;
int SPORTS_CAR_COST = 12500;
int F1_CAR_COST = 15000;
int OFFROAD_TYRES_COST = 5000;
int BOOST_COST = 5000;
int PULSE_COST = 5000;
int AIR_STRIKE_COST = 5000;

// Set power up parameters
int MAX_BOOST_TIMER = 30;
int BOOST_COOLDOWN = 5*60;
int PULSE_SIZE = 100;
int MAX_PULSE_TIMER = 75;
int PULSE_COOLDOWN = 30*60;
int AIR_STRIKE_SIZE = 50;
int AIR_STRIKE_NUM_BOMBS = 5;
int AIR_STRIKE_MAX_BOMB_TIMER = 100;

// Set wave difficulty parameters
int HUMAN_COUNT_INCREMENT = 1;
int POLICE_CAR_WAVE_INCREMENT = 3;
float POLICE_CAR_SPEED_INCREMENT = 0.1f;

// Set map parameters
int MAP_RESOLUTION = 80;
int NUM_DECORATIONS = 10;
int DECORATION_SIZE = 1;
int DECORATION_OFFSET = 10;

// Instantiate number of humans and police cars
int numHumans;
int numPoliceCars;

// Instantiate the player car, police cars array list, and humans array lists
PlayerCar playerCar;
ArrayList<PoliceCar> policeCars;
ArrayList<Human> humans;
ArrayList<Human> homepageHumans;

// Instantiate sound effects objects
Minim minim;
AudioPlayer crashOne, crashTwo, wilhelm, minecraft, roblox, cashSpent, boost, pulse, explosion, waveComplete, gameOver, music;

// Instantiate car unlocks
boolean ambulanceUnlocked;
boolean sportsCarUnlocked;
boolean f1CarUnlocked;

// Instantiate power up icons
PImage offroadTyre;
PImage boostIcon;
PImage pulseIcon;
PImage airStrikes;

// Instantiate power up unlocks
boolean offroadTyresUnlocked;
boolean boostUnlocked;
boolean pulseUnlocked;
boolean airStrikeUnlocked;
AirStrike airStrike;

// Instantiate map and game state
Map map;
GameState gameState;

// Instantiate game variables
int wave;
int cash;
int cashEarned;
int highscore;
int highestWave;
boolean highestWaveAchieved;

// Instantiate stats variables
int totalGamesPlayed;
int totalWavesCleared;
int totalCashEarned;
int totalCashSpent;
int totalHumansKilled;
int totalPoliceCarsEliminated;

// Instantiate collision detection utils and quad tree objects
CollisionDetectionUtils utils = new CollisionDetectionUtils();
QuadTree quadTree;
BoundingBox root;
int quadTreeCapacity;
ArrayList<Point> mapQuadTreePoints;
boolean showQuadTree;

// Instantiate wave variables
boolean waveStarted;
int waveStartCountdown;
int humansKilled;

// Instantiate dev tools and mute toggles
boolean devToolsOn;
boolean muted;

// Set window size
void settings() {
    size(GAME_WIDTH, GAME_HEIGHT+DATABAR_HEIGHT);
}

// Initialise all game variables
void setup() {
    // Set framerate
    frameRate(60);

    // Initialise quad tree
    root = new BoundingBox(new PVector(0, 0), width, height);
    quadTreeCapacity = 4;
    quadTree = new QuadTree(root, quadTreeCapacity);
    showQuadTree = false;

    // Initialise map
    map = new Map(GAME_WIDTH, GAME_HEIGHT, MAP_RESOLUTION, NUM_DECORATIONS, DECORATION_SIZE, DECORATION_OFFSET);
    map.generate();

    // Initialise game state
    gameState = new GameState();

    // Initialise dev tools and mute toggle
    devToolsOn = false;
    muted = false;

    // Initialise wave, cash, and highscore
    wave = 1;
    cash = 0;
    cashEarned = 0;
    highscore = 0;
    highestWave = 1;
    highestWaveAchieved = false;

    // Initialise stats
    totalGamesPlayed = 0;
    totalWavesCleared = 0;
    totalCashEarned = 0;
    totalCashSpent = 0;
    totalHumansKilled = 0;
    totalPoliceCarsEliminated = 0;

    // Initialise wave start countdown and humans killed
    waveStarted = false;
    waveStartCountdown = (60 * 3)-20;
    humansKilled = 0;

    // Initialise number of humans and police cars
    numHumans = INITIAL_HUMAN_COUNT;
    numPoliceCars = INITIAL_POLICE_CAR_COUNT;

    // Initialise sprites
    offroadTyre = loadImage("./Sprites/OffRoadTyre.png");
    boostIcon = loadImage("./Sprites/Boost.png");
    pulseIcon = loadImage("./Sprites/Pulse.png");
    airStrikes = loadImage("./Sprites/AirStrike.png");

    // Initialise sounds
    minim = new Minim(this);
    crashOne = minim.loadFile("./Sounds/CrashOne.wav");
    crashTwo = minim.loadFile("./Sounds/CrashTwo.wav");
    wilhelm = minim.loadFile("./Sounds/WilhelmScream.wav");
    minecraft = minim.loadFile("./Sounds/MinecraftOof.wav");
    roblox = minim.loadFile("./Sounds/RobloxOof.wav");
    cashSpent = minim.loadFile("./Sounds/CashSpent.wav");
    boost = minim.loadFile("./Sounds/Boost.wav");
    pulse = minim.loadFile("./Sounds/Pulse.wav");
    explosion = minim.loadFile("./Sounds/Explosion.wav");
    waveComplete = minim.loadFile("./Sounds/WaveComplete.wav");
    gameOver = minim.loadFile("./Sounds/GameOver.wav");
    music = minim.loadFile("./Sounds/Music.wav");
    music.loop();
    
    // Initialise unlocks
    ambulanceUnlocked = false;
    sportsCarUnlocked = false;
    f1CarUnlocked = false;
    offroadTyresUnlocked = false;
    boostUnlocked = false;
    pulseUnlocked = false;
    airStrikeUnlocked = false;
    airStrike = new AirStrike(AIR_STRIKE_SIZE, AIR_STRIKE_NUM_BOMBS, AIR_STRIKE_MAX_BOMB_TIMER);

    // Initialise player car
    PVector initialPlayerCarPosition = new PVector(random(50, GAME_WIDTH-50), random(50, GAME_HEIGHT-50));
    PVector nwCorner = new PVector(0, 0);
    PVector neCorner = new PVector(GAME_WIDTH, 0);
    PVector swCorner = new PVector(0, GAME_HEIGHT);
    PVector seCorner = new PVector(GAME_WIDTH, GAME_HEIGHT);
    // Start player car facing away from nearest corner
    PVector nearestCornerToPlayerCar = new PVector(GAME_WIDTH/2, GAME_HEIGHT/2);
    float nearestCornerToPlayerCarDistance = Float.MAX_VALUE;
    if (initialPlayerCarPosition.copy().sub(nwCorner).mag() < nearestCornerToPlayerCarDistance) {
        nearestCornerToPlayerCar = nwCorner;
        nearestCornerToPlayerCarDistance = initialPlayerCarPosition.copy().sub(nwCorner).mag();
    }
    if (initialPlayerCarPosition.copy().sub(neCorner).mag() < nearestCornerToPlayerCarDistance) {
        nearestCornerToPlayerCar = neCorner;
        nearestCornerToPlayerCarDistance = initialPlayerCarPosition.copy().sub(neCorner).mag();
    }
    if (initialPlayerCarPosition.copy().sub(swCorner).mag() < nearestCornerToPlayerCarDistance) {
        nearestCornerToPlayerCar = swCorner;
        nearestCornerToPlayerCarDistance = initialPlayerCarPosition.copy().sub(swCorner).mag();
    }
    if (initialPlayerCarPosition.copy().sub(seCorner).mag() < nearestCornerToPlayerCarDistance) {
        nearestCornerToPlayerCar = seCorner;
        nearestCornerToPlayerCarDistance = initialPlayerCarPosition.copy().sub(seCorner).mag();
    }
    PVector directionToNearestCornerFromPlayerCar = initialPlayerCarPosition.copy().sub(nearestCornerToPlayerCar);
    float initialPlayerCarOrientation = directionToNearestCornerFromPlayerCar.heading();
    playerCar = new PlayerCar(PLAYER_CAR_WIDTH, PLAYER_CAR_HEIGHT, initialPlayerCarPosition, initialPlayerCarOrientation, PLAYER_CAR_BRAKING_POWER, PLAYER_CAR_MAX_SPEED, PLAYER_CAR_MAX_ACCELERATION, PLAYER_CAR_MAX_STEERING, PLAYER_CAR_FRICTION, PLAYER_CAR_FRICTION_MULTIPLIER, GAME_WIDTH, GAME_HEIGHT, PLAYER_CAR_MAX_LIVES, MAX_BOOST_TIMER, MAX_PULSE_TIMER, BOOST_COOLDOWN, PULSE_SIZE, PULSE_COOLDOWN);

    // Initialise police cars
    policeCars = new ArrayList<PoliceCar>();
    // Do not allow police cars to spawn right next to player car or another police car
    for (int i = 0; i < numPoliceCars; i++) {
        PVector initialPoliceCarPosition = new PVector(random(50, GAME_WIDTH-50), random(50, GAME_HEIGHT-50));
        PVector closestPoliceCar = new PVector(0, 0);
        float closestPoliceCarDistance = Float.MAX_VALUE;
        for (PoliceCar policeCar : policeCars) {
            float distance = initialPoliceCarPosition.copy().sub(policeCar.position).mag();
            if ((distance != 0.0) && (distance < closestPoliceCarDistance)) {
                closestPoliceCar = policeCar.position.copy();
                closestPoliceCarDistance = distance;
            }
        }
        while ((initialPoliceCarPosition.copy().sub(initialPlayerCarPosition).mag() < PLAYER_CAR_SAFE_ZONE) || (initialPoliceCarPosition.copy().sub(closestPoliceCar).mag() < POLICE_CAR_VISION_RADIUS)) {
            initialPoliceCarPosition = new PVector(random(50, GAME_WIDTH-50), random(50, GAME_HEIGHT-50));
            for (PoliceCar policeCar : policeCars) {
                float distance = initialPoliceCarPosition.copy().sub(policeCar.position).mag();
                if ((distance != 0.0) && (distance < closestPoliceCarDistance)) {
                    closestPoliceCar = policeCar.position.copy();
                    closestPoliceCarDistance = distance;
                }
            }
        }
        float initialPoliceCarOrientation = initialPlayerCarPosition.copy().sub(initialPoliceCarPosition).heading();
        PoliceCar newPoliceCar = new PoliceCar(POLICE_CAR_WIDTH, POLICE_CAR_HEIGHT, i, initialPoliceCarPosition, initialPoliceCarOrientation, POLICE_CAR_MAX_SPEED, POLICE_CAR_MAX_ACCELERATION, playerCar, GAME_WIDTH, GAME_HEIGHT);
        policeCars.add(newPoliceCar);
    }

    // Initialise humans
    humans = new ArrayList<Human>();
    // Do not allow humans to spawn right next to a police car or another human
    for (int i = 0; i < numHumans; i++) {
        PVector initialHumanPosition = new PVector(random(50, GAME_WIDTH-50), random(50, GAME_HEIGHT-50));
        PVector closestPoliceCar = new PVector(0, 0);
        float closestPoliceCarDistance = Float.MAX_VALUE;
        for (PoliceCar policeCar : policeCars) {
            float distance = initialHumanPosition.copy().sub(policeCar.position).mag();
            if (distance < closestPoliceCarDistance) {
                closestPoliceCar = policeCar.position.copy();
                closestPoliceCarDistance = distance;
            }
        }
        PVector closestOtherHuman = new PVector(0, 0);
        float closestOtherHumanDistance = Float.MAX_VALUE;
        for (Human human : humans) {
            float distance = initialHumanPosition.copy().sub(human.position).mag();
            if ((distance != 0.0) && (distance < closestOtherHumanDistance)) {
                closestOtherHuman = human.position.copy();
                closestOtherHumanDistance = distance;
            }
        }
        while ((initialHumanPosition.copy().sub(initialPlayerCarPosition).mag() < HUMAN_SAFE_ZONE) || (initialHumanPosition.copy().sub(closestPoliceCar).mag() < HUMAN_SAFE_ZONE) || (initialHumanPosition.copy().sub(closestOtherHuman).mag() < HUMAN_SAFE_ZONE) || (initialHumanPosition.copy().sub(closestOtherHuman).mag() < HUMAN_SAFE_ZONE)) {
            initialHumanPosition = new PVector(random(50, GAME_WIDTH-50), random(50, GAME_HEIGHT-50));
            for (PoliceCar policeCar : policeCars) {
                float distance = initialHumanPosition.copy().sub(policeCar.position).mag();
                if (distance < closestPoliceCarDistance) {
                    closestPoliceCar = policeCar.position.copy();
                    closestPoliceCarDistance = distance;
                }
            }
            for (Human human : humans) {
                float distance = initialHumanPosition.copy().sub(human.position).mag();
                if ((distance != 0.0) && (distance < closestOtherHumanDistance)) {
                    closestOtherHuman = human.position.copy();
                    closestOtherHumanDistance = distance;
                }
            }
        }
        Human newHuman = new Human(HUMAN_SIZE, initialHumanPosition, new PVector(random(-HUMAN_MAX_SPEED, HUMAN_MAX_SPEED), random(-HUMAN_MAX_SPEED, HUMAN_MAX_SPEED)), GAME_WIDTH, GAME_HEIGHT);
        humans.add(newHuman);
    }

    // Initialise homepage humans
    homepageHumans = new ArrayList<Human>();
    for (int i = 0; i < 10; i++) {
        PVector initialHumanPosition = new PVector(random(50, GAME_WIDTH-50), random(50, GAME_HEIGHT-50));
        homepageHumans.add(new Human(2*HUMAN_SIZE, initialHumanPosition, new PVector(random(-HUMAN_MAX_SPEED, HUMAN_MAX_SPEED), random(-HUMAN_MAX_SPEED, HUMAN_MAX_SPEED)), GAME_WIDTH, GAME_HEIGHT));
    }
}

// Switch to draw the correct game state
void draw() {
    textAlign(CENTER, CENTER);
    switch (gameState.phase) {
        case 0: // Homepage
            drawHomepage();
            drawCrosshairs();
            break;
        case 1: // Guide
            drawGuide();
            if (devToolsOn) {
                drawDevTools();
            }
            drawCrosshairs();
            break;
        case 2: // CarSelect
            drawCarSelect();
            if (devToolsOn) {
                drawDevTools();
            }
            drawCrosshairs();
            break;
        case 3: // ItemShop
            drawItemShop();
            if (devToolsOn) {
                drawDevTools();
            }
            drawCrosshairs();
            break;
        case 4: // PreWave
            drawPreWave();
            if (devToolsOn) {
                drawDevTools();
            }
            drawCrosshairs();
            break;
        case 5: // Wave
            drawWave();
            if (devToolsOn) {
                drawDevTools();
            }
            drawCrosshairs();
            break;
        case 6: // PostWave
            drawPostWave();
            if (devToolsOn) {
                drawDevTools();
            }
            drawCrosshairs();
            break;
        case 7: // Paused
            drawPaused();
            if (devToolsOn) {
                drawDevTools();
            }
            drawCrosshairs();
            break;
        case 8: // GameOver
            drawGameOver();
            drawCrosshairs();
            break;
        case 9: // ItemGuide
            drawItemGuide();
            if (devToolsOn) {
                drawDevTools();
            }
            drawCrosshairs();
            break;
        case 10: // Stats
            drawStats();
            if (devToolsOn) {
                drawDevTools();
            }
            drawCrosshairs();
            break;
    }
}

// Draw the home page
void drawHomepage() {
    background(0, 152, 0);
    // map.draw();
    for (Human human : homepageHumans) {
        human.draw();
        human.integrate();
    }
    textSize(60);
    fill(0, 0, 0);
    text("Welcome to SmashMania!", GAME_WIDTH/2, GAME_HEIGHT/3);
    if (highscore != 0) {
        textSize(30);
        text("High Score: ??" + highscore, GAME_WIDTH/2, GAME_HEIGHT/2);
    }
    if (highestWave > 1) {
        textSize(30);
        text("Highest Wave: " + highestWave, GAME_WIDTH/2, GAME_HEIGHT/2 + 50);
    }
    rect(0, GAME_HEIGHT, GAME_WIDTH, DATABAR_HEIGHT);
    rect(0, 0, 3*DATABAR_HEIGHT, DATABAR_HEIGHT);
    rect(GAME_WIDTH-(3*DATABAR_HEIGHT), 0, 3*DATABAR_HEIGHT, DATABAR_HEIGHT);
    rect((GAME_WIDTH/2)-(1.5*DATABAR_HEIGHT), 0, 3*DATABAR_HEIGHT, DATABAR_HEIGHT);
    fill(255, 255, 255);
    textSize(25);
    stroke(255, 255, 255);
    strokeWeight(1);
    line(0, GAME_HEIGHT, GAME_WIDTH, GAME_HEIGHT);
    line(GAME_WIDTH/3, GAME_HEIGHT, GAME_WIDTH/3, GAME_HEIGHT + DATABAR_HEIGHT);
    line(2*GAME_WIDTH/3, GAME_HEIGHT, 2*GAME_WIDTH/3, GAME_HEIGHT + DATABAR_HEIGHT);
    line(0, DATABAR_HEIGHT, 3*DATABAR_HEIGHT, DATABAR_HEIGHT);
    line(3*DATABAR_HEIGHT, 0, 3*DATABAR_HEIGHT, DATABAR_HEIGHT);
    line(GAME_WIDTH-(3*DATABAR_HEIGHT), 0, GAME_WIDTH-(3*DATABAR_HEIGHT), DATABAR_HEIGHT);
    line(GAME_WIDTH, DATABAR_HEIGHT, GAME_WIDTH-(3*DATABAR_HEIGHT), DATABAR_HEIGHT);

    line((GAME_WIDTH/2)-(1.5*DATABAR_HEIGHT), 0, (GAME_WIDTH/2)-(1.5*DATABAR_HEIGHT), DATABAR_HEIGHT);
    line((GAME_WIDTH/2)+(1.5*DATABAR_HEIGHT), 0, (GAME_WIDTH/2)+(1.5*DATABAR_HEIGHT), DATABAR_HEIGHT);
    line((GAME_WIDTH/2)-(1.5*DATABAR_HEIGHT), DATABAR_HEIGHT, (GAME_WIDTH/2)+(1.5*DATABAR_HEIGHT), DATABAR_HEIGHT);
    noStroke();
    text("Start", GAME_WIDTH/6, GAME_HEIGHT + 2*(DATABAR_HEIGHT/5));
    text("Guide", GAME_WIDTH/2, GAME_HEIGHT + 2*(DATABAR_HEIGHT/5));
    text("Car Select", 5*GAME_WIDTH/6, GAME_HEIGHT + 2*(DATABAR_HEIGHT/5));
    text("Stats", 1.5*DATABAR_HEIGHT, 2*DATABAR_HEIGHT/5);
    if (devToolsOn) {
        text("Dev Tools On", GAME_WIDTH-(1.5*DATABAR_HEIGHT), 2*DATABAR_HEIGHT/5);
    } else {
        text("Dev Tools Off", GAME_WIDTH-(1.5*DATABAR_HEIGHT), 2*DATABAR_HEIGHT/5);
    }
    if (muted) {
        text("Sound Off", GAME_WIDTH/2, 2*DATABAR_HEIGHT/5);
    } else {
        text("Sound On", GAME_WIDTH/2, 2*DATABAR_HEIGHT/5);
    }
}

// Draw the guide page
void drawGuide() {
    background(0, 152, 0);
    // map.draw();
    for (Human human : homepageHumans) {
        human.draw();
        human.integrate();
    }
    textSize(50);
    fill(0, 0, 0);
    text("Guide", GAME_WIDTH/2, GAME_HEIGHT/5);
    textSize(25);
    text("Use the W, A, S, D keys to drive.", GAME_WIDTH/2, GAME_HEIGHT/2 - 70);
    text("Earn cash by running over the walking civilians.", GAME_WIDTH/2, GAME_HEIGHT/2 - 10);
    text("Avoid getting hit by the police cars.", GAME_WIDTH/2, GAME_HEIGHT/2 + 50);
    text("Run over all humans in wave to continue.", GAME_WIDTH/2, GAME_HEIGHT/2 + 110);
    text("Press SPACE to boost.", GAME_WIDTH/2, GAME_HEIGHT/2 + 170);
    text("Press Q during a wave to pause.", GAME_WIDTH/2, GAME_HEIGHT/2 + 230);
    rect(0, GAME_HEIGHT, GAME_WIDTH, DATABAR_HEIGHT);
    stroke(255, 255, 255);
    strokeWeight(1);
    line(0, GAME_HEIGHT, GAME_WIDTH, GAME_HEIGHT);
    noStroke();
    fill(255, 255, 255);
    text("Back", GAME_WIDTH/2, GAME_HEIGHT + 2*(DATABAR_HEIGHT/5));
}

// Draw the car selection page
void drawCarSelect() {
    background(0, 152, 0);
    // map.draw();
    for (Human human : homepageHumans) {
        human.draw();
        human.integrate();
    }
    textSize(50);
    fill(0, 0, 0);
    text("Car Select", GAME_WIDTH/2, GAME_HEIGHT/5);
    rectMode(CENTER);

    rect(GAME_WIDTH/2, GAME_HEIGHT/2, 2.5*PLAYER_CAR_WIDTH, 2.5*PLAYER_CAR_WIDTH);
    fill(0, 152, 0);
    rect(GAME_WIDTH/2, GAME_HEIGHT/2, 2.25*PLAYER_CAR_WIDTH, 2.25*PLAYER_CAR_WIDTH);
    playerCar.drawAt(GAME_WIDTH/2, GAME_HEIGHT/2, 2*PLAYER_CAR_WIDTH, 2*PLAYER_CAR_HEIGHT);

    fill(0, 0, 0);
    rect(GAME_WIDTH/5, 4*GAME_HEIGHT/5, 2.5*PLAYER_CAR_WIDTH, 2.5*PLAYER_CAR_WIDTH);
    fill(0, 152, 0);
    rect(GAME_WIDTH/5, 4*GAME_HEIGHT/5, 2.25*PLAYER_CAR_WIDTH, 2.25*PLAYER_CAR_WIDTH);
    image(playerCar.minivan, GAME_WIDTH/5, 4*GAME_HEIGHT/5, 2*PLAYER_CAR_WIDTH, 2*PLAYER_CAR_HEIGHT);

    fill(0, 0, 0);
    rect(2*GAME_WIDTH/5, 4*GAME_HEIGHT/5, 2.5*PLAYER_CAR_WIDTH, 2.5*PLAYER_CAR_WIDTH);
    fill(0, 152, 0);
    rect(2*GAME_WIDTH/5, 4*GAME_HEIGHT/5, 2.25*PLAYER_CAR_WIDTH, 2.25*PLAYER_CAR_WIDTH);
    image(playerCar.ambulanceTwo, 2*GAME_WIDTH/5, 4*GAME_HEIGHT/5, 2*PLAYER_CAR_WIDTH, 2*PLAYER_CAR_HEIGHT);
    if (!ambulanceUnlocked) {
        drawLock(2*GAME_WIDTH/5, 5+4*GAME_HEIGHT/5, PLAYER_CAR_WIDTH);
    }

    fill(0, 0, 0);
    rect(3*GAME_WIDTH/5, 4*GAME_HEIGHT/5, 2.5*PLAYER_CAR_WIDTH, 2.5*PLAYER_CAR_WIDTH);
    fill(0, 152, 0);
    rect(3*GAME_WIDTH/5, 4*GAME_HEIGHT/5, 2.25*PLAYER_CAR_WIDTH, 2.25*PLAYER_CAR_WIDTH);
    image(playerCar.sports, 3*GAME_WIDTH/5, 4*GAME_HEIGHT/5, 2*PLAYER_CAR_WIDTH, 2*PLAYER_CAR_HEIGHT);
    if (!sportsCarUnlocked) {
        drawLock(3*GAME_WIDTH/5, 5+4*GAME_HEIGHT/5, PLAYER_CAR_WIDTH);
    }

    fill(0, 0, 0);
    rect(4*GAME_WIDTH/5, 4*GAME_HEIGHT/5, 2.5*PLAYER_CAR_WIDTH, 2.5*PLAYER_CAR_WIDTH);
    fill(0, 152, 0);
    rect(4*GAME_WIDTH/5, 4*GAME_HEIGHT/5, 2.25*PLAYER_CAR_WIDTH, 2.25*PLAYER_CAR_WIDTH);
    image(playerCar.f1, 4*GAME_WIDTH/5, 4*GAME_HEIGHT/5, 2*PLAYER_CAR_WIDTH, 2*PLAYER_CAR_HEIGHT);
    if (!f1CarUnlocked) {
        drawLock(4*GAME_WIDTH/5, 5+4*GAME_HEIGHT/5, PLAYER_CAR_WIDTH);
    }

    rectMode(CORNER);
    fill(0, 0, 0);
    rect(0, GAME_HEIGHT, GAME_WIDTH, DATABAR_HEIGHT);
    stroke(255, 255, 255);
    strokeWeight(1);
    line(0, GAME_HEIGHT, GAME_WIDTH, GAME_HEIGHT);
    noStroke();
    textSize(25);
    fill(255, 255, 255);
    text("Back", GAME_WIDTH/2, GAME_HEIGHT + 2*(DATABAR_HEIGHT/5));
}

// Draw the item shop
void drawItemShop() {
    background(0, 152, 0);
    // map.draw();
    for (Human human : homepageHumans) {
        human.draw();
        human.integrate();
    }
    textSize(50);
    fill(0, 0, 0);
    text("Item Shop", GAME_WIDTH/2, GAME_HEIGHT/5);
    rectMode(CENTER);
    imageMode(CENTER);
    textSize(25);

    fill(0, 0, 0);
    rect(GAME_WIDTH/4, GAME_HEIGHT/2, 2.5*PLAYER_CAR_WIDTH, 2.5*PLAYER_CAR_WIDTH);
    fill(0, 152, 0);
    rect(GAME_WIDTH/4, GAME_HEIGHT/2, 2.25*PLAYER_CAR_WIDTH, 2.25*PLAYER_CAR_WIDTH);
    image(playerCar.ambulanceTwo, GAME_WIDTH/4, GAME_HEIGHT/2, 2*PLAYER_CAR_WIDTH, 2*PLAYER_CAR_HEIGHT);
    fill(0, 0, 0);
    if (!ambulanceUnlocked) {
        drawLock(GAME_WIDTH/4, 5+GAME_HEIGHT/2, PLAYER_CAR_WIDTH);
        text("??" + formatNumber(AMBULANCE_COST), GAME_WIDTH/4, GAME_HEIGHT/2 + 2*PLAYER_CAR_WIDTH);
    }
    text("Ambulance", GAME_WIDTH/4, GAME_HEIGHT/2 - 2*PLAYER_CAR_WIDTH);

    fill(0, 0, 0);
    rect(2*GAME_WIDTH/4, GAME_HEIGHT/2, 2.5*PLAYER_CAR_WIDTH, 2.5*PLAYER_CAR_WIDTH);
    fill(0, 152, 0);
    rect(2*GAME_WIDTH/4, GAME_HEIGHT/2, 2.25*PLAYER_CAR_WIDTH, 2.25*PLAYER_CAR_WIDTH);
    image(playerCar.sports, 2*GAME_WIDTH/4, GAME_HEIGHT/2, 2*PLAYER_CAR_WIDTH, 2*PLAYER_CAR_HEIGHT);
    fill(0, 0, 0);
    if (!sportsCarUnlocked) {
        drawLock(2*GAME_WIDTH/4, 5+GAME_HEIGHT/2, PLAYER_CAR_WIDTH);
        text("??" + formatNumber(SPORTS_CAR_COST), 2*GAME_WIDTH/4, GAME_HEIGHT/2 + 2*PLAYER_CAR_WIDTH);
    }
    text("Sports Car", 2*GAME_WIDTH/4, GAME_HEIGHT/2 - 2*PLAYER_CAR_WIDTH);

    fill(0, 0, 0);
    rect(3*GAME_WIDTH/4, GAME_HEIGHT/2, 2.5*PLAYER_CAR_WIDTH, 2.5*PLAYER_CAR_WIDTH);
    fill(0, 152, 0);
    rect(3*GAME_WIDTH/4, GAME_HEIGHT/2, 2.25*PLAYER_CAR_WIDTH, 2.25*PLAYER_CAR_WIDTH);
    image(playerCar.f1, 3*GAME_WIDTH/4, GAME_HEIGHT/2, 2*PLAYER_CAR_WIDTH, 2*PLAYER_CAR_HEIGHT);
    fill(0, 0, 0);
    if (!f1CarUnlocked) {
        drawLock(3*GAME_WIDTH/4, 5+GAME_HEIGHT/2, PLAYER_CAR_WIDTH);
        text("??" + formatNumber(F1_CAR_COST), 3*GAME_WIDTH/4, GAME_HEIGHT/2 + 2*PLAYER_CAR_WIDTH);
    }
    text("F1 Car", 3*GAME_WIDTH/4, GAME_HEIGHT/2 - 2*PLAYER_CAR_WIDTH);

    fill(0, 0, 0);
    rect(GAME_WIDTH/5, 4*GAME_HEIGHT/5, 2.5*PLAYER_CAR_WIDTH, 2.5*PLAYER_CAR_WIDTH);
    fill(0, 152, 0);
    rect(GAME_WIDTH/5, 4*GAME_HEIGHT/5, 2.25*PLAYER_CAR_WIDTH, 2.25*PLAYER_CAR_WIDTH);
    image(offroadTyre, GAME_WIDTH/5, 4*GAME_HEIGHT/5, 2*PLAYER_CAR_WIDTH, 2*PLAYER_CAR_WIDTH);
    fill(0, 0, 0);
    if (!offroadTyresUnlocked) {
        drawLock(GAME_WIDTH/5, 5+4*GAME_HEIGHT/5, PLAYER_CAR_WIDTH);
        text("??" + formatNumber(OFFROAD_TYRES_COST), GAME_WIDTH/5, 4*GAME_HEIGHT/5 + 2*PLAYER_CAR_WIDTH);
    }
    text("Offroad Tyres", GAME_WIDTH/5, 4*GAME_HEIGHT/5 - 2*PLAYER_CAR_WIDTH);

    fill(0, 0, 0);
    rect(2*GAME_WIDTH/5, 4*GAME_HEIGHT/5, 2.5*PLAYER_CAR_WIDTH, 2.5*PLAYER_CAR_WIDTH);
    fill(0, 152, 0);
    rect(2*GAME_WIDTH/5, 4*GAME_HEIGHT/5, 2.25*PLAYER_CAR_WIDTH, 2.25*PLAYER_CAR_WIDTH);
    image(boostIcon, 2*GAME_WIDTH/5, 4*GAME_HEIGHT/5, 2*PLAYER_CAR_WIDTH, 2*PLAYER_CAR_WIDTH);
    fill(0, 0, 0);
    if (!boostUnlocked) {
        drawLock(2*GAME_WIDTH/5, 5+4*GAME_HEIGHT/5, PLAYER_CAR_WIDTH);
        text("??" + formatNumber(BOOST_COST), 2*GAME_WIDTH/5, 4*GAME_HEIGHT/5 + 2*PLAYER_CAR_WIDTH);
    }
    text("Boost", 2*GAME_WIDTH/5, 4*GAME_HEIGHT/5 - 2*PLAYER_CAR_WIDTH);

    fill(0, 0, 0);
    rect(3*GAME_WIDTH/5, 4*GAME_HEIGHT/5, 2.5*PLAYER_CAR_WIDTH, 2.5*PLAYER_CAR_WIDTH);
    fill(0, 152, 0);
    rect(3*GAME_WIDTH/5, 4*GAME_HEIGHT/5, 2.25*PLAYER_CAR_WIDTH, 2.25*PLAYER_CAR_WIDTH);
    image(pulseIcon, 3*GAME_WIDTH/5, 4*GAME_HEIGHT/5, 2*PLAYER_CAR_WIDTH, 2*PLAYER_CAR_WIDTH);
    fill(0, 0, 0);
    if (!pulseUnlocked) {
        drawLock(3*GAME_WIDTH/5, 5+4*GAME_HEIGHT/5, PLAYER_CAR_WIDTH);
        text("??" + formatNumber(PULSE_COST), 3*GAME_WIDTH/5, 4*GAME_HEIGHT/5 + 2*PLAYER_CAR_WIDTH);
    }
    text("Pulse", 3*GAME_WIDTH/5, 4*GAME_HEIGHT/5 - 2*PLAYER_CAR_WIDTH);

    fill(0, 0, 0);
    rect(4*GAME_WIDTH/5, 4*GAME_HEIGHT/5, 2.5*PLAYER_CAR_WIDTH, 2.5*PLAYER_CAR_WIDTH);
    fill(0, 152, 0);
    rect(4*GAME_WIDTH/5, 4*GAME_HEIGHT/5, 2.25*PLAYER_CAR_WIDTH, 2.25*PLAYER_CAR_WIDTH);
    image(airStrikes, 4*GAME_WIDTH/5, 4*GAME_HEIGHT/5, 2*PLAYER_CAR_WIDTH, 2*PLAYER_CAR_WIDTH);
    fill(0, 0, 0);
    if (!airStrikeUnlocked) {
        drawLock(4*GAME_WIDTH/5, 5+4*GAME_HEIGHT/5, PLAYER_CAR_WIDTH);
        text("??" + formatNumber(AIR_STRIKE_COST), 4*GAME_WIDTH/5, 4*GAME_HEIGHT/5 + 2*PLAYER_CAR_WIDTH);
    }
    text("Air Strike", 4*GAME_WIDTH/5, 4*GAME_HEIGHT/5 - 2*PLAYER_CAR_WIDTH);
    
    rectMode(CORNER);
    fill(0, 0, 0);
    rect(0, GAME_HEIGHT, GAME_WIDTH, DATABAR_HEIGHT);
    stroke(255, 255, 255);
    strokeWeight(1);
    line(0, GAME_HEIGHT, GAME_WIDTH, GAME_HEIGHT);
    line(GAME_WIDTH/3, GAME_HEIGHT, GAME_WIDTH/3, GAME_HEIGHT + DATABAR_HEIGHT);
    line(2*GAME_WIDTH/3, GAME_HEIGHT, 2*GAME_WIDTH/3, GAME_HEIGHT + DATABAR_HEIGHT);
    noStroke();
    textSize(25);
    text("Cash: ??" + cash, GAME_WIDTH/2, 1.5*GAME_HEIGHT/5);
    fill(255, 255, 255);
    text("Car Select", GAME_WIDTH/6, GAME_HEIGHT + 2*(DATABAR_HEIGHT/5));
    text("Item Guide", 3*GAME_WIDTH/6, GAME_HEIGHT + 2*(DATABAR_HEIGHT/5));
    text("Back", 5*GAME_WIDTH/6, GAME_HEIGHT + 2*(DATABAR_HEIGHT/5));
}

// Draw the prewave page
void drawPreWave() {
    background(0, 152, 0);
    // map.draw();
    for (Human human : homepageHumans) {
        human.draw();
        human.integrate();
    }
    textSize(50);
    fill(0, 0, 0);
    text("Wave " + wave, GAME_WIDTH/2, GAME_HEIGHT/5);
    textSize(25);
    text("Cash: ??" + cash, GAME_WIDTH/2, GAME_HEIGHT/2);
    text("Lives left: " + playerCar.lives, GAME_WIDTH/2, GAME_HEIGHT/2 + 50);
    rect(0, GAME_HEIGHT, GAME_WIDTH, DATABAR_HEIGHT);
    stroke(255, 255, 255);
    strokeWeight(1);
    line(0, GAME_HEIGHT, GAME_WIDTH, GAME_HEIGHT);
    noStroke();
    fill(255, 255, 255);
    text("Start Wave", GAME_WIDTH/2, GAME_HEIGHT + 2*(DATABAR_HEIGHT/5));
}

// Draw the game
void drawWave() {
    background(0, 152, 0);
    noStroke();
    fill(150, 150, 150);

    // Countdown to wave start/resume
    if (((gameState.lastPhase == 4) || (gameState.lastPhase == 7)) && !waveStarted) {
        if (waveStartCountdown <= 0) {
            waveStartCountdown = (60 * 3)-20;
            waveStarted = true;
        } else {
            map.draw();
            for (Human human : humans) {
                human.draw();
            }
            for (PoliceCar policeCar : policeCars) {
                policeCar.draw();
            }
            playerCar.draw();
            textSize(200);
            fill(0, 0, 0);
            text((int) (Math.ceil(waveStartCountdown/60)+1) + "", GAME_WIDTH/2, GAME_HEIGHT/2);
            // Databar
            fill(0, 0, 0);
            rect(0, GAME_HEIGHT, GAME_WIDTH, DATABAR_HEIGHT);
            fill(255, 255, 255);
            textSize(25);
            text("Cash: ??" + cash, GAME_WIDTH/5, GAME_HEIGHT + 2*(DATABAR_HEIGHT/5));
            text("Wave " + wave, GAME_WIDTH/2, GAME_HEIGHT + 2*(DATABAR_HEIGHT/5));
            text("Lives: " + playerCar.lives, 4*GAME_WIDTH/5, GAME_HEIGHT + 2*(DATABAR_HEIGHT/5));
            waveStartCountdown--;
            return;
        }
    }

    // Endgame condition
    if (playerCar.lives <= 0) {
        gameState.visitEndgame();
        gameOver.rewind();
        if (!muted) {
            gameOver.play();
        }
    }

    // Wave complete condition
    if (humansKilled >= numHumans) {
        gameState.visitPostWave();
        waveComplete.rewind();
        if (!muted) {
            waveComplete.play();
        }
    }

    // Reset QuadTree
    quadTree = new QuadTree(root, quadTreeCapacity);

    // Add air strike bombs to the QuadTree
    for (int i = 0; i < airStrike.numBombs; i++) {
        quadTree.insert(new Point(airStrike.position.copy().add(airStrike.bombPositions[i]), airStrike));
    }

    // Add other points to the QuadTree
    quadTree.insert(new Point(playerCar.position, playerCar));
    for (Human human : humans) {
        quadTree.insert(new Point(human.position, human));
    }
    for (PoliceCar policeCar : policeCars) {
        quadTree.insert(new Point(policeCar.position, policeCar));
    }
    for (int i = 0; i < NUM_DECORATIONS; i++) {
        if (map.decorations[i].type == 0) {
            quadTree.insert(new Point(map.decorations[i].position, map.decorations[i]));
        }
    }

    // Draw map
    map.draw();

    // Draw the cooldown bars
    if (boostUnlocked) {
        fill(0, 0, 0);
        rect(18, 23, 225, 42);
    }
    if (pulseUnlocked) {
        fill(0, 0, 0);
        rect(18, 53, 225, 42);
    }
    if (airStrikeUnlocked) {
        fill(0, 0, 0);
        rect(18, 83, 225, 42);
    }
    if (boostUnlocked) {
        fill(255, 255, 255);
        textAlign(LEFT, CENTER);
        text("Boost:", 25, 40);
        textAlign(CENTER, CENTER);
        drawCooldownBar(185, 43, 100, 21, BOOST_COOLDOWN - playerCar.boostCooldownTimer, BOOST_COOLDOWN, 255, 255, 0);
    }
    if (pulseUnlocked) {
        fill(255, 255, 255);
        textAlign(LEFT, CENTER);
        text("Pulse:", 25, 70);
        textAlign(CENTER, CENTER);
        drawCooldownBar(185, 73, 100, 21, PULSE_COOLDOWN - playerCar.pulseCooldownTimer, PULSE_COOLDOWN, 0, 255, 255);
    }
    if (airStrikeUnlocked) {
        fill(255, 255, 255);
        textAlign(LEFT, CENTER);
        text("Air Strike:", 25, 100);
        textAlign(CENTER, CENTER);
        if (airStrike.used || airStrike.exploding) {
            drawCooldownBar(185, 103, 100, 21, 0, 1, 255, 0, 255);
        } else {
            drawCooldownBar(185, 103, 100, 21, 1, 1, 255, 0, 255);
        }
    }

    // Draw and integrate humans
    for (Human human : humans) {
        human.draw();
        human.integrate();
    }

    // Draw and integrate police cars
    for (PoliceCar policeCar : policeCars) {
        // Check if police car is on the road or the grass
        if (map.closestPoint(policeCar.position) == 0) { // Grass
            policeCar.maxSpeed = POLICE_CAR_MAX_SPEED * GRASS_MAX_SPEED_MULTIPLIER;
        } else { // Road
            policeCar.maxSpeed = POLICE_CAR_MAX_SPEED;
        }
        policeCar.draw();
        policeCar.integrate();
    }

    // Check if player car is on the road or the grass and set max speed and friction accordingly
    if ((map.closestPoint(playerCar.position) == 0) && !offroadTyresUnlocked) { // Grass
        switch (playerCar.type) {
            case 0:
                playerCar.maxSpeed = PLAYER_CAR_MAX_SPEED * GRASS_MAX_SPEED_MULTIPLIER;
                playerCar.friction = PLAYER_CAR_FRICTION * GRASS_FRICTION_MULTIPLIER;
                break;
            case 1:
                playerCar.maxSpeed = 0.75f * PLAYER_CAR_MAX_SPEED * GRASS_MAX_SPEED_MULTIPLIER;
                playerCar.friction = 0.01f + (PLAYER_CAR_FRICTION * GRASS_FRICTION_MULTIPLIER);
                break;
            case 2:
                playerCar.maxSpeed = 1.25f * PLAYER_CAR_MAX_SPEED * GRASS_MAX_SPEED_MULTIPLIER;
                playerCar.friction = (PLAYER_CAR_FRICTION * GRASS_FRICTION_MULTIPLIER) - 0.05f;
                break;
            case 3:
                playerCar.maxSpeed = 1.5f * PLAYER_CAR_MAX_SPEED * GRASS_MAX_SPEED_MULTIPLIER;
                playerCar.friction = 0.01f + (PLAYER_CAR_FRICTION * GRASS_FRICTION_MULTIPLIER);
                break;
        }
    } else { // Road
        playerCar.updateCarStats();
    }

    // Draw and integrate player car
    playerCar.draw();
    playerCar.integrate();

    // Draw air strike
    airStrike.draw();

    // Draw QuadTree
    if (showQuadTree) {
        quadTree.draw();
    }

    // Player car collision detection
    BoundingBox playerCarQuerySpace = new BoundingBox(new PVector(playerCar.position.x-(0.5*PLAYER_CAR_WIDTH)-50, playerCar.position.y-(0.5*PLAYER_CAR_WIDTH)-50), (int) (PLAYER_CAR_WIDTH + 100), (int) (PLAYER_CAR_WIDTH + 100));
    // playerCarQuerySpace.draw();
    ArrayList<Point> playerCarPointsForCollisionDetection = quadTree.query(playerCarQuerySpace, new ArrayList<Point>());
    for (Point point : playerCarPointsForCollisionDetection) {
        if (point.object instanceof PoliceCar) {
            PoliceCar policeCar = (PoliceCar) point.object;
            if (!policeCar.broken) {
                // If player car collides with a police car
                if (utils.rectCollisionDetection(playerCar.position, PLAYER_CAR_WIDTH, PLAYER_CAR_HEIGHT, playerCar.orientation, policeCar.position, POLICE_CAR_WIDTH, POLICE_CAR_HEIGHT, policeCar.orientation)) {
                    // Both objects collide
                    playerCar.collision();
                    policeCar.collision();
                    // Play either crash sound one or two
                    int crashSound = round(random(1));
                    if (crashSound == 0) {
                        crashOne.rewind();
                        if (!muted) {
                            crashOne.play();
                        }
                    } else {
                        crashTwo.rewind();
                        if (!muted) {
                            crashTwo.play();
                        }
                    }
                } else if (playerCar.pulsing) {
                    // If the player car is pulsing and the pulse collides with a police car
                    if (utils.circleRectCollisionDetection(playerCar.position, playerCar.currentPulseSize, policeCar.position, POLICE_CAR_WIDTH, POLICE_CAR_HEIGHT, policeCar.orientation)) {
                        // Police car collides with the pulse
                        policeCar.collision();
                        totalPoliceCarsEliminated++;
                        addCash(100);
                    }
                }
            }
        } else if (point.object instanceof Human) {
            Human human = (Human) point.object;
            if (human.alive) {
                // If the player car collides with a human
                if (utils.circleRectCollisionDetection(human.position, HUMAN_SIZE, playerCar.position, PLAYER_CAR_WIDTH, PLAYER_CAR_HEIGHT, playerCar.orientation)) {
                    // Kill the human
                    human.kill();
                    humansKilled++;
                    totalHumansKilled++;
                    if (playerCar.type == 1) {
                        addCash(150);
                    } else {
                        addCash(100);
                    }
                    // Play one of the death sounds
                    int humanKilledSound = round(random(100));
                    if (humanKilledSound == 0) {
                        wilhelm.rewind();
                        if (!muted) {
                            wilhelm.play();
                        }
                    } else if (humanKilledSound < 50) {
                        minecraft.rewind();
                        if (!muted) {
                            minecraft.play();
                        }
                    } else {
                        roblox.rewind();
                        if (!muted) {
                            roblox.play();
                        }
                    }
                } else if (playerCar.pulsing) {
                    // If the player car is pulsing and the pulse collides with a human
                    if (playerCar.position.copy().sub(human.position).mag() < (playerCar.currentPulseSize + HUMAN_SIZE)/2) {
                        // Kill the human
                        human.kill();
                        humansKilled++;
                        totalHumansKilled++;
                        addCash(50);
                        // Play one of the death sounds
                        int humanKilledSound = round(random(100));
                        if (humanKilledSound == 0) {
                            wilhelm.rewind();
                            if (!muted) {
                                wilhelm.play();
                            }
                        } else if (humanKilledSound < 50) {
                            minecraft.rewind();
                            if (!muted) {
                                minecraft.play();
                            }
                        } else {
                            roblox.rewind();
                            if (!muted) {
                                roblox.play();
                            }
                        }
                    }
                }
            }
        }
    }

    // Police car collision detection
    for (PoliceCar policeCar : policeCars) {
        if (!policeCar.broken) {
            BoundingBox policeCarQuerySpace = new BoundingBox(new PVector(policeCar.position.x-(1.5*POLICE_CAR_WIDTH), policeCar.position.y-(1.5*POLICE_CAR_WIDTH)), (int) (POLICE_CAR_WIDTH*3), (int) (POLICE_CAR_WIDTH*3));
            // policeCarQuerySpace.draw();
            ArrayList<Point> policeCarPointsForCollisionDetection = quadTree.query(policeCarQuerySpace, new ArrayList<Point>());
            for (Point point : policeCarPointsForCollisionDetection) {
                if (point.object instanceof PoliceCar) {
                    PoliceCar otherPoliceCar = (PoliceCar) point.object;
                    if (policeCar.id != otherPoliceCar.id) {
                        if (!otherPoliceCar.broken) {
                            // If a police car can 'see' another police car, they should flee eachother
                            if (policeCar.position.copy().sub(otherPoliceCar.position).mag() < POLICE_CAR_VISION_RADIUS) {
                                policeCar.kinematicFlee(otherPoliceCar.position);
                            }
                        }
                    }
                } else if (point.object instanceof Human) {
                    Human human = (Human) point.object;
                    if (human.alive) {
                        // If a police car collides with a human
                        if (utils.circleRectCollisionDetection(human.position, HUMAN_SIZE, policeCar.position, POLICE_CAR_WIDTH, POLICE_CAR_HEIGHT, policeCar.orientation)) {
                            // Kill the human
                            human.kill();
                            humansKilled++;
                            // Play one of the death sounds
                            int humanKilledSound = round(random(100));
                            if (humanKilledSound == 0) {
                                wilhelm.rewind();
                                if (!muted) {
                                    wilhelm.play();
                                }
                            } else if (humanKilledSound < 50) {
                                minecraft.rewind();
                                if (!muted) {
                                    minecraft.play();
                                }
                            } else {
                                roblox.rewind();
                                if (!muted) {
                                    roblox.play();
                                }
                            }
                        } else if (policeCar.position.copy().sub(human.position).mag() < POLICE_CAR_VISION_RADIUS) {
                            // If the police car can 'see' a human, they should flee the human
                            policeCar.kinematicFlee(human.position);
                        }
                    }
                }
            }
        }
    }

    // Air strike collision detection
    if (airStrike.exploding) {
        for (int i = 0; i < airStrike.numBombs; i++) {
            BoundingBox bombQuerySpace = new BoundingBox(new PVector(airStrike.position.copy().add(airStrike.bombPositions[i]).x-airStrike.currentBombSizes[i]*2, airStrike.position.copy().add(airStrike.bombPositions[i]).y-airStrike.currentBombSizes[i]*2), (int) (airStrike.currentBombSizes[i]*4), (int) (airStrike.currentBombSizes[i]*4));
            // bombQuerySpace.draw();
            ArrayList<Point> bombPointsForCollisionDetection = quadTree.query(bombQuerySpace, new ArrayList<Point>());
            for (Point point : bombPointsForCollisionDetection) {
                if (point.object instanceof PoliceCar) {
                    PoliceCar policeCar = (PoliceCar) point.object;
                    if (!policeCar.broken) {
                        // If the air strike collides with a police car
                        if (utils.circleRectCollisionDetection(airStrike.position.copy().add(airStrike.bombPositions[i]), airStrike.currentBombSizes[i], policeCar.position, POLICE_CAR_WIDTH, POLICE_CAR_HEIGHT, policeCar.orientation)) {
                            // Eliminate the police car
                            policeCar.collision();
                            totalPoliceCarsEliminated++;
                            addCash(100);
                        }
                    }
                } else if (point.object instanceof Human) {
                    Human human = (Human) point.object;
                    if (human.alive) {
                        // If the air strike collides with a human
                        if (airStrike.position.copy().add(airStrike.bombPositions[i]).copy().sub(human.position).mag() < (airStrike.currentBombSizes[i] + HUMAN_SIZE)/2) {
                            // Kill the human
                            human.kill();
                            humansKilled++;
                            totalHumansKilled++;
                            addCash(50);
                            // Play one of the death sounds
                            int humanKilledSound = round(random(100));
                            if (humanKilledSound == 0) {
                                wilhelm.rewind();
                                if (!muted) {
                                    wilhelm.play();
                                }
                            } else if (humanKilledSound < 50) {
                                minecraft.rewind();
                                if (!muted) {
                                    minecraft.play();
                                }
                            } else {
                                roblox.rewind();
                                if (!muted) {
                                    roblox.play();
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // Databar
    fill(0, 0, 0);
    rect(0, GAME_HEIGHT, GAME_WIDTH, DATABAR_HEIGHT);
    fill(255, 255, 255);
    textSize(25);
    text("Cash: ??" + cash, GAME_WIDTH/5, GAME_HEIGHT + 2*(DATABAR_HEIGHT/5));
    text("Wave " + wave, GAME_WIDTH/2, GAME_HEIGHT + 2*(DATABAR_HEIGHT/5));
    text("Lives: " + playerCar.lives, 4*GAME_WIDTH/5, GAME_HEIGHT + 2*(DATABAR_HEIGHT/5));
}

// Draw the postwave page
void drawPostWave() {
    background(0, 152, 0);
    // map.draw();
    for (Human human : homepageHumans) {
        human.draw();
        human.integrate();
    }
    textSize(50);
    fill(0, 0, 0);
    text("Wave " + wave + " Complete!", GAME_WIDTH/2, GAME_HEIGHT/5);
    textSize(25);
    text("Cash: ??" + cash, GAME_WIDTH/2, GAME_HEIGHT/2);
    text("Lives left: " + playerCar.lives, GAME_WIDTH/2, GAME_HEIGHT/2 + 50);
    rect(0, GAME_HEIGHT, GAME_WIDTH, DATABAR_HEIGHT);
    stroke(255, 255, 255);
    strokeWeight(1);
    line(0, GAME_HEIGHT, GAME_WIDTH, GAME_HEIGHT);
    line(GAME_WIDTH/2, GAME_HEIGHT, GAME_WIDTH/2, GAME_HEIGHT + DATABAR_HEIGHT);
    noStroke();
    fill(255, 255, 255);
    text("Next Wave", GAME_WIDTH/4, GAME_HEIGHT + 2*(DATABAR_HEIGHT/5));
    text("Item Shop", 3*GAME_WIDTH/4, GAME_HEIGHT + 2*(DATABAR_HEIGHT/5));
}

// Draw the paused screen
void drawPaused() {
    background(0, 152, 0);
    // map.draw();
    for (Human human : homepageHumans) {
        human.draw();
        human.integrate();
    }
    textSize(50);
    fill(0, 0, 0);
    text("Paused!", GAME_WIDTH/2, GAME_HEIGHT/5);
    textSize(25);
    text("Wave " + wave, GAME_WIDTH/2, GAME_HEIGHT/2);
    text("Cash: ??" + cash, GAME_WIDTH/2, GAME_HEIGHT/2 + 50);
    text("Lives left: " + playerCar.lives, GAME_WIDTH/2, GAME_HEIGHT/2 + 100);
    rect(0, GAME_HEIGHT, GAME_WIDTH, DATABAR_HEIGHT);
    stroke(255, 255, 255);
    strokeWeight(1);
    line(0, GAME_HEIGHT, GAME_WIDTH, GAME_HEIGHT);
    noStroke();
    fill(255, 255, 255);
    text("Press 'Q' to unpause", GAME_WIDTH/2, GAME_HEIGHT + 2*(DATABAR_HEIGHT/5));
}

// Draw the game over screen
void drawGameOver() {
    background(0, 152, 0);
    // map.draw();
    for (Human human : homepageHumans) {
        human.draw();
        human.integrate();
    }
    textSize(50);
    fill(0, 0, 0);
    text("Game Over!", GAME_WIDTH/2, GAME_HEIGHT/5);
    textSize(25);
    text("Wave reached: " + wave, GAME_WIDTH/2, GAME_HEIGHT/2);
    text("Cash earned: ??" + cashEarned, GAME_WIDTH/2, GAME_HEIGHT/2 + 50);
    if ((cashEarned >= highscore) && (cashEarned > 0)) {
        text("New high score!", GAME_WIDTH/2, GAME_HEIGHT/2 + 100);
        highscore = cashEarned;
    }
    if (highestWaveAchieved) {
        text("New highest wave!", GAME_WIDTH/2, GAME_HEIGHT/2 + 150);
    }
    rect(0, GAME_HEIGHT, GAME_WIDTH, DATABAR_HEIGHT);
    stroke(255, 255, 255);
    strokeWeight(1);
    line(0, GAME_HEIGHT, GAME_WIDTH, GAME_HEIGHT);
    noStroke();
    fill(255, 255, 255);
    text("Homepage", GAME_WIDTH/2, GAME_HEIGHT + 2*(DATABAR_HEIGHT/5));
}

// Draw the item guide page
void drawItemGuide() {
    background(0, 152, 0);
    // map.draw();
    for (Human human : homepageHumans) {
        human.draw();
        human.integrate();
    }
    textSize(50);
    fill(0, 0, 0);
    text("Item Guide", GAME_WIDTH/2, GAME_HEIGHT/5);
    textSize(25);
    textAlign(LEFT, CENTER);
    text("- The ambulance is slow but earns 1.5x cash.", GAME_WIDTH/12, GAME_HEIGHT/2 - 100);
    text("- The sports car is faster and has better grip.", GAME_WIDTH/12, GAME_HEIGHT/2 - 50);
    text("- The F1 car is fastest but has bad grass grip.", GAME_WIDTH/12, GAME_HEIGHT/2);
    text("- Offroad tyres gives road-level grip on the grass.", GAME_WIDTH/12, GAME_HEIGHT/2 + 50);
    text("- The boost propels the car forwards using SPACE.", GAME_WIDTH/12, GAME_HEIGHT/2 + 100);
    text("- The pulse eliminates proximate humans and police cars using 'E'.", GAME_WIDTH/12, GAME_HEIGHT/2 + 150);
    text("- The air strike drops a cluster of bombs around a clicked position.", GAME_WIDTH/12, GAME_HEIGHT/2 + 200);
    text("- Both the pulse and air strike earn ??50 for killing a human", GAME_WIDTH/12, GAME_HEIGHT/2 + 250);
    text("  and ??100 for destroying a police car.", GAME_WIDTH/12, GAME_HEIGHT/2 + 300);
    textAlign(CENTER, CENTER);
    rect(0, GAME_HEIGHT, GAME_WIDTH, DATABAR_HEIGHT);
    stroke(255, 255, 255);
    strokeWeight(1);
    line(0, GAME_HEIGHT, GAME_WIDTH, GAME_HEIGHT);
    noStroke();
    fill(255, 255, 255);
    text("Back", GAME_WIDTH/2, GAME_HEIGHT + 2*(DATABAR_HEIGHT/5));
}

// Draw the stats page
void drawStats() {
    background(0, 152, 0);
    // map.draw();
    for (Human human : homepageHumans) {
        human.draw();
        human.integrate();
    }
    textSize(50);
    fill(0, 0, 0);
    text("Stats", GAME_WIDTH/2, GAME_HEIGHT/5);
    textSize(25);
    text("Total games played: " + totalGamesPlayed, GAME_WIDTH/2, GAME_HEIGHT/2 - 70);
    text("Total waves cleared: " + totalWavesCleared, GAME_WIDTH/2, GAME_HEIGHT/2 - 10);
    text("Total cash earned: " + totalCashEarned, GAME_WIDTH/2, GAME_HEIGHT/2 + 50);
    text("Total humans killed: " + totalHumansKilled, GAME_WIDTH/2, GAME_HEIGHT/2 + 110);
    text("Total police cars eliminated: " + totalPoliceCarsEliminated, GAME_WIDTH/2, GAME_HEIGHT/2 + 170);
    rect(0, GAME_HEIGHT, GAME_WIDTH, DATABAR_HEIGHT);
    stroke(255, 255, 255);
    strokeWeight(1);
    line(0, GAME_HEIGHT, GAME_WIDTH, GAME_HEIGHT);
    noStroke();
    fill(255, 255, 255);
    text("Back", GAME_WIDTH/2, GAME_HEIGHT + 2*(DATABAR_HEIGHT/5));
}

// Draw a lock to show locked items
void drawLock(int posX, int posY, int size) {
    rectMode(CENTER);
    fill(0, 0, 0);
    ellipse(posX, posY - size/2, size, size);
    fill(0, 152, 0);
    ellipse(posX, posY - size/2, size/2, size/2);
    fill(0, 0, 0);
    rect(posX, posY, size, size);
}

// Draw cooldown bars for power ups
void drawCooldownBar(int posX, int posY, int _width, int _height, int cooldown, int maxCooldown, int red, int green, int blue) {
    rectMode(CENTER);
    fill(0, 0, 0);
    rect(posX, posY, _width, _height);
    fill(red, green, blue);
    rectMode(CORNER);
    rect(posX - (_width/2), posY - (_height/2), _width*cooldown/maxCooldown, _height);
}

// Draw crosshairs to enhance mouse position and aim air strike
void drawCrosshairs() {
    stroke(255, 255, 255);
    strokeWeight(1);
    line(mouseX-10, mouseY, mouseX+10, mouseY);
    line(mouseX, mouseY-10, mouseX, mouseY+10);
    noStroke();
}

// Draw a small red circle in the corner to show when dev tools are turned on
void drawDevTools() {
    fill(255, 0, 0);
    ellipse(GAME_WIDTH-DATABAR_HEIGHT/2, DATABAR_HEIGHT/2, DATABAR_HEIGHT/2, DATABAR_HEIGHT/2);
}

// Add cash
void addCash(int value) {
    cash += value;
    cashEarned += value;
    totalCashEarned += value;
}

// Add commas to a number in appropriate positions
String formatNumber(int num) {
    String numberString = Integer.toString(num);
    int length = numberString.length();
    int commaPos = length % 3;
    if (commaPos == 0) {
        commaPos = 3;
    }
    String formattedNumber = "";
    for (int i = 0; i < length; i++) {
        if (i == commaPos) {
            formattedNumber += ",";
            commaPos += 3;
        }
        formattedNumber += numberString.charAt(i);
    }
    return formattedNumber;
}

// Close sound channels
void stop() {
    music.close();
    crashOne.close();
    crashTwo.close();
    wilhelm.close();
    minecraft.close();
    roblox.close();
    cashSpent.close();
    boost.close();
    pulse.close();
    explosion.close();
    waveComplete.close();
    gameOver.close();
    minim.stop();
}

// Set wave variables and reset game elements for the next wave
void setupNextWave() {
    // Increment wave
    wave++;
    totalWavesCleared++;

    // Update highestWave
    if (wave > highestWave) {
        highestWave = wave;
        highestWaveAchieved = true;
    }

    // Update number of humans
    numHumans += HUMAN_COUNT_INCREMENT;

    // Update number of police cars
    if (wave % POLICE_CAR_WAVE_INCREMENT == 0) {
        numPoliceCars++;
    }

    // Update police car max speed
    if (wave < 20) { // To stop police cars from going too fast
        POLICE_CAR_MAX_SPEED += POLICE_CAR_SPEED_INCREMENT;
    }

    // Reset air strike
    airStrike.reset();

    // Reset wave start countdown
    waveStarted = false;
    waveStartCountdown = (60 * 3)-20;

    // Reset humans killed
    humansKilled = 0;

    // Generate new map
    map = new Map(GAME_WIDTH, GAME_HEIGHT, MAP_RESOLUTION, NUM_DECORATIONS, DECORATION_SIZE, DECORATION_OFFSET);
    map.generate();

    // Reset player car
    PVector initialPlayerCarPosition = new PVector(random(50, GAME_WIDTH-50), random(50, GAME_HEIGHT-50));
    PVector nwCorner = new PVector(0, 0);
    PVector neCorner = new PVector(GAME_WIDTH, 0);
    PVector swCorner = new PVector(0, GAME_HEIGHT);
    PVector seCorner = new PVector(GAME_WIDTH, GAME_HEIGHT);
    PVector nearestCornerToPlayerCar = new PVector(GAME_WIDTH/2, GAME_HEIGHT/2);
    float nearestCornerToPlayerCarDistance = Float.MAX_VALUE;
    if (initialPlayerCarPosition.copy().sub(nwCorner).mag() < nearestCornerToPlayerCarDistance) {
        nearestCornerToPlayerCar = nwCorner;
        nearestCornerToPlayerCarDistance = initialPlayerCarPosition.copy().sub(nwCorner).mag();
    }
    if (initialPlayerCarPosition.copy().sub(neCorner).mag() < nearestCornerToPlayerCarDistance) {
        nearestCornerToPlayerCar = neCorner;
        nearestCornerToPlayerCarDistance = initialPlayerCarPosition.copy().sub(neCorner).mag();
    }
    if (initialPlayerCarPosition.copy().sub(swCorner).mag() < nearestCornerToPlayerCarDistance) {
        nearestCornerToPlayerCar = swCorner;
        nearestCornerToPlayerCarDistance = initialPlayerCarPosition.copy().sub(swCorner).mag();
    }
    if (initialPlayerCarPosition.copy().sub(seCorner).mag() < nearestCornerToPlayerCarDistance) {
        nearestCornerToPlayerCar = seCorner;
        nearestCornerToPlayerCarDistance = initialPlayerCarPosition.copy().sub(seCorner).mag();
    }
    PVector directionToNearestCornerFromPlayerCar = initialPlayerCarPosition.copy().sub(nearestCornerToPlayerCar);
    float initialPlayerCarOrientation = directionToNearestCornerFromPlayerCar.heading();
    int playerLives = playerCar.lives;
    int playerCarType = playerCar.type;
    playerCar = new PlayerCar(PLAYER_CAR_WIDTH, PLAYER_CAR_HEIGHT, initialPlayerCarPosition, initialPlayerCarOrientation, PLAYER_CAR_BRAKING_POWER, PLAYER_CAR_MAX_SPEED, PLAYER_CAR_MAX_ACCELERATION, PLAYER_CAR_MAX_STEERING, PLAYER_CAR_FRICTION, PLAYER_CAR_FRICTION_MULTIPLIER, GAME_WIDTH, GAME_HEIGHT, PLAYER_CAR_MAX_LIVES, MAX_BOOST_TIMER, MAX_PULSE_TIMER, BOOST_COOLDOWN, PULSE_SIZE, PULSE_COOLDOWN);
    playerCar.setLives(playerLives);
    playerCar.setType(playerCarType);

    // Reset police cars
    policeCars = new ArrayList<PoliceCar>();
    for (int i = 0; i < numPoliceCars; i++) {
        PVector initialPoliceCarPosition = new PVector(random(50, GAME_WIDTH-50), random(50, GAME_HEIGHT-50));
        PVector closestPoliceCar = new PVector(0, 0);
        float closestPoliceCarDistance = Float.MAX_VALUE;
        for (PoliceCar policeCar : policeCars) {
            float distance = initialPoliceCarPosition.copy().sub(policeCar.position).mag();
            if ((distance != 0.0) && (distance < closestPoliceCarDistance)) {
                closestPoliceCar = policeCar.position.copy();
                closestPoliceCarDistance = distance;
            }
        }
        while ((initialPoliceCarPosition.copy().sub(initialPlayerCarPosition).mag() < PLAYER_CAR_SAFE_ZONE) || (initialPoliceCarPosition.copy().sub(closestPoliceCar).mag() < POLICE_CAR_VISION_RADIUS)) {
            initialPoliceCarPosition = new PVector(random(50, GAME_WIDTH-50), random(50, GAME_HEIGHT-50));
            for (PoliceCar policeCar : policeCars) {
                float distance = initialPoliceCarPosition.copy().sub(policeCar.position).mag();
                if ((distance != 0.0) && (distance < closestPoliceCarDistance)) {
                    closestPoliceCar = policeCar.position.copy();
                    closestPoliceCarDistance = distance;
                }
            }
        }
        float initialPoliceCarOrientation = random(0, PI) - random(-PI, 0);
        PoliceCar newPoliceCar = new PoliceCar(POLICE_CAR_WIDTH, POLICE_CAR_HEIGHT, i, initialPoliceCarPosition, initialPoliceCarOrientation, POLICE_CAR_MAX_SPEED, POLICE_CAR_MAX_ACCELERATION, playerCar, GAME_WIDTH, GAME_HEIGHT);
        policeCars.add(newPoliceCar);
    }

    // Reset humans
    humans = new ArrayList<Human>();
    for (int i = 0; i < numHumans; i++) {
        PVector initialHumanPosition = new PVector(random(50, GAME_WIDTH-50), random(50, GAME_HEIGHT-50));
        PVector closestPoliceCar = new PVector(0, 0);
        float closestPoliceCarDistance = Float.MAX_VALUE;
        for (PoliceCar policeCar : policeCars) {
            float distance = initialHumanPosition.copy().sub(policeCar.position).mag();
            if (distance < closestPoliceCarDistance) {
                closestPoliceCar = policeCar.position.copy();
                closestPoliceCarDistance = distance;
            }
        }
        PVector closestOtherHuman = new PVector(0, 0);
        float closestOtherHumanDistance = Float.MAX_VALUE;
        for (Human human : humans) {
            float distance = initialHumanPosition.copy().sub(human.position).mag();
            if ((distance != 0.0) && (distance < closestOtherHumanDistance)) {
                closestOtherHuman = human.position.copy();
                closestOtherHumanDistance = distance;
            }
        }
        while ((initialHumanPosition.copy().sub(initialPlayerCarPosition).mag() < HUMAN_SAFE_ZONE) || (initialHumanPosition.copy().sub(closestPoliceCar).mag() < HUMAN_SAFE_ZONE) || (initialHumanPosition.copy().sub(closestOtherHuman).mag() < HUMAN_SAFE_ZONE) || (initialHumanPosition.copy().sub(closestOtherHuman).mag() < HUMAN_SAFE_ZONE)) {
            initialHumanPosition = new PVector(random(50, GAME_WIDTH-50), random(50, GAME_HEIGHT-50));
            for (PoliceCar policeCar : policeCars) {
                float distance = initialHumanPosition.copy().sub(policeCar.position).mag();
                if (distance < closestPoliceCarDistance) {
                    closestPoliceCar = policeCar.position.copy();
                    closestPoliceCarDistance = distance;
                }
            }
            for (Human human : humans) {
                float distance = initialHumanPosition.copy().sub(human.position).mag();
                if ((distance != 0.0) && (distance < closestOtherHumanDistance)) {
                    closestOtherHuman = human.position.copy();
                    closestOtherHumanDistance = distance;
                }
            }
        }
        Human newHuman = new Human(HUMAN_SIZE, initialHumanPosition, new PVector(random(-HUMAN_MAX_SPEED, HUMAN_MAX_SPEED), random(-HUMAN_MAX_SPEED, HUMAN_MAX_SPEED)), GAME_WIDTH, GAME_HEIGHT);
        humans.add(newHuman);
    }
}

// Reset all game parameters apart from unlocks to allow player to play again after game over
void resetWaves() {
    // Reset wave parameters
    numHumans = INITIAL_HUMAN_COUNT;
    numPoliceCars = INITIAL_POLICE_CAR_COUNT;
    POLICE_CAR_MAX_SPEED = INITIAL_POLICE_CAR_MAX_SPEED;

    // Reset wave and cash
    wave = 1;
    cash = 0;
    cashEarned = 0;

    // Reset highest wave flag
    highestWaveAchieved = false;

    // Reset air strike
    airStrike.reset();

    // Reset wave start countdown
    waveStarted = false;
    waveStartCountdown = (60 * 3)-20;

    // Reset humans killed
    humansKilled = 0;

    // Reset map
    map = new Map(GAME_WIDTH, GAME_HEIGHT, MAP_RESOLUTION, NUM_DECORATIONS, DECORATION_SIZE, DECORATION_OFFSET);
    map.generate();

    // Reset player car
    PVector initialPlayerCarPosition = new PVector(random(50, GAME_WIDTH-50), random(50, GAME_HEIGHT-50));
    PVector nwCorner = new PVector(0, 0);
    PVector neCorner = new PVector(GAME_WIDTH, 0);
    PVector swCorner = new PVector(0, GAME_HEIGHT);
    PVector seCorner = new PVector(GAME_WIDTH, GAME_HEIGHT);
    PVector nearestCornerToPlayerCar = new PVector(GAME_WIDTH/2, GAME_HEIGHT/2);
    float nearestCornerToPlayerCarDistance = Float.MAX_VALUE;
    if (initialPlayerCarPosition.copy().sub(nwCorner).mag() < nearestCornerToPlayerCarDistance) {
        nearestCornerToPlayerCar = nwCorner;
        nearestCornerToPlayerCarDistance = initialPlayerCarPosition.copy().sub(nwCorner).mag();
    }
    if (initialPlayerCarPosition.copy().sub(neCorner).mag() < nearestCornerToPlayerCarDistance) {
        nearestCornerToPlayerCar = neCorner;
        nearestCornerToPlayerCarDistance = initialPlayerCarPosition.copy().sub(neCorner).mag();
    }
    if (initialPlayerCarPosition.copy().sub(swCorner).mag() < nearestCornerToPlayerCarDistance) {
        nearestCornerToPlayerCar = swCorner;
        nearestCornerToPlayerCarDistance = initialPlayerCarPosition.copy().sub(swCorner).mag();
    }
    if (initialPlayerCarPosition.copy().sub(seCorner).mag() < nearestCornerToPlayerCarDistance) {
        nearestCornerToPlayerCar = seCorner;
        nearestCornerToPlayerCarDistance = initialPlayerCarPosition.copy().sub(seCorner).mag();
    }
    PVector directionToNearestCornerFromPlayerCar = initialPlayerCarPosition.copy().sub(nearestCornerToPlayerCar);
    float initialPlayerCarOrientation = directionToNearestCornerFromPlayerCar.heading();
    int playerCarType = playerCar.type;
    playerCar = new PlayerCar(PLAYER_CAR_WIDTH, PLAYER_CAR_HEIGHT, initialPlayerCarPosition, initialPlayerCarOrientation, PLAYER_CAR_BRAKING_POWER, PLAYER_CAR_MAX_SPEED, PLAYER_CAR_MAX_ACCELERATION, PLAYER_CAR_MAX_STEERING, PLAYER_CAR_FRICTION, PLAYER_CAR_FRICTION_MULTIPLIER, GAME_WIDTH, GAME_HEIGHT, PLAYER_CAR_MAX_LIVES, MAX_BOOST_TIMER, MAX_PULSE_TIMER, BOOST_COOLDOWN, PULSE_SIZE, PULSE_COOLDOWN);
    playerCar.setType(playerCarType);

    // Reset police cars
    policeCars = new ArrayList<PoliceCar>();
    for (int i = 0; i < numPoliceCars; i++) {
        PVector initialPoliceCarPosition = new PVector(random(50, GAME_WIDTH-50), random(50, GAME_HEIGHT-50));
        PVector closestPoliceCar = new PVector(0, 0);
        float closestPoliceCarDistance = Float.MAX_VALUE;
        for (PoliceCar policeCar : policeCars) {
            float distance = initialPoliceCarPosition.copy().sub(policeCar.position).mag();
            if ((distance != 0.0) && (distance < closestPoliceCarDistance)) {
                closestPoliceCar = policeCar.position.copy();
                closestPoliceCarDistance = distance;
            }
        }
        while ((initialPoliceCarPosition.copy().sub(initialPlayerCarPosition).mag() < PLAYER_CAR_SAFE_ZONE) || (initialPoliceCarPosition.copy().sub(closestPoliceCar).mag() < POLICE_CAR_VISION_RADIUS)) {
            initialPoliceCarPosition = new PVector(random(50, GAME_WIDTH-50), random(50, GAME_HEIGHT-50));
            for (PoliceCar policeCar : policeCars) {
                float distance = initialPoliceCarPosition.copy().sub(policeCar.position).mag();
                if ((distance != 0.0) && (distance < closestPoliceCarDistance)) {
                    closestPoliceCar = policeCar.position.copy();
                    closestPoliceCarDistance = distance;
                }
            }
        }
        float initialPoliceCarOrientation = random(0, PI) - random(-PI, 0);
        PoliceCar newPoliceCar = new PoliceCar(POLICE_CAR_WIDTH, POLICE_CAR_HEIGHT, i, initialPoliceCarPosition, initialPoliceCarOrientation, POLICE_CAR_MAX_SPEED, POLICE_CAR_MAX_ACCELERATION, playerCar, GAME_WIDTH, GAME_HEIGHT);
        policeCars.add(newPoliceCar);
    }

    // Reset humans
    humans = new ArrayList<Human>();
    for (int i = 0; i < numHumans; i++) {
        PVector initialHumanPosition = new PVector(random(50, GAME_WIDTH-50), random(50, GAME_HEIGHT-50));
        PVector closestPoliceCar = new PVector(0, 0);
        float closestPoliceCarDistance = Float.MAX_VALUE;
        for (PoliceCar policeCar : policeCars) {
            float distance = initialHumanPosition.copy().sub(policeCar.position).mag();
            if (distance < closestPoliceCarDistance) {
                closestPoliceCar = policeCar.position.copy();
                closestPoliceCarDistance = distance;
            }
        }
        PVector closestOtherHuman = new PVector(0, 0);
        float closestOtherHumanDistance = Float.MAX_VALUE;
        for (Human human : humans) {
            float distance = initialHumanPosition.copy().sub(human.position).mag();
            if ((distance != 0.0) && (distance < closestOtherHumanDistance)) {
                closestOtherHuman = human.position.copy();
                closestOtherHumanDistance = distance;
            }
        }
        while ((initialHumanPosition.copy().sub(initialPlayerCarPosition).mag() < HUMAN_SAFE_ZONE) || (initialHumanPosition.copy().sub(closestPoliceCar).mag() < HUMAN_SAFE_ZONE) || (initialHumanPosition.copy().sub(closestOtherHuman).mag() < HUMAN_SAFE_ZONE) || (initialHumanPosition.copy().sub(closestOtherHuman).mag() < HUMAN_SAFE_ZONE)) {
            initialHumanPosition = new PVector(random(50, GAME_WIDTH-50), random(50, GAME_HEIGHT-50));
            for (PoliceCar policeCar : policeCars) {
                float distance = initialHumanPosition.copy().sub(policeCar.position).mag();
                if (distance < closestPoliceCarDistance) {
                    closestPoliceCar = policeCar.position.copy();
                    closestPoliceCarDistance = distance;
                }
            }
            for (Human human : humans) {
                float distance = initialHumanPosition.copy().sub(human.position).mag();
                if ((distance != 0.0) && (distance < closestOtherHumanDistance)) {
                    closestOtherHuman = human.position.copy();
                    closestOtherHumanDistance = distance;
                }
            }
        }
        Human newHuman = new Human(HUMAN_SIZE, initialHumanPosition, new PVector(random(-HUMAN_MAX_SPEED, HUMAN_MAX_SPEED), random(-HUMAN_MAX_SPEED, HUMAN_MAX_SPEED)), GAME_WIDTH, GAME_HEIGHT);
        humans.add(newHuman);
    }
}

// Handle keyboard inputs
void keyPressed() {
    if (key == 'w' || key == 'W') {
        playerCar.accelerate();
    } else if (key == 's' || key == 'S') {
        playerCar.brake();
    } else if (key == 'a' || key == 'A') {
        playerCar.steerLeft();
    } else if (key == 'd' || key == 'D') {
        playerCar.steerRight();
    } else if (key == ' ') {
        if (boostUnlocked) {
            if (!playerCar.boosting && !playerCar.boostUsed) {
                boost.rewind();
                if (!muted) {
                    boost.play();
                }
            }
            playerCar.boost();
        }
    } else if (key == 'e' || key == 'E') {
        if (pulseUnlocked) {
            if (!playerCar.pulsing && !playerCar.pulseUsed) {
                pulse.rewind();
                if (!muted) {
                    pulse.play();
                }
            }
            playerCar.pulse();
        }
    } else if (key == 'j' || key == 'J') {
        showQuadTree = !showQuadTree;
    } else if (key == 'q' || key == 'Q') {
        if (gameState.phase == 5) {
            // Reset wave start countdown
            waveStarted = false;
            waveStartCountdown = (60 * 3)-20;
            gameState.visitPaused();
        } else if (gameState.phase == 7) {
            gameState.visitWave();
        }
    }
    // Developer tools
    if (devToolsOn) {
        if (key == 'z' || key == 'Z') {
            gameState.visitHomepage();
        } else if (key == 'x' || key == 'X') {
            gameState.visitGuide();
        } else if (key == 'c' || key == 'C') {
            gameState.visitCarSelect();
        } else if (key == 'v' || key == 'V') {
            gameState.visitItemShop();
        } else if (key == 'b' || key == 'B') {
            gameState.visitPreWave();
        } else if (key == 'n' || key == 'N') {
            gameState.visitWave();
        } else if (key == 'm' || key == 'M') {
            gameState.visitPostWave();
        } else if (key == ',' || key == '<') {
            gameState.visitPaused();
        } else if (key == '.' || key == '>') {
            gameState.visitEndgame();
        } else if (key == '/' || key == '?') {
            gameState.visitItemGuide();
        } else if (keyCode == UP) {
            playerCar.setType(0);
        } else if (keyCode == LEFT) {
            playerCar.setType(1);
        } else if (keyCode == DOWN) {
            playerCar.setType(2);
        } else if (keyCode == RIGHT) {
            playerCar.setType(3);
        } else if (key == '1') {
            ambulanceUnlocked = true;
        } else if (key == '2') {
            sportsCarUnlocked = true;
        } else if (key == '3') {
            f1CarUnlocked = true;
        } else if (key == '4') {
            offroadTyresUnlocked = true;
        } else if (key == '5') {
            boostUnlocked = true;
        } else if (key == '6') {
            pulseUnlocked = true;
        } else if (key == '7') {
            airStrikeUnlocked = true;
        } else if (key == '0') {
            cash += 1000;
        } else if (key == '-') {
            playerCar.lives++;
        }
    }
}

// Handle key released keyboard inputs
void keyReleased() {
    if (key == 'w' || key == 'W') {
        playerCar.stopAccelerating();
    } else if (key == 's' || key == 'S') {
        playerCar.stopBraking();
    } else if (key == 'a' || key == 'A') {
        playerCar.stopSteeringLeft();
    } else if (key == 'd' || key == 'D') {
        playerCar.stopSteeringRight();
    }
}

// Handle mouse click inputs
void mousePressed() {
    if (gameState.phase == 0) { // Homepage
        if (mouseY > GAME_HEIGHT) {
            if (mouseX < GAME_WIDTH/3) {
                totalGamesPlayed++;
                gameState.visitPreWave();
            } else if (mouseX > 2*GAME_WIDTH/3) {
                gameState.visitCarSelect();
            } else {
                gameState.visitGuide();
            }
        } else if (mouseY < DATABAR_HEIGHT) {
            if (mouseX < 3*DATABAR_HEIGHT) {
                gameState.visitStats();
            } else if (mouseX > GAME_WIDTH-(3*DATABAR_HEIGHT)) {
                devToolsOn = !devToolsOn;
            } else if (((GAME_WIDTH/2)-(1.5*DATABAR_HEIGHT) < mouseX) && (mouseX < (GAME_WIDTH/2)+(1.5*DATABAR_HEIGHT))) {
                if (muted) {
                    muted = false;
                    music.loop();
                } else {
                    muted = true;
                    music.pause();
                }
            }
        }
    } else if (gameState.phase == 1) {  // Guide
        if (mouseY > GAME_HEIGHT) {
            gameState.visitHomepage();
        }
    } else if (gameState.phase == 2) {  // CarSelect
        if (mouseY > GAME_HEIGHT) {
            gameState.previous();
        } else if ((mouseY > (4*GAME_HEIGHT/5 - 1.25*PLAYER_CAR_WIDTH)) && (mouseY < (4*GAME_HEIGHT/5 + 1.25*PLAYER_CAR_WIDTH))) {
            if ((mouseX > (GAME_WIDTH/5 - 1.25*PLAYER_CAR_WIDTH)) && (mouseX < (GAME_WIDTH/5 + 1.25*PLAYER_CAR_WIDTH))) {
                playerCar.setType(0);
            } else if ((mouseX > (2*GAME_WIDTH/5 - 1.25*PLAYER_CAR_WIDTH)) && (mouseX < (2*GAME_WIDTH/5 + 1.25*PLAYER_CAR_WIDTH))) {
                if (ambulanceUnlocked) {
                    playerCar.setType(1);
                }
            } else if ((mouseX > (3*GAME_WIDTH/5 - 1.25*PLAYER_CAR_WIDTH)) && (mouseX < (3*GAME_WIDTH/5 + 1.25*PLAYER_CAR_WIDTH))) {
                if (sportsCarUnlocked) {
                    playerCar.setType(2);
                }
            } else if ((mouseX > (4*GAME_WIDTH/5 - 1.25*PLAYER_CAR_WIDTH)) && (mouseX < (4*GAME_WIDTH/5 + 1.25*PLAYER_CAR_WIDTH))) {
                if (f1CarUnlocked) {
                    playerCar.setType(3);
                }
            }
        }
    } else if (gameState.phase == 3) { // ItemShop
        if (mouseY > GAME_HEIGHT) {
            if (mouseX < GAME_WIDTH/3) {
                gameState.visitCarSelect();
            } else if (mouseX > 2*GAME_WIDTH/3) {
                gameState.visitPostWave();
            } else {
                gameState.visitItemGuide();
            }
        } else if ((mouseY > GAME_HEIGHT/2 - 1.25*PLAYER_CAR_WIDTH) && (mouseY < GAME_HEIGHT/2 + 1.25*PLAYER_CAR_WIDTH)) {
            if ((mouseX > GAME_WIDTH/4 - 1.25*PLAYER_CAR_WIDTH) && (mouseX < GAME_WIDTH/4 + 1.25*PLAYER_CAR_WIDTH)) {
                // Ambulance
                if (!ambulanceUnlocked && cash >= AMBULANCE_COST) {
                    cash -= AMBULANCE_COST;
                    totalCashSpent += AMBULANCE_COST;
                    ambulanceUnlocked = true;
                    cashSpent.rewind();
                    if (!muted) {
                        cashSpent.play();
                    }
                }
            } else if ((mouseX > 2*GAME_WIDTH/4 - 1.25*PLAYER_CAR_WIDTH) && (mouseX < 2*GAME_WIDTH/4 + 1.25*PLAYER_CAR_WIDTH)) {
                // Sports car
                if (!sportsCarUnlocked && cash >= SPORTS_CAR_COST) {
                    cash -= SPORTS_CAR_COST;
                    totalCashSpent += SPORTS_CAR_COST;
                    sportsCarUnlocked = true;
                    cashSpent.rewind();
                    if (!muted) {
                        cashSpent.play();
                    }
                }
            } else if ((mouseX > 3*GAME_WIDTH/4 - 1.25*PLAYER_CAR_WIDTH) && (mouseX < 3*GAME_WIDTH/4 + 1.25*PLAYER_CAR_WIDTH)) {
                // F1 car
                if (!f1CarUnlocked && cash >= F1_CAR_COST) {
                    cash -= F1_CAR_COST;
                    totalCashSpent += F1_CAR_COST;
                    f1CarUnlocked = true;
                    cashSpent.rewind();
                    if (!muted) {
                        cashSpent.play();
                    }
                }
            }
        } else if ((mouseY > 4*GAME_HEIGHT/5 - 1.25*PLAYER_CAR_WIDTH) && (mouseY < 4*GAME_HEIGHT/5 + 1.25*PLAYER_CAR_WIDTH)) {
            if ((mouseX > GAME_WIDTH/5 - 1.25*PLAYER_CAR_WIDTH) && (mouseX < GAME_WIDTH/5 + 1.25*PLAYER_CAR_WIDTH)) {
                // Offroad tyres
                if (!offroadTyresUnlocked && cash >= OFFROAD_TYRES_COST) {
                    cash -= OFFROAD_TYRES_COST;
                    totalCashSpent += OFFROAD_TYRES_COST;
                    offroadTyresUnlocked = true;
                    cashSpent.rewind();
                    if (!muted) {
                        cashSpent.play();
                    }
                }
            } else if ((mouseX > 2*GAME_WIDTH/5 - 1.25*PLAYER_CAR_WIDTH) && (mouseX < 2*GAME_WIDTH/5 + 1.25*PLAYER_CAR_WIDTH)) {
                // Boost
                if (!boostUnlocked && cash >= BOOST_COST) {
                    cash -= BOOST_COST;
                    totalCashSpent += BOOST_COST;
                    boostUnlocked = true;
                    cashSpent.rewind();
                    if (!muted) {
                        cashSpent.play();
                    }
                }
            } else if ((mouseX > 3*GAME_WIDTH/5 - 1.25*PLAYER_CAR_WIDTH) && (mouseX < 3*GAME_WIDTH/5 + 1.25*PLAYER_CAR_WIDTH)) {
                // Pulse
                if (!pulseUnlocked && cash >= PULSE_COST) {
                    cash -= PULSE_COST;
                    totalCashSpent += PULSE_COST;
                    pulseUnlocked = true;
                    cashSpent.rewind();
                    if (!muted) {
                        cashSpent.play();
                    }
                }
            } else if ((mouseX > 4*GAME_WIDTH/5 - 1.25*PLAYER_CAR_WIDTH) && (mouseX < 4*GAME_WIDTH/5 + 1.25*PLAYER_CAR_WIDTH)) {
                // Air Strike
                if (!airStrikeUnlocked && cash >= AIR_STRIKE_COST) {
                    cash -= AIR_STRIKE_COST;
                    totalCashSpent += AIR_STRIKE_COST;
                    airStrikeUnlocked = true;
                    cashSpent.rewind();
                    if (!muted) {
                        cashSpent.play();
                    }
                }
            }
        }
    } else if (gameState.phase == 4) { // PreWave
        if (mouseY > GAME_HEIGHT) {
            gameState.visitWave();
        }
    } else if (gameState.phase == 5) { // Wave
        if (!airStrike.used && !airStrike.exploding && airStrikeUnlocked && waveStarted) {
            airStrike.drop(mouseX, mouseY);
            explosion.rewind();
            if (!muted) {
                explosion.play();
            }
        }
    } else if (gameState.phase == 6) { // PostWave
        if (mouseY > GAME_HEIGHT) {
            if (mouseX < GAME_WIDTH/2) {
                waveStarted = false;
                setupNextWave();
                gameState.visitPreWave();
            } else {
                gameState.visitItemShop();
            }
        }
    } else if (gameState.phase == 8) { // GameOver
        if (mouseY > GAME_HEIGHT) {
            resetWaves();
            gameState.visitHomepage();
        }
    } else if (gameState.phase == 9) { // ItemGuide
        if (mouseY > GAME_HEIGHT) {
            gameState.visitItemShop();
        }
    } else if (gameState.phase == 10) {  // Stats
        if (mouseY > GAME_HEIGHT) {
            gameState.visitHomepage();
        }
    }
}
