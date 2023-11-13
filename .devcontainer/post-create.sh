# General
sudo usermod -s /bin/bash opsidoc

# Antora
npm install

# Antora-UI
cd antora-ui
npm install

# Install CSpell
sudo npm install -g cspell@latest
sudo npm install -g @cspell/dict-de-de
cspell link add @cspell/dict-de-de
