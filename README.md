[![build](https://github.com/lkwg82/rc.files/actions/workflows/build.yml/badge.svg)](https://github.com/lkwg82/rc.files/actions/workflows/build.yml)

# rc.files

local bash rc files

```bash
git clone git@github.com:lkwg82/rc.files.git .bashrc.d

# includes into existing .bashrc
echo "# git versioned rc files" >> ~/.bashrc
echo "source ~/.bashrc.d/__init__.sh" >> ~/.bashrc
ln -s ~/.bashrc ~/.bash_profile
```
