{
  lib,
  args,
  ...
}: path: default:
if
  (lib.hasAttrByPath [
      "osConfig"
      "TM"
    ]
    args)
then lib.attrByPath path default args.osConfig.TM
else default
