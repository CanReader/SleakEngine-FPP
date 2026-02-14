#include "Game.hpp"
#include "Core/GameObject.hpp"
#include <Core/Scene.hpp>
#include "ECS/Components/MeshComponent.hpp"
#include "ECS/Components/TransformComponent.hpp"
#include "ECS/Components/MaterialComponent.hpp"
#include "Math/Vector.hpp"
#include <Lighting/DirectionalLight.hpp>
#include <Lighting/LightManager.hpp>
#include <Runtime/Material.hpp>

Game::Game() {
  bIsGameRunning = true;
}

Game::~Game() {
  SLEAK_LOG("The game has been destroyed. Cleaning up resources...");
}

bool Game::Initialize() {

    // --- Create scene ---
    mainScene = new Sleak::Scene("MainScene");
    AddScene(mainScene);

    // --- Create a material
    auto* mat = new Sleak::Material();
    mat->SetShader("assets/shaders/default_shader.hlsl");
    mat->SetDiffuseColor(
        (uint8_t)255, (uint8_t)255, (uint8_t)255);
    mat->SetSpecularColor(
        (uint8_t)255, (uint8_t)255, (uint8_t)255);
    mat->SetShininess(32.0f);
    mat->SetMetallic(0.0f);
    mat->SetRoughness(0.5f);
    mat->SetAO(1.0f);
    mat->SetOpacity(1.0f);
    auto cubeMaterial = Sleak::RefPtr<Sleak::Material>(mat);

    // --- Create a cube ---
    auto cube = Sleak::GameObject::CreateCube(
        Sleak::Vector3D(0, 0, 0));
    cube->SetTag("Cube");
    cube->AddComponent<Sleak::MaterialComponent>(cubeMaterial);
    mainScene->AddObject(cube);

    // --- Activate the scene ---
    SetActiveScene(mainScene);

    // --- Add a directional light (sun) ---
    auto* sun = new Sleak::DirectionalLight("Sun");
    sun->SetDirection(Sleak::Math::Vector3D(-0.4f, -0.8f, -0.4f));
    sun->SetColor(1.0f, 0.98f, 0.95f);
    sun->SetIntensity(2.0f);
    mainScene->AddObject(sun);

    // --- Configure scene ambient lighting ---
    auto* lm = mainScene->GetLightManager();
    if (lm) {
        lm->SetAmbientColor(0.15f, 0.15f, 0.2f);
        lm->SetAmbientIntensity(1.0f);
    }

    return true;
}

void Game::Begin() {
}

void Game::Loop(float DeltaTime) {
}

int Game::Run() {
  return EXIT_SUCCESS;
}
