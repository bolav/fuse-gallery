Fuse Gallery [![Build Status](https://travis-ci.org/bolav/fuse-gallery.svg?branch=master)](https://travis-ci.org/bolav/fuse-gallery) ![Fuse Version](https://fuse-version.herokuapp.com/?repo=https://github.com/bolav/fuse-gallery)
============

Library to use the gallery in [Fuse](http://www.fusetools.com/).

## Installation

Using [fusepm](https://github.com/bolav/fusepm)

    $ fusepm install https://github.com/bolav/fuse-gallery

## Usage

UX:

```
<Gallery ux:Global="Gallery" />
<Image File="{image}">
```

JavaScript:

```
var gallery = require('Gallery');
var Observable = require('FuseJS/Observable');
var image = Observable();

function load () {
  gallery.getPicture().then(function (pic) {
    image.value = pic;
  });
}
module.exports = {
  load: load,
  image: image
}
```
