### 1. Create a folder in the root folder of your computer. scripts 

### 2. Copy script in folder

### 3. Make the script executable
```
chmod +x ~/scripts/generate_module.sh
```
### 4. Add an export of the scripts folder to your .zshrc
```
export PATH="$HOME/scripts:$PATH"
```
### 5. Done. Now you can call in the spawn folder
```
generate_module.sh module_name
```