with (import <nixpkgs> {});

mkShell {
	packages = [
		bash
		pandoc
		gladtex
		graphviz
		darkhttpd
		(aspellWithDicts (d: [d.en d.en-computers]))
		(texlive.combine {
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
