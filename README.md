"# Stonecraft-WorldAtlas" 

## Requirements

- libgd
- sqlite3
- leveldb (optional, set ENABLE_LEVELDB=1 in CMake to enable)
- hiredis (optional, set ENABLE_REDIS=1 in CMake to enable)
- Postgres libraries (optional, set ENABLE_POSTGRES=1 in CMake to enable)
- ImageMagick


```
$ sudo apt-get install git-core build-essential libgd-dev libsqlite3-dev libleveldb-dev libhiredis-dev libpq-dev imagemagick
```

## Compilation on GNU/Linux (e.g. Ubuntu)

Download source via github:


```
$ git clone --depth 1 https://github.com/MrCerealGuy/Stonecraft-WorldAtlas.git
```

Change into the WorldAtlas directory and get the source for minetestmapper:

```
$ cd Stonecraft-WorldAtlas
$ git clone --depth 1 https://github.com/MrCerealGuy/minetestmapper.git
```

Compile minetestmapper:

```
$ cd minetestmapper
$ cmake . -DENABLE_LEVELDB=1
$ make -j2
```

## Usage

Edit *generate_map.sh* and set *WORLD_PATH* and *WWW_ROOT*. Run the script:

```
$ ./generate_map.sh
```