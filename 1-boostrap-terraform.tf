# Configure the OpenStack Provider
# It will read info from env OS_xxx
provider "openstack" {
}

#
# SSH key
#
resource "openstack_compute_keypair_v2" "keypairs" {
  name          = "cat-arnaud-ovh"
  count         = "${length(var.regions)}"
  region        = "${element(var.regions, count.index)}"
  public_key    = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDOYsxhRRwC4+uKhJLuoPpNhf1jD97R/S5KnegmCF45QxnSbwfJq4XxBMLc8+BOqP1HLAIRW6HfdZMxkpVVi0aVdYSjJdtBA/9ImceqB0uvXP8Zhsivmr+/u/PB30bUS1/yblOAT62Hxu17KYv79g1FhJa3sJNQ5InzgDOUmLMCYczacMKpVQUFoj92zO3HSe0SXGSBh4++So4rcvD5Dywz6bmMbM/mtzSym95D53RwsJ/9a3CQa3BqIqoRNX/zjGS4C7tpqi1AlwFyBjJzOjqjwDYcTfune22DLnotMX06Salnhp1MZHuhffyUdu8Bkk3RjMiVtTwOECZGr59Ovj5aE2J/xPeDiCWg1J/ois0Zl4TeVipgWL9p/ULBtVS4LpFHO2GKy10rQfW10oYgclR+gfM9SEq3ZuKZmXHieNDUogHCW1oZRi1M3Z7hJEe6C5dmerx02cXb1CBp1OebmrKxQMBt8QtWpnKEE+74GEUbjyRI8oDGOzdTPhkvH6M1o7WyyWmxLwtFkuQkaKxa5lGju+LXJb9tnAyijjpH1h0BldWuEdfiijuIaRieDj1CBDDnn9Ukcjl1eYqGC0KX3M4rq5EIMHwZ8Nb4Lrb6SqUKWz2RYKKWIsT3rJFa3jKiUVzSODM8cGf0rFTKqXihCdqvfkdAYchKli1U6xaEZdl0zw=="
}

#
# Private networking
#
# Create the subnets
resource "openstack_networking_subnet_v2" "subnets" {
  name              = "subnet_${element(var.regions, count.index)}"
  count             = "${length(var.regions)}"
  network_id        = "${element(var.networks, count.index)}"
  cidr              = "192.168.1.0/24"
  region            = "${element(var.regions, count.index)}"
  allocation_pools  = {
    start   = "192.168.1.1${count.index}0"
    end     = "192.168.1.1${count.index}9"
  }
  no_gateway        = "true"
  enable_dhcp       = "true"
}

# Create a router, to give backends access to internet, through NAT
resource "openstack_compute_instance_v2" "router" {
  name          = "router"
  region        = "SBG3"
  image_name    = "Debian 8"
  key_pair      = "cat-arnaud-ovh"
  flavor_name   = "c2-7"

  # Network configuration
  # This VM has double attachement:
  #  - one public interface to internet
  #  - one private interface to communicate with backends
  network       = { name = "Ext-Net" }
  network       = {
    name        = "VLAN"
    fixed_ip_v4 = "192.168.1.1"
  }

  # Postinstall
  connection    = { user = "debian" }
  user_data     = "${file("router.yaml")}"
}

#
# BACKENDS
#
# Create one backend per region
resource "openstack_compute_instance_v2" "backends" {
  name          = "${format("backend-%s", element(var.regions, count.index))}"
  count         = "${length(var.regions)}"
  region        = "${element(var.regions, count.index)}"
  image_name    = "Debian 8"
  key_pair      = "cat-arnaud-ovh"
  flavor_name   = "c2-7"

  # Network configuration
  # This VM has only one interface:
  #  - private interface to communicate with frontend
  # Direct access from internet is not possible
  # Access from VM to internet is possible thanks to router (NAT)
  network       = {
    name        = "VLAN"
    fixed_ip_v4 = "192.168.1.1${count.index+1}"
  }

  # Postinstall
  connection    = { user = "debian" }
  user_data     = "${file("backend.yaml")}"

  # Ordering
  # We need router before spawning the backends
  depends_on    = ["openstack_compute_instance_v2.router"]
}

#
# FRONTEND
#
# Create template for frontend user_data
# The user_data is filled with backends IP before spawning the frontend
data "template_file" "frontend_user_data" {
  template = "${file("frontend.yaml.tpl")}"
  vars {
    nodes = "${join("\n", formatlist("    server %s %s:5000 check", openstack_compute_instance_v2.backends.*.name, openstack_compute_instance_v2.backends.*.access_ip_v4))}"
  }
}

# Create one frontend
resource "openstack_compute_instance_v2" "frontend" {
  name          = "frontend"
  region        = "SBG3"
  image_name    = "Debian 8"
  key_pair      = "cat-arnaud-ovh"
  flavor_name   = "c2-7"

  # Network configuration
  # This VM has double attachement:
  #  - one public interface to be reachable from internet
  #  - one private interface to communicate with backends
  network       = { name = "Ext-Net" }
  network       = { name = "VLAN" }

  # Postinstall
  connection    = { user = "debian" }
  user_data     = "${data.template_file.frontend_user_data.rendered}"
}

#
# OUTPUT
#
output "router" {
  value = "${format("%s", openstack_compute_instance_v2.router.access_ip_v4)}"
}

output "backends" {
  value = "${join("\n", formatlist("http://%s:5000", openstack_compute_instance_v2.backends.*.access_ip_v4))}"
}

output "frontend" {
  value = "${format("http://%s", openstack_compute_instance_v2.frontend.access_ip_v4)}"
}

