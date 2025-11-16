{ lib, ... }:
{
  options = {
    variables = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Various variables";
    };
  };
}
