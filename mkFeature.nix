# Builds a NixOS module gated behind `my.<path>.enable`, collapsing the usual
# options.my.X.enable / config = mkIf ... boilerplate into one call.
#
# `gates` is the list of ancestor `my.<...>` paths (each itself a path-list) that
# this feature is nested under - directories along the way that have their own
# default.nix/own toggle. Enabling this feature defaults every gate's enable to
# true too (via mkDefault, so it's overridable by a plain assignment or mkForce
# elsewhere), and its own config only actually applies once every gate is
# (however it was ultimately resolved) also true - so an override on an ancestor
# has real teeth instead of being silently bypassed by an enabled descendant.
#
# `path` is a feature name, or a list for a nested option (e.g. [ "users" "autumn" ]
# for my.users.autumn.enable).
#
# `body` is either an attrset of config, or a module-args function returning one.
# It may also carry an `imports` key, spliced in unconditionally since imports
# can't be gated by mkIf, while everything else is gated behind the enable option.
#
# Called only from getFeatures in lib.nix - feature files never import this
# directly, they're just bodies.
#
# NixOS only forwards a module function's *named* args (it computes
# intersectAttrs functionArgs allArgs before calling, regardless of "..."), so
# every arg a feature body might need has to be named here too for @args to
# actually contain it.
gates: path: body:
let
  path' = if builtins.isList path then path else [ path ];
in
{
  lib,
  config,
  pkgs,
  inputs,
  outputs,
  ...
}@args:
let
  resolved = if builtins.isFunction body then body args else body;
  ownEnable = lib.attrByPath (path' ++ [ "enable" ]) false config.my;
  gatesEnabled = lib.all (g: lib.attrByPath (g ++ [ "enable" ]) false config.my) gates;
in
{
  imports = resolved.imports or [ ];
  options.my = lib.setAttrByPath path' {
    enable = lib.mkEnableOption (lib.concatStringsSep "." path');
  };
  config = lib.mkMerge (
    [ (lib.mkIf (ownEnable && gatesEnabled) (builtins.removeAttrs resolved [ "imports" ])) ]
    ++ map (g: lib.mkIf ownEnable { my = lib.setAttrByPath g { enable = lib.mkDefault true; }; }) gates
  );
}
