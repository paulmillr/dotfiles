# Dotfiles
My personal dotfiles.

## Building my system from scratch (reminder)

1. Apps to install:

    XCode, TextMate, CSSEdit, Tower, Sequel Pro, Transmit, Droplr, 1Password,
    iLife, iWork, Firefox, Chrome, Handbrake, Lastfm, Screenflow, UnrarX,
    Transmission, VLC, Skype [, VMWare Fusion, PSCS5]

2. Sync 1Password, Keychain, iPhoto, iDisk, iTunes, iCloud.
3. Install homebrew: 
    
    ruby -e "$(curl -fsSL https://raw.github.com/gist/323731)"

4. Install brew packages:

    brew install cmake geoip hub mysql51 python3 wget coffee-script git libevent node readline gdbm htop memcached pidof sqlite

5. Install:

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

6. Clone GitHub packages.
