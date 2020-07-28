# webapp-tutorial
Gambit Scheme Web app tutorial

You can view the tutorial by visiting https://udem-dlteam.github.io/webapp-tutorial/.

To build the slide deck, do:

    make
    git commit -a -m "<some_message>"
    git push

You will need to have Gambit and pandoc installed, and Gambit must be built with:

    ./configure --enable-targets=js ...
    make
    make modules
    make install
