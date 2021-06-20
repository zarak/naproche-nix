{ mkDerivation, base, bytestring, containers, ghc-prim, hpack, lib
, mtl, network, process, split, text, threads, time, transformers
, utf8-string, uuid, yaml, isabelle
}:
mkDerivation {
  pname = "Naproche-SAD";
  version = "0.1.0.0";
  src = ./.;
  isLibrary = true;
  isExecutable = true;
  libraryHaskellDepends = [
    base bytestring containers ghc-prim mtl network process split text
    threads time transformers utf8-string uuid yaml
  ];
  libraryToolDepends = [ hpack ];
  executableHaskellDepends = [
    base bytestring containers ghc-prim mtl network process split text
    threads time transformers utf8-string uuid yaml
  ];
  testHaskellDepends = [
    base bytestring containers ghc-prim mtl network process split text
    threads time transformers utf8-string uuid yaml
  ];
  doCheck = false;
  prePatch = "hpack";
  homepage = "https://github.com/naproche-community/naproche#readme";
  license = lib.licenses.gpl3Only;
}
