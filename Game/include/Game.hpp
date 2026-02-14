#ifndef _GAME_H_
#define _GAME_H_

#include <GameBase.hpp>
#include <Core/OSDef.hpp>
#include <Memory/RefPtr.h>

class SLEAK_API Game : public Sleak::GameBase {
public:
  Game();
  Game(Game &&) = delete;
  Game(const Game &) = default;
  ~Game();

  Game &operator=(Game &&) = delete;
  Game &operator=(const Game &) = delete;

  // Called once at startup. Create scenes, add objects, set active scene.
  bool Initialize() override;

  // Called once after Initialize. Use for post-init setup.
  void Begin() override;

  // Called every frame. Use for per-frame game logic.
  void Loop(float DeltaTime) override;

  int Run();

  inline bool GetIsGameRunning() { return bIsGameRunning; }

private:
  bool bIsGameRunning = true;

  Sleak::Scene* mainScene = nullptr;
};

#endif
