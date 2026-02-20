#include "Game.hpp"
#include "MainScene.hpp"

Game::Game() {
  bIsGameRunning = true;
}

Game::~Game() {
  SLEAK_LOG("The game has been destroyed. Cleaning up resources...");
}

bool Game::Initialize() {
    auto* scene = new MainScene("MainScene");
    AddScene(scene);
    SetActiveScene(scene);
    return true;
}

void Game::Begin() {
}

void Game::Loop(float DeltaTime) {
}
