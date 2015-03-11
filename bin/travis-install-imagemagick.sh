sudo apt-get remove -y imagemagick libmagickcore-dev libmagickwand-dev;
sudo apt-get autoremove;
sudo apt-get install -y libtiff-dev libjpeg-dev libpng-dev libdjvulibre-dev libwmf-dev pkg-config;

curl -O http://www.imagemagick.org/download/releases/ImageMagick-6.9.0-4.tar.gz;
tar xzf ImageMagick-6.9.0-4.tar.gz;
cd ImageMagick-6.9.0-4;
./configure
make;
sudo make install;
cd ..;
