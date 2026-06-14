#!/usr/bin/env nu
# build script for the box containerfile

const DEFAULT_SSH_PORT = 21524
const PLATES = [ "box", "empower" ] # parent layers must be ordered first

def prelog [name: string] {
    $"(ansi cyan)[($name)](ansi reset)"
}

def errlog [name: string] {
    $"(ansi red)[($name)] error:(ansi reset)"
}

# initialize podman and return an `app` object containing preloaded
# configuration for the `pod.toml` and `user.toml` files
def init [logname: string, plate: string] {
  let prelog = prelog $logname 
  let errlog = errlog $logname 
  
  # start the machine if needed
  if (podman info | complete).exit_code != 0 {
    print $"($prelog) starting machine ..."
    podman machine start
  }

  let arch = (podman machine info --format '{{.Host.Arch}}')
  let pod_toml = try { open pod.toml } catch {
    print -e $"($errlog) failed to read config: pod.toml"
  }

  let ref = $"($pod_toml.repo)/($pod_toml.image):($pod_toml.tag)"
  let host_platform = $"linux/($arch)"
  let version = open Containerfile | lines
    | parse 'LABEL name="{name}" version="{version}"'
    | where {|$l|
        $l.name == $pod_toml.image 
    }
    | first | get version

  mut app = {
    prelog: $prelog,
    errlog: $errlog,
    arch: $arch,
    host_platform: $host_platform,
    repo: $pod_toml.repo,
    image: $pod_toml.image,
    version: $version,
    ref: $ref,
    tag: $pod_toml.tag,
    platforms: $pod_toml.platforms,
  };

  $app
}

# pulls the latest sourcetrait/box images
def "main pull" [] {
    for plate in $PLATES {
        cd $plate
        let app = init "pull" $plate
        print $"($app.prelog) pulling (ansi green)($app.ref)(ansi reset) ..."
        podman manifest rm $app.ref out+err>| ignore
        podman rmi $app.ref out+err>| ignore
        podman manifest create $app.ref
        podman manifest add --all $app.ref docker://($app.ref)
        print $"($app.prelog) (ansi green)done(ansi reset)"
    }
}

def "main build" [] {
    for plate in $PLATES {
        cd $plate
        let app = init "pod/build" $plate
        print $"($app.prelog) building (ansi magenta)($app.host_platform)(ansi reset) ..."
        
        podman kill $app.container out+err>| ignore
        
        let image_id = (
            podman build --build-arg BASE="localhost/sourcetrait/box:latest" --platform $app.host_platform --manifest $app.ref .
                | tee { print }
                | lines | last | str trim
        )
        
        podman tag $image_id localhost/($app.image):($app.version)
        print $"($app.prelog) (ansi green)done(ansi reset)"
    }
}

# creates a new container
def "main create" [plate: string, container: string, force: bool = false] {
    cd $plate
    let app = init "pod/create" $plate
    
    if $force {
        podman container rm $container out+err>| ignore
    }
    
    let ssh_port = claim_port $DEFAULT_SSH_PORT 
    
    podman create --name $container -p ($ssh_port):22 --pull=never localhost/($app.image):($app.version)
    ssh-keygen -f ($nu.home-dir | path join '.ssh/known_hosts') -R $'[localhost]:($ssh_port)' err>| ignore
    print $"($app.prelog) (ansi green)done(ansi reset)"
}

def box_running [container: string] {
  podman ps -q -f name=($container) | str trim | is-not-empty
}

def start_box [container: string] {
  podman start $container | ignore
}

def stop_box [container: string] {
  if (box_running $container) {
    podman stop $container out+err>| ignore
  }
}

def container_ssh_port [container: string] {
    podman inspect mycontainer
        | from json
        | get 0.NetworkSettings.Ports
        | transpose container host
        | where host != null
        | each {|r| {
            host: ($r.host | each {|b| $b.HostPort} | first | into int)
            guest: ($r.container | split row "/" | first | into int)
        }}
        | where guest == 22
        | first | get host
}

def ports_claimed [] {
    let names = (podman ps -a --format '{{.Names}}' | lines)
    podman inspect ...$names
        | from json
        | each {|c| $c.HostConfig.PortBindings | values }
        | flatten
        | flatten
        | get HostPort
        | each {|p| $p | into int }
        | uniq
        | sort
}

def claim_port [start_port: int] {
    let claimed = (ports_claimed)
    mut port = $start_port
    while $port in $claimed {
        $port = $port + 1
    }
    
    $port
}

def "main ssh" [container: string] {
    let ssh_port = container_ssh_port $container

    if not (box_running $container) {
        print -n $"(prelog "ssh") starting (ansi magenta)($container)(ansi reset) ... "
        start_box $container
        print $"(ansi green)started(ansi reset)"
    }
    
    ssh ($container)@localhost -p $ssh_port
}

def "main stop" [container: string] {
    let prelog = prelog "stop"
    print -n $"($prelog) stopping (ansi magenta)($container)(ansi reset) ... "
    stop_box $container
    print $"(ansi green)stopped(ansi reset)"
}

def "main publish" [] {
    for plate in $PLATES {
        cd $plate
        let app = init "pod/publish" $plate
        
        # login if needed
        if (podman login --get-login $app.repo | complete).exit_code != 0 {
            print $"($app.prelog) logging in to (ansi magenta)($app.repo)(ansi reset) ..."
            podman login $app.repo
        }

        # build the local platform first so that we catch errors faster
        print $"($app.prelog) building (ansi magenta)($app.host_platform)(ansi reset) ..."
        podman build --build-arg BASE="ghcr.io/sourcetrait/box:latest" --platform $app.host_platform --manifest $app.ref .
        
        # linux only: build everything else
        if $nu.os-info.name == "linux" {
            for platform in $app.platforms {
                if $platform == $app.host_platform { continue }
                print $"($app.prelog) building (ansi magenta)($platform)(ansi reset) ..."
                podman build --build-arg BASE="ghcr.io/sourcetrait/box:latest" --platform $platform --manifest $app.ref .
            }
        }
        
        print $"($app.prelog) pushing to (ansi magenta)($app.repo)(ansi reset) ..."
        podman manifest push --all $app.ref
    }
        
    print $"(prelog "build") (ansi green)done(ansi reset)"
}

def main [] { help main }
