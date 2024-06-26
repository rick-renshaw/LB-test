locals {
  mps_cidrs = [
    "10.10.100.0/22",
    "192.18.55.0/24",
    "216.17.31.166/32"
  ]

  type = "network"
  # type = "application"

  http_protocol = local.type == "network" ? "TCP" : "HTTP"
}

