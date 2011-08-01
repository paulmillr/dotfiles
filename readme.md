# Dotfiles
My personal dotfiles.

## Building my system from scratch (reminder)

* Apps to install:

```sh
XCode, TextMate, CSSEdit, Tower, Sequel Pro, Transmit, Droplr, 1Password,
iLife, iWork, Firefox, Chrome, Handbrake, Lastfm, Screenflow, UnrarX,
Transmission, VLC, Skype [, VMWare Fusion, PSCS5]
```

* Sync 1Password, Keychain, iPhoto, iDisk, iTunes, iCloud.
* Install homebrew: 
    
```sh
ruby -e "$(curl -fsSL https://raw.github.com/gist/323731)"
```

* Install brew packages:

```sh
brew install cmake geoip hub mysql51 python3 wget coffee-script git libevent node readline gdbm htop memcached pidof sqlite
```

* Install:

```sh
# Distribute for Python 3
wget http://pypi.python.org/packages/source/d/distribute/distribute-0.6.19.tar.gz
tar -zxvf distribute-0.6.19.tar.gz
cd distribute-0.6.19
sudo python setup.py install

# PIP
sudo easy_install-2.7 pip
sudo easy_install-3.2 pip

# NPM
curl http://npmjs.org/install.sh | sh
```

* Clone GitHub packages.

* Install python packages

```python
# iPython (I use this as a default command shell)
sudo pip-2.7 install ipython

````

* Do ./symlink_dotfiles.sh


## License

Copyright (c) 2011 Paul Miller.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
