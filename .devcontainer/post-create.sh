# General
sudo usermod -s /bin/bash opsidoc

# Antora
npm install

# Antora-UI
cd antora-ui
npm install

# Install CSpell
npm install cspell@latest
npm install @cspell/dict-de-de
cspell link add @cspell/dict-de-de
