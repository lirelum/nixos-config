{packages}: prev: final: {
  local = packages.${prev.system};
}