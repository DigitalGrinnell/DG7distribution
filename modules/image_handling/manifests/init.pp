## This is the init.pp manifest for the custom Puppet "image_handling" module.

class image_handling {

TODO !!!!!!!!!!!!!

## ImageMagick (GraphicsMagick DOESN'T WORK) install from http://v2p2dev.to.cnr.it/doku.php?id=isla2:tools

apt-get install build-essential checkinstall
apt-get build-dep imagemagick
wget http://www.imagemagick.org/download/ImageMagick-6.8.9-5.tar.gz
tar xzvf ImageMagick-6.8.9-5.tar.gz
cd ImageMagick-6.8.9-5/
./configure --prefix=/opt/imagemagick-6.8
make
checkinstall

ln -s /opt/imagemagick-6.8/bin/animate /usr/bin/
ln -s /opt/imagemagick-6.8/bin/compare /usr/bin/
ln -s /opt/imagemagick-6.8/bin/composite /usr/bin/
ln -s /opt/imagemagick-6.8/bin/conjure /usr/bin/
ln -s /opt/imagemagick-6.8/bin/convert /usr/bin/
ln -s /opt/imagemagick-6.8/bin/display /usr/bin/
ln -s /opt/imagemagick-6.8/bin/identify /usr/bin/
ln -s /opt/imagemagick-6.8/bin/import /usr/bin/
ln -s /opt/imagemagick-6.8/bin/mogrify /usr/bin/
ln -s /opt/imagemagick-6.8/bin/montage /usr/bin/
ln -s /opt/imagemagick-6.8/bin/stream /usr/bin/

convert -version
  Version: ImageMagick 6.8.9-5 Q16 x86_64 2014-07-23 http://www.imagemagick.org
  Copyright: Copyright (C) 1999-2014 ImageMagick Studio LLC
  Features: DPC OpenMP
  Delegates: bzlib djvu fftw fontconfig freetype jbig jng jpeg lcms lqr lzma openexr pangocairo png tiff x xml zlib

## In addition to making sure imagemagick is installed, make sure you configure it
## at admin/config/media/image-toolkit

## The following command set also needs to be dealt with in order to make sure
## necessary Kakadu components are in place.  Also from from http://v2p2dev.to.cnr.it/doku.php?id=isla2:tools

  exec { "Install Kakadu" :
    cwd => "/root",
    command => "dpkg --install $archive; apt-get -q -y -f install ",

Kakadu libraries
wget http://downloads.sourceforge.net/project/djatoka/djatoka/1.1/adore-djatoka-1.1.tar.gz
tar -xvzf adore-djatoka-1.1.tar.gz
mv adore-djatoka-1.1/bin/Linux-x86-64/* /usr/local/bin/
mv adore-djatoka-1.1/lib/Linux-x86-64/* /usr/local/lib/
ldconfig
rm -R adore-djatoka-1.1

    creates => $installed,
    require => Exec[ "DownloadWebmin" ],
    notify => Service[apache2],
    }

}