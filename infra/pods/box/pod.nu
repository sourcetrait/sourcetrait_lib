#!/usr/bin/env nu

def init [logname: string] {
  let prelog = $"(ansi cyan)[($logname)](ansi reset)"
  let errlog = $"(ansi red)[($logname)] error:(ansi reset)"
  
  # start the machine if needed
  if (podman info | complete).exit_code != 0 {
    print $"($prelog) starting machine ..."
    podman machine start
  }

  let toml = try { open pod.toml } catch {
    print -e $"($errlog) failed to read config: pod.toml"
  }

  let ref = $"($toml.repo)/($toml.image):($toml.tag)"
  let host_platform = $"linux/(podman machine info --format '{{.Host.Arch}}')"

  mut app = {
    prelog: $prelog,
    errlog: $errlog,
    host_platform: $host_platform,
    repo: $toml.repo,
    image: $toml.image,
    ref: $ref,
    tag: $toml.tag,
    platforms: $toml.platforms,
  };

  $app
}

def "main pull" [] {
  let app = init "pull"
  print $"($app.prelog) pulling (ansi green)($app.ref)(ansi reset) ..."
  podman manifest rm $app.ref out+err>| ignore
  podman rmi $app.ref out+err>| ignore
  podman manifest create $app.ref
  podman manifest add --all $app.ref docker://($app.ref)
  print $"($app.prelog) (ansi green)done(ansi reset)"
}

def "main build" [] {
  let app = init "build"
  print $"($app.prelog) building (ansi green)($app.host_platform)(ansi reset) ..."
  podman build --platform $app.host_platform --manifest $app.ref .
  print $"($app.prelog) (ansi green)done(ansi reset)"
}

def "main tty" [] {
  let app = init "build"
  podman run -it $app.ref
}

def "main publish" [] {
  let app = init "publish"

  # login if needed
  try { podman login --get-login $app.repo out+err>| ignore } catch {
    print $"($app.prelog) logging in to (ansi green)($app.repo)(ansi reset) ..."
    podman login $app.repo
  }

  # build the local platform first so that we catch errors faster
  let host_platform = $"linux/(podman machine info --format '{{.Host.Arch}}')"
  print $"($app.prelog) building (ansi green)($app.host_platform)(ansi reset) ..."
  podman build --platform $app.host_platform --manifest $app.ref .

  # linux only: build everything else
  if $nu.os-info.name == "linux" {
    for platform in $app.platforms {
      if $platform == $app.host_platform { continue }
      print $"($app.prelog) building (ansi green)($platform)(ansi reset) ..."
      podman build --platform $platform --manifest $app.ref .
    }
  }

  print $"($app.prelog) pushing to (ansi green)($app.repo)(ansi reset) ..."
  podman manifest push --all $app.ref

  print $"($app.prelog) (ansi green)done(ansi reset)"
}

def main [] { help main }
