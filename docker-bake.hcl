// This is what is baked by GitHub Actions
group "default" { targets = ["worker", "web"] }

// Targets filled by GitHub Actions: one for the regular tag, one for the debug tag
target "docker-metadata-action-worker" {}
target "docker-metadata-action-web" {}

// This sets the platforms and is further extended by GitHub Actions to set the
// output and the cache locations
target "base" {
  platforms = [
    "linux/amd64",
    "linux/arm64",
  ]
}

target "worker" {
  inherits = ["base", "docker-metadata-action-worker"]
  target = "worker"
}

target "web" {
  inherits = ["base", "docker-metadata-action-web"]
  target = "web"
}
