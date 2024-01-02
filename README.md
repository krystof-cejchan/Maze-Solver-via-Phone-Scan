
# Maze Solver via Phone Scan

[![flutter](https://github.com/krystof-cejchan/Maze-Solver-via-Phone-Scan/actions/workflows/flutter.yml/badge.svg)](https://github.com/krystof-cejchan/Maze-Solver-via-Phone-Scan/actions/workflows/flutter.yml)

- Table of Contents
  * [Introduction](#introduction)
  * [Smartphone client](#smartphone-client)
    + [Features](#features)
  * [Arduino robot](#arduino-robot)
    + [Features](#features-1)

## Introduction

Welcome to my semestral project where a Flutter app turns your phone into a maze solver using the camera as an input and A* algorithm to find the shortest path. It sends the found path via Bluetooth to an Arduino. The Arduino, my project's other half, follows the path, making maze-solving a hands-free adventure.

## Smartphone client

Using Flutter with Dart, I created a hybrid application that runs on Android and iOS.

### Features

-   **Image Input:** Capture or select an image from your device's gallery to serve as the maze for the adventure.
-   **Coordinate Selection:** Choose starting and ending coordinates on the maze image.
-   **Shortest Path Finder:** The app employs an efficient A* algorithm to find the shortest path from the selected start to the end.
-   **Direction Rewriting:** Transform complex path directions into user-friendly instructions at crossroads, simplifying the navigation process.
-   **Arduino Integration:** Send the optimized directions to an Arduino device, allowing it to follow the instructions and conquer the maze.

## Arduino robot

Using an Arduino Nano microcontroller, I created the final piece of this project. The robot receives instructions via Bluetooth from the smartphone client and conquers the maze.

### Features

-   **Bluetooth Connectivity:** Wirelessly establish a connection from smartphone to the Arduino robot
-   **Real-time Data Reception:** Receive real-time instructions from the app via Bluetooth, guiding your robot through the maze with efficiency.
-   **Maze Navigation:** The Arduino robot interprets the received data, making informed decisions to successfully navigate the maze and reach the endpoint.

<hr>

©[Kryštof Čejchan](https://github.com/krystof-cejchan) 2023
