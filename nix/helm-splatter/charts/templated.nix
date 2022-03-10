{ pkgs, nixpkgs }:
let
  templateChart = { url, chart, version, chartSha256, sha256 }:
  let
    # well known url for helm charts in repos
    # TODO: parse index.yaml if needed
    chartData = pkgs.fetchurl {
      url = "${url}/${chart}-${version}.tgz";
      sha256 = chartSha256;
    };
  in
  pkgs.runCommand "template-chart" {
    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
    outputHash = sha256;
    preferLocalBuild = true;
    allowSubstitutes = true;
  } ''
    set -x
    mkdir -p $out
    ${pkgs.kubernetes-helm}/bin/helm template ${chartData} --output-dir $out
  '';
in
{
  nginx-ingress = templateChart {
    url = "https://helm.nginx.com/stable";
    chart = "nginx-ingress";
    version = "0.12.1";
    chartSha256 = "sha256-AIZ08w3sM555z/4H3y5rxH+TBCulKNfXsRAKwDUl03E=";
    sha256 = "sha256-LliO+uh8P82aY55/k/JvspERFXkNJePwlrDcm4FLo4Y=";
  };
}
