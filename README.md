# rc.files
local bash rc files

``bash
git clone git@github.com:lkwg82/rc.files.git .bashrc.d

echo "# git versioned rc files" 	>> ~/.bashrc
echo "source ~/.bashrc.d/__init__.sh"	>> ~/.bashrc
``
