# README


## Other things to install

(Assuming you're running this on an RPi)


### LFTP

    `sudo apt-get install ncurses-dev`
    `wget http://lftp.yar.ru/ftp/lftp-4.7.3.tar.gz`
    `tar -zxvf lftp-4.7.3.tar.gz`
    `cd lftp-4.7.3`
    `./configure --without-gnutls --with-openssl`
    `make -j4`
    `sudo make install`