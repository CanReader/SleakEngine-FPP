#include <iostream>
#include <Core/Application.hpp>
#include <Game.hpp>
#include <string>
#include <Logger.hpp>

#define PROJECT_NAME "SleakEngine"

std::string HelpMessage =
  "Usage: SleakEngine [OPTION...] \n\
  help : Shows this help message \n\
  -w :    Sets width of the window. \n\
  -h :    Sets height of the window \n\
  -t :    Sets title of the window, to set space between words put _ character \n\
  ";

int main(int argc, char** argv) {

  Sleak::Logger::Init((char*)PROJECT_NAME);

  Sleak::ApplicationDefaults defaults
  {
    .Name = PROJECT_NAME,
    .CommandLineArgs = Sleak::Arguments(argc, argv)
  };

  Game* game = new Game();
  Sleak::Application app(defaults);

  return app.Run( game );
}
