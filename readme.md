![Hexane for LuaJIT][hexane_banner]
![shield_license]
![shield_release_version]
![shield_prerelease_version]
![shield_dev_version]

Hexane is a suite of libraries intended to promote and ease game development in pure LuaJIT. It depends on [Carbon for Lua][carbon] for providing much of its underlying structure and uses LuaJIT C FFI bindings to provide cross-platform audio, graphics, and input.

See [releases.md](releases.md) for the releases history of Hexane.

# Dependencies
- GLFW 3.1
- stb (included in `stb` directory)

# Setting Up
Some platforms may have binary dependencies already built for them. Check the releases section on GitHub!

# Windows
Get the latest GLFW 3.1 in DLL form, place it at `bin/glfw3.dll`.

Compile all the files in the `stb` folder to a DLL, place it at `bin/stb.dll`.

[carbon]: https://github.com/lua-carbon/carbon
[hexane_banner]: https://raw.githubusercontent.com/luajit-hexane/hexane/master/assets/hexane-banner.png
[hexane_icon]: https://raw.githubusercontent.com/luajit-hexane/hexane/master/assets/hexane-icon.png

[shield_license]: https://img.shields.io/badge/license-zlib/libpng-333333.svg?style=flat-square
[shield_release_version]: https://img.shields.io/badge/release-none-lightgrey.svg?style=flat-square
[shield_prerelease_version]: https://img.shields.io/badge/prerelease-none-lightgrey.svg?style=flat-square
[shield_dev_version]: https://img.shields.io/badge/development-1.0.0-orange.svg?style=flat-square