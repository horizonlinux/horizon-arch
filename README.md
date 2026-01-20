# <img width="2335" height="1296" alt="Horizon" src="https://raw.githubusercontent.com/horizonlinux/horizon/refs/heads/main/.github/logo.png" />

# Archived
This repo was archived due to us wating to make an atomic distro that is both x86_64 and ARM64, but due to Arch ARM not using `vmlinuz` to boot and current state of bootc composefs and systemd-boot on ARM it is impossible to do using Arch. Thank you for you interest.

General use distro created using Arch Linux with BootC and composeFS.

## I need to install a package across the entire system. How do I do it?
You can check if the package is avaible as one of our pre-packaged system extensions.
If it isn't avaible there, you can create your own system extension or make a custom image based on Horizon.

## Creating image based on Horizon

a) for personal use:
  - Fork this repository and edit it how you like.
  - Put at the top of `README.md` that this image is for personal use only.

b) different usecase:
  - Fork this repository and edit it how you like.
  - Remove `filesystem-horizon` package. `filesystem-horizon` is the package that contains Horizon branding,
    if you are making an image with a different usecase, you are most likely going to release it to the public,
    and we do not want people reporting issues with your image to us.

## Building

In order to get a running arch-bootc system you can run the following steps:
```shell
just build-containerfile # This will build the containerfile and all the dependencies you need
just generate-bootable-image # Generates a bootable image for you using bootc!
```

Then you can run the `bootable.img` as your boot disk in your preferred hypervisor.
