# README


## Other things to install


(Assuming you're running this on an RPi)

    sudo apt-get install git
    mkdir ~/installs
    sudo apt-get install libmp3lame-dev

### LFTP

    `sudo apt-get install ncurses-dev`
    `wget http://lftp.yar.ru/ftp/lftp-4.7.3.tar.gz`
    `tar -zxvf lftp-4.7.3.tar.gz`
    `cd lftp-4.7.3`
    `./configure --without-gnutls --with-openssl`
    `make -j4`
    `sudo make install`
    
### INSTALL H264 SUPPORT
    cd ~/installs
    git clone git://git.videolan.org/x264
    cd x264
    ./configure --host=arm-unknown-linux-gnueabi --enable-static --disable-opencl
    make -j4
    sudo make install
    
    
### LibFAAC: http://owenashurst.com/?p=242

    
### Now Reboot (Seriously)

    sudo ldconfig
    sudo reboot
    
### FFMPEG (Takes a long time to compile)

    cd ~/installs
    git clone --depth 1 git://git.videolan.org/ffmpeg
    cd ffmpeg
    ./configure --arch=armel --target-os=linux --enable-gpl --enable-libx264 --enable-nonfree --enable-libfaac --enable-libmp3lame
    make -j4
    sudo make install