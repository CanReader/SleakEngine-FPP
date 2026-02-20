#ifndef _MAIN_SCENE_HPP_
#define _MAIN_SCENE_HPP_

#include <Core/Scene.hpp>
#include <Memory/RefPtr.h>

namespace Sleak { class Material; }

class MainScene : public Sleak::Scene {
public:
    explicit MainScene(const std::string& name);
    ~MainScene() override = default;

    bool Initialize() override;

private:
    void SetupMaterials();
    void SetupLevel();
    void SetupSkybox();
    void SetupLighting();

    Sleak::RefPtr<Sleak::Material> floorMaterial;
    Sleak::RefPtr<Sleak::Material> wallMaterial;
    Sleak::RefPtr<Sleak::Material> boxMaterial;
};

#endif
