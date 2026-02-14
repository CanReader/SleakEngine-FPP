/**
 * SCENE SYSTEM INTEGRATION GUIDE
 * ==============================
 *
 * This document explains how the Scene system works and how all components integrate.
 */

/*
 * ===== FLOW OVERVIEW =====
 *
 * 1. Application::Run(GameBase* game)
 *    └─> Game::Initialize()
 *        └─> Creates Scene("MainScene")
 *        └─> Adds GameObjects to scene (scene takes ownership)
 *        └─> Calls SetActiveScene(mainScene)
 *            └─> Deactivates old scene (if any)
 *            └─> Sets ActiveScene = mainScene
 *            └─> Calls mainScene->Activate()
 *                └─> Initializes all objects in scene
 *                └─> Calls OnActivate()
 *                └─> Calls Begin() (activates all objects, triggers OnEnable)
 *    └─> Game::Begin()
 *    └─> Main Loop:
 *        ├─> CoreWindow::Update()
 *        ├─> Renderer::BeginRender()
 *        ├─> FixedUpdate loop (accumulator-based, 60Hz fixed timestep)
 *        │   └─> Scene::FixedUpdate(fixedDeltaTime)
 *        │       └─> Root objects -> Component::FixedUpdate() (recursive to children)
 *        ├─> Scene::Update(DeltaTime)
 *        │   └─> Root objects -> Component::Update() (recursive to children)
 *        │   └─> ProcessPendingDestroy() — deferred object cleanup
 *        ├─> Scene::LateUpdate(DeltaTime)
 *        │   └─> Root objects -> Component::LateUpdate() (recursive to children)
 *        └─> Renderer::EndRender()
 */

/*
 * ===== CLASS RESPONSIBILITIES =====
 *
 * SceneBase (Abstract Base)
 * ─────────────────────────
 * • Owns all GameObjects (deletes them on unload/destroy)
 * • Lifecycle states: Unloaded, Loading, Active, Paused, Unloading
 * • Provides Initialize(), Begin(), Update(), FixedUpdate(), LateUpdate()
 * • Update loops iterate only ROOT objects (parent == nullptr)
 *   — children update recursively through their parent
 * • Deferred destruction: DestroyObject() marks objects, cleanup at end of Update()
 * • Object queries: FindObjectByName(), FindObjectByID(), FindObjectsByTag()
 * • State transitions: Load/Unload/Activate/Deactivate/Pause/Resume
 * • OnLoad()/OnUnload()/OnActivate()/OnDeactivate() virtual hooks
 *
 * Scene (Concrete Implementation)
 * ───────────────────────────────
 * • Inherits from SceneBase
 * • Implements lifecycle hooks (OnLoad, OnUnload, OnActivate, OnDeactivate)
 * • Logs scene lifecycle events via SLEAK_LOG
 * • bEnableFixedUpdate flag controls whether FixedUpdate runs
 * • Can be extended for specific game scenes (MainMenuScene, LevelScene, etc.)
 *
 * GameBase (Abstract Base)
 * ────────────────────────
 * • Owns all Scenes (deletes them in destructor)
 * • Manages List<SceneBase*> Scenes
 * • Tracks SceneBase* ActiveScene
 * • AddScene(scene) — adds scene to list
 * • RemoveScene(scene) — unloads, deletes, and removes from list
 * • SetActiveScene(scene) — activates a scene (auto initializes/begins it)
 * • GetActiveScene() — returns currently active scene
 * • Pure virtual: Initialize(), Begin(), Loop(), GetIsGameRunning()
 *
 * Game (Concrete Implementation)
 * ──────────────────────────────
 * • Inherits from GameBase
 * • Game::Initialize() is called ONCE by Application::Run()
 *   └─> Should create one or more scenes
 *   └─> Should populate scenes with GameObjects
 *   └─> Should call SetActiveScene(mainScene) to activate the first scene
 * • Game::Begin() is called ONCE after Initialize
 * • Game owns the game logic, scene management, and event handling
 *
 * Application
 * ───────────
 * • Creates Window and Renderer
 * • Calls Game::Initialize() and Game::Begin() once at startup
 * • Manages main game loop with three update phases:
 *   1. FixedUpdate — accumulator-based, 60Hz fixed timestep (for physics)
 *   2. Update — per-frame, variable timestep
 *   3. LateUpdate — after Update (for camera follow, post-processing logic)
 */

/*
 * ===== GAMEOBJECT FEATURES =====
 *
 * Tag System:
 * ───────────
 * • Every GameObject has a tag (default: "Untagged")
 * • SetTag("Enemy"), GetTag()
 * • Scene::FindObjectsByTag("Enemy") returns all matching objects
 *
 * Parent-Child Hierarchy:
 * ───────────────────────
 * • SetParent(parent) — sets parent, manages children lists automatically
 * • AddChild(child) — adds child (calls child->SetParent(this))
 * • RemoveChild(child) — detaches child from this parent
 * • HasParent(), HasChildren(), GetParent(), GetChildren()
 * • Children update recursively through parent's Update()
 * • Scene only iterates root objects (no parent) — children handled automatically
 * • Destroying a parent also destroys its children
 * • When a parent is deleted, children are detached (their parent becomes nullptr)
 *
 * Component Management:
 * ─────────────────────
 * • AddComponent<T>(args...) — creates and adds component
 * • RemoveComponent<T>() — calls OnDestroy, then removes
 * • GetComponent<T>() — returns first component of type T
 * • HasComponent<T>() — checks if component exists
 *
 * Deferred Destruction:
 * ─────────────────────
 * • scene->DestroyObject(obj) marks object for destruction
 * • Object and its children are cleaned up at end of Scene::Update()
 * • Safe to call during Update loops — no iterator invalidation
 */

