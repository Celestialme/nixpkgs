{ lib, callPackage, fetchpatch, fetchurl, stdenv, pkgsi686Linux }:

let
  generic = args: let
    imported = import ./generic.nix args;
  in if ((!lib.versionOlder args.version "391")
    && stdenv.hostPlatform.system != "x86_64-linux") then null
  else callPackage imported {
    lib32 = (pkgsi686Linux.callPackage imported {
      libsOnly = true;
      kernel = null;
    }).out;
  };

  kernel = callPackage # a hacky way of extracting parameters from callPackage
    ({ kernel, libsOnly ? false }: if libsOnly then { } else kernel) { };
in
rec {
  # Policy: use the highest stable version as the default (on our master).
  stable = if stdenv.hostPlatform.system == "x86_64-linux"
    then generic {
      version = "510.54";
      sha256_64bit = "TCDezK4/40et/Q5piaMG+QJP2t+DGtwejmCFVnUzUWE=";
      settingsSha256 = "ZWz5UN6Pa69NlmerKu30G+X8WfGlAwnVerDrO7TRO6w=";
      persistencedSha256 = "MgWrBjKXJeRqF+ouT72tTiLPtn+lsS/Cp3oS61AWV8Q=";
    }
    else legacy_390;

  # see https://www.nvidia.com/en-us/drivers/unix/ "Production branch"
  production = legacy_470;

  beta = generic {
    version = "510.39.01";
    sha256_64bit = "sha256-Lj7cOvulhApeuRycIiyYy5kcPv3ZlM8qqpPUWl0bmRs=";
    settingsSha256 = "sha256-qlSwNq0wC/twvrbQjY+wSTcDaV5KG4Raq6WkzTizyXw=";
    persistencedSha256 = "sha256-UNrl/hfiNXKGACQ7aHpsNcfcHPWVnycQ51yaa3eKXhI=";
  };

  # Vulkan developer beta driver
  # See here for more information: https://developer.nvidia.com/vulkan-driver
  vulkan_beta = generic rec {
    version = "470.62.13";
    persistencedVersion = "470.86";
    settingsVersion = "470.86";
    sha256_64bit = "sha256-itBFNPMy+Nn0g8V8qdkRb+ELHj57GRso1lXhPHUxKVI=";
    settingsSha256 = "sha256-fq6RlD6g3uylvvTjE4MmaQwxPJYU0u6IMfpPVzks0tI=";
    persistencedSha256 = "sha256-eHvauvh8Wd+b8DK6B3ZWNjoWGztupWrR8iog9ok58io=";
    url = "https://developer.nvidia.com/vulkan-beta-${lib.concatStrings (lib.splitString "." version)}-linux";
  };

  # Update note:
  # If you add a legacy driver here, also update `top-level/linux-kernels.nix`,
  # adding to the `nvidia_x11_legacy*` entries.

  # Last one supporting Kepler architecture
  legacy_470 = generic {
      version = "470.94";
      sha256_64bit = "lYWqKTMOutm98izjyiusICbIWpoy8D18WfcUp3mFAOs=";
      settingsSha256 = "blJNKuFu/Th/ceexkKhTH/eYk8miUlTT+ESrcIyJNn0=";
      persistencedSha256 = "xnccQ/EgafwnReBlk5Y7iClAj4hwXyFq9gUmwqyEuwE=";
  };

  # Last one supporting x86
  legacy_390 = generic {
    version = "390.147";
    sha256_32bit = "00avsns7l0j1ai8bf8gav2qshvphfdngy388bwzz24p61mfv1i1a";
    sha256_64bit = "09qcdfn4j5jza3iw59wqwgq4a489qf7kx355yssrcahaw9g87lxz";
    settingsSha256 = "16qqw0jy31da65cdi17y3j2kcdhw09vra7g17bkcimaqnf70j0ni";
    persistencedSha256 = "1ad81y4qfpxrx0vqsk81a3h0bi1yg8hw5gi5y5d58p76vc8083i9";
  };

  legacy_340 = generic {
    version = "340.108";
    sha256_32bit = "1jkwa1phf0x4sgw8pvr9d6krmmr3wkgwyygrxhdazwyr2bbalci0";
    sha256_64bit = "06xp6c0sa7v1b82gf0pq0i5p0vdhmm3v964v0ypw36y0nzqx8wf6"; 
    settingsSha256 = "0zm29jcf0mp1nykcravnzb5isypm8l8mg2gpsvwxipb7nk1ivy34";
    persistencedSha256 = "1ax4xn3nmxg1y6immq933cqzw6cj04x93saiasdc0kjlv0pvvnkn";
 useGLVND = false;
    patches = [./0001_kernel_5.7.patch ./0002_kernel_5.8.patch ./0003_kernel_5.9.patch ./0004_kernel_5.10.patch ./0005_kernel_5.11.patch ./0006_kernel_5.14.patch ./0007_kernel_5.15.patch ./0008_kernel_5.16.patch ];
	  
};
}
