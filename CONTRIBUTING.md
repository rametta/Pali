# Contributing to Pali

This document outlines how to contribute to the Pali project, such as setting up your development environment, running the game, and contributing code.

- [Contributing to Pali](#contributing-to-pali)
  - [Setting Up Your Development Environment](#setting-up-your-development-environment)
  - [Running the Game](#running-the-game)
    - [Configure server address](#configure-server-address)
    - [Enable the Create Server button](#enable-the-create-server-button)
    - [Run the game](#run-the-game)
  - [Contributing Code](#contributing-code)

## Setting Up Your Development Environment

1. Install [Godot Engine](https://godotengine.org/download)
2. Clone this repository
3. Open the project in Godot

## Running the Game

Since this is a multiplayer game, you will need to run a dedicated server and connect to it with two clients.

### Configure server address

We need to configure the server address in the `Global.gd` script and then tell Godot to run three instances of the game in debug mode.

1. Open the `Global.gd` script
2. Set the `SERVER_ADDRESS` to `localhost`
3. In the Godot UI, click Debug -> Run Multiple Instances -> Run 3 Instances

### Enable the Create Server button

To start a local server, e need to make sure the `Create Server (debug only)` button will appear on the main menu. To do this, we need to check `Scenes/MainMenuUI/MainMenuUI.gd` and make sure the `Create Server (debug only)` button is visible by toggling `Toggle Visibility` button next to the `CreateServerBtn`.

### Run the game

Once you have configured Godot to start three instances and ensured the `CreateServerBtn` is visible, you can run the game.

1. Click the play button in the Godot UI
2. In one of the three instances, click the `Create Server (debug only)` button
3. In the other two instances, click the `Join Server` button after entering a player name

## Contributing Code

1. Fork this repository
2. Create a new branch for your feature or bug fix
3. Make your changes
4. Push your changes to your fork
5. Create a pull request to this repository
6. Wait for a maintainer to review your changes
7. Make any requested changes
8. Once your changes are approved, they will be merged into the main branch
