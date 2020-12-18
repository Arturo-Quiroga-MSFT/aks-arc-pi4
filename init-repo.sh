
# How to create a new repository on the command line
echo "# aks-arc-pi4" >> README.md
git init
git add README.md
git commit -m "first commit"
git branch -M main
git remote add origin https://github.com/arturoqu77/aks-arc-pi4.git
git push -u origin main

# Or how to push an existing repository from the command line
git remote add origin https://github.com/arturoqu77/aks-arc-pi4.git
git branch -M main
git push -u origin main

