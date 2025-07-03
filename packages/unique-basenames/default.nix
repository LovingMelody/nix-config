{python3Packages, ...}:
with python3Packages;
  buildPythonApplication {
    name = "unique-basenames";
    version = "1.0";
    src = ./src;
    pyproject = true;
    build-system = [setuptools];
    meta = {
      description = "Script to take a list of paths and deduplicate using the basename";
      mainProgram = "unique-basenames";
    };
  }
