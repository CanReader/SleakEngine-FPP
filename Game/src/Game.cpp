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
#include <Runtime/Skybox.hpp>

using namespace Sleak;
using namespace Sleak::Math;

static RefPtr<Material> CreateLevelMaterial(uint8_t r, uint8_t g, uint8_t b) {
    auto* mat = new Material();
    mat->SetShader("assets/shaders/default_shader.hlsl");
    mat->SetDiffuseColor(r, g, b);
    mat->SetSpecularColor((uint8_t)200, (uint8_t)200, (uint8_t)200);
    mat->SetShininess(16.0f);
    mat->SetMetallic(0.0f);
    mat->SetRoughness(0.7f);
    mat->SetAO(1.0f);
    mat->SetOpacity(1.0f);
    return RefPtr<Material>(mat);
}

static GameObject* CreateLevelCube(const Vector3D& position, const Vector3D& scale,
                                    const RefPtr<Material>& material,
                                    const std::string& name) {
    auto* cube = GameObject::CreateCube(Vector3D(0, 0, 0));
    cube->SetTag(name);

    auto* transform = cube->GetComponent<TransformComponent>();
    if (transform) {
        transform->SetPosition(position);
        transform->SetScale(scale);
    }

    // CreateCube already adds a MaterialComponent with default material — replace it
    auto* matComp = cube->GetComponent<MaterialComponent>();
    if (matComp) {
        matComp->SetMaterial(material);
    }

    return cube;
}

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

    // --- Materials ---
    auto floorMaterial = CreateLevelMaterial(180, 180, 180);  // Light gray
    auto wallMaterial  = CreateLevelMaterial(140, 150, 160);  // Blue-gray
    auto boxMaterial   = CreateLevelMaterial(200, 160, 100);  // Warm tan

    // --- Floor: 20x20 platform ---
    mainScene->AddObject(
        CreateLevelCube({0, -0.5f, 0}, {20, 1, 20}, floorMaterial, "Floor"));

    // --- Walls ---
    mainScene->AddObject(
        CreateLevelCube({0, 1, 10.5f}, {20, 3, 1}, wallMaterial, "WallNorth"));
    mainScene->AddObject(
        CreateLevelCube({0, 1, -10.5f}, {20, 3, 1}, wallMaterial, "WallSouth"));
    mainScene->AddObject(
        CreateLevelCube({10.5f, 1, 0}, {1, 3, 20}, wallMaterial, "WallEast"));
    mainScene->AddObject(
        CreateLevelCube({-10.5f, 1, 0}, {1, 3, 20}, wallMaterial, "WallWest"));

    // --- Obstacle boxes ---
    mainScene->AddObject(
        CreateLevelCube({3, 0.5f, 3}, {1, 1, 1}, boxMaterial, "Box1"));
    mainScene->AddObject(
        CreateLevelCube({-4, 0.5f, -2}, {1.5f, 1, 1.5f}, boxMaterial, "Box2"));
    mainScene->AddObject(
        CreateLevelCube({6, 0.5f, -5}, {2, 1, 1}, boxMaterial, "Box3"));
    mainScene->AddObject(
        CreateLevelCube({-2, 1.0f, 5}, {1, 2, 1}, boxMaterial, "Box4"));

    // --- Create skybox ---
    auto* skybox = new Sleak::Skybox();
    mainScene->SetSkybox(skybox);

    // --- Activate the scene ---
    SetActiveScene(mainScene);

    // --- Add a directional light (sun) ---
    auto* sun = new Sleak::DirectionalLight("Sun");
    sun->SetDirection(Vector3D(-0.4f, -0.8f, -0.4f));
    sun->SetColor(1.0f, 0.98f, 0.92f);   // warm sunlight
    sun->SetIntensity(1.8f);
    sun->SetCastShadows(true);
    sun->SetShadowBias(0.003f);
    sun->SetShadowNormalBias(0.04f);
    sun->SetLightSize(1.5f);
    sun->SetShadowFrustumSize(20.0f);
    sun->SetShadowDistance(30.0f);
    sun->SetShadowNearPlane(0.1f);
    sun->SetShadowFarPlane(70.0f);
    mainScene->AddObject(sun);

    // --- Configure scene ambient lighting ---
    // Sky-blue ambient — hemisphere shader blends this with warm ground bounce
    auto* lm = mainScene->GetLightManager();
    if (lm) {
        lm->SetAmbientColor(0.6f, 0.65f, 0.75f);  // neutral sky
        lm->SetAmbientIntensity(0.25f);
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
