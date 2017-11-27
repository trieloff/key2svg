# key2svg

Command line tools to convert Keynote slides to SVG

## Prerequisites

You will need Apple Keynote, Ghostscript, pdfseparate, Poppler, and Inkscape to run this script. Inkscape requires XQuartz.

```bash
$ brew cask install xquartz 
$ brew install caskroom/cask/inkscape
$ brew install ghostscript poppler
```

## Installation

Check out this repository and make the `key2svg.sh` executable

```bash
$ git clone https://github.com/trieloff/key2svg.git
$ cd key2svg
$ chmod +x key2svg.sh
```

## Usage

Run the script and pass the path to a Keynote file as the first command line argument.

```bash
$ ./key2svg /path/to/your/keynote.key
```

## License

Apache License, Version 2.0

## Contributing

Yes, please. All pull request will be reviewed.