/*
 * ===== COMPONENT LIFECYCLE =====
 *
 * Methods (all virtual, override as needed):
 *
 * • Initialize()     — called when scene initializes (or when added to initialized scene)
 * • OnEnable()       — called when owner GameObject becomes active
 * • Update(dt)       — called every frame (variable timestep)
 * • FixedUpdate(dt)  — called at fixed 60Hz timestep (for physics)
 * • LateUpdate(dt)   — called after all Update() calls
 * • OnDisable()      — called when owner GameObject becomes inactive
 * • OnDestroy()      — called before component is removed or owner is destroyed
 */

/*
 * ===== HOW TO USE THE SCENE SYSTEM =====
 *
 * Creating a Custom Scene:
 * ────────────────────────
 *
 * class MyLevel : public Sleak::Scene {
 * public:
 *     MyLevel() : Scene("MyLevel") {}
 *
 *     void OnLoad() override {
 *         SLEAK_LOG("Loading resources for MyLevel...");
 *     }
 *
 *     void OnActivate() override {
 *         SLEAK_LOG("MyLevel is now active!");
 *     }
 * };
 *
 *
 * Creating and Managing Game Objects:
 * ───────────────────────────────────
 *
 * bool Game::Initialize() {
 *     Sleak::Scene* level = new Sleak::Scene("Level1");
 *     AddScene(level);
 *
 *     // Create objects — scene takes ownership
 *     auto player = Sleak::GameObject::CreateCube(Sleak::Vector3D(0, 0, 0));
 *     player->SetTag("Player");
 *     level->AddObject(player);
 *
 *     auto enemy = Sleak::GameObject::CreateSphere(Sleak::Vector3D(5, 0, 0));
 *     enemy->SetTag("Enemy");
 *     level->AddObject(enemy);
 *
 *     // Parent-child hierarchy
 *     auto weapon = Sleak::GameObject::CreateCube(Sleak::Vector3D(1, 0, 0));
 *     weapon->SetTag("Weapon");
 *     level->AddObject(weapon);
 *     player->AddChild(weapon);  // weapon moves with player
 *
 *     SetActiveScene(level);
 *     return true;
 * }
 *
 *
 * Querying Objects:
 * ─────────────────
 *
 * auto* player = scene->FindObjectByName("Player-0");
 * auto enemies = scene->FindObjectsByTag("Enemy");
 * auto* specific = scene->FindObjectByID(42);
 *
 *
 * Deferred Destruction (safe during Update):
 * ──────────────────────────────────────────
 *
 * // In a component's Update():
 * void EnemyAI::Update(float dt) {
 *     if (health <= 0) {
 *         auto* scene = /* get active scene */;
 *         scene->DestroyObject(GetOwner());  // safe, deferred to end of frame
 *     }
 * }
 *
 *
 * Switching Scenes:
 * ──────────────────
 *
 * void Game::OnLevelComplete() {
 *     Sleak::Scene* nextLevel = new Sleak::Scene("Level2");
 *     AddScene(nextLevel);
 *     // Populate nextLevel...
 *     SetActiveScene(nextLevel); // Old scene deactivated, new one activated
 * }
 *
 *
 * Pausing/Resuming:
 * ──────────────────
 *
 * GetActiveScene()->Pause();   // Objects stop updating
 * GetActiveScene()->Resume();  // Objects resume updating
 */

/*
 * ===== MEMORY OWNERSHIP =====
 *
 * • Scene OWNS its GameObjects — they are deleted when the scene unloads or is destroyed
 * • GameBase OWNS its Scenes — they are unloaded and deleted in the destructor
 * • Components are owned by their GameObject via RefPtr (reference-counted)
 * • Parent-child links are non-owning — the scene owns all objects in a flat list
 * • Factory methods (CreateCube, etc.) allocate with new — caller passes to scene
 *
 * DO NOT delete GameObjects manually if they're in a scene — use DestroyObject() or
 * RemoveObject() instead.
 */

/*
 * ===== KEY POINTS =====
 *
 * • Scenes manage GameObjects; GameBase manages Scenes
 * • SetActiveScene() automatically initializes and begins the scene
 * • Objects are NOT initialized/updated until scene is activated
 * • Game::Initialize() creates scenes; Application::Run() calls it
 * • Update loop: FixedUpdate (60Hz) → Update (per frame) → LateUpdate (per frame)
 * • Only root objects (no parent) are iterated by the scene — children recurse
 * • Multiple scenes can exist, only one is active at a time
 * • Pausing a scene pauses all objects in it without unloading
 * • Removing/unloading a scene properly cleans up all owned objects
 * • DestroyObject() is deferred — safe to call during update loops
 */
