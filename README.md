# Tennis for Two
A 2D demo game project made with the Godot engine and based on the pioneering Tennis for Two game from the 1950s.
This is a two-player game. Play it with your friends!

## Introduction
Tennis for Two is inspired by one of the world's earliest games, mimicking the gameplay of the original Tennis for Two. This version is designed for two players.

## Gameplay
Players take turns hitting the ball. You can only hit the ball when it is on your side, and you can only hit it once per turn.
The player with ball possession loses if the ball hits the net, goes out of bounds, or exceeds the screen height.

## Controls
- Player One
Tab: Hit the ball
A/D: Adjust angle
W/S: Adjust power
- Player Two
Enter: Hit the ball
J/L: Adjust angle
I/K: Adjust power

## Known Issues
- If the ball was moving too fast in the previous turn, the player may not be able to hit the ball.
- In version 1.3.2, I designed the physics so that the paddle approaches the ball at a certain speed and hits it. If the paddle's speed is too low, it may cause the ball to move in the opposite direction (as if the ball was hit from the back of the paddle). I have temporarily decided to keep this design and not consider it a bug.
