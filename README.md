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
curl https://raw.githubusercontent.com/toniok2nd/vim_dev/master/yaml.snippets -O && cp yaml.snippets ~/.config/coc/ultisnips/yaml.snippets
```

# To install minikub kubctl docker and kompose
```bash
curl https://raw.githubusercontent.com/toniok2nd/vim_dev/master/minikubInstall |bash
```
# If you docker in docker
```bash
docker run --privileged=true -v /var/run/docker.sock:/var/run/docker.sock -it ubuntu bash
```


# you can also generate a docker image from Dockerfile

## Doc for coc-nvim extensions
- https://github.com/neoclide/coc.nvim/wiki/Using-coc-extensions
