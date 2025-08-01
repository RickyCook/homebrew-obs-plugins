# OBS Plugins
A collection of OBS plugins that I use in a Homebrew tap.

Also included is an updater script to read the formulas, download new version data,
and update the formulas with new URLs and hashes.

## Tricks

- Reinstall all installed formulas:
  ```bash
  brew list --full-name | grep -i rickycook/obs-plugins | xargs brew reinstall
  ```
- Upgrade all installed plugins:
  ```bash
  brew list --full-name | grep -i rickycook/obs-plugins | xargs brew upgrade
  ```

## Limitations

- This is all a really quick and dirty hack. You've been warned! (though I've probably installed the formulas in main, so they should work)
- Only works on MacOS - I use pkg files, and not advanced enough to really know how to generically switch that for Linux, and certainly not Windows
- Plugins must have a universal pkg (ie arm64 or x86_64 won't be found)
- The words "macos" and "universal" must appear in the filename of the download
- Doesn't check that the installation worked
- GitHub rate limits _might_ hit at some point if doing a big update

## Updater
This uses the Ruby bundled with homebrew, and adds a few gems.

It can find new versions either hosted on the OBS forum, or as GitHub releases.

### Setup and update all formulas

```bash
cd updater
./install.sh
./update.rb
```

### Usage

```
usage: update.rb [OPTIONS]

OPTIONS:
    -g, --glob
        Glob pattern to use when filtering for formula files
        Default: *.rb
    -v, --verbose
        Verbose logging
    -h, --help
        Prints this help message
```

## Adding a new plugin

Adding plugins is very easy:

- Copy an existing plugin (probably not DistroAV - it's a little more complex)
- Find the plugin on the OBS forum
  - This can be a massive pain if you've lost it, but a [resources search](https://obsproject.com/forum/search/?type=resource&c[categories][0]=6&c[title_only]=1) with "search titles only" seems to be okay
- Update the following:
  - Class name
  - Description
  - Homepage (to an OBS forum post URL)
  - License (it's probably GPLv2, but check on GitHub/etc)
  - plugin_path (it's a variable in the install function)
- Run the updater (after installing dependencies - see above): `./update.rb --glob <your formula>.rb`

## Development

I simply symlink the tap into my dev directory and work on it there. Homebrew
will complain about uncommitted changes, but you can ignore it.

```bash
cd <your dev directory>
ln -s /opt/homebrew/Library/Taps/rickycook/homebrew-obs-plugins
```

You don't even really need to symlink it - you can just open it in your IDE and
work on the tap directory directly.

I also add another origin so that I can push without effecting Homebrew

```bash
git remote add origin-dev git@github.com:RickyCook/homebrew-obs-plugins.git
```

And then to push

```bash
git push -u origin-dev
```
