# To install on ubuntu
```bash
curl https://raw.githubusercontent.com/toniok2nd/vim_dev/master/template |bash
```

# To rebuild template
```bash
bash buildScript.sh
```
The script use local files:
- bashrcFile
- tmuxFile
- vimrcFile

# To install snippets file 
```bash
curl https://raw.githubusercontent.com/toniok2nd/vim_dev/master/yaml.snippets -O
mv yaml.snippets ~/.config/coc/ultisnips/yaml.snippets
```

# you can also generate a docker image from Dockerfile

## Doc for coc-nvim extensions
- https://github.com/neoclide/coc.nvim/wiki/Using-coc-extensions
