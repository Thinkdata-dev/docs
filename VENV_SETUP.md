# Virtual Environment (venv) setup

These steps show how to create and use a Python virtual environment for this project on macOS (zsh). The project keeps dependencies in `requirements.txt`.

1. Create the venv (in the project root):

```bash
python3 -m venv .venv
```

2. Activate the venv:

```bash
source .venv/bin/activate
```

3. Upgrade pip and install dependencies:

```bash
python -m pip install --upgrade pip
pip install -r requirements.txt
```

4. Work on the project. Run python as usual; it will use the venv's interpreter.

5. Deactivate when done:

```bash
deactivate
```

Removing the venv:

```bash
rm -rf .venv
```

VS Code

- The repo includes a workspace setting to prefer `./.venv/bin/python`. If VS Code doesn't pick it up, open the Command Palette (Cmd+Shift+P) and run "Python: Select Interpreter" → choose the `.venv` entry.
