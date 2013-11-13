wisp-playground
===============

wisp dummy code

install requirements::

    npm install wisp
    npm install jsdom
    npm install swig
    npm install redis

compile wisp files to javascript::    
    
    ./compile.sh *.wisp
    
run server::    
    
    ./compile.sh *.wisp && node main.js 
