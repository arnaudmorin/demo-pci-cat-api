# Configure the OpenStack Provider
# It will read info from env OS_xxx
provider "openstack" {
}

terraform {
  backend "swift" {
    path        = "terraform-state"
    region_name = "SBG3"
  }
}

# Configure the OVH Provider
# It will also read info from env OVH_xxx
provider "ovh" {
}

#
# SSH key
#
resource "openstack_compute_keypair_v2" "ssh_keys" {
  name          = "${var.ssh_key["name"]}"
  count         = "${length(var.regions)}"
  region        = "${element(var.regions, count.index)}"
  public_key    = "${var.ssh_key["value"]}"
}

#
# Private net and subnet
#

# Network
resource "ovh_publiccloud_private_network" "network" {
  name              = "VLAN_${var.vlan_id}"
  regions           = "${var.regions}"
  vlan_id           = "${var.vlan_id}"
}

# Subnet
resource "ovh_publiccloud_private_network_subnet" "subnets" {
  count             = "${length(var.regions)}"
  network_id        = "${ovh_publiccloud_private_network.network.id}"
  region            = "${element(var.regions, count.index)}"
  network           = "192.168.1.0/24"
  start             = "192.168.1.1${count.index}0"
  end               = "192.168.1.1${count.index}9"
  no_gateway        = "true"
  dhcp              = "true"
}

# Create a router, to give backends access to internet, through NAT
resource "openstack_compute_instance_v2" "router" {
  name          = "router"
  region        = "${var.regions[0]}"
  image_name    = "${var.image["name"]}"
  key_pair      = "${element(openstack_compute_keypair_v2.ssh_keys.*.name, count.index)}"
  flavor_name   = "${var.flavor}"

  # Network configuration
  # This VM has double attachement:
  #  - one public interface to internet
  #  - one private interface to communicate with backends
  network       = { name = "Ext-Net" }
  network       = {
    name        = "${ovh_publiccloud_private_network.network.name}"
    fixed_ip_v4 = "192.168.1.1"
  }

  # Postinstall
  connection    = { user = "${var.image["user"]}" }
  user_data     = "${file("router.sh")}"

  # Ordering
  # We need subnets before booting the router
  depends_on    = ["ovh_publiccloud_private_network_subnet.subnets"]
}

#
# BACKENDS
#
# Create one backend per region
resource "openstack_compute_instance_v2" "backends" {
  name          = "${format("backend-%s", element(var.regions, count.index))}"
  count         = "${length(var.regions)}"
  region        = "${element(var.regions, count.index)}"
  image_name    = "${var.image["name"]}"
  key_pair      = "${element(openstack_compute_keypair_v2.ssh_keys.*.name, count.index)}"
  flavor_name   = "${var.flavor}"

  # Network configuration
  # This VM has only one interface:
  #  - private interface to communicate with frontend
  # Direct access from internet is not possible
  # Access from VM to internet is possible thanks to router (NAT)
  network       = {
    name        = "${ovh_publiccloud_private_network.network.name}"
    fixed_ip_v4 = "192.168.1.1${count.index+1}"
  }

  # Postinstall
  connection    = { user = "${var.image["user"]}" }
  user_data     = "${file("backend.sh")}"

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
  template = "${file("frontend.sh.tpl")}"
  vars {
    nodes = "${join("\n", formatlist("    server %s %s:5000 check", openstack_compute_instance_v2.backends.*.name, openstack_compute_instance_v2.backends.*.access_ip_v4))}"
  }
}

# Create one frontend
resource "openstack_compute_instance_v2" "frontend" {
  name          = "frontend"
  region        = "${var.regions[0]}"
  image_name    = "${var.image["name"]}"
  key_pair      = "${element(openstack_compute_keypair_v2.ssh_keys.*.name, count.index)}"
  flavor_name   = "${var.flavor}"

  # Network configuration
  # This VM has double attachement:
  #  - one public interface to be reachable from internet
  #  - one private interface to communicate with backends
  network       = { name = "Ext-Net" }
  network       = { name = "${ovh_publiccloud_private_network.network.name}" }

  # Postinstall
  connection    = { user = "${var.image["user"]}" }
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

