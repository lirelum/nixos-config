{ packages }: final: prev: {
  local = packages.${prev.stdenv.hostPlatform.system};
}
