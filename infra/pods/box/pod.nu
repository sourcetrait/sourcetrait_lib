#!/usr/bin/env nu

def init [logname: string] {
  let prelog = $"(ansi cyan)[($logname)](ansi reset)"
  let errlog = $"(ansi red)[($logname)] error:(ansi reset)"
  
  # start the machine if needed
  if (podman info | complete).exit_code != 0 {
    print $"($prelog) starting machine ..."
    podman machine start
  }

  let pod_toml = try { open pod.toml } catch {
    print -e $"($errlog) failed to read config: pod.toml"
  }
  let user_toml = try { open user.toml } catch {
    print -e $"($errlog) failed to read config: user.toml"
  }

  let ref = $"($pod_toml.repo)/($pod_toml.image):($pod_toml.tag)"
  let arch = (podman machine info --format '{{.Host.Arch}}')
  let host_platform = $"linux/($arch)"

  mut app = {
    prelog: $prelog,
    errlog: $errlog,
    arch: $arch,
    host_platform: $host_platform,
    repo: $pod_toml.repo,
    image: $pod_toml.image,
    ref: $ref,
    tag: $pod_toml.tag,
    platforms: $pod_toml.platforms,
    container: $user_toml.container,
    ssh_port: $user_toml.ssh_port,
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
  let app = init "pod/build"
  print $"($app.prelog) building (ansi magenta)($app.host_platform)(ansi reset) ..."

  podman kill $app.container out+err>| ignore

  let image_id = (
    podman build --platform $app.host_platform --manifest $app.ref .
    | tee { print } | lines | last | str trim
  )

  podman tag $image_id localhost/($app.image):local

  podman container rm $app.container out+err>| ignore
  podman create --name $app.container -p($app.ssh_port):22 --pull=never localhost/($app.image):local
  ssh-keygen -f ($nu.home-dir | path join '.ssh/known_hosts') -R $'[localhost]:($app.ssh_port)' err>| ignore

  print $"($app.prelog) (ansi green)done(ansi reset)"
}

def box_running [app: record] {
  podman ps -q -f name=($app.container) | str trim | is-not-empty
}

def start_box [app: record] {
  podman start $app.container | ignore
}

def stop_box [app: record] {
  if (box_running $app) {
    podman stop $app.container out+err>| ignore
  }
}

def "main ssh" [] {
  let app = init "pod/ssh"

  if not (box_running $app) {
    print -n $"($app.prelog) starting (ansi magenta)($app.container)(ansi reset) ... "
    start_box $app
    print $"(ansi green)started(ansi reset)"
  }

  ssh box@localhost -p $app.ssh_port
}

def "main stop" [] {
  let app = init "pod/stop"
  print -n $"($app.prelog) stopping (ansi magenta)($app.container)(ansi reset) ... "
  stop_box $app
  print $"(ansi green)stopped(ansi reset)"
}

def "main publish" [] {
  let app = init "pod/publish"

  # login if needed
  try { podman login --get-login $app.repo out+err>| ignore } catch {
    print $"($app.prelog) logging in to (ansi magenta)($app.repo)(ansi reset) ..."
    podman login $app.repo
  }

  # build the local platform first so that we catch errors faster
  let host_platform = $"linux/(podman machine info --format '{{.Host.Arch}}')"
  print $"($app.prelog) building (ansi magenta)($app.host_platform)(ansi reset) ..."
  podman build --platform $app.host_platform --manifest $app.ref .

  # linux only: build everything else
  if $nu.os-info.name == "linux" {
    for platform in $app.platforms {
      if $platform == $app.host_platform { continue }
      print $"($app.prelog) building (ansi magenta)($platform)(ansi reset) ..."
      podman build --platform $platform --manifest $app.ref .
    }
  }

  print $"($app.prelog) pushing to (ansi magenta)($app.repo)(ansi reset) ..."
  podman manifest push --all $app.ref

  print $"($app.prelog) (ansi green)done(ansi reset)"
}

def main [] { help main }
