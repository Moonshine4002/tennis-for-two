# Tennis for Two
**A 2D demo game project made with the Godot engine, based on the pioneering Tennis for Two game from the 1950s.
This is a two-player game—play it with your friends!**

## Introduction
Tennis for Two is inspired by one of the world's earliest games, replicating the gameplay of the original Tennis for Two. This version is designed for both single-player (with a basic AI) and two players.

## Gameplay
Players take turns hitting the ball. You can only hit the ball once per turn when it is on your side.
The player with ball possession loses if the ball *hits the floor twice*, *hits the net* or *goes out of bounds*.

## Controls
Currently only the left mouse button is available. You can *hold the mouse for greater force*.

## Known Issues
The server always returns a "can't create" error in html5 version.

# Archive - Old TfT

## Gameplay
Compared to the latest version, the player also loses if the ball *exceeds the screen height*.

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
- In version 1.3.2 and beyond, I designed the physics so that the paddle approaches the ball at a certain speed and hits it. If the paddle's speed is too low, it may cause the ball to move in the opposite direction (as if the ball was hit from the back of the paddle). I have temporarily decided to keep this design and not consider it a bug.
