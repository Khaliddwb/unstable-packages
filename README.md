# Repository for new/unstable packages

[![Packages last build status](https://github.com/termux/unstable-packages/workflows/Packages/badge.svg)](https://github.com/termux/unstable-packages/actions)

[![Powered by JFrog Bintray](./.github/static/powered-by-bintray.png)](https://bintray.com)

There are located packages which were requested, but not added to the
[main][termux-packages] Termux repository due to various reasons. Packages
available here may have lower quality, be unstable or not work at all.

**Only for Termux installations on Android 7.0 or higher.**

**Issue reporting is disabled!** Post issues to https://github.com/termux/termux-packages/issues
instead and remember that packages in unstable repository are known to
have problems which may not be fixed now.

## How to enable this repository

To enable this package repository run:

```
pkg install unstable-repo
```

## Building packages manually

You can build all packages manually by using provided docker image. The only
requirements are Linux-based host with Docker installed.

1. Clone this repository:
	```
	git clone https://github.com/termux/unstable-packages
	```

2. Enter build environment (will download docker image if necessary):
	```
	cd ./unstable-packages
	./start-builder.sh
	```

3. Choose package you want to build and run:
	```
	./build-package.sh -a ${arch} ${package name}
	```
	Replace `${arch}` with target CPU architecture and `${package name}` with
	package name you want to build.

## Contributing

[I](https://github.com/xeffyr) am working on packages in my spare time and probably
will not be able to process your issues instantly. It would be very helpful if you
submit a pull request with new packages or bug fixes.

If you wish to contribute, please take a look at Unstable packages [contributing guide](./CONTRIBUTING.md)
and developer's [wiki pages](https://github.com/termux/termux-packages/wiki).

[termux-packages]: <https://github.com/termux/termux-packages>

## Status of packages

Here is a list of available packages with some information about their usability.

| Package           | Is stable ? | Need root ? | Notes                                            |
|:------------------|:-----------:|:-----------:|:-------------------------------------------------|
| at                | X           |             |                                                  |
| atomvm            |             |             | As its readme states: AtomVM is still in its early stages. |
| bftpd             |             |             | Needs patches in order to be usable on rootless Termux. |
| biber             |             |             | Sideloaded.                                      |
| ccls              |             |             | Not tested.                                      |
| cppcheck          |             |             | Not tested.                                      |
| cups              |             |             | When trying to add a printer, it hangs and CPU usage goes to 100%. |
| distcc            |             |             | Not tested.                                      |
| docopt            | X           |             |                                                  |
| electrum          |             |             | Uses external python modules.                    |
| enscript          |             |             |                                                  |
| fdroidcl          |             |             | Some functionality relies on ADB.                |
| fetchmail         |             |             | fetchmailconf requires tkinter in python2.       |
| ghc               |             |             | Works on AArch64 and x86_64. Need more testing.  |
| gitflow-avh       |             |             | Requires dependency list fix.                    |
| gopass            |             |             | Reports problems with GPG key generation.        |
| guile18           |             |             | Is https://github.com/termux/termux-packages/issues/3360 still applicable ? |
| guile             |             |             | Is https://github.com/termux/termux-packages/issues/3360 still applicable ? |
| haproxy           |             |             | Not tested.                                      |
| hashcat           |             |             | May crash OS. May not find own OpenCL directory. |
| jigdo             |             |             | Not tested.                                      |
| libburn           |             |             |                                                  |
| libisoburn        |             |             | Reports sizeof(off_t) is too small for 32bit installations. Same goes for libburn and libisofs. |
| libisofs          |             |             |                                                  |
| libopenfec        |             |             | Not tested.                                      |
| libsixel          |             |             | Not tested.                                      |
| libtd             |             |             |                                                  |
| metasploit        |             |             | Uses external Ruby modules and sideloading.      |
| nmh               |             |             | Not tested.                                      |
| openldap          |             |             | Not tested.                                      |
| pandoc            |             |             | Not native binary. Relies on QEMU.               |
| racket            |             |             |                                                  |
| rapidjson         |             |             | Not tested.                                      |
| restic-server     |             |             | Not tested.                                      |
| rustc-nightly     |             |             | Nightly branch of Rust.                          |
| samba             |             | preferable  | smbd CPU usage may go to 100%. Hardcoded root account. |
| shtool            |             |             | Not tested.                                      |
| smalltalk         |             |             |                                                  |
| srelay            |             |             |                                                  |
| sqlmap            |             |             | Not tested.                                      |
| surfraw           |             |             | Needs fix for hardcoded paths.                   |
| tcc               |             |             | No support for generation of PIE executables.    |
| telegram-cli      |             |             | May crash under certain conditions.              |
| texlive-installer |             |             |                                                  |
| vlang             |             |             | Not tested.                                      |
| yara              |             |             | Always exits with `error: 31`.                   |
| zeronet           |             |             | Uses external python modules.                    |

### Disabled packages

These packages are excluded from main source tree. Some of them may be available for installation, others are not.

- **a2ps** - segmentation fault on AArch64 for unknown reason.

- **geckodriver** - requires Firefox package which is not available for Termux.

- **micropython** - requires update & build fix.

- **roc** - doesn't support CI autobuilds as requires Pulseaudio build directory.

- **shiori** - no longer maintained, compilation error with Go 1.13+.
