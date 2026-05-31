with (import <nixpkgs> {});

mkShell {
	packages = [
		bash
		pandoc
		gladtex
		graphviz
		(pkgs.texlive.combine {
			inherit (texlive) scheme-basic
			amsmath
			dvisvgm
			dvipng
			hyperref
			koma-script
			preview
			xcolor
		;})
	];
}
